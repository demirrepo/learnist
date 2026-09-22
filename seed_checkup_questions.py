"""Seed `public.checkup_questions` from assets/data/checkup_questions.json.

Run the migration in supabase/migrations/20260922120000_checkup_system.sql
first, then:

    .venv/bin/python seed_checkup_questions.py            # upsert all 30
    .venv/bin/python seed_checkup_questions.py --dry-run  # validate only

Upserts on `id`, so re-running updates questions in place. Afterwards run
the `setval` statement at the bottom of the migration once. Uses the same
credentials as seed_supabase.py (SUPABASE_SERVICE_ROLE_KEY in .env.seed).
"""

import json
import sys
from pathlib import Path

from seed_supabase import create_client_from_env, progress_bar

ROOT = Path(__file__).resolve().parent
DATA_FILE = ROOT / "assets" / "data" / "checkup_questions.json"
TABLE = "checkup_questions"
LEVELS = ["A1", "A2", "B1", "B2", "C1", "C2"]
PER_LEVEL = 5
COLUMNS = ["id", "level", "question", "options", "answer_index"]


def load_questions():
    rows = json.loads(DATA_FILE.read_text(encoding="utf-8"))
    problems = []
    if not isinstance(rows, list):
        sys.exit(f"{DATA_FILE.name} must contain a JSON array.")

    ids = [row.get("id") for row in rows]
    if len(set(ids)) != len(ids):
        problems.append("duplicate ids")
    for level in LEVELS:
        count = sum(1 for row in rows if row.get("level") == level)
        if count != PER_LEVEL:
            problems.append(f"{level} has {count} questions, expected {PER_LEVEL}")

    for row in rows:
        label = f"question {row.get('id')}"
        if set(row) != set(COLUMNS):
            problems.append(f"{label}: keys {sorted(row)}")
            continue
        options = row["options"]
        if not isinstance(row["id"], int) or row["id"] < 1:
            problems.append(f"{label}: id must be a positive integer")
        if not isinstance(row["question"], str) or not row["question"].strip():
            problems.append(f"{label}: blank question")
        if not (
            isinstance(options, list)
            and len(options) >= 2
            and all(isinstance(o, str) and o.strip() for o in options)
            and len(set(options)) == len(options)
        ):
            problems.append(f"{label}: needs 2+ distinct non-blank options")
        elif not (
            isinstance(row["answer_index"], int)
            and 0 <= row["answer_index"] < len(options)
        ):
            problems.append(f"{label}: answer_index out of range")

    if problems:
        sys.exit("Question data is invalid:\n  " + "\n  ".join(problems))
    return sorted(rows, key=lambda row: row["id"])


def main():
    questions = load_questions()
    print(f"Loaded {len(questions)} valid questions from {DATA_FILE.name}")
    if "--dry-run" in sys.argv:
        print("Dry run: nothing was sent to Supabase.")
        return

    client = create_client_from_env()
    try:
        client.table(TABLE).upsert(questions, on_conflict="id").execute()
    except Exception as error:  # noqa: BLE001 — report and stop cleanly
        sys.exit(f"Seeding failed: {error}")
    print(progress_bar(len(questions), len(questions)))

    # Service role bypasses the column privilege, so this can count answers.
    count = client.table(TABLE).select("id", count="exact").execute().count
    print(f"Table `{TABLE}` now has {count} rows.")
    print(
        "Next: run the setval statement at the bottom of the migration once "
        "so new questions don't collide with ids 1–30."
    )


if __name__ == "__main__":
    main()
