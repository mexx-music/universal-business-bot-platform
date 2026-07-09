import '../models/company.dart';
import '../models/company_workspace.dart';
import '../models/product_or_service.dart';
import '../models/knowledge_entry.dart';
import '../models/bot_question_log.dart';

class MockData {
  static final Company company = Company(
    id: 'hb-cure',
    name: 'HB Cure',
    industry: 'Digitale Gesundheits-App',
    description:
        'HB Cure verbindet ein biometrisches Messgerät mit einer mobilen App, '
        'die Nutzern hilft, ihre Körperwerte zu verfolgen und ihr persönliches Wohlbefinden '
        'besser zu verstehen – einfach, sicher und datenschutzkonform nach EU-DSGVO.',
    website: 'https://www.hbcure.at',
    email: 'support@hbcure.at',
    phone: '+43 720 123 456',
    address: 'Wiedner Hauptstraße 10, 1040 Wien',
  );

  static final List<ProductOrService> products = [
    ProductOrService(
      id: 'p1',
      name: 'HB Cure App',
      description:
          'Kostenlose iOS- & Android-App zur Anzeige und Auswertung Ihrer persönlichen Messwerte.',
      type: ProductType.produkt,
    ),
    ProductOrService(
      id: 'p2',
      name: 'HB Cure Messgerät Pro',
      description:
          'Biometrisches Messgerät mit Bluetooth-Anbindung, IPX4-Schutz und 10-Tage-Akku.',
      type: ProductType.produkt,
      price: 149.0,
    ),
    ProductOrService(
      id: 'p3',
      name: 'Premium Support',
      description:
          'Priorisierter Support, erweiterte App-Auswertungen und Datenexport (9,90 €/Monat).',
      type: ProductType.dienstleistung,
      price: 9.90,
    ),
  ];

  static final List<KnowledgeEntry> knowledgeEntries = [
    // ── Einstieg ──────────────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k1',
      languageCode: 'de',
      title: 'Wie starte ich mit HB Cure?',
      content:
          'Laden Sie die HB Cure App kostenlos aus dem App Store oder Google Play herunter. '
          'Erstellen Sie ein Konto, verbinden Sie das Messgerät per Bluetooth und folgen Sie '
          'der Schritt-für-Schritt-Anleitung unter „Erste Schritte" in der App.',
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
      source: 'Onboarding-Guide',
      createdAt: DateTime(2025, 1, 10),
    ),
    KnowledgeEntry(
      id: 'k2',
      languageCode: 'de',
      title: 'Was kostet HB Cure?',
      content:
          'Die HB Cure App ist kostenlos erhältlich. Das Messgerät HB Cure Pro kostet 149 €. '
          'Ein optionales Premium-Abo (9,90 €/Monat) bietet erweiterte Auswertungen, '
          'Datenexport und Priority-Support.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: [
        'kosten',
        'preis',
        'kaufen',
        'abo',
        'premium',
        'euro',
        'kostet',
        'günstig',
      ],
      source: 'Preisliste',
      createdAt: DateTime(2025, 1, 11),
    ),

    // ── Gerät & Technik ───────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k3',
      languageCode: 'de',
      title: 'Wie verbinde ich das Messgerät mit der App?',
      content:
          'Aktivieren Sie Bluetooth auf Ihrem Smartphone. Öffnen Sie die HB Cure App, '
          'tippen Sie auf „Gerät verbinden" und halten Sie das Messgerät nahe ans Telefon. '
          'Die Verbindung wird automatisch in wenigen Sekunden hergestellt.',
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
      source: 'Geräte-Handbuch',
      createdAt: DateTime(2025, 1, 15),
    ),
    KnowledgeEntry(
      id: 'k4',
      languageCode: 'de',
      title: 'Welche Smartphones werden unterstützt?',
      content:
          'Die HB Cure App ist kompatibel mit iOS 14+ (iPhone 8 und neuer) und Android 9.0+. '
          'Für eine stabile Bluetooth-Verbindung empfehlen wir aktuelle Betriebssystemversionen.',
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
      source: 'Technische Anforderungen',
      createdAt: DateTime(2025, 1, 16),
    ),
    KnowledgeEntry(
      id: 'k5',
      languageCode: 'de',
      title: 'Wie lade ich das Messgerät auf?',
      content:
          'Das Messgerät wird über das mitgelieferte USB-C-Kabel aufgeladen. '
          'Eine vollständige Ladung dauert ca. 90 Minuten und reicht für ca. 10 Messtage. '
          'Der Ladestand wird in der App und durch eine LED am Gerät angezeigt.',
      category: KnowledgeCategory.produkt,
      riskLevel: RiskLevel.green,
      keywords: [
        'aufladen',
        'akku',
        'laden',
        'usb',
        'usb-c',
        'batterie',
        'ladestand',
        'laufzeit',
      ],
      source: 'Geräte-Handbuch',
      createdAt: DateTime(2025, 1, 17),
    ),
    KnowledgeEntry(
      id: 'k6',
      languageCode: 'de',
      title: 'Ist das Messgerät wasserdicht?',
      content:
          'Das HB Cure Messgerät ist nach IPX4 gegen Spritzwasser von allen Seiten geschützt. '
          'Es ist nicht zum Tauchen oder zum längeren Untertauchen geeignet. '
          'Nach Wasserkontakt bitte sofort mit einem trockenen Tuch abtupfen.',
      category: KnowledgeCategory.produkt,
      riskLevel: RiskLevel.green,
      keywords: [
        'wasserdicht',
        'ipx',
        'wasser',
        'spritzwasser',
        'nass',
        'duschen',
        'regen',
      ],
      source: 'Geräte-Handbuch',
      createdAt: DateTime(2025, 1, 18),
    ),
    KnowledgeEntry(
      id: 'k7',
      languageCode: 'de',
      title: 'Messgerät verbindet sich nicht – was tun?',
      content:
          '1. Prüfen Sie, ob Bluetooth aktiviert ist. '
          '2. Starten Sie App und Gerät neu. '
          '3. Stellen Sie sicher, dass der Akku min. 20 % hat. '
          '4. Löschen Sie die Gerätekopplung in der App und verbinden Sie neu. '
          'Hilft das nicht, kontaktieren Sie uns unter support@hbcure.at.',
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
      source: 'Support-Wiki',
      createdAt: DateTime(2025, 2, 1),
    ),

    // ── App & Funktionen ──────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k8',
      languageCode: 'de',
      title: 'Was zeigt das Dashboard in der App an?',
      content:
          'Das App-Dashboard zeigt Ihre aktuellen Messwerte, Verlaufsgraphen der letzten 30 Tage, '
          'eine persönliche Tagesübersicht und Push-Benachrichtigungen. '
          'Alle Daten werden lokal verschlüsselt gespeichert.',
      category: KnowledgeCategory.produkt,
      riskLevel: RiskLevel.green,
      keywords: [
        'dashboard',
        'app',
        'anzeigen',
        'messwerte',
        'übersicht',
        'verlauf',
        'funktionen',
      ],
      source: 'App-Dokumentation',
      createdAt: DateTime(2025, 2, 5),
    ),
    KnowledgeEntry(
      id: 'k9',
      languageCode: 'de',
      title: 'Wie oft sollte ich messen?',
      content:
          'Wir empfehlen eine Messung täglich zur gleichen Zeit – vorzugsweise morgens nach dem Aufwachen – '
          'für verlässliche Vergleichswerte. Die App erinnert Sie automatisch per Benachrichtigung.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: [
        'messen',
        'häufigkeit',
        'täglich',
        'wann',
        'messung',
        'wie oft',
        'morgens',
      ],
      source: 'App-Dokumentation',
      createdAt: DateTime(2025, 2, 6),
    ),
    KnowledgeEntry(
      id: 'k10',
      languageCode: 'de',
      title: 'Wie werden meine Daten gespeichert?',
      content:
          'Ihre Messdaten werden verschlüsselt auf Ihrem Gerät gespeichert und optional '
          'in unserer sicheren EU-Cloud synchronisiert (DSGVO-konform, Serverstandort Wien). '
          'Wir geben keine Daten an Dritte weiter. Details: hbcure.at/datenschutz.',
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
      source: 'Datenschutzerklärung',
      createdAt: DateTime(2025, 2, 10),
    ),

    // ── Support ───────────────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k11',
      languageCode: 'de',
      title: 'Wie erreiche ich den Support?',
      content:
          'Unser Support-Team ist per E-Mail support@hbcure.at (Mo–Fr, 9–17 Uhr) '
          'und über den In-App-Chat erreichbar. '
          'Premium-Kunden haben zusätzlich Zugang zu priorisierten Support-Tickets mit 4h-Reaktionszeit.',
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
      source: 'Support-Wiki',
      createdAt: DateTime(2025, 2, 12),
    ),

    // ── Wellness (Yellow) ─────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k12',
      languageCode: 'de',
      title: 'Kann HB Cure mir bei meinem Wohlbefinden helfen?',
      content:
          'HB Cure unterstützt Sie dabei, Ihre persönlichen Körperwerte besser zu verstehen '
          'und Veränderungen im Zeitverlauf zu beobachten. Viele Nutzer berichten, '
          'dass regelmäßiges Tracking ihnen hilft, einen bewussteren Lebensstil zu pflegen. '
          'HB Cure ist kein Medizinprodukt und ersetzt keine ärztliche Beratung.',
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
      source: 'Website FAQ',
      createdAt: DateTime(2025, 3, 1),
    ),
    KnowledgeEntry(
      id: 'k13',
      languageCode: 'de',
      title: 'Was bedeutet ein hoher oder niedriger Messwert?',
      content:
          'Die App zeigt Ihre Messwerte im Kontext Ihrer persönlichen Baseline. '
          'Abweichungen können auf Faktoren wie Schlaf, Stress oder körperliche Aktivität hinweisen. '
          'Für eine medizinische Einschätzung Ihrer Werte wenden Sie sich bitte an einen Arzt.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.yellow,
      keywords: [
        'messwert',
        'hoch',
        'niedrig',
        'wert',
        'bedeutung',
        'ergebnis',
        'normal',
        'abweichung',
      ],
      source: 'App-Dokumentation',
      createdAt: DateTime(2025, 3, 5),
    ),

    // ── Rechtliche No-Go-Bereiche (Red – Bot verweist, antwortet nicht) ──
    KnowledgeEntry(
      id: 'k14',
      languageCode: 'de',
      title: 'Heilversprechen und medizinische Diagnosen',
      content:
          'HB Cure ist kein Medizinprodukt und darf keine medizinischen Diagnosen stellen '
          'oder Heilversprechen machen. Bitte wenden Sie sich bei medizinischen Fragen an einen Arzt.',
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
          'HB Cure macht keine Aussagen zu spezifischen Erkrankungen und ersetzt keine ärztliche Behandlung. '
          'Bei Beschwerden wenden Sie sich bitte an einen Arzt oder Apotheker.',
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
      answer:
          'Die HB Cure App ist kostenlos erhältlich. Das Messgerät kostet 149 €.',
      matched: true,
      redirected: false,
      timestamp: DateTime(2025, 6, 2, 9, 45),
      reviewStatus: ReviewStatus.closed,
      reviewedAt: DateTime(2025, 6, 2, 9, 45),
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
  ];

  static final Company schnurrPurrCompany = Company(
    id: 'schnurr-purr',
    name: 'SchnurrPurr',
    industry: 'Entspannungs-App & Komfortprodukte',
    description:
        'SchnurrPurr entwickelt ruhige digitale Begleiter und weiche Komfortprodukte '
        'für entspannte Pausen im Alltag. Die Angebote helfen beim Abschalten, '
        'bei kleinen Routinen und beim bewussten Umgang mit Erholungszeiten.',
    website: 'https://www.schnurrpurr.example',
    email: 'support@schnurrpurr.example',
    phone: '+43 720 987 654',
    address: 'Schottenfeldgasse 22, 1070 Wien',
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

  static final List<CompanyWorkspace> companyWorkspaces = [
    CompanyWorkspace(
      company: company,
      products: products,
      knowledgeEntries: knowledgeEntries,
      botLogs: botLogs,
    ),
    CompanyWorkspace(
      company: schnurrPurrCompany,
      products: schnurrPurrProducts,
      knowledgeEntries: schnurrPurrKnowledgeEntries,
      botLogs: schnurrPurrBotLogs,
    ),
  ];
}
