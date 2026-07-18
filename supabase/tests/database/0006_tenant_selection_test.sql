begin;

create extension if not exists pgtap with schema extensions;

set local search_path = public, extensions;

select plan(14);

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
  confirmation_token,
  recovery_token,
  email_change_token_current,
  email_change_token_new,
  email_change,
  phone,
  phone_change,
  phone_change_token,
  reauthentication_token,
  is_super_admin,
  is_sso_user,
  is_anonymous
) values
  (
    '00000000-0000-0000-0000-000000000000',
    'f0000000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'tenant-selector@example.test',
    extensions.crypt('password', extensions.gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{}'::jsonb,
    '',
    '',
    '',
    '',
    '',
    '+190000000001',
    '',
    '',
    '',
    false,
    false,
    false
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    'f0000000-0000-4000-8000-000000000002',
    'authenticated',
    'authenticated',
    'tenant-other@example.test',
    extensions.crypt('password', extensions.gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{}'::jsonb,
    '',
    '',
    '',
    '',
    '',
    '+190000000002',
    '',
    '',
    '',
    false,
    false,
    false
  );

insert into public.tenants (id, name, status, created_by, updated_by) values
  (
    'f0000000-0000-4000-8000-000000000101',
    'Tenant Alpha',
    'active',
    'f0000000-0000-4000-8000-000000000001',
    'f0000000-0000-4000-8000-000000000001'
  ),
  (
    'f0000000-0000-4000-8000-000000000102',
    'Tenant Beta',
    'active',
    'f0000000-0000-4000-8000-000000000001',
    'f0000000-0000-4000-8000-000000000001'
  ),
  (
    'f0000000-0000-4000-8000-000000000103',
    'Tenant Disabled Membership',
    'active',
    'f0000000-0000-4000-8000-000000000001',
    'f0000000-0000-4000-8000-000000000001'
  ),
  (
    'f0000000-0000-4000-8000-000000000104',
    'Tenant Suspended',
    'suspended',
    'f0000000-0000-4000-8000-000000000001',
    'f0000000-0000-4000-8000-000000000001'
  ),
  (
    'f0000000-0000-4000-8000-000000000105',
    'Tenant Foreign',
    'active',
    'f0000000-0000-4000-8000-000000000002',
    'f0000000-0000-4000-8000-000000000002'
  );

insert into public.tenant_members (tenant_id, user_id, role, status) values
  (
    'f0000000-0000-4000-8000-000000000101',
    'f0000000-0000-4000-8000-000000000001',
    'owner',
    'active'
  ),
  (
    'f0000000-0000-4000-8000-000000000102',
    'f0000000-0000-4000-8000-000000000001',
    'viewer',
    'active'
  ),
  (
    'f0000000-0000-4000-8000-000000000103',
    'f0000000-0000-4000-8000-000000000001',
    'admin',
    'disabled'
  ),
  (
    'f0000000-0000-4000-8000-000000000104',
    'f0000000-0000-4000-8000-000000000001',
    'admin',
    'active'
  ),
  (
    'f0000000-0000-4000-8000-000000000105',
    'f0000000-0000-4000-8000-000000000002',
    'owner',
    'active'
  );

insert into public.workspaces (id, tenant_id, name) values
  (
    'f0000000-0000-4000-8000-000000000201',
    'f0000000-0000-4000-8000-000000000101',
    'Alpha Main'
  ),
  (
    'f0000000-0000-4000-8000-000000000202',
    'f0000000-0000-4000-8000-000000000101',
    'Alpha Second'
  ),
  (
    'f0000000-0000-4000-8000-000000000203',
    'f0000000-0000-4000-8000-000000000102',
    'Beta Main'
  );

insert into public.companies (
  workspace_id,
  tenant_id,
  id,
  company_name,
  primary_language
) values
  (
    'f0000000-0000-4000-8000-000000000201',
    'f0000000-0000-4000-8000-000000000101',
    'alpha',
    'Tenant Alpha',
    'de'
  ),
  (
    'f0000000-0000-4000-8000-000000000203',
    'f0000000-0000-4000-8000-000000000102',
    'beta',
    'Tenant Beta',
    'de'
  );

select set_config('request.jwt.claim.sub', 'f0000000-0000-4000-8000-000000000001', true);
set local role authenticated;

select is(
  (select count(*) from public.active_tenant_memberships()),
  2::bigint,
  'user sees all own active memberships only'
);

select is(
  (select count(*) from public.active_tenant_memberships() where tenant_name = 'Tenant Foreign'),
  0::bigint,
  'foreign membership is not returned'
);

select is(
  (select count(*) from public.active_tenant_memberships() where tenant_name like '%Disabled%'),
  0::bigint,
  'inactive membership is not returned'
);

select is(
  (select count(*) from public.active_tenant_memberships() where tenant_name like '%Suspended%'),
  0::bigint,
  'suspended tenant is not returned'
);

select is(
  (select role from public.active_tenant_memberships() where tenant_name = 'Tenant Alpha'),
  'owner',
  'owner role is returned for tenant A'
);

select is(
  (select role from public.active_tenant_memberships() where tenant_name = 'Tenant Beta'),
  'viewer',
  'viewer role is returned for tenant B'
);

select is(
  (select workspace_count from public.active_tenant_memberships() where tenant_name = 'Tenant Alpha'),
  2,
  'workspace count is returned'
);

select is(
  (select primary_workspace_name from public.active_tenant_memberships() where tenant_name = 'Tenant Alpha'),
  'Alpha Main',
  'primary workspace metadata is returned'
);

select ok(
  public.can_write_tenant('f0000000-0000-4000-8000-000000000101'),
  'owner can write tenant A'
);

select ok(
  not public.can_write_tenant('f0000000-0000-4000-8000-000000000102'),
  'viewer cannot write tenant B'
);

select is(
  (select count(*) from public.workspaces where tenant_id = 'f0000000-0000-4000-8000-000000000105'),
  0::bigint,
  'tenant A/B user cannot read foreign workspace'
);

select throws_ok(
  $$
    insert into public.knowledge_entries (
      workspace_id,
      tenant_id,
      company_id,
      id,
      title,
      content
    ) values (
      'f0000000-0000-4000-8000-000000000203',
      'f0000000-0000-4000-8000-000000000102',
      'beta',
      'blocked',
      'Blocked',
      'Viewer cannot write this.'
    )
  $$,
  'new row violates row-level security policy for table "knowledge_entries"',
  'viewer cannot write to tenant B'
);

reset role;

select set_config('request.jwt.claim.sub', 'f0000000-0000-4000-8000-000000000002', true);
set local role authenticated;

select is(
  (select count(*) from public.active_tenant_memberships()),
  1::bigint,
  'other user sees only own membership'
);

reset role;
set local role anon;

select throws_ok(
  $$ select count(*) from public.active_tenant_memberships() $$,
  'permission denied for function active_tenant_memberships',
  'anonymous users cannot execute membership resolver'
);

reset role;

select * from finish();

rollback;
