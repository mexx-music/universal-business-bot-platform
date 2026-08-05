# BusinessBrain — XPRIZE Release Candidate

Audit snapshot: 2026-08-04

Target: Build with Gemini XPRIZE public demo

Canonical demo origin: `https://universal-business-bot-platform.pages.dev`

This is a deployment and verification report. It does not add product
functionality and does not change Knowledge Builder, retrieval, prompts, Human
Review, workspace data, Guided Demo, Jury Mode or any business logic.

## Release decision

**ACTION REQUIRED — not yet a production GO.**

The real Gemini server path is active and answered an authenticated live
generation successfully. The repository-side Cloudflare build now selects
Gemini explicitly. The current public origin is nevertheless not returned by
the deployed Edge Function's CORS allow-list. In addition, the corrected client
build has deliberately not been pushed or deployed. Both actions must be
completed and re-verified before recording the final jury video.

## Readiness matrix

| Area | Status | Evidence / required action |
|---|---|---|
| Gemini provider adapter | READY | `AI_PROVIDER=gemini` selects `GeminiProvider`; missing transport fails loudly and never falls back to mock. |
| Cloudflare build define | READY locally | Workflow now validates and passes `--dart-define=AI_PROVIDER=gemini`. The corrected build is not deployed yet. |
| Supabase project | READY | Repository and CLI link resolve to project `susxkcemwhsnuaemsqfs`. |
| Edge Function | READY | Deployed `ai-generate`, status `ACTIVE`, version 3, JWT verification enabled. |
| Gemini secret | READY | Secret name `GEMINI_API_KEY` exists server-side; no value was read or logged. |
| Live upstream generation | READY | Authenticated POST returned `BB_GEMINI_LIVE`, `gemini-3.6-flash`, finish reason `STOP`, usage and request ID. |
| CORS secret | ACTION REQUIRED | `ALLOWED_ORIGINS` exists, but preflight for the canonical Pages origin returns no `Access-Control-Allow-Origin`. Replace the allow-list with the exact production origins and repeat the preflight. |
| Cloudflare public routes | READY | `/`, `/jury`, `/jury-demo`, `/knowledge-builder`, `/review`, `/bot-test`, `/operations-dashboard` and `/sources` return HTTP 200 HTML directly. |
| GitHub production values | ACTION REQUIRED | Workflow contract is complete, but remote secret/variable presence could not be inspected because the local GitHub CLI credential is invalid. Verify the names below before merge. |
| Current public client build | ACTION REQUIRED | The workflow correction is local only. Redeploy only after review/merge; then prove the displayed provider is Google Gemini. |
| Deterministic fallback | READY | Knowledge Builder and Operations retain deterministic content when Gemini fails. |
| Mock honesty | READY | Automated tests prove mock content is never rendered as Gemini and a live failure never switches providers silently. |
| Jury flow | READY locally | Existing route, Guided Demo, platform-entry and responsive tests cover the public-to-platform journey without loops or duplicate shells. |

## Executed verification

| Check | Result |
|---|---|
| `flutter analyze` | READY — no issues |
| Complete `flutter test` | READY — 527 tests passed |
| Consolidated XPRIZE Flutter smoke | READY — 93 tests passed |
| Edge Function Deno suite | READY — 26 tests passed |
| Live Edge GET ping | READY — HTTP 200, `googleGemini`, `gemini-3.6-flash` |
| Live Edge Gemini generation | READY — exact response `BB_GEMINI_LIVE`, finish `STOP` |
| Cloudflare route probe | READY — all eight tested direct routes returned HTTP 200 HTML |
| Production-configured web release | READY — built with Gemini and the browser-safe Supabase configuration |
| Production-configured Wasm release | READY — `main.dart.wasm` and supporting artifacts built |
| Cloudflare artifact preparation | READY — SPA redirect and required PWA files verified |
| Canonical-origin CORS preflight | ACTION REQUIRED — HTTP 204 but `Access-Control-Allow-Origin` missing |
| `git diff --check` | READY — clean |

The live requests used only a browser-safe Supabase publishable key. No key
value, company document or customer content was printed or written to tracked
files.

## Required production configuration

### Flutter / Cloudflare build

The client values below are build-time dart-defines; `AUTH_REDIRECT_URL` is
optional. Only the publishable Supabase key may enter the browser build.

```text
AI_PROVIDER=gemini
SUPABASE_URL=https://susxkcemwhsnuaemsqfs.supabase.co
SUPABASE_PUBLISHABLE_KEY=<browser-safe publishable key>
PUBLIC_APP_URL=https://universal-business-bot-platform.pages.dev
AUTH_REDIRECT_URL=<exact HTTPS callback, when authentication uses one>
```

Required GitHub Secrets:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`
- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

Required GitHub repository variable:

- `CLOUDFLARE_PAGES_PROJECT_NAME`

Recommended explicit repository variables:

- `PUBLIC_APP_URL=https://universal-business-bot-platform.pages.dev`
- `AUTH_REDIRECT_URL=<exact production callback>`

`GEMINI_API_KEY` must never be a GitHub build secret, Cloudflare build value or
dart-define. It belongs only to the Supabase Edge Function environment.

### Supabase Edge Function

Required server-side secret names:

- `GEMINI_API_KEY`
- `ALLOWED_ORIGINS`

The production allow-list must use exact origins, without a path or trailing
slash. For the current demo it must include:

```text
https://universal-business-bot-platform.pages.dev
```

When a custom domain is added, keep both origins during the transition:

```text
https://universal-business-bot-platform.pages.dev,https://<custom-domain>
```

After changing the secret, an unauthenticated browser-style `OPTIONS` request
must return HTTP 204 and exactly the requesting production origin in
`Access-Control-Allow-Origin`. A successful server response without that header
is still a browser failure.

## Reproducible smoke test

Run the consolidated local suite from the repository root:

```bash
bash scripts/xprize_release_smoke.sh
```

It verifies:

| Jury proof point | Automated evidence |
|---|---|
| Grounded Answer uses Google Gemini | Real `GeminiProvider` → `SupabaseAiTransport` contract, grounded sources and provider badge. |
| Knowledge Builder shows Gemini Insights | Document-bound insights and review proposals; deterministic analysis survives a provider failure. |
| Operations Center shows Gemini Weekly Summary | Gemini selects only existing deterministic insight IDs; no invented metrics. |
| Knowledge Gap shows Gemini Proposal | Gap improvement cards are provider-backed, human-reviewable and disappear cleanly on failure/mock. |
| Human Review remains unchanged | Draft preview, explicit acceptance workflow and Guided Demo learning loop remain covered. |
| Website Links remain source-bound | Only links from knowledge entries actually used in the answer are shown. |
| Fallback remains deterministic | Gemini errors do not remove Knowledge Builder or Operations results. |
| Mock never claims Gemini | Mock markers are hidden and provider identity is never relabelled. |
| Jury flow remains reachable | Landing, Guided Demo, platform entry, back/forward, refresh and responsive navigation tests. |
| Edge contract remains safe | Deno tests cover validation, CORS, model allow-list, missing secret, upstream errors and secret non-disclosure. |

The live external verification is intentionally separate because it requires
deployed infrastructure. Perform it once immediately before recording:

1. Confirm the CORS preflight returns the canonical Pages origin.
2. Open the deployed app with DevTools Network visible.
3. Complete one Knowledge Builder analysis and confirm Gemini Insights.
4. Ask a grounded question and confirm the Google Gemini badge, correct source
   binding and answer language.
5. Trigger a genuine knowledge gap and confirm no free-model answer appears.
6. Open Operations Center and confirm Gemini Weekly Summary.
7. Disable/unavailable-test Gemini in a non-production test environment only;
   deterministic content must remain and no Gemini badge may appear.

## Jury flow release check

Use this exact presentation path after the final deployment:

1. Landing (`/`)
2. Knowledge Builder (`/knowledge-builder`)
3. Human Review (`/review` or the in-flow review state)
4. Grounded Answer (`/bot-test`)
5. Operations Center (`/operations-dashboard`)
6. Website Links (source-bound actions inside Grounded Answer; `/sources` for
   source administration)
7. Guided/Jury conclusion (`/jury-demo`)

Pass conditions: no login interruption in demo mode, no routing loop, no mock
badge, no English answer to a German question, no unrelated source, no empty
Gemini card, and no browser console CORS error.

## Video-Checkliste

Record only after every ACTION REQUIRED item above is closed.

- [ ] Landing: value proposition and “2 minutes” entry
- [ ] Knowledge Builder: prepared document loaded and analysis started
- [ ] Gemini Insights: document-bound proposal visible
- [ ] Human Review: human confirms; nothing is auto-published
- [ ] Grounded Answer: natural answer from confirmed company knowledge
- [ ] Google Gemini badge: provider and model legible in the same shot
- [ ] Sources / Website Links: exact used source and official destination
- [ ] Knowledge Gap: honest missing-information state plus Gemini proposal
- [ ] Operations Center: daily activity and knowledge growth
- [ ] Gemini Weekly Summary: clearly separated from deterministic metrics
- [ ] Final frame: “the human decides” and the learning loop

For demo safety, preload one known-good German question and one known gap. Keep
the public Pages URL, the Supabase status page and a local screen recording
available. Do not demonstrate secret configuration or browser storage.

## Final operator checklist

- [ ] Set `ALLOWED_ORIGINS` to the exact Pages/custom origins.
- [ ] Re-run browser preflight and verify `Access-Control-Allow-Origin`.
- [ ] Re-authenticate GitHub CLI or inspect Actions settings manually.
- [ ] Verify all GitHub secret/variable names listed above.
- [ ] Review and merge the local workflow change.
- [ ] Build/deploy through the existing Cloudflare workflow.
- [ ] Confirm the deployed UI says Google Gemini, never mock.
- [ ] Run the complete jury path once in German and once in English.
- [ ] Run the known-gap and deterministic-fallback checks.
- [ ] Record the XPRIZE video only after a clean final run.

No push, deployment, GitHub mutation, Supabase secret change or Edge Function
deployment was performed during this release-preparation block.
