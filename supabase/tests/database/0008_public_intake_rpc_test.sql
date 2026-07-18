begin;

create extension if not exists pgtap with schema extensions;

set local search_path = public, extensions;

select plan(8);

select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000010', true);
set local role authenticated;

create temp table _created_invitation as
select public.create_intake_invitation(
  '00000000-0000-4000-8000-000000000101',
  'hb-cure',
  'Hallo Klaus.'
) as response;

select ok(
  length((select response->>'token' from _created_invitation)) >= 64,
  'admin RPC returns a strong one-time token'
);

select is(
  (
    select count(*)
    from public.intake_invitations
    where token_hash = public.hash_intake_invitation_token(
      (select response->>'token' from _created_invitation)
    )
  ),
  1::bigint,
  'only the token hash is stored'
);

select is(
  (
    select count(*)
    from public.intake_invitations
    where token_hash = (select response->>'token' from _created_invitation)
  ),
  0::bigint,
  'clear token is not stored as token_hash'
);

reset role;
set local role anon;

create temp table _opened_invitation as
select public.public_open_intake_invitation(
  (select response->>'token' from _created_invitation)
) as response;

select is(
  (select response->>'status' from _opened_invitation),
  'opened',
  'anonymous public RPC opens a valid invitation'
);

create temp table _saved_intake as
select public.public_save_intake_session(
  (select response->>'token' from _created_invitation),
  jsonb_build_object(
    'id', (select response->'intakeSession'->>'id' from _opened_invitation),
    'companyId', 'foreign-company',
    'status', 'inProgress',
    'currentStepIndex', 2,
    'chatCurrentQuestionIndex', 2,
    'basics', jsonb_build_object('companyName', 'Klaus Remote')
  )
) as response;

select is(
  (select response->>'status' from _saved_intake),
  'opened',
  'anonymous public RPC saves intake progress'
);

reset role;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000010', true);
set local role authenticated;

select is(
  (
    select company_id
    from public.intake_sessions
    where workspace_id = '00000000-0000-4000-8000-000000000101'
    order by updated_at desc
    limit 1
  ),
  'hb-cure',
  'public save keeps the invitation company assignment'
);

create temp table _deactivated_invitation as
select public.deactivate_intake_invitation(
  '00000000-0000-4000-8000-000000000101',
  'hb-cure'
) as response;

reset role;
set local role anon;

select is(
  public.public_open_intake_invitation(
    (select response->>'token' from _created_invitation)
  )->>'status',
  'disabled',
  'disabled invitation is rejected for public open'
);

select is(
  public.public_open_intake_invitation('missing-token')->>'status',
  'not_found',
  'invalid token is rejected'
);

select * from finish();

rollback;
