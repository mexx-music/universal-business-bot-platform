/// A local, editable example document for the Knowledge Builder entry screen.
///
/// Demo documents are presentation content only. Loading one never invokes the
/// analyzer and never writes to the workspace.
class KnowledgeDemoDocument {
  const KnowledgeDemoDocument({
    required this.id,
    required this.title,
    required this.area,
    required this.documentTypeDe,
    required this.documentTypeEn,
    required this.contentDe,
    required this.contentEn,
  });

  final String id;
  final String title;
  final String area;
  final String documentTypeDe;
  final String documentTypeEn;
  final String contentDe;
  final String contentEn;

  String documentType(String languageCode) =>
      languageCode == 'de' ? documentTypeDe : documentTypeEn;

  String content(String languageCode) =>
      languageCode == 'de' ? contentDe : contentEn;
}

const knowledgeDemoDocuments = <KnowledgeDemoDocument>[
  KnowledgeDemoDocument(
    id: 'hb-cure-app',
    title: 'HB Cure App',
    area: 'HB Cure App',
    documentTypeDe: 'Bedienungsanleitung',
    documentTypeEn: 'User guide',
    contentDe: '''HB Cure App – Bedienungsanleitung

Die HB Cure App verbindet sich über Bluetooth mit einem kompatiblen Gerät. Aktivieren Sie Bluetooth auf Ihrem Smartphone und öffnen Sie in der App den Bereich „Gerät verbinden“. Wählen Sie das gefundene Gerät aus und bestätigen Sie die Verbindung.

Ein Frequenzprogramm wird in der Programmübersicht ausgewählt und über „Starten“ begonnen. Der Timer zeigt die verbleibende Laufzeit an. Ein laufendes Programm kann jederzeit pausiert oder beendet werden.

Wenn ein Firmware-Update verfügbar ist, zeigt die App einen Hinweis an. Smartphone und Gerät müssen während des Updates verbunden bleiben. Schalten Sie das Gerät erst aus, wenn die App den erfolgreichen Abschluss bestätigt.

Voraussetzung ist ein Smartphone mit aktiviertem Bluetooth. Wenn keine Verbindung hergestellt werden kann, prüfen Sie Bluetooth, den Ladezustand des Geräts und den Abstand zwischen Smartphone und Gerät.''',
    contentEn: '''HB Cure App – User guide

The HB Cure App connects to a compatible device via Bluetooth. Enable Bluetooth on your smartphone and open “Connect device” in the app. Select the device that was found and confirm the connection.

Choose a frequency program in the program overview and select “Start” to begin. The timer shows the remaining runtime. A running program can be paused or stopped at any time.

When a firmware update is available, the app displays a notice. The smartphone and device must remain connected during the update. Do not switch off the device until the app confirms successful completion.

A smartphone with Bluetooth enabled is required. If a connection cannot be established, check Bluetooth, the device battery level, and the distance between the smartphone and device.''',
  ),
  KnowledgeDemoDocument(
    id: 'curebase',
    title: 'CureBase',
    area: 'CureBase',
    documentTypeDe: 'Gerätebeschreibung',
    documentTypeEn: 'Device description',
    contentDe: '''CureBase – Gerätebeschreibung

CureBase wird über die Ein/Aus-Taste gestartet. Die Statusanzeige informiert darüber, ob das Gerät eingeschaltet, verbunden oder im Ladevorgang ist. Vor der ersten Verwendung muss der Akku vollständig geladen werden.

Zur Verbindung mit der HB Cure App muss CureBase eingeschaltet sein und sich in der Nähe des Smartphones befinden. Nach erfolgreicher Kopplung zeigt die App den Verbindungsstatus an.

Reinigen Sie die Oberfläche ausschließlich mit einem weichen, trockenen Tuch. Verwenden Sie keine aggressiven Reinigungsmittel und tauchen Sie das Gerät nicht in Wasser. Bei ungewöhnlicher Wärmeentwicklung muss das Gerät ausgeschaltet und vom Ladekabel getrennt werden.''',
    contentEn: '''CureBase – Device description

CureBase is started with the power button. The status indicator shows whether the device is switched on, connected, or charging. The battery must be fully charged before first use.

To connect with the HB Cure App, CureBase must be switched on and close to the smartphone. After successful pairing, the app displays the connection status.

Clean the surface only with a soft, dry cloth. Do not use aggressive cleaning products and do not immerse the device in water. If unusual heat develops, switch off the device and disconnect the charging cable.''',
  ),
  KnowledgeDemoDocument(
    id: 'schnurrpurr',
    title: 'SchnurrPurr',
    area: 'SchnurrPurr',
    documentTypeDe: 'Produktübersicht',
    documentTypeEn: 'Product overview',
    contentDe: '''SchnurrPurr – Produktübersicht

SchnurrPurr ist ein kompaktes Produkt für einen festen Ruheplatz der Katze. Es wird auf einer ebenen und trockenen Fläche aufgestellt. Der Standort sollte für die Katze frei zugänglich sein.

Vor der ersten Nutzung wird der abnehmbare Bezug angebracht. Der Bezug kann zur Reinigung entfernt werden. Beachten Sie dabei die Pflegehinweise auf dem Etikett.

Kontrollieren Sie das Produkt regelmäßig auf sichtbare Beschädigungen. Beschädigte Teile dürfen nicht weiterverwendet werden. Bewahren Sie die Produktinformation für spätere Fragen zur Pflege und Verwendung auf.''',
    contentEn: '''SchnurrPurr – Product overview

SchnurrPurr is a compact product for a cat's designated resting place. Place it on a level, dry surface. The location should remain freely accessible to the cat.

Attach the removable cover before first use. The cover can be removed for cleaning. Follow the care instructions on the label.

Check the product regularly for visible damage. Damaged parts must no longer be used. Keep the product information for future questions about care and use.''',
  ),
  KnowledgeDemoDocument(
    id: 'support-faq',
    title: 'Support FAQ',
    area: 'HB Cure App',
    documentTypeDe: 'Support FAQ',
    documentTypeEn: 'Support FAQ',
    contentDe: '''Support FAQ – HB Cure App

Warum findet die App mein Gerät nicht? Prüfen Sie, ob Bluetooth aktiviert ist, das Gerät eingeschaltet ist und sich in der Nähe des Smartphones befindet.

Was kann ich bei einem Verbindungsabbruch tun? Schließen und öffnen Sie die App erneut. Prüfen Sie anschließend den Ladezustand des Geräts und starten Sie die Verbindung noch einmal.

Kann ein laufendes Programm pausiert werden? Ja, ein laufendes Programm kann in der Programmansicht pausiert und später fortgesetzt werden.

Wo sehe ich die App-Version? Die installierte Version wird in der App unter „Einstellungen“ und „Über die App“ angezeigt.''',
    contentEn: '''Support FAQ – HB Cure App

Why can't the app find my device? Check that Bluetooth is enabled, the device is switched on, and it is close to the smartphone.

What can I do if the connection is interrupted? Close and reopen the app. Then check the device battery level and start the connection again.

Can a running program be paused? Yes. A running program can be paused in the program view and continued later.

Where can I find the app version? The installed version is displayed under “Settings” and “About the app”.''',
  ),
];
