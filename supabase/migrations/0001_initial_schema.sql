-- Universal Business Platform
-- Block 22A: initial Supabase schema.
--
-- Design intent:
-- - tenant/workspace ownership is relational and enforced by RLS,
-- - long-lived company memory is queryable over years,
-- - JSONB is used only for document-like leaf structures,
-- - Flutter client ids remain import-compatible through text entity ids.

create extension if not exists "pgcrypto" with schema extensions;

-- ---------------------------------------------------------------------------
-- Shared helpers
-- ---------------------------------------------------------------------------

create or replace function public.set_row_audit_fields()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  new.updated_by = coalesce(new.updated_by, auth.uid(), old.updated_by);
  new.rev = old.rev + 1;
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Tenancy and identity
-- ---------------------------------------------------------------------------

create table public.tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  plan text not null default 'free'
    check (plan in ('free', 'pro', 'team', 'enterprise')),
  status text not null default 'active'
    check (status in ('active', 'suspended', 'closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0
);

create table public.user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  locale text not null default 'de' check (locale in ('de', 'en')),
  timezone text not null default 'Europe/Vienna',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0
);

create table public.tenant_members (
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner', 'admin', 'editor', 'reviewer', 'viewer')),
  status text not null default 'active' check (status in ('active', 'invited', 'disabled')),
  invited_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  primary key (tenant_id, user_id)
);

-- Security-definer helpers keep policies readable and prevent recursive RLS
-- checks on tenant_members.
create or replace function public.current_tenant_role(target_tenant_id uuid)
returns text
language sql
stable
security definer
set search_path = public
as $$
  select tm.role
  from public.tenant_members tm
  where tm.tenant_id = target_tenant_id
    and tm.user_id = auth.uid()
    and tm.status = 'active'
    and tm.deleted_at is null
  limit 1;
$$;

create or replace function public.has_tenant_role(
  target_tenant_id uuid,
  allowed_roles text[]
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.current_tenant_role(target_tenant_id) = any(allowed_roles);
$$;

revoke all on function public.current_tenant_role(uuid) from public;
revoke all on function public.has_tenant_role(uuid, text[]) from public;
grant execute on function public.current_tenant_role(uuid) to authenticated;
grant execute on function public.has_tenant_role(uuid, text[]) to authenticated;

grant usage on schema public to authenticated;

-- ---------------------------------------------------------------------------
-- Workspace core
-- ---------------------------------------------------------------------------

create table public.workspaces (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  name text not null,
  archived_at timestamptz,
  import_batch_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0
);

create table public.companies (
  workspace_id uuid primary key references public.workspaces(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  id text not null,
  company_name text not null,
  short_description text not null default '',
  industry text not null default '',
  country text not null default '',
  primary_language text not null default 'de',
  website text not null default '',
  support_email text not null default '',
  support_phone text,
  social_links jsonb not null default '{}'::jsonb,
  business_rules jsonb not null default '{}'::jsonb,
  bot_configuration jsonb not null default '{}'::jsonb,
  internal_notes text not null default '',
  import_batch_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  unique (workspace_id, id),
  unique (tenant_id, id)
);

create table public.products (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  company_id text not null,
  id text not null,
  name text not null,
  description text not null default '',
  type text not null default 'product',
  price_note text,
  priority integer not null default 0,
  is_primary boolean not null default false,
  import_batch_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  primary key (workspace_id, id),
  foreign key (workspace_id, company_id)
    references public.companies(workspace_id, id) on delete cascade
);

-- ---------------------------------------------------------------------------
-- Knowledge, sources, support and review
-- ---------------------------------------------------------------------------

create table public.knowledge_entries (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  company_id text not null,
  id text not null,
  title text not null,
  content text not null,
  category text not null default 'faq',
  risk_level text not null default 'green' check (risk_level in ('green', 'yellow', 'red')),
  keywords text[] not null default '{}',
  source text not null default '',
  source_material_id text,
  language_code text not null default 'de',
  import_batch_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  primary key (workspace_id, id),
  foreign key (workspace_id, company_id)
    references public.companies(workspace_id, id) on delete cascade
);

create table public.source_materials (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  company_id text not null,
  id text not null,
  title text not null,
  type text not null default 'other'
    check (type in ('website', 'pdf', 'faq', 'review', 'social', 'note', 'other')),
  url text,
  content_snippet text,
  status text not null default 'new'
    check (status in ('new', 'reviewed', 'converted', 'ignored')),
  related_knowledge_entry_ids text[] not null default '{}',
  notes text,
  import_batch_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  primary key (workspace_id, id),
  foreign key (workspace_id, company_id)
    references public.companies(workspace_id, id) on delete cascade
);

alter table public.knowledge_entries
  add constraint knowledge_entries_source_material_fk
  foreign key (workspace_id, source_material_id)
  references public.source_materials(workspace_id, id)
  on delete set null (source_material_id);

create table public.bot_question_logs (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  company_id text not null,
  id text not null,
  question text not null,
  answer text,
  matched boolean not null default false,
  redirected boolean not null default false,
  reason text,
  risk_level text not null default 'green' check (risk_level in ('green', 'yellow', 'red')),
  review_status text not null default 'open'
    check (review_status in ('open', 'reviewed', 'closed')),
  reviewed_at timestamptz,
  human_note text,
  language_code text not null default 'de',
  import_batch_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  primary key (workspace_id, id),
  foreign key (workspace_id, company_id)
    references public.companies(workspace_id, id) on delete cascade
);

create table public.review_logs (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  company_id text not null,
  id text not null,
  target_table text not null,
  target_id text not null,
  review_type text not null default 'human_review',
  decision text not null default 'pending'
    check (decision in ('pending', 'approved', 'changed', 'rejected', 'escalated')),
  note text not null default '',
  confidence text not null default 'medium'
    check (confidence in ('low', 'medium', 'high')),
  reviewed_at timestamptz,
  import_batch_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  primary key (workspace_id, id),
  foreign key (workspace_id, company_id)
    references public.companies(workspace_id, id) on delete cascade
);

-- ---------------------------------------------------------------------------
-- Company memory: actions, check-ins, goals, marketing and audit
-- ---------------------------------------------------------------------------

create table public.action_records (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  company_id text not null,
  id text not null,
  action_type text not null,
  title_snapshot text not null,
  description_snapshot text not null default '',
  status text not null default 'suggested'
    check (status in ('suggested', 'accepted', 'inProgress', 'completed', 'deferred', 'declined')),
  accepted_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  deferred_until timestamptz,
  declined_at timestamptz,
  decline_reason text,
  result_rating text
    check (result_rating is null or result_rating in ('helpedALot', 'helpedSomewhat', 'noEffect', 'negative', 'notYetRatable')),
  result_note text,
  expected_impact text not null default 'medium',
  actual_outcome text,
  repeat_requested boolean,
  related_goal_ids text[] not null default '{}',
  source_reason_keys text[] not null default '{}',
  import_batch_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  primary key (workspace_id, id),
  foreign key (workspace_id, company_id)
    references public.companies(workspace_id, id) on delete cascade
);

create table public.companion_check_ins (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  company_id text not null,
  id text not null,
  period_start date not null,
  period_end date not null,
  status text not null default 'draft'
    check (status in ('draft', 'inProgress', 'completed', 'skipped')),
  completed_at timestamptz,
  data_confidence text not null default 'low'
    check (data_confidence in ('low', 'medium', 'high')),
  needs_human_review boolean not null default false,
  content jsonb not null default '{}'::jsonb,
  import_batch_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  primary key (workspace_id, id),
  foreign key (workspace_id, company_id)
    references public.companies(workspace_id, id) on delete cascade,
  check (period_end >= period_start)
);

create table public.business_goals (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  company_id text not null,
  id text not null,
  title text not null,
  description text not null default '',
  priority text not null default 'medium' check (priority in ('low', 'medium', 'high')),
  start_date date,
  target_date date,
  status text not null default 'planned'
    check (status in ('notStarted', 'planned', 'inProgress', 'achieved', 'paused', 'canceled')),
  owner text not null default '',
  comment text not null default '',
  linked_areas text[] not null default '{}',
  import_batch_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  primary key (workspace_id, id),
  foreign key (workspace_id, company_id)
    references public.companies(workspace_id, id) on delete cascade
);

create table public.marketing_actions (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  company_id text not null,
  id text not null,
  type text not null,
  priority text not null default 'medium' check (priority in ('low', 'medium', 'high')),
  effort text not null default 'medium' check (effort in ('low', 'medium', 'high')),
  impact text not null default 'medium' check (impact in ('low', 'medium', 'high')),
  status text not null default 'notStarted'
    check (status in ('notStarted', 'planned', 'inProgress', 'completed', 'postponed')),
  notes text not null default '',
  planned_budget numeric(12, 2),
  used_budget numeric(12, 2),
  budget_comment text not null default '',
  import_batch_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  primary key (workspace_id, id),
  foreign key (workspace_id, company_id)
    references public.companies(workspace_id, id) on delete cascade
);

create table public.audit_items (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  company_id text not null,
  id text not null,
  area text not null,
  title text not null,
  description text not null default '',
  status text not null default 'missing'
    check (status in ('missing', 'partial', 'complete')),
  priority text not null default 'medium' check (priority in ('low', 'medium', 'high')),
  note text,
  recommendation text,
  import_batch_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  primary key (workspace_id, id),
  foreign key (workspace_id, company_id)
    references public.companies(workspace_id, id) on delete cascade
);

create table public.intake_sessions (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  company_id text not null,
  id text not null,
  status text not null default 'draft'
    check (status in ('draft', 'inProgress', 'completed')),
  current_step integer not null default 0,
  chat_completed_at timestamptz,
  imported_at timestamptz,
  basics jsonb not null default '{}'::jsonb,
  products jsonb not null default '{}'::jsonb,
  target_groups jsonb not null default '{}'::jsonb,
  website_support jsonb not null default '{}'::jsonb,
  sources_reviews jsonb not null default '{}'::jsonb,
  marketing jsonb not null default '{}'::jsonb,
  goals_risks jsonb not null default '{}'::jsonb,
  import_batch_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  primary key (workspace_id, id),
  foreign key (workspace_id, company_id)
    references public.companies(workspace_id, id) on delete cascade
);

-- ---------------------------------------------------------------------------
-- Operational history
-- ---------------------------------------------------------------------------

create table public.import_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  workspace_id uuid references public.workspaces(id) on delete cascade,
  batch_id text not null,
  status text not null default 'started'
    check (status in ('started', 'completed', 'failed', 'rolledBack')),
  entity_counts jsonb not null default '{}'::jsonb,
  error_message text,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0,
  unique (tenant_id, batch_id)
);

create table public.change_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  workspace_id uuid references public.workspaces(id) on delete set null,
  entity_table text not null,
  entity_id text not null,
  actor_id uuid references auth.users(id) on delete set null default auth.uid(),
  action text not null check (action in ('insert', 'update', 'delete', 'restore', 'import')),
  diff jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  deleted_at timestamptz,
  rev integer not null default 0
);

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'tenants',
    'user_profiles',
    'tenant_members',
    'workspaces',
    'companies',
    'products',
    'knowledge_entries',
    'source_materials',
    'bot_question_logs',
    'review_logs',
    'action_records',
    'companion_check_ins',
    'business_goals',
    'marketing_actions',
    'audit_items',
    'intake_sessions',
    'import_logs',
    'change_log'
  ]
  loop
    execute format(
      'create trigger %I before update on public.%I for each row execute function public.set_row_audit_fields()',
      table_name || '_set_row_audit_fields',
      table_name
    );
  end loop;
end;
$$;

grant select, insert, update, delete on all tables in schema public to authenticated;

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

create index tenants_status_idx on public.tenants(status);
create index tenants_created_at_idx on public.tenants(created_at);

create index tenant_members_user_id_idx on public.tenant_members(user_id);
create index tenant_members_role_idx on public.tenant_members(role);
create index tenant_members_status_idx on public.tenant_members(status);
create index tenant_members_created_at_idx on public.tenant_members(created_at);

create index workspaces_tenant_id_idx on public.workspaces(tenant_id);
create index workspaces_created_at_idx on public.workspaces(created_at);
create index workspaces_archived_at_idx on public.workspaces(archived_at);

create index companies_tenant_id_idx on public.companies(tenant_id);
create index companies_company_id_idx on public.companies(id);
create index companies_created_at_idx on public.companies(created_at);

create index products_tenant_id_idx on public.products(tenant_id);
create index products_workspace_id_idx on public.products(workspace_id);
create index products_company_id_idx on public.products(company_id);
create index products_created_at_idx on public.products(created_at);

create index knowledge_entries_tenant_id_idx on public.knowledge_entries(tenant_id);
create index knowledge_entries_workspace_id_idx on public.knowledge_entries(workspace_id);
create index knowledge_entries_company_id_idx on public.knowledge_entries(company_id);
create index knowledge_entries_risk_level_idx on public.knowledge_entries(risk_level);
create index knowledge_entries_category_idx on public.knowledge_entries(category);
create index knowledge_entries_language_code_idx on public.knowledge_entries(language_code);
create index knowledge_entries_created_at_idx on public.knowledge_entries(created_at);
create index knowledge_entries_keywords_idx on public.knowledge_entries using gin(keywords);

create index source_materials_tenant_id_idx on public.source_materials(tenant_id);
create index source_materials_workspace_id_idx on public.source_materials(workspace_id);
create index source_materials_company_id_idx on public.source_materials(company_id);
create index source_materials_type_idx on public.source_materials(type);
create index source_materials_status_idx on public.source_materials(status);
create index source_materials_created_at_idx on public.source_materials(created_at);

create index bot_question_logs_tenant_id_idx on public.bot_question_logs(tenant_id);
create index bot_question_logs_workspace_id_idx on public.bot_question_logs(workspace_id);
create index bot_question_logs_company_id_idx on public.bot_question_logs(company_id);
create index bot_question_logs_review_status_idx on public.bot_question_logs(review_status);
create index bot_question_logs_risk_level_idx on public.bot_question_logs(risk_level);
create index bot_question_logs_created_at_idx on public.bot_question_logs(created_at);

create index review_logs_tenant_id_idx on public.review_logs(tenant_id);
create index review_logs_workspace_id_idx on public.review_logs(workspace_id);
create index review_logs_company_id_idx on public.review_logs(company_id);
create index review_logs_decision_idx on public.review_logs(decision);
create index review_logs_target_idx on public.review_logs(target_table, target_id);
create index review_logs_created_at_idx on public.review_logs(created_at);

create index action_records_tenant_id_idx on public.action_records(tenant_id);
create index action_records_workspace_id_idx on public.action_records(workspace_id);
create index action_records_company_id_idx on public.action_records(company_id);
create index action_records_status_idx on public.action_records(status);
create index action_records_action_type_idx on public.action_records(action_type);
create index action_records_created_at_idx on public.action_records(created_at);
create index action_records_completed_at_idx on public.action_records(completed_at);

create index companion_check_ins_tenant_id_idx on public.companion_check_ins(tenant_id);
create index companion_check_ins_workspace_id_idx on public.companion_check_ins(workspace_id);
create index companion_check_ins_company_id_idx on public.companion_check_ins(company_id);
create index companion_check_ins_status_idx on public.companion_check_ins(status);
create index companion_check_ins_period_idx on public.companion_check_ins(period_start, period_end);
create index companion_check_ins_created_at_idx on public.companion_check_ins(created_at);

create index business_goals_tenant_id_idx on public.business_goals(tenant_id);
create index business_goals_workspace_id_idx on public.business_goals(workspace_id);
create index business_goals_company_id_idx on public.business_goals(company_id);
create index business_goals_status_idx on public.business_goals(status);
create index business_goals_priority_idx on public.business_goals(priority);
create index business_goals_created_at_idx on public.business_goals(created_at);

create index marketing_actions_tenant_id_idx on public.marketing_actions(tenant_id);
create index marketing_actions_workspace_id_idx on public.marketing_actions(workspace_id);
create index marketing_actions_company_id_idx on public.marketing_actions(company_id);
create index marketing_actions_status_idx on public.marketing_actions(status);
create index marketing_actions_priority_idx on public.marketing_actions(priority);
create index marketing_actions_created_at_idx on public.marketing_actions(created_at);

create index audit_items_tenant_id_idx on public.audit_items(tenant_id);
create index audit_items_workspace_id_idx on public.audit_items(workspace_id);
create index audit_items_company_id_idx on public.audit_items(company_id);
create index audit_items_status_idx on public.audit_items(status);
create index audit_items_priority_idx on public.audit_items(priority);
create index audit_items_area_idx on public.audit_items(area);
create index audit_items_created_at_idx on public.audit_items(created_at);

create index intake_sessions_tenant_id_idx on public.intake_sessions(tenant_id);
create index intake_sessions_workspace_id_idx on public.intake_sessions(workspace_id);
create index intake_sessions_company_id_idx on public.intake_sessions(company_id);
create index intake_sessions_status_idx on public.intake_sessions(status);
create index intake_sessions_created_at_idx on public.intake_sessions(created_at);

create index import_logs_tenant_id_idx on public.import_logs(tenant_id);
create index import_logs_workspace_id_idx on public.import_logs(workspace_id);
create index import_logs_status_idx on public.import_logs(status);
create index import_logs_created_at_idx on public.import_logs(created_at);

create index change_log_tenant_id_idx on public.change_log(tenant_id);
create index change_log_workspace_id_idx on public.change_log(workspace_id);
create index change_log_entity_idx on public.change_log(entity_table, entity_id);
create index change_log_created_at_idx on public.change_log(created_at);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.tenants enable row level security;
alter table public.user_profiles enable row level security;
alter table public.tenant_members enable row level security;
alter table public.workspaces enable row level security;
alter table public.companies enable row level security;
alter table public.products enable row level security;
alter table public.knowledge_entries enable row level security;
alter table public.source_materials enable row level security;
alter table public.bot_question_logs enable row level security;
alter table public.review_logs enable row level security;
alter table public.action_records enable row level security;
alter table public.companion_check_ins enable row level security;
alter table public.business_goals enable row level security;
alter table public.marketing_actions enable row level security;
alter table public.audit_items enable row level security;
alter table public.intake_sessions enable row level security;
alter table public.import_logs enable row level security;
alter table public.change_log enable row level security;

create policy tenants_read_by_members
  on public.tenants for select
  using (public.has_tenant_role(id, array['owner', 'admin', 'editor', 'reviewer', 'viewer']));

create policy tenants_update_by_owner_admin
  on public.tenants for update
  using (public.has_tenant_role(id, array['owner', 'admin']))
  with check (public.has_tenant_role(id, array['owner', 'admin']));

create policy tenants_delete_by_owner
  on public.tenants for delete
  using (public.has_tenant_role(id, array['owner']));

create policy user_profiles_read_own
  on public.user_profiles for select
  using (id = auth.uid());

create policy user_profiles_insert_own
  on public.user_profiles for insert
  with check (id = auth.uid());

create policy user_profiles_update_own
  on public.user_profiles for update
  using (id = auth.uid())
  with check (id = auth.uid());

create policy tenant_members_read_by_members
  on public.tenant_members for select
  using (public.has_tenant_role(tenant_id, array['owner', 'admin', 'editor', 'reviewer', 'viewer']));

create policy tenant_members_insert_by_owner_admin
  on public.tenant_members for insert
  with check (public.has_tenant_role(tenant_id, array['owner', 'admin']));

create policy tenant_members_update_by_owner_admin
  on public.tenant_members for update
  using (public.has_tenant_role(tenant_id, array['owner', 'admin']))
  with check (public.has_tenant_role(tenant_id, array['owner', 'admin']));

create policy tenant_members_delete_by_owner_admin
  on public.tenant_members for delete
  using (public.has_tenant_role(tenant_id, array['owner', 'admin']));

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'workspaces',
    'companies',
    'products',
    'knowledge_entries',
    'source_materials',
    'action_records',
    'companion_check_ins',
    'business_goals',
    'marketing_actions',
    'audit_items',
    'intake_sessions',
    'import_logs',
    'change_log'
  ]
  loop
    execute format(
      'create policy %I on public.%I for select using (public.has_tenant_role(tenant_id, array[''owner'', ''admin'', ''editor'', ''reviewer'', ''viewer'']))',
      table_name || '_read_by_members',
      table_name
    );

    execute format(
      'create policy %I on public.%I for insert with check (public.has_tenant_role(tenant_id, array[''owner'', ''admin'', ''editor'']))',
      table_name || '_insert_by_owner_admin_editor',
      table_name
    );

    execute format(
      'create policy %I on public.%I for update using (public.has_tenant_role(tenant_id, array[''owner'', ''admin'', ''editor''])) with check (public.has_tenant_role(tenant_id, array[''owner'', ''admin'', ''editor'']))',
      table_name || '_update_by_owner_admin_editor',
      table_name
    );

    execute format(
      'create policy %I on public.%I for delete using (public.has_tenant_role(tenant_id, array[''owner'', ''admin'']))',
      table_name || '_delete_by_owner_admin',
      table_name
    );
  end loop;
end;
$$;

do $$
declare
  table_name text;
begin
  foreach table_name in array array['bot_question_logs', 'review_logs']
  loop
    execute format(
      'create policy %I on public.%I for select using (public.has_tenant_role(tenant_id, array[''owner'', ''admin'', ''editor'', ''reviewer'', ''viewer'']))',
      table_name || '_read_by_members',
      table_name
    );

    execute format(
      'create policy %I on public.%I for insert with check (public.has_tenant_role(tenant_id, array[''owner'', ''admin'', ''editor'', ''reviewer'']))',
      table_name || '_insert_by_review_roles',
      table_name
    );

    execute format(
      'create policy %I on public.%I for update using (public.has_tenant_role(tenant_id, array[''owner'', ''admin'', ''editor'', ''reviewer''])) with check (public.has_tenant_role(tenant_id, array[''owner'', ''admin'', ''editor'', ''reviewer'']))',
      table_name || '_update_by_review_roles',
      table_name
    );

    execute format(
      'create policy %I on public.%I for delete using (public.has_tenant_role(tenant_id, array[''owner'', ''admin'']))',
      table_name || '_delete_by_owner_admin',
      table_name
    );
  end loop;
end;
$$;
