"""Render every listening transcript to MP3 with Neural TTS and publish it.

For each lesson that has a `listening_transcript` but no `audio_url`, this
script speaks the transcript with Microsoft Edge's neural voices (free, no
API key), uploads the MP3 to the `listening_audios` Supabase bucket, and
writes the public URL back onto the lesson row.

Run the migration first (supabase/migrations/20260923090000_listening_audio.sql),
then:

    .venv/bin/pip install edge-tts supabase python-dotenv
    .venv/bin/python generate_audios.py             # only lessons missing audio
    .venv/bin/python generate_audios.py --limit 1   # try one lesson first
    .venv/bin/python generate_audios.py --force     # re-render everything
    .venv/bin/python generate_audios.py --dry-run   # render locally, upload nothing

Two-speaker transcripts ("Maya: Hi Daniel.") are split by speaker and voiced
alternately, so the dialogue sounds like two people. Anything else is read by
a single voice.

Credentials: SUPABASE_URL from `.env`, SUPABASE_SERVICE_ROLE_KEY from
`.env.seed` (git-ignored) — same split as seed_supabase.py, because
pubspec.yaml bundles `.env` into the Flutter app.
"""

import argparse
import asyncio
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent
OUT_DIR = ROOT / "audio_out"
TABLE = "lessons"
BUCKET = "listening_audios"

# Neural voices, in the order speakers appear in the transcript. Listed at
# `edge-tts --list-voices`; these two are the clearest en-US pair.
VOICES = ["en-US-AriaNeural", "en-US-GuyNeural"]
SOLO_VOICE = VOICES[0]

# Learners are A1–B2, so a touch slower than native pace.
RATE = "-8%"

# A failed render is almost always a dropped websocket; retry before giving up.
ATTEMPTS = 3
RETRY_DELAY = 3

# "Maya: Hi Daniel." / "Speaker 1: ..." — the name half of a dialogue line.
SPEAKER_LINE = re.compile(r"^\s*([A-Z][\w .'-]{0,30}?)\s*:\s+(.*\S)\s*$")


def parse_dialogue(transcript, speakers):
    """Split a transcript into (voice, text) segments.

    Lines are attributed to a speaker only when every non-blank line names
    one, so a stray colon in prose can't turn a monologue into a dialogue.
    Returns a single segment when there is nothing to split.
    """
    lines = [line for line in transcript.splitlines() if line.strip()]
    known = {name.strip().lower() for name in speakers or [] if name.strip()}

    parsed = []
    for line in lines:
        match = SPEAKER_LINE.match(line)
        if not match:
            return [(SOLO_VOICE, transcript.strip())]
        name, text = match.group(1), match.group(2)
        # Trust the column when it's there; fall back to the prefixes found.
        if known and name.lower() not in known:
            return [(SOLO_VOICE, transcript.strip())]
        parsed.append((name.lower(), text))

    order = []
    for name, _ in parsed:
        if name not in order:
            order.append(name)
    if len(order) < 2:
        return [(SOLO_VOICE, transcript.strip())]

    # More speakers than voices: the extras cycle back through the list.
    voice_of = {name: VOICES[i % len(VOICES)] for i, name in enumerate(order)}
    return [(voice_of[name], text) for name, text in parsed]


async def speak(text, voice):
    """Bytes of one utterance, retried on a dropped connection."""
    import edge_tts

    for attempt in range(1, ATTEMPTS + 1):
        audio = bytearray()
        try:
            async for chunk in edge_tts.Communicate(text, voice, rate=RATE, volume="+50%").stream():
                if chunk["type"] == "audio":
                    audio += chunk["data"]
            if audio:
                return bytes(audio)
            raise RuntimeError("edge-tts returned no audio")
        except Exception as error:  # noqa: BLE001 — any failure is worth a retry
            if attempt == ATTEMPTS:
                raise
            print(f"    retry {attempt}/{ATTEMPTS - 1} after {type(error).__name__}: {error}")
            await asyncio.sleep(RETRY_DELAY * attempt)


async def render(segments, path):
    """Speak every segment and write them to `path` as one MP3."""
    parts = []
    for voice, text in segments:
        parts.append(await speak(text, voice))
    path.write_bytes(b"".join(parts))
    remux(path)
    return path.stat().st_size


def remux(path):
    """Rewrite the concatenated frames into one clean MP3 stream.

    edge-tts returns raw 48 kbps CBR frames with no Xing header, so simply
    joining the segments already plays and already reports the right
    duration (players derive it from size ÷ bitrate). This is belt and
    braces: it normalises the stream if a voice ever renders at a different
    bitrate. Skipped when ffmpeg isn't installed.
    """
    if not shutil.which("ffmpeg"):
        return
    fixed = path.with_suffix(".fixed.mp3")
    result = subprocess.run(
        ["ffmpeg", "-y", "-loglevel", "error", "-i", str(path), "-c", "copy", str(fixed)],
        capture_output=True,
    )
    if result.returncode == 0 and fixed.exists() and fixed.stat().st_size:
        fixed.replace(path)
    else:
        fixed.unlink(missing_ok=True)


def create_client_from_env():
    load_dotenv(ROOT / ".env")
    load_dotenv(ROOT / ".env.seed", override=True)

    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
    if not url:
        sys.exit("SUPABASE_URL is not set (expected in .env).")
    if not key:
        # The anon key can't upload or update: RLS only grants reads.
        sys.exit(
            "SUPABASE_SERVICE_ROLE_KEY is not set.\n"
            "Add it to .env.seed (Supabase dashboard → Project Settings → API "
            "Keys → service_role). Do not put it in .env: that file ships "
            "inside the Flutter app."
        )

    from supabase import create_client

    return create_client(url, key)


def fetch_lessons(client, force):
    query = (
        client.table(TABLE)
        .select("lesson_number, title, listening_transcript, listening_speakers, audio_url")
        .not_.is_("listening_transcript", "null")
    )
    if not force:
        query = query.is_("audio_url", "null")
    return query.order("lesson_number").execute().data


def upload(client, path, lesson_number):
    """Upload (replacing any earlier take) and return the public URL."""
    remote = f"lesson_{lesson_number:02d}.mp3"
    client.storage.from_(BUCKET).upload(
        remote,
        path.read_bytes(),
        {"content-type": "audio/mpeg", "cache-control": "31536000", "upsert": "true"},
    )
    # storage3 leaves a bare "?" on the end when no transform is requested.
    return client.storage.from_(BUCKET).get_public_url(remote).rstrip("?")


def human(size):
    return f"{size / 1024:.0f} KB"


async def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--force", action="store_true", help="re-render lessons that already have audio")
    parser.add_argument("--limit", type=int, help="stop after N lessons")
    parser.add_argument("--dry-run", action="store_true", help="render locally, upload nothing, keep the files")
    args = parser.parse_args()

    client = create_client_from_env()
    lessons = fetch_lessons(client, args.force)
    if args.limit:
        lessons = lessons[: args.limit]
    if not lessons:
        print("Every lesson with a transcript already has audio. Nothing to do.")
        return

    OUT_DIR.mkdir(exist_ok=True)
    if not shutil.which("ffmpeg"):
        print("Note: ffmpeg not found, so the segments are joined as-is. That is\n"
              "      fine for edge-tts output; install ffmpeg only if a future\n"
              "      voice change makes durations look wrong.\n")

    total = len(lessons)
    print(f"{total} lesson(s) to render → bucket `{BUCKET}`\n")
    failures = []
    started = time.monotonic()

    for index, lesson in enumerate(lessons, start=1):
        number = lesson["lesson_number"]
        title = lesson["title"]
        segments = parse_dialogue(
            lesson["listening_transcript"], lesson.get("listening_speakers")
        )
        voices = len({voice for voice, _ in segments})
        path = OUT_DIR / f"lesson_{number:02d}.mp3"

        label = f"[{index:2d}/{total}] lesson {number:2d} · {title[:38]}"
        print(f"{label}\n    {len(segments)} segment(s), {voices} voice(s) … ", end="", flush=True)

        lesson_started = time.monotonic()
        try:
            size = await render(segments, path)
            print(f"{human(size)} in {time.monotonic() - lesson_started:.1f}s")

            if args.dry_run:
                print(f"    dry run: kept {path.relative_to(ROOT)}, not uploaded")
                continue

            url = await asyncio.to_thread(upload, client, path, number)
            await asyncio.to_thread(
                lambda: client.table(TABLE)
                .update({"audio_url": url})
                .eq("lesson_number", number)
                .execute()
            )
            print(f"    uploaded → {url}")
        except Exception as error:  # noqa: BLE001 — report, keep going
            print(f"\n    FAILED: {type(error).__name__}: {error}")
            failures.append(number)
        finally:
            if not args.dry_run:
                path.unlink(missing_ok=True)

    elapsed = time.monotonic() - started
    done = total - len(failures)
    print(f"\nDone: {done}/{total} lesson(s) in {elapsed / 60:.1f} min.")
    if failures:
        print(f"Failed lessons: {failures}")
        print("Re-run the script — it picks up only the rows still missing audio.")
        sys.exit(1)

    if not args.dry_run:
        remaining = (
            client.table(TABLE)
            .select("lesson_number", count="exact")
            .not_.is_("listening_transcript", "null")
            .is_("audio_url", "null")
            .execute()
            .count
        )
        print(f"Lessons with a transcript but no audio_url: {remaining}")
    if OUT_DIR.exists() and not any(OUT_DIR.iterdir()):
        OUT_DIR.rmdir()


if __name__ == "__main__":
    asyncio.run(main())
