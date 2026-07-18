-- Block 22E: initial tenant/workspace onboarding.
--
-- This RPC is the only path for a newly authenticated user without an active
-- membership to create the first tenant. It creates the tenant, owner
-- membership, workspace, company and conservative bot configuration in one
-- database transaction.

create or replace function public.create_initial_tenant_workspace(
  company_name text,
  website text default null,
  industry text default null,
  short_description text default null,
  primary_language text default 'de',
  workspace_name text default null
)
returns table (
  tenant_id uuid,
  workspace_id uuid,
  company_id text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  acting_user uuid := auth.uid();
  clean_company_name text := btrim(coalesce(company_name, ''));
  clean_website text := btrim(coalesce(website, ''));
  clean_industry text := btrim(coalesce(industry, ''));
  clean_description text := btrim(coalesce(short_description, ''));
  clean_language text := lower(btrim(coalesce(primary_language, 'de')));
  clean_workspace_name text := btrim(coalesce(workspace_name, ''));
  generated_tenant_id uuid := gen_random_uuid();
  generated_workspace_id uuid := gen_random_uuid();
  generated_company_id text;
begin
  if acting_user is null then
    raise exception using
      errcode = '28000',
      message = 'authentication_required';
  end if;

  if exists (
    select 1
    from public.tenant_members tm
    where tm.user_id = acting_user
      and tm.status = 'active'
      and tm.deleted_at is null
  ) then
    raise exception using
      errcode = '23505',
      message = 'initial_onboarding_already_completed';
  end if;

  if length(clean_company_name) < 2
      or length(clean_company_name) > 120
      or clean_company_name !~ '[[:alnum:]]' then
    raise exception using
      errcode = '22023',
      message = 'invalid_company_name';
  end if;

  if length(clean_description) > 600 then
    raise exception using
      errcode = '22023',
      message = 'invalid_short_description';
  end if;

  if clean_language not in ('de', 'en') then
    raise exception using
      errcode = '22023',
      message = 'invalid_primary_language';
  end if;

  if clean_website <> '' then
    if clean_website !~* '^https?://' then
      clean_website := 'https://' || clean_website;
    end if;

    if clean_website !~* '^https://[a-z0-9][a-z0-9.-]*\.[a-z]{2,}([/:?#].*)?$' then
      raise exception using
        errcode = '22023',
        message = 'invalid_website';
    end if;
  end if;

  if clean_workspace_name = '' then
    clean_workspace_name := clean_company_name;
  end if;
  clean_workspace_name := left(clean_workspace_name, 120);

  generated_company_id := lower(regexp_replace(clean_company_name, '[^a-zA-Z0-9]+', '-', 'g'));
  generated_company_id := trim(both '-' from generated_company_id);
  if generated_company_id = '' then
    generated_company_id := 'company';
  end if;
  generated_company_id := left(generated_company_id, 80);

  insert into public.tenants (
    id,
    name,
    plan,
    status,
    created_by,
    updated_by
  ) values (
    generated_tenant_id,
    clean_company_name,
    'free',
    'active',
    acting_user,
    acting_user
  );

  insert into public.tenant_members (
    tenant_id,
    user_id,
    role,
    status,
    created_by,
    updated_by
  ) values (
    generated_tenant_id,
    acting_user,
    'owner',
    'active',
    acting_user,
    acting_user
  );

  insert into public.workspaces (
    id,
    tenant_id,
    name,
    created_by,
    updated_by
  ) values (
    generated_workspace_id,
    generated_tenant_id,
    clean_workspace_name,
    acting_user,
    acting_user
  );

  insert into public.companies (
    workspace_id,
    tenant_id,
    id,
    company_name,
    short_description,
    industry,
    country,
    primary_language,
    website,
    support_email,
    social_links,
    business_rules,
    bot_configuration,
    created_by,
    updated_by
  ) values (
    generated_workspace_id,
    generated_tenant_id,
    generated_company_id,
    clean_company_name,
    clean_description,
    clean_industry,
    '',
    clean_language,
    clean_website,
    '',
    case
      when clean_website = '' then '{}'::jsonb
      else jsonb_build_object('website', clean_website)
    end,
    jsonb_build_object(
      'brandVoice', '',
      'doNotSay', jsonb_build_array(),
      'noGoRules', jsonb_build_array(),
      'allowedSupportTopics', jsonb_build_array(),
      'escalationNotes', '',
      'disclaimerText', null
    ),
    jsonb_build_object(
      'status', 'draft',
      'answerStyle', 'balanced',
      'defaultLanguage', clean_language,
      'useDisclaimer', false,
      'disclaimerText', '',
      'alwaysEscalateRedFlags', true,
      'escalateNoMatch', true,
      'escalateYellowRisk', false,
      'allowedTopics', jsonb_build_array(),
      'blockedTopics', jsonb_build_array(),
      'handoverMessage', ''
    ),
    acting_user,
    acting_user
  );

  tenant_id := generated_tenant_id;
  workspace_id := generated_workspace_id;
  company_id := generated_company_id;
  return next;
end;
$$;

revoke all on function public.create_initial_tenant_workspace(
  text,
  text,
  text,
  text,
  text,
  text
) from public;

grant execute on function public.create_initial_tenant_workspace(
  text,
  text,
  text,
  text,
  text,
  text
) to authenticated;
