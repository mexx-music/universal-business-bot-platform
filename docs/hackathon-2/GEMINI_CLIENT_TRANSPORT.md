# Gemini Client Transport (G-3) — Technische Doku

> Status: **G-3**, lokal auf `hackathon-2`. Kein Deploy, kein Secret, kein
> echter Gemini-/Netzaufruf. Die öffentliche Haupt-README bleibt unverändert.

## Kette

```
UI  →  AiController  →  AiProvider (GeminiProvider)  →  AiTransport
     →  SupabaseAiTransport  →  EdgeFunctionClient (supabase_flutter)
     →  Supabase Edge Function `ai-generate`  →  Gemini REST
```

Die UI kennt **nur** `AiController`/`AiProvider`. Kein Screen importiert
Supabase. Der Client ruft Google **niemals** direkt und hält **keinen** Key.

Beteiligte Dateien (Client):
- `lib/ai/transports/supabase_ai_transport.dart` — `AiTransport`-Impl; baut das
  kanonische JSON, mappt Antworten/Fehler. Kennt nur `EdgeFunctionClient`.
- `lib/ai/transports/edge_function_client.dart` — injizierbare Abstraktion
  (`EdgeFunctionClient`, `EdgeFunctionResponse`, `AiConfigurationException`).
- `lib/ai/transports/supabase_edge_function_client.dart` — **einziger** Ort mit
  `supabase_flutter`; normalisiert Erfolg/`FunctionException` zu
  `EdgeFunctionResponse`.
- `lib/ai/ai_provider_selection.dart` — `buildAiController(...)` (Auswahl).
- `lib/ai/ai_provider_registry.dart` — `AiProviderRegistry.gemini(transport)`.

## Kanonischer JSON-Vertrag (einziger, keine Aliasse)

**Request – generate** (POST an `ai-generate`):
```jsonc
{
  "provider": "googleGemini",
  "model": "gemini-3.6-flash",   // optional, nur Hinweis (Server-Allowlist)
  "maxTokens": 2048,             // optional, serverseitig geklemmt
  "action": "generate",
  "messages": [ { "role": "system|user|assistant", "content": "…" } ]
}
```
**Request – ping**: `{ "provider": "googleGemini", "action": "ping" }`

Nicht gesendet: `providerId`, `modelHint`, `metadata`, `temperature`,
`top_p`, `top_k`. `metadata`/Sampling existieren im neutralen Dart-Modell,
werden vom Transport aber **bewusst nicht** übertragen.

**Response – Erfolg**:
```jsonc
{ "text": "…", "model": "gemini-3.6-flash",
  "finishReason": "STOP|MAX_TOKENS|SAFETY|RECITATION|OTHER",
  "usage": { "inputTokens": 0, "outputTokens": 0, "totalTokens": 0 },
  "requestId": "…" }
```
**Response – Fehler**: `{ "error": { "code": <ErrorCode>, "message": "…", "requestId": "…" } }`

Der Vertrag ist beidseitig durch `test/gemini_contract_test.dart` (Client-Wire)
und die Deno-Validierung (`supabase/functions/_shared/validate.ts`) gesichert.
`model` ist der **einzige** kanonische Modellname (G-2 `modelHint`-Alias
wurde entfernt, da nichts deployed ist).

## Fehler-Mapping (maschinenlesbarer `error.code`, nicht nur HTTP-Status)

| Function-Code | `AiTransportErrorKind` |
|---|---|
| `invalid_request` | `badRequest` |
| `unauthorized` | `unauthorized` |
| `missing_server_configuration` | `configuration` *(neu, additiv)* |
| `rate_limited` | `rateLimited` |
| `upstream_timeout` | `timeout` |
| `upstream_unavailable` | `network` |
| `content_blocked` | `contentBlocked` *(neu, additiv)* |
| `malformed_upstream_response` | `badResponse` |
| `internal_error` | `server` |
| (fehlt) | Fallback über HTTP-Status |

`AiTransportErrorKind` wurde **additiv** um `configuration` und
`contentBlocked` erweitert; bestehende Bedeutungen unverändert. Client-Timeout
und Netzfehler werden ebenfalls typisiert (`timeout`/`network`). Fehlertexte
sind generisch — keine Secrets, keine Upstream-Details, keine Prompts/Antworten
in Logs.

## Provider-Auswahl über `AI_PROVIDER`

`AI_PROVIDER` ist **kein Secret** und darf als `--dart-define` gesetzt werden:

| `AI_PROVIDER` | Verhalten |
|---|---|
| nicht gesetzt / `mock` | Offline-Mock-Adapter (lokale Entwicklung & Tests) |
| `gemini` | echter `GeminiProvider` über `SupabaseAiTransport` |

Regeln:
- **Kein stiller Fallback:** Ist `gemini` gewählt und ein Aufruf schlägt fehl,
  bleibt der Fehler ein echter Transport-/Providerfehler; es wird **nicht** auf
  Mock zurückgeschaltet. Der aktive Provider bleibt Gemini.
- Ist `gemini` gewählt, aber Supabase nicht initialisiert (kein Transport),
  wirft `buildAiController` eine **`AiConfigurationException`** — klarer
  Konfigurationsfehler statt Downgrade.
- `SUPABASE_URL`/`SUPABASE_PUBLISHABLE_KEY` wie bisher (nicht geheim).
- **`GEMINI_API_KEY` kommt niemals im Flutter-Build vor** — weder in `dart-define`
  noch im Client noch im Repo. Der Key existiert nur serverseitig
  (Edge-Function-Secret, G-2).

## Sichere Aktivierung (später)

Lokal (Dev):
```sh
# Edge Function lokal bereitstellen (Deno/Supabase-CLI nötig):
supabase functions serve ai-generate --env-file supabase/functions/.env.local  # .env.local NICHT committen
# Flutter mit Gemini-Modus starten (kein Key im Client!):
flutter run -d chrome \
  --dart-define=SUPABASE_URL=… --dart-define=SUPABASE_PUBLISHABLE_KEY=… \
  --dart-define=AI_PROVIDER=gemini
```
Produktion: Function deployen + `GEMINI_API_KEY`/`ALLOWED_ORIGINS` als
Supabase-Secrets setzen (siehe `GEMINI_EDGE_FUNCTION.md`), dann Build mit
`--dart-define=AI_PROVIDER=gemini`. Nichts davon in G-3 ausführen.

## Offene Punkte
- Demo-Schutz (Rate-Limit/Turnstile/Kontingent/Auth) in der Edge Function
  (G-2-Erweiterungsstellen).
- Verdrahtung einer sichtbaren Demo-Funktion an `AiController` (nächster Block).
- Deno-Tests der Function sind vorhanden, wurden lokal aber **nicht ausgeführt**
  (kein Deno/Supabase-CLI verfügbar).
