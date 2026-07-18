begin;

create extension if not exists pgtap with schema extensions;

set local search_path = public, extensions;

select plan(9);

select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000010', true);
set local role authenticated;

select is(
  (select count(*) from public.workspaces),
  2::bigint,
  'seed demo user can read seeded workspaces'
);

select is(
  (select count(*) from public.products),
  4::bigint,
  'seed demo user can read seeded products'
);

select is(
  (select count(*) from public.knowledge_entries),
  3::bigint,
  'seed demo user can read seeded knowledge entries'
);

select is(
  (select count(*) from public.bot_question_logs),
  3::bigint,
  'seed demo user can read seeded bot question logs'
);

reset role;

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
    '50000000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'remote-a@example.test',
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
    '+150000000001',
    '',
    '',
    '',
    false,
    false,
    false
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '50000000-0000-4000-8000-000000000002',
    'authenticated',
    'authenticated',
    'remote-b@example.test',
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
    '+150000000002',
    '',
    '',
    '',
    false,
    false,
    false
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '50000000-0000-4000-8000-000000000003',
    'authenticated',
    'authenticated',
    'remote-none@example.test',
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
    '+150000000003',
    '',
    '',
    '',
    false,
    false,
    false
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '50000000-0000-4000-8000-000000000004',
    'authenticated',
    'authenticated',
    'remote-disabled@example.test',
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
    '+150000000004',
    '',
    '',
    '',
    false,
    false,
    false
  );

insert into public.tenants (id, name) values
  ('60000000-0000-4000-8000-000000000001', 'Remote Tenant A'),
  ('60000000-0000-4000-8000-000000000002', 'Remote Tenant B');

insert into public.tenant_members (tenant_id, user_id, role, status) values
  ('60000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000001', 'viewer', 'active'),
  ('60000000-0000-4000-8000-000000000002', '50000000-0000-4000-8000-000000000002', 'viewer', 'active'),
  ('60000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000004', 'viewer', 'disabled');

insert into public.workspaces (id, tenant_id, name) values
  ('70000000-0000-4000-8000-000000000001', '60000000-0000-4000-8000-000000000001', 'Tenant A Workspace'),
  ('70000000-0000-4000-8000-000000000002', '60000000-0000-4000-8000-000000000002', 'Tenant B Workspace');

select set_config('request.jwt.claim.sub', '50000000-0000-4000-8000-000000000001', true);
set local role authenticated;

select is(
  (select count(*) from public.workspaces),
  1::bigint,
  'tenant A member can read own tenant workspace'
);

select is(
  (select count(*) from public.workspaces where tenant_id = '60000000-0000-4000-8000-000000000002'),
  0::bigint,
  'tenant A member cannot read tenant B workspace'
);

reset role;

select set_config('request.jwt.claim.sub', '50000000-0000-4000-8000-000000000003', true);
set local role authenticated;

select is(
  (select count(*) from public.workspaces),
  0::bigint,
  'authenticated user without membership sees no tenant data'
);

reset role;

select set_config('request.jwt.claim.sub', '50000000-0000-4000-8000-000000000004', true);
set local role authenticated;

select is(
  (select count(*) from public.workspaces),
  0::bigint,
  'disabled membership grants no tenant access'
);

reset role;

set local role anon;

select throws_ok(
  $$ select count(*) from public.workspaces $$,
  '42501',
  'permission denied for table workspaces',
  'anonymous user cannot read protected workspace data'
);

reset role;

select * from finish();

rollback;
