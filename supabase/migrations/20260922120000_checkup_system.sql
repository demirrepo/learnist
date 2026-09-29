-- CEFR level check-up: questions, per-user progress, result history and the
-- submit_checkup() function that scores a submission on the server.
--
-- Safe to re-run. Paste into the Supabase SQL Editor, then seed the
-- questions with `.venv/bin/python seed_checkup_questions.py` and run the
-- `setval` at the bottom of this file once.
--
-- Security model:
--   * Students can read question text and options, but not `answer_index`
--     (column privilege), so answers never reach the app.
--   * Students can read their own progress and history but cannot write
--     either table. Every write goes through submit_checkup(), which
--     enforces the 10-day cooldown and computes the level itself.

-- ---------------------------------------------------------------------------
-- Questions
-- ---------------------------------------------------------------------------

create table if not exists public.checkup_questions (
  id           serial primary key,
  level        text not null check (level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  question     text not null check (btrim(question) <> ''),
  options      text[] not null check (cardinality(options) >= 2),
  answer_index smallint not null,
  constraint checkup_questions_answer_in_range
    check (answer_index >= 0 and answer_index < cardinality(options))
);

alter table public.checkup_questions enable row level security;

drop policy if exists "Signed-in users can read check-up questions"
  on public.checkup_questions;
create policy "Signed-in users can read check-up questions"
  on public.checkup_questions for select
  to authenticated
  using (true);

-- Supabase grants everything on new tables by default; narrow it to the
-- columns the app needs. `select *` from the app will fail, by design.
revoke all on public.checkup_questions from anon, authenticated;
grant select (id, level, question, options)
  on public.checkup_questions to authenticated;

-- ---------------------------------------------------------------------------
-- Progress: one row per user, created on the first submission. A missing
-- row means "lesson 1, no level, never checked".
-- ---------------------------------------------------------------------------

create table if not exists public.user_progress (
  user_id           uuid primary key references auth.users (id) on delete cascade,
  current_lesson    smallint not null default 1 check (current_lesson between 1 and 52),
  cefr_level        text check (cefr_level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  last_checkup_date timestamptz,
  updated_at        timestamptz not null default now()
);

alter table public.user_progress enable row level security;

drop policy if exists "Users can read their own progress" on public.user_progress;
create policy "Users can read their own progress"
  on public.user_progress for select
  to authenticated
  using ((select auth.uid()) = user_id);

revoke all on public.user_progress from anon;
revoke insert, update, delete, truncate on public.user_progress from authenticated;
grant select on public.user_progress to authenticated;

-- ---------------------------------------------------------------------------
-- History: one row per completed check-up, for the growth chart.
-- ---------------------------------------------------------------------------

create table if not exists public.checkup_history (
  id           bigint generated always as identity primary key,
  user_id      uuid not null references auth.users (id) on delete cascade,
  cefr_level   text not null check (cefr_level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  score        smallint not null check (score >= 0),
  total        smallint not null check (total > 0 and score <= total),
  -- {"A1": {"correct": 4, "total": 5}, ...}
  level_scores jsonb not null,
  taken_at     timestamptz not null default now()
);

create index if not exists checkup_history_user_taken_idx
  on public.checkup_history (user_id, taken_at);

alter table public.checkup_history enable row level security;

drop policy if exists "Users can read their own check-up history"
  on public.checkup_history;
create policy "Users can read their own check-up history"
  on public.checkup_history for select
  to authenticated
  using ((select auth.uid()) = user_id);

revoke all on public.checkup_history from anon;
revoke insert, update, delete, truncate on public.checkup_history from authenticated;
grant select on public.checkup_history to authenticated;

-- ---------------------------------------------------------------------------
-- submit_checkup(p_answers): scores one submission for the calling user.
--
-- p_answers maps every question id to the chosen option index:
--   {"1": 0, "2": 2, ..., "30": 1}
--
-- Level rule: a level counts as passed with at least 60% correct (3 of 5).
-- The result is the highest level reached by passing every level from A1
-- upwards, so lucky guesses at C2 can't outrank a failed B1. Failing A1
-- still records A1, the lowest level on the scale.
--
-- Errors (message → meaning):
--   not_authenticated   no signed-in user
--   checkup_cooldown    last check-up was under 10 days ago; HINT holds the
--                       next allowed time
--   invalid_answers     not an object, missing or unknown question ids
-- ---------------------------------------------------------------------------

create or replace function public.submit_checkup(p_answers jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user         uuid := auth.uid();
  v_now          timestamptz := now();
  v_cooldown     constant interval := interval '10 days';
  v_pass_ratio   constant numeric := 0.6;
  v_last         timestamptz;
  v_total        int;
  v_score        int;
  v_level_scores jsonb;
  v_level        text := 'A1';
  v_candidate    text;
  v_correct      int;
  v_level_total  int;
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  if p_answers is null or jsonb_typeof(p_answers) <> 'object' then
    raise exception 'invalid_answers' using errcode = '22023';
  end if;

  -- Serialise submissions per user so a double tap can't pass the
  -- cooldown check twice (this also covers users with no progress row yet).
  perform pg_advisory_xact_lock(hashtextextended(v_user::text, 0));

  select last_checkup_date into v_last
  from public.user_progress
  where user_id = v_user;

  if v_last is not null and v_now < v_last + v_cooldown then
    raise exception 'checkup_cooldown'
      using errcode = 'P0001', hint = (v_last + v_cooldown)::text;
  end if;

  select count(*) into v_total from public.checkup_questions;
  if v_total = 0 then
    raise exception 'invalid_answers' using errcode = '22023',
      detail = 'no check-up questions are seeded';
  end if;

  -- Exactly one numeric answer per question, and no unknown ids.
  if (select count(*) from jsonb_object_keys(p_answers)) <> v_total
     or exists (
       select 1
       from public.checkup_questions q
       where jsonb_typeof(p_answers -> q.id::text) is distinct from 'number'
     ) then
    raise exception 'invalid_answers' using errcode = '22023',
      detail = 'answer every question exactly once';
  end if;

  select
    jsonb_object_agg(s.level, jsonb_build_object('correct', s.correct, 'total', s.total)),
    sum(s.correct)::int
  into v_level_scores, v_score
  from (
    select
      q.level,
      -- Non-integer or out-of-range choices simply never match.
      count(*) filter (
        where (p_answers ->> q.id::text)::numeric = q.answer_index
      )::int as correct,
      count(*)::int as total
    from public.checkup_questions q
    group by q.level
  ) s;

  foreach v_candidate in array array['A1', 'A2', 'B1', 'B2', 'C1', 'C2'] loop
    v_correct     := coalesce((v_level_scores -> v_candidate ->> 'correct')::int, 0);
    v_level_total := coalesce((v_level_scores -> v_candidate ->> 'total')::int, 0);
    exit when v_level_total = 0 or v_correct < ceil(v_level_total * v_pass_ratio);
    v_level := v_candidate;
  end loop;

  insert into public.checkup_history
    (user_id, cefr_level, score, total, level_scores, taken_at)
  values
    (v_user, v_level, v_score, v_total, v_level_scores, v_now);

  insert into public.user_progress
    (user_id, cefr_level, last_checkup_date, updated_at)
  values
    (v_user, v_level, v_now, v_now)
  on conflict (user_id) do update
    set cefr_level        = excluded.cefr_level,
        last_checkup_date = excluded.last_checkup_date,
        updated_at        = excluded.updated_at;

  return jsonb_build_object(
    'cefr_level', v_level,
    'score', v_score,
    'total', v_total,
    'level_scores', v_level_scores,
    'taken_at', v_now
  );
end;
$$;

revoke execute on function public.submit_checkup(jsonb) from public, anon;
grant execute on function public.submit_checkup(jsonb) to authenticated;

-- ---------------------------------------------------------------------------
-- Run once after seeding: the seeder inserts explicit ids 1–30, so move the
-- serial sequence past them.
-- ---------------------------------------------------------------------------
-- select setval(
--   pg_get_serial_sequence('public.checkup_questions', 'id'),
--   (select max(id) from public.checkup_questions)
-- );
