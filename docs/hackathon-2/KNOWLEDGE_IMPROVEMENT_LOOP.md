# Knowledge Improvement Loop (BLOCK 4)

A guided, seven-step demo page that visualises the platform's core
differentiator in ~30 seconds: how a single customer question turns a knowledge
gap into permanent knowledge that every future answer benefits from.

Route: `/knowledge-improvement` · Nav: "Lernkreislauf" / "Learning loop".

## What it is (and is not)

- **A visualisation, not a new module.** It reuses existing models
  (`KnowledgeDraftCategory` for the suggested entry's category) and the app's
  Material 3 design language.
- **No new AI logic, no backend, no persistence.** The scenario is scripted and
  deterministic; there is no live Gemini call and nothing is saved. A visible
  trust notice states this.
- **Honest framing.** The gap stage shows the same honest "not enough knowledge"
  message the real grounded bot uses; the suggestion is clearly a *proposal* a
  human accepts.

## The seven stages

1. **Customer question** — a concrete question (chat bubble).
2. **AI answer** — the AI answers only from the approved knowledge base.
3. **Knowledge gap detected** — honest gap, with the uncovered terms as chips.
4. **Improvement suggestion** — a proposed knowledge entry (FAQ category, title,
   content, keywords).
5. **Employee accepts** — a human reviews and accepts (nothing auto-saved).
6. **Knowledge base grows** — the entry count moves 8 → 9.
7. **All answers benefit** — a before/after of the *same* question (honest gap
   answer vs. the precise, sourced answer) plus the "aha moment" card.

## Interaction & layout

- A numbered step indicator (Wrap — overflow-safe) shows progress; completed
  steps get a checkmark, the current step is highlighted.
- One "Next" advances through the loop; "Restart" returns to step 1; a "Step X /
  7" counter orients the viewer.
- The before/after comparison is a two-column layout ≥ 640 px and a single
  column below; every row uses `Wrap`/`Flexible`/`Expanded` so it stays
  overflow-free on mobile (360 px) and desktop (1400 px).

## Files

- `lib/knowledge_loop/knowledge_loop.dart` — `KnowledgeLoopStage` (7 stages) and
  `KnowledgeImprovementDemo` (structural scenario: KB counts, missing terms,
  suggestion category/keywords).
- `lib/screens/knowledge_improvement/knowledge_improvement_screen.dart` — the
  guided screen.
- `lib/l10n/*` + `label_helpers.dart` — DE/EN strings.
- `lib/router/app_router.dart`, `lib/widgets/app_shell.dart` — route + nav.
- `test/knowledge_improvement_screen_test.dart` — start stage, full walk to the
  aha moment, restart, EN localization, no overflow on mobile/desktop.

## Why this matters for the demo

Jury and customers grasp the value proposition — "the assistant gets measurably
better with every question, with a human in the loop and one source of truth" —
in a single, self-contained 30-second click-through, without any live
infrastructure.
