import '../models/business_audit.dart';
import '../models/business_rules.dart';
import '../models/business_strategy.dart';
import '../models/bot_configuration.dart';
import '../models/company.dart';
import '../models/company_workspace.dart';
import '../models/product_or_service.dart';
import '../models/knowledge_entry.dart';
import '../models/marketing_strategy.dart';
import '../models/bot_question_log.dart';
import '../models/source_material.dart';
import '../models/intake_session.dart';

class MockData {
  static final Company company = Company(
    id: 'hb-cure',
    name: 'Healing und Balance GmbH',
    industry: 'Gesundheit / Frequenztechnologie',
    description:
        'Healing und Balance GmbH entwickelt und vertreibt Systeme im Bereich '
        'Frequenztechnologie. Die Produkte dienen der ergänzenden Anwendung '
        'und ersetzen keine medizinische Diagnose oder Behandlung.',
    country: 'Österreich',
    primaryLanguage: 'de',
    website: 'https://www.healing-balance.com',
    email: 'semper@healing-balance.com',
    phone: '+43 660 6506900',
    address: 'Europäische Union',
    socialLinks: {
      'website': 'https://www.healing-balance.com',
      'social_media': 'Vorhanden, konkrete Plattformen noch zu klären',
    },
    internalNotes:
        'Ansprechpartner: GF Klaus Semper. HB Cure Workspace für Healing und '
        'Balance GmbH. Vom Unternehmen gelieferte Ausgangsangabe intern: '
        '"Aktivierung körpereigener Selbstheilungsprozesse". Diese Aussage '
        'nicht ungeprüft öffentlich verwenden. Offene Unternehmensangaben: '
        'wichtigste Angebote, konkrete Anfragekanäle, Priorität Marketing, '
        'Priorität Website, Priorität Automatisierung, Priorität Sonstiges, '
        'konkrete Social-Media-Plattformen und konkrete Werbekanäle.',
  );

  static final List<ProductOrService> products = [
    ProductOrService(
      id: 'p1',
      name: 'Frequenztechnologie mit App-Unterstützung',
      description:
          'Systeme und Anwendungen im Bereich Frequenztechnologie mit '
          'App-gestützter Einrichtung und verständlicher Nutzungsführung.',
      type: ProductType.produkt,
    ),
    ProductOrService(
      id: 'p2',
      name: 'Programme und Frequenzen',
      description:
          'Strukturierte Programme und Frequenzinformationen für ergänzende '
          'Anwendungsabläufe. Konkrete Inhalte müssen fachlich geprüft werden.',
      type: ProductType.produkt,
    ),
    ProductOrService(
      id: 'p3',
      name: 'Einrichtung, Anleitung und Support',
      description:
          'Unterstützung bei App-Einrichtung, Geräteverbindung, Ablauf der '
          'Nutzung, Anleitungen und sicheren rechtlichen Hinweisen.',
      type: ProductType.dienstleistung,
    ),
  ];

  static final List<KnowledgeEntry> knowledgeEntries = [
    // ── Einstieg ──────────────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k1',
      languageCode: 'de',
      title: 'Wie starte ich mit der Anwendung?',
      content:
          'Öffnen Sie die App, folgen Sie der Einrichtung Schritt für Schritt '
          'und verbinden Sie das zugehörige Gerät, falls dies für Ihre Anwendung '
          'vorgesehen ist. Nutzen Sie vorhandene Anleitungen und wenden Sie '
          'sich bei Unsicherheiten an den Support.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: [
        'starten',
        'einstieg',
        'erste schritte',
        'anfangen',
        'download',
        'konto',
        'installieren',
      ],
      source: 'Firmenaufnahme Klaus / Anleitungen',
      createdAt: DateTime(2025, 1, 10),
    ),
    KnowledgeEntry(
      id: 'k2',
      languageCode: 'de',
      title: 'Welche Angebote sind aktuell erfasst?',
      content:
          'Erfasst sind Frequenztechnologie, zugehörige Geräte, Anwendungen, '
          'Programme und App-Unterstützung. Welche Angebote am wichtigsten '
          'sind, ist noch zu klären und darf nicht automatisch angenommen werden.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: [
        'angebote',
        'produkte',
        'dienstleistungen',
        'frequenztechnologie',
        'geräte',
        'programme',
        'app',
        'noch zu klären',
      ],
      source: 'Firmenaufnahme Klaus',
      createdAt: DateTime(2025, 1, 11),
    ),

    // ── Gerät & Technik ───────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k3',
      languageCode: 'de',
      title: 'Wie verbinde ich das Messgerät mit der App?',
      content:
          'Aktivieren Sie die benötigte Verbindung am Smartphone. Öffnen Sie '
          'die App und folgen Sie der Anleitung zur Geräteverbindung. Falls '
          'die Verbindung nicht klappt, prüfen Sie Akku, Abstand und die '
          'jeweilige Schritt-für-Schritt-Anleitung.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: [
        'verbinden',
        'bluetooth',
        'messgerät',
        'koppeln',
        'gerät',
        'app verbinden',
        'pairing',
      ],
      source: 'Anleitungen',
      createdAt: DateTime(2025, 1, 15),
    ),
    KnowledgeEntry(
      id: 'k4',
      languageCode: 'de',
      title: 'Welche Smartphones werden unterstützt?',
      content:
          'Die konkreten technischen Anforderungen müssen aus den aktuellen '
          'App- und Geräteunterlagen übernommen werden. Bis dahin sollte der '
          'Support nach Gerät, Betriebssystem und App-Version fragen.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: [
        'smartphone',
        'ios',
        'android',
        'unterstützt',
        'kompatibel',
        'handy',
        'iphone',
        'samsung',
      ],
      source: 'App- und Produktnotizen',
      createdAt: DateTime(2025, 1, 16),
    ),
    KnowledgeEntry(
      id: 'k5',
      languageCode: 'de',
      title: 'Wo finde ich Programme und Frequenzen?',
      content:
          'Informationen zu Programmen und Frequenzen sollen aus geprüften '
          'Unterlagen, Anleitungen oder freigegebenen App-Texten übernommen '
          'werden. Wirkungsbezogene Aussagen müssen vor Veröffentlichung '
          'menschlich geprüft werden.',
      category: KnowledgeCategory.produkt,
      riskLevel: RiskLevel.yellow,
      keywords: [
        'programme',
        'frequenzen',
        'wirkungsweise',
        'app',
        'anleitung',
        'prüfung',
      ],
      source: 'Firmenaufnahme Klaus',
      createdAt: DateTime(2025, 1, 17),
    ),
    KnowledgeEntry(
      id: 'k6',
      languageCode: 'de',
      title: 'Welche Sicherheitshinweise gelten?',
      content:
          'Sicherheitshinweise müssen aus geprüften Unterlagen übernommen '
          'werden. Der Bot darf keine Nutzung empfehlen, wenn eine Frage '
          'medizinisch, rechtlich oder sicherheitsrelevant ist. Solche Fälle '
          'werden an Human Review weitergeleitet.',
      category: KnowledgeCategory.produkt,
      riskLevel: RiskLevel.yellow,
      keywords: [
        'sicherheit',
        'hinweise',
        'nutzung',
        'risiko',
        'rechtlich',
        'medizinisch',
      ],
      source: 'Sicherheit und rechtliche Hinweise',
      createdAt: DateTime(2025, 1, 18),
    ),
    KnowledgeEntry(
      id: 'k7',
      languageCode: 'de',
      title: 'Messgerät verbindet sich nicht – was tun?',
      content:
          'Prüfen Sie zuerst die Verbindungseinstellungen, starten Sie App und '
          'Gerät neu und folgen Sie der aktuellen Anleitung. Hilft das nicht, '
          'kontaktieren Sie den Support unter semper@healing-balance.com.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: [
        'verbindet nicht',
        'problem',
        'bluetooth',
        'fehler',
        'technisch',
        'kein signal',
        'hilfe',
      ],
      source: 'Anleitungen',
      createdAt: DateTime(2025, 2, 1),
    ),

    // ── App & Funktionen ──────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k8',
      languageCode: 'de',
      title: 'Was zeigt das Dashboard in der App an?',
      content:
          'Die App soll Einrichtung, Ablauf und relevante Nutzungshinweise '
          'verständlich darstellen. Konkrete App-Funktionen werden erst aus '
          'freigegebenen Produktunterlagen in die Wissensbasis übernommen.',
      category: KnowledgeCategory.produkt,
      riskLevel: RiskLevel.green,
      keywords: [
        'dashboard',
        'app',
        'anzeigen',
        'einrichtung',
        'übersicht',
        'ablauf',
        'funktionen',
      ],
      source: 'Firmenaufnahme Klaus',
      createdAt: DateTime(2025, 2, 5),
    ),
    KnowledgeEntry(
      id: 'k9',
      languageCode: 'de',
      title: 'Wie läuft die Nutzung ab?',
      content:
          'Der konkrete Ablauf soll anhand der freigegebenen Anleitungen '
          'beschrieben werden. Der Bot darf nur organisatorische Schritte '
          'erklären und keine medizinische Wirkung oder Nutzungshäufigkeit '
          'empfehlen.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.yellow,
      keywords: [
        'ablauf',
        'nutzung',
        'anwendung',
        'schritte',
        'anleitung',
        'häufigkeit',
      ],
      source: 'Firmenaufnahme Klaus',
      createdAt: DateTime(2025, 2, 6),
    ),
    KnowledgeEntry(
      id: 'k10',
      languageCode: 'de',
      title: 'Wie werden meine Daten gespeichert?',
      content:
          'Datenschutzinformationen müssen aus der aktuellen Datenschutzerklärung '
          'übernommen werden. Bis die Details geprüft sind, verweist der Bot '
          'auf die Website und gibt keine technischen Datenschutzversprechen ab.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: [
        'datenschutz',
        'daten',
        'dsgvo',
        'sicherheit',
        'cloud',
        'privatsphäre',
        'gespeichert',
      ],
      source: 'Rechtliche Hinweise',
      createdAt: DateTime(2025, 2, 10),
    ),

    // ── Support ───────────────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k11',
      languageCode: 'de',
      title: 'Wie erreiche ich den Support?',
      content:
          'Der interne Ansprechpartner ist GF Klaus Semper. Für Supportfragen '
          'ist semper@healing-balance.com hinterlegt. Konkrete Anfragekanäle '
          'wie Formular, Telefon, Messenger oder Social Media sind noch zu klären.',
      category: KnowledgeCategory.allgemein,
      riskLevel: RiskLevel.green,
      keywords: [
        'support',
        'kontakt',
        'hilfe',
        'email',
        'chat',
        'erreichbar',
        'anrufen',
        'melden',
      ],
      source: 'Firmenaufnahme Klaus',
      createdAt: DateTime(2025, 2, 12),
    ),

    // ── Wellness (Yellow) ─────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k12',
      languageCode: 'de',
      title: 'Wofür sind die Systeme gedacht?',
      content:
          'Die Systeme der Healing und Balance GmbH sind für ergänzende '
          'Anwendungen im Bereich Frequenztechnologie beschrieben. Sie ersetzen '
          'keine medizinische Diagnose oder Behandlung. Wirkungsbezogene Fragen '
          'müssen menschlich geprüft werden.',
      category: KnowledgeCategory.allgemein,
      riskLevel: RiskLevel.yellow,
      keywords: [
        'wohlbefinden',
        'wellness',
        'gesundheit',
        'helfen',
        'besser fühlen',
        'unterstützen',
        'lebensstil',
      ],
      source: 'Sichere Außenbeschreibung',
      createdAt: DateTime(2025, 3, 1),
    ),
    KnowledgeEntry(
      id: 'k13',
      languageCode: 'de',
      title: 'Wie darf Wirkungsweise beschrieben werden?',
      content:
          'Beschreibungen zur Wirkungsweise müssen neutral und belegbar bleiben. '
          'Ungeprüfte Aussagen zu Heilung, Diagnose, Therapieerfolg oder '
          'Garantien dürfen nicht veröffentlicht werden.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.yellow,
      keywords: [
        'wirkungsweise',
        'wirkung',
        'heilung',
        'garantie',
        'belege',
        'prüfung',
      ],
      source: 'Rechtliche Hinweise',
      createdAt: DateTime(2025, 3, 5),
    ),

    // ── Rechtliche No-Go-Bereiche (Red – Bot verweist, antwortet nicht) ──
    KnowledgeEntry(
      id: 'k14',
      languageCode: 'de',
      title: 'Heilversprechen und medizinische Diagnosen',
      content:
          'Der Bot darf keine medizinischen Diagnosen stellen, keine Heilversprechen '
          'machen und keine Behandlungserfolge zusagen. Bitte wenden Sie sich '
          'bei medizinischen Fragen an qualifizierte Fachstellen.',
      category: KnowledgeCategory.allgemein,
      riskLevel: RiskLevel.red,
      keywords: [
        'heilen',
        'heilung',
        'geheilt',
        'diagnose',
        'diagnostizieren',
        'therapie',
        'behandlung',
        'medikament',
        'medikamente',
        'klinisch',
        'klinisch bewiesen',
        'arzt ersetzen',
        'rezept',
        'verschreibung',
      ],
      source: 'Rechtliche Richtlinien',
      createdAt: DateTime(2025, 3, 10),
    ),
    KnowledgeEntry(
      id: 'k15',
      languageCode: 'de',
      title: 'Spezifische Erkrankungen und Medikamentenersatz',
      content:
          'Healing und Balance GmbH macht in der Bot-Kommunikation keine '
          'Aussagen zu spezifischen Erkrankungen und ersetzt keine ärztliche '
          'Behandlung. Bei Beschwerden wenden Sie sich bitte an einen Arzt '
          'oder Apotheker.',
      category: KnowledgeCategory.allgemein,
      riskLevel: RiskLevel.red,
      keywords: [
        'diabetes',
        'bluthochdruck',
        'krebs',
        'asthma',
        'depression',
        'herzinfarkt',
        'schlaganfall',
        'epilepsie',
        'alzheimer',
        'blutdruck',
        'blutzucker',
        'insulin',
        'chemotherapie',
      ],
      source: 'Rechtliche Richtlinien',
      createdAt: DateTime(2025, 3, 10),
    ),
    KnowledgeEntry(
      id: 'k16',
      languageCode: 'de',
      title: 'Anwendung: Inhalt fehlt',
      content:
          'Dokument hinzufügen: Für konkrete Anwendungsschritte fehlen noch '
          'freigegebene Inhalte aus Anleitung, Schulung oder Support.',
      category: KnowledgeCategory.prozess,
      riskLevel: RiskLevel.yellow,
      keywords: ['anwendung', 'inhalt fehlt', 'dokument hinzufügen'],
      source: 'Offene Unternehmensangaben',
      createdAt: DateTime(2025, 5, 24),
    ),
    KnowledgeEntry(
      id: 'k17',
      languageCode: 'de',
      title: 'Geräte: Inhalt fehlt',
      content:
          'Dokument hinzufügen: Gerätespezifische Informationen müssen aus '
          'aktuellen Produktunterlagen übernommen und geprüft werden.',
      category: KnowledgeCategory.produkt,
      riskLevel: RiskLevel.yellow,
      keywords: ['geräte', 'inhalt fehlt', 'produktunterlagen'],
      source: 'Offene Unternehmensangaben',
      createdAt: DateTime(2025, 5, 24),
    ),
    KnowledgeEntry(
      id: 'k18',
      languageCode: 'de',
      title: 'App und Einrichtung: Inhalt fehlt',
      content:
          'FAQ ergänzen: Für App-Einrichtung, Geräteverbindung und typische '
          'Fehlerfälle sollen konkrete Schritt-für-Schritt-Antworten ergänzt werden.',
      category: KnowledgeCategory.prozess,
      riskLevel: RiskLevel.green,
      keywords: ['app', 'einrichtung', 'faq ergänzen'],
      source: 'Offene Unternehmensangaben',
      createdAt: DateTime(2025, 5, 24),
    ),
    KnowledgeEntry(
      id: 'k19',
      languageCode: 'de',
      title: 'Programme und Frequenzen: Prüfung erforderlich',
      content:
          'FAQ ergänzen: Aussagen zu Programmen, Frequenzen und Wirkungsweise '
          'müssen vor Nutzung in Bot oder Marketing fachlich und rechtlich geprüft werden.',
      category: KnowledgeCategory.allgemein,
      riskLevel: RiskLevel.yellow,
      keywords: ['programme', 'frequenzen', 'prüfung erforderlich'],
      source: 'Offene Unternehmensangaben',
      createdAt: DateTime(2025, 5, 24),
    ),
    KnowledgeEntry(
      id: 'k20',
      languageCode: 'de',
      title: 'Videos: Inhalt fehlt',
      content:
          'Video verknüpfen: Vorhandene Videos sollen als Quelle erfasst und '
          'erst nach Prüfung für Wissensbasis oder Marketing genutzt werden.',
      category: KnowledgeCategory.allgemein,
      riskLevel: RiskLevel.green,
      keywords: ['videos', 'video verknüpfen', 'quelle'],
      source: 'Offene Unternehmensangaben',
      createdAt: DateTime(2025, 5, 24),
    ),
    KnowledgeEntry(
      id: 'k21',
      languageCode: 'en',
      title: 'Safe public company description',
      content:
          'Healing und Balance GmbH develops and distributes systems in the '
          'field of frequency technology. The products are intended for '
          'complementary use and do not replace medical diagnosis or treatment.',
      category: KnowledgeCategory.allgemein,
      riskLevel: RiskLevel.yellow,
      keywords: ['company', 'description', 'complementary use', 'disclaimer'],
      source: 'Company intake Klaus',
      createdAt: DateTime(2025, 5, 24),
    ),
  ];

  static final List<BotQuestionLog> botLogs = [
    BotQuestionLog(
      id: 'b1',
      question: 'Wie verbinde ich das Messgerät?',
      answer: 'Aktivieren Sie Bluetooth auf Ihrem Smartphone...',
      matched: true,
      redirected: false,
      timestamp: DateTime(2025, 6, 1, 10, 23),
      reviewStatus: ReviewStatus.closed,
      reviewedAt: DateTime(2025, 6, 1, 10, 23),
    ),
    BotQuestionLog(
      id: 'b2',
      question: 'Was kostet die App?',
      answer: null,
      matched: false,
      redirected: false,
      timestamp: DateTime(2025, 6, 2, 9, 45),
      reviewStatus: ReviewStatus.open,
      reviewReason: ReviewReason.noMatch,
      humanNote: 'Preise wurden von Klaus nicht geliefert. Nicht erfinden.',
    ),
    BotQuestionLog(
      id: 'b3',
      question: 'Kann HB Cure meinen Bluthochdruck heilen?',
      answer: null,
      matched: false,
      redirected: true,
      timestamp: DateTime(2025, 6, 3, 14, 12),
      reviewStatus: ReviewStatus.open,
      reviewReason: ReviewReason.redFlag,
    ),
    BotQuestionLog(
      id: 'b4',
      question: 'Wie lange hält der Akku?',
      answer: null,
      matched: false,
      redirected: false,
      timestamp: DateTime(2025, 6, 4, 11, 30),
      reviewStatus: ReviewStatus.open,
      reviewReason: ReviewReason.noMatch,
    ),
    BotQuestionLog(
      id: 'b5',
      question: 'Welche Frequenz hilft bei Schmerzen?',
      answer: null,
      matched: false,
      redirected: true,
      timestamp: DateTime(2025, 6, 5, 15, 5),
      reviewStatus: ReviewStatus.open,
      reviewReason: ReviewReason.redFlag,
      humanNote:
          'Medizinisch sensible Wirkungsfrage. Keine automatische Freigabe.',
    ),
    BotQuestionLog(
      id: 'b6',
      question: 'Wie richte ich die App für das Gerät ein?',
      answer:
          'Ein Antwortvorschlag darf vorbereitet werden, muss aber vor Nutzung '
          'gegen die aktuelle Anleitung geprüft werden.',
      matched: true,
      redirected: false,
      timestamp: DateTime(2025, 6, 5, 16, 20),
      reviewStatus: ReviewStatus.reviewed,
      reviewReason: ReviewReason.yellowRisk,
      humanNote:
          'Human Review bleibt aktiv, bis konkrete Anleitung freigegeben ist.',
      reviewedAt: DateTime(2025, 6, 5, 16, 45),
    ),
  ];

  static final Company schnurrPurrCompany = Company(
    id: 'schnurr-purr',
    name: 'SchnurrPurr',
    industry: 'Entspannungs-App & Komfortprodukte',
    description:
        'SchnurrPurr entwickelt ruhige digitale Begleiter und weiche Komfortprodukte '
        'für entspannte Pausen im Alltag. Die Angebote helfen beim Abschalten, '
        'bei kleinen Routinen und beim bewussten Umgang mit Erholungszeiten.',
    country: 'Österreich',
    primaryLanguage: 'de',
    website: 'https://www.schnurrpurr.example',
    email: 'support@schnurrpurr.example',
    phone: '+43 720 987 654',
    address: 'Schottenfeldgasse 22, 1070 Wien',
    socialLinks: {
      'website': 'https://www.schnurrpurr.example',
      'instagram': 'https://instagram.com/schnurrpurr',
      'youtube': 'https://youtube.com/@schnurrpurr',
    },
    internalNotes:
        'Demo-Workspace für App- und Komfortprodukt-Kommunikation ohne medizinische Versprechen.',
  );

  static final List<ProductOrService> schnurrPurrProducts = [
    ProductOrService(
      id: 'sp-p1',
      name: 'SchnurrPurr Relax App',
      description:
          'Mobile App mit Atem-Timern, ruhigen Soundlandschaften und einfachen Pausenroutinen.',
      type: ProductType.produkt,
    ),
    ProductOrService(
      id: 'sp-p2',
      name: 'SchnurrPurr Kissen / Purr Pillow',
      description:
          'Weiches Komfortkissen mit abnehmbarem Bezug für Sofa, Lesesessel oder kurze Ruhepausen.',
      type: ProductType.produkt,
      price: 49.0,
    ),
  ];

  static final List<KnowledgeEntry> schnurrPurrKnowledgeEntries = [
    KnowledgeEntry(
      id: 'sp-k1',
      languageCode: 'de',
      title: 'Was ist die SchnurrPurr Relax App?',
      content:
          'Die SchnurrPurr Relax App bietet kurze Pausenroutinen, sanfte Klangwelten '
          'und einfache Timer für bewusste Entspannungsmomente im Alltag.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: ['app', 'relax app', 'entspannung', 'pause', 'klang', 'timer'],
      source: 'Produkt-FAQ',
      createdAt: DateTime(2025, 4, 2),
    ),
    KnowledgeEntry(
      id: 'sp-k2',
      languageCode: 'de',
      title: 'Wie starte ich eine Entspannungsroutine?',
      content:
          'Öffnen Sie die App, wählen Sie eine Routine und legen Sie die gewünschte Dauer fest. '
          'Sie können die Übung jederzeit pausieren oder beenden.',
      category: KnowledgeCategory.prozess,
      riskLevel: RiskLevel.green,
      keywords: ['routine', 'starten', 'dauer', 'übung', 'pause', 'beenden'],
      source: 'App-Hilfe',
      createdAt: DateTime(2025, 4, 4),
    ),
    KnowledgeEntry(
      id: 'sp-k3',
      languageCode: 'de',
      title: 'Kann ich die App ohne Konto nutzen?',
      content:
          'Ja, Basisfunktionen wie Timer und ausgewählte Klangwelten sind ohne Konto nutzbar. '
          'Ein Konto ist nur für Synchronisierung und optionale Favoriten erforderlich.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: [
        'konto',
        'ohne konto',
        'login',
        'basisfunktionen',
        'favoriten',
      ],
      source: 'App-Hilfe',
      createdAt: DateTime(2025, 4, 5),
    ),
    KnowledgeEntry(
      id: 'sp-k4',
      languageCode: 'de',
      title: 'Was ist das SchnurrPurr Kissen?',
      content:
          'Das SchnurrPurr Kissen ist ein weiches Komfortkissen mit waschbarem Bezug. '
          'Es ist für gemütliche Pausen, Lesen und ruhige Momente gedacht.',
      category: KnowledgeCategory.produkt,
      riskLevel: RiskLevel.green,
      keywords: [
        'kissen',
        'purr pillow',
        'bezug',
        'waschbar',
        'komfort',
        'pause',
      ],
      source: 'Produktdatenblatt',
      createdAt: DateTime(2025, 4, 8),
    ),
    KnowledgeEntry(
      id: 'sp-k5',
      languageCode: 'de',
      title: 'Wie reinige ich den Kissenbezug?',
      content:
          'Der Bezug kann abgenommen und bei niedriger Temperatur gewaschen werden. '
          'Bitte beachten Sie das Pflegeetikett und lassen Sie den Bezug vollständig trocknen.',
      category: KnowledgeCategory.produkt,
      riskLevel: RiskLevel.green,
      keywords: ['reinigen', 'waschen', 'bezug', 'pflege', 'trocknen'],
      source: 'Pflegehinweise',
      createdAt: DateTime(2025, 4, 10),
    ),
    KnowledgeEntry(
      id: 'sp-k6',
      languageCode: 'de',
      title: 'Welche Geräte unterstützt die App?',
      content:
          'Die App unterstützt aktuelle iOS- und Android-Geräte. Für Klanginhalte empfehlen wir '
          'eine stabile Internetverbindung oder zuvor gespeicherte Favoriten.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: [
        'geräte',
        'ios',
        'android',
        'smartphone',
        'internet',
        'offline',
      ],
      source: 'Technische Anforderungen',
      createdAt: DateTime(2025, 4, 12),
    ),
    KnowledgeEntry(
      id: 'sp-k7',
      languageCode: 'de',
      title: 'Hilft SchnurrPurr bei Stress oder Schlafproblemen?',
      content:
          'SchnurrPurr kann ruhige Pausen und Entspannungsroutinen unterstützen. '
          'Die Produkte stellen keine Diagnose, behandeln keine Beschwerden und ersetzen keine '
          'professionelle medizinische Beratung.',
      category: KnowledgeCategory.allgemein,
      riskLevel: RiskLevel.yellow,
      keywords: [
        'stress',
        'schlaf',
        'schlafprobleme',
        'entspannen',
        'helfen',
        'beratung',
      ],
      source: 'Sichere Kommunikationsrichtlinien',
      createdAt: DateTime(2025, 4, 15),
    ),
    KnowledgeEntry(
      id: 'sp-k8',
      languageCode: 'de',
      title: 'Welche Aussagen darf der Bot nicht machen?',
      content:
          'Der Bot darf keine Heilversprechen, Diagnosen oder Aussagen zur Behandlung von '
          'Erkrankungen machen. Bei gesundheitlichen Fragen soll er an qualifizierte Fachstellen verweisen.',
      category: KnowledgeCategory.allgemein,
      riskLevel: RiskLevel.red,
      keywords: [
        'heilen',
        'heilung',
        'diagnose',
        'behandlung',
        'therapie',
        'depression',
        'angststörung',
        'insomnie',
        'medizinisch',
      ],
      source: 'Sichere Kommunikationsrichtlinien',
      createdAt: DateTime(2025, 4, 16),
    ),
    KnowledgeEntry(
      id: 'sp-k9',
      languageCode: 'de',
      title: 'Wie erreiche ich den Support?',
      content:
          'Der Support ist per E-Mail unter support@schnurrpurr.example erreichbar. '
          'Bitte nennen Sie bei App-Fragen das verwendete Gerät und die App-Version.',
      category: KnowledgeCategory.allgemein,
      riskLevel: RiskLevel.green,
      keywords: [
        'support',
        'kontakt',
        'hilfe',
        'email',
        'app-version',
        'gerät',
      ],
      source: 'Support-Wiki',
      createdAt: DateTime(2025, 4, 18),
    ),
    KnowledgeEntry(
      id: 'sp-k10',
      languageCode: 'de',
      title: 'Kann ich Erinnerungen deaktivieren?',
      content:
          'Ja, Erinnerungen können in den App-Einstellungen jederzeit aktiviert, pausiert oder '
          'vollständig deaktiviert werden.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: [
        'erinnerung',
        'benachrichtigung',
        'deaktivieren',
        'pausieren',
        'einstellungen',
      ],
      source: 'App-Hilfe',
      createdAt: DateTime(2025, 4, 20),
    ),
  ];

  static final List<BotQuestionLog> schnurrPurrBotLogs = [
    BotQuestionLog(
      id: 'sp-b1',
      question: 'Wie starte ich eine Routine?',
      answer:
          'Öffnen Sie die App, wählen Sie eine Routine und legen Sie die gewünschte Dauer fest.',
      matched: true,
      redirected: false,
      timestamp: DateTime(2025, 6, 6, 8, 40),
      reviewStatus: ReviewStatus.closed,
      reviewedAt: DateTime(2025, 6, 6, 8, 40),
    ),
    BotQuestionLog(
      id: 'sp-b2',
      question: 'Kann die App meine Schlafprobleme behandeln?',
      answer: null,
      matched: false,
      redirected: true,
      timestamp: DateTime(2025, 6, 7, 21, 10),
      reviewStatus: ReviewStatus.open,
      reviewReason: ReviewReason.redFlag,
    ),
  ];

  static final List<BusinessAuditItem> hbCureAuditItems = [
    BusinessAuditItem(
      id: 'hb-a1',
      area: AuditArea.companyProfile,
      title: 'Firmenprofil vollständig',
      description:
          'Firmenname, Branche, Website, Ansprechpartner, E-Mail und Telefon '
          'sind für den Workspace gepflegt.',
      status: AuditItemStatus.complete,
      priority: AuditPriority.medium,
      recommendation:
          'Regelmäßig prüfen, ob Kontakt- und Supportdaten noch aktuell sind.',
    ),
    BusinessAuditItem(
      id: 'hb-a2',
      area: AuditArea.website,
      title: 'Website vorhanden',
      description:
          'Ein Webauftritt ist vorhanden und kann als primäre Außenquelle genutzt werden.',
      status: AuditItemStatus.complete,
      priority: AuditPriority.medium,
      note: 'https://www.healing-balance.com ist im Firmenprofil hinterlegt.',
    ),
    BusinessAuditItem(
      id: 'hb-a3',
      area: AuditArea.products,
      title: 'Produkte und Leistungen erfasst',
      description:
          'Frequenztechnologie, Geräte, Anwendungen, Programme und App-Unterstützung '
          'sind grob erfasst. Die wichtigsten Angebote wurden im Formular nicht priorisiert.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      note: 'Offen: Welche Angebote sind am wichtigsten?',
      recommendation:
          'Produktprioritäten mit Klaus klären, bevor Bot- oder Marketinglogik daraus Empfehlungen ableitet.',
    ),
    BusinessAuditItem(
      id: 'hb-a4',
      area: AuditArea.supportKnowledge,
      title: 'FAQ und Supportwissen ausbauen',
      description:
          'FAQ, PDFs, Anleitungen, Videos und rechtliche Hinweise sind vorhanden, '
          'aber konkrete Inhalte müssen noch strukturiert übernommen werden.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      recommendation:
          'FAQ zu Anwendung, Bedienung, App-Einrichtung, Programmen, Frequenzen '
          'und Fehlerbehebung ergänzen.',
    ),
    BusinessAuditItem(
      id: 'hb-a5',
      area: AuditArea.trustMaterial,
      title: 'Rezensionen auf Website vorhanden',
      description:
          'Bewertungen sind vorhanden. Plattformen, Links und Freigabestatus '
          'wurden noch nicht konkret angegeben.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.medium,
      recommendation:
          'Bewertungsquellen, erlaubte Zitate und Nutzungsrechte vor Marketingverwendung dokumentieren.',
    ),
    BusinessAuditItem(
      id: 'hb-a6',
      area: AuditArea.socialPresence,
      title: 'Social Reviews schwach',
      description:
          'Social Media ist vorhanden, konkrete Plattformen, Profile und '
          'Leistungsdaten wurden aber noch nicht benannt.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.low,
      recommendation:
          'Konkrete Social-Media-Plattformen und Profil-Links nacherfassen.',
    ),
    BusinessAuditItem(
      id: 'hb-a7',
      area: AuditArea.sources,
      title: 'Quellen und Dokumente strukturieren',
      description:
          'FAQ, PDFs, Anleitungen, Videos und rechtliche Hinweise sind vorhanden; '
          'Speicherorte, Aktualität und Freigabe müssen noch geprüft werden.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.medium,
      recommendation:
          'Dokumente je Kategorie erfassen: Anwendung, Geräte, App, Programme, FAQ, PDFs, Videos und Recht.',
    ),
    BusinessAuditItem(
      id: 'hb-a8',
      area: AuditArea.riskRules,
      title: 'No-Go-Regeln für medizinische Aussagen',
      description:
          'Rote Regeln sind für Heilversprechen, Diagnosen, Therapieerfolg, '
          'Krankheiten, rechtliche Aussagen und Garantien erforderlich.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      recommendation:
          'Sensible, medizinische, rechtliche und wirkungsbezogene Fragen immer mindestens gelb oder rot einstufen.',
    ),
    BusinessAuditItem(
      id: 'hb-a9',
      area: AuditArea.botReadiness,
      title: 'Bot-Bereitschaft',
      description:
          'Automatische Antworten sind nicht freigegeben. Der Bot darf nur '
          'Vorschläge vorbereiten; Human Review bleibt Standard.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      recommendation:
          'Antwortvorschläge in Human Review prüfen und erst nach Freigabe für Bot-Test verwenden.',
    ),
    BusinessAuditItem(
      id: 'hb-a10',
      area: AuditArea.companyProfile,
      title: 'Offene Unternehmensangaben',
      description:
          'Wichtigste Angebote, Anfragekanäle, konkrete Social-Media-Plattformen, '
          'konkrete Werbekanäle und mehrere Prioritäten sind noch nicht ausgefüllt.',
      status: AuditItemStatus.missing,
      priority: AuditPriority.high,
      note:
          'Prioritäten Kundenservice und Wissensdatenbank sind bestätigt mit 5 von 5. Marketing, Website, Automatisierung und Sonstiges bleiben unbewertet.',
      recommendation:
          'Offene Angaben im Firmenfragebogen nacherfassen, bevor daraus automatische Empfehlungen abgeleitet werden.',
    ),
  ];

  static const BusinessRules hbCureBusinessRules = BusinessRules(
    brandVoice:
        'Sachlich, klar und vorsichtig. Ergänzende Anwendung erklären, ohne '
        'medizinische Wirkung oder Therapieerfolg zu versprechen.',
    doNotSay: [
      'Keine Heilversprechen',
      'Keine Diagnosen',
      'Keine Aussagen, die ärztliche Beratung ersetzen',
      'Keine Medikamenten- oder Therapieempfehlungen',
      'Keine Garantie für Wirkung, Behandlungserfolg oder Heilung',
      'Die interne Ausgangsangabe "Aktivierung körpereigener Selbstheilungsprozesse" nicht ungeprüft öffentlich verwenden',
    ],
    allowedSupportTopics: [
      'App-Nutzung',
      'Geräteverbindung',
      'Ablauf der Nutzung',
      'Anleitungen',
      'Programme und Frequenzen ohne Wirkungsversprechen',
      'Supportkontakt',
      'Datenschutz und rechtliche Hinweise auf allgemeiner Ebene',
    ],
    escalationNotes:
        'Medizinische, rechtliche, sicherheitskritische oder wirkungsbezogene '
        'Fragen immer an Human Review geben. Antworten dürfen nicht automatisch veröffentlicht werden.',
    disclaimerText:
        'Die Produkte dienen der ergänzenden Anwendung und ersetzen keine medizinische Diagnose oder Behandlung.',
  );

  static const BotConfiguration hbCureBotConfiguration = BotConfiguration(
    status: BotStatus.testReady,
    answerStyle: BotAnswerStyle.balanced,
    defaultLanguage: 'de',
    useDisclaimer: true,
    disclaimerText:
        'Hinweis: Die Produkte dienen der ergänzenden Anwendung und ersetzen keine medizinische Diagnose oder Behandlung.',
    alwaysEscalateRedFlags: true,
    escalateNoMatch: true,
    escalateYellowRisk: true,
    allowedTopics: [
      'App-Nutzung',
      'Geräteverbindung',
      'Ablauf der Nutzung',
      'Anleitungen',
      'Programme und Frequenzen ohne Wirkungsversprechen',
      'Support',
      'Rechtliche Hinweise allgemein',
    ],
    blockedTopics: [
      'Diagnosen',
      'Heilversprechen',
      'Krankheiten',
      'Medikamente',
      'Therapieempfehlungen',
      'Garantierte Wirkung',
      'Behandlungserfolg',
    ],
    handoverMessage:
        'Diese Frage muss menschlich geprüft werden. Bitte wenden Sie sich an den Support oder eine qualifizierte Fachstelle.',
  );

  static final List<BusinessAuditItem> schnurrPurrAuditItems = [
    BusinessAuditItem(
      id: 'sp-a1',
      area: AuditArea.companyProfile,
      title: 'Firmenprofil angelegt',
      description:
          'Basisdaten und Kontaktwege sind vorhanden, Positionierung kann noch präzisiert werden.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.medium,
      recommendation:
          'Beschreibung mit klaren Produkt- und Supportgrenzen ergänzen.',
    ),
    BusinessAuditItem(
      id: 'sp-a2',
      area: AuditArea.website,
      title: 'Website vorhanden',
      description:
          'Ein Webauftritt ist hinterlegt; Detailseiten und Supportpfade sind noch nicht vollständig beschrieben.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.medium,
    ),
    BusinessAuditItem(
      id: 'sp-a3',
      area: AuditArea.products,
      title: 'App- und Produktinfos teilweise',
      description:
          'Relax App und Kissen sind angelegt, aber Spezifikationen, Preise und Pflegehinweise sollten konsistenter werden.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      recommendation:
          'Produktdatenblatt für App-Funktionen und Kissenpflege ergänzen.',
    ),
    BusinessAuditItem(
      id: 'sp-a4',
      area: AuditArea.supportKnowledge,
      title: 'Supportwissen teilweise',
      description:
          'FAQ zur App, Nutzung und Support sind vorhanden; Rückgaben, Bestellung und technische Fehler fehlen noch.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      recommendation:
          'Supportwissen für Kauf, Nutzung, Konto und technische Probleme ergänzen.',
    ),
    BusinessAuditItem(
      id: 'sp-a5',
      area: AuditArea.trustMaterial,
      title: 'Rezensionen und Trustmaterial fehlen',
      description:
          'Für externe Glaubwürdigkeit fehlen dokumentierte Rezensionen, Testimonials oder Pressestimmen.',
      status: AuditItemStatus.missing,
      priority: AuditPriority.medium,
      recommendation:
          'Erlaubte Rezensionen und kurze Trust-Quellen sammeln und als Quellen ablegen.',
    ),
    BusinessAuditItem(
      id: 'sp-a6',
      area: AuditArea.socialPresence,
      title: 'Social und Community ausbaufähig',
      description:
          'Community- und Social-Media-Signale sind für den Demo-Workspace noch kaum dokumentiert.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.low,
      recommendation:
          'Öffentliche Kanäle und häufige Community-Fragen strukturiert erfassen.',
    ),
    BusinessAuditItem(
      id: 'sp-a7',
      area: AuditArea.sources,
      title: 'Quellenbasis erweitern',
      description:
          'App-Hilfe und Produktdaten sind vorhanden, aber Website-, Pflege- und Supportquellen sollten sauber getrennt werden.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.medium,
    ),
    BusinessAuditItem(
      id: 'sp-a8',
      area: AuditArea.riskRules,
      title: 'No-Go-Regeln für Wellness-Kommunikation',
      description:
          'Regeln gegen Heilversprechen und Diagnosen sind vorhanden, sollten aber für Entspannungs- und Schlaf-Fragen präzisiert werden.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      recommendation:
          'Grenzen für Wellness-Aussagen und Support-Verweise klarer dokumentieren.',
    ),
    BusinessAuditItem(
      id: 'sp-a9',
      area: AuditArea.botReadiness,
      title: 'Bot-Bereitschaft',
      description:
          'Der Bot kann Basisfragen beantworten, ist aber vor Marketing-Ausbau noch nicht vollständig abgesichert.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      recommendation:
          'Review-Fälle schließen, FAQ erweitern und rote Regeln mit Testfragen prüfen.',
    ),
  ];

  static const BusinessRules schnurrPurrBusinessRules = BusinessRules(
    brandVoice:
        'Ruhig, freundlich und alltagsnah. Fokus auf Nutzung, Komfort und Support.',
    doNotSay: [
      'Keine Heilversprechen',
      'Keine Diagnose- oder Therapieaussagen',
      'Keine Garantie für Schlaf, Stressreduktion oder Gesundheit',
    ],
    allowedSupportTopics: [
      'Relax-App Nutzung',
      'Pausenroutinen',
      'Kissenpflege',
      'Support und App-Version',
      'Benachrichtigungseinstellungen',
    ],
    escalationNotes:
        'Bei gesundheitlichen oder rechtlichen Fragen an professionelle Beratung verweisen.',
    disclaimerText:
        'SchnurrPurr bietet Komfort- und Entspannungsinformationen, keine medizinische Beratung.',
  );

  static const BotConfiguration schnurrPurrBotConfiguration = BotConfiguration(
    status: BotStatus.draft,
    answerStyle: BotAnswerStyle.balanced,
    defaultLanguage: 'de',
    useDisclaimer: true,
    disclaimerText:
        'Hinweis: SchnurrPurr bietet Komfort- und Entspannungsinformationen, keine medizinische Beratung.',
    alwaysEscalateRedFlags: true,
    escalateNoMatch: true,
    escalateYellowRisk: false,
    allowedTopics: [
      'Relax-App Nutzung',
      'Pausenroutinen',
      'Kissenpflege',
      'Support',
    ],
    blockedTopics: [
      'Diagnosen',
      'Behandlung',
      'Therapie',
      'Garantierte Gesundheitswirkung',
    ],
    handoverMessage:
        'Diese Frage sollte vom Support geprüft werden. Bitte kontaktieren Sie SchnurrPurr direkt.',
  );

  static final List<SourceMaterial> hbCureSourceMaterials = [
    SourceMaterial(
      id: 'hb-sm1',
      title: 'Website FAQ',
      type: SourceMaterialType.faq,
      url: 'https://www.healing-balance.com',
      contentSnippet:
          'FAQ vorhanden. Konkrete FAQ-URL und botfähige Einzelfragen müssen '
          'noch aus der Website übernommen und geprüft werden.',
      status: SourceMaterialStatus.converted,
      relatedKnowledgeEntryIds: ['k1', 'k2', 'k3', 'k11', 'k18'],
      createdAt: DateTime(2025, 5, 1),
      updatedAt: DateTime(2025, 5, 3),
      notes: 'FAQ ergänzen; keine Wirkungsclaims ungeprüft übernehmen.',
    ),
    SourceMaterial(
      id: 'hb-sm2',
      title: 'Bewertungen und Website-Rezensionen',
      type: SourceMaterialType.review,
      contentSnippet:
          'Bewertungen sind vorhanden, aber Plattformen, Links, Anzahl und '
          'Nutzungsrechte wurden noch nicht konkret angegeben.',
      status: SourceMaterialStatus.newItem,
      createdAt: DateTime(2025, 5, 4),
      updatedAt: DateTime(2025, 5, 5),
      notes:
          'Bewertungsübersicht erstellen und Content-Freigabe vor Marketingnutzung prüfen.',
    ),
    SourceMaterial(
      id: 'hb-sm3',
      title: 'App-, Geräte- und Produktnotizen',
      type: SourceMaterialType.note,
      contentSnippet:
          'Hauptangebot: Frequenztechnologie mit Geräten, Anwendungen, '
          'Programmen und App-Unterstützung.',
      status: SourceMaterialStatus.converted,
      relatedKnowledgeEntryIds: ['k4', 'k5', 'k8', 'k17', 'k19'],
      createdAt: DateTime(2025, 5, 8),
      updatedAt: DateTime(2025, 5, 10),
      notes: 'Produktprioritäten wurden nicht beantwortet und bleiben offen.',
    ),
    SourceMaterial(
      id: 'hb-sm4',
      title: 'Social Media vorhanden',
      type: SourceMaterialType.social,
      contentSnippet:
          'Social Media wurde als vorhanden angegeben. Konkrete Plattformen '
          'und Profil-Links fehlen noch.',
      status: SourceMaterialStatus.newItem,
      createdAt: DateTime(2025, 5, 15),
      updatedAt: DateTime(2025, 5, 15),
      notes: 'Konkrete Social-Media-Plattformen nacherfassen.',
    ),
    SourceMaterial(
      id: 'hb-sm5',
      title: 'PDFs und Anleitungen',
      type: SourceMaterialType.pdf,
      contentSnippet:
          'PDFs und Anleitungen sind vorhanden. Speicherort, Aktualität und '
          'freigegebene Textstellen müssen noch dokumentiert werden.',
      status: SourceMaterialStatus.newItem,
      relatedKnowledgeEntryIds: ['k16', 'k17', 'k18'],
      createdAt: DateTime(2025, 5, 24),
      updatedAt: DateTime(2025, 5, 24),
      notes: 'Dokument hinzufügen und rechtliche Freigabe prüfen.',
    ),
    SourceMaterial(
      id: 'hb-sm6',
      title: 'Videos',
      type: SourceMaterialType.other,
      contentSnippet:
          'Videos sind vorhanden. Links und Inhalte müssen verknüpft werden, '
          'bevor daraus Wissenseinträge oder Marketingentwürfe entstehen.',
      status: SourceMaterialStatus.newItem,
      relatedKnowledgeEntryIds: ['k20'],
      createdAt: DateTime(2025, 5, 24),
      updatedAt: DateTime(2025, 5, 24),
      notes: 'Video verknüpfen.',
    ),
    SourceMaterial(
      id: 'hb-sm7',
      title: 'Offene Unternehmensangaben',
      type: SourceMaterialType.note,
      contentSnippet:
          'Offen: wichtigste Angebote, konkrete Anfragekanäle, Priorität '
          'Marketing, Website, Automatisierung, Sonstiges, Social-Plattformen '
          'und Werbekanäle.',
      status: SourceMaterialStatus.newItem,
      createdAt: DateTime(2025, 5, 24),
      updatedAt: DateTime(2025, 5, 24),
      notes:
          'Diese Lücken dürfen nicht automatisch mit Annahmen gefüllt werden.',
    ),
  ];

  static final List<MarketingAction> hbCureMarketingActions = [
    MarketingAction(
      id: 'hb-marketing-faq',
      type: MarketingActionType.expandFaq,
      priority: MarketingActionPriority.high,
      effort: MarketingActionEffort.medium,
      impact: MarketingActionImpact.high,
      status: MarketingActionStatus.planned,
      notes:
          'FAQ-basierte Aufklärung zu Anwendung, Bedienung, App-Einrichtung, '
          'Programmen, Frequenzen und rechtlichen Hinweisen vorbereiten. '
          'Priorität Wissensdatenbank: 5 von 5.',
    ),
    MarketingAction(
      id: 'hb-marketing-reviews',
      type: MarketingActionType.collectReviews,
      priority: MarketingActionPriority.medium,
      effort: MarketingActionEffort.medium,
      impact: MarketingActionImpact.medium,
      status: MarketingActionStatus.notStarted,
      notes:
          'Bewertungsübersicht erstellen. Plattformen, Links und Nutzungsrechte '
          'sind noch offen.',
    ),
    MarketingAction(
      id: 'hb-marketing-seo',
      type: MarketingActionType.improveSeo,
      priority: MarketingActionPriority.medium,
      effort: MarketingActionEffort.medium,
      impact: MarketingActionImpact.high,
      status: MarketingActionStatus.planned,
      notes:
          'Website-Inhalte und rechtlich vorsichtige Aufklärung vorbereiten. '
          'Keine medizinischen Claims ohne Prüfung.',
    ),
    MarketingAction(
      id: 'hb-marketing-newsletter',
      type: MarketingActionType.prepareNewsletter,
      priority: MarketingActionPriority.medium,
      effort: MarketingActionEffort.low,
      impact: MarketingActionImpact.medium,
      status: MarketingActionStatus.planned,
      notes:
          'Newsletter-Entwürfe nur als vorbereitete Inhalte. Keine automatische '
          'Veröffentlichung; Freigabe erst nach menschlicher Prüfung.',
    ),
    MarketingAction(
      id: 'hb-marketing-bot',
      type: MarketingActionType.integrateBotWebsite,
      priority: MarketingActionPriority.high,
      effort: MarketingActionEffort.high,
      impact: MarketingActionImpact.high,
      status: MarketingActionStatus.postponed,
      notes:
          'Bot nicht automatisch veröffentlichen. Zuerst Human Review, No-Go-Regeln '
          'und sensible Wirkungsfragen absichern.',
    ),
  ];

  static final List<SourceMaterial> schnurrPurrSourceMaterials = [
    SourceMaterial(
      id: 'sp-sm1',
      title: 'Website Produktübersicht',
      type: SourceMaterialType.website,
      url: 'https://www.schnurrpurr.example',
      contentSnippet:
          'Kurzbeschreibung der Relax App und des Purr Pillow mit Supportkontakt.',
      status: SourceMaterialStatus.reviewed,
      relatedKnowledgeEntryIds: ['sp-k1', 'sp-k4'],
      createdAt: DateTime(2025, 5, 2),
      updatedAt: DateTime(2025, 5, 4),
    ),
    SourceMaterial(
      id: 'sp-sm2',
      title: 'App-Store Notizen',
      type: SourceMaterialType.note,
      contentSnippet:
          'Entwurfstexte zu Klangwelten, Timern, Erinnerungen und Kontofunktionen.',
      status: SourceMaterialStatus.converted,
      relatedKnowledgeEntryIds: ['sp-k2', 'sp-k3', 'sp-k10'],
      createdAt: DateTime(2025, 5, 6),
      updatedAt: DateTime(2025, 5, 8),
    ),
    SourceMaterial(
      id: 'sp-sm3',
      title: 'Kissen- und Relax-Konzeptnotizen',
      type: SourceMaterialType.note,
      contentSnippet:
          'Material- und Pflegehinweise, Nutzungskontext für Pausen und Komfort.',
      status: SourceMaterialStatus.converted,
      relatedKnowledgeEntryIds: ['sp-k4', 'sp-k5'],
      createdAt: DateTime(2025, 5, 10),
      updatedAt: DateTime(2025, 5, 12),
    ),
    SourceMaterial(
      id: 'sp-sm4',
      title: 'Review-/Trustmaterial Sammlung',
      type: SourceMaterialType.review,
      contentSnippet:
          'Trustmaterial ist erst teilweise vorhanden und noch nicht botfähig freigegeben.',
      status: SourceMaterialStatus.newItem,
      createdAt: DateTime(2025, 5, 16),
      updatedAt: DateTime(2025, 5, 16),
    ),
  ];

  static final IntakeSession hbCureIntakeSession = IntakeSession(
    id: 'intake-hb-cure',
    companyId: 'hb-cure',
    status: IntakeStatus.inProgress,
    currentStepIndex: 6,
    createdAt: DateTime(2025, 5, 20),
    updatedAt: DateTime(2025, 5, 24),
    basics: IntakeBasics(
      companyName: 'Healing und Balance GmbH',
      shortDescription:
          'Healing und Balance GmbH entwickelt und vertreibt Systeme im Bereich Frequenztechnologie. '
          'Die Produkte dienen der ergänzenden Anwendung und ersetzen keine medizinische Diagnose oder Behandlung.',
      industry: 'Gesundheit / Frequenztechnologie',
      country: 'Österreich',
      primaryLanguage: 'de',
      website: 'https://www.healing-balance.com',
      supportEmail: 'semper@healing-balance.com',
      supportPhone: '+43 660 6506900',
      hasWebsite: true,
      additionalLanguages: 'Englisch',
      targetRegions: 'Europäische Union',
    ),
    products: IntakeProducts(
      importantProducts: '',
      mainProduct:
          'Frequenztechnologie und zugehörige Geräte, Anwendungen, Programme und App-Unterstützung',
      explanationNeeded:
          'Anwendung, Bedienung, Wirkungsweise, Programme und Frequenzen, '
          'Einrichtung über die App, Ablauf der Nutzung, Geräteverbindung, '
          'Anleitungen, Sicherheitshinweise und rechtliche Hinweise.',
      priorityProducts: '',
    ),
    targetGroups: IntakeTargetGroups(
      targetGroup: 'Ärzte\nTherapeuten\nEndverbraucher',
      marketType: 'B2B und B2C',
      problemSolved:
          'Kunden benötigen verständliche Informationen zu Anwendung, App-Einrichtung, '
          'Geräteverbindung und sicheren rechtlichen Grenzen.',
      customerBenefit:
          'Besser verständliche Nutzung und klarer Support ohne medizinische Heilversprechen.',
      differentiation:
          'Frequenztechnologie mit App-Unterstützung, Anleitungen und menschlich geprüfter Kommunikation.',
    ),
    websiteAndSupport: IntakeWebsiteAndSupport(
      websiteUrl: 'https://www.healing-balance.com',
      hasFaqArea: true,
      importantPages: 'Startseite, FAQ, rechtliche Hinweise, Support',
      frequentQuestions:
          'Anwendung, Bedienung, Wirkungsweise, Programme und Frequenzen, App-Einrichtung, Ablauf der Nutzung, Geräteverbindung, Anleitungen, Sicherheitshinweise, rechtliche Hinweise.',
      hasSupportQuestions: true,
      supportChannels: '',
      preSalesQuestions:
          'Anwendung\nWirkungsweise\nProgramme und Frequenzen\nrechtliche Hinweise',
      afterSalesQuestions:
          'Einrichtung über die App\nAblauf der Nutzung\nGeräteverbindung\nAnleitungen',
      technicalProblems: 'App-Einrichtung\nGeräteverbindung',
      complaintsOrMisunderstandings:
          'Heilungs-, Diagnose-, Therapie- oder Garantieerwartungen',
      supportOwner: 'GF Klaus Semper',
      standardizableQuestions:
          'App-Einrichtung\nAnleitungen\nGeräteverbindung\nallgemeine rechtliche Hinweise',
      supportProblems:
          'Anfragekanäle noch festlegen. Automatische Antworten: Nein. Menschliche Freigabe: Ja.',
      sensitiveTopics:
          'Medizinische, rechtliche und wirkungsbezogene Fragen; Heilung, Krankheiten, Diagnose, Therapieerfolg und Garantien.',
      hasSensitiveTopics: true,
    ),
    sourcesAndReviews: IntakeSourcesAndReviews(
      existingSources:
          'FAQ\nPDFs\nAnleitungen\nVideos\nrechtliche Hinweise\nWebsite\nBewertungen',
      hasMaterials: true,
      materialDetails: 'FAQ\nPDF\nAnleitungen\nVideos\nrechtliche Hinweise',
      materialLocations: '',
      materialFreshness: '',
      importantMaterials: 'FAQ\nAnleitungen\nrechtliche Hinweise',
      materialsUsableForKnowledgeBase: true,
      reviews:
          'Bewertungen vorhanden; konkrete Plattformen und Links fehlen noch.',
      reviewPlatforms: '',
      reviewLinksOrFiles: '',
      reviewTypes: '',
      hasReviews: true,
      socialMentions:
          'Social Media vorhanden; konkrete Plattformen und Profil-Links fehlen noch.',
      trustMaterial:
          'Bewertungen und rechtliche Hinweise vorhanden, aber vor öffentlicher Nutzung prüfen.',
      hasSocialMentions: true,
      hasTrustMaterial: true,
    ),
    marketingAndChannels: IntakeMarketingAndChannels(
      hasSocialChannels: true,
      socialPlatforms: '',
      socialProfileLinks: '',
      hasRunAds: true,
      advertisingChannels: '',
      approximateBudget: '',
      campaigns:
          'Werbung über mehrere Kanäle; möglichst automatisierte Vorbereitung; einfacher neue Kunden erreichen.',
      futureAdChannels: '',
      channels:
          'Social Media vorhanden. Konkrete Social-Media- und Werbekanäle noch festlegen.',
      reachProblems:
          'Einfacher neue Kunden erreichen\nWerbung für alle Kanäle vorbereitet bekommen',
    ),
    goalsAndRisks: IntakeGoalsAndRisks(
      hasSensitiveTopics: true,
      sensitiveTopics:
          'medizinische Fragen\nrechtliche Fragen\nWirkungsweise\nHeilung\nKrankheiten\nDiagnose\nTherapieerfolg\nGarantien',
      companyGoals:
          'Kundenservice\nWissensdatenbank\nApp-Einrichtung\nMarketingvorbereitung\nAuftragsbearbeitung\nLead-Gewinnung',
      shortTermPriorities:
          'Kundenservice: 5 von 5\nWissensdatenbank: 5 von 5\nMarketing: Noch nicht bewertet\nWebsite: Noch nicht bewertet\nAutomatisierung: Noch nicht bewertet\nSonstiges: Noch nicht bewertet',
      prohibitedStatements:
          'Keine Heilversprechen\nKeine Diagnosen\nKeine Therapieerfolge\nKeine Garantien\nKeine ungeprüften Aussagen zur Aktivierung körpereigener Selbstheilungsprozesse',
      forbiddenClaims:
          'Heilung\nKrankheiten behandeln\nDiagnose stellen\nTherapieerfolg garantieren\närztliche Behandlung ersetzen',
      botRestrictedTopics:
          'medizinische Fragen\nrechtliche Fragen\nsicherheitskritische Nutzung\nwirkungsbezogene Fragen',
      alwaysEscalateTopics:
          'Heilung\nKrankheiten\nDiagnose\nTherapieerfolg\nGarantien\nrechtliche Einordnung',
      legalRestrictions:
          'Antworten dürfen nicht automatisch veröffentlicht oder versendet werden. Human Review ist für sensible Inhalte verpflichtend.',
    ),
  );

  static final IntakeSession schnurrPurrIntakeSession = IntakeSession(
    id: 'intake-schnurr-purr',
    companyId: 'schnurr-purr',
    status: IntakeStatus.inProgress,
    currentStepIndex: 2,
    createdAt: DateTime(2025, 5, 21),
    updatedAt: DateTime(2025, 5, 23),
    basics: IntakeBasics(
      companyName: 'SchnurrPurr',
      shortDescription:
          'Entspannungs-App und Komfortprodukte für ruhige Pausen im Alltag.',
      industry: 'Entspannungs-App & Komfortprodukte',
      country: 'Deutschland',
      primaryLanguage: 'de',
      website: 'https://www.schnurrpurr.example',
      supportEmail: 'support@schnurrpurr.example',
    ),
    products: IntakeProducts(
      importantProducts: 'SchnurrPurr Relax App, Purr Pillow',
      mainProduct: 'SchnurrPurr Relax App',
      explanationNeeded:
          'App-Nutzung, Klangwelten, Pausenroutinen, Kissenpflege.',
      priorityProducts: 'Relax App und Kissen-Komfortinformationen.',
    ),
    targetGroups: IntakeTargetGroups(
      targetGroup:
          'Menschen, die kurze entspannte Pausen und weiche Komfortprodukte suchen.',
      marketType: 'B2C',
      problemSolved:
          'Alltagspausen werden einfacher vorbereitet und angenehmer gestaltet.',
      customerBenefit:
          'Ruhige Routinen und klare Produktinformationen ohne Gesundheitsversprechen.',
      differentiation:
          'Freundlicher Ton, einfache Nutzung und Kombination aus App und Produkt.',
    ),
    websiteAndSupport: IntakeWebsiteAndSupport(
      importantPages: 'Website, Produktseite, Support, App-Hilfe',
      frequentQuestions:
          'App-Start, Timer, Klangwelten, Kissenpflege, Versand.',
      supportProblems: 'Account, App-Erinnerungen, Pflegehinweise.',
      sensitiveTopics:
          'Stress, Schlaf, Therapie oder medizinische Wirkversprechen.',
    ),
  );

  static final List<BusinessGoal> hbCureBusinessGoals = [
    BusinessGoal(
      id: 'hb-goal-support',
      title: 'Kundenservice absichern',
      description:
          'Kundenservice ist mit 5 von 5 priorisiert. Wiederkehrende Fragen '
          'zu Anwendung, Bedienung, App-Einrichtung und Geräteverbindung sollen '
          'vorbereitet, aber nicht automatisch veröffentlicht werden.',
      priority: BusinessGoalPriority.high,
      startDate: DateTime(2025, 6, 1),
      targetDate: DateTime(2025, 9, 30),
      status: BusinessGoalStatus.inProgress,
      owner: 'GF Klaus Semper',
      comment:
          'Human Review standardmäßig aktiv. Medizinische, rechtliche und wirkungsbezogene Fragen immer prüfen.',
      linkedAreas: [
        BusinessGoalArea.knowledgeBase,
        BusinessGoalArea.bot,
        BusinessGoalArea.humanReview,
        BusinessGoalArea.audit,
      ],
    ),
    BusinessGoal(
      id: 'hb-goal-knowledge',
      title: 'Wissensbasis vervollständigen',
      description:
          'Wissensdatenbank ist mit 5 von 5 priorisiert. FAQ, PDFs, Anleitungen, '
          'Videos und rechtliche Hinweise sollen strukturiert übernommen werden.',
      priority: BusinessGoalPriority.high,
      startDate: DateTime(2025, 6, 1),
      targetDate: DateTime(2025, 10, 15),
      status: BusinessGoalStatus.inProgress,
      owner: 'GF Klaus Semper',
      comment:
          'Konkrete Inhalte fehlen teilweise; Platzhalter nicht als fertige Bot-Antworten verwenden.',
      linkedAreas: [
        BusinessGoalArea.knowledgeBase,
        BusinessGoalArea.sources,
        BusinessGoalArea.audit,
        BusinessGoalArea.humanReview,
      ],
    ),
    BusinessGoal(
      id: 'hb-goal-marketing',
      title: 'Marketing vorbereiten',
      description:
          'Werbung und Marketinginhalte sollen für mehrere Kanäle vorbereitet '
          'werden. Konkrete Kanäle und Budgets sind noch offen.',
      priority: BusinessGoalPriority.medium,
      startDate: DateTime(2025, 6, 1),
      targetDate: DateTime(2025, 11, 30),
      status: BusinessGoalStatus.planned,
      owner: 'Marketing / Human Review',
      comment:
          'Keine automatische Veröffentlichung. Content-Freigabe und rechtliche Risikoprüfung bleiben Pflicht.',
      linkedAreas: [
        BusinessGoalArea.marketing,
        BusinessGoalArea.sources,
        BusinessGoalArea.humanReview,
        BusinessGoalArea.controlling,
      ],
    ),
  ];

  static final List<BusinessGoal> schnurrPurrBusinessGoals = [
    BusinessGoal(
      id: 'sp-goal-customers',
      title: 'Mehr Kunden gewinnen',
      description:
          'Website, Social Proof und einfache Inhalte für App und Komfortprodukte ausbauen.',
      priority: BusinessGoalPriority.high,
      startDate: DateTime(2025, 6, 1),
      targetDate: DateTime(2025, 11, 30),
      status: BusinessGoalStatus.inProgress,
      owner: 'Demo Team',
      comment: 'Trustmaterial und Marketing-Basics fehlen noch teilweise.',
      linkedAreas: [
        BusinessGoalArea.marketing,
        BusinessGoalArea.sources,
        BusinessGoalArea.audit,
        BusinessGoalArea.knowledgeBase,
      ],
    ),
    BusinessGoal(
      id: 'sp-goal-bot',
      title: 'Bot ausbauen',
      description:
          'Supportfragen rund um App, Pausenroutinen und Kissenpflege sicher beantworten.',
      priority: BusinessGoalPriority.medium,
      startDate: DateTime(2025, 6, 5),
      targetDate: DateTime(2025, 10, 31),
      status: BusinessGoalStatus.planned,
      owner: 'Support',
      linkedAreas: [
        BusinessGoalArea.bot,
        BusinessGoalArea.knowledgeBase,
        BusinessGoalArea.humanReview,
        BusinessGoalArea.projectStatus,
      ],
    ),
  ];

  static final List<CompanyWorkspace> companyWorkspaces = [
    CompanyWorkspace(
      company: company,
      products: products,
      knowledgeEntries: knowledgeEntries,
      botLogs: botLogs,
      auditItems: hbCureAuditItems,
      businessRules: hbCureBusinessRules,
      botConfiguration: hbCureBotConfiguration,
      sourceMaterials: hbCureSourceMaterials,
      marketingActions: hbCureMarketingActions,
      businessGoals: hbCureBusinessGoals,
      intakeSession: hbCureIntakeSession,
    ),
    CompanyWorkspace(
      company: schnurrPurrCompany,
      products: schnurrPurrProducts,
      knowledgeEntries: schnurrPurrKnowledgeEntries,
      botLogs: schnurrPurrBotLogs,
      auditItems: schnurrPurrAuditItems,
      businessRules: schnurrPurrBusinessRules,
      botConfiguration: schnurrPurrBotConfiguration,
      sourceMaterials: schnurrPurrSourceMaterials,
      businessGoals: schnurrPurrBusinessGoals,
      intakeSession: schnurrPurrIntakeSession,
    ),
  ];
}
