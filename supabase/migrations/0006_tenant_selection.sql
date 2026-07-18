-- Block 22F: tenant selection metadata.
--
-- The client must choose only from memberships resolved for auth.uid().
-- This RPC remains the single safe source for selectable tenants.

drop function if exists public.active_tenant_memberships();

create function public.active_tenant_memberships()
returns table (
  membership_id text,
  tenant_id uuid,
  user_id uuid,
  role text,
  membership_status text,
  tenant_name text,
  tenant_slug text,
  tenant_status text,
  workspace_count integer,
  primary_workspace_id uuid,
  primary_workspace_name text,
  membership_created_at timestamptz,
  membership_updated_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    tm.tenant_id::text || ':' || tm.user_id::text as membership_id,
    tm.tenant_id,
    tm.user_id,
    tm.role,
    tm.status as membership_status,
    t.name as tenant_name,
    null::text as tenant_slug,
    t.status as tenant_status,
    coalesce(ws.workspace_count, 0)::integer as workspace_count,
    ws.primary_workspace_id,
    ws.primary_workspace_name,
    tm.created_at as membership_created_at,
    tm.updated_at as membership_updated_at
  from public.tenant_members tm
  join public.tenants t on t.id = tm.tenant_id
  left join lateral (
    select
      count(*)::integer as workspace_count,
      (array_agg(w.id order by w.created_at asc, w.id asc))[1]
        as primary_workspace_id,
      (array_agg(w.name order by w.created_at asc, w.id asc))[1]
        as primary_workspace_name
    from public.workspaces w
    where w.tenant_id = tm.tenant_id
      and w.deleted_at is null
      and w.archived_at is null
  ) ws on true
  where tm.user_id = auth.uid()
    and tm.status = 'active'
    and tm.deleted_at is null
    and t.deleted_at is null
    and t.status = 'active'
  order by lower(t.name) asc, tm.created_at asc, tm.tenant_id asc;
$$;

revoke all on function public.active_tenant_memberships() from public;
grant execute on function public.active_tenant_memberships() to authenticated;
