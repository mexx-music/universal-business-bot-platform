# Guided Demo (BLOCK 5)

A two-to-three-minute, seven-step click-through at `/guided-demo` that turns the
platform's existing modules into one understandable story. It exists so a jury
or new customer grasps within ~2 minutes that BusinessBrain is not a chatbot but
a **learning company platform with one central knowledge base**, where customer
questions expose gaps, employees stay in control, and every confirmed addition
improves all future answers.

Nav: "Geführte Demo" / "Guided demo".

## What it reuses (no new logic)

The guided demo adds **no business logic** — it embeds the real existing modules
and frames them with narration, a left step navigation and an always-visible
progress bar:

- **Step 2 – Build knowledge** → embeds `KnowledgeBuilderScreen` (BLOCK 2).
- **Step 3 – Grounded answer** → embeds `GroundedAnswerPanel` (BLOCK 1/G-4):
  real grounded answer with visible sources, no invention.
- **Step 4 – Knowledge gap** → embeds `GroundedAnswerPanel` again, framed to
  show the honest "not enough knowledge" gap (no hallucination).
- **Step 5 – Improvement & control** → embeds `KnowledgeImprovementScreen`
  (BLOCK 4): suggestion → employee decides → knowledge grows → all benefit
  (nothing saved automatically).
- **Steps 1, 6, 7** are framing/summary panels (welcome statement; a
  learning-loop overview chain; the conclusion card).

Everything else — the analyzer, the grounded service, the loop model — is used
as-is. No backend, Supabase, edge-function, prompt, provider, API, persistence
or AI-logic changes.

## The seven steps

1. **Welcome** — "BusinessBrain ist das digitale Wissenszentrum eines
   Unternehmens." + a "Demo starten" button.
2. **Build knowledge** — unstructured text → structured knowledge (Knowledge
   Builder).
3. **Grounded answer** — answered from the knowledge base, sources shown, no
   invention.
4. **Knowledge gap** — a new question without enough knowledge → honest gap.
5. **Improvement & control** — automatic suggestion; an employee decides;
   nothing is saved automatically.
6. **Learning loop** — the full cycle at a glance: company knowledge → answer
   customer questions → new questions → gaps detected → improvement suggestions
   → employee decides → knowledge base grows → better answers.
7. **Conclusion** — a large card: "BusinessBrain lernt nicht durch
   Halluzinationen.", "Das Unternehmen behält jederzeit die Kontrolle.", "Jede
   bestätigte Ergänzung verbessert alle zukünftigen Antworten."

## Layout

- **Wide (≥ 820 px):** left step navigation (1–7, tappable, current
  highlighted, completed checked) + right content pane.
- **Narrow:** a horizontal step strip on top + content below.
- A `LinearProgressIndicator` and a "Schritt x / 7" counter are always visible;
  Back/Next controls advance the story. Fully DE/EN, Material 3, responsive and
  overflow-free on mobile and desktop.

## Files

- `lib/screens/guided_demo/guided_demo_screen.dart` — the guided shell.
- `lib/l10n/*` — DE/EN strings (`gd*`, reusing `kiStep`).
- `lib/router/app_router.dart`, `lib/widgets/app_shell.dart` — route + nav.
- `test/guided_demo_screen_test.dart` — welcome, start, full walk (asserts each
  embedded module by type), EN localization, no overflow on mobile/desktop.

## Note

This is the final large demo block. Subsequent work focuses on the long-term
vision (autonomous research agents, competitor analysis, visibility monitoring,
morning briefings, strategic recommendations, task coordination, continuous
company observation) — not further demo modules.
