begin;

create extension if not exists pgtap with schema extensions;

set local search_path = public, extensions;

select no_plan();

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

select has_table('public', 'tenants', 'tenants table exists');
select has_table('public', 'tenant_members', 'tenant_members table exists');
select has_table('public', 'user_profiles', 'user_profiles table exists');
select has_table('public', 'workspaces', 'workspaces table exists');
select has_table('public', 'companies', 'companies table exists');
select has_table('public', 'products', 'products table exists');
select has_table('public', 'knowledge_entries', 'knowledge_entries table exists');
select has_table('public', 'source_materials', 'source_materials table exists');
select has_table('public', 'bot_question_logs', 'bot_question_logs table exists');
select has_table('public', 'action_records', 'action_records table exists');
select has_table('public', 'companion_check_ins', 'companion_check_ins table exists');
select has_table('public', 'business_goals', 'business_goals table exists');
select has_table('public', 'marketing_actions', 'marketing_actions table exists');
select has_table('public', 'audit_items', 'audit_items table exists');
select has_table('public', 'intake_sessions', 'intake_sessions table exists');
select has_table('public', 'review_logs', 'review_logs table exists');
select has_table('public', 'import_logs', 'import_logs table exists');
select has_table('public', 'change_log', 'change_log table exists');

-- ---------------------------------------------------------------------------
-- Standard fields
-- ---------------------------------------------------------------------------

with required_tables(table_name) as (
  values
    ('tenants'),
    ('tenant_members'),
    ('user_profiles'),
    ('workspaces'),
    ('companies'),
    ('products'),
    ('knowledge_entries'),
    ('source_materials'),
    ('bot_question_logs'),
    ('action_records'),
    ('companion_check_ins'),
    ('business_goals'),
    ('marketing_actions'),
    ('audit_items'),
    ('intake_sessions'),
    ('review_logs')
),
required_columns(column_name) as (
  values ('created_at'), ('updated_at'), ('created_by'), ('updated_by')
)
select ok(
  not exists (
    select 1
    from required_tables rt
    cross join required_columns rc
    where not exists (
      select 1
      from information_schema.columns c
      where c.table_schema = 'public'
        and c.table_name = rt.table_name
        and c.column_name = rc.column_name
    )
  ),
  'all required domain tables include standard audit fields'
);

-- ---------------------------------------------------------------------------
-- Foreign keys
-- ---------------------------------------------------------------------------

select ok(
  exists (
    select 1
    from pg_constraint
    where conrelid = 'public.workspaces'::regclass
      and confrelid = 'public.tenants'::regclass
      and contype = 'f'
  ),
  'workspaces reference tenants'
);

select ok(
  exists (
    select 1
    from pg_constraint
    where conrelid = 'public.tenant_members'::regclass
      and confrelid = 'auth.users'::regclass
      and contype = 'f'
  ),
  'tenant_members reference auth.users'
);

select ok(
  exists (
    select 1
    from pg_constraint
    where conrelid = 'public.companies'::regclass
      and confrelid = 'public.workspaces'::regclass
      and contype = 'f'
  ),
  'companies reference workspaces'
);

select ok(
  exists (
    select 1
    from pg_constraint
    where conrelid = 'public.knowledge_entries'::regclass
      and confrelid = 'public.companies'::regclass
      and contype = 'f'
  ),
  'knowledge_entries reference companies'
);

select ok(
  exists (
    select 1
    from pg_constraint
    where conrelid = 'public.action_records'::regclass
      and confrelid = 'public.companies'::regclass
      and contype = 'f'
  ),
  'action_records reference companies'
);

select ok(
  exists (
    select 1
    from pg_constraint
    where conrelid = 'public.companion_check_ins'::regclass
      and confrelid = 'public.companies'::regclass
      and contype = 'f'
  ),
  'companion_check_ins reference companies'
);

-- ---------------------------------------------------------------------------
-- RLS and policies
-- ---------------------------------------------------------------------------

with required_tables(table_name) as (
  values
    ('tenants'),
    ('tenant_members'),
    ('user_profiles'),
    ('workspaces'),
    ('companies'),
    ('products'),
    ('knowledge_entries'),
    ('source_materials'),
    ('bot_question_logs'),
    ('action_records'),
    ('companion_check_ins'),
    ('business_goals'),
    ('marketing_actions'),
    ('audit_items'),
    ('intake_sessions'),
    ('review_logs'),
    ('import_logs'),
    ('change_log')
)
select ok(
  not exists (
    select 1
    from required_tables rt
    join pg_class c on c.relname = rt.table_name
    join pg_namespace n on n.oid = c.relnamespace and n.nspname = 'public'
    where c.relrowsecurity is not true
  ),
  'RLS is enabled on every public application table'
);

select ok(
  exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'knowledge_entries'
      and policyname = 'knowledge_entries_read_by_members'
  ),
  'knowledge_entries read policy exists'
);

select ok(
  exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'bot_question_logs'
      and policyname = 'bot_question_logs_update_by_review_roles'
  ),
  'reviewer write policy exists for bot_question_logs'
);

select ok(
  exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'tenant_members'
      and policyname = 'tenant_members_update_by_owner_admin'
  ),
  'owner/admin policy exists for tenant_members'
);

-- ---------------------------------------------------------------------------
-- Tenant isolation smoke test
-- ---------------------------------------------------------------------------

insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  is_sso_user,
  is_anonymous
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '10000000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'tenant-a@example.test',
    extensions.crypt('password', extensions.gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{}'::jsonb,
    false,
    false,
    false
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '10000000-0000-4000-8000-000000000002',
    'authenticated',
    'authenticated',
    'tenant-b@example.test',
    extensions.crypt('password', extensions.gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{}'::jsonb,
    false,
    false,
    false
  );

insert into public.tenants (id, name) values
  ('20000000-0000-4000-8000-000000000001', 'Tenant A'),
  ('20000000-0000-4000-8000-000000000002', 'Tenant B');

insert into public.tenant_members (tenant_id, user_id, role, status) values
  ('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'owner', 'active'),
  ('20000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000002', 'owner', 'active');

insert into public.workspaces (id, tenant_id, name) values
  ('30000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 'Workspace A'),
  ('30000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000002', 'Workspace B');

select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000001', true);
set local role authenticated;

select is(
  (select count(*) from public.workspaces),
  1::bigint,
  'authenticated user sees only own tenant workspaces'
);

select is(
  (select count(*) from public.workspaces where tenant_id = '20000000-0000-4000-8000-000000000002'),
  0::bigint,
  'authenticated user cannot see another tenant workspace'
);

reset role;

select * from finish();

rollback;
