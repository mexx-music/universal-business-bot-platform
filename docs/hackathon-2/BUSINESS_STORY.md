# Business Story & Jury Experience (BLOCK 6)

A credibility-focused page at `/business-story` aimed at entrepreneurs,
investors and jury members (not developers). It answers, in ~2 minutes: which
problem BusinessBrain solves, why it is more than a normal AI chat, and what a
company gains — while clearly separating what exists today from the long-term
vision.

Presentation only: **no** backend, Supabase, edge-function, prompt, provider,
API or persistence changes, and **no** new business features. Material 3,
responsive, DE/EN.

Nav: "Business Story" / "Business story".

## Sections

1. **The problem** — knowledge is scattered across PDFs, emails, sites, people,
   manuals and support requests; time and quality are lost.
2. **The solution** — one central knowledge base; the AI answers only from it and
   shows sources; gaps become improvement suggestions; employees decide.
3. **The loop** — a large graphic of the full cycle: company knowledge → answer
   questions → new questions → gaps → suggestions → employee confirms →
   knowledge grows → better answers. (Reuses the loop wording already used by the
   guided demo / improvement loop.)
4. **Benefits** — eight high-quality cards, each grounded in a feature that
   already exists (faster support, consistent answers, central base, employee
   relief, continuous improvement, transparent sources, no hallucinations,
   human control). No marketing fluff.
5. **Deliberate boundaries** — a side-by-side contrast: what BusinessBrain
   deliberately does **not** do (invent facts, auto-publish, replace employees,
   decide on its own) vs. what it **does** (support employees, detect gaps,
   create suggestions, learn from confirmed knowledge). Builds trust.
6. **Vision** — clearly badged "🔵 Zukünftige Entwicklung / Future development"
   and visually separated (tertiary colour): autonomous research agents,
   competitor analysis, visibility monitoring, morning briefings, trend
   analysis, strategic recommendations, task allocation, continuous observation.

**Closing** — a large heading ("BusinessBrain entwickelt sich vom Wissenssystem
zum digitalen Unternehmensgehirn.") and a two-part paragraph separating today's
capabilities from the future direction.

## Status overview (credibility anchor)

Every capability is mapped to one of three categories so a jury instantly sees
what is real:

- **✅ Available** — central knowledge base, grounded assistant with sources,
  gap detection, AI Knowledge Builder, improvement suggestions (human decides),
  learning-loop visualisation, Company Evolution (demo data), roles & portals
  preview, DE/EN.
- **🟡 In development** — live Gemini in production (hardening), role enforcement
  & login guards, live research pipeline with real sources, Community Radar
  (read-only demo).
- **🔵 Long-term vision** — the eight future items above.

This mapping is honest: no capability is claimed as available that is not
actually implemented and tested in the codebase.

## Files

- `lib/screens/business_story/business_story_screen.dart` — the page.
- `lib/l10n/*` — DE/EN strings (`bs*`; the loop reuses `gdLoop*`).
- `lib/router/app_router.dart`, `lib/widgets/app_shell.dart` — route + nav.
- `test/business_story_screen_test.dart` — all sections, loop chain, benefits,
  contrast, vision badge, three status groups, EN localization, no overflow on
  mobile/desktop.
