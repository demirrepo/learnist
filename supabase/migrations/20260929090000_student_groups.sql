-- Class groups: teachers create a group with a class login and password,
-- students join it with those credentials, and the teacher panel reads
-- their progress through get_teacher_dashboard() and get_student_detail().
--
-- Safe to re-run. Paste into the Supabase SQL Editor after
-- 20260928090000_user_stats_and_mistakes.sql.
--
-- Security model:
--   * A teacher reads only the groups they own. Students can't read
--     `student_groups` at all, so class logins and passwords never reach
--     them; joining goes through join_group(), which checks the password
--     on the server.
--   * The group password is a shared class code, not an account password:
--     it is stored as entered so the teacher panel can show it.
--   * Membership is written only by join_group(). A student sees their own
--     memberships; a teacher sees the members of their own groups.
--   * teaches_student() adds read-only access for a teacher to the
--     `profiles`, `user_progress` and `lesson_scores` rows of students in
--     their groups, and nothing else. The dashboard functions run as the
--     caller, so these policies are what limits them.
--   * The teacher role lives in user-editable metadata, so the insert
--     policy's role check only mirrors the app. A student who made a group
--     would still see only students who chose to join it.
--
-- Errors (message → meaning):
--   not_authenticated    no signed-in user
--   invalid_credentials  no group has this login and password
--   own_group            the caller created this group
--   student_not_found    not a student in one of the caller's groups

-- ---------------------------------------------------------------------------
-- Groups. Logins are stored upper-case, so joining ignores case; the app
-- normalises them before inserting.
-- ---------------------------------------------------------------------------

create table if not exists public.student_groups (
  id         uuid primary key default gen_random_uuid(),
  teacher_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name       text not null check (btrim(name) <> '' and char_length(name) <= 80),
  login_code text not null unique check (login_code ~ '^[A-Z0-9_-]{3,32}$'),
  password   text not null check (
    password = btrim(password) and char_length(password) between 4 and 64
  ),
  created_at timestamptz not null default now()
);

create index if not exists student_groups_teacher_idx
  on public.student_groups (teacher_id, created_at);

alter table public.student_groups enable row level security;

drop policy if exists "Teachers can read their own groups" on public.student_groups;
create policy "Teachers can read their own groups"
  on public.student_groups for select
  to authenticated
  using ((select auth.uid()) = teacher_id);

drop policy if exists "Teachers can create their own groups" on public.student_groups;
create policy "Teachers can create their own groups"
  on public.student_groups for insert
  to authenticated
  with check (
    (select auth.uid()) = teacher_id
    and (select auth.jwt()) -> 'user_metadata' ->> 'role' = 'teacher'
  );

revoke all on public.student_groups from anon;
revoke update, delete, truncate on public.student_groups from authenticated;
grant select, insert on public.student_groups to authenticated;

-- ---------------------------------------------------------------------------
-- Members: one row per student and group.
-- ---------------------------------------------------------------------------

create table if not exists public.group_members (
  group_id   uuid not null references public.student_groups (id) on delete cascade,
  student_id uuid not null references auth.users (id) on delete cascade,
  joined_at  timestamptz not null default now(),
  constraint group_members_group_student_key unique (group_id, student_id)
);

create index if not exists group_members_student_idx
  on public.group_members (student_id);

alter table public.group_members enable row level security;

drop policy if exists "Students can read their own memberships" on public.group_members;
create policy "Students can read their own memberships"
  on public.group_members for select
  to authenticated
  using ((select auth.uid()) = student_id);

drop policy if exists "Teachers can read their groups' members" on public.group_members;
create policy "Teachers can read their groups' members"
  on public.group_members for select
  to authenticated
  using (
    exists (
      select 1
      from public.student_groups g
      where g.id = group_id
        and g.teacher_id = (select auth.uid())
    )
  );

revoke all on public.group_members from anon;
revoke insert, update, delete, truncate on public.group_members from authenticated;
grant select on public.group_members to authenticated;

-- ---------------------------------------------------------------------------
-- teaches_student(p_student_id): whether the student is in one of the
-- caller's groups. Security definer so the policies below don't re-run
-- the membership policies for every row.
-- ---------------------------------------------------------------------------

create or replace function public.teaches_student(p_student_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.group_members m
    join public.student_groups g on g.id = m.group_id
    where m.student_id = p_student_id
      and g.teacher_id = (select auth.uid())
  );
$$;

revoke execute on function public.teaches_student(uuid) from public, anon;
grant execute on function public.teaches_student(uuid) to authenticated;

drop policy if exists "Teachers can view their students' profiles" on public.profiles;
create policy "Teachers can view their students' profiles"
  on public.profiles for select
  to authenticated
  using (public.teaches_student(id));

drop policy if exists "Teachers can read their students' progress" on public.user_progress;
create policy "Teachers can read their students' progress"
  on public.user_progress for select
  to authenticated
  using (public.teaches_student(user_id));

drop policy if exists "Teachers can read their students' lesson scores" on public.lesson_scores;
create policy "Teachers can read their students' lesson scores"
  on public.lesson_scores for select
  to authenticated
  using (public.teaches_student(user_id));

-- ---------------------------------------------------------------------------
-- join_group(p_login_code, p_password): adds the caller to the group, as
--   { "group_name": "English 301", "already_member": false }
-- Joining a group twice succeeds with "already_member": true. An unknown
-- login and a wrong password raise the same error, so logins can't be
-- probed.
-- ---------------------------------------------------------------------------

create or replace function public.join_group(p_login_code text, p_password text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user     uuid := auth.uid();
  v_group    public.student_groups%rowtype;
  v_inserted integer;
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  select * into v_group
  from public.student_groups
  where login_code = upper(btrim(coalesce(p_login_code, '')));

  if not found or v_group.password is distinct from btrim(p_password) then
    raise exception 'invalid_credentials' using errcode = 'P0001';
  end if;

  if v_group.teacher_id = v_user then
    raise exception 'own_group' using errcode = 'P0001';
  end if;

  insert into public.group_members (group_id, student_id)
  values (v_group.id, v_user)
  on conflict (group_id, student_id) do nothing;

  get diagnostics v_inserted = row_count;

  return jsonb_build_object(
    'group_name', v_group.name,
    'already_member', v_inserted = 0
  );
end;
$$;

revoke execute on function public.join_group(text, text) from public, anon;
grant execute on function public.join_group(text, text) to authenticated;

-- ---------------------------------------------------------------------------
-- get_teacher_dashboard(): the caller's groups and their students, as
--   {
--     "total_students":  distinct students across the groups,
--     "total_groups":    groups the caller owns,
--     "average_mastery": mean of the students' mastery,
--     "groups": [
--       { "id", "name", "login_code", "password",
--         "students": [
--           { "id", "full_name", "username", "current_lesson",
--             "mastery", "cefr_level" }
--         ] }
--     ]
--   }
-- Mastery is get_user_stats()'s "overall_average": the mean section
-- average of completed lessons, rounded down, so the teacher sees the
-- number the student sees. Groups are oldest first, students in joining
-- order. No progress row means lesson 1 and no CEFR level (null).
-- ---------------------------------------------------------------------------

create or replace function public.get_teacher_dashboard()
returns jsonb
language plpgsql
stable
security invoker
set search_path = ''
as $$
declare
  v_user   uuid := auth.uid();
  v_result jsonb;
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  with my_groups as (
    select g.id, g.name, g.login_code, g.password, g.created_at
    from public.student_groups g
    where g.teacher_id = v_user
  ),
  members as (
    select m.group_id, m.student_id, m.joined_at
    from public.group_members m
    join my_groups g on g.id = m.group_id
  ),
  students as (
    select
      d.student_id,
      p.full_name,
      p.username,
      coalesce(up.current_lesson, 1) as current_lesson,
      up.cefr_level,
      floor(coalesce(sc.average, 0))::integer as mastery
    from (select distinct student_id from members) d
    left join public.profiles p on p.id = d.student_id
    left join public.user_progress up on up.user_id = d.student_id
    left join lateral (
      select avg((ls.grammar_score + ls.reading_score + ls.listening_score
                  + ls.writing_score + ls.speaking_score) / 5.0) as average
      from public.lesson_scores ls
      where ls.user_id = d.student_id
        and ls.lesson_number < coalesce(up.current_lesson, 1)
    ) sc on true
  )
  select jsonb_build_object(
    'total_students',  (select count(*) from students),
    'total_groups',    (select count(*) from my_groups),
    'average_mastery', coalesce((select floor(avg(mastery)) from students), 0)::integer,
    'groups', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id',         g.id,
          'name',       g.name,
          'login_code', g.login_code,
          'password',   g.password,
          'students', coalesce((
            select jsonb_agg(
              jsonb_build_object(
                'id',             s.student_id,
                'full_name',      s.full_name,
                'username',       s.username,
                'current_lesson', s.current_lesson,
                'mastery',        s.mastery,
                'cefr_level',     s.cefr_level
              )
              order by m.joined_at, m.student_id
            )
            from members m
            join students s on s.student_id = m.student_id
            where m.group_id = g.id
          ), '[]'::jsonb)
        )
        order by g.created_at, g.id
      )
      from my_groups g
    ), '[]'::jsonb)
  )
  into v_result;

  return v_result;
end;
$$;

revoke execute on function public.get_teacher_dashboard() from public, anon;
grant execute on function public.get_teacher_dashboard() to authenticated;

-- ---------------------------------------------------------------------------
-- get_student_detail(p_student_id): the student's lessons from their
-- current one back to lesson 1, most recent first:
--   [
--     { "lesson_number": 3, "title": "...", "is_current": true,
--       "grammar": 85, "reading": 100, "listening": 0, "writing": 0,
--       "speaking": 0 },
--     ...
--   ]
-- A section never attempted reads 0, like in complete_lesson().
-- ---------------------------------------------------------------------------

create or replace function public.get_student_detail(p_student_id uuid)
returns jsonb
language plpgsql
stable
security invoker
set search_path = ''
as $$
declare
  v_user    uuid := auth.uid();
  v_current smallint;
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  if p_student_id is null or not public.teaches_student(p_student_id) then
    raise exception 'student_not_found' using errcode = 'P0002';
  end if;

  select current_lesson into v_current
  from public.user_progress
  where user_id = p_student_id;

  v_current := coalesce(v_current, 1);

  return coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'lesson_number', n.lesson_number,
        'title',         l.title,
        'is_current',    n.lesson_number = v_current,
        'grammar',       coalesce(s.grammar_score, 0),
        'reading',       coalesce(s.reading_score, 0),
        'listening',     coalesce(s.listening_score, 0),
        'writing',       coalesce(s.writing_score, 0),
        'speaking',      coalesce(s.speaking_score, 0)
      )
      order by n.lesson_number desc
    )
    from generate_series(1, v_current) as n (lesson_number)
    left join public.lessons l on l.lesson_number = n.lesson_number
    left join public.lesson_scores s
      on s.user_id = p_student_id
     and s.lesson_number = n.lesson_number
  ), '[]'::jsonb);
end;
$$;

revoke execute on function public.get_student_detail(uuid) from public, anon;
grant execute on function public.get_student_detail(uuid) to authenticated;
