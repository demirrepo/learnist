"""Translate every lesson's Uzbek `grammar_rules` into English, Russian and
Karakalpak with OpenAI, and write them to lessons_seed_data.json.

    .venv/bin/pip install openai python-dotenv
    .venv/bin/python translate_grammar.py                 # all lessons
    .venv/bin/python translate_grammar.py --lessons 1 12  # just these
    .venv/bin/python translate_grammar.py --langs kk      # one language
    .venv/bin/python translate_grammar.py --lenient       # looser Karakalpak checks

Then sync with `.venv/bin/python seed_supabase.py`.

Each lesson is split on paragraph boundaries into chunks small enough for
one response. A chunk goes out as a JSON list of paragraphs and must come
back as a list of the same length, so the layout survives; it is then
checked (table rows kept, line breaks kept, right script, no leftover Uzbek
in Karakalpak, plausible length) before it is accepted. Accepted chunks are
cached in .cache/grammar_translations.json, so a re-run after a failure only
pays for what is still missing.

Lessons whose rule is the generic site guide (`site_fallback_guide`) are
skipped: their translations are already complete.

Credentials: OPENAI_API_KEY from `.env`.
"""

import argparse
import hashlib
import json
import os
import re
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent
DATA_FILE = ROOT / "lessons_seed_data.json"
CACHE_FILE = ROOT / ".cache" / "grammar_translations.json"

MODEL = "gpt-4o-mini"
# Bump to invalidate the cache when the prompt changes meaningfully.
PROMPT_VERSION = 2
CHUNK_CHARS = 5000
# Enough of the existing translation to show style and terminology.
REFERENCE_CHARS = 1500
WORKERS = 8
ATTEMPTS = 4
# Tries at full size before a multi-paragraph chunk is split in half; the
# model merges or drops paragraphs far less often in smaller pieces.
ATTEMPTS_BEFORE_SPLIT = 2

LANGUAGES = {
    "en": "English",
    "ru": "Russian",
    "kk": "Karakalpak",
}

LANGUAGE_RULES = {
    "en": (
        "- When a line only gives the Uzbek meaning of the English example "
        "sentence or phrase right before it, DROP that Uzbek line: the reader "
        "already understands English. Keep and translate lines that explain "
        "something (e.g. 'Bu gap men haqimda.' → 'This sentence is about me.').\n"
        "- In 'english phrase — uzbek meaning' lines, drop the dash and the "
        "Uzbek meaning when it is just a literal translation ('My name — "
        "mening ismim' → 'My name'). Keep it, translated, when it explains "
        "a meaning or usage ('happen — sodir bo‘lmoq' → 'happen — to take "
        "place').\n"
        "- A paragraph may become an empty string if it was only an Uzbek "
        "gloss.\n"
        "- In tables, keep every row and every column. A column that only "
        "holds Uzbek translations stays in Uzbek, with its header translated "
        "as 'Uzbek'."
    ),
    "ru": (
        "- Keep English example sentences unchanged and translate the Uzbek "
        "gloss that follows them into Russian, on the same line position.\n"
        "- Write natural, correct Russian with ё where standard."
    ),
    "kk": (
        "- Write Karakalpak, not Uzbek, Kazakh or Turkish, in the modern "
        "Karakalpak Latin alphabet (á, ǵ, ı, ń, ó, ú, sh, ch), exactly like "
        "the reference translation. Never use Cyrillic or the letters ş, ğ, "
        "ö, ü, ä, ə, ç, and never Uzbek o‘ / g‘.\n"
        "- Keep English example sentences unchanged and translate the Uzbek "
        "gloss that follows them into Karakalpak (I am a student. / Men "
        "talabaman. → I am a student. / Men studentpen.).\n"
        "- Only where the text quotes Uzbek on purpose ('In Uzbek we say "
        "Men talabaman') keep the quoted Uzbek words, and keep calling the "
        "language Uzbek (ózbek tili).\n"
        "- Uzbek → Karakalpak glossary: tasavvur qiling → kóz aldıńızǵa "
        "keltiriń; masalan → mısalı; misollar → mısallar; oddiy qilib → "
        "ápiwayı etip aytqanda; ingliz tili → inglis tili; talaba → student; "
        "o‘quvchi → oqıwshı; o‘qituvchi → oqıtıwshı; men/sen/siz/u/biz/ular → "
        "men/sen/siz/ol/biz/olar; bu → bul; narsa → zat; joy → orın; "
        "ayol → hayal; erkak → er adam; o‘g‘il bola → ul bala; lekin → "
        "biraq; odatda → ádette; ko‘pincha → kóbinese; shuning uchun → "
        "sonlıqtan; ya’ni → yaǵnıy; kerak → kerek; ishlatiladi → "
        "qollanıladı; gap → gáp; fe’l → feyil; sifat → kelbetlik; ot → "
        "atlıq; olmosh → almasıq; ega → baslawısh; kesim → bayanlawısh; "
        "to‘ldiruvchi → tolıqlawısh; savol → soraw; javob → juwap; inkor → "
        "biykar; yoki → yamasa; va → hám; bilan → menen; uchun → ushın; "
        "emas → emes; nima → ne; qayerda → qay jerde; qachon → qashan; "
        "nega → nege; har kuni → hár kúni; kecha → keshe; ertaga → erteń; "
        "bugun → búgin; yil → jıl; vaqt → waqıt; harakat → háreket; "
        "qoida → qaǵıyda; qo‘shimcha → qosımsha; yaxshi → jaqsı; katta → "
        "úlken; kichik → kishkene; yangi → jańa; shahar → qala; maktab → "
        "mektep; kitob → kitap; do‘st → dos; oila → shańaraq; ish → jumıs; "
        "o‘rganmoq → úyreniw; tushuntirmoq → túsindiriw."
    ),
}

SYSTEM_PROMPT = """You translate grammar explanations for an English course \
taught to Uzbek university students. The source is Uzbek (Latin script). \
Translate it into {language}.

Rules:
- English example sentences, words and grammar terms written in English stay \
exactly as they are. Translate everything written in Uzbek: explanations, \
headings, notes and glosses.
- Where the text compares English with the Uzbek language, keep that meaning \
and keep any Uzbek example words it quotes.
- The input is a JSON object {{"paragraphs": [...]}}. Return the same shape \
with exactly one translated string per input paragraph, in order, even when \
a paragraph is a sentence fragment. Inside each paragraph keep the same line \
breaks (\\n): an example sentence and its gloss stay on separate lines. \
Keep numbering and bullets ("1.", "a)", "•") and symbols (✅ ❌ →). Table \
lines have cells separated by " | "; keep every table line and its cell \
count.
- Translate everything; do not summarise, shorten, add comments or wrap the \
answer in code fences.
{language_rules}

The lesson is "{title}" (grammar focus: {focus}). The text may be one part of \
a longer lesson; translate only the text you are given.

For style and terminology, here is how the beginning of this lesson was \
translated before (its line layout may differ; follow the rules above for \
layout):
<reference>
{reference}
</reference>"""

CYRILLIC = re.compile(r"[Ѐ-ӿ]")
TABLE_LINE = " | "

RESPONSE_FORMAT = {
    "type": "json_schema",
    "json_schema": {
        "name": "translation",
        "strict": True,
        "schema": {
            "type": "object",
            "properties": {"paragraphs": {"type": "array", "items": {"type": "string"}}},
            "required": ["paragraphs"],
            "additionalProperties": False,
        },
    },
}

cache_lock = threading.Lock()


def chunk(text, limit=CHUNK_CHARS):
    """Split on blank lines into pieces of at most ~limit characters."""
    chunks, current = [], ""
    for paragraph in text.split("\n\n"):
        if current and len(current) + 2 + len(paragraph) > limit:
            chunks.append(current)
            current = paragraph
        else:
            current = f"{current}\n\n{paragraph}" if current else paragraph
    if current:
        chunks.append(current)
    return chunks


def cache_key(lang, text):
    raw = f"{PROMPT_VERSION}\0{MODEL}\0{lang}\0{text}"
    return hashlib.sha256(raw.encode()).hexdigest()


def load_cache():
    if CACHE_FILE.exists():
        return json.loads(CACHE_FILE.read_text(encoding="utf-8"))
    return {}


def save_cache(cache):
    CACHE_FILE.parent.mkdir(exist_ok=True)
    tmp = CACHE_FILE.with_suffix(".tmp")
    tmp.write_text(json.dumps(cache, ensure_ascii=False), encoding="utf-8")
    tmp.replace(CACHE_FILE)


UZBEK_WORDS = re.compile(
    r"\b(?:uchun|bilan|lekin|odatda|ishlatiladi|ya’ni|shuning|qiling|"
    r"misollar|masalan|kerak|narsa)\b",
    re.IGNORECASE,
)
# "My name — my name": a gloss translated back into the phrase it glosses.
SAME_BOTH_SIDES = re.compile(r"^(.+?) — (?i:\1)$", re.MULTILINE)
FOREIGN_LATIN = re.compile(r"[şŞğĞöÖüÜäÄəƏçÇ]")


def problems(lang, source, output, lenient=False):
    """Reasons to reject a translated chunk; empty when it looks right.

    `source` and `output` are lists of paragraphs of the same length.
    `lenient` skips the Karakalpak wording checks, keeping the structural ones.
    """
    found = []
    joined_in, joined_out = "\n\n".join(source), "\n\n".join(output)
    table_in = sum(TABLE_LINE in line for line in joined_in.split("\n"))
    table_out = sum(TABLE_LINE in line for line in joined_out.split("\n"))
    if table_in != table_out:
        found.append(f"table lines {table_out}, expected {table_in}")
    ratio = len(joined_out) / max(1, len(joined_in))
    low = 0.3 if lang == "en" else 0.6
    if not low <= ratio <= 2.2:
        found.append(f"length ratio {ratio:.2f}")
    cyrillic = len(CYRILLIC.findall(joined_out))
    if lang == "ru" and cyrillic < len(joined_out) * 0.15:
        found.append("too little Cyrillic for Russian")
    if lang != "ru" and cyrillic:
        found.append(f"{cyrillic} Cyrillic characters")
    if lang != "en":
        if empty := sum(1 for p in output if not p.strip()):
            found.append(f"{empty} empty paragraphs")
        # A merged example + gloss loses a line; allow a couple of
        # legitimate re-wraps per chunk.
        reflowed = sum(
            a.count("\n") != b.count("\n") for a, b in zip(source, output)
        )
        if reflowed > 2:
            found.append(f"{reflowed} paragraphs changed their line breaks")
    if lang == "kk" and not lenient:
        if foreign := FOREIGN_LATIN.findall(joined_out):
            found.append(f"non-Karakalpak letters {''.join(sorted(set(foreign)))}")
        left = len(UZBEK_WORDS.findall(joined_out))
        if left > max(2, 0.2 * len(UZBEK_WORDS.findall(joined_in))):
            found.append(f"{left} untranslated Uzbek words")
    return found


def translate_chunk(client, lesson, lang, text, reference, lenient=False):
    source = text.split("\n\n")
    if len(source) == 1:
        return translate_piece(client, lesson, lang, source, reference, lenient, ATTEMPTS)
    try:
        return translate_piece(
            client, lesson, lang, source, reference, lenient, ATTEMPTS_BEFORE_SPLIT
        )
    except RuntimeError:
        middle = len(source) // 2
        return "\n\n".join(
            part
            for half in (source[:middle], source[middle:])
            if (part := translate_chunk(client, lesson, lang, "\n\n".join(half), reference, lenient))
        )


def translate_piece(client, lesson, lang, source, reference, lenient, attempts):
    system = SYSTEM_PROMPT.format(
        language=LANGUAGES[lang],
        language_rules=LANGUAGE_RULES[lang],
        title=lesson["title"],
        focus=lesson["grammar_focus"],
        reference=reference or "(none)",
    )
    last_error = None
    for attempt in range(1, attempts + 1):
        try:
            response = client.chat.completions.create(
                model=MODEL,
                temperature=0.2,
                max_tokens=16000,
                response_format=RESPONSE_FORMAT,
                messages=[
                    {"role": "system", "content": system},
                    {"role": "user", "content": json.dumps({"paragraphs": source}, ensure_ascii=False)},
                ],
            )
        except Exception as error:  # noqa: BLE001 — network/rate limit: retry
            last_error = str(error)
            time.sleep(2**attempt)
            continue
        choice = response.choices[0]
        if choice.finish_reason != "stop":
            last_error = f"finish_reason={choice.finish_reason}"
            continue
        output = [p.strip() for p in json.loads(choice.message.content)["paragraphs"]]
        if len(output) != len(source):
            last_error = f"{len(output)} paragraphs, expected {len(source)}"
            continue
        if not (issues := problems(lang, source, output, lenient)):
            return "\n\n".join(p for p in output if p)
        last_error = "; ".join(issues)
    raise RuntimeError(last_error)


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--lessons", type=int, nargs="*", help="lesson numbers")
    parser.add_argument("--langs", nargs="*", choices=LANGUAGES, default=list(LANGUAGES))
    parser.add_argument(
        "--lenient",
        action="store_true",
        help="accept Karakalpak with Turkish letters or leftover Uzbek words",
    )
    args = parser.parse_args()

    load_dotenv(ROOT / ".env")
    if not os.getenv("OPENAI_API_KEY"):
        sys.exit("OPENAI_API_KEY is not set (expected in .env).")
    from openai import OpenAI

    client = OpenAI()
    lessons = json.loads(DATA_FILE.read_text(encoding="utf-8"))
    selected = [
        lesson
        for lesson in lessons
        if lesson["grammar_rules_source"] == "lesson"
        and lesson["grammar_rules"]
        and (not args.lessons or lesson["lesson_number"] in args.lessons)
    ]

    cache = load_cache()
    jobs = []  # (lesson, lang, index, text, reference)
    for lesson in selected:
        for lang in args.langs:
            reference = (lesson.get(f"grammar_rules_{lang}") or "")[:REFERENCE_CHARS]
            for index, text in enumerate(chunk(lesson["grammar_rules"])):
                jobs.append((lesson, lang, index, text, reference))
    todo = [job for job in jobs if cache_key(job[1], job[3]) not in cache]
    print(f"{len(selected)} lessons, {len(jobs)} chunks, {len(todo)} to translate")

    failures = []
    with ThreadPoolExecutor(WORKERS) as pool:
        futures = {
            pool.submit(translate_chunk, client, lesson, lang, text, ref, args.lenient): (
                lesson,
                lang,
                i,
                text,
            )
            for lesson, lang, i, text, ref in todo
        }
        for done, future in enumerate(as_completed(futures), 1):
            lesson, lang, index, text = futures[future]
            label = f"lesson {lesson['lesson_number']} {lang} part {index + 1}"
            try:
                output = future.result()
            except RuntimeError as error:
                failures.append(f"{label}: {error}")
                print(f"[{done}/{len(todo)}] FAILED {label}: {error}")
                continue
            with cache_lock:
                cache[cache_key(lang, text)] = output
                save_cache(cache)
            print(f"[{done}/{len(todo)}] {label}")

    # Write a lesson's language only when every one of its chunks succeeded.
    written = 0
    for lesson in selected:
        for lang in args.langs:
            parts = [cache.get(cache_key(lang, text)) for text in chunk(lesson["grammar_rules"])]
            if all(parts):
                text = "\n\n".join(parts)
                if lang == "en":
                    text = SAME_BOTH_SIDES.sub(r"\1", text)
                lesson[f"grammar_rules_{lang}"] = text
                written += 1
    DATA_FILE.write_text(json.dumps(lessons, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Wrote {written} lesson translations to {DATA_FILE.name}.")

    if failures:
        print(f"\n{len(failures)} chunks failed; re-run to retry them:")
        print("  " + "\n  ".join(failures))
        sys.exit(1)


if __name__ == "__main__":
    main()
