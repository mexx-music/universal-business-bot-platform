-- Universal Business Platform
-- Block 22B: authentication foundation.
--
-- This migration prepares Auth integration without creating tenants from the
-- client. Tenant onboarding remains an explicit backend step so RLS stays the
-- authority for workspace access.

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  display_name text;
begin
  display_name := coalesce(
    nullif(new.raw_user_meta_data ->> 'display_name', ''),
    nullif(new.raw_user_meta_data ->> 'name', ''),
    split_part(coalesce(new.email, ''), '@', 1),
    ''
  );

  insert into public.user_profiles (
    id,
    display_name,
    locale,
    timezone,
    created_by,
    updated_by
  ) values (
    new.id,
    display_name,
    'de',
    'Europe/Vienna',
    new.id,
    new.id
  )
  on conflict (id) do update set
    display_name = excluded.display_name,
    updated_at = now(),
    updated_by = excluded.updated_by;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();

insert into public.user_profiles (
  id,
  display_name,
  locale,
  timezone,
  created_by,
  updated_by
)
select
  u.id,
  coalesce(
    nullif(u.raw_user_meta_data ->> 'display_name', ''),
    nullif(u.raw_user_meta_data ->> 'name', ''),
    split_part(coalesce(u.email, ''), '@', 1),
    ''
  ),
  'de',
  'Europe/Vienna',
  u.id,
  u.id
from auth.users u
on conflict (id) do nothing;

create or replace function public.active_tenant_memberships()
returns table (
  tenant_id uuid,
  user_id uuid,
  role text,
  membership_status text,
  tenant_name text,
  membership_created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    tm.tenant_id,
    tm.user_id,
    tm.role,
    tm.status,
    t.name,
    tm.created_at
  from public.tenant_members tm
  join public.tenants t on t.id = tm.tenant_id
  where tm.user_id = auth.uid()
    and tm.status = 'active'
    and tm.deleted_at is null
    and t.deleted_at is null
    and t.status = 'active'
  order by tm.created_at asc, tm.tenant_id asc;
$$;

revoke all on function public.handle_new_auth_user() from public;
revoke all on function public.active_tenant_memberships() from public;
grant execute on function public.active_tenant_memberships() to authenticated;
