# Architektur

Universal Business Bot Platform — Flutter Web (PWA), ausgeliefert über
Cloudflare Pages. Die App läuft vollständig lokal im Browser; Workspace-Daten
werden lokal in IndexedDB persistiert und überleben einen Reload. Der
Repository-Layer ist so geschnitten, dass Auth und Cloud-Backend später ohne
Änderungen an UI oder Screens ergänzt werden können.

## Schichten

```
Screens / Widgets                 (UI, liest ausschließlich AppState)
        │
AppState (ChangeNotifier)         (Anwendungslogik, Benachrichtigung der UI)
        │
WorkspaceRepository               (Interface — einzige Datenzugriffsgrenze)
        │
        ├── PersistentWorkspaceRepository   (Standard im Web: sembast/IndexedDB)
        │       └── WorkspaceCodec          (explizites toJson/fromJson)
        └── LocalWorkspaceRepository        (In-Memory: Tests, Demo, Fallback)
                └── WorkspaceStore + MockData
```

Daneben, jeweils zustandslos und per Konstruktor in `AppState` injiziert:

- `services/` — Mutationslogik auf Workspaces (`WorkspaceMutationService`,
  `IntakeMappingService`)
- `calculators/` — pure Ableitungen/Scores (Project Status, Marketing,
  Strategy, BI, Dashboard)

## Repository Layer

- `lib/repositories/workspace_repository.dart` — Interface. `AppState` kennt
  nur dieses Interface; kein UI-Code und keine Anwendungslogik greift auf
  `WorkspaceStore` oder `MockData` zu.
- `lib/repositories/persistent_workspace_repository.dart` — Standard im Web;
  persistiert nach jeder Mutation in IndexedDB (sembast).
- `lib/repositories/local_workspace_repository.dart` — In-Memory-Variante für
  Tests, Demo und als Fallback; einziger Ort, der `WorkspaceStore` kennt.
- `lib/repositories/tenant_context.dart` — `TenantContext` (tenantId, userId).
  Jedes Repository ist an einen Kontext gebunden. Ohne Auth läuft alles unter
  `TenantContext.local()`; nach Einführung von Auth erzeugt die Composition
  Root pro Session einen echten Kontext.

Lesezugriffe sind synchron (Snapshot-Semantik): Der komplette Zustand liegt
im Speicher, Schreibzugriffe aktualisieren ihn sofort und laufen danach über
eine serialisierte Write-Queue in den Storage (local-first). Die
`Future`-Rückgaben der Schreibmethoden signalisieren den Abschluss der
Persistierung.

## Lokale Persistenz

- **Technologie:** [sembast](https://pub.dev/packages/sembast) mit
  IndexedDB-Backend (`sembast_web`). Pro Workspace ein eigener Record im
  Store `workspaces` (Key = Company-ID), dazu ein `meta`-Record mit
  `schemaVersion` und `selectedCompanyId` — kein monolithischer
  localStorage-String.
- **Serialisierung:** `lib/repositories/persistence/workspace_codec.dart` —
  explizite toJson/fromJson für den gesamten Modellgraphen. Enums werden als
  stabile `.name`-Strings gespeichert, `DateTime` als ISO-8601. Reads sind
  tolerant: unbekannte Felder werden ignoriert, unbekannte Enum-Werte fallen
  auf sichere Defaults zurück; nur ein Record ohne Company-ID gilt als
  unlesbar.
- **Datenfluss beim Start:** `main()` wartet auf `AppDependencies.create()`,
  erst danach rendert die App — kein UI-Flash, kein Überschreiben während
  des Ladens.
  1. Kein persistenter Bestand → MockData als Seed übernehmen und
     persistieren (einmalig, erster Start).
  2. Bestand vorhanden → laden; MockData wird nicht erneut darübergeschrieben.
  3. Einzelne unlesbare Records werden übersprungen; ist gar nichts lesbar,
     läuft die Session auf dem Mock-Seed, ohne den gespeicherten Bestand zu
     überschreiben.
  4. Öffnen schlägt fehl oder `schemaVersion` ist neuer als die App →
     Fallback auf `LocalWorkspaceRepository` (In-Memory); gespeicherte Daten
     bleiben unangetastet. Persistenzfehler erscheinen nie ungefiltert im UI.
- **Schema-Version:** aktuell `1`, im `meta`-Record gespeichert. Neuere
  Versionen werden abgewiesen (`SchemaVersionException`), ältere laufen
  künftig durch `_migrateIfNeeded` — der Migrationshaken existiert bereits.
- **Reset:** `WorkspaceRepository.clear()` löscht den lokalen Bestand
  (nur für Tests/Debug, bewusst ohne UI); der nächste Start verhält sich wie
  ein Erststart.
- **Plattformen:** Web über Conditional Import
  (`persistence/persistence_database.dart`); auf Nicht-Web-Plattformen gibt
  es noch kein Backend → sauberer Fallback auf `LocalWorkspaceRepository`.
- **Grenzen:** Die Daten sind an Gerät + Browser(-Profil) gebunden. Kein
  Sync zwischen Geräten, kein Backup; „Website-Daten löschen" im Browser
  entfernt den Bestand. Echte Cloud-Synchronisation kommt erst mit dem
  `RemoteWorkspaceRepository`.

## Dependency-Auflösung

`lib/app/app_dependencies.dart` ist die Composition Root: der einzige Ort, an
dem konkrete Implementierungen gewählt und verdrahtet werden
(`AppDependencies.local()` → `TenantContext` → Repository → `AppState`).
Keine globalen Singletons, keine Service Locators; alles wird per Konstruktor
durchgereicht. Tests können `AppState` oder Repositories direkt mit eigenen
Abhängigkeiten konstruieren.

## Zukünftiger Austausch gegen Cloud

1. Neue Klasse, z. B. `RemoteWorkspaceRepository implements
   WorkspaceRepository` (REST/Supabase/Firebase), gescoped über den
   `TenantContext`. Der lokale IndexedDB-Bestand kann dabei als
   Offline-Cache weiterleben (local-first, Sync im Hintergrund) — das
   Schreibmodell (synchroner Snapshot + Write-Queue) ist dafür ausgelegt.
2. Neue Factory in der Composition Root, z. B.
   `AppDependencies.remote(session)`.
3. `main.dart` wählt die Factory. Screens, Widgets, Router, Services und
   Calculators bleiben unverändert.

## Empfohlene Reihenfolge

1. **Repository** — ✅ umgesetzt.
2. **Persistenz** — ✅ umgesetzt (lokal, IndexedDB; Cloud folgt mit dem
   Remote-Repository).
3. **Auth** — Login-Session erzeugt den echten `TenantContext`; Repositories
   sind bereits kontextgebunden.
4. **Bot Runtime** — LLM + Retrieval über die geprüfte Wissensbasis, als
   Service hinter eigener Schnittstelle; unbeantwortete Fragen fließen in den
   Human-Review-Queue.
5. **Billing** — Pläne/Limits pro Tenant, ansetzbar am `TenantContext`.
