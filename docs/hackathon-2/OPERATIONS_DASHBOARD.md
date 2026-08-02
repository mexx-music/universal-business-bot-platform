# AI Operations Dashboard (BLOCK 7)

A first-impression page at `/operations-dashboard` that conveys, within the
first 30 seconds, that BusinessBrain is actively working for a company — "here a
professional company system is already at work," not just a chatbot.

Pure **presentation** of existing demo data: no new AI, no business logic, no
background processes, no agents, no backend/Supabase/edge/prompt/API/persistence
changes. Every card carries a **DEMO** badge so it is always clear this is a
demonstration, not live company data.

Nav: "Operations".

## Structure

- **BusinessBrain heute** — a large status card introducing today's view (DEMO).
- **Live metrics** — six cards on demo figures: customer questions today,
  answered successfully, new knowledge gaps detected, improvement suggestions
  created, sources used, new knowledge entries adopted. Each metric card shows a
  DEMO badge.
- **Activity timeline** — the learning loop as a dated sequence (09:12 answered
  → 09:18 gap detected → 09:20 suggestion → 09:45 employee confirms → 10:02
  knowledge base extended → 10:03 future answers improved).
- **Detected today** — demo findings (frequent question, same topic asked by
  several customers, recommended FAQ / manual / step-by-step, missing technical
  requirement).
- **Human decisions** — total / adopted / in progress / rejected, with an
  explicit note that BusinessBrain makes no decisions itself — every change is
  confirmed by a human.
- **Knowledge-base quality** — a simple horizontal bar chart (Material
  `LinearProgressIndicator`) over FAQ, guides, technical information,
  troubleshooting and definitions, plus the total entry count.
- **Closing card** — "BusinessBrain arbeitet kontinuierlich – der Mensch
  entscheidet." with the human-in-control message.

## Design

Material 3, responsive: metric cards and stat tiles use `Wrap` (reflow on
narrow), bar rows use `Expanded` + a fixed value column, and everything sits in
a single scroll view — verified overflow-free on mobile (360 px) and desktop
(1400 px). The page is intentionally non-technical: big numbers, clear labels,
timeline and charts.

## Data

`lib/operations/operations_demo.dart` holds only the structural demo figures
(metric counts, fixed timeline times, decision counts, quality distribution).
All labels are localized (DE/EN) in the screen. Nothing is fetched or computed
live.

## Files

- `lib/operations/operations_demo.dart` — static demo figures.
- `lib/screens/operations/operations_dashboard_screen.dart` — the page.
- `lib/l10n/*` — DE/EN strings (`op*`).
- `lib/router/app_router.dart`, `lib/widgets/app_shell.dart` — route + nav.
- `test/operations_dashboard_screen_test.dart` — today/closing + DEMO badges,
  metrics, timeline, detected, human decisions (+ control note), quality bars,
  EN localization, no overflow on mobile/desktop.
