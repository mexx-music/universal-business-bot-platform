begin;

create extension if not exists pgtap with schema extensions;

set local search_path = public, extensions;

select plan(22);

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
    'a0000000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'onboarding-user@example.test',
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
    '+180000000001',
    '',
    '',
    '',
    false,
    false,
    false
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    'a0000000-0000-4000-8000-000000000002',
    'authenticated',
    'authenticated',
    'onboarding-other@example.test',
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
    '+180000000002',
    '',
    '',
    '',
    false,
    false,
    false
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    'a0000000-0000-4000-8000-000000000003',
    'authenticated',
    'authenticated',
    'onboarding-invalid@example.test',
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
    '+180000000003',
    '',
    '',
    '',
    false,
    false,
    false
  );

select set_config('request.jwt.claim.sub', 'a0000000-0000-4000-8000-000000000001', true);
set local role authenticated;

create temporary table onboarding_result as
select *
from public.create_initial_tenant_workspace(
  'Neue Firma GmbH',
  'www.neue-firma.test',
  'Beratung',
  'Begleitung fuer kleinere Unternehmen.',
  'en',
  null
);

select is((select count(*) from onboarding_result), 1::bigint, 'authenticated user without membership can run onboarding');

select is(
  (
    select count(*)
    from public.tenants t
    join onboarding_result r on r.tenant_id = t.id
  ),
  1::bigint,
  'tenant is created'
);

select is(
  (
    select tm.role
    from public.tenant_members tm
    join onboarding_result r on r.tenant_id = tm.tenant_id
    where tm.user_id = 'a0000000-0000-4000-8000-000000000001'
  ),
  'owner',
  'owner membership is created for current user'
);

select is(
  (
    select tm.status
    from public.tenant_members tm
    join onboarding_result r on r.tenant_id = tm.tenant_id
    where tm.user_id = 'a0000000-0000-4000-8000-000000000001'
  ),
  'active',
  'membership is active'
);

select is(
  (
    select count(*)
    from public.workspaces w
    join onboarding_result r on r.workspace_id = w.id
    where w.tenant_id = r.tenant_id
  ),
  1::bigint,
  'workspace is created in same tenant'
);

select is(
  (
    select c.company_name
    from public.companies c
    join onboarding_result r on r.workspace_id = c.workspace_id
  ),
  'Neue Firma GmbH',
  'company is created'
);

select is(
  (
    select c.primary_language
    from public.companies c
    join onboarding_result r on r.workspace_id = c.workspace_id
  ),
  'en',
  'company language is stored'
);

select is(
  (
    select c.website
    from public.companies c
    join onboarding_result r on r.workspace_id = c.workspace_id
  ),
  'https://www.neue-firma.test',
  'website is normalized to https'
);

select is(
  (
    select c.bot_configuration->>'status'
    from public.companies c
    join onboarding_result r on r.workspace_id = c.workspace_id
  ),
  'draft',
  'bot configuration is created conservatively'
);

select is(
  (
    select count(*)
    from public.products p
    join onboarding_result r on r.workspace_id = p.workspace_id
  ),
  0::bigint,
  'no demo products are copied'
);

select is(
  (
    select count(*)
    from public.knowledge_entries k
    join onboarding_result r on r.workspace_id = k.workspace_id
  ),
  0::bigint,
  'no demo knowledge is copied'
);

select ok(
  public.can_read_tenant((select tenant_id from onboarding_result)),
  'new owner can read the new tenant'
);

select throws_ok(
  $$ select * from public.create_initial_tenant_workspace('Noch eine Firma') $$,
  '23505',
  null,
  'second onboarding call is rejected'
);

select is(
  (
    select count(*)
    from public.tenant_members
    where user_id = 'a0000000-0000-4000-8000-000000000001'
      and status = 'active'
  ),
  1::bigint,
  'duplicate call does not create a second tenant'
);

reset role;

select set_config('request.jwt.claim.sub', 'a0000000-0000-4000-8000-000000000002', true);
set local role authenticated;

select is(
  (
    select count(*)
    from public.tenants
    where id = (select tenant_id from onboarding_result)
  ),
  0::bigint,
  'other user cannot read created tenant'
);

select set_config('request.jwt.claim.sub', 'a0000000-0000-4000-8000-000000000003', true);

select throws_ok(
  $$ select * from public.create_initial_tenant_workspace('!') $$,
  '22023',
  null,
  'invalid company name is rejected'
);

select throws_ok(
  $$ select * from public.create_initial_tenant_workspace('Valid Name', null, null, null, 'fr') $$,
  '22023',
  null,
  'invalid language is rejected'
);

select throws_ok(
  $$ select * from public.create_initial_tenant_workspace('Valid Name', 'javascript:alert(1)') $$,
  '22023',
  null,
  'unsafe website is rejected'
);

select is(
  (
    select count(*)
    from public.tenant_members
    where user_id = 'a0000000-0000-4000-8000-000000000003'
  ),
  0::bigint,
  'failed validation leaves no membership behind'
);

reset role;

set local role anon;

select throws_ok(
  $$ select * from public.create_initial_tenant_workspace('Anonymous Company') $$,
  '42501',
  null,
  'anonymous user cannot execute onboarding RPC'
);

reset role;

select set_config('request.jwt.claim.sub', 'a0000000-0000-4000-8000-000000000001', true);
set local role authenticated;

select is(
  (
    select tm.user_id
    from public.tenant_members tm
    join onboarding_result r on r.tenant_id = tm.tenant_id
  ),
  'a0000000-0000-4000-8000-000000000001'::uuid,
  'membership user cannot be manipulated by client input'
);

select is(
  (
    select tm.role
    from public.tenant_members tm
    join onboarding_result r on r.tenant_id = tm.tenant_id
  ),
  'owner',
  'membership role is fixed server-side'
);

select * from finish();

rollback;
