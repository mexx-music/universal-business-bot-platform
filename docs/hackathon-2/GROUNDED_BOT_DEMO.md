# Grounded AI Bot Demo (`/bot-test`)

A visible, end-to-end demonstration that the assistant answers **only** from the
active company's own knowledge — never from the model's general training — and
shows exactly which knowledge entries were used.

## Data flow

```
User question
   │
   ▼
GroundedAnswerService.answer()            (lib/ai/grounded_answer_service.dart)
   │  1. trim / reject empty question
   │  2. KnowledgeRuntime.buildContext(question, workspace)
   │        → scored matches, blocked-topic hits, handover flag
   │  3. blocked topic or handover?  → return blockedTopic, NO AI call
   │  4. keep only green, relevant (score > 0) matches, capped at maxSources
   │  5. no usable knowledge?        → return noKnowledge, NO AI call
   │  6. build sources from the used entries only
   │  7. build AiRequest: system rules + selected excerpts (size-capped)
   ▼
AiController.generate()                   (active provider: mock or Gemini)
   │        errors propagate — never swallowed, never a silent mock fallback
   ▼
GroundedAnswerResult  →  GroundedAnswerPanel renders answer + sources + status
```

Knowledge retrieval lives **only** in `GroundedAnswerService`. The widget
(`lib/screens/bot_test/grounded_answer_panel.dart`) never touches the knowledge
base directly; it only renders the result.

## Roles

- **KnowledgeRuntime** — selects and scores the relevant knowledge, detects
  blocked topics and human-handover cases. This is the "BusinessBrain": it
  decides *what* the model is allowed to see.
- **AiController** — routes the request to the active `AiProvider`. The service
  is provider-agnostic; it does not know whether it is talking to the mock or to
  Gemini.
- **The provider** — only *formulates* an answer from the supplied context. It
  receives the selected excerpts, not the full knowledge base.

## Grounding guarantees

- **Sources come only from used entries.** Each `GroundedSource` is built from a
  knowledge entry that was actually placed into the prompt — sources are never
  parsed out of free-form model text, so they cannot be fabricated.
- **Only selected context is sent.** The prompt contains the trimmed, size-capped
  excerpts of the chosen entries (`maxSources`, `maxEntryChars`,
  `maxContextChars`) — never a full dump of the workspace and never other
  companies' data (a single workspace is passed in; there is no cross-tenant
  read).
- **Honest "not found".** When no green, relevant entry exists, the service
  returns `noKnowledge` and makes **no** AI call.
- **Blocked topics never reach the model.** Sensitive/handover topics return
  `blockedTopic` with no AI call.
- **No auto-publish, no external action.** The system prompt forbids claiming to
  publish or act. The UI shows every answer as a suggestion.
- **Human-review hint.** Each answer carries the subtle reminder
  "KI-Vorschlag – vor Veröffentlichung prüfen." / "AI suggestion – review before
  publishing."
- **Company-neutral.** No company-specific logic is hard-coded; behaviour is
  driven entirely by the passed `CompanyWorkspace`.

## Mock vs. Gemini mode

Provider selection is driven by the non-secret `AI_PROVIDER` dart-define:

| `AI_PROVIDER` | Provider          | Network                         |
|---------------|-------------------|---------------------------------|
| unset / `mock`| `MockAiProvider`  | none — fully offline, deterministic |
| `gemini`      | `GeminiProvider`  | Supabase Edge Function `ai-generate` only |

- **Mock mode** is the default and needs no configuration; it is used for local
  dev, the demo, and all tests.
- **Gemini mode** reaches Gemini **only** through the server-side Supabase Edge
  Function. The client never calls Google directly and never holds the API key.
  The `GEMINI_API_KEY` exists only in the Edge Function's server environment — it
  is never present in the Flutter build, dart-defines, repo, tests, docs or logs.
- There is **no silent fallback** from Gemini to mock. If the transport fails,
  the panel surfaces a typed error (config / network / timeout / rate-limit /
  blocked / server) with a retry action.

## Running locally

Mock mode (recommended, offline, deterministic):

```bash
flutter run -d chrome --dart-define=AI_PROVIDER=mock
# open /bot-test, ask a question that matches the seeded company knowledge
```

Gemini mode (documented, not run here — requires separate setup):

```bash
# Prerequisites configured OUTSIDE this repo:
#   - Supabase project with the ai-generate Edge Function deployed
#   - GEMINI_API_KEY set as an Edge Function secret (server-side only)
#   - Supabase URL / anon key wired via the app's normal Supabase config
flutter run -d chrome --dart-define=AI_PROVIDER=gemini
```

The Edge Function and its secret must be provisioned separately; see
`docs/hackathon-2/GEMINI_EDGE_FUNCTION.md` and
`docs/hackathon-2/GEMINI_CLIENT_TRANSPORT.md`.

## Tests

- `test/grounded_answer_service_test.dart` — retrieval, source/context limiting,
  language, zero-knowledge → no AI call, blocked topic → no AI call, error
  propagation, prompt rules, mock stays offline, Gemini error does not become a
  mock answer.
- `test/grounded_answer_panel_test.dart` — input/submit, loading, answer +
  sources, provider badge, human-review hint, not-found state, error mapping +
  retry, re-run.

All tests fake/inject every network path — no real Gemini or Supabase call is
made.
