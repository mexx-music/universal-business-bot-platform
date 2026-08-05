# Real Knowledge Improvement Workflow (BLOCK 8)

The first **reproducible end-to-end proof** that a real customer question turns a
knowledge gap into permanent company knowledge that improves future answers.
Route: `/knowledge-workflow` · Nav: "Lern-Workflow" / "Learning workflow".

This block **only connects existing modules** — it adds no new AI, no new
heuristics, no parallel data:

- **GroundedAnswerService** — gap detection and grounded answers (existing).
- **KnowledgeImportAnalyzer** — derives the improvement suggestion (existing).
- **AppState.addKnowledgeEntry** — writes into the real workspace knowledge base
  (the same path the Human-Review screen uses; existing).
- **KnowledgeRuntime** — retrieves the new entry on re-ask (existing).

No Supabase / edge / Gemini-prompt / provider / model changes.

## The loop

1. A fixed question is asked whose terms are **not** in the seeded knowledge base
   ("Wie kann ich meine Berichte als CSV-Datei exportieren?").
2. GroundedAnswerService correctly returns a **gap** — an honest "not enough
   knowledge" message, **no hallucination**, **no sources**.
3. The improvement suggestion is shown automatically (category + editable
   title/content, keywords from the analyzer) in a Human-Review card.
4. The employee can edit and **Accept** or **Reject**.
   - **Accept** → a real `KnowledgeEntry` is created via
     `AppState.addKnowledgeEntry` in the **same** knowledge base (no separate
     demo data). The exact same question is asked again; now the Grounded
     Assistant finds the new entry, uses it as a **source**, and returns a
     better answer. A banner above the answer states: "Diese Antwort wurde durch
     einen neu bestätigten Wissenseintrag verbessert."
   - **Reject** → the knowledge base stays unchanged and the same question keeps
     returning the honest gap.
5. A closing card: "Der Lernkreislauf wurde erfolgreich abgeschlossen." /
   "BusinessBrain verbessert seine Antworten ausschließlich durch bestätigtes
   Unternehmenswissen."

No automatic decisions are made — every adoption is the employee's.

## Process indicator

A six-step rail (right on wide, top on narrow) with a green check per completed
step: Frage gestellt → Wissenslücke erkannt → Verbesserungsvorschlag erstellt →
Mitarbeiter bestätigt → Wissenseintrag gespeichert → Antwort verbessert. Steps
1–3 complete after asking; 4–6 complete only after the employee confirms.

## Files

- `lib/screens/knowledge_workflow/knowledge_workflow_screen.dart` — the workflow
  (orchestration of existing modules only).
- `lib/l10n/*` — DE/EN strings (`kw*`; reuses `botDemoNoKnowledge`,
  `botDemoSources`, `kbFieldTitle`, `kbFieldContent`).
- `lib/router/app_router.dart`, `lib/widgets/app_shell.dart` — route + nav.
- `test/knowledge_workflow_screen_test.dart`.

## Tests

- Gap before adoption (honest, no sources, no hallucination).
- Accept creates a **real** entry (`knowledgeEntries.length` grows by one) and
  the repeated question uses it (improved banner + source shown).
- Sources are shown correctly (the new entry's title appears as a source).
- Reject leaves the knowledge base unchanged and the gap persists.
- The process rail marks 3 steps after asking and 6 after confirming.
- English localization.
- No overflow on mobile (380 px) and desktop (1400 px).
