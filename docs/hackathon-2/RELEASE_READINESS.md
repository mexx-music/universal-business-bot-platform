# Release Readiness & Jury Mode (BLOCK 9)

Release/presentation only — no new business features, no backend/AI changes.
Focus: stability, understandability and a professional jury experience.

## 1. Jury Mode

- **Start page** `/jury` (`JuryStartScreen`): a modern entry with a short intro
  and two clear actions — "Geführte Jury-Demo starten" and "Plattform frei
  erkunden". Both activate jury mode.
- **Guided jury demo** `/jury-demo` (`JuryTourScreen`): walks the visitor through
  the most important existing areas in a fixed order with short intro texts
  (no developer explanation needed):
  1. Business Story
  2. Operations Dashboard
  3. Guided Demo
  4. Grounded Assistant
  5. Knowledge Workflow
  6. Conclusion
  It only **embeds existing screens** — no new logic.

## 2. Simplified navigation (jury mode)

While jury mode is active, the app shell (`_JuryShell`) shows only the five main
areas — Business Story, Operations, Guided Demo, Grounded AI, Knowledge
Workflow — plus a single **"Weitere Module"** entry (`/more`) that lists every
other area. **No feature is removed**; it is purely a clearer information
architecture. Jury mode defaults to **off**, so the full navigation and all
existing behaviour/tests are unchanged (`JuryModeController` +
`JuryModeScope`, read via `maybeOf`).

## 3. Release checklist (internal)

`/release-check` (`ReleaseChecklistScreen`) — a team-only checklist with a
per-item status (Nicht begonnen / In Arbeit / Erledigt; tap to cycle). Reachable
from "Weitere Module", not shown in the jury navigation. Items: branch published,
Cloudflare deployment, live Gemini active, AI_PROVIDER set, demo data, Guided
Demo, Business Story, Operations Dashboard, Knowledge Workflow, README,
screenshots, pitch video, submission document.

## 4. Central demo switch

`DemoDataController` + `DemoDataScope` provide a single source of truth for
whether demo content is shown. Existing demo data is unchanged; screens read the
switch instead of each managing its own state. The Operations Dashboard consults
it (`DemoDataController.enabledOf`) to show/hide DEMO badges — backward
compatible (default on). The switch is toggled centrally from "Weitere Module".

## Files

- `lib/jury/jury_mode_controller.dart`, `lib/demo_data/demo_data_controller.dart`
  — presentation-only controllers + scopes (wired in
  `universal_business_bot_app.dart`).
- `lib/screens/jury/jury_start_screen.dart`, `lib/screens/jury/jury_tour_screen.dart`
- `lib/screens/more/more_modules_screen.dart`
- `lib/screens/release/release_checklist_screen.dart`
- `lib/widgets/app_shell.dart` — added `_JuryShell` (isolated, default-off).
- `lib/screens/operations/operations_dashboard_screen.dart` — reads the demo switch.
- `lib/router/app_router.dart`, l10n — routes + DE/EN strings.
- Tests: `jury_mode_test.dart`, `release_ready_screens_test.dart`,
  `jury_navigation_test.dart`.

## Open items before official submission

These are **not** code tasks for this block but must be done before submitting
(tracked in the release checklist):

- Push branch `hackathon-2` / merge as intended (currently local only).
- Cloudflare Pages deployment of the current build.
- Verify live Gemini in the deployed environment (edge function + secret) with
  `AI_PROVIDER=gemini`.
- Update the public README for the current feature set.
- Capture screenshots and record the pitch video.
- Finalise the Devpost/submission document.
