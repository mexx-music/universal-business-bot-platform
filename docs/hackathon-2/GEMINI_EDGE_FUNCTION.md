# Gemini Edge Function (`ai-generate`) — Technische Doku

> Status: **G-2**, lokal erstellt, **nicht deployed**, **kein Secret gesetzt**,
> **kein echter Gemini-Aufruf**. Nur öffentliche Doku für Hackathon 2 —
> die öffentliche Haupt-README bleibt unverändert.

## Architektur

Der Flutter-Client ruft Gemini **niemals direkt**. Kette:

```
Flutter (GeminiProvider)  →  AiTransport (G-3, Client-seitig, kein Key)
        →  Supabase Edge Function ai-generate  (hält GEMINI_API_KEY)
        →  Gemini REST API
```

Die Function nimmt das **vendor-neutrale Transportformat** aus G-1 entgegen,
validiert es streng, ruft Gemini **serverseitig** auf und antwortet im
neutralen Format, das der Client zu `AiResponse` mappt. Der API-Key existiert
ausschließlich serverseitig (`Deno.env.get('GEMINI_API_KEY')`).

Dateien:
- `supabase/functions/ai-generate/index.ts` — Handler (`handleRequest(req, deps)`
  mit injizierbaren `env`/`fetch`/`requestId`/`now`; `Deno.serve` am Ende).
- `supabase/functions/_shared/config.ts` — Limits, Modell-Allowlist, Default.
- `supabase/functions/_shared/validate.ts` — strikte Eingabevalidierung.
- `supabase/functions/_shared/gemini.ts` — Request-/Response-Mapping, `callGemini`.
- `supabase/functions/_shared/cors.ts` — CORS-Allowlist.
- `supabase/functions/_shared/errors.ts` — stabile Fehlercodes + HTTP-Status.
- `supabase/functions/tests/ai_generate_test.ts` — Unit-Tests (Fake-Fetch).

## Sicherheitsmodell

- **Key nur serverseitig**, nur aus `GEMINI_API_KEY`. Nie im Client, in
  `--dart-define`, im Repo, in Tests, in Doku oder in Logs.
- **Key wird als Header** `x-goog-api-key` gesendet (nicht in der URL).
- **Modellwahl serverseitig:** fester Default `gemini-3.6-flash`; ein
  Client-Hinweis wird **nur gegen eine Allowlist** geprüft und sonst ignoriert.
- **Keine Sampling-Parameter** (`temperature`/`top_p`/`top_k`) werden für
  `gemini-3.6-flash` gesendet — sie dürfen im neutralen Request vorkommen,
  werden aber bewusst entfernt.
- **Keine ungeprüften Client-Felder** an Google: nur validierte Nachrichten
  gehen upstream; `metadata` wird **nie** an Gemini weitergereicht.
- **Datensparsame, strukturierte Logs** (JSON): nur `requestId`, Event,
  Method, Status, Zähler (Nachrichtenanzahl/Gesamtzeichen), Dauer — **nie**
  Inhalte, Nutzereingaben, Antworten oder Secrets.
- **Fehler ohne Interna:** generische Client-Nachrichten, keine Stacktraces,
  keine Upstream-Rohbodies.

## Eingabe-Limits (zentral in `config.ts`)

| Limit | Wert |
|---|---|
| max. Nachrichten | 20 |
| max. Zeichen pro Nachricht | 8 000 |
| max. Gesamtzeichen | 30 000 |
| max. Output-Tokens (Demo) | 2 048 (serverseitig geklemmt) |
| erlaubte Rollen | `system`, `user`, `assistant` |
| erlaubter Provider | `googleGemini` |

## Request-Schema (POST, `application/json`)

Exakt das, was der Client-`AiTransport` sendet (G-1):

```jsonc
{
  "provider": "googleGemini",     // Pflicht
  "model": "gemini-3.6-flash",    // optional, einziger kanonischer Modell-Hinweis (Allowlist)
  "maxTokens": 2048,              // optional, serverseitig geklemmt
  "temperature": 0.3,             // optional — wird ignoriert
  "messages": [                   // 1..20
    { "role": "system", "content": "…" },
    { "role": "user",   "content": "…" }
  ],
  "metadata": { "workspace": "…" },// optional — NICHT an Google
  "action": "generate"            // optional: "generate" (Default) | "ping"
}
```

`action: "ping"` (oder HTTP `GET`) prüft nur Erreichbarkeit — **kein**
(kostenpflichtiger) Gemini-Aufruf.

## Response-Schema

Erfolg (`200`), kompatibel zu `AiTransportResponse`:

```jsonc
{
  "text": "…",
  "model": "gemini-3.6-flash",
  "finishReason": "STOP",         // STOP | MAX_TOKENS | SAFETY | RECITATION | OTHER
  "usage": { "inputTokens": 10, "outputTokens": 5, "totalTokens": 15 },
  "requestId": "…"
}
```

Ping (`200`): `{ "ok": true, "provider": "googleGemini", "model": "gemini-3.6-flash", "requestId": "…" }`

Fehler: `{ "error": { "code": <ErrorCode>, "message": "…", "requestId": "…" } }`

| Code | HTTP |
|---|---|
| `invalid_request` | 400 |
| `unauthorized` | 401 |
| `missing_server_configuration` | 500 |
| `rate_limited` | 429 |
| `upstream_timeout` | 504 |
| `upstream_unavailable` | 502 |
| `content_blocked` | 422 |
| `malformed_upstream_response` | 502 |
| `internal_error` | 500 |

Blockierte oder leere Antworten erzeugen **nie** einen falschen Erfolg →
`content_blocked` (422).

## Gemini-Mapping

- Endpoint: `POST {base}/models/{model}:generateContent`.
- `system` → `systemInstruction.parts`; `user` → `contents[role=user]`;
  `assistant` → `contents[role=model]`.
- `generationConfig` enthält **nur** `maxOutputTokens`.
- Antwort: `candidates[0].content.parts[].text` (join), `finishReason`
  (normalisiert), `usageMetadata` → `usage`.

## Lokale Tests

```sh
# Voraussetzung: Deno installiert (hier aktuell NICHT verfügbar, s. u.)
cd supabase/functions
deno fmt
deno check ai-generate/index.ts
deno test --allow-none tests/
```

Die Tests injizieren einen **Fake-Fetch** — es erfolgt **kein** echter
Netzaufruf. Abgedeckt: gültiger Request, Methoden-/Content-Type-/Rollen-/
Größen-Validierung, Modell-Allowlist, Nicht-Weitergabe von Sampling-Parametern,
Request-/Response-Mapping, `STOP`/`MAX_TOKENS`/`SAFETY`, Usage, Timeout, 429,
fehlender Key (ohne Upstream-Aufruf), malformed Response, Ping ohne Upstream,
sowie Key-Leak-Prüfung.

> **Ausführungshinweis (G-2):** Erstellt ohne lokal verfügbare Deno-/Supabase-
> CLI. Die Deno-Tests sind geschrieben und isoliert, konnten hier aber **nicht
> ausgeführt** werden. `dart format`/`flutter analyze`/`flutter test` liefen
> erfolgreich.

## Späteres Deployment (noch NICHT ausführen)

```sh
# 1. Secret setzen (Key aus sicherer Quelle, NIE ins Repo):
supabase secrets set GEMINI_API_KEY=<key>
supabase secrets set ALLOWED_ORIGINS="https://<projekt>.pages.dev"
# 2. Deploy:
supabase functions deploy ai-generate
```

Secret-Name: **`GEMINI_API_KEY`**. Zusätzlich `ALLOWED_ORIGINS` (Komma-Liste;
Produktion **nie** `*`; nur lokale Entwicklung darf localhost nutzen).

**Wichtig:** API-Keys dürfen niemals im Flutter-Web-Build landen — der Client
spricht ausschließlich diese Function an.

## Offene Punkte (Demo-Schutz, spätere Blöcke)

Vorbereitete Erweiterungsstellen (im Handler nach CORS/Methoden-Check
markiert), in G-2 bewusst **nicht** implementiert (bräuchten externe Infra/
Secrets):
- Rate-Limit pro IP/Session
- Cloudflare Turnstile
- tägliches globales Demo-Kontingent
- Missbrauchserkennung
- Auth-Entscheidung für die login-freie Demo

Bereits umgesetzt: Eingabe-/Methoden-Limits, zentrale CORS-Allowlist,
`requestId`, strukturierte datensparsame Logs, serverseitige Modell-Allowlist,
kein Senden von Sampling-Parametern.
