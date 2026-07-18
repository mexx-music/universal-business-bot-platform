begin;

create extension if not exists pgtap with schema extensions;

set local search_path = public, extensions;

select plan(19);

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
    '90000000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'crud-viewer@example.test',
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
    '90000000-0000-4000-8000-000000000002',
    'authenticated',
    'authenticated',
    'crud-disabled@example.test',
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
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '90000000-0000-4000-8000-000000000003',
    'authenticated',
    'authenticated',
    'crud-none@example.test',
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
    '+190000000003',
    '',
    '',
    '',
    false,
    false,
    false
  );

insert into public.tenants (id, name) values
  ('90000000-0000-4000-8000-000000000101', 'CRUD foreign tenant');

insert into public.tenant_members (tenant_id, user_id, role, status) values
  ('00000000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000001', 'viewer', 'active'),
  ('00000000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000002', 'editor', 'disabled');

insert into public.workspaces (id, tenant_id, name) values
  ('90000000-0000-4000-8000-000000000201', '90000000-0000-4000-8000-000000000101', 'CRUD foreign workspace');

insert into public.companies (
  workspace_id,
  tenant_id,
  id,
  company_name
) values (
  '90000000-0000-4000-8000-000000000201',
  '90000000-0000-4000-8000-000000000101',
  'foreign-company',
  'Foreign Company'
);

select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000010', true);
set local role authenticated;

select ok(
  public.can_write_tenant('00000000-0000-4000-8000-000000000001'),
  'owner can_write_tenant for own tenant'
);

select lives_ok(
  $$
    insert into public.knowledge_entries (
      workspace_id,
      tenant_id,
      company_id,
      id,
      title,
      content
    ) values (
      '00000000-0000-4000-8000-000000000101',
      '00000000-0000-4000-8000-000000000001',
      'hb-cure',
      'crud-owner-knowledge',
      'Owner CRUD knowledge',
      'Owner can create knowledge.'
    )
  $$,
  'owner can create knowledge in own tenant'
);

select lives_ok(
  $$
    update public.knowledge_entries
    set title = 'Owner CRUD knowledge updated'
    where workspace_id = '00000000-0000-4000-8000-000000000101'
      and id = 'crud-owner-knowledge'
  $$,
  'owner can update knowledge in own tenant'
);

select is(
  (
    select title
    from public.knowledge_entries
    where workspace_id = '00000000-0000-4000-8000-000000000101'
      and id = 'crud-owner-knowledge'
  ),
  'Owner CRUD knowledge updated',
  'owner update is visible'
);

select lives_ok(
  $$
    update public.source_materials
    set status = 'reviewed'
    where workspace_id = '00000000-0000-4000-8000-000000000101'
      and id = 'hb-source-faq'
  $$,
  'owner can update source material status'
);

select lives_ok(
  $$
    update public.bot_question_logs
    set review_status = 'reviewed', reviewed_at = now()
    where workspace_id = '00000000-0000-4000-8000-000000000101'
      and id = 'hb-log-red'
  $$,
  'owner can update bot question review status'
);

select lives_ok(
  $$
    update public.audit_items
    set status = 'partial', note = 'Checked by CRUD test'
    where workspace_id = '00000000-0000-4000-8000-000000000101'
      and id = 'hb-audit-risk'
  $$,
  'owner can update audit item fields'
);

select ok(
  (
    select updated_at > created_at
    from public.audit_items
    where workspace_id = '00000000-0000-4000-8000-000000000101'
      and id = 'hb-audit-risk'
  ),
  'updated_at is maintained server-side'
);

select throws_ok(
  $$
    update public.audit_items
    set status = 'invalid'
    where workspace_id = '00000000-0000-4000-8000-000000000101'
      and id = 'hb-audit-risk'
  $$,
  '23514',
  null,
  'invalid audit status is rejected'
);

select throws_ok(
  $$
    update public.knowledge_entries
    set tenant_id = '90000000-0000-4000-8000-000000000101'
    where workspace_id = '00000000-0000-4000-8000-000000000101'
      and id = 'crud-owner-knowledge'
  $$,
  '42501',
  null,
  'tenant_id cannot be moved to a foreign tenant'
);

select lives_ok(
  $$
    delete from public.knowledge_entries
    where workspace_id = '00000000-0000-4000-8000-000000000101'
      and id = 'crud-owner-knowledge'
  $$,
  'owner can delete own knowledge entry'
);

select is(
  (
    select count(*)
    from public.knowledge_entries
    where id = 'crud-owner-knowledge'
  ),
  0::bigint,
  'deleted knowledge entry is gone'
);

reset role;

select set_config('request.jwt.claim.sub', '90000000-0000-4000-8000-000000000001', true);
set local role authenticated;

select ok(
  not public.can_write_tenant('00000000-0000-4000-8000-000000000001'),
  'viewer cannot write tenant'
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
      '00000000-0000-4000-8000-000000000101',
      '00000000-0000-4000-8000-000000000001',
      'hb-cure',
      'crud-viewer-knowledge',
      'Viewer knowledge',
      'Viewer must not create.'
    )
  $$,
  '42501',
  null,
  'viewer cannot create knowledge'
);

select lives_ok(
  $$
    update public.audit_items
    set note = 'viewer changed'
    where workspace_id = '00000000-0000-4000-8000-000000000101'
      and id = 'hb-audit-risk'
  $$,
  'viewer update statement is filtered by RLS'
);

select isnt(
  (
    select note
    from public.audit_items
    where workspace_id = '00000000-0000-4000-8000-000000000101'
      and id = 'hb-audit-risk'
  ),
  'viewer changed',
  'viewer cannot change audit item'
);

reset role;

select set_config('request.jwt.claim.sub', '90000000-0000-4000-8000-000000000002', true);
set local role authenticated;

select results_eq(
  $$
    with updated as (
      update public.source_materials
      set status = 'ignored'
      where workspace_id = '00000000-0000-4000-8000-000000000101'
        and id = 'hb-source-faq'
      returning 1
    )
    select count(*)::bigint from updated
  $$,
  $$ values (0::bigint) $$,
  'inactive membership cannot update rows'
);

reset role;

select set_config('request.jwt.claim.sub', '90000000-0000-4000-8000-000000000003', true);
set local role authenticated;

select throws_ok(
  $$
    insert into public.source_materials (
      workspace_id,
      tenant_id,
      company_id,
      id,
      title
    ) values (
      '00000000-0000-4000-8000-000000000101',
      '00000000-0000-4000-8000-000000000001',
      'hb-cure',
      'crud-no-member-source',
      'No member source'
    )
  $$,
  '42501',
  null,
  'user without membership cannot write'
);

reset role;

set local role anon;

select throws_ok(
  $$
    insert into public.source_materials (
      workspace_id,
      tenant_id,
      company_id,
      id,
      title
    ) values (
      '00000000-0000-4000-8000-000000000101',
      '00000000-0000-4000-8000-000000000001',
      'hb-cure',
      'crud-anon-source',
      'Anonymous source'
    )
  $$,
  '42501',
  null,
  'anonymous user cannot write'
);

select * from finish();

rollback;
