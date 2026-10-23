"""Copy the speaking and writing tasks from Mavzula.docx into
lessons_seed_data.json.

    .venv/bin/python import_lesson_tasks.py            # update the seed file
    .venv/bin/python import_lesson_tasks.py --dry-run  # parse and print only

Then sync with `.venv/bin/python seed_supabase.py`.

Mavzula.docx holds one table: a header row, then one row per lesson with
"Lesson N." | speaking task | writing task. Each task cell is the task's
title followed by a paragraph starting "Instruction:". They become
`speaking_title` / `speaking_prompt` and `writing_title` / `writing_prompt`
of the lesson whose `lesson_number` is N.

Text is kept as written, except that whitespace (Word's non-breaking spaces,
stray tabs) is collapsed to single spaces and the typos in CORRECTIONS are
fixed.
"""

import json
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DOCX_FILE = ROOT / "Mavzula.docx"
DATA_FILE = ROOT / "lessons_seed_data.json"
EXPECTED_LESSONS = 52

W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"
INSTRUCTION = re.compile(r"^Instruction:\s*", re.IGNORECASE)
LESSON = re.compile(r"^Lesson\s+(\d+)\.?$", re.IGNORECASE)

# Typos in the source document, fixed wherever they appear.
CORRECTIONS = {"fir st time": "first time"}

TASKS = ("speaking", "writing")


def clean(text):
    text = " ".join(text.split())
    for wrong, right in CORRECTIONS.items():
        text = text.replace(wrong, right)
    return text


def paragraph_lines(paragraph):
    """The paragraph's text, split at line breaks: some cells put the
    title and the instruction in one paragraph with a break between."""
    parts = []
    for node in paragraph.iter():
        if node.tag == W + "t":
            parts.append(node.text or "")
        elif node.tag == W + "tab":
            parts.append(" ")
        elif node.tag == W + "br":
            parts.append("\n")
    return [clean(line) for line in "".join(parts).split("\n")]


def cell_paragraphs(cell):
    lines = (line for p in cell.iter(W + "p") for line in paragraph_lines(p))
    return [line for line in lines if line]


def parse_task(lesson, kind, cell):
    """Splits a task cell into its title and instruction."""
    paragraphs = cell_paragraphs(cell)
    starts = [i for i, text in enumerate(paragraphs) if INSTRUCTION.match(text)]
    if len(starts) != 1 or starts[0] == 0:
        sys.exit(
            f"Lesson {lesson} {kind} task: expected a title, then one "
            f"'Instruction:' paragraph; got {paragraphs!r}"
        )
    split = starts[0]
    title = " ".join(paragraphs[:split])
    instruction = INSTRUCTION.sub("", " ".join(paragraphs[split:]))
    if not instruction:
        sys.exit(f"Lesson {lesson} {kind} task has an empty instruction.")
    return title, instruction


def read_tasks():
    """Returns {lesson_number: {speaking_title: …, speaking_prompt: …, …}}."""
    with zipfile.ZipFile(DOCX_FILE) as docx:
        root = ET.fromstring(docx.read("word/document.xml"))
    tables = list(root.iter(W + "tbl"))
    if len(tables) != 1:
        sys.exit(f"{DOCX_FILE.name}: expected one table, found {len(tables)}.")

    tasks = {}
    rows = tables[0].findall(W + "tr")
    for row in rows[1:]:  # skip the header
        cells = row.findall(W + "tc")
        if len(cells) != 3:
            sys.exit(f"{DOCX_FILE.name}: a row has {len(cells)} cells, expected 3.")
        label = " ".join(cell_paragraphs(cells[0]))
        match = LESSON.match(label)
        if not match:
            sys.exit(f"{DOCX_FILE.name}: unexpected lesson label {label!r}.")
        lesson = int(match.group(1))
        if lesson in tasks:
            sys.exit(f"{DOCX_FILE.name}: lesson {lesson} appears twice.")

        fields = {}
        for kind, cell in zip(TASKS, cells[1:]):
            title, instruction = parse_task(lesson, kind, cell)
            fields[f"{kind}_title"] = title
            fields[f"{kind}_prompt"] = instruction
        tasks[lesson] = fields

    expected = set(range(1, EXPECTED_LESSONS + 1))
    if set(tasks) != expected:
        sys.exit(
            f"{DOCX_FILE.name}: missing lessons {sorted(expected - set(tasks))}, "
            f"unexpected {sorted(set(tasks) - expected)}."
        )
    return tasks


def with_tasks(lesson, fields):
    """The lesson with its task fields replaced, each title just before its
    prompt so the file reads in order."""
    updated = {}
    for key, value in lesson.items():
        if key.endswith("_title") and key in fields:
            continue  # re-added beside its prompt
        if key.endswith("_prompt") and key in fields:
            title = key.removesuffix("_prompt") + "_title"
            updated[title] = fields[title]
            value = fields[key]
        updated[key] = value
    return updated


def main():
    dry_run = "--dry-run" in sys.argv
    tasks = read_tasks()

    if dry_run:
        for number, fields in sorted(tasks.items()):
            print(f"Lesson {number}")
            for kind in TASKS:
                print(f"  {kind}: {fields[f'{kind}_title']}")
                print(f"    {fields[f'{kind}_prompt']}")
        print(f"\nParsed {len(tasks)} lessons. Dry run: nothing was written.")
        return

    lessons = json.loads(DATA_FILE.read_text(encoding="utf-8"))
    numbers = [lesson["lesson_number"] for lesson in lessons]
    if sorted(numbers) != sorted(tasks):
        sys.exit(f"{DATA_FILE.name} lesson numbers don't match {DOCX_FILE.name}.")

    lessons = [with_tasks(lesson, tasks[lesson["lesson_number"]]) for lesson in lessons]
    DATA_FILE.write_text(json.dumps(lessons, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Updated the speaking and writing tasks of {len(lessons)} lessons in {DATA_FILE.name}.")


if __name__ == "__main__":
    main()
