// transcribe_audio: turns a speaking-tab recording into text with Deepgram
// Nova-2. The API key never leaves the server.
//
// Deploy from the Supabase dashboard (Edge Functions → Deploy a new
// function → name it `transcribe_audio`, paste this file) and keep
// "Enforce JWT verification" on, so only signed-in users can call it. Set
// the key under Edge Functions → Secrets as DEEPGRAM_API_KEY.
//
// Request: the raw audio bytes as the body, with the audio's Content-Type
// (audio/mp4 for the app's .m4a recordings, audio/wav for its fallback;
// application/octet-stream lets Deepgram detect the format).
//
// Response 200 (JSON):
//   { "transcript": "<what was said>" }   empty when no speech was heard
//
// Errors (JSON { "error": code }):
//   400 invalid_request   empty body, or neither audio/* nor octet-stream
//   405 method_not_allowed
//   413 too_large         over MAX_AUDIO_BYTES
//   429 rate_limited      Deepgram is rate limiting the key
//   500 not_configured    DEEPGRAM_API_KEY is not set
//   502 upstream_error    Deepgram failed or sent an unexpected reply
//   504 upstream_timeout  Deepgram took too long

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// Same settings the app used when it called Deepgram directly.
const DEEPGRAM_URL = "https://api.deepgram.com/v1/listen?" +
  new URLSearchParams({
    model: "nova-2",
    smart_format: "true",
    language: "en",
  });

const TIMEOUT_MS = 60_000;

// A five-minute AAC answer is about 2.5 MB; WAV about 10 MB.
const MAX_AUDIO_BYTES = 20 * 1024 * 1024;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const apiKey = Deno.env.get("DEEPGRAM_API_KEY");
  if (!apiKey) {
    console.error("DEEPGRAM_API_KEY is not set");
    return json({ error: "not_configured" }, 500);
  }

  const contentType = (req.headers.get("content-type") ?? "")
    .split(";")[0]
    .trim()
    .toLowerCase();
  // Deepgram detects the format of an untyped upload itself.
  if (
    !contentType.startsWith("audio/") &&
    contentType !== "application/octet-stream"
  ) {
    return json({ error: "invalid_request" }, 400);
  }

  const declaredLength = Number(req.headers.get("content-length") ?? 0);
  if (declaredLength > MAX_AUDIO_BYTES) {
    return json({ error: "too_large" }, 413);
  }
  const audio = new Uint8Array(await req.arrayBuffer());
  if (audio.byteLength === 0) return json({ error: "invalid_request" }, 400);
  if (audio.byteLength > MAX_AUDIO_BYTES) {
    return json({ error: "too_large" }, 413);
  }

  let response: Response;
  try {
    response = await fetch(DEEPGRAM_URL, {
      method: "POST",
      headers: {
        Authorization: `Token ${apiKey}`,
        "Content-Type": contentType,
      },
      body: audio,
      signal: AbortSignal.timeout(TIMEOUT_MS),
    });
  } catch (error) {
    const timedOut = error instanceof DOMException &&
      error.name === "TimeoutError";
    console.error("Deepgram request failed", error);
    return json(
      { error: timedOut ? "upstream_timeout" : "upstream_error" },
      timedOut ? 504 : 502,
    );
  }

  if (!response.ok) {
    console.error("Deepgram error", response.status, await response.text());
    return response.status === 429
      ? json({ error: "rate_limited" }, 429)
      : json({ error: "upstream_error" }, 502);
  }

  const result = await response.json().catch(() => null);
  const transcript = result?.results?.channels?.[0]?.alternatives?.[0]
    ?.transcript;
  if (typeof transcript !== "string") {
    return json({ error: "upstream_error" }, 502);
  }
  return json({ transcript: transcript.trim() });
});
