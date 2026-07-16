# Supabase Backend Foundation

Backend foundation for the Universal Business Platform.

This folder contains the first Supabase schema for the future SaaS backend.
It is intentionally backend-only: no Flutter UI, AppState, repository, or auth
integration is part of Block 22A.

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

The initial migration is:

```text
supabase/migrations/0001_initial_schema.sql
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

## Current limits

Block 22A does not include:

- login UI
- Supabase Flutter integration
- remote repositories
- IndexedDB-to-cloud migration
- reminder jobs
- Edge Functions
- file upload/storage workflows

Those belong to later backend phases.

## Next phase

Block 22B: Auth Foundation.
