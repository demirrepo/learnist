-- Grammar explanations in the other interface languages. `grammar_rules`
-- stays the Uzbek original; the app shows `grammar_rules_<code>` for the
-- picked language and falls back to Uzbek while a column is empty.
--
-- Safe to re-run. Paste into the Supabase SQL Editor BEFORE shipping an
-- app build that selects these columns (older builds ignore them), then run
-- `.venv/bin/python seed_supabase.py` to fill them from lessons_seed_data.json.

alter table public.lessons
  add column if not exists grammar_rules_en text,
  add column if not exists grammar_rules_ru text,
  add column if not exists grammar_rules_kk text;

comment on column public.lessons.grammar_rules_en is
  'English translation of grammar_rules. Null falls back to Uzbek.';
comment on column public.lessons.grammar_rules_ru is
  'Russian translation of grammar_rules. Null falls back to Uzbek.';
comment on column public.lessons.grammar_rules_kk is
  'Karakalpak (Latin) translation of grammar_rules. Null falls back to Uzbek.';
