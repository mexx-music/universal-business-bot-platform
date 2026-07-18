begin;

create extension if not exists pgtap with schema extensions;

set local search_path = public, extensions;

select plan(8);

select has_function(
  'public',
  'handle_new_auth_user',
  array[]::name[],
  'auth profile trigger function exists'
);

select has_function(
  'public',
  'active_tenant_memberships',
  array[]::name[],
  'active tenant membership resolver exists'
);

select ok(
  exists (
    select 1
    from pg_trigger
    where tgname = 'on_auth_user_created'
      and tgrelid = 'auth.users'::regclass
  ),
  'auth.users insert trigger exists'
);

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
) values (
  '00000000-0000-0000-0000-000000000000',
  '40000000-0000-4000-8000-000000000001',
  'authenticated',
  'authenticated',
  'new-user@example.test',
  extensions.crypt('password', extensions.gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"]}'::jsonb,
  '{"display_name": "New User"}'::jsonb,
  '',
  '',
  '',
  '',
  '',
  '+140000000001',
  '',
  '',
  '',
  false,
  false,
  false
);

select is(
  (select display_name from public.user_profiles where id = '40000000-0000-4000-8000-000000000001'),
  'New User',
  'new auth user gets profile'
);

select set_config('request.jwt.claim.sub', '40000000-0000-4000-8000-000000000001', true);
set local role authenticated;

select is(
  (select count(*) from public.active_tenant_memberships()),
  0::bigint,
  'user without tenant has no active memberships'
);

select is(
  (select count(*) from public.workspaces),
  0::bigint,
  'user without tenant cannot see workspaces'
);

reset role;

select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000010', true);
set local role authenticated;

select is(
  (select role from public.active_tenant_memberships() limit 1),
  'owner',
  'demo user resolves owner role'
);

select is(
  (select count(*) from public.workspaces),
  2::bigint,
  'demo user sees seeded tenant workspaces'
);

reset role;

select * from finish();

rollback;
