# Supabase Backend Foundation

Backend foundation for the Universal Business Platform.

This folder contains the Supabase schema, seed data, and database tests for
the future SaaS backend. Blocks 22A-22F provide the backend foundation, auth
foundation, tenant-safe reads, controlled remote CRUD policies, initial tenant
onboarding, and tenant selection metadata.

## Requirements

- Supabase CLI
- Docker Desktop or another Docker runtime supported by Supabase

Check locally:

```bash
supabase --version
docker --version
```

## Local start

From the repository root:

```bash
supabase start
```

The local API, database, Studio, and Inbucket ports are configured in
`supabase/config.toml`.

## Apply migrations and seed

Reset the local database, apply all migrations, and run `seed.sql`:

```bash
supabase db reset
```

Current migrations include:

```text
supabase/migrations/0001_initial_schema.sql
supabase/migrations/0002_auth_foundation.sql
supabase/migrations/0004_remote_workspace_crud.sql
supabase/migrations/0005_tenant_onboarding.sql
supabase/migrations/0006_tenant_selection.sql
supabase/migrations/0007_public_intake_invitations.sql
supabase/migrations/0008_public_intake_rpc.sql
```

The seed creates only:

- one demo tenant
- one demo user
- one HB Cure workspace/company
- one SchnurrPurr workspace/company

It does not import the large Flutter mock data.

## Run database tests

```bash
supabase test db
```

The pgTAP tests live in:

```text
supabase/tests/database/
```

Current test coverage:

- required tables exist
- standard audit fields exist
- core foreign keys exist
- RLS is enabled on application tables
- expected policies exist
- tenant isolation smoke test with two authenticated users
- auth profile and membership helpers
- remote workspace read isolation
- remote CRUD policy checks for owner/viewer/inactive/no-membership/anon
- server-side `updated_at` behavior and status constraints
- tenant onboarding RPC transaction, idempotency, validation, and RLS
- tenant selection RPC visibility, roles, workspace metadata, and anon denial
- public intake invitation table, status constraints, and RLS write boundaries
- secure public intake RPCs for token open, autosave, resume, and disabled-token handling

## Reset

```bash
supabase db reset
```

This drops and recreates the local database from migrations and `seed.sql`.

## Schema principles

The database is the future company memory, not just technical storage.

Relational tables are used for data that must be queried over time:

- knowledge entries
- source materials
- bot question logs
- action records
- companion check-ins
- business goals
- marketing actions
- audit items
- review logs

JSONB is used only for document-like data that is read and written as a block:

- company social links
- business rules
- bot configuration
- intake sections
- check-in content
- import/change metadata

## Security model

All application tables have Row Level Security enabled.

Access is based on:

```text
auth.uid() -> tenant_members -> tenant role -> table policies
```

Roles:

- owner
- admin
- editor
- reviewer
- viewer

Client-side `TenantContext` is convenience only. It is not a security boundary.
RLS policies are the backend security boundary.

Write policies currently allow:

- owner/admin/editor: domain content writes
- reviewer: review-oriented writes on bot question logs and review logs
- viewer: read only

Remote Flutter writes use `TenantContext` for tenant/user/role context, but the
database still rejects unauthorized direct API calls through RLS.

## Initial tenant onboarding

Signed-in users without an active membership call:

```sql
public.create_initial_tenant_workspace(...)
```

The function is `security definer`, uses only `auth.uid()` for ownership, and
creates in one transaction:

- tenant
- active owner membership
- first workspace
- company profile
- conservative draft bot configuration

The RPC accepts only business fields such as company name, website, industry,
description, language, and optional workspace name. It does not accept tenant
IDs, user IDs, roles, timestamps, or owner IDs. Users who already have an
active membership cannot run the initial onboarding again; additional tenant
creation is a later block.

## Tenant selection

Signed-in users resolve selectable companies through:

```sql
public.active_tenant_memberships()
```

The function is `security definer`, accepts no user identifier, uses
`auth.uid()`, and returns only active memberships on active tenants. It includes
safe display metadata for the client:

- membership id
- tenant id and tenant name
- membership role and status
- workspace count
- primary workspace id/name

Anonymous users cannot execute the function. The client stores only the last
selected tenant id per user locally; RLS remains the backend security boundary.

## Public intake invitations

The `intake_invitations` table stores workspace-scoped company questionnaire
invitations with:

- a non-human token hash instead of a company slug
- status values for invited, started, partial, completed, and disabled
- tenant/workspace/company references
- server-managed audit fields
- RLS policies for authenticated tenant members

The table does not grant anonymous direct reads. Public access goes through
narrow `security definer` RPCs:

```sql
public.public_open_intake_invitation(raw_token)
public.public_save_intake_session(raw_token, session_payload)
```

Admin link management uses authenticated RPCs:

```sql
public.create_intake_invitation(target_workspace_id, target_company_id, invitation_greeting)
public.regenerate_intake_invitation(target_workspace_id, target_company_id, invitation_greeting)
public.deactivate_intake_invitation(target_workspace_id, target_company_id)
```

The clear invitation token is generated server-side and returned only from
create/regenerate. The database stores only `token_hash`.

## Current limits

The current backend foundation still does not include:

- additional tenant creation
- invitations or membership management
- IndexedDB-to-cloud migration
- realtime synchronization
- offline outbox/conflict resolution
- reminder jobs
- Edge Functions
- file upload/storage workflows

Those belong to later backend phases.

## Next phase

Block 22G: Team invitations, membership management, and role control.
