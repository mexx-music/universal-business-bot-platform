# Research Engine Foundation (G-5)

BusinessBrain answers today from a company's **own** knowledge base (see
`GROUNDED_BOT_DEMO.md`). To reason about a company's *market* and *evolution*,
it also needs a structured picture of the outside world. This block builds the
**data foundation** for that — and nothing more.

## What this layer is

A small, self-contained module under `lib/research/` that models external
information as plain, immutable value objects and serves brand-neutral demo data
through a repository/runtime pair:

```
lib/research/
├── models/
│   ├── research_enums.dart        ResearchDocumentType, ResearchEvidenceCategory,
│   │                              TimelineCategory
│   ├── research_document.dart     ResearchDocument   (a source reference)
│   ├── research_evidence.dart     ResearchEvidence   (one source-backed claim)
│   ├── company_snapshot.dart      CompanySnapshot    (point-in-time facts)
│   ├── company_timeline_event.dart CompanyTimelineEvent
│   └── company_research.dart      CompanyResearch    (aggregate per company)
├── research_repository.dart        ResearchRepository (interface)
├── local_research_repository.dart  LocalResearchRepository (in-memory demo)
├── research_demo_data.dart         3 fictional companies
└── research_runtime.dart           ResearchRuntime    (central entry point)
```

### The models

- **ResearchDocument** — a reference to one external document (news article,
  blog post, review, press release, …). It carries a `sourceUrl`, but this layer
  never requests it; the URL is metadata only.
- **ResearchEvidence** — one small, source-backed statement ("Neue Produktlinie
  veröffentlicht", "Expansion nach USA"). Every evidence points back to exactly
  one document via `documentId`, so a claim is always traceable to its source.
- **CompanySnapshot** — a point-in-time set of known facts (products, countries,
  website, social media, rating, market segment). No AI, no derivation — just
  data.
- **CompanyTimelineEvent** — a dated milestone with a `TimelineCategory`
  (founding, product, expansion, finance, …).
- **CompanyResearch** — the aggregate that bundles a company's snapshot,
  timeline, documents and evidence, with pure read helpers (`timelineSorted`,
  `evidenceForDocument`).

### Repository & runtime

- **ResearchRepository** is the data-access boundary. In G-5 the only
  implementation, **LocalResearchRepository**, serves in-memory demo data.
- **ResearchRuntime** is the central entry point the rest of the app will use.
  Today it only *loads demo data* and exposes a few pure helpers (sorted
  timeline, evidence-for-document). It computes nothing and reaches nowhere.

## Why web research is deliberately NOT here yet

This block intentionally contains **no real web research, no crawling and no API
access**. That is a deliberate sequencing decision, not an omission:

1. **Contract before pipeline.** Fixing the data shapes first lets the
   intelligence modules and their UI be built and tested against a stable,
   deterministic contract — before any flaky, rate-limited external source is
   involved.
2. **Security boundary.** When real research arrives, it must run behind a
   server-side boundary (as the Gemini integration already does — the client
   never holds keys or calls third parties directly). Designing the local
   contract first keeps that boundary clean: the UI depends on
   `ResearchRepository`/`ResearchRuntime`, never on a network client.
3. **Determinism & tests.** Demo data makes every downstream feature
   demonstrable and unit-testable offline, with no network in the test suite.
4. **Compliance.** Crawling, scraping and third-party API terms need explicit
   handling. Keeping this block data-only avoids taking on that surface before
   it is designed.

When the real pipeline lands, it slots in **behind the existing interface**:
`ResearchRuntime` gains the collect → filter → AI-prepare → assemble-timeline
steps, and a non-local `ResearchRepository` implementation feeds it — with no
change required in any consuming module or screen.

## How later modules build on this

The following planned modules all consume this foundation rather than gathering
their own data:

- **Market Intelligence** — reads `CompanySnapshot` + `ResearchEvidence` across
  companies to position a company in its segment.
- **Company Evolution** — renders `CompanyTimelineEvent`s (already sorted by the
  runtime) into a company history.
- **Marketing Evolution** — filters evidence/timeline by the `marketing`
  category to trace how a company's messaging changed over time.
- **Competitor Analysis** — compares snapshots and evidence between
  `CompanyResearch` aggregates.

Because every claim is tied to a `ResearchDocument`, each of these modules can
show *why* it says what it says — the same source-grounding principle as the
knowledge bot.

## Tests

`test/research_foundation_test.dart`:

- timeline is returned sorted oldest → newest (demo data is stored unsorted);
- every evidence entry references an existing document;
- `evidenceForDocument` returns only that document's evidence;
- every demo company has a complete snapshot;
- the repository serves data and resolves ids (and returns null for unknown);
- the runtime returns companies, sorts timelines, resolves evidence, and accepts
  an injected repository.

All tests run fully offline — no network, no APIs, no crawling.
