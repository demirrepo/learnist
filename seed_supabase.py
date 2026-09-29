"""Seed the Supabase `lessons` table from lessons_seed_data.json.

Create the table first (SQL in the Supabase SQL Editor), then run:

    .venv/bin/python seed_supabase.py            # upsert all lessons
    .venv/bin/python seed_supabase.py --dry-run  # validate only, no network

Rows are upserted on `lesson_number`, so re-running updates lessons in place
instead of duplicating them.

Credentials: SUPABASE_URL is read from `.env`. The service_role key must go
in `.env.seed` (git-ignored) as SUPABASE_SERVICE_ROLE_KEY — never in `.env`,
because pubspec.yaml bundles `.env` into the Flutter app, and a service_role
key shipped in the app gives anyone full database access.
"""

import json
import os
import sys
from pathlib import Path

from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent
DATA_FILE = ROOT / "lessons_seed_data.json"
TABLE = "lessons"
BATCH_SIZE = 10
EXPECTED_LESSONS = 52

COLUMNS = [
    "lesson_number",
    "original_number",
    "semester",
    "title",
    "grammar_focus",
    "cefr_level",
    "topic",
    "task_meta",
    "grammar_rules",
    "grammar_rules_source",
    "reading_passage",
    "reading_format",
    "reading_vocabulary",
    "reading_questions",
    "listening_transcript",
    "listening_format",
    "listening_speakers",
    "listening_questions",
    "writing_prompt",
    "speaking_prompt",
]


def load_lessons():
    lessons = json.loads(DATA_FILE.read_text(encoding="utf-8"))
    if not isinstance(lessons, list):
        sys.exit(f"{DATA_FILE.name} must contain a JSON array.")

    problems = []
    numbers = [lesson.get("lesson_number") for lesson in lessons]
    if len(lessons) != EXPECTED_LESSONS:
        problems.append(f"expected {EXPECTED_LESSONS} lessons, found {len(lessons)}")
    if len(set(numbers)) != len(numbers):
        problems.append("duplicate lesson_number values")
    for lesson in lessons:
        missing = set(COLUMNS) - lesson.keys()
        unknown = lesson.keys() - set(COLUMNS)
        if missing or unknown:
            problems.append(
                f"lesson {lesson.get('lesson_number')}: "
                f"missing {sorted(missing)} unknown {sorted(unknown)}"
            )
    if problems:
        sys.exit("Seed data is invalid:\n  " + "\n  ".join(problems))

    # Send only known columns, in a stable order.
    return [{column: lesson[column] for column in COLUMNS} for lesson in lessons]


def create_client_from_env():
    load_dotenv(ROOT / ".env")
    load_dotenv(ROOT / ".env.seed", override=True)

    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
    if not url:
        sys.exit("SUPABASE_URL is not set (expected in .env).")
    if not key:
        # The anon key can't write here: RLS only grants reads.
        sys.exit(
            "SUPABASE_SERVICE_ROLE_KEY is not set.\n"
            "Add it to .env.seed (Supabase dashboard → Project Settings → API "
            "Keys → service_role). Do not put it in .env: that file ships "
            "inside the Flutter app."
        )

    from supabase import create_client

    return create_client(url, key)


def progress_bar(done, total, width=30):
    filled = round(width * done / total)
    return f"[{'#' * filled}{'.' * (width - filled)}] {done}/{total}"


def main():
    dry_run = "--dry-run" in sys.argv
    lessons = load_lessons()
    print(f"Loaded {len(lessons)} valid lessons from {DATA_FILE.name}")
    if dry_run:
        print("Dry run: nothing was sent to Supabase.")
        return

    client = create_client_from_env()
    total = len(lessons)
    done = 0
    for start in range(0, total, BATCH_SIZE):
        batch = lessons[start : start + BATCH_SIZE]
        first, last = batch[0]["lesson_number"], batch[-1]["lesson_number"]
        try:
            client.table(TABLE).upsert(batch, on_conflict="lesson_number").execute()
        except Exception as error:  # noqa: BLE001 — report and stop cleanly
            print(f"\nFailed on lessons {first}–{last}: {error}")
            print(
                f"{done} lessons were saved before the failure. Fix the error "
                "and re-run; upserts make that safe."
            )
            sys.exit(1)
        done += len(batch)
        print(f"\r{progress_bar(done, total)}  lessons {first}–{last}", end="", flush=True)

    print(f"\nSeeded {done} lessons into `{TABLE}`.")

    count = client.table(TABLE).select("lesson_number", count="exact").execute().count
    print(f"Table `{TABLE}` now has {count} rows.")


if __name__ == "__main__":
    main()
