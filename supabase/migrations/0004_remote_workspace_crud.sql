-- Block 22D: named tenant capability helpers for controlled remote writes.
--
-- Existing Block 22A policies already enforce INSERT/UPDATE/DELETE by tenant
-- role. These helpers keep future CRUD policies and database tests readable
-- without changing the current RLS boundary.

create or replace function public.can_read_tenant(target_tenant_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_tenant_role(
    target_tenant_id,
    array['owner', 'admin', 'editor', 'reviewer', 'viewer']
  );
$$;

create or replace function public.can_write_tenant(target_tenant_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_tenant_role(
    target_tenant_id,
    array['owner', 'admin', 'editor']
  );
$$;

create or replace function public.can_review_tenant(target_tenant_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_tenant_role(
    target_tenant_id,
    array['owner', 'admin', 'editor', 'reviewer']
  );
$$;

create or replace function public.can_admin_tenant(target_tenant_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.has_tenant_role(target_tenant_id, array['owner', 'admin']);
$$;

revoke all on function public.can_read_tenant(uuid) from public;
revoke all on function public.can_write_tenant(uuid) from public;
revoke all on function public.can_review_tenant(uuid) from public;
revoke all on function public.can_admin_tenant(uuid) from public;

grant execute on function public.can_read_tenant(uuid) to authenticated;
grant execute on function public.can_write_tenant(uuid) to authenticated;
grant execute on function public.can_review_tenant(uuid) to authenticated;
grant execute on function public.can_admin_tenant(uuid) to authenticated;
