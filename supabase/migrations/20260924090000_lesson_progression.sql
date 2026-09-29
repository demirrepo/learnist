-- Lesson progression: complete_lesson() lets a student unlock the next
-- lesson without write access to `user_progress`.
--
-- Safe to re-run. Paste into the Supabase SQL Editor.
--
-- Security model:
--   * Students still cannot write `user_progress` directly (see
--     20260922120000_checkup_system.sql). This function is the only way
--     `current_lesson` moves, and only ever by one step.
--   * It advances only when the completed lesson IS the current one, so
--     replaying an old lesson never moves a student back, and sending a
--     higher number never skips ahead.
--
-- Errors (message → meaning):
--   not_authenticated   no signed-in user
--   invalid_lesson      null or outside 1–52

-- ---------------------------------------------------------------------------
-- complete_lesson(completed_lesson): returns the caller's current_lesson
-- after the call (unchanged when the call was a no-op).
--
-- Students who have never taken a check-up have no progress row, which
-- means "lesson 1"; completing lesson 1 creates the row. Completing the
-- last lesson (52) leaves current_lesson at 52, the table's upper bound.
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
  v_current     smallint;
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  if completed_lesson is null or completed_lesson not between 1 and v_last_lesson then
    raise exception 'invalid_lesson' using errcode = '22023';
  end if;

  -- The WHERE is re-checked after a concurrent update commits, so a
  -- double tap advances once.
  update public.user_progress
     set current_lesson = least(completed_lesson + 1, v_last_lesson),
         updated_at     = now()
   where user_id = v_user
     and current_lesson = completed_lesson
  returning current_lesson into v_current;

  if not found then
    if completed_lesson = 1 then
      insert into public.user_progress (user_id, current_lesson, updated_at)
      values (v_user, 2, now())
      on conflict (user_id) do nothing;
    end if;

    select current_lesson into v_current
    from public.user_progress
    where user_id = v_user;
  end if;

  return coalesce(v_current, 1);
end;
$$;

revoke execute on function public.complete_lesson(smallint) from public, anon;
grant execute on function public.complete_lesson(smallint) to authenticated;
