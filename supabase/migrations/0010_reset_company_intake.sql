-- Reset one company's intake session without touching business data or links.
--
-- The public invitation token/hash remains unchanged. Internal writers can
-- clear all intake answers and progress for exactly one workspace/company.

create or replace function public.reset_company_intake(
  target_workspace_id uuid,
  target_company_id text
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  target_tenant_id uuid;
  invitation_row public.intake_invitations;
  session_row public.intake_sessions;
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
    raise exception 'Not allowed to reset this intake.'
      using errcode = '42501';
  end if;

  select *
    into invitation_row
  from public.intake_invitations
  where workspace_id = target_workspace_id
    and company_id = target_company_id
    and deleted_at is null
  order by updated_at desc
  limit 1;

  delete from public.intake_sessions
  where workspace_id = target_workspace_id
    and company_id = target_company_id;

  if invitation_row.id is not null and invitation_row.status <> 'disabled' then
    update public.intake_invitations
       set status = 'invited',
           started_at = null,
           completed_at = null,
           last_autosaved_at = null
     where workspace_id = invitation_row.workspace_id
       and id = invitation_row.id
    returning * into invitation_row;
  end if;

  insert into public.intake_sessions (
    workspace_id,
    tenant_id,
    company_id,
    id,
    status,
    current_step,
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
    target_workspace_id,
    target_tenant_id,
    target_company_id,
    coalesce(
      case when invitation_row.id is null then null else 'intake_' || invitation_row.id end,
      'intake_' || replace(extensions.gen_random_uuid()::text, '-', '')
    ),
    'draft',
    0,
    0,
    '[]'::jsonb,
    '[]'::jsonb,
    '{}'::jsonb,
    '{}'::jsonb,
    '{}'::jsonb,
    '{}'::jsonb,
    '{}'::jsonb,
    '{}'::jsonb,
    '{}'::jsonb
  )
  returning * into session_row;

  return jsonb_build_object(
    'status', 'reset',
    'invitation', case
      when invitation_row.id is null then null
      else public.admin_intake_invitation_json(invitation_row, null)
    end,
    'intakeSession', public.public_intake_session_json(session_row)
  );
end;
$$;

revoke all on function public.reset_company_intake(uuid, text) from public;
grant execute on function public.reset_company_intake(uuid, text) to authenticated;
