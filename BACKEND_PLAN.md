# Backend-Plan: Vom lokalen Produkt zur SaaS-Plattform

Stand: Juli 2026 · Schema-Version lokal: 3 · Entscheidung: **Supabase**

---

## 0. Ausgangslage (geprüfter Ist-Zustand)

Was die Migration trägt — und was sie bremst:

**Trägt:**
- `WorkspaceRepository` ist die einzige Datenzugriffsgrenze; UI und AppState
  kennen keine Speichertechnik. Der Austausch findet hinter dem Interface
  statt (synchrone Snapshot-Reads, `Future`-Writes, Write-Queue).
- `TenantContext` (tenantId, userId) wird bereits durch alle Repositories
  gereicht — Auth muss ihn nur noch mit echten Werten füllen.
- `AppDependencies.create()` ist eine asynchrone Composition Root; eine
  `AppDependencies.remote(session)`-Factory ist der vorgesehene Andockpunkt.
- `WorkspaceCodec` serialisiert bereits **jede Entität einzeln** (explizite
  encode/decode-Methoden pro Modell) — die Zerlegung in Tabellenzeilen ist
  vorbereitet, auch wenn lokal alles als ein Dokument gespeichert wird.
- Schema-Versionierung + Migrationen (v1→v2→v3) sind etabliertes Muster.
- IDs sind client-generiert und stabil (`k1`, `ar_expandFaq_…`, `ci_…`) —
  gut für idempotenten Import.

**Bremst (ehrlich benannt):**
1. **Speichergranularität:** Lokal ist ein Workspace *ein* Dokument
   (ein sembast-Record). Ein Backend braucht Zeilen pro Entität — sonst
   überschreiben sich zwei Geräte gegenseitig den kompletten Workspace.
   Das ist die größte technische Einzelaufgabe der Migration (betrifft nur
   Repository + Codec, nicht UI/AppState).
2. **`selectedCompanyId` liegt im Persistenz-Meta** — das ist
   Client-Zustand, kein Tenant-Datum; wandert bei der Migration in lokale
   Präferenzen.
3. **Kein `updatedAt` auf Entitätsebene** (nur teilweise, z. B.
   SourceMaterial). Für Sync-Konflikterkennung muss das Backend
   `updated_at`/`rev` führen; der Client muss es nicht rückwirkend haben.
4. `IntakeSession` ist ein tief verschachteltes Dokument mit ~100
   Blattfeldern in 7 Sektionen — als relationale Tabellen wäre das Unsinn;
   klarer JSONB-Fall.

---

## 1. Entscheidung: Supabase (statt Firebase)

### Projektbezogene Bewertung

| Kriterium | Befund für dieses Projekt |
|---|---|
| **Datenstruktur** | Unsere Daten sind oben relational (tenants → members → workspaces → Entitätslisten) und unten dokumentartig (IntakeSession, BusinessRules, BotConfiguration). Postgres mit JSONB bedient **beides nativ**. Firestore zwingt alles ins Dokumentmodell; Listen wie `action_records` mit Status-/Zeitraum-Queries (Check-in-Generator!) würden zu Collection-Group-Queries mit Index-Pflege. |
| **Multi-Tenancy / RLS** | Row-Level Security ist *das* Argument: `tenant_id`-Spalte + eine Policy pro Tabelle, serverseitig erzwungen, testbar mit SQL. Genau das Modell, das `TenantContext` vorbereitet. Firestore-Security-Rules können das auch, sind aber pfadbasiert, schwerer zu testen und bei 14 Collection-Typen × 5 Rollen deutlich fehleranfälliger. Datenvermischung ist unser Top-Risiko — hier zählt das robustere Werkzeug. |
| **Auth** | Beide gleichwertig (E-Mail/Passwort, Magic Link, Reset, Verifikation). Supabase-Auth speist `auth.uid()` direkt in RLS-Policies — Auth und Datensicherheit sind *ein* System statt zwei. |
| **Flutter Web** | `supabase_flutter` ist pure Dart (REST + WebSocket) — kein JS-Interop. Firebase-Web unter Flutter läuft über JS-SDK-Bridges; funktioniert, ist aber die fehleranfälligere Schicht, und Web ist unsere primäre Plattform. |
| **Realtime** | Später nützlich (zwei Nutzer im selben Workspace). Supabase Realtime auf Postgres-Changes reicht; Firestore ist hier stärker, aber wir brauchen kein Streaming-First. |
| **Offline/Local-First** | **Firebases stärkstes Argument:** Firestore bringt Offline-Cache gratis mit. Aber: Wir *haben* bereits eine funktionierende Local-First-Schicht (sembast/IndexedDB, Write-Queue, Schema-Migrationen). Sie bleibt als Cache bestehen — der Firebase-Vorteil ist für uns weitgehend entwertet. |
| **Datei-Uploads** | Supabase Storage (S3-kompatibel, RLS-integriert) vs. Firebase Storage — gleichwertig. Relevant erst für Quellen-Uploads (PDF). |
| **E-Mail/Reminder** | Supabase: `pg_cron` + Edge Function + Resend/SMTP — der fällige Check-in ist **eine SQL-Query** über `companion_check_ins`. Firebase: Cloud Scheduler + Function + Firestore-Query. Beides machbar; SQL-Fälligkeit ist einfacher zu testen. |
| **LLM-/API-Anbindung** | Strategisch wichtig: **pgvector** für die Knowledge Runtime (Embedding-Retrieval über `knowledge_entries`) liegt in derselben DB, mit denselben RLS-Policies. Firestore-Vektorsuche existiert, aber pgvector + SQL-Filter (tenant, risk_level, category) passt exakt auf unser Retrieval-Design. Edge Functions (Deno/TS) als LLM-Proxy: gleichwertig zu Cloud Functions. |
| **Stripe** | Beide über Webhooks + Functions gut machbar; kein Differenzierer. `tenants.plan` + RLS-gestützte Limits sind in SQL leicht. |
| **Lokale Entwicklung** | `supabase start` (Docker) = komplette lokale Instanz inkl. Auth/RLS; Migrationen als SQL-Dateien im Repo — passt zur bestehenden Versionierungsdisziplin. Firebase-Emulatoren sind gut, aber Rules-Tests bleiben mühsamer. |
| **Backup/Export** | Postgres-Dumps, Point-in-Time-Recovery ab Pro-Plan. Firestore-Export ist umständlicher und proprietär. |
| **Vendor Lock-in** | Supabase = Postgres: jederzeit zu RDS/Fly/selbst gehostet migrierbar. Firestore-Datenmodell + Rules sind nicht portabel. Für ein Produkt, dessen Moat „Unternehmensgedächtnis" heißt, ist Datenportabilität kein Detail. |
| **Kosten 50/500/5000 Firmen** | Datenvolumen ist winzig (Text). 50 Firmen: Free/Pro ($25/Monat). 500: Pro reicht ($25–50). 5000: kleines Compute-Upgrade (~$100/Monat) + E-Mail-Kosten (~$20). Firestore wäre ähnlich billig, aber nutzungsbasiert schwerer prognostizierbar (Reads pro Check-in-Query × Firmen). |

### Empfehlung

**Supabase**, weil:
1. **Die Datenstruktur passt:** relationaler Kopf (Tenancy, Listen mit
   Queries) + JSONB-Blätter (Intake, Rules, Config) — exakt unser Modell.
2. **RLS deckt unser größtes Risiko** (Mandantentrennung) mit dem
   robustesten, testbarsten Mechanismus ab — und `TenantContext` ist die
   clientseitige Entsprechung, die schon existiert.
3. **Solo-Entwickler-Ökonomie:** eine Technologie (SQL) für Schema,
   Sicherheit, Fälligkeits-Queries und späteres Vektor-Retrieval; SQL-
   Migrationen im Repo statt Rules-DSL + Index-Konfiguration + Scheduler.
4. **Kein Lock-in** auf das Herzstück (die Daten).

**Verbleibende Risiken:** RLS-Fehlkonfiguration (Gegenmittel: Default-Deny +
dedizierte Isolationstests, Phase 22C); Sync-Konflikte in Eigenbau statt
Firestore-Gratis-Offline (Gegenmittel: bewusst simple Strategie, s. §6);
Supabase ist als Firma jünger als Google (Gegenmittel: Postgres-Portabilität).

**Wann Firebase besser wäre:** wenn native Mobile-Apps mit Push (FCM) und
aggressivem Offline-Sync der Kern wären, oder ein Team ohne SQL-Erfahrung —
beides trifft nicht zu.

---

## 2. Ziel-Architektur

```
Flutter Web (unverändert: Screens, AppState, Engine, Runtime, Services)
        │
WorkspaceRepository (Interface, unverändert)
        │
SyncedWorkspaceRepository            NEU (ersetzt Persistent~ als Default)
   ├── In-Memory-Snapshot            (synchrone Reads, wie heute)
   ├── sembast/IndexedDB             (Offline-Cache + Outbox, wie heute)
   └── SupabaseWorkspaceApi          NEU (Zeilen statt Blob; supabase_flutter)
        │
Supabase: Postgres (RLS, pg_cron, später pgvector) · Auth · Edge Functions · Storage
```

- `LocalWorkspaceRepository` (Tests/Demo) und `PersistentWorkspaceRepository`
  (reiner Offline-Modus) bleiben erhalten.
- `AppDependencies.remote(session)` verdrahtet Auth-Session → `TenantContext`
  → SyncedRepository. `main()` wählt nach Session-Restore.

## 3. Datenmodell (Postgres)

**Konventionen für alle Inhaltstabellen:** `id text` (client-generiert,
PK zusammen mit `workspace_id` → idempotenter Import), `workspace_id uuid`,
`tenant_id uuid` (denormalisiert für einfache RLS + Indizes),
`created_at/updated_at timestamptz`, `created_by/updated_by uuid`,
`deleted_at timestamptz` (Soft Delete), `rev int` (optimistische Sperre,
serverseitig inkrementiert).

```
auth.users                          (Supabase-verwaltet)
user_profiles    id (=auth.uid), display_name, locale, timezone
tenants          id uuid, name, plan, created_at
tenant_members   tenant_id, user_id, role, status(active|invited), invited_by
                 PK (tenant_id, user_id)
invites          id, tenant_id, email, role, token, expires_at, accepted_at
workspaces       id uuid, tenant_id, name, archived_at, …
companies        1:1 zu workspaces — Profilspalten (name, industry, website,
                 email, …) + social_links jsonb
                 + business_rules jsonb + bot_configuration jsonb
products         relational (id, name, description, type, price)
knowledge_entries    relational: title, content, category, risk_level,
                     keywords text[], source, language_code
                     → wird gefiltert/gerankt/später embedded → Zeilen, kein Blob
source_materials     relational (Status-Workflow, Typen, related_ids text[])
bot_question_logs    relational (Review-Queue-Queries: status, reason, ts)
action_records       relational: action_type, status, alle Zeitpunkte,
                     result_rating, expected_impact, repeat_requested,
                     decline_reason, result_note, actual_outcome,
                     source_reason_keys text[], related_goal_ids text[]
                     → Engine-Unterdrückung & Historie brauchen Queries
companion_check_ins  Kopf relational (period_start/end, status, completed_at,
                     data_confidence, needs_human_review) + content jsonb
                     (summary, outcomes, lessons, user_notes, next_action_ids,
                     id-Listen) → wird als Ganzes gelesen, ist unveränderlich
business_goals       relational (priority, status, dates, linked_areas text[])
marketing_actions    relational (type, status, priority, budgets)
audit_items          relational (area, status, priority, note)
intake_sessions      Kopf relational (status, step, timestamps) + 7 Sektionen
                     als jsonb (basics, products, target_groups, …)
                     → ~100 Blattfelder, immer als Block gelesen/geschrieben
import_logs          Import-Protokoll (siehe §7)
change_log           Audit Trail: entity, entity_id, actor, action, diff jsonb
```

**Ehrliche Abgrenzungen:**
- **Relational, weil abgefragt:** knowledge_entries, action_records,
  bot_question_logs, source_materials, check-in-Köpfe, goals, marketing,
  audit — alles, worüber Engine/Generator/Reminder filtern.
- **JSONB, weil Dokument:** Intake-Sektionen, BusinessRules,
  BotConfiguration, Check-in-Inhalt, social_links. Diese Blobs werden nie
  serverseitig gefiltert; Spalten wären reine Zeremonie.
- **Versionierung:** Backend-Schema über SQL-Migrationsdateien im Repo
  (supabase CLI); der lokale `schemaVersion`-Mechanismus bleibt für den
  Cache. `rev` pro Zeile für Konflikt­erkennung.
- **Audit Trail bewusst minimal starten:** Trigger-basiertes `change_log`
  nur für Mitglieder-/Rollenänderungen und Löschungen. Ein Voll-Audit aller
  Tabellen ist Solo-Dev-Overhead ohne aktuellen Abnehmer — die fachliche
  Historie (ActionRecords, Check-ins) existiert ja bereits als Produktfeature.

## 4. Tenant-Sicherheit

- **Default-Deny:** RLS auf jeder Tabelle aktiv; ohne passende Policy kein
  Zugriff. Kein Service-Role-Key im Client, jemals.
- **Zugriffspfad:** JWT → `auth.uid()` → `tenant_members` →
  Policy `tenant_id IN (SELECT tenant_id FROM tenant_members
  WHERE user_id = auth.uid() AND status = 'active')` auf **jeder** Zeile
  (deshalb die denormalisierte `tenant_id`).
- **Rollen** (Spalte in `tenant_members`, in Write-Policies ausgewertet):
  - `owner` — alles inkl. Billing, Tenant löschen, Owner übertragen
  - `admin` — Mitglieder/Einladungen, Workspaces anlegen/archivieren
  - `editor` — Inhalte schreiben (Knowledge, Maßnahmen, Check-ins, Intake)
  - `reviewer` — Human Review bearbeiten (bot_question_logs schreiben),
    Inhalte lesen
  - `viewer` — nur lesen
- **Serverseitig erzwungen:** Inserts validieren `tenant_id`/`workspace_id`
  gegen die Mitgliedschaft per Policy (`WITH CHECK`), nicht per Client-Code.
  Client-`TenantContext` ist Komfort, nie Sicherheitsgrenze.
- **Tests der Mandantentrennung (Pflicht, Phase 22C):** SQL-Tests (pgTAP
  oder supabase test) mit zwei Nutzern in zwei Tenants: jeder CRUD-Versuch
  auf fremde Daten muss scheitern; zusätzlich ein Dart-Integrationstest
  gegen die lokale Supabase-Instanz. Merkregel: **Jede neue Tabelle ohne
  Isolationstest gilt als unsicher.**

## 5. Auth-Flow (Block 22B Foundation)

1. **Optionaler Start:** Ohne `SUPABASE_URL` und `SUPABASE_ANON_KEY` läuft die
   App weiter im lokalen Modus. Login ist ein Upgrade, keine Pflicht.
2. **Initialisierung:** Mit Build-Variablen wird Supabase vor `runApp`
   initialisiert. Fehler führen kontrolliert in den lokalen Modus, nicht in
   eine leere App.
3. **Login/Logout/Reset:** Standard `supabase_flutter`, aber gekapselt hinter
   `AuthService`; kein UI-Code greift direkt auf `SupabaseClient.auth` zu.
4. **TenantContext:** Nach Login werden aktive Mitgliedschaften über
   `active_tenant_memberships()` aus `tenant_members` geladen. Keine
   Membership führt ins Onboarding, eine Membership wird automatisch aktiv,
   mehrere Memberships nutzen die letzte gültige Tenant-Auswahl pro User-ID
   oder führen zu `/select-tenant`. Es gibt keinen automatischen
   „ersten Eintrag“-Fallback mehr.
5. **Registrierung:** E-Mail + Passwort + optionaler Name. Der Trigger
   `handle_new_auth_user()` legt `user_profiles` an. Tenant-Erstellung bleibt
   ein späterer, serverseitiger Onboarding-/RPC-Schritt; der Client insertet
   keine Tenants, um RLS nicht zu umgehen.
6. **Später:** Einladungen, Rollenverwaltung, Teamverwaltung und Migration
   lokaler Daten folgen in späteren Blöcken.

## 6. Repository-Migration & Sync

- **Interface unverändert**, AppState unverändert, UI unverändert — das ist
  das Abnahmekriterium jeder Phase.
- **22C-Stand:** `RemoteWorkspaceRepository` lädt einen tenant-gesicherten
  Supabase-Snapshot hinter dem bestehenden Interface. Unterstützt sind
  Workspaces, Companies, Products, Knowledge Entries, Source Materials,
  Bot Question Logs und Audit Items. Jede Query filtert explizit auf den
  aktiven `TenantContext.tenantId`; RLS bleibt die eigentliche Autorität.
- **22D-Stand:** Kontrollierte Cloud-Writes sind für die bereits
  bearbeitbaren Entitäten umgesetzt: Company-Profil inklusive Business Rules
  und BotConfiguration, Products, Knowledge Entries, Source Materials,
  Bot Question Logs und Audit Items. Die UI bleibt hinter `AppState` und
  `WorkspaceRepository`; Supabase-Zugriffe liegen ausschließlich in
  `RemoteWorkspaceDataSource`.
- **Reads:** wie heute synchron aus dem In-Memory-Snapshot. Start: Cache
  sofort laden (schnell), dann Remote-Pull, dann `notifyListeners` über den
  bestehenden Mechanismus (AppState lauscht nicht auf Repo — der Pull läuft
  vor `runApp` oder löst einen Workspace-Replace über AppState aus; Detail
  in 22D).
- **Writes:** lokal weiter local-first über IndexedDB-Queue; remote bewusst
  server-first. Das Repository schreibt zuerst nach Supabase, erhält den
  bestätigten Datensatz zurück, mappt ihn in den Snapshot und benachrichtigt
  dann AppState. Es gibt noch keine Outbox, kein Realtime und keine
  Mehr-Client-Konfliktauflösung.
- **Konflikte (bewusst simpel für Stufe 1):** Last-Write-Wins pro Zeile via
  `updated_at`/`rev`; bei `rev`-Konflikt gewinnt der Server, die lokale
  Änderung wird als Konfliktnotiz geloggt (kein Merge-UI). Ehrlich: Bis es
  Mehrbenutzer-Tenants wirklich gibt, ist jeder Konflikt ein
  Selbstkonflikt zweier Geräte — LWW reicht, Merge-Aufwand wäre verfrüht.
  Check-ins sind unveränderlich → konfliktfrei per Design.
- **Lade-/Fehlerzustände:** Start bleibt „Cache sofort"; ein globaler,
  dezenter Sync-Status (aktuell/synchronisiert/offline) am Shell-Rand ist
  die einzige UI-Ergänzung. Fehler degradieren zu Offline-Betrieb — nie zu
  Datenverlust, nie zu Blockade (dasselbe Prinzip wie heute bei
  Persistenzfehlern).

## 7. Datenmigration IndexedDB → Cloud

1. **Erkennen:** Nach erstem Login prüfen, ob die lokale sembast-DB
   Nicht-Seed-Daten enthält (Workspaces ≠ unveränderte Mock-Seeds oder
   vorhandene actionRecords/checkIns/intake).
2. **Fragen:** Dialog „Lokale Daten gefunden — in Ihr Konto übernehmen?"
   (Übernehmen / Später / Nicht übernehmen). Nichts passiert automatisch.
3. **Import:** pro Workspace → Tabellenzeilen (der Codec kann jede Entität
   bereits einzeln encodieren). **Idempotent durch Upsert auf
   (workspace_id, id)** — client-generierte IDs bleiben erhalten, doppelte
   Ausführung erzeugt keine Duplikate.
4. **Protokoll:** `import_logs` (Batch-ID, Zählstände pro Entitätstyp,
   Status started/completed/failed). Wiederaufnahme nach Abbruch = erneuter
   Upsert desselben Batches.
5. **Rollback:** Alle importierten Zeilen tragen die Batch-ID
   (`import_batch_id`-Spalte) → Rollback = Delete per Batch-ID. Die lokalen
   Daten werden **nie** vor bestätigtem, verifiziertem Import gelöscht
   (Zählstände Client vs. Server müssen übereinstimmen); danach bleibt die
   lokale DB als Cache ohnehin bestehen.
6. **Versionen:** Import akzeptiert nur lokale Schema-Version ≤ 3 (heutige);
   ältere laufen erst durch die bestehende lokale Migration.

## 8. Reminder-/Check-in-Vorbereitung (nur Plan)

- **Fälligkeit ist eine SQL-Query:** letzter completed Check-in pro
  Workspace (`max(period_end)`) + Intervall < now → fällig. Kein neuer
  Zustand nötig — genau die Logik, die `CheckInService.nextRecommendedCheckIn`
  heute clientseitig rechnet.
- **Ablauf:** `pg_cron` täglich → Edge Function → fällige Workspaces mit
  `reminder_settings.enabled` und ohne Eintrag in `reminder_log` der letzten
  Periode → E-Mail via Resend, in `user_profiles.locale` (de/en — ARB-Texte
  wiederverwendbar) und zur lokalen Morgenzeit gemäß
  `user_profiles.timezone` (Cron läuft stündlich, filtert nach Zeitzone).
- **Abmelden:** Unsubscribe-Link (signierter Token) → Edge Function →
  `reminder_settings.enabled = false`; zusätzlich später als Einstellung.
- **`reminder_log`** verhindert Doppelversand (Idempotenz wie überall).

## 9. Phasenplan

| Phase | Ziel | Geänderte Bereiche | Hauptrisiko | Tests | Abnahme |
|---|---|---|---|---|---|
| **22A Schema & lokales Backend** | Supabase-Projekt + komplettes SQL-Schema als Migrationsdateien; `supabase start` lokal läuft | nur `supabase/`-Ordner, kein App-Code | Schema-Fehlentwurf (später teuer) | pgTAP-Smoke: Tabellen, Constraints, Default-Deny | Lokale Instanz startet; Schema entspricht §3; CI kann Migrationen anwenden |
| **22B Auth** | Registrierung/Login/Reset/Verifikation/Session-Restore in der App; Tenant+Workspace-Anlage bei Signup | `AppDependencies`, neue Auth-Screens, `TenantContext` echt | Session-Handling Web (Reload, Tabs) | Widget-Tests Auth-Flows gegen lokale Instanz; Session-Restore-Test | Nutzer kann sich registrieren, einloggen, Reload behält Session; ohne Login bleibt lokaler Modus voll funktionsfähig |
| **22C Tenant-Sicherheit** | RLS-Policies für alle Tabellen + Rollen | nur SQL + Tests | Policy-Lücke = Datenleck | **Pflicht:** Zwei-Tenant-Isolationstests für jede Tabelle (CRUD-Matrix), Rollen-Matrix-Tests | Kein einziger Fremd-Zugriff möglich; Tests rot bei fehlender Policy neuer Tabellen |
| **22D Remote CRUD** | Kontrollierte server-first Cloud-Writes für vorhandene Workspace-Entitäten | `lib/repositories/`, `AppState`, Supabase-Tests; Widgets bleiben ohne Supabase | RLS-/Rollenlücke; versehentliche Tenant-IDs aus UI | Repository-/AppState-Tests, pgTAP CRUD/RLS-Matrix | Remote-Änderungen sind nach Reload vorhanden; Viewer/Inactive/No-Membership schreiben nicht |
| **22E Tenant Onboarding** | Erster Tenant + Owner-Membership + Workspace + Company per RPC | `supabase/`, Auth/Onboarding-Service, Router | Doppelte Tenants, halbfertiger Setup | pgTAP RPC-Tests, Controller-/Router-/Widget-Tests, E2E-Smoke | Neuer Nutzer ohne Membership richtet Firma ein und landet nach Reload im Remote-Workspace |
| **22F Tenant-Auswahl & Rollen** | Mehrere aktive Memberships, sichere Auswahl, Tenant-Switcher, letzte Auswahl pro User | AuthController, TenantSelectionController, AppShell, RPC `active_tenant_memberships` | Tenant-Wechsel/Rollenfehler, alte Daten sichtbar | Membership-/Router-/Widget-Tests, pgTAP Tenant-Auswahl | Nutzer mit mehreren Firmen wählt sicher; alter State wird geleert; Rollen wechseln pro Tenant |
| **22G Team-Einladungen** | Einladungen, Membership-Verwaltung und Rollensteuerung | Auth/RLS/UI für Teams | falsche Rollen, Einladungs-Missbrauch | Rollen-/Invite-Tests | Owner/Admin können Mitglieder sicher einladen und Rollen verwalten |
| **22H Reminder** | pg_cron + Edge Function + Resend, Abmeldelink | nur Backend + `reminder_*`-Tabellen | Doppelversand, Zeitzonen | Fälligkeits-Query-Tests; Idempotenz via reminder_log | Fälliger Check-in erzeugt genau eine E-Mail in Nutzersprache/-zeitzone; Abmelden wirkt |

Reihenfolge ist bindend; jede Phase ist einzeln deploybar und lässt die App
jederzeit im lokalen Modus voll funktionsfähig.

## 10. Kosten & Risiken

**Kosten:** Entwicklung: Supabase Free + lokale Instanz = 0 €. Launch:
Pro-Plan ~25 $/Monat (Backups, pg_cron) + Resend Free (bis 3 000 Mails/Monat)
+ Domain. 50 Firmen: ~25 $/Monat. 500: 25–50 $. 5 000: ~100–150 $/Monat
(Compute + E-Mail) — Textdaten bleiben klein; kein Kostenrisiko im Modell.

**Top-Risiken, priorisiert:**
1. **RLS-Lücke** → Default-Deny + Test-Pflicht pro Tabelle (22C), kein
   Service-Key im Client.
2. **Blob→Zeilen-Refactor** (22D) → größter Codeeingriff; abgesichert durch
   die 116 bestehenden Tests und das unveränderte Interface.
3. **Sync-Eigenbau** → bewusst primitives LWW + Outbox; Komplexität
   (Merge, CRDTs) explizit vertagt, bis Mehrbenutzer real sind.
4. **Solo-Dev-Betrieb** → Managed Service, tägliche Backups (Pro),
   Monitoring per Supabase-Dashboard; kein eigenes Ops.
5. **Scope-Sog** („wenn schon Backend, dann auch gleich…") → Phasenplan ist
   die Verteidigungslinie; nichts außerhalb 22A–22G.

## 11. Nächste konkrete Implementierungsaufgabe

**Block 22A:** Supabase-Projekt anlegen, `supabase init` im Repo,
das Schema aus §3 als erste Migrationsdatei
(`supabase/migrations/0001_initial_schema.sql`) inklusive RLS-Default-Deny
auf allen Tabellen, lokale Instanz per `supabase start`, pgTAP-Smoke-Tests.
**Kein Flutter-Code wird angefasst.**
