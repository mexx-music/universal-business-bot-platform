import '../models/company_knowledge_package.dart';

const _websiteSource = KnowledgePackageSource(
  id: 'healing-balance-website',
  nameDe: 'Healing-&-Balance-Website',
  nameEn: 'Healing & Balance website',
  type: KnowledgePackageSourceType.publicCompanyWebsite,
  dataStatusDe: 'Vorbereiteter Wettbewerbsdatensatz, August 2026',
  dataStatusEn: 'Prepared competition dataset, August 2026',
);

const _productSource = KnowledgePackageSource(
  id: 'hb-cure-product-docs',
  nameDe: 'Interne HB-Cure-Produktdokumentation',
  nameEn: 'Internal HB Cure product documentation',
  type: KnowledgePackageSourceType.confirmedProductDocumentation,
  dataStatusDe: 'Bestätigter interner Projektdatenstand, August 2026',
  dataStatusEn: 'Confirmed internal project data, August 2026',
);

const _supportSource = KnowledgePackageSource(
  id: 'hb-cure-support-docs',
  nameDe: 'Interne HB-Cure-Support-Dokumentation',
  nameEn: 'Internal HB Cure support documentation',
  type: KnowledgePackageSourceType.confirmedSupportDocumentation,
  dataStatusDe: 'Bestätigter interner Projektdatenstand, August 2026',
  dataStatusEn: 'Confirmed internal project data, August 2026',
);

final hbCureKnowledgePackage = CompanyKnowledgePackage(
  id: 'hb-cure-complete',
  titleDe: 'HB Cure – vollständiges Demo-Wissen',
  titleEn: 'HB Cure – complete demo knowledge',
  descriptionDe:
      'Lädt vorbereitete Unternehmens-, Produkt-, App-, Support- und '
      'Kontaktinformationen für eine vollständige BusinessBrain-Demonstration.',
  descriptionEn:
      'Loads prepared company, product, app, support, and contact information '
      'for a complete BusinessBrain demonstration.',
  includedAreasDe: const [
    'Unternehmen',
    'HB Cure Überblick',
    'H&B Cure App',
    'CureBase',
    'CureClip',
    'Programme',
    'Kennenlernangebot',
    'FAQ',
    'Support',
    'Kontakt',
  ],
  includedAreasEn: const [
    'Company',
    'HB Cure overview',
    'H&B Cure App',
    'CureBase',
    'CureClip',
    'Programs',
    'Trial offer',
    'FAQ',
    'Support',
    'Contact',
  ],
  documents: [
    KnowledgePackageDocument(
      id: 'company',
      areaDe: 'Unternehmen',
      areaEn: 'Company',
      documentTypeDe: 'Unternehmensinformation',
      documentTypeEn: 'Company information',
      source: _websiteSource,
      freshness: KnowledgePackageFreshness.timeSensitive(
        lastChecked: DateTime.utc(2026, 8, 3),
      ),
      contentDe: '''Healing & Balance GmbH ist das Unternehmen hinter HB Cure.
Der Unternehmenssitz befindet sich am Sparkassenplatz 2 in A-4690 Schwanenstadt.
Das Team bietet persönliche Unterstützung und Beratung bei Fragen zu HB Cure.
Healing & Balance ist per E-Mail an office@healing-balance.com und telefonisch unter +43 (0) 6606506900 erreichbar.''',
      contentEn: '''Healing & Balance GmbH is the company behind HB Cure.
The company is located at Sparkassenplatz 2, A-4690 Schwanenstadt, Austria.
The team provides personal support and guidance for questions about HB Cure.
Healing & Balance can be reached by email at office@healing-balance.com and by phone at +43 (0) 6606506900.''',
    ),
    const KnowledgePackageDocument(
      id: 'hb-cure-overview',
      areaDe: 'HB Cure Überblick',
      areaEn: 'HB Cure overview',
      documentTypeDe: 'Systemübersicht',
      documentTypeEn: 'System overview',
      source: _productSource,
      contentDe:
          '''HB Cure ist der Produkt- und Systembereich von Healing & Balance.
Zum HB-Cure-System gehören CureBase, CureClip und die H&B Cure App.
CureBase und CureClip werden gemeinsam mit der H&B Cure App verwendet.
Die H&B Cure App ermöglicht den Zugriff auf die verfügbaren Frequenzprogramme.''',
      contentEn:
          '''HB Cure is the product and system division of Healing & Balance.
The HB Cure system consists of CureBase, CureClip, and the H&B Cure App.
CureBase and CureClip are used together with the H&B Cure App.
The H&B Cure App provides access to the available frequency programs.''',
    ),
    const KnowledgePackageDocument(
      id: 'hb-cure-app',
      areaDe: 'H&B Cure App',
      areaEn: 'H&B Cure App',
      documentTypeDe: 'Bestätigte App-Dokumentation',
      documentTypeEn: 'Confirmed app documentation',
      source: _productSource,
      contentDe:
          '''Die H&B Cure App verbindet sich über Bluetooth mit kompatiblen Geräten.
Programme können über Kategorien oder die Suche ausgewählt werden.
Ein ausgewähltes Programm wird in der App gestartet.
Die App zeigt die Laufzeit und einen Timer für das laufende Programm an.
In der App können eigene Programme beziehungsweise eigene Frequenzen verwaltet werden.
Wenn ein Firmware-Update verfügbar ist, zeigt die App einen entsprechenden Hinweis.
Die App zeigt an, ob ein kompatibles Gerät verbunden ist.''',
      contentEn:
          '''The H&B Cure App connects to compatible devices through Bluetooth.
Programs can be selected by category or by using search.
A selected program is started in the app.
The app displays the runtime and a timer for the active program.
The app can manage custom programs or custom frequencies.
When a firmware update is available, the app displays a corresponding notice.
The app shows whether a compatible device is connected.''',
    ),
    const KnowledgePackageDocument(
      id: 'curebase',
      areaDe: 'CureBase',
      areaEn: 'CureBase',
      documentTypeDe: 'Bestätigte Produktbeschreibung',
      documentTypeEn: 'Confirmed product description',
      source: _productSource,
      contentDe:
          '''CureBase ist das stationäre beziehungsweise zentrale Gerät im HB-Cure-System.
CureBase wird über die H&B Cure App gesteuert.
Programme werden in der App ausgewählt und mit CureBase ausgeführt.''',
      contentEn:
          '''CureBase is the stationary or central device in the HB Cure system.
CureBase is controlled through the H&B Cure App.
Programs are selected in the app and run with CureBase.''',
    ),
    const KnowledgePackageDocument(
      id: 'cureclip',
      areaDe: 'CureClip',
      areaEn: 'CureClip',
      documentTypeDe: 'Bestätigte Produktbeschreibung',
      documentTypeEn: 'Confirmed product description',
      source: _productSource,
      contentDe:
          '''CureClip ist das mobile und flexible Gerät im HB-Cure-System.
CureClip kann zu Hause, im Beruf oder unterwegs verwendet werden.
Die Programmauswahl und Steuerung erfolgen über die H&B Cure App.''',
      contentEn:
          '''CureClip is the mobile and flexible device in the HB Cure system.
CureClip can be used at home, at work, or while traveling.
Programs are selected and controlled through the H&B Cure App.''',
    ),
    KnowledgePackageDocument(
      id: 'programs',
      areaDe: 'Programme',
      areaEn: 'Programs',
      documentTypeDe: 'Öffentliche Produktinformation',
      documentTypeEn: 'Public product information',
      source: _websiteSource,
      freshness: KnowledgePackageFreshness.timeSensitive(
        lastChecked: DateTime.utc(2026, 8, 3),
      ),
      contentDe:
          '''Die Healing-&-Balance-Website nennt über 2.500 strukturierte Frequenzprogramme.
Die Programme werden über die H&B Cure App ausgewählt.
Die Anzahl der Programme ist zeitabhängig und sollte vor einer Veröffentlichung erneut geprüft werden.
Aus der Programmanzahl wird keine medizinische Wirkung abgeleitet.''',
      contentEn:
          '''The Healing & Balance website lists more than 2,500 structured frequency programs.
Programs are selected through the H&B Cure App.
The number of programs is time-sensitive and should be checked again before publication.
No medical effect is inferred from the number of programs.''',
    ),
    KnowledgePackageDocument(
      id: 'trial-offer',
      areaDe: 'Kennenlernangebot',
      areaEn: 'Trial offer',
      documentTypeDe: 'Zeitabhängige Angebotsinformation',
      documentTypeEn: 'Time-sensitive offer information',
      source: _websiteSource,
      freshness: KnowledgePackageFreshness.timeSensitive(
        lastChecked: DateTime.utc(2026, 8, 3),
      ),
      contentDe:
          '''Für das 30-Tage-Kennenlernangebot wird CureBase oder CureClip ausgewählt.
Das ausgewählte Gerät kann 30 Tage zu Hause getestet werden.
Bei Fragen steht persönliche Unterstützung zur Verfügung.
Nach dem Testzeitraum entscheidet der Interessent selbst über das weitere Vorgehen.
Nach dem Testmonat besteht keine Kaufpflicht.
Ein Leihpreis oder eine Kaufanrechnung ist in diesem vorbereiteten Datensatz nicht bestätigt und wird deshalb nicht genannt.''',
      contentEn:
          '''For the 30-day trial offer, the customer selects CureBase or CureClip.
The selected device can be tested at home for 30 days.
Personal support is available for questions.
After the trial period, the interested person decides how to proceed.
There is no obligation to purchase after the trial month.
A rental price or purchase credit is not confirmed in this prepared dataset and is therefore not stated.''',
    ),
    const KnowledgePackageDocument(
      id: 'faq',
      areaDe: 'FAQ',
      areaEn: 'FAQ',
      documentTypeDe: 'Bestätigte häufige Fragen',
      documentTypeEn: 'Confirmed frequently asked questions',
      source: _supportSource,
      contentDe:
          '''Ist die Anwendung einfach? Die H&B Cure App führt durch Verbindung, Programmauswahl und Start.
Muss man sich mit Frequenzen auskennen? Die Programme sind in der App strukturiert und können über Kategorien oder die Suche ausgewählt werden.
Was passiert bei Fragen? Healing & Balance bietet persönliche Unterstützung und Beratung.
Muss anschließend gekauft werden? Nach dem 30-tägigen Kennenlernangebot besteht keine Kaufpflicht.
Was passiert, wenn ein Anwender subjektiv nichts wahrnimmt? Eine subjektive Wahrnehmung wird nicht als Nachweis einer Wirkung interpretiert und bei Fragen kann persönliche Unterstützung kontaktiert werden.''',
      contentEn:
          '''Is the application easy to use? The H&B Cure App guides users through connection, program selection, and starting a program.
Do users need prior knowledge about frequencies? Programs are structured in the app and can be selected by category or search.
What happens when users have questions? Healing & Balance provides personal support and guidance.
Is a purchase required afterward? There is no purchase obligation after the 30-day trial offer.
What happens if a user subjectively notices nothing? A subjective perception is not interpreted as proof of an effect, and personal support can be contacted for questions.''',
    ),
    const KnowledgePackageDocument(
      id: 'support',
      areaDe: 'Support',
      areaEn: 'Support',
      documentTypeDe: 'Bestätigte Support-Anleitung',
      documentTypeEn: 'Confirmed support guide',
      source: _supportSource,
      contentDe:
          '''Bei Verbindungsproblemen muss zuerst Bluetooth auf dem Smartphone aktiviert werden.
Wählen Sie anschließend das kompatible Gerät in der App aus und bestätigen Sie die Verbindung.
Prüfen Sie den Akkustand des Geräts und die Entfernung zwischen Gerät und Smartphone.
Ein Firmware-Update darf nicht unterbrochen werden.
Während eines Firmware-Updates müssen Gerät und Smartphone verbunden bleiben.
Das Gerät muss während des Firmware-Updates ausreichend geladen sein.''',
      contentEn:
          '''For connection problems, first enable Bluetooth on the smartphone.
Then select the compatible device in the app and confirm the connection.
Check the device battery level and the distance between the device and smartphone.
A firmware update must not be interrupted.
The device and smartphone must remain connected during a firmware update.
The device must remain sufficiently charged during a firmware update.''',
    ),
    KnowledgePackageDocument(
      id: 'contact',
      areaDe: 'Kontakt',
      areaEn: 'Contact',
      documentTypeDe: 'Öffentliche Kontaktinformation',
      documentTypeEn: 'Public contact information',
      source: _websiteSource,
      freshness: KnowledgePackageFreshness.timeSensitive(
        lastChecked: DateTime.utc(2026, 8, 3),
      ),
      contentDe:
          '''Healing & Balance GmbH ist am Sparkassenplatz 2 in A-4690 Schwanenstadt erreichbar.
Die Kontakt-E-Mail lautet office@healing-balance.com.
Die Telefonnummer lautet +43 (0) 6606506900.
Kontaktinformationen sind zeitabhängig und sollten vor einer Veröffentlichung erneut geprüft werden.''',
      contentEn:
          '''Healing & Balance GmbH can be reached at Sparkassenplatz 2, A-4690 Schwanenstadt, Austria.
The contact email address is office@healing-balance.com.
The phone number is +43 (0) 6606506900.
Contact details are time-sensitive and should be checked again before publication.''',
    ),
    const KnowledgePackageDocument(
      id: 'impact-statements',
      areaDe: 'HB Cure Überblick',
      areaEn: 'HB Cure overview',
      documentTypeDe: 'Wirkungsbezogene Website-Aussagen',
      documentTypeEn: 'Impact-related website statements',
      source: _websiteSource,
      risk: KnowledgePackageRisk.impactRelatedClaim(),
      contentDe:
          '''Die Healing-&-Balance-Website stellt Frequenztechnologie in einen Zusammenhang mit Selbstregulation, Balance und Wohlbefinden.
Diese wirkungsbezogenen Aussagen sind Aussagen des Anbieters und erfordern vor einer Veröffentlichung eine rechtliche beziehungsweise fachliche Prüfung.
Aus diesen Aussagen wird keine medizinische Wirkung und kein Heilversprechen abgeleitet.''',
      contentEn:
          '''The Healing & Balance website associates frequency technology with self-regulation, balance, and well-being.
These impact-related statements are provider claims and require legal or professional review before publication.
No medical effect or promise of healing is inferred from these statements.''',
    ),
    const KnowledgePackageDocument(
      id: 'testimonials',
      areaDe: 'FAQ',
      areaEn: 'FAQ',
      documentTypeDe: 'Persönliche Erfahrungsberichte',
      documentTypeEn: 'Personal testimonials',
      source: _websiteSource,
      risk: KnowledgePackageRisk.testimonial(),
      contentDe:
          '''Die Healing-&-Balance-Website enthält persönliche Erfahrungsberichte.
Ein Erfahrungsbericht beschreibt ausschließlich die subjektive Erfahrung der jeweiligen Person.
Erfahrungsberichte dürfen nicht in allgemeine Tatsachenbehauptungen oder medizinische Aussagen umgewandelt werden.
Jeder Erfahrungsbericht erfordert vor einer Veröffentlichung eine ausdrückliche menschliche Prüfung.''',
      contentEn:
          '''The Healing & Balance website contains personal testimonials.
A testimonial describes only the subjective experience of the individual person.
Testimonials must not be converted into general factual or medical claims.
Every testimonial requires explicit human review before publication.''',
    ),
  ],
);
