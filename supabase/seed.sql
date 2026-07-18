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
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
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

insert into public.products (
  workspace_id,
  tenant_id,
  company_id,
  id,
  name,
  description,
  type,
  priority,
  is_primary,
  created_by,
  updated_by
) values
  (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000001',
    'hb-cure',
    'hb-device',
    'HB Cure Messgerät',
    'Biometrisches Messgerät zur strukturierten Erfassung persönlicher Werte.',
    'product',
    1,
    true,
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  ),
  (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000001',
    'hb-cure',
    'hb-app',
    'HB Cure App',
    'Mobile App zur Anzeige, Verwaltung und Einordnung der erfassten Werte.',
    'product',
    2,
    false,
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  ),
  (
    '00000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000001',
    'schnurr-purr',
    'sp-relax-app',
    'SchnurrPurr Relax App',
    'Ruhige Begleit-App für Entspannung, Pausen und einfache Routinen.',
    'product',
    1,
    true,
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  ),
  (
    '00000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000001',
    'schnurr-purr',
    'sp-purr-pillow',
    'SchnurrPurr Kissen',
    'Komfortkissen für ruhige Pausen im Alltag.',
    'product',
    2,
    false,
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  )
on conflict (workspace_id, id) do update set
  name = excluded.name,
  description = excluded.description,
  type = excluded.type,
  priority = excluded.priority,
  is_primary = excluded.is_primary,
  updated_at = now();

insert into public.source_materials (
  workspace_id,
  tenant_id,
  company_id,
  id,
  title,
  type,
  url,
  content_snippet,
  status,
  notes,
  created_by,
  updated_by
) values
  (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000001',
    'hb-cure',
    'hb-source-faq',
    'HB Cure Website FAQ',
    'faq',
    'https://www.hb-cure.example/faq',
    'Fragen zu App, Messgerät, Konto und Support.',
    'reviewed',
    'Minimaler Remote-Seed für Repository-Tests.',
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  ),
  (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000001',
    'hb-cure',
    'hb-source-reviews',
    'HB Cure Website-Rezensionen',
    'review',
    'https://www.hb-cure.example/reviews',
    'Ausgewählte Nutzerstimmen auf der Website.',
    'new',
    'Trustmaterial ist vorhanden, Social Reviews bleiben ausbaufähig.',
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  ),
  (
    '00000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000001',
    'schnurr-purr',
    'sp-source-website',
    'SchnurrPurr Website',
    'website',
    'https://www.schnurrpurr.example',
    'Produkt- und App-Informationen für entspannte Pausen.',
    'reviewed',
    'Remote-Seed ohne medizinische Claims.',
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  )
on conflict (workspace_id, id) do update set
  title = excluded.title,
  type = excluded.type,
  url = excluded.url,
  content_snippet = excluded.content_snippet,
  status = excluded.status,
  notes = excluded.notes,
  updated_at = now();

insert into public.knowledge_entries (
  workspace_id,
  tenant_id,
  company_id,
  id,
  title,
  content,
  category,
  risk_level,
  keywords,
  source,
  source_material_id,
  language_code,
  created_by,
  updated_by
) values
  (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000001',
    'hb-cure',
    'hb-k-faq-app',
    'Wie funktioniert die HB Cure App?',
    'Die App zeigt erfasste Werte übersichtlich an und unterstützt Nutzer dabei, ihre Daten strukturiert zu betrachten. Sie ersetzt keine medizinische Beratung.',
    'faq',
    'yellow',
    array['app', 'werte', 'support'],
    'HB Cure Website FAQ',
    'hb-source-faq',
    'de',
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  ),
  (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000001',
    'hb-cure',
    'hb-k-no-medical',
    'Keine medizinische Einzelberatung',
    'Der Bot darf keine Diagnosen stellen, keine Behandlungsentscheidungen treffen und keine Heilversprechen formulieren.',
    'prozess',
    'red',
    array['no-go', 'medizin', 'diagnose'],
    'Business Rules',
    null,
    'de',
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  ),
  (
    '00000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000001',
    'schnurr-purr',
    'sp-k-relax-app',
    'Wofür ist die Relax App gedacht?',
    'Die Relax App unterstützt ruhige Pausen, einfache Routinen und eine angenehmere Alltagsstruktur. Sie macht keine medizinischen Aussagen.',
    'faq',
    'green',
    array['app', 'entspannung', 'pausen'],
    'SchnurrPurr Website',
    'sp-source-website',
    'de',
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  )
on conflict (workspace_id, id) do update set
  title = excluded.title,
  content = excluded.content,
  category = excluded.category,
  risk_level = excluded.risk_level,
  keywords = excluded.keywords,
  source = excluded.source,
  source_material_id = excluded.source_material_id,
  language_code = excluded.language_code,
  updated_at = now();

insert into public.bot_question_logs (
  workspace_id,
  tenant_id,
  company_id,
  id,
  question,
  answer,
  matched,
  redirected,
  reason,
  risk_level,
  review_status,
  human_note,
  created_by,
  updated_by
) values
  (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000001',
    'hb-cure',
    'hb-log-red',
    'Kann die App eine Diagnose stellen?',
    null,
    false,
    true,
    'redFlag',
    'red',
    'open',
    'Muss menschlich geprüft werden.',
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  ),
  (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000001',
    'hb-cure',
    'hb-log-faq',
    'Wie erreiche ich den Support?',
    'Bitte wenden Sie sich an support@hb-cure.example.',
    true,
    false,
    null,
    'green',
    'closed',
    null,
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  ),
  (
    '00000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000001',
    'schnurr-purr',
    'sp-log-no-match',
    'Gibt es Ersatzbezüge für das Kissen?',
    null,
    false,
    false,
    'noMatch',
    'green',
    'open',
    'Noch kein Wissenseintrag vorhanden.',
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  )
on conflict (workspace_id, id) do update set
  question = excluded.question,
  answer = excluded.answer,
  matched = excluded.matched,
  redirected = excluded.redirected,
  reason = excluded.reason,
  risk_level = excluded.risk_level,
  review_status = excluded.review_status,
  human_note = excluded.human_note,
  updated_at = now();

insert into public.audit_items (
  workspace_id,
  tenant_id,
  company_id,
  id,
  area,
  title,
  description,
  status,
  priority,
  note,
  recommendation,
  created_by,
  updated_by
) values
  (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000001',
    'hb-cure',
    'hb-audit-website',
    'website',
    'Website vorhanden',
    'Die Website ist als zentrale Quelle vorhanden.',
    'complete',
    'medium',
    null,
    'FAQ und Quellen weiter strukturiert übernehmen.',
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  ),
  (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000001',
    'hb-cure',
    'hb-audit-risk',
    'riskRules',
    'No-Go-Regeln wichtig',
    'Medizinische und riskante Aussagen müssen klar blockiert werden.',
    'partial',
    'high',
    'Remote Seed enthält erste Regeln.',
    'Regeln vor produktivem Bot-Einsatz weiter schärfen.',
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  ),
  (
    '00000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000001',
    'schnurr-purr',
    'sp-audit-support',
    'supportKnowledge',
    'Supportwissen teilweise vorhanden',
    'Erste FAQ-Inhalte sind vorhanden, weitere Produktfragen fehlen.',
    'partial',
    'medium',
    null,
    'FAQ zu Kissen, App und Support erweitern.',
    '00000000-0000-4000-8000-000000000010',
    '00000000-0000-4000-8000-000000000010'
  )
on conflict (workspace_id, id) do update set
  area = excluded.area,
  title = excluded.title,
  description = excluded.description,
  status = excluded.status,
  priority = excluded.priority,
  note = excluded.note,
  recommendation = excluded.recommendation,
  updated_at = now();
