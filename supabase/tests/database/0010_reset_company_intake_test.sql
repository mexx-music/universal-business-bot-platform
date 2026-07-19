begin;

create extension if not exists pgtap with schema extensions;

set local search_path = public, extensions;

select plan(7);

select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000010', true);
set local role authenticated;

create temp table _reset_invitation as
select public.create_intake_invitation(
  '00000000-0000-4000-8000-000000000101',
  'hb-cure',
  'Hallo Klaus.'
) as response;

reset role;
set local role anon;

create temp table _opened_before_reset as
select public.public_open_intake_invitation(
  (select response->>'token' from _reset_invitation)
) as response;

create temp table _saved_before_reset as
select public.public_save_intake_session(
  (select response->>'token' from _reset_invitation),
  jsonb_build_object(
    'id', (select response->'intakeSession'->>'id' from _opened_before_reset),
    'status', 'completed',
    'currentStepIndex', 7,
    'chatCurrentQuestionIndex', 99,
    'chatCompletedAt', now(),
    'basics', jsonb_build_object('companyName', 'Answered Company')
  )
) as response;

reset role;
select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000000010', true);
set local role authenticated;

create temp table _reset_result as
select public.reset_company_intake(
  '00000000-0000-4000-8000-000000000101',
  'hb-cure'
) as response;

select is(
  (select response->>'status' from _reset_result),
  'reset',
  'internal writer can reset company intake'
);

select is(
  (select response->'intakeSession'->>'status' from _reset_result),
  'draft',
  'reset intake session is draft'
);

select is(
  (select response->'intakeSession'->>'chatCurrentQuestionIndex' from _reset_result),
  '0',
  'reset intake starts at the first question index'
);

select is(
  coalesce((select response->'intakeSession'->'basics'->>'companyName' from _reset_result), ''),
  '',
  'reset clears previous intake answers'
);

select is(
  (select response->'invitation'->>'status' from _reset_result),
  'invited',
  'reset keeps the invitation but clears completion status'
);

reset role;
set local role anon;

select is(
  public.public_open_intake_invitation(
    (select response->>'token' from _reset_invitation)
  )->'intakeSession'->>'status',
  'draft',
  'same public token opens the reset draft intake'
);

select throws_ok(
  $$
    select public.reset_company_intake(
      '00000000-0000-4000-8000-000000000101',
      'hb-cure'
    )
  $$,
  '42501',
  null,
  'anonymous public users cannot reset intake'
);

select * from finish();

rollback;
