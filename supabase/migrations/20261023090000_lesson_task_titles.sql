-- Titles of the speaking and writing tasks, from the client's Mavzula.docx.
-- `speaking_prompt` / `writing_prompt` hold each task's instruction; the app
-- shows the title above it and falls back to the lesson title while a
-- column is empty.
--
-- Safe to re-run. Paste into the Supabase SQL Editor BEFORE running
-- `.venv/bin/python seed_supabase.py` (which sends these columns) and
-- before shipping an app build that selects them (older builds ignore them).

alter table public.lessons
  add column if not exists speaking_title text,
  add column if not exists writing_title text;

comment on column public.lessons.speaking_title is
  'Title of the speaking task; speaking_prompt is its instruction.';
comment on column public.lessons.writing_title is
  'Title of the writing task; writing_prompt is its instruction.';
