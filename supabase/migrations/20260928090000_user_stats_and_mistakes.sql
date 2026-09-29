-- Tracked quiz mistakes and the Home/Profile statistics.
--
-- Safe to re-run. Paste into the Supabase SQL Editor after
-- 20260927090000_lesson_scores.sql.
--
-- Security model:
--   * Students read and write only their own mistakes (RLS), like
--     `lesson_scores`: the quiz is graded in the app, so the server trusts
--     the question indexes it is sent and only keeps them in range.
--   * get_user_stats() runs as the caller, so RLS limits it to their rows.
--
-- Errors (message → meaning):
--   not_authenticated   no signed-in user
--   invalid_lesson      null or outside 1–52
--   invalid_section     not reading or listening
--   invalid_question    a null or negative index, or a null list

-- ---------------------------------------------------------------------------
-- Mistakes: one row per student and quiz question they got wrong.
-- `question_index` is the question's 0-based position in the lesson's
-- reading or listening quiz.
-- ---------------------------------------------------------------------------

create table if not exists public.user_mistakes (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references auth.users (id) on delete cascade,
  lesson_number  smallint not null check (lesson_number between 1 and 52),
  section        text not null check (section in ('reading', 'listening')),
  question_index smallint not null check (question_index >= 0),
  frequency      smallint not null default 1 check (frequency >= 1),
  resolved       boolean not null default false,
  constraint user_mistakes_user_question_key
    unique (user_id, lesson_number, section, question_index)
);

alter table public.user_mistakes enable row level security;

drop policy if exists "Users can read their own mistakes" on public.user_mistakes;
create policy "Users can read their own mistakes"
  on public.user_mistakes for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can add their own mistakes" on public.user_mistakes;
create policy "Users can add their own mistakes"
  on public.user_mistakes for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own mistakes" on public.user_mistakes;
create policy "Users can update their own mistakes"
  on public.user_mistakes for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

revoke all on public.user_mistakes from anon;
revoke delete, truncate on public.user_mistakes from authenticated;
grant select, insert, update on public.user_mistakes to authenticated;

-- ---------------------------------------------------------------------------
-- upsert_mistakes(p_lesson_number, p_section, p_wrong_indexes): records one
-- graded quiz. For that lesson and section:
--   * each wrong question is added, or its frequency goes up by one; a
--     mistake that had been resolved and is wrong again is reopened;
--   * each tracked mistake answered correctly this time is resolved.
-- An empty list resolves them all.
-- ---------------------------------------------------------------------------

create or replace function public.upsert_mistakes(
  p_lesson_number smallint,
  p_section       text,
  p_wrong_indexes integer[]
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

  if p_section is null or p_section not in ('reading', 'listening') then
    raise exception 'invalid_section' using errcode = '22023';
  end if;

  if p_wrong_indexes is null
     or exists (
       select 1 from unnest(p_wrong_indexes) as i
       where i is null or i not between 0 and 32767
     ) then
    raise exception 'invalid_question' using errcode = '22023';
  end if;

  update public.user_mistakes
     set resolved = true
   where user_id = v_user
     and lesson_number = p_lesson_number
     and section = p_section
     and not resolved
     and question_index <> all (p_wrong_indexes);

  insert into public.user_mistakes as m (
    user_id, lesson_number, section, question_index
  )
  select distinct v_user, p_lesson_number, p_section, i::smallint
  from unnest(p_wrong_indexes) as i
  on conflict (user_id, lesson_number, section, question_index) do update
     set frequency = least(m.frequency + 1, 32767),
         resolved  = false;
end;
$$;

revoke execute on function public.upsert_mistakes(smallint, text, integer[]) from public, anon;
grant execute on function public.upsert_mistakes(smallint, text, integer[]) to authenticated;

-- ---------------------------------------------------------------------------
-- get_user_stats(): the caller's statistics as
--   {
--     "lessons_mastered":       current_lesson - 1,
--     "current_lesson_mastery": section average of the current lesson,
--     "overall_average":        mean section average of completed lessons,
--     "tracked_mistakes":       unresolved mistakes
--   }
-- Averages are 0–100, rounded down like complete_lesson()'s, so 79.6
-- never reads as the 80 needed to move on. No progress row means lesson 1.
-- Completed lessons without scores (finished before scoring existed) are
-- left out of the overall average; with none it is 0.
-- ---------------------------------------------------------------------------

create or replace function public.get_user_stats()
returns jsonb
language plpgsql
stable
security invoker
set search_path = ''
as $$
declare
  v_user     uuid := auth.uid();
  v_current  smallint;
  v_mastery  numeric;
  v_average  numeric;
  v_mistakes integer;
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  select current_lesson into v_current
  from public.user_progress
  where user_id = v_user;

  v_current := coalesce(v_current, 1);

  select (grammar_score + reading_score + listening_score
          + writing_score + speaking_score) / 5.0
    into v_mastery
  from public.lesson_scores
  where user_id = v_user
    and lesson_number = v_current;

  select avg((grammar_score + reading_score + listening_score
              + writing_score + speaking_score) / 5.0)
    into v_average
  from public.lesson_scores
  where user_id = v_user
    and lesson_number < v_current;

  select count(*) into v_mistakes
  from public.user_mistakes
  where user_id = v_user
    and not resolved;

  return jsonb_build_object(
    'lessons_mastered',       v_current - 1,
    'current_lesson_mastery', floor(coalesce(v_mastery, 0))::integer,
    'overall_average',        floor(coalesce(v_average, 0))::integer,
    'tracked_mistakes',       v_mistakes
  );
end;
$$;

revoke execute on function public.get_user_stats() from public, anon;
grant execute on function public.get_user_stats() to authenticated;
