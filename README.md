# Universal Business Bot Platform

AI-powered multi-tenant business workspace for company knowledge, human-reviewed customer support, and business intelligence.

## At a Glance

- Multi-tenant workspaces
- Human Review workflow
- Knowledge Base
- Company Intake
- Business Audit
- Business Intelligence
- Local Demo Mode (no login)
- Flutter Web + Cloudflare Pages

Built during OpenAI Build Week with Codex as the primary engineering collaborator and GPT-5.6 as the intended reasoning layer for future recommendation and assistant workflows. The current submitted MVP keeps runtime decisions deterministic and local by design: no live OpenAI API calls are required to run the demo.

## Build Week Submission Notes

- **Track fit:** Work and Productivity
- **Primary user:** small and medium-sized business owners and operators
- **Core idea:** a digital company companion that turns company memory into explainable next best actions
- **Public demo:** https://universal-business-bot-platform.pages.dev/
- **Repository:** `https://github.com/mexx-music/universal-business-bot-platform`
- **Runtime AI:** not required for this MVP; deterministic local logic keeps the demo reproducible and safe
- **Human-in-the-loop:** risky or low-confidence support questions are routed into Human Review instead of being blindly automated

## Idea

The project explores a platform layer for three connected areas:

- Company workspaces and business knowledge: profile, products, rules, sources, audit, goals, and company memory
- Bot testing and safe support workflows: local retrieval, risk levels, handover behavior, and bot configuration per company
- Human review and escalation: unanswered, risky, or blocked bot interactions become review items and can be converted into knowledge entries

The bot is not the product. The product direction is the intelligent action plan: the platform should repeatedly answer, "What is the next most useful step for this business, and why?"

## Current MVP Scope

The current app includes:

- Public landing page and company selection for the local MVP
- Dashboard with knowledge, review, redirect, and audit metrics
- Company profile and product/service overview
- Guided company intake and conversational intake flow
- Workspace-scoped public questionnaire invitation links with secure Supabase token resolution when configured
- Project status, next best actions, monthly check-ins, and action lifecycle
- Business Strategy, Marketing Strategy, and Business Intelligence modules
- Business audit for company readiness, source quality, risk rules, and bot readiness
- Knowledge Base with categories, risk levels, sources, and manual entries
- Bot Test screen using local keyword matching only
- Human Review workflow for open, reviewed, and closed bot logs
- Review-to-Knowledge workflow for turning reviewed questions into knowledge entries
- Sources and material management per company
- Bot configuration per company
- Multi-company support with isolated local mock data per workspace
- Local persistence: workspace data is stored in the current browser (IndexedDB) and survives reloads — device- and browser-bound, no cloud sync
- Optional Supabase authentication foundation: local mode by default, sign-up/sign-in/session restore/logout when configured
- Remote workspace repository for Supabase mode, scoped by active tenant membership
- Tenant onboarding for signed-in users without a membership: creates the first tenant, owner membership, workspace, company profile, and draft bot configuration
- Tenant selection for users with multiple active memberships, including a safe company switcher and last-used company preference
- German and English localization structure
- Local demo data for HB Cure and SchnurrPurr

## How Codex And GPT-5.6 Were Used

Codex was used as the main build partner across the project:

- product architecture: reframing the project from a bot dashboard into a digital company companion
- implementation: Flutter screens, routing, state management, local persistence, Supabase foundation, repository boundaries, RLS migrations, and tests
- quality work: architecture reviews, refactoring, responsive UI fixes, localization, web/PWA deployment preparation, and database test coverage
- safety decisions: deterministic local recommendations, clear tenant separation, no hidden cloud fallback, and Human Review for uncertain support flows

GPT-5.6 is documented as the target model for the future intelligent reasoning layer. In this MVP, its role is intentionally not a live runtime dependency. The deterministic recommendation engine and Knowledge Runtime define the boundaries that a future GPT-5.6 integration should respect: explainable recommendations, confidence awareness, source grounding, and human approval before risky automation.

For Devpost, include the required `/feedback` Codex Session ID from the primary build thread and mention the specific sessions where Codex accelerated implementation and architectural decisions.

## Demo Flow

Recommended judging path:

1. Open the public landing page.
2. Choose one of the demo companies, for example HB Cure or SchnurrPurr.
3. Review the Dashboard and Project Status to see the automatically derived next steps.
4. Open Company, Audit, Knowledge Base, Sources, Marketing Strategy, Business Strategy, and Business Intelligence.
5. Use Bot Test with a safe question and then a risky or unknown question.
6. Open Human Review and convert a review item into a Knowledge Base entry.
7. Switch companies and confirm that demo data stays separated.

## Demo Mode

The public demo can be explored without login. Use the landing page, start the
demo, and select either Healing and Balance GmbH or SchnurrPurr. Demo workspaces
are isolated from each other and run on local demo data unless Supabase mode is
explicitly configured for an authenticated environment.

## Not Included

This MVP intentionally does not include:

- Production backend operations beyond the current Supabase foundation
- Full offline/cloud synchronization
- Workspace data synchronization after login
- Team invitations, role management, or billing
- Real AI model/API integration
- Automated document ingestion
- Production-grade compliance or medical/legal advice handling

## Quick Start

```sh
flutter pub get
flutter gen-l10n
flutter run -d chrome
```

The default local mode requires no login and no backend. It opens with local demo workspaces for HB Cure and SchnurrPurr.

## Tech Stack

- Flutter
- Dart
- Material 3
- go_router
- Flutter localizations / ARB files
- Repository layer with local IndexedDB persistence (sembast) and in-memory fallback
- Optional Supabase Auth via `supabase_flutter`
- Supabase remote workspace reads and controlled CRUD writes behind the same repository interface

## Supported Platforms

The current MVP is optimized for Flutter Web on modern desktop browsers, with
responsive support for tablet and smartphone widths. The Flutter codebase can be
extended toward mobile and desktop targets later, but the Build Week demo should
be evaluated in a browser.

## Local and Authenticated Modes

The app supports two startup modes:

- **Local mode:** no backend configuration required. Run with:

```sh
flutter run -d chrome
```

- **Supabase mode:** authentication is enabled when both build variables are present:

```sh
flutter run -d chrome \
  --dart-define=SUPABASE_URL=http://127.0.0.1:54321 \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<LOCAL_PUBLISHABLE_KEY>
```

In Supabase mode the app restores the auth session before the first frame, resolves active tenant memberships from Supabase, and redirects unauthenticated users to `/login` for internal routes. If Supabase is not configured or initialization fails, the app falls back to local mode.

Repository selection is centralized in `AppDependencies`:

- local mode uses the local IndexedDB/in-memory repository and demo workspaces
- authenticated Supabase mode uses `RemoteWorkspaceRepository`
- users without an active tenant membership are redirected to `/onboarding` and never see local demo data
- users with multiple active memberships either resume their last valid company or choose one at `/select-tenant`

The remote repository reads workspaces, companies, products, knowledge entries, source materials, bot question logs, and audit items. Controlled cloud writes are supported for company profile/rules/bot configuration, products, knowledge entries, source materials, bot question logs, and audit item updates. Every remote query and write is scoped by the resolved `TenantContext.tenantId`; tenant IDs are not accepted from the UI.

Remote writes use a server-first strategy: the repository sends the change to Supabase, receives the confirmed row, maps it back into the workspace snapshot, and only then notifies AppState. RLS remains the security boundary. Client-side role checks only guide behavior.

Initial tenant setup uses the Supabase RPC `create_initial_tenant_workspace`. The RPC is transactionally server-side, uses `auth.uid()` for the owner, fixes the role to `owner`, and rejects users who already have an active membership. It creates no HB Cure or SchnurrPurr demo data.

Tenant selection uses the RPC `active_tenant_memberships`. With one active membership the tenant is selected automatically. With multiple memberships the app restores the last valid tenant for the current user; otherwise it shows `/select-tenant`. Tenant switching clears the old workspace state, rebuilds the remote repository with the new `TenantContext`, and navigates to the dashboard.

Known limits for this block: no local data is uploaded automatically, team invitations and role management do not exist yet, additional tenant creation is still separate, realtime synchronization/conflict resolution are not included, and there is no offline outbox for Supabase writes.

## Web / PWA

The browser is the primary access path. Supported browsers can optionally install the app or add it to the home screen, but installation is not required.

Release build:

```sh
flutter pub get
flutter gen-l10n
flutter test
flutter build web --release
bash scripts/prepare_cloudflare_pages.sh
```

The build output is written to `build/web`. Production PWA behavior requires HTTPS, except for local development on `localhost`.

Because the app uses Flutter web routing with direct routes such as `/companies`, `/dashboard`, `/onboarding`, `/intake-chat`, and `/bot-settings`, the hosting server should fall back to `index.html` for app routes. This can be configured with the equivalent of a Firebase Hosting rewrite, Netlify redirect, Cloudflare Pages SPA fallback, or a GitHub Pages-compatible setup.

## Test Deployment

GitHub remains the source of truth for code. The preferred test deployment path is:

- GitHub Actions installs Flutter `3.35.7`
- `flutter pub get`
- `flutter gen-l10n`
- `flutter test`
- `flutter build web --release`
- `bash scripts/prepare_cloudflare_pages.sh`
- the generated `build/web` directory is deployed to Cloudflare Pages

The workflow in `.github/workflows/cloudflare-pages.yml` builds on every push to `main`. It deploys to Cloudflare Pages when the repository variable `CLOUDFLARE_PAGES_PROJECT_NAME` is set and the required GitHub Secrets exist:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

For the deployed web app to use Supabase instead of local demo storage, set these GitHub Secrets as well:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

Only browser-safe Supabase publishable keys may be passed to Flutter Web. Never use
`SUPABASE_SECRET_KEY`, `service_role`, or any `sb_secret_...` key in GitHub
Actions, Cloudflare Pages, or a `--dart-define`.

Optionally set the repository variable `AUTH_REDIRECT_URL` when the deployed authentication redirect should use an explicit URL.
Set `PUBLIC_APP_URL` to the public Cloudflare Pages or custom-domain URL, for example `https://<project>.pages.dev`. If it is omitted, the workflow derives `https://<CLOUDFLARE_PAGES_PROJECT_NAME>.pages.dev` when the Pages project variable is available. The app never invents a public questionnaire domain at runtime; when it is not running from an HTTP(S) browser origin and no valid public URL is configured, it shows a clear error instead of creating a `file://` link.

No Cloudflare tokens or secret values are stored in the repository.

Cloudflare Pages should initially serve a `pages.dev` test URL. A custom domain can be connected later. For Flutter/GoRouter routes such as `/companies`, `/dashboard`, `/onboarding`, `/intake`, `/intake-chat`, and `/bot-settings`, Cloudflare needs an SPA fallback. The `web/_redirects` file contains:

```txt
/* /index.html 200
```

The `scripts/prepare_cloudflare_pages.sh` step copies this file into `build/web` after the Flutter build and verifies the expected PWA files. Refreshed direct routes can then fall back to `index.html` after deployment.

## PWA Status And Current Limitations

The current PWA preparation provides a web app manifest, app icons, standalone display metadata, and Flutter's generated service worker in release builds. After the first successful load, the app shell and static build assets can be available again depending on browser support and cache state.

This does not add authentication, a backend, secure server-side tenancy, encrypted persistent customer storage, or device synchronization. Workspace data persists locally in the current browser (IndexedDB) and survives reloads; it remains bound to this device and browser profile and is lost when site data is cleared. Production customer data requires authentication, backend storage, and a database design.

## Status

Internal MVP / work in progress. Presentation-ready for a Build Week demo after adding the final Devpost demo video URL, Codex `/feedback` Session ID, and repository license decision.
