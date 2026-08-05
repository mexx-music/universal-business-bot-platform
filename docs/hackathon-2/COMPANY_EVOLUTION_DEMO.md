# Company Evolution Demo (G-6)

The first **visible** surface of the Research Engine foundation (G-5). It renders
the local, brand-neutral demo research for a selected company — its profile, its
timeline, its sources and the evidence extracted from those sources — with a
clear transparency notice. No web research, no crawling, no external API, no
Gemini analysis, and no second demo data source: it consumes G-5 as-is.

Route: `/company-evolution` (in the app shell). Nav entry: "Recherche" →
"Unternehmens-Evolution" / "Company Evolution".

## Data flow

```
CompanyEvolutionScreen (widget)
   │  reads only ↓ (no repository/demo-data access from the UI)
CompanyEvolutionController  (ChangeNotifier + InheritedNotifier scope)
   │  reads only ↓
ResearchRuntime            (G-5 central entry point)
   │  reads only ↓
ResearchRepository → LocalResearchRepository → ResearchDemoData (G-5)
```

- The **screen** depends on `CompanyEvolutionController.of(context)`. Because the
  controller is exposed via an `InheritedNotifier` (`CompanyEvolutionScope`,
  wired in the composition root), selecting another company rebuilds the screen
  automatically.
- The **controller** is a small view-model: it loads the companies, holds the
  selected one (defaulting to the first), switches selection, and exposes the
  snapshot / timeline / documents / evidence for the current company. It talks
  only to `ResearchRuntime`.
- No widget touches `ResearchRepository` or `ResearchDemoData` directly, and no
  research or sorting logic lives in the UI.

## Role of ResearchRuntime

`ResearchRuntime` remains the single point the app reads research through. The
controller delegates every read to it:

- `companies` / `company(id)` — the researched companies,
- `timeline(id)` — **sorted** (oldest → newest) by the model/runtime, never by
  the widget,
- `evidenceForDocument(companyId, documentId)` — evidence resolved strictly by
  document id.

When a real research pipeline eventually replaces the demo repository, this
screen and controller change **nothing** — they already sit behind the runtime.

## Separation of document and evidence

Sources and statements are modelled — and displayed — separately:

- A **ResearchDocument** is a reference to an external source (title, source
  name, type, publish date, language, country, URL-as-text). The URL is shown as
  plain text only; the screen never navigates to the web.
- A **ResearchEvidence** is one source-backed statement that points back to
  exactly one document via `documentId`.

The screen renders each document as a card and nests **only that document's**
evidence beneath it (resolved via `evidenceForDocument`). Evidence can never
appear under the wrong document — this is covered by both a controller test and a
widget test (`ev-nordlicht-3` shows under `doc-nordlicht-2`, never under
`doc-nordlicht-1`).

## Screen structure

1. **Company selector** — dropdown over the available companies; first selected
   by default; responsive.
2. **Company profile** (from `CompanySnapshot`) — company name, industry,
   founding year, market segment, countries, known products, website, social
   channels, rating, last-updated. Only fields that are actually present are
   shown.
3. **Timeline** — chronological `CompanyTimelineEvent`s, each with date, a
   category chip, title and description.
4. **Research sources** — the `ResearchDocument`s of the selected company (title,
   source, type, publish date, language, country, URL as text).
5. **Evidence** — for each document, its `ResearchEvidence` (summary, category,
   confidence, extraction date), clearly grouped under the owning document.
6. **Transparency notice** — demo data, no live research, no AI-generated
   conclusions, sources and statements modelled separately.

Empty states exist for: no companies, no timeline entries, no documents, no
evidence.

Responsiveness: a two-column layout ≥ 900 px (profile + timeline | sources), a
single column below, everything inside a scroll view — verified overflow-free on
desktop (1400 px) and mobile (390 px) widths.

## Why no live research yet

Same deliberate sequencing as G-5 (see `RESEARCH_FOUNDATION.md`): the UI and its
contract are proven against deterministic demo data first. Real gathering must
run behind a server-side boundary (like the Gemini integration), and the client
must never crawl or hold third-party keys. Building the visible layer on the
stable local contract keeps that boundary clean and the demo fully offline and
testable.

## What builds on this

- **Market Intelligence** — will compare `CompanySnapshot` + `ResearchEvidence`
  across companies; this screen already proves the snapshot/evidence rendering.
- **Marketing Evolution** — will filter the same timeline/evidence by the
  marketing category.
- **Gemini analysis** — will later summarise or draw conclusions from the
  *already-selected* evidence, routed through the existing `AiController`
  (server-side Gemini), while sources stay separate from AI text — exactly the
  grounding principle used by the knowledge bot.

Because every statement is tied to a document, all of these can show *why* they
say what they say.

## Tests

- `test/company_evolution_controller_test.dart` — loads via runtime; first
  company default; switch updates snapshot/timeline + notifies; no-op on
  same/unknown id; timeline chronological; evidence per document with no
  cross-document leakage; empty repository safe.
- `test/company_evolution_screen_test.dart` — default company; switching updates
  snapshot + timeline; chronological display order; evidence nested under the
  correct document; empty states (no companies / timeline / documents /
  evidence); no overflow on desktop and mobile; reachable via app navigation to
  `/company-evolution`.

All tests run offline — no network, no APIs, no crawling.
