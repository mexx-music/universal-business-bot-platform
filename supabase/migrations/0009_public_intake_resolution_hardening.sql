-- Harden public intake invitation resolution diagnostics.
--
-- This keeps clear tokens server-only, switches newly generated tokens to
-- base64url form, and lets the public client distinguish expired links from
-- missing links without exposing token hashes or internal workspace data.

create or replace function public.create_intake_invitation(
  target_workspace_id uuid,
  target_company_id text,
  invitation_greeting text default ''
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  target_tenant_id uuid;
  clear_token text;
  invitation_row public.intake_invitations;
begin
  select w.tenant_id
    into target_tenant_id
  from public.workspaces w
  join public.companies c
    on c.workspace_id = w.id
   and c.id = target_company_id
   and c.deleted_at is null
  where w.id = target_workspace_id
    and w.deleted_at is null
  limit 1;

  if target_tenant_id is null or not public.can_write_tenant(target_tenant_id) then
    raise exception 'Not allowed to create an intake invitation.'
      using errcode = '42501';
  end if;

  update public.intake_invitations
     set status = 'disabled',
         disabled_at = coalesce(disabled_at, now())
   where workspace_id = target_workspace_id
     and company_id = target_company_id
     and deleted_at is null
     and status <> 'disabled';

  clear_token := rtrim(
    translate(encode(extensions.gen_random_bytes(32), 'base64'), '+/', '-_'),
    '='
  );

  insert into public.intake_invitations (
    workspace_id,
    tenant_id,
    company_id,
    id,
    token_hash,
    status,
    greeting
  ) values (
    target_workspace_id,
    target_tenant_id,
    target_company_id,
    'invite_' || replace(extensions.gen_random_uuid()::text, '-', ''),
    public.hash_intake_invitation_token(clear_token),
    'invited',
    coalesce(nullif(trim(invitation_greeting), ''), 'Welcome to the company questionnaire.')
  )
  returning * into invitation_row;

  return public.admin_intake_invitation_json(invitation_row, clear_token);
end;
$$;

revoke all on function public.create_intake_invitation(uuid, text, text) from public;
grant execute on function public.create_intake_invitation(uuid, text, text) to authenticated;

create or replace function public.public_open_intake_invitation(raw_token text)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  invitation_row public.intake_invitations;
  company_row public.companies;
  session_row public.intake_sessions;
  resolved_hash text;
begin
  if raw_token is null or length(trim(raw_token)) < 32 then
    return jsonb_build_object('status', 'not_found', 'reason', 'token_too_short');
  end if;

  resolved_hash := public.hash_intake_invitation_token(trim(raw_token));

  select *
    into invitation_row
  from public.intake_invitations
  where token_hash = resolved_hash
    and deleted_at is null
  limit 1;

  if invitation_row.id is null then
    return jsonb_build_object('status', 'not_found', 'reason', 'no_token_match');
  end if;

  if invitation_row.expires_at is not null and invitation_row.expires_at < now() then
    return jsonb_build_object('status', 'expired', 'reason', 'expired');
  end if;

  if invitation_row.status = 'disabled' then
    return jsonb_build_object('status', 'disabled', 'reason', 'disabled');
  end if;

  if invitation_row.status = 'invited' then
    update public.intake_invitations
       set status = 'started',
           started_at = coalesce(started_at, now())
     where workspace_id = invitation_row.workspace_id
       and id = invitation_row.id
    returning * into invitation_row;
  end if;

  select *
    into company_row
  from public.companies
  where workspace_id = invitation_row.workspace_id
    and id = invitation_row.company_id
    and deleted_at is null
  limit 1;

  if company_row.id is null then
    return jsonb_build_object('status', 'not_found', 'reason', 'company_missing');
  end if;

  select *
    into session_row
  from public.intake_sessions
  where workspace_id = invitation_row.workspace_id
    and company_id = invitation_row.company_id
    and deleted_at is null
  order by updated_at desc
  limit 1;

  if session_row.id is null then
    insert into public.intake_sessions (
      workspace_id,
      tenant_id,
      company_id,
      id,
      status,
      current_step,
      chat_started_at,
      chat_updated_at,
      basics
    ) values (
      invitation_row.workspace_id,
      invitation_row.tenant_id,
      invitation_row.company_id,
      'intake_' || invitation_row.id,
      'inProgress',
      0,
      now(),
      now(),
      jsonb_build_object(
        'companyName', company_row.company_name,
        'shortDescription', company_row.short_description,
        'industry', company_row.industry,
        'country', company_row.country,
        'primaryLanguage', company_row.primary_language,
        'website', company_row.website,
        'hasWebsite', nullif(company_row.website, '') is not null
      )
    )
    returning * into session_row;
  end if;

  return jsonb_build_object(
    'status', 'opened',
    'reason', 'opened',
    'company', jsonb_build_object(
      'id', company_row.id,
      'name', company_row.company_name,
      'shortDescription', company_row.short_description,
      'industry', company_row.industry,
      'country', company_row.country,
      'primaryLanguage', company_row.primary_language,
      'website', company_row.website
    ),
    'invitation', public.admin_intake_invitation_json(invitation_row, null),
    'intakeSession', public.public_intake_session_json(session_row)
  );
end;
$$;

revoke all on function public.public_open_intake_invitation(text) from public;
grant execute on function public.public_open_intake_invitation(text) to anon, authenticated;

create or replace function public.public_save_intake_session(
  raw_token text,
  session_payload jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  invitation_row public.intake_invitations;
  company_row public.companies;
  session_row public.intake_sessions;
  resolved_hash text;
  session_status text;
begin
  if raw_token is null or length(trim(raw_token)) < 32 then
    return jsonb_build_object('status', 'not_found', 'reason', 'token_too_short');
  end if;

  resolved_hash := public.hash_intake_invitation_token(trim(raw_token));

  select *
    into invitation_row
  from public.intake_invitations
  where token_hash = resolved_hash
    and deleted_at is null
  limit 1;

  if invitation_row.id is null then
    return jsonb_build_object('status', 'not_found', 'reason', 'no_token_match');
  end if;

  if invitation_row.expires_at is not null and invitation_row.expires_at < now() then
    return jsonb_build_object('status', 'expired', 'reason', 'expired');
  end if;

  if invitation_row.status = 'disabled' then
    return jsonb_build_object('status', 'disabled', 'reason', 'disabled');
  end if;

  select *
    into company_row
  from public.companies
  where workspace_id = invitation_row.workspace_id
    and id = invitation_row.company_id
    and deleted_at is null
  limit 1;

  if company_row.id is null then
    return jsonb_build_object('status', 'not_found', 'reason', 'company_missing');
  end if;

  session_status := coalesce(session_payload->>'status', 'inProgress');
  if session_status not in ('draft', 'inProgress', 'completed') then
    session_status := 'inProgress';
  end if;

  insert into public.intake_sessions (
    workspace_id,
    tenant_id,
    company_id,
    id,
    status,
    current_step,
    chat_started_at,
    chat_updated_at,
    chat_completed_at,
    chat_current_question_index,
    skipped_question_keys,
    deferred_question_keys,
    basics,
    products,
    target_groups,
    website_support,
    sources_reviews,
    marketing,
    goals_risks
  ) values (
    invitation_row.workspace_id,
    invitation_row.tenant_id,
    invitation_row.company_id,
    coalesce(nullif(session_payload->>'id', ''), 'intake_' || invitation_row.id),
    session_status,
    greatest(coalesce((session_payload->>'currentStepIndex')::integer, 0), 0),
    coalesce((session_payload->>'chatStartedAt')::timestamptz, now()),
    now(),
    case
      when session_status = 'completed'
      then coalesce((session_payload->>'chatCompletedAt')::timestamptz, now())
      else null
    end,
    greatest(coalesce((session_payload->>'chatCurrentQuestionIndex')::integer, 0), 0),
    case
      when jsonb_typeof(session_payload->'skippedQuestionKeys') = 'array'
      then session_payload->'skippedQuestionKeys'
      else '[]'::jsonb
    end,
    case
      when jsonb_typeof(session_payload->'deferredQuestionKeys') = 'array'
      then session_payload->'deferredQuestionKeys'
      else '[]'::jsonb
    end,
    coalesce(session_payload->'basics', '{}'::jsonb),
    coalesce(session_payload->'products', '{}'::jsonb),
    coalesce(session_payload->'targetGroups', '{}'::jsonb),
    coalesce(session_payload->'websiteAndSupport', '{}'::jsonb),
    coalesce(session_payload->'sourcesAndReviews', '{}'::jsonb),
    coalesce(session_payload->'marketingAndChannels', '{}'::jsonb),
    coalesce(session_payload->'goalsAndRisks', '{}'::jsonb)
  )
  on conflict (workspace_id, id) do update set
    status = excluded.status,
    current_step = excluded.current_step,
    chat_started_at = coalesce(public.intake_sessions.chat_started_at, excluded.chat_started_at),
    chat_updated_at = now(),
    chat_completed_at = excluded.chat_completed_at,
    chat_current_question_index = excluded.chat_current_question_index,
    skipped_question_keys = excluded.skipped_question_keys,
    deferred_question_keys = excluded.deferred_question_keys,
    basics = excluded.basics,
    products = excluded.products,
    target_groups = excluded.target_groups,
    website_support = excluded.website_support,
    sources_reviews = excluded.sources_reviews,
    marketing = excluded.marketing,
    goals_risks = excluded.goals_risks
  returning * into session_row;

  update public.intake_invitations
     set status = case
           when session_status = 'completed' then 'completed'
           when status in ('invited', 'started') then 'partial'
           else status
         end,
         started_at = coalesce(started_at, now()),
         completed_at = case
           when session_status = 'completed' then coalesce(completed_at, now())
           else completed_at
         end,
         last_autosaved_at = now()
   where workspace_id = invitation_row.workspace_id
     and id = invitation_row.id
  returning * into invitation_row;

  return jsonb_build_object(
    'status', 'opened',
    'reason', 'saved',
    'company', jsonb_build_object(
      'id', company_row.id,
      'name', company_row.company_name,
      'shortDescription', company_row.short_description,
      'industry', company_row.industry,
      'country', company_row.country,
      'primaryLanguage', company_row.primary_language,
      'website', company_row.website
    ),
    'invitation', public.admin_intake_invitation_json(invitation_row, null),
    'intakeSession', public.public_intake_session_json(session_row)
  );
end;
$$;

revoke all on function public.public_save_intake_session(text, jsonb) from public;
grant execute on function public.public_save_intake_session(text, jsonb) to anon, authenticated;
