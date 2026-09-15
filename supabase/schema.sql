-- =============================================================================
-- Learnist — Supabase schema
-- Paste into the Supabase SQL Editor and run. Safe to re-run.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Shared helper: keep updated_at current on UPDATE
-- -----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;


-- -----------------------------------------------------------------------------
-- 1. profiles (1:1 with auth.users)
-- -----------------------------------------------------------------------------
create table if not exists public.profiles (
  id                   uuid primary key references auth.users (id) on delete cascade,
  full_name            text,
  username             text unique,
  university           text,
  cefr_level           text check (cefr_level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  last_cefr_check_date timestamptz,
  created_at           timestamptz not null default now()
);


-- -----------------------------------------------------------------------------
-- 2. topics (52-step roadmap; managed by admins / service role)
-- -----------------------------------------------------------------------------
create table if not exists public.topics (
  id                     bigint generated always as identity primary key,
  title                  text not null,
  order_index            integer not null unique check (order_index > 0),
  semester               smallint check (semester > 0),
  is_unlocked_by_default boolean not null default false
);


-- -----------------------------------------------------------------------------
-- 3. user_progress (one row per user per topic)
-- -----------------------------------------------------------------------------
create table if not exists public.user_progress (
  id           bigint generated always as identity primary key,
  user_id      uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  topic_id     bigint not null references public.topics (id) on delete cascade,
  is_completed boolean not null default false,
  score        integer check (score between 0 and 100),
  updated_at   timestamptz not null default now(),
  unique (user_id, topic_id)
);

create index if not exists user_progress_topic_id_idx on public.user_progress (topic_id);

drop trigger if exists user_progress_set_updated_at on public.user_progress;
create trigger user_progress_set_updated_at
  before update on public.user_progress
  for each row execute function public.set_updated_at();


-- -----------------------------------------------------------------------------
-- 4. test_attempts (append-only; aggregate counts only)
-- -----------------------------------------------------------------------------
create table if not exists public.test_attempts (
  id            bigint generated always as identity primary key,
  user_id       uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  topic_id      bigint not null references public.topics (id) on delete cascade,
  correct_count integer not null check (correct_count >= 0),
  total_count   integer not null check (total_count > 0),
  created_at    timestamptz not null default now(),
  check (correct_count <= total_count)
);

create index if not exists test_attempts_user_id_created_at_idx
  on public.test_attempts (user_id, created_at desc);
create index if not exists test_attempts_topic_id_idx on public.test_attempts (topic_id);


-- -----------------------------------------------------------------------------
-- 5. Auto-create a profile when a user signs up
--    Reads full_name / username / university from the sign-up metadata:
--    supabase.auth.signUp(email:, password:, data: {'full_name': ..., ...})
-- -----------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, username, university)
  values (
    new.id,
    nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
    nullif(trim(new.raw_user_meta_data ->> 'username'), ''),
    nullif(trim(new.raw_user_meta_data ->> 'university'), '')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- -----------------------------------------------------------------------------
-- 6. Row Level Security
-- -----------------------------------------------------------------------------
alter table public.profiles      enable row level security;
alter table public.topics        enable row level security;
alter table public.user_progress enable row level security;
alter table public.test_attempts enable row level security;

-- profiles: read and edit only your own row (rows are created by the trigger)
drop policy if exists "Users can view own profile" on public.profiles;
create policy "Users can view own profile"
  on public.profiles for select
  to authenticated
  using ((select auth.uid()) = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- Users may edit their personal details, but not cefr_level or
-- last_cefr_check_date — otherwise the client could skip the 10-day
-- level-check cooldown. Those columns are set server-side (service role).
revoke update on public.profiles from authenticated, anon;
grant update (full_name, username, university) on public.profiles to authenticated;

-- topics: every signed-in user can read; writes only via service role
drop policy if exists "Authenticated users can view topics" on public.topics;
create policy "Authenticated users can view topics"
  on public.topics for select
  to authenticated
  using (true);

-- user_progress: full CRUD on your own rows
drop policy if exists "Users can view own progress" on public.user_progress;
create policy "Users can view own progress"
  on public.user_progress for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can insert own progress" on public.user_progress;
create policy "Users can insert own progress"
  on public.user_progress for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update own progress" on public.user_progress;
create policy "Users can update own progress"
  on public.user_progress for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete own progress" on public.user_progress;
create policy "Users can delete own progress"
  on public.user_progress for delete
  to authenticated
  using ((select auth.uid()) = user_id);

-- test_attempts: read and add your own; history is immutable (no update/delete)
drop policy if exists "Users can view own test attempts" on public.test_attempts;
create policy "Users can view own test attempts"
  on public.test_attempts for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can insert own test attempts" on public.test_attempts;
create policy "Users can insert own test attempts"
  on public.test_attempts for insert
  to authenticated
  with check ((select auth.uid()) = user_id);


-- -----------------------------------------------------------------------------
-- 7. Username availability check (called by the app before sign-up)
--    Signed-out users can't read profiles under RLS, so this runs as the
--    function owner and returns only a boolean — no profile data is exposed.
-- -----------------------------------------------------------------------------
create or replace function public.is_username_available(p_username text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select not exists (
    select 1
    from public.profiles
    where lower(username) = lower(trim(p_username))
  );
$$;

revoke all on function public.is_username_available(text) from public;
grant execute on function public.is_username_available(text) to anon, authenticated;
