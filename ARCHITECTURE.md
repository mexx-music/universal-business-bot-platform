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

Unabhängig davon (noch nicht in `AppState` verdrahtet):

- `runtime/` — Knowledge Runtime: Retrieval + Ranking + Antwortkontext,
  siehe unten.
- `recommendations/` — Next Best Actions Engine: die zentrale
  Empfehlungslogik des Unternehmensbegleiters, siehe unten.

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
- **Schema-Version:** aktuell `2`, im `meta`-Record gespeichert
  (v1 → v2: `actionRecords` am Workspace; alte Daten laden unverändert,
  die Migration stempelt nur die Version um). Neuere Versionen werden
  abgewiesen (`SchemaVersionException`), ältere laufen durch
  `_migrateIfNeeded`.
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

## Knowledge Runtime (`lib/runtime/`)

Die Runtime beantwortet keine Fragen — sie baut aus einer Benutzerfrage und
einem Workspace einen **strukturierten Antwortkontext**, den später jeder
Antwortgenerator (LLM, Template-Engine, Bot-Widget) konsumieren kann. Pure
Business-Logik: keine UI, keine API, keine KI, keine Seiteneffekte.

```
userQuestion + CompanyWorkspace
        │
KnowledgeRetriever      Normalisierung, Stoppwörter, einfache Synonyme;
        │               sucht in Wissenseinträgen (inkl. FAQ), Quellen,
        │               beantworteten Human-Review-Logs und Bot-Regeln
        ▼
KnowledgeRanking        Beispielheuristiken (0–100 je Treffer):
        │               Titel 35 · Schlagwörter 25 · Inhalt 15 ·
        │               Kategorie 5 · Review-Bestätigung 10 ·
        │               Aktualität 5 · Risikostufe Grün 5
        ▼
KnowledgeRuntime        Confidence, Begründung, fehlende Begriffe,
        │               offene Fragen, Gap-Erkennung
        ▼
KnowledgeAnswerContext  Top-Einträge, Top-Quellen, Confidence (0–100),
                        Begründung, Lücken, blockierte Themen, KnowledgeGap?
```

- **Confidence:** `TopScore × 0,65 + Termabdeckung × 25 + Korroboration
  (max. 10) + Review-Bonus (5)`, gedeckelt auf 25 %, wenn nur gesperrtes
  Wissen passt oder ein `blockedTopic` berührt wird. Stufen: ≥ 70 gut
  abgesichert, 40–69 teilweise, < 40 kaum Wissen.
- **KnowledgeGap:** entsteht unter 40 % Confidence; enthält Frage, Grund und
  fehlende Begriffe. `KnowledgeGap.toBotQuestionLog()` mappt bereits auf das
  bestehende Human-Review-Modell (offener Log, `noMatch`/`lowConfidence`),
  sodass ein späterer Block Gaps ohne Modelländerung in den Review-Queue
  übernehmen kann. Noch keine UI dafür.
- **Rote Einträge** (gesperrtes Wissen) bleiben als Treffer sichtbar
  (`restricted: true`), zählen aber nicht als beantwortbar —
  `requiresHumanHandover` signalisiert die Übergabe.

**Späterer Anschluss:** Die Bot Runtime ruft `buildContext()` auf und
entscheidet anhand von Confidence/Handover, ob geantwortet, eskaliert oder
ein Gap in den Human-Review-Queue geschrieben wird. Ein LLM erhält den
Kontext (Top-Einträge + Regeln) als Grounding-Material und formuliert nur
noch; das Retrieval bleibt deterministisch und prüfbar.

## Next Best Actions Engine (`lib/recommendations/`)

Das Herz des Unternehmensbegleiters: berechnet pro Workspace die **3–5
aktuell wichtigsten Maßnahmen** — deterministisch, erklärbar, ohne KI und
ohne Seiteneffekte.

```
CompanyWorkspace (+ injizierbares now)
        │
Kandidaten-Builder      je Regel eine mögliche Maßnahme, direkt aus den
        │               vorhandenen Daten: Intake-Status, Firmenprofil,
        │               offene Reviews, Quellen, FAQ-/Wissensstand,
        │               Audit-Bereiche (Website, Social, Vertrauen),
        │               Bot-Reife, Marketing- und Strategie-Snapshots
        ▼
Scoring                 Priorität (critical 400 / high 300 / medium 200 /
        │               low 100) + Impact (30/20/10) + Quick-Win-Bonus für
        │               geringen Aufwand (15/8/0) + Situations-Dringlichkeit
        │               (0–25, z. B. Anzahl offener Reviews)
        ▼
Top 3–5 NextBestActions sortiert nach Score, Ties deterministisch nach Typ
```

- **Kein Blackbox-Ranking:** Jede `NextBestAction` trägt `ActionReason`s —
  je eine menschenlesbare Begründung plus den konkreten Datenpunkt
  (`botLogs: 4× reviewStatus=open`). Der Score ist am Objekt sichtbar.
- **Modelle:** `NextBestAction`, `ActionReason`, `ActionPriority`,
  `ActionEffort`, `ActionImpact`; betroffene Bereiche über das bestehende
  `BusinessGoalArea`. `NextBestActionType` gibt jeder Empfehlung eine
  stabile Identität, `NextBestActionStatus`
  (proposed/accepted/deferred/rejected/completed) bereitet den späteren
  Annehmen/Verschieben/Ablehnen/Abschließen-Flow vor — bewusst noch ohne UI.
- **Entscheidungslogik (Beispiele):** Red-Flag-Reviews oder ≥ 5 offene
  Reviews → critical; Bot-Aktivierung wird erst empfohlen, wenn Wissensbasis
  (≥ 10 Einträge), Audit-Score (≥ 60 %) und Review-Lage reif sind;
  Marketing „starten" bei null laufenden Maßnahmen, „fokussieren" bei ≥ 4
  parallelen; junge Workspaces bekommen zuerst Intake/Profil/FAQ.
- **Bewusst nicht konsumiert:** die BI-Snapshot-Views — sie sind an die
  Wanduhr gebundene Ableitungen derselben Primärdaten; die Engine liest die
  Primärdaten direkt und bleibt dadurch mit injiziertem `now` vollständig
  deterministisch.

**Anschluss (umgesetzt in Block 20):** Der Screen `/next-actions` („Meine
nächsten Schritte") rendert den Plan; ein LLM kann Begründungen später in
Beratersprache umformulieren — die Entscheidung, *was* empfohlen wird,
bleibt regelbasiert und testbar.

## Action Lifecycle & Unternehmensgedächtnis

Zentrale Unterscheidung: **Empfehlungen werden berechnet, Entscheidungen
werden persistiert.** Die Engine bleibt zustandslos; gespeichert wird nur,
was der Nutzer entschieden hat und was daraus wurde.

- **`ActionRecord`** (`lib/models/action_record.dart`, Teil des Workspace,
  Schema v2): Entscheidung + Historie einer Maßnahme — Status
  (`suggested/accepted/inProgress/completed/deferred/declined`), Zeitpunkte,
  Ablehnungsgrund, Ergebnisbewertung (`helpedALot … notYetRatable`),
  Ergebnis-/Kennzahlnotiz, Wiederholungswunsch. `titleSnapshot`/
  `descriptionSnapshot` frieren den Wortlaut der Empfehlung ein;
  `sourceReasonKeys` friert die Evidenz ein.
- **`ActionLifecycleService`** (`lib/services/`): pure Mutationen
  (annehmen, verschieben, ablehnen, beginnen, abschließen, bewerten);
  `AppState` delegiert nur. Entscheidungen auf eine Empfehlung erzeugen
  einen neuen Record; Übergänge (beginnen → abschließen → bewerten)
  aktualisieren den offenen Record.
- **Engine × Historie** (`recommendPlan`): angenommene/laufende Maßnahmen
  werden nicht doppelt vorgeschlagen; verschobene ruhen bis `deferredUntil`;
  abgelehnte kehren nur zurück, wenn sich die Datenlage wesentlich geändert
  hat (aktuelle Evidenz ≠ eingefrorene `sourceReasonKeys`); erfolglose
  brauchen ebenfalls neue Evidenz; erfolgreiche dürfen nach 90 Tagen
  Cooldown als Wiederholung zurückkehren (außer der Nutzer wünschte keine).
  Jede Unterdrückung landet erklärt in `NextBestActionPlan.suppressed`,
  jede Wiederempfehlung trägt einen zusätzlichen `ActionReason` — keine
  Blackbox.
- **Human Intelligence:** Die Plattform schlägt vor, der Mensch entscheidet,
  die Plattform merkt es sich. Wirkungserfassung beim Abschluss („Hat die
  Maßnahme geholfen?") ist bewusst einfach und ehrlich — eine
  Selbsteinschätzung, keine Kausalitätsbehauptung.
- **UI:** `/next-actions` zeigt max. 3–5 Karten (Titel, Warum jetzt?,
  Nutzen/Aufwand/Priorität, Datengrundlage, Aktionen) plus
  Maßnahmenhistorie; das Dashboard zeigt nur einen Teaser (wichtigste
  Maßnahme, laufende, zu bewertende).

## Companion-Rhythmus: Monats-Check-in

Der Begleiter ist ein Ritual, kein Dashboard: In regelmäßigen, kurzen
Check-ins blickt der Unternehmer zurück und bestätigt die nächsten Schritte.

- **`CompanionCheckIn`** (`lib/models/companion_check_in.dart`, Teil des
  Workspace, Schema v3): ein persistierter Zeitpunkt im
  Unternehmensgedächtnis — Zeitraum, Zusammenfassung, abgeschlossene/
  laufende/unbewertete Maßnahmen, positive und negative gemeldete
  Ergebnisse, Erkenntnisse, eigene Beobachtungen, bestätigte nächste
  Schritte, `dataConfidence` (low/medium/high) und `needsHumanReview`.
  **Abgeschlossene Check-ins sind unveränderlich** — der Service ignoriert
  jede spätere Mutation; die Historie bleibt vertrauenswürdig.
- **`CompanionCheckInGenerator`** (`lib/services/`): pure, deterministische
  Erzeugung des Check-in-Inhalts aus Workspace + Zeitraum +
  Next-Best-Actions-Plan. Keine Mutationen.
- **`CheckInService`** (`lib/services/`): Start (Zeitraum = Ende des letzten
  Check-ins bis heute), Notizen, Abschluss (Inhalt wird beim Abschluss aus
  dem aktuellen Datenstand neu eingefroren — nachgeholte Bewertungen aus
  Schritt 2 sind enthalten), Überspringen. Die **Kadenz ist ein Parameter**
  (`interval`, Default 30 Tage) — wöchentlich/quartalsweise/manuell sind
  architektonisch möglich, bewusst ohne Einstellungs-UI.
- **Ehrliche Wirkungssprache:** Alle Ergebnisaussagen sind Beobachtungen
  („Nach dieser Maßnahme wurde ein positiver Effekt gemeldet. Es ist noch
  nicht sicher, ob die Veränderung durch diese Maßnahme verursacht
  wurde."), nie Kausalbehauptungen. `dataConfidence` macht die Datenbasis
  sichtbar; Kausalaussagen bleiben echten Messdaten vorbehalten, die es
  noch nicht gibt. Der Unterschied zwischen *Beobachtung* und *bewiesener
  Wirkung* ist Teil des Produkts, nicht nur der Doku.
- **Human Intelligence:** Bei widersprüchlichen Ergebnissen, niedriger
  Confidence, offenen Red-Flag-Reviews oder ≥ 2 unbewerteten Maßnahmen wird
  `needsHumanReview = true` gesetzt; das UI formuliert nur: „Eine kurze
  menschliche Prüfung wäre sinnvoll." Keine neue Review-Infrastruktur.
- **UI:** `/check-in` — sechs geführte Schritte mit Fortschritt (Überblick →
  Bewertungen nachholen → geholfen/nicht geholfen → eigene Beobachtungen →
  nächste drei Schritte → Abschluss) plus Historie früherer Check-ins. Das
  Dashboard zeigt kompakt letzten/nächsten Check-in und den Start-Button.

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
