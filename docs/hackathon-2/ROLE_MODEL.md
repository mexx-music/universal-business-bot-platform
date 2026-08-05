# Role Model: Company / Employee / Customer Portals (BLOCK 3)

Structure-only preparation for three portal tiers that share **one** knowledge
base. This block adds the model, the reduced-navigation catalog, a read-only
preview screen and a per-tier demo day. It deliberately contains **no login, no
permission enforcement, no backend/auth/DB/Supabase/Gemini changes.**

## Why this design

- **One source of truth.** All three tiers read from the same knowledge base
  (`RolePortal.knowledgeSource`). New knowledge is only maintained in the company
  portal. The same underlying data answers different questions per role later.
- **Descriptive, not enforcing.** `PortalCatalog` is pure data describing *which
  areas each portal shows*. Enforcement (login, guards, RLS) is intentionally a
  later block — keeping this change safe and reversible.
- **Reuses existing areas.** `PortalSection` maps to existing routes where they
  exist (`/knowledge`, `/knowledge-builder`, `/bot-test`, `/review`,
  `/company-evolution`, `/community`, `/business-intelligence`,
  `/marketing-strategy`, `/sources`, `/company`, `/bot-settings`, `/dashboard`);
  a few sections (research, competitors, employees, roles, customer assistant,
  contact) are conceptual placeholders for other blocks.
- **Single labelling path.** Section/tier/role labels go through
  `label_helpers.dart`, reusing existing `nav*` strings where possible — DE/EN.

## The three tiers

**Ebene 1 – Firmenadministrator (`PortalTier.company`)** — full internal
navigation incl. system areas (`aiSettings`, `roles`, `employees`). Sees
everything.

**Ebene 2 – Mitarbeiter (`PortalTier.employee` + `EmployeeRole`)** — a reduced
subset of the company portal, **never** a system-setting area:
- Support: knowledge, knowledge builder, review answers, AI assistant.
- Marketing: marketing, community, AI assistant.
- Technical: knowledge, knowledge builder, sources, AI assistant.
- Sales: products, knowledge, AI assistant.

**Ebene 3 – Kunde (`PortalTier.customer`)** — public sections only: customer
assistant and contact. No internal data, no employees, no research, no
competitors, no internal notes.

## Navigation proposal (reduced per role)

The `/portals` preview screen renders, for the selected persona:
- **Firmenportal** — all internal + management areas.
- **Mitarbeiterportal** — only the department's areas (system settings hidden).
- **Kundenportal** — customer assistant + contact only.

## Demo: a day per tier

- **Administrator** → import documents, structure them with the Knowledge
  Builder, assign roles, review analytics, watch Company Evolution/competitors.
- **Mitarbeiter** → open only assigned areas, prepare customer answers, add
  missing knowledge — no system settings.
- **Kunde** → ask a question, read the answer with sources, open released
  documents, get in touch — no internal data.

All three ask different questions of the **same** knowledge base:
- Admin: „Welche Supportanfragen häufen sich?"
- Support: „Welche Antwort soll ich dem Kunden schicken?"
- Kunde: „Wie verbinde ich mein Gerät?"

## Invariants (tested)

- Company portal is the superset of every employee portal.
- Employee portals never contain a system-setting section
  (`aiSettings`/`roles`/`employees`) and never a public section.
- Customer portal is public-only and contains no internal area.
- Every tier resolves to the same `knowledgeSource`.

## Files

- `lib/roles/models/portal_role.dart` — enums (`PortalTier`, `EmployeeRole`,
  `PortalSection`) + section metadata + `RolePortal`.
- `lib/roles/portal_catalog.dart` — reduced-navigation catalog.
- `lib/screens/roles/role_overview_screen.dart` — read-only `/portals` preview.
- `lib/l10n/*` + `label_helpers.dart` — DE/EN strings and label helpers.
- `lib/router/app_router.dart`, `lib/widgets/app_shell.dart` — route + nav entry.
- `test/portal_catalog_test.dart`, `test/role_overview_screen_test.dart`.

## Explicitly not done

No login, no permission logic, no backend/auth/DB/Supabase changes, no Gemini
prompt changes. Enforcement of these portals is a future block.
