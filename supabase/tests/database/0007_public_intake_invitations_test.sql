begin;

create extension if not exists pgtap with schema extensions;

set local search_path = public, extensions;

select plan(9);

select ok(
  to_regclass('public.intake_invitations') is not null,
  'intake_invitations table exists'
);

select ok(
  (
    select relrowsecurity
    from pg_class
    where oid = 'public.intake_invitations'::regclass
  ),
  'RLS is enabled for intake_invitations'
);

select ok(
  (
    select count(*) >= 4
    from pg_policies
    where schemaname = 'public'
      and tablename = 'intake_invitations'
  ),
  'intake_invitations policies exist'
);

select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000010', true);
set local role authenticated;

select lives_ok(
  $$
    insert into public.intake_invitations (
      workspace_id,
      tenant_id,
      company_id,
      id,
      token_hash,
      greeting
    ) values (
      '00000000-0000-4000-8000-000000000101',
      '00000000-0000-4000-8000-000000000001',
      'hb-cure',
      'invite-hb-klaus',
      'sha256-demo-token-hash',
      'Willkommen beim Firmenfragebogen für HB Cure.'
    )
  $$,
  'owner can create an intake invitation'
);

select lives_ok(
  $$
    update public.intake_invitations
    set status = 'partial', last_autosaved_at = now()
    where workspace_id = '00000000-0000-4000-8000-000000000101'
      and id = 'invite-hb-klaus'
  $$,
  'owner can update invitation progress'
);

select is(
  (
    select status
    from public.intake_invitations
    where workspace_id = '00000000-0000-4000-8000-000000000101'
      and id = 'invite-hb-klaus'
  ),
  'partial',
  'updated invitation status is visible'
);

select throws_ok(
  $$
    update public.intake_invitations
    set status = 'invalid'
    where workspace_id = '00000000-0000-4000-8000-000000000101'
      and id = 'invite-hb-klaus'
  $$,
  '23514',
  null,
  'invalid invitation status is rejected'
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
) values (
  '00000000-0000-0000-0000-000000000000',
  'a0000000-0000-4000-8000-000000000001',
  'authenticated',
  'authenticated',
  'intake-viewer@example.test',
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
  '+190000000007',
  '',
  '',
  '',
  false,
  false,
  false
);

insert into public.tenant_members (tenant_id, user_id, role, status) values
  (
    '00000000-0000-4000-8000-000000000001',
    'a0000000-0000-4000-8000-000000000001',
    'viewer',
    'active'
  );

select set_config('request.jwt.claim.sub', 'a0000000-0000-4000-8000-000000000001', true);
set local role authenticated;

select throws_ok(
  $$
    insert into public.intake_invitations (
      workspace_id,
      tenant_id,
      company_id,
      id,
      token_hash
    ) values (
      '00000000-0000-4000-8000-000000000101',
      '00000000-0000-4000-8000-000000000001',
      'hb-cure',
      'invite-viewer',
      'sha256-viewer-token-hash'
    )
  $$,
  '42501',
  null,
  'viewer cannot create intake invitations'
);

reset role;

set local role anon;

select throws_ok(
  $$
    select count(*) from public.intake_invitations
  $$,
  '42501',
  null,
  'anonymous users cannot read intake invitations directly'
);

select * from finish();

rollback;
