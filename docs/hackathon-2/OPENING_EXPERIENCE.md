# Opening Experience & First 60 Seconds (BLOCK 10)

Finalisation polish for the first impression. Presentation/dramaturgy only — no
new features, no AI/Supabase/edge/Gemini/DB/business-logic changes.

## Landing experience (`/jury`, `JuryStartScreen`)

A calm, high-quality entry:

- Large brand heading **BusinessBrain**.
- Positioning line: "Die lernende Unternehmens-KI." / "The learning company AI."
- One short description paragraph (grounded, answers only from confirmed
  knowledge, improves via human-approved building blocks).
- Two large actions: **"Jury-Demo starten"** and **"Plattform erkunden"**.
- A subtle, atmosphere-only background: the value chain (Unternehmenswissen →
  Kundenfragen → Wissenslücken → Verbesserungen → Lernkreislauf → BusinessBrain)
  fades in slowly, node by node. It is a **one-shot** animation (no repeat,
  low opacity, non-interactive) — calm, never distracting, and it settles.

"Jury-Demo starten" launches the existing guided jury demo; "Plattform erkunden"
enters the app in jury mode.

## Guided demo transitions (`/jury-demo`, `JuryTourScreen`)

- A soft **AnimatedSwitcher** fade between stations (≈350 ms) — no hectic motion.
- Each station shows a short, high-quality **transition line** that fades in:
  "BusinessBrain beginnt mit dem Wissen Ihres Unternehmens.", "Jetzt beantwortet
  die KI eine echte Kundenfrage.", "Fehlendes Wissen wird erkannt.", "Der
  Mitarbeiter entscheidet.", "Die Wissensbasis wächst.", "Alle zukünftigen
  Antworten profitieren."
- A persistent **step counter**: "Schritt X von 6" / "Step X of 6".

## Closing page

Instead of dropping straight into the menu, the tour ends on a polished closing
page:

- Large heading: "BusinessBrain lernt niemals durch Vermutungen."
- Subtitle: "Jede Verbesserung basiert auf bestätigtem Unternehmenswissen."
- "Heute gesehen:" — a checklist of the seven areas shown (Grounded AI,
  Wissensbasis, Human Review, Knowledge Builder, Lernkreislauf, Operations
  Dashboard, Business Story).
- "Vielen Dank für Ihr Interesse an BusinessBrain."
- Optional link chips: Projektseite (QR), GitHub, Projektvideo, Dokumentation.

## Files

- `lib/screens/jury/jury_start_screen.dart` — landing hero + one-shot flow
  background.
- `lib/screens/jury/jury_tour_screen.dart` — transitions, step counter, closing.
- `lib/l10n/*` — DE/EN strings (`hero*`, `juryTrans*`, `juryOf`, `ox*`).
- `test/opening_experience_test.dart` — hero content + mobile no-overflow, step
  counter, closing page, EN localization.

Material 3, responsive, DE/EN. All motion is soft and one-shot so the UI settles
(no infinite animations). Goal: within the first minute a jury perceives a
professional platform, not a technical prototype.
