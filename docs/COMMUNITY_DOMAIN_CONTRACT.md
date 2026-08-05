# Community / Human Intelligence Network — Domänenvertrag (Entwurf)

> **Status:** Entwurf, nicht implementiert, nicht committet. Rein dokumentarisch.
> Beschreibt den Ist-Stand der Domäne nach CR-1 + CR-2 (read-only, lokal) und
> markiert, was noch nicht durchgesetzt wird. Quelle der Wahrheit ist der Code
> unter `lib/community/`. Bei Abweichung gilt der Code; dieses Dokument ist bei
> Änderungen nachzuziehen.

Geltungsbereich: erste Domäne `communityEngagement` des künftigen
**Human Intelligence Network** (später auch Produkttests, Ideenforschung,
Übersetzungen). Members sind ein **globaler, firmenunabhängiger Pool**.
`CompanyWorkspace`/`WorkspaceCodec` sind bewusst unberührt.

---

## 1. Enums (alle Werte)

`lib/community/models/community_enums.dart`

| Enum | Werte | Bedeutung |
|---|---|---|
| `HumanIntelligenceDomain` | `communityEngagement`, `productTest`, `ideaResearch`, `translation`, `other` | Dienst-Domäne einer Aufgabe. CR-1/CR-2 nutzen nur `communityEngagement`; Rest ist Erweiterungspunkt. |
| `CommunityPlatform` | `reddit`, `facebookGroup`, `forum`, `instagram`, `x`, `youtube`, `other` | Öffentliche Plattform des Beitrags/Profils. |
| `ContentIntent` | `question`, `complaint`, `recommendationRequest`, `discussion`, `comparison`, `experienceShare`, `other` | Von der KI erkannte Absicht (rein deskriptiv). |
| `ContentSentiment` | `positive`, `neutral`, `negative`, `mixed` | Stimmung des Beitrags. |
| `ContentStatus` | `newContent`, `reviewing`, `matched`, `taskCreated`, `actioned`, `dismissed` | Lebenszyklus eines Beitrags im Radar. |
| `CommunityActionType` | `viewOnly`, `like`, `share`, `repost`, `shortPersonalComment`, `personalExperience`, `factualAnswer`, `askFollowUpQuestion`, `openOriginal`, `skip` | Freiwillige Reaktionsart. Wird **nie** automatisch ausgeführt. |
| `CommunityTaskStatus` | `open`, `offered`, `accepted`, `declined`, `completed`, `expired` | Lebenszyklus einer freiwilligen Aufgabe. |
| `MemberStatus` | `active`, `pending`, `paused`, `blocked` | Status eines Mitglieds im Pool. |

`lib/community/models/profile_match.dart`

| Enum | Werte | Bedeutung |
|---|---|---|
| `MatchFactor` | `language`, `country`, `topic`, `experience`, `platform`, `publicActivity`, `preferredAction` | Bewertbare Score-Komponente. |
| `MatchWarning` | `noExperience`, `notOnPlatform`, `lowAuthenticity`, `profileAnalysisNoConsent` | Weicher Hinweis (kein Ausschluss). |
| `MatchBlock` | `companyExcluded`, `topicExcluded`, `unavailable`, `accountBlocked`, `domainUnsupported` | Harter Ausschlussgrund. |

---

## 2. Modelle (Feld · Typ · Nullbarkeit · Bedeutung)

Nullbarkeit: **required** = im Konstruktor Pflicht; **default X** = optional mit
Vorgabe; **nullable** = `?`-Typ, darf null sein.

### `DiscoveredContent` — `discovered_content.dart` (firmenbezogen via `companyId`)
| Feld | Typ | Nullbarkeit | Bedeutung |
|---|---|---|---|
| `id` | `String` | required | Stabile ID (`dc-…`). |
| `companyId` | `String` | required | Firma, für die der Beitrag relevant ist. |
| `platform` | `CommunityPlatform` | required | Herkunftsplattform. |
| `sourceUrl` | `String` | required | Öffentliche Quelle (Demo: `example.invalid`). |
| `title` | `String` | required | Titel/Kurzfassung. |
| `originalText` | `String` | required | Originalwortlaut. |
| `language` | `String` | required | ISO-639-1 (`de`/`en`). |
| `country` | `String` | required | ISO-3166-1 alpha-2 (`DE`/`AT`/`US`…). |
| `topicTags` | `List<String>` | required | Themen-Tokens (lowercase-Vergleich). |
| `detectedIntent` | `ContentIntent` | required | Erkannte Absicht. |
| `sentiment` | `ContentSentiment` | required | Stimmung. |
| `relevanceScore` | `int` | required | 0–100, Relevanz für die Firma. |
| `riskLevel` | `RiskLevel` | required | Wiederverwendetes App-Enum (green/yellow/red). |
| `discoveredAt` | `DateTime` | required | Fundzeitpunkt. |
| `status` | `ContentStatus` | required | Radar-Status. |
| `recommendedActionTypes` | `List<CommunityActionType>` | required | Von der KI **vorgeschlagene** Aktionen (nie ausgeführt). |
| `aiSummary` | `String` | default `''` | Neutrale KI-Zusammenfassung. |
| `relevanceReason` | `String` | default `''` | Sachliche Relevanzbegründung. |
| `riskNotes` | `List<String>` | default `const []` | Risiko-Hinweise. |
| `prohibitedClaims` | `List<String>` | default `const []` | Gesperrte Aussagen (Compliance-Guard, später erzwungen). |
| `relatedKnowledgeEntryIds` | `List<String>` | default `const []` | Referenzen auf `KnowledgeEntry.id` (Titel read-only aufgelöst). |

Methoden: `copyWith({ContentStatus? status})`.

### `MemberPlatformProfile` — `community_member.dart`
| Feld | Typ | Nullbarkeit | Bedeutung |
|---|---|---|---|
| `platform` | `CommunityPlatform` | required | Plattform. |
| `handle` | `String` | required | Anzeige-Handle (Demo: fiktiv). |

### `CommunityMember` — `community_member.dart` (globaler Pool, **keine** `companyId`)
| Feld | Typ | Nullbarkeit | Bedeutung |
|---|---|---|---|
| `id` | `String` | required | Stabile ID (`m-…`). |
| `displayName` | `String` | required | Anzeigename. |
| `country` | `String` | required | ISO-3166-1 alpha-2. |
| `languages` | `List<String>` | required | ISO-639-1 Codes. |
| `platformProfiles` | `List<MemberPlatformProfile>` | required | Plattform-Handles. |
| `declaredInterests` | `List<String>` | required | Freiwillig angegebene Interessen. |
| `verifiedTopics` | `List<String>` | required | Verifizierte Themen. |
| `publicActivityTopics` | `List<String>` | required | Öffentlich besprochene Themen — **nur mit Einwilligung nutzbar**. |
| `writingStyle` | `String` | required | Schreibstil (deskriptiv). |
| `experienceCategories` | `List<String>` | required | Kategorien eigener Erfahrung. |
| `isVerified` | `bool` | required | Verifizierungs-Flag. |
| `accountAuthenticityScore` | `int` | required | 0–100 **neutrales Signal** — kein Glaubwürdigkeitsurteil. |
| `qualityScore` | `int` | required | 0–100 Qualität bisheriger Aufgaben. |
| `availability` | `String` | required | Freitext-Verfügbarkeit (Anzeige). |
| `compensationEnabled` | `bool` | required | Vergütung grundsätzlich möglich. |
| `disclosureRequirements` | `List<String>` | required | Offenlegungspflichten. |
| `status` | `MemberStatus` | required | Pool-Status. |
| `completedTaskCount` | `int` | default `0` | Erledigte Aufgaben. |
| `preferredActions` | `List<CommunityActionType>` | default `const []` | Bevorzugte Aufgabenarten. |
| `supportedDomains` | `List<HumanIntelligenceDomain>` | default `[communityEngagement]` | Bediente Domänen. |
| `excludedTopics` | `List<String>` | default `const []` | **Harter Ausschluss** bei Themenüberschneidung. |
| `excludedCompanyIds` | `List<String>` | default `const []` | **Harter Ausschluss** je Firma. |
| `profileAnalysisConsent` | `bool` | default `true` | Einwilligung zur Analyse öffentlicher Aktivität. |
| `isAvailable` | `bool` | default `true` | **Harter Gate**: aktuell verfügbar. |

Getter: `platforms` → `Set<CommunityPlatform>`.

### `MatchComponent` — `profile_match.dart`
| Feld | Typ | Nullbarkeit | Bedeutung |
|---|---|---|---|
| `factor` | `MatchFactor` | required | Faktor. |
| `matched` | `bool` | required | Erfüllt? |
| `points` | `int` | required | Erzielte Punkte. |
| `maxPoints` | `int` | required | Maximalpunkte des Faktors. |
| `detail` | `String?` | nullable | Getroffenes Token (nur Anzeige). |

### `MatchBlockReason` — `profile_match.dart`
| Feld | Typ | Nullbarkeit | Bedeutung |
|---|---|---|---|
| `reason` | `MatchBlock` | required | Ausschlussgrund. |
| `detail` | `String?` | nullable | Detail-Token (z. B. ausgeschlossenes Thema). |

### `ProfileMatch` — `profile_match.dart` (verbindet Member × Content)
| Feld | Typ | Nullbarkeit | Bedeutung |
|---|---|---|---|
| `id` | `String` | required | `pm-{contentId}-{memberId}`. |
| `memberId` | `String` | required | Mitglied. |
| `contentId` | `String` | required | Beitrag. |
| `overallMatchScore` | `int` | required | 0–100, Summe der Komponentenpunkte. |
| `eligible` | `bool` | required | Für Zuweisung geeignet? `false` bei hartem Ausschluss. |
| `components` | `List<MatchComponent>` | required | Vollständige Faktoren-Aufschlüsselung. |
| `warnings` | `List<MatchWarning>` | default `const []` | Hinweise. |
| `blockReasons` | `List<MatchBlockReason>` | default `const []` | Harte Ausschlüsse. |
| `disclosureRequired` | `bool` | default `false` | Offenlegung nötig. |
| `possibleActions` | `List<CommunityActionType>` | default `const []` | Auf der Plattform zulässige Aktionen. |

Getter: `matchedComponents` → nur erfüllte Komponenten.

### `CommunityTask` — `community_task.dart` (Member × Content × Company)
| Feld | Typ | Nullbarkeit | Bedeutung |
|---|---|---|---|
| `id` | `String` | required | `ct-…`. |
| `contentId` | `String` | required | Zugehöriger Beitrag. |
| `companyId` | `String` | required | Auftraggeber-Firma. |
| `domain` | `HumanIntelligenceDomain` | default `communityEngagement` | Netzwerk-Domäne. |
| `assignedMemberId` | `String?` | nullable | Zugewiesenes Mitglied. |
| `allowedActions` | `List<CommunityActionType>` | required | Erlaubte Aktionen (Teilmenge der Plattform-Regeln). |
| `guidance` | `String` | required | Richtungsangabe (eigene Worte, keine identischen Massenkommentare). |
| `prohibitedClaims` | `List<String>` | default `const []` | Verbotene Aussagen. |
| `disclosureRequired` | `bool` | default `false` | Offenlegungspflicht. |
| `compensation` | `String?` | nullable | Vergütungslabel (`null` = unvergütet). |
| `deadline` | `DateTime?` | nullable | Frist. |
| `status` | `CommunityTaskStatus` | required | Aufgabenstatus. |
| `acceptedAt` | `DateTime?` | nullable | Annahmezeitpunkt. |
| `completedAt` | `DateTime?` | nullable | Abschlusszeitpunkt. |
| `completionNote` | `String?` | nullable | Abschlussnotiz. |

Getter: `isPaid` (compensation gesetzt & nicht leer), `isOpen` (`open`/`offered`).

### `HumanActionReport` — `human_action_report.dart` (Audit-Trail je Aufgabe)
| Feld | Typ | Nullbarkeit | Bedeutung |
|---|---|---|---|
| `id` | `String` | required | `har-…`. |
| `taskId` | `String` | required | Zugehörige Aufgabe. |
| `actionType` | `CommunityActionType` | required | Durchgeführte Aktion. |
| `performedBy` | `String` | required | Mitglieds-ID. |
| `performedAt` | `DateTime` | required | Zeitpunkt. |
| `originalPlatformUrl` | `String?` | nullable | Link zur echten Aktion. |
| `selfWrittenText` | `String?` | nullable | Selbst verfasster Text. |
| `wasEditedFromGuidance` | `bool` | default `false` | Text von Vorgabe abgewandelt (erwünscht). |
| `disclosureUsed` | `bool` | default `false` | Offenlegung tatsächlich enthalten. |
| `resultStatus` | `String` | default `'submitted'` | Ergebnisstatus. |
| `moderationNotes` | `String?` | nullable | Moderationsnotiz. |

---

## 3. Plattformabhängige Aktionsregeln

`platformAllowedActions` + immer verfügbar: `openOriginal`, `skip`
(via `allowedActionsFor(platform)`).

| Plattform | Zusätzlich erlaubte Aktionen |
|---|---|
| `reddit` | viewOnly, like, shortPersonalComment, personalExperience, factualAnswer, askFollowUpQuestion |
| `facebookGroup` | viewOnly, like, share, shortPersonalComment, personalExperience, factualAnswer, askFollowUpQuestion |
| `forum` | viewOnly, personalExperience, factualAnswer, askFollowUpQuestion |
| `instagram` | viewOnly, like, shortPersonalComment |
| `x` | viewOnly, like, repost, shortPersonalComment, askFollowUpQuestion |
| `youtube` | viewOnly, like, shortPersonalComment |
| `other` | viewOnly |

Helfer: `allowedActionsFor(platform)` (inkl. openOriginal/skip),
`isActionAllowedOn(platform, action)`.
**Invariante:** `recommendedActionTypes` eines Beitrags müssen auf seiner
Plattform zulässig sein (durch Test erzwungen).

---

## 4. Matching-Gewichte

`CommunityMatchingService`, weiche Faktoren summieren zu **100**:

| Faktor | Max-Punkte | Erfüllt wenn |
|---|---|---|
| `language` | 25 | `content.language` ∈ `member.languages` |
| `topic` | 20 | Überschneidung `topicTags` ∩ (`declaredInterests` ∪ `verifiedTopics`) |
| `platform` | 15 | `content.platform` ∈ `member.platforms` |
| `experience` | 15 | Überschneidung `topicTags` ∩ `experienceCategories` |
| `country` | 10 | `member.country` == `content.country` |
| `publicActivity` | 10 | **nur mit Einwilligung**: Überschneidung `topicTags` ∩ `publicActivityTopics` |
| `preferredAction` | 5 | `member.preferredActions` ∩ `content.recommendedActionTypes` ≠ ∅ |

- Alle Token-Vergleiche case-insensitive, Überschneidung deterministisch
  (erstes Token in Iterationsreihenfolge als `detail`).
- `overallMatchScore` = Summe erzielter Punkte (0–100).
- Punkte werden auch bei Ineligibilität berechnet (zur Anzeige), aber der
  Kandidat bleibt `eligible = false`.

**Reihenfolge (deterministisch):** eligible zuerst → Score absteigend →
`memberId` aufsteigend (Tiebreak).

---

## 5. Harte Ausschlussregeln (`eligible = false`)

Erzeugen je einen `MatchBlockReason`:

| Grund (`MatchBlock`) | Bedingung |
|---|---|
| `accountBlocked` | `member.status == blocked` |
| `unavailable` | `!member.isAvailable` **oder** `member.status == paused` |
| `companyExcluded` | `content.companyId` ∈ `member.excludedCompanyIds` (detail = companyId) |
| `topicExcluded` | `content.topicTags` ∩ `member.excludedTopics` ≠ ∅ (detail = Thema) |
| `domainUnsupported` | `communityEngagement` ∉ `member.supportedDomains` |

Ausgeschlossene Mitglieder werden **nie** für eine Zuweisung vorgeschlagen,
unabhängig vom Score. Es gibt kein automatisches Zuweisen.

---

## 6. Einwilligungsregeln

- `profileAnalysisConsent == false` ⇒ Faktor `publicActivity` wird **nicht**
  berechnet (0 Punkte, `detail == null`), d. h. **keine öffentlichen
  Profildaten werden verwendet**.
- Kein harter Block — das Mitglied bleibt matchbar über deklarierte Interessen,
  Erfahrung etc.
- Zusätzlich Warnung `profileAnalysisNoConsent`.
- Öffentliche Aktivität darf nur analysiert werden, wenn technisch, rechtlich
  und plattformseitig zulässig **oder** ausdrücklich eingewilligt.

Weiche Warnungen (`MatchWarning`), kein Ausschluss:
`notOnPlatform` (Plattform fehlt), `noExperience` (keine Themen-/Erfahrungs-
Überschneidung), `lowAuthenticity` (`accountAuthenticityScore` < 70),
`profileAnalysisNoConsent`.

---

## 7. Statusübergänge (Stand: definiert, noch nicht erzwungen)

CR-1/CR-2 sind read-only; die folgenden Übergänge sind das **beabsichtigte**
Modell für CR-3+ und werden noch nicht durch Code durchgesetzt.

- **`ContentStatus`:** `newContent → reviewing → matched → taskCreated →
  actioned`; aus jedem Zustand `→ dismissed`.
- **`CommunityTaskStatus`:** `open → offered → accepted → completed`;
  Abzweige `→ declined` (jederzeit durch Mitglied, ohne Begründung),
  `→ expired` (nach `deadline`). `accepted` setzt `acceptedAt`, `completed`
  setzt `completedAt` (+ optional `completionNote` und einen
  `HumanActionReport`).
- **`MemberStatus`:** `pending → active`; `active ↔ paused`; `→ blocked`
  (administrativ). `paused`/`blocked` wirken als harte Gates im Matching.

---

## 8. Compliance-Regeln (kanonisch)

1. **Keine automatische Veröffentlichung** — die KI führt nie eine Aktion aus.
2. **Mensch entscheidet** — freiwillige Teilnahme; Ablehnung jederzeit ohne
   Begründung möglich.
3. **Keine Fake-Profile, keine erfundene Erfahrung.** Matching nennt nur
   Fakten; nie ein Urteil „glaubwürdig/unglaubwürdig". Scores sind neutrale
   Signale.
4. **Keine Heil-/Erfolgsversprechen; keine erfundene Produkterfahrung.**
   `prohibitedClaims` (Beitrag und Aufgabe) definieren gesperrte Aussagen;
   Durchsetzung als Guard folgt in CR-3.
5. **Offenlegung:** `disclosureRequired` (Aufgabe) und
   `member.disclosureRequirements`; tatsächliche Nutzung wird im
   `HumanActionReport.disclosureUsed` protokolliert.
6. **Keine identischen Massenkommentare** — `guidance` fordert eigene Worte;
   `wasEditedFromGuidance` dokumentiert die Abwandlung.
7. **Vergütung ist nie an eine positive Aussage gekoppelt** — bezahlt wird
   ausschließlich für eine zulässige, echte, ordnungsgemäß ausgeführte Aufgabe.
8. **Ausschlüsse sind harte Sperren** (Firma/Thema/Verfügbarkeit/Status/Domäne).
9. **Einwilligung vor Profilanalyse** (siehe §6).
10. **Plattformregeln beachten** — nur plattformzulässige Aktionen.
11. **Audit-Trail:** jede menschliche Aktion wird als `HumanActionReport`
    dokumentiert.

---

## 9. Nur in der Hauptplattform (firmen-/betreiberseitig)

Diese Typen und Felder bleiben in der Betreiber-App und dürfen **nicht** an
Teilnehmer gelangen:

- `DiscoveredContent` inkl. `relevanceScore`, `aiSummary`, `relevanceReason`,
  `riskNotes`, `status` (interne Analyse).
- `CommunityMember` als Vollprofil des Pools — insbesondere
  `accountAuthenticityScore`, `qualityScore`, `verifiedTopics`,
  `excludedTopics`, `excludedCompanyIds`, `profileAnalysisConsent`,
  `publicActivityTopics` **anderer** Mitglieder.
- `ProfileMatch`, `MatchComponent`, `MatchBlockReason`, `MatchFactor`,
  `MatchWarning`, `MatchBlock` — die Matching-/Ranking-Interna über den
  gesamten Pool.
- `CommunityMatchingService` (Engine) und `CommunityRepository` (Pool-Zugriff).
- `ContentStatus`, `ContentIntent`, `ContentSentiment`.

Grund: Datenschutz und Nichtdiskriminierung — ein Teilnehmer sieht nie die
Bewertung anderer Personen oder interne Relevanz-/Risiko-Scores.

---

## 10. Von der Teilnehmer-App zu übernehmen (gemeinsamer Kern)

Diese Typen bilden den Vertrag zwischen Hauptplattform und Teilnehmer-App
(CR-4). Der Teilnehmer sieht ausschließlich **seine eigene** Aufgabe:

- `CommunityTask` — die angebotene Aufgabe inkl. `guidance`, `allowedActions`,
  `prohibitedClaims`, `disclosureRequired`, `compensation`, `deadline`,
  `status`, `domain`.
- `CommunityActionType` — Auswahl der Reaktionsart.
- `HumanActionReport` — Rückmeldung des Teilnehmers (eigener Text, Link,
  Offenlegung genutzt).
- `HumanIntelligenceDomain` — Art des Dienstes.
- `CommunityTaskStatus` — Übergänge Annehmen/Ablehnen/Abschließen.
- Ein **reduzierter** Ausschnitt des zugehörigen `DiscoveredContent`
  (Originaltext, Quelle, Plattform, Sprache) — ohne interne Analysefelder.
- Ein **reduziertes** eigenes Profil (eigene Sprachen/Interessen/Verfügbarkeit)
  — nicht das Vollprofil mit Scores.

Nicht an die Teilnehmer-App: alles aus §9 (fremde Profile, Pool-Matching,
Scores, interne Analyse).

---

## Offene Punkte (für spätere Blöcke)

- Durchsetzung der Statusübergänge und `prohibitedClaims` (CR-3, Task-Mutationen
  + Compliance-Guards).
- Themen-/Erfahrungs-Vokabular: Matching vergleicht Tokens exakt
  (case-insensitive); Synonym-/Normalisierungslogik ist noch offen.
- Persistenz/Remote und Teilnehmer-App (CR-4/CR-5) — bisher rein lokal,
  read-only, ohne APIs.
