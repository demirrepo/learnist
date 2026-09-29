-- Lesson scores: one row per student and lesson holding the best score
-- (0–100) of each of the five sections, and a complete_lesson() that only
-- unlocks the next lesson when their average is at least 80.
--
-- Safe to re-run. Paste into the Supabase SQL Editor after
-- 20260924090000_lesson_progression.sql.
--
-- Security model:
--   * Students read and write only their own rows (RLS). Scores are
--     computed in the app, so the server trusts the numbers it is sent;
--     the checks below only keep them in range.
--   * `user_progress` is still written only by complete_lesson().
--
-- Errors (message → meaning):
--   not_authenticated   no signed-in user
--   invalid_lesson      null or outside 1–52
--   invalid_section     not one of grammar, reading, listening, writing, speaking
--   invalid_score       null or outside 0–100
--   insufficient_score  section average below 80; DETAIL is 'Score: <n>'
--                       with the average rounded down

-- ---------------------------------------------------------------------------
-- Scores. A missing row, like a section never attempted, counts as 0.
-- ---------------------------------------------------------------------------

create table if not exists public.lesson_scores (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users (id) on delete cascade,
  lesson_number   smallint not null check (lesson_number between 1 and 52),
  grammar_score   smallint not null default 0 check (grammar_score between 0 and 100),
  reading_score   smallint not null default 0 check (reading_score between 0 and 100),
  listening_score smallint not null default 0 check (listening_score between 0 and 100),
  writing_score   smallint not null default 0 check (writing_score between 0 and 100),
  speaking_score  smallint not null default 0 check (speaking_score between 0 and 100),
  constraint lesson_scores_user_lesson_key unique (user_id, lesson_number)
);

alter table public.lesson_scores enable row level security;

drop policy if exists "Users can read their own lesson scores" on public.lesson_scores;
create policy "Users can read their own lesson scores"
  on public.lesson_scores for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can add their own lesson scores" on public.lesson_scores;
create policy "Users can add their own lesson scores"
  on public.lesson_scores for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own lesson scores" on public.lesson_scores;
create policy "Users can update their own lesson scores"
  on public.lesson_scores for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

revoke all on public.lesson_scores from anon;
revoke delete, truncate on public.lesson_scores from authenticated;
grant select, insert, update on public.lesson_scores to authenticated;

-- ---------------------------------------------------------------------------
-- save_section_score(p_lesson_number, p_section, p_score): stores the
-- caller's best score for one section, leaving the other four as they
-- were (0 for a new row).
-- ---------------------------------------------------------------------------

create or replace function public.save_section_score(
  p_lesson_number smallint,
  p_section       text,
  p_score         smallint
)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  if p_lesson_number is null or p_lesson_number not between 1 and 52 then
    raise exception 'invalid_lesson' using errcode = '22023';
  end if;

  if p_section is null
     or p_section not in ('grammar', 'reading', 'listening', 'writing', 'speaking') then
    raise exception 'invalid_section' using errcode = '22023';
  end if;

  if p_score is null or p_score not between 0 and 100 then
    raise exception 'invalid_score' using errcode = '22023';
  end if;

  insert into public.lesson_scores as s (
    user_id, lesson_number,
    grammar_score, reading_score, listening_score, writing_score, speaking_score
  )
  values (
    v_user, p_lesson_number,
    case when p_section = 'grammar'   then p_score else 0 end,
    case when p_section = 'reading'   then p_score else 0 end,
    case when p_section = 'listening' then p_score else 0 end,
    case when p_section = 'writing'   then p_score else 0 end,
    case when p_section = 'speaking'  then p_score else 0 end
  )
  on conflict (user_id, lesson_number) do update
     set grammar_score   = case when p_section = 'grammar'   then greatest(s.grammar_score, p_score) else s.grammar_score   end,
         reading_score   = case when p_section = 'reading'   then greatest(s.reading_score, p_score) else s.reading_score   end,
         listening_score = case when p_section = 'listening' then greatest(s.listening_score, p_score) else s.listening_score end,
         writing_score   = case when p_section = 'writing'   then greatest(s.writing_score, p_score) else s.writing_score   end,
         speaking_score  = case when p_section = 'speaking'  then greatest(s.speaking_score, p_score) else s.speaking_score  end;
end;
$$;

revoke execute on function public.save_section_score(smallint, text, smallint) from public, anon;
grant execute on function public.save_section_score(smallint, text, smallint) to authenticated;

-- ---------------------------------------------------------------------------
-- complete_lesson(completed_lesson): as before, returns the caller's
-- current_lesson after the call. When the completed lesson is the current
-- one it now also requires a section average of at least 80.
--
-- Completing an earlier lesson again is still a no-op and is not scored,
-- so lessons finished before scores existed never raise.
-- ---------------------------------------------------------------------------

create or replace function public.complete_lesson(completed_lesson smallint)
returns smallint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user        uuid := auth.uid();
  v_last_lesson constant smallint := 52;
  v_min_average constant numeric := 80;
  v_current     smallint;
  v_average     numeric;
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  if completed_lesson is null or completed_lesson not between 1 and v_last_lesson then
    raise exception 'invalid_lesson' using errcode = '22023';
  end if;

  -- Locked so a double tap advances once. No row means lesson 1.
  select current_lesson into v_current
  from public.user_progress
  where user_id = v_user
  for update;

  if coalesce(v_current, 1) <> completed_lesson then
    return coalesce(v_current, 1);
  end if;

  select (grammar_score + reading_score + listening_score
          + writing_score + speaking_score) / 5.0
    into v_average
  from public.lesson_scores
  where user_id = v_user
    and lesson_number = completed_lesson;

  v_average := coalesce(v_average, 0);

  if v_average < v_min_average then
    raise exception 'insufficient_score'
      using errcode = 'P0001',
            detail  = format('Score: %s', floor(v_average));
  end if;

  if v_current is null then
    insert into public.user_progress (user_id, current_lesson, updated_at)
    values (v_user, least(completed_lesson + 1, v_last_lesson), now())
    on conflict (user_id) do nothing;
  else
    update public.user_progress
       set current_lesson = least(completed_lesson + 1, v_last_lesson),
           updated_at     = now()
     where user_id = v_user;
  end if;

  select current_lesson into v_current
  from public.user_progress
  where user_id = v_user;

  return coalesce(v_current, 1);
end;
$$;

revoke execute on function public.complete_lesson(smallint) from public, anon;
grant execute on function public.complete_lesson(smallint) to authenticated;
