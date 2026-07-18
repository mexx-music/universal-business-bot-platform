-- Public intake invitations.
--
-- This table prepares secure company questionnaire links without exposing
-- internal workspace data. Public token resolution should happen through a
-- narrow RPC in a later block; the table itself remains protected by RLS.

create table public.intake_invitations (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  company_id text not null,
  id text not null,
  token_hash text not null,
  status text not null default 'invited'
    check (status in ('invited', 'started', 'partial', 'completed', 'disabled')),
  greeting text not null default '',
  started_at timestamptz,
  completed_at timestamptz,
  disabled_at timestamptz,
  expires_at timestamptz,
  last_autosaved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  primary key (workspace_id, id),
  unique (token_hash),
  foreign key (workspace_id, company_id)
    references public.companies(workspace_id, id) on delete cascade
);

create index intake_invitations_tenant_id_idx
  on public.intake_invitations(tenant_id);
create index intake_invitations_workspace_id_idx
  on public.intake_invitations(workspace_id);
create index intake_invitations_company_id_idx
  on public.intake_invitations(company_id);
create index intake_invitations_status_idx
  on public.intake_invitations(status);
create index intake_invitations_created_at_idx
  on public.intake_invitations(created_at);
create index intake_invitations_token_hash_idx
  on public.intake_invitations(token_hash);

create trigger intake_invitations_set_row_audit_fields
before update on public.intake_invitations
for each row execute function public.set_row_audit_fields();

alter table public.intake_invitations enable row level security;

grant select, insert, update, delete on public.intake_invitations
  to authenticated;

create policy intake_invitations_read_by_members
on public.intake_invitations
for select
using (public.can_read_tenant(tenant_id));

create policy intake_invitations_insert_by_writers
on public.intake_invitations
for insert
with check (public.can_write_tenant(tenant_id));

create policy intake_invitations_update_by_writers
on public.intake_invitations
for update
using (public.can_write_tenant(tenant_id))
with check (public.can_write_tenant(tenant_id));

create policy intake_invitations_delete_by_admins
on public.intake_invitations
for delete
using (public.can_admin_tenant(tenant_id));
