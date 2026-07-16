-- Minimal local seed for Block 22A.
-- This is intentionally small: demo tenant, demo user, HB Cure, SchnurrPurr.

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
  is_super_admin,
  is_sso_user,
  is_anonymous
) values (
  '00000000-0000-0000-0000-000000000000',
  '00000000-0000-4000-8000-000000000010',
  'authenticated',
  'authenticated',
  'demo@universalbusiness.local',
  extensions.crypt('demo-password', extensions.gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"]}'::jsonb,
  '{"display_name": "Demo User"}'::jsonb,
  false,
  false,
  false
) on conflict (id) do update set
  email = excluded.email,
  updated_at = now();

insert into public.user_profiles (
  id,
  display_name,
  locale,
  timezone,
  created_by,
  updated_by
) values (
  '00000000-0000-4000-8000-000000000010',
  'Demo User',
  'de',
  'Europe/Vienna',
  '00000000-0000-4000-8000-000000000010',
  '00000000-0000-4000-8000-000000000010'
) on conflict (id) do update set
  display_name = excluded.display_name,
  locale = excluded.locale,
  timezone = excluded.timezone,
  updated_at = now();

insert into public.tenants (
  id,
  name,
  plan,
  created_by,
  updated_by
) values (
  '00000000-0000-4000-8000-000000000001',
  'Demo Tenant',
  'free',
  '00000000-0000-4000-8000-000000000010',
  '00000000-0000-4000-8000-000000000010'
) on conflict (id) do update set
  name = excluded.name,
  updated_at = now();

insert into public.tenant_members (
  tenant_id,
  user_id,
  role,
  status,
  created_by,
  updated_by
) values (
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000010',
  'owner',
  'active',
  '00000000-0000-4000-8000-000000000010',
  '00000000-0000-4000-8000-000000000010'
) on conflict (tenant_id, user_id) do update set
  role = excluded.role,
  status = excluded.status,
  updated_at = now();

insert into public.workspaces (
  id,
  tenant_id,
  name,
  created_by,
  updated_by
) values
  (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000001',
    'HB Cure',
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  ),
  (
    '00000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000001',
    'SchnurrPurr',
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  )
on conflict (id) do update set
  name = excluded.name,
  updated_at = now();

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
) values
  (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000001',
    'hb-cure',
    'HB Cure',
    'Digitale Gesundheits-App mit strukturiertem Support- und Wissensaufbau.',
    'Digital Health',
    'AT',
    'de',
    'https://www.hb-cure.example',
    'support@hb-cure.example',
    '{"website": "https://www.hb-cure.example"}'::jsonb,
    '{"brandVoice": "klar, ruhig, vorsichtig", "noGoRules": ["keine Heilversprechen", "keine individuelle medizinische Beratung"]}'::jsonb,
    '{"status": "testReady", "defaultLanguage": "de", "useDisclaimer": true, "alwaysEscalateRedFlags": true}'::jsonb,
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  ),
  (
    '00000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000001',
    'schnurr-purr',
    'SchnurrPurr',
    'Entspannungs-App und Komfortprodukte für ruhige Pausen im Alltag.',
    'Wellbeing / Comfort Products',
    'AT',
    'de',
    'https://www.schnurrpurr.example',
    'support@schnurrpurr.example',
    '{"website": "https://www.schnurrpurr.example"}'::jsonb,
    '{"brandVoice": "freundlich, warm, alltagsnah", "noGoRules": ["keine medizinischen Claims"]}'::jsonb,
    '{"status": "draft", "defaultLanguage": "de", "useDisclaimer": false, "alwaysEscalateRedFlags": true}'::jsonb,
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  )
on conflict (workspace_id) do update set
  company_name = excluded.company_name,
  short_description = excluded.short_description,
  industry = excluded.industry,
  website = excluded.website,
  support_email = excluded.support_email,
  updated_at = now();
