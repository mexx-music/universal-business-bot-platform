# Gemini Live Deployment & Verification (G-7)

How to take the already-built, vendor-neutral Gemini path from "wired" to
"live and reproducible" — and how to prove it for the hackathon. No new module,
no new product feature: this is deployment, configuration, verification and
tests around the existing code.

> Nothing here has been auto-deployed. Deployment and secret-setting are manual,
> explicit steps (commands below). The `GEMINI_API_KEY` is **server-side only**
> and is never a client dart-define, never in the repo, never in the build.

## 1. Architecture (recap)

```
Flutter UI (GroundedAnswerPanel)
  → GroundedAnswerService        selects only relevant knowledge → prompt
  → AiController (active: Gemini) chosen when AI_PROVIDER=gemini
  → GeminiProvider               vendor-neutral adapter, no key, no HTTP
  → SupabaseAiTransport          builds the canonical transport JSON
  → SupabaseEdgeFunctionClient   the ONLY file importing supabase_flutter
  → Supabase Edge Function `ai-generate`  (server) holds GEMINI_API_KEY
  → Google Gemini (generativelanguage.googleapis.com)
```

Security by construction: the client never calls Google directly, never holds
the key, never chooses the model freely (server allow-list), and never forwards
sampling params or metadata. Errors are mapped from a stable `error.code`.

## 2. Prerequisites

- A Supabase project (project ref, e.g. `abcdefghijklmnop`).
- The Supabase CLI installed locally (`supabase --version`).
- A Google Gemini API key.
- Flutter toolchain.

The release environment must provide both the Supabase CLI and Deno. The
2026-08-04 release-candidate audit verified the active Function and secret names
with the Supabase CLI and executed the complete local Deno suite. See
`docs/XPRIZE_RELEASE_CANDIDATE.md` for the current deployment status and open
production actions.

## 3. Secrets (server-side only)

Set the Gemini key and the CORS allow-list as **Edge Function secrets** — never
as client config:

```bash
# Placeholders — substitute your real values. Do NOT commit real keys.
supabase secrets set GEMINI_API_KEY=<YOUR_GEMINI_API_KEY> --project-ref <PROJECT_REF>
supabase secrets set ALLOWED_ORIGINS=https://<YOUR_APP_DOMAIN> --project-ref <PROJECT_REF>

# Verify which secret names exist (values are not printed):
supabase secrets list --project-ref <PROJECT_REF>
```

- `GEMINI_API_KEY` — required. Missing → the function returns
  `missing_server_configuration` (never a fake success).
- `ALLOWED_ORIGINS` — comma-separated allow-list. Empty falls back to localhost
  dev origins only; production must set the real app origin (never `*`).

## 4. Deployment

The function name is **`ai-generate`** (dir: `supabase/functions/ai-generate/`).
Config lives in `supabase/config.toml` under `[functions.ai-generate]`
(`verify_jwt = true`).

```bash
supabase login
supabase link --project-ref <PROJECT_REF>

# Optional: run the edge unit tests first (needs Deno; see §7)
deno test supabase/functions/tests/

# Deploy the single function:
supabase functions deploy ai-generate --project-ref <PROJECT_REF>
```

Deployed URL: `https://<PROJECT_REF>.supabase.co/functions/v1/ai-generate`

`verify_jwt = true` means a valid token is required. The Flutter client sends the
Supabase anon (publishable) key as `Authorization` automatically, so the demo
works without a user login while the endpoint stays protected.

## 5. Local (client) configuration

The **client** needs only non-secret values (the anon/publishable key is public
by design). Copy the example and fill in your project values:

```bash
cp config/gemini-live.example.json config/gemini-live.json
# edit config/gemini-live.json (this file is git-ignored)
```

```jsonc
// config/gemini-live.json
{
  "SUPABASE_URL": "https://<PROJECT_REF>.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "<YOUR_ANON_OR_PUBLISHABLE_KEY>",
  "AI_PROVIDER": "gemini"
}
```

Run against live Gemini:

```bash
flutter run -d chrome --dart-define-from-file=config/gemini-live.json
```

Run offline (mock, default — no config needed):

```bash
flutter run -d chrome --dart-define=AI_PROVIDER=mock
```

There is **no silent fallback**: `AI_PROVIDER=gemini` without an initialized
Supabase transport raises `AiConfigurationException` instead of quietly using the
mock.

## 6. Manual verification flow

1. Start the app with the live config (§5).
2. Sign in / enter the app so a workspace with knowledge is loaded (or use the
   demo company that carries a seeded knowledge base).
3. Open **`/bot-test`**.
4. Ask a question that the company's knowledge can answer, e.g.
   **"Was kostet der Versand?"** / **"What are your opening hours?"** — pick one
   that matches a real knowledge entry of the selected company.
5. Expected result:
   - An answer grounded in the company knowledge.
   - A **source list** built only from the knowledge entries actually used.
   - A **provider badge** reading `Provider: Google Gemini · gemini-3.6-flash`
     (not "Offline mock").
   - A **grounded** indicator ("Wissensbasiert").
6. Error cases to spot-check:
   - Ask something with **no** matching knowledge → honest "not found", **no**
     Gemini call.
   - A blocked/sensitive topic → handover, no Gemini call.
   - Temporarily unset `GEMINI_API_KEY` → config error surfaced in the UI.

### Quick server ping (no Gemini call)

```bash
curl -sS "https://<PROJECT_REF>.supabase.co/functions/v1/ai-generate" \
  -H "Authorization: Bearer <YOUR_ANON_KEY>"
# → {"ok":true,"provider":"googleGemini","model":"gemini-3.6-flash","requestId":"..."}
```

## 7. Edge (Deno) tests

26 unit tests exist in `supabase/functions/tests/ai_generate_test.ts` and use an
injected fake fetch (no network, no permissions needed):

```bash
cd supabase/functions && deno task test     # i.e. deno test tests/
# or from repo root:
deno test supabase/functions/tests/
```

The 2026-08-04 release-candidate run passed all 26 tests. They cover: valid
mapping, method / content-type / message-limit validation, model allow-list,
sampling-param stripping, system-instruction mapping, usage mapping, finish
reasons, SAFETY → `content_blocked`, timeout → 504, 429 → `rate_limited`,
missing key (no upstream call), malformed upstream, ping (no upstream call),
CORS preflights and key-never-leaks assertions.

## 8. Error diagnosis

| Symptom (UI) | `error.code` | Likely cause / fix |
|---|---|---|
| "AI service is not configured" | `missing_server_configuration` | `GEMINI_API_KEY` secret not set on the project |
| "rejected the request" | `unauthorized` | Bad/rotated Gemini key (401/403) |
| CORS error in browser console | — | `ALLOWED_ORIGINS` missing your app origin |
| "timed out" | `upstream_timeout` | Gemini slow; retry |
| "currently unavailable" | `upstream_unavailable` | Gemini 5xx / network |
| "blocked by safety filters" | `content_blocked` | Prompt/response blocked upstream |
| "unexpected response" | `malformed_upstream_response` | Upstream contract change |
| Config error on launch | (client) | `AI_PROVIDER=gemini` but `SUPABASE_URL`/key missing |

`x-request-id` is returned on every response and logged server-side (logs
contain no content and no secrets) for correlation.

## 9. Hackathon proof

- **Automated (runs here):** `test/gemini_live_path_test.dart` drives the real
  `GeminiProvider` + `SupabaseAiTransport` through a fake edge client (no
  network) and proves: gemini is selected (not mock), no silent fallback,
  only selected context is sent, sources stay bound, and `content_blocked` /
  `timeout` / invalid-response map correctly; the provider badge shows Gemini +
  model. Plus the existing `supabase_ai_transport_test`, `gemini_provider_test`,
  `gemini_contract_test`, `ai_provider_selection_test`.
- **Manual (after deploy):** the flow in §6, ideally captured as a short
  screen recording showing the Gemini badge on a real answer.

## 10. What is live vs. what stays demo

**Live once deployed (§4–6):**
- The grounded bot on `/bot-test` calling real Gemini via the edge function.

**Still demo / not live (by design):**
- Research Foundation + Company Evolution — local demo data, no live research
  (see `RESEARCH_FOUNDATION.md`, `COMPANY_EVOLUTION_DEMO.md`).
- Community Radar / Matching — read-only demo data.
- No autonomous actions: the AI only proposes; a human reviews and publishes.
