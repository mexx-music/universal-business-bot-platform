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
    industry: 'Health / frequency technology',
    description:
        'Healing und Balance GmbH develops and distributes systems in the '
        'field of frequency technology. The products are intended for '
        'complementary use and do not replace medical diagnosis or treatment.',
    country: 'Austria',
    primaryLanguage: 'en',
    website: 'https://www.healing-balance.com',
    email: 'semper@healing-balance.com',
    phone: '+43 660 6506900',
    address: 'European Union',
    socialLinks: {
      'website': 'https://www.healing-balance.com',
      'social_media': 'Available; exact platforms still need to be clarified',
    },
    internalNotes:
        'Contact person: Managing Director Klaus Semper. HB Cure workspace '
        'for Healing und Balance GmbH. The company provided an internal '
        'self-healing-process wording. Do not use this claim publicly without '
        'review. Open company details: most important offers, exact inquiry '
        'channels, marketing priority, website priority, automation priority, '
        'other priority, exact social media platforms and exact advertising '
        'channels.',
  );

  static final List<ProductOrService> products = [
    ProductOrService(
      id: 'p1',
      name: 'Frequency technology with app support',
      description:
          'Systems and applications in the field of frequency technology with '
          'app-guided setup and understandable usage flows.',
      type: ProductType.produkt,
    ),
    ProductOrService(
      id: 'p2',
      name: 'Programs and frequencies',
      description:
          'Structured program and frequency information for complementary use '
          'flows. Specific content must be reviewed before publication.',
      type: ProductType.produkt,
    ),
    ProductOrService(
      id: 'p3',
      name: 'Setup, guidance and support',
      description:
          'Support for app setup, device connection, usage flow, instructions '
          'and legally safe guidance.',
      type: ProductType.dienstleistung,
    ),
  ];

  static final List<KnowledgeEntry> knowledgeEntries = [
    // ── Einstieg ──────────────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k1',
      languageCode: 'en',
      title: 'How do I get started?',
      content:
          'Open the app, follow the setup step by step and connect the related '
          'device if this is part of your use case. Use the available '
          'instructions and contact support if anything is unclear.',
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
      source: 'Company intake Klaus / instructions',
      createdAt: DateTime(2025, 1, 10),
    ),
    KnowledgeEntry(
      id: 'k2',
      languageCode: 'en',
      title: 'Which offers are currently captured?',
      content:
          'Captured offers include frequency technology, related devices, '
          'applications, programs and app support. Which offers are most '
          'important still needs to be clarified and must not be assumed automatically.',
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
      source: 'Company intake Klaus',
      createdAt: DateTime(2025, 1, 11),
    ),

    // ── Gerät & Technik ───────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k3',
      languageCode: 'en',
      title: 'How do I connect the device with the app?',
      content:
          'Enable the required connection on your smartphone. Open the app and '
          'follow the device connection instructions. If the connection does not '
          'work, check battery level, distance and the relevant step-by-step guide.',
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
      source: 'Instructions',
      createdAt: DateTime(2025, 1, 15),
    ),
    KnowledgeEntry(
      id: 'k4',
      languageCode: 'en',
      title: 'Which smartphones are supported?',
      content:
          'The exact technical requirements must be taken from current app and '
          'device documentation. Until then, support should ask for device, '
          'operating system and app version.',
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
      source: 'App and product notes',
      createdAt: DateTime(2025, 1, 16),
    ),
    KnowledgeEntry(
      id: 'k5',
      languageCode: 'en',
      title: 'Where can I find programs and frequencies?',
      content:
          'Information about programs and frequencies should be taken from '
          'reviewed documents, instructions or approved app copy. Effect-related '
          'statements require human review before publication.',
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
      source: 'Company intake Klaus',
      createdAt: DateTime(2025, 1, 17),
    ),
    KnowledgeEntry(
      id: 'k6',
      languageCode: 'en',
      title: 'Which safety notes apply?',
      content:
          'Safety notes must be taken from reviewed documents. The bot must not '
          'recommend use when a question is medical, legal or safety-critical. '
          'These cases are routed to Human Review.',
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
      source: 'Safety and legal guidance',
      createdAt: DateTime(2025, 1, 18),
    ),
    KnowledgeEntry(
      id: 'k7',
      languageCode: 'en',
      title: 'The device does not connect. What should I do?',
      content:
          'First check the connection settings, restart the app and device and '
          'follow the current instructions. If that does not help, contact '
          'support at semper@healing-balance.com.',
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
      source: 'Instructions',
      createdAt: DateTime(2025, 2, 1),
    ),

    // ── App & Funktionen ──────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k8',
      languageCode: 'en',
      title: 'What does the app dashboard show?',
      content:
          'The app should present setup, flow and relevant usage guidance in an '
          'understandable way. Specific app functions are added to the knowledge '
          'base only from approved product documents.',
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
      source: 'Company intake Klaus',
      createdAt: DateTime(2025, 2, 5),
    ),
    KnowledgeEntry(
      id: 'k9',
      languageCode: 'en',
      title: 'What does the usage flow look like?',
      content:
          'The exact flow should be described using approved instructions. The '
          'bot may explain organizational steps only and must not recommend '
          'medical effects or usage frequency.',
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
      source: 'Company intake Klaus',
      createdAt: DateTime(2025, 2, 6),
    ),
    KnowledgeEntry(
      id: 'k10',
      languageCode: 'en',
      title: 'How is my data stored?',
      content:
          'Data protection information must be taken from the current privacy '
          'policy. Until the details are reviewed, the bot refers to the website '
          'and does not make technical privacy promises.',
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
      source: 'Legal guidance',
      createdAt: DateTime(2025, 2, 10),
    ),

    // ── Support ───────────────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k11',
      languageCode: 'en',
      title: 'How can I contact support?',
      content:
          'The internal contact person is Managing Director Klaus Semper. '
          'Support email is semper@healing-balance.com. Exact inquiry channels '
          'such as form, phone, messenger or social media still need to be clarified.',
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
      source: 'Company intake Klaus',
      createdAt: DateTime(2025, 2, 12),
    ),

    // ── Wellness (Yellow) ─────────────────────────────────────────────
    KnowledgeEntry(
      id: 'k12',
      languageCode: 'en',
      title: 'What are the systems intended for?',
      content:
          'The systems from Healing und Balance GmbH are described for '
          'complementary applications in the field of frequency technology. '
          'They do not replace medical diagnosis or treatment. Effect-related '
          'questions require human review.',
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
      source: 'Safe public description',
      createdAt: DateTime(2025, 3, 1),
    ),
    KnowledgeEntry(
      id: 'k13',
      languageCode: 'en',
      title: 'How may effects be described?',
      content:
          'Descriptions of effects must remain neutral and evidence-based. '
          'Unchecked statements about healing, diagnosis, therapy success or '
          'guarantees must not be published.',
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
      source: 'Legal guidance',
      createdAt: DateTime(2025, 3, 5),
    ),

    // ── Rechtliche No-Go-Bereiche (Red – Bot verweist, antwortet nicht) ──
    KnowledgeEntry(
      id: 'k14',
      languageCode: 'en',
      title: 'Healing promises and medical diagnoses',
      content:
          'The bot must not make medical diagnoses, healing promises or '
          'treatment-success claims. For medical questions, users should contact '
          'qualified professionals.',
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
      source: 'Legal guidelines',
      createdAt: DateTime(2025, 3, 10),
    ),
    KnowledgeEntry(
      id: 'k15',
      languageCode: 'en',
      title: 'Specific diseases and medication replacement',
      content:
          'Healing und Balance GmbH does not make bot statements about specific '
          'diseases and does not replace medical treatment. For symptoms, users '
          'should contact a doctor or pharmacist.',
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
      source: 'Legal guidelines',
      createdAt: DateTime(2025, 3, 10),
    ),
    KnowledgeEntry(
      id: 'k16',
      languageCode: 'en',
      title: 'Use: content missing',
      content:
          'Add document: approved content from instructions, training or support '
          'is still missing for concrete usage steps.',
      category: KnowledgeCategory.prozess,
      riskLevel: RiskLevel.yellow,
      keywords: ['anwendung', 'inhalt fehlt', 'dokument hinzufügen'],
      source: 'Open company details',
      createdAt: DateTime(2025, 5, 24),
    ),
    KnowledgeEntry(
      id: 'k17',
      languageCode: 'en',
      title: 'Devices: content missing',
      content:
          'Add document: device-specific information must be taken from current '
          'product documents and reviewed.',
      category: KnowledgeCategory.produkt,
      riskLevel: RiskLevel.yellow,
      keywords: ['geräte', 'inhalt fehlt', 'produktunterlagen'],
      source: 'Open company details',
      createdAt: DateTime(2025, 5, 24),
    ),
    KnowledgeEntry(
      id: 'k18',
      languageCode: 'en',
      title: 'App and setup: content missing',
      content:
          'Add FAQ: concrete step-by-step answers should be added for app setup, '
          'device connection and typical troubleshooting cases.',
      category: KnowledgeCategory.prozess,
      riskLevel: RiskLevel.green,
      keywords: ['app', 'einrichtung', 'faq ergänzen'],
      source: 'Open company details',
      createdAt: DateTime(2025, 5, 24),
    ),
    KnowledgeEntry(
      id: 'k19',
      languageCode: 'en',
      title: 'Programs and frequencies: review required',
      content:
          'Add FAQ: statements about programs, frequencies and effects must be '
          'professionally and legally reviewed before use in bot or marketing.',
      category: KnowledgeCategory.allgemein,
      riskLevel: RiskLevel.yellow,
      keywords: ['programme', 'frequenzen', 'prüfung erforderlich'],
      source: 'Open company details',
      createdAt: DateTime(2025, 5, 24),
    ),
    KnowledgeEntry(
      id: 'k20',
      languageCode: 'en',
      title: 'Videos: content missing',
      content:
          'Link video: existing videos should be captured as sources and used '
          'for the knowledge base or marketing only after review.',
      category: KnowledgeCategory.allgemein,
      riskLevel: RiskLevel.green,
      keywords: ['videos', 'video verknüpfen', 'quelle'],
      source: 'Open company details',
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
      question: 'How do I connect the device?',
      answer: 'Enable the required connection on your smartphone...',
      matched: true,
      redirected: false,
      timestamp: DateTime(2025, 6, 1, 10, 23),
      reviewStatus: ReviewStatus.closed,
      reviewedAt: DateTime(2025, 6, 1, 10, 23),
    ),
    BotQuestionLog(
      id: 'b2',
      question: 'How much does the app cost?',
      answer: null,
      matched: false,
      redirected: false,
      timestamp: DateTime(2025, 6, 2, 9, 45),
      reviewStatus: ReviewStatus.open,
      reviewReason: ReviewReason.noMatch,
      humanNote: 'Prices were not provided by Klaus. Do not invent them.',
    ),
    BotQuestionLog(
      id: 'b3',
      question: 'Can HB Cure heal my high blood pressure?',
      answer: null,
      matched: false,
      redirected: true,
      timestamp: DateTime(2025, 6, 3, 14, 12),
      reviewStatus: ReviewStatus.open,
      reviewReason: ReviewReason.redFlag,
    ),
    BotQuestionLog(
      id: 'b4',
      question: 'How long does the battery last?',
      answer: null,
      matched: false,
      redirected: false,
      timestamp: DateTime(2025, 6, 4, 11, 30),
      reviewStatus: ReviewStatus.open,
      reviewReason: ReviewReason.noMatch,
    ),
    BotQuestionLog(
      id: 'b5',
      question: 'Which frequency helps with pain?',
      answer: null,
      matched: false,
      redirected: true,
      timestamp: DateTime(2025, 6, 5, 15, 5),
      reviewStatus: ReviewStatus.open,
      reviewReason: ReviewReason.redFlag,
      humanNote:
          'Medically sensitive effect-related question. No automatic approval.',
    ),
    BotQuestionLog(
      id: 'b6',
      question: 'How do I set up the app for the device?',
      answer:
          'A draft answer may be prepared, but it must be checked against the '
          'current instructions before use.',
      matched: true,
      redirected: false,
      timestamp: DateTime(2025, 6, 5, 16, 20),
      reviewStatus: ReviewStatus.reviewed,
      reviewReason: ReviewReason.yellowRisk,
      humanNote:
          'Human Review remains active until concrete instructions are approved.',
      reviewedAt: DateTime(2025, 6, 5, 16, 45),
    ),
  ];

  static final Company schnurrPurrCompany = Company(
    id: 'schnurr-purr',
    name: 'SchnurrPurr',
    industry: 'Relaxation app & comfort products',
    description:
        'SchnurrPurr develops calm digital companions and soft comfort products '
        'for relaxed everyday breaks. The offers support small routines, mindful '
        'pauses and a gentle approach to recovery time.',
    country: 'Austria',
    primaryLanguage: 'en',
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
        'Demo workspace for app and comfort-product communication without medical claims.',
  );

  static final List<ProductOrService> schnurrPurrProducts = [
    ProductOrService(
      id: 'sp-p1',
      name: 'SchnurrPurr Relax App',
      description:
          'Mobile app with breathing timers, calm soundscapes and simple break routines.',
      type: ProductType.produkt,
    ),
    ProductOrService(
      id: 'sp-p2',
      name: 'SchnurrPurr Kissen / Purr Pillow',
      description:
          'Soft comfort pillow with removable cover for the sofa, reading chair or short quiet breaks.',
      type: ProductType.produkt,
      price: 49.0,
    ),
  ];

  static final List<KnowledgeEntry> schnurrPurrKnowledgeEntries = [
    KnowledgeEntry(
      id: 'sp-k1',
      languageCode: 'en',
      title: 'What is the SchnurrPurr Relax App?',
      content:
          'The SchnurrPurr Relax App offers short break routines, gentle '
          'soundscapes and simple timers for mindful relaxation moments in everyday life.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: ['app', 'relax app', 'entspannung', 'pause', 'klang', 'timer'],
      source: 'Product FAQ',
      createdAt: DateTime(2025, 4, 2),
    ),
    KnowledgeEntry(
      id: 'sp-k2',
      languageCode: 'en',
      title: 'How do I start a relaxation routine?',
      content:
          'Open the app, choose a routine and set the desired duration. You can '
          'pause or end the exercise at any time.',
      category: KnowledgeCategory.prozess,
      riskLevel: RiskLevel.green,
      keywords: ['routine', 'starten', 'dauer', 'übung', 'pause', 'beenden'],
      source: 'App help',
      createdAt: DateTime(2025, 4, 4),
    ),
    KnowledgeEntry(
      id: 'sp-k3',
      languageCode: 'en',
      title: 'Can I use the app without an account?',
      content:
          'Yes, basic functions such as timers and selected soundscapes can be '
          'used without an account. An account is only required for synchronization '
          'and optional favorites.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: [
        'konto',
        'ohne konto',
        'login',
        'basisfunktionen',
        'favoriten',
      ],
      source: 'App help',
      createdAt: DateTime(2025, 4, 5),
    ),
    KnowledgeEntry(
      id: 'sp-k4',
      languageCode: 'en',
      title: 'What is the SchnurrPurr pillow?',
      content:
          'The SchnurrPurr pillow is a soft comfort pillow with a washable cover. '
          'It is designed for cozy breaks, reading and quiet moments.',
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
      source: 'Product sheet',
      createdAt: DateTime(2025, 4, 8),
    ),
    KnowledgeEntry(
      id: 'sp-k5',
      languageCode: 'en',
      title: 'How do I clean the pillow cover?',
      content:
          'The cover can be removed and washed at low temperature. Please follow '
          'the care label and let the cover dry completely.',
      category: KnowledgeCategory.produkt,
      riskLevel: RiskLevel.green,
      keywords: ['reinigen', 'waschen', 'bezug', 'pflege', 'trocknen'],
      source: 'Care instructions',
      createdAt: DateTime(2025, 4, 10),
    ),
    KnowledgeEntry(
      id: 'sp-k6',
      languageCode: 'en',
      title: 'Which devices does the app support?',
      content:
          'The app supports current iOS and Android devices. For sound content, '
          'we recommend a stable internet connection or previously saved favorites.',
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
      source: 'Technical requirements',
      createdAt: DateTime(2025, 4, 12),
    ),
    KnowledgeEntry(
      id: 'sp-k7',
      languageCode: 'en',
      title: 'Does SchnurrPurr help with stress or sleep problems?',
      content:
          'SchnurrPurr can support calm breaks and relaxation routines. The '
          'products do not diagnose, treat complaints or replace professional medical advice.',
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
      source: 'Safe communication guidelines',
      createdAt: DateTime(2025, 4, 15),
    ),
    KnowledgeEntry(
      id: 'sp-k8',
      languageCode: 'en',
      title: 'Which statements must the bot avoid?',
      content:
          'The bot must not make healing promises, diagnoses or statements about '
          'treating diseases. For health questions, it should refer users to qualified professionals.',
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
      source: 'Safe communication guidelines',
      createdAt: DateTime(2025, 4, 16),
    ),
    KnowledgeEntry(
      id: 'sp-k9',
      languageCode: 'en',
      title: 'How can I contact support?',
      content:
          'Support is available by email at support@schnurrpurr.example. For app '
          'questions, please include the device you use and the app version.',
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
      source: 'Support wiki',
      createdAt: DateTime(2025, 4, 18),
    ),
    KnowledgeEntry(
      id: 'sp-k10',
      languageCode: 'en',
      title: 'Can I disable reminders?',
      content:
          'Yes, reminders can be enabled, paused or fully disabled in the app settings at any time.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: [
        'erinnerung',
        'benachrichtigung',
        'deaktivieren',
        'pausieren',
        'einstellungen',
      ],
      source: 'App help',
      createdAt: DateTime(2025, 4, 20),
    ),
  ];

  static final List<BotQuestionLog> schnurrPurrBotLogs = [
    BotQuestionLog(
      id: 'sp-b1',
      question: 'How do I start a routine?',
      answer: 'Open the app, choose a routine and set the desired duration.',
      matched: true,
      redirected: false,
      timestamp: DateTime(2025, 6, 6, 8, 40),
      reviewStatus: ReviewStatus.closed,
      reviewedAt: DateTime(2025, 6, 6, 8, 40),
    ),
    BotQuestionLog(
      id: 'sp-b2',
      question: 'Can the app treat my sleep problems?',
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
      title: 'Company profile complete',
      description:
          'Company name, industry, website, contact person, email and phone '
          'are maintained for this workspace.',
      status: AuditItemStatus.complete,
      priority: AuditPriority.medium,
      recommendation:
          'Regularly check whether contact and support details are still current.',
    ),
    BusinessAuditItem(
      id: 'hb-a2',
      area: AuditArea.website,
      title: 'Website available',
      description:
          'A website is available and can be used as the primary public source.',
      status: AuditItemStatus.complete,
      priority: AuditPriority.medium,
      note: 'https://www.healing-balance.com is stored in the company profile.',
    ),
    BusinessAuditItem(
      id: 'hb-a3',
      area: AuditArea.products,
      title: 'Products and services captured',
      description:
          'Frequency technology, devices, applications, programs and app support '
          'are broadly captured. The most important offers were not prioritized in the form.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      note: 'Open: Which offers are most important?',
      recommendation:
          'Clarify product priorities with Klaus before bot or marketing logic derives recommendations from them.',
    ),
    BusinessAuditItem(
      id: 'hb-a4',
      area: AuditArea.supportKnowledge,
      title: 'Expand FAQ and support knowledge',
      description:
          'FAQ, PDFs, instructions, videos and legal guidance exist, but concrete '
          'content still needs to be structured and imported.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      recommendation:
          'Add FAQ content for use, operation, app setup, programs, frequencies '
          'and troubleshooting.',
    ),
    BusinessAuditItem(
      id: 'hb-a5',
      area: AuditArea.trustMaterial,
      title: 'Website reviews available',
      description:
          'Reviews exist. Platforms, links and approval status were not provided yet.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.medium,
      recommendation:
          'Document review sources, permitted quotes and usage rights before marketing use.',
    ),
    BusinessAuditItem(
      id: 'hb-a6',
      area: AuditArea.socialPresence,
      title: 'Social reviews need work',
      description:
          'Social media exists, but concrete platforms, profiles and performance '
          'data have not been named yet.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.low,
      recommendation: 'Capture exact social media platforms and profile links.',
    ),
    BusinessAuditItem(
      id: 'hb-a7',
      area: AuditArea.sources,
      title: 'Structure sources and documents',
      description:
          'FAQ, PDFs, instructions, videos and legal guidance exist; storage '
          'locations, freshness and approval still need to be checked.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.medium,
      recommendation:
          'Capture documents by category: use, devices, app, programs, FAQ, PDFs, videos and legal.',
    ),
    BusinessAuditItem(
      id: 'hb-a8',
      area: AuditArea.riskRules,
      title: 'No-go rules for medical claims',
      description:
          'Red rules are required for healing promises, diagnoses, therapy '
          'success, diseases, legal statements and guarantees.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      recommendation:
          'Always classify sensitive, medical, legal and effect-related questions as at least yellow or red.',
    ),
    BusinessAuditItem(
      id: 'hb-a9',
      area: AuditArea.botReadiness,
      title: 'Bot readiness',
      description:
          'Automatic answers are not approved. The bot may prepare drafts only; '
          'human review remains the default.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      recommendation:
          'Review answer drafts in Human Review and use them for bot testing only after approval.',
    ),
    BusinessAuditItem(
      id: 'hb-a10',
      area: AuditArea.companyProfile,
      title: 'Open company details',
      description:
          'Most important offers, inquiry channels, exact social media platforms, '
          'exact advertising channels and several priorities are still missing.',
      status: AuditItemStatus.missing,
      priority: AuditPriority.high,
      note:
          'Customer service and knowledge base priorities are confirmed as 5 out of 5. Marketing, website, automation and other remain unrated.',
      recommendation:
          'Complete the open company details in the questionnaire before deriving automatic recommendations from them.',
    ),
  ];

  static const BusinessRules hbCureBusinessRules = BusinessRules(
    brandVoice:
        'Clear, factual and careful. Explain complementary use without promising '
        'medical effects or therapy success.',
    doNotSay: [
      'No healing promises',
      'No diagnoses',
      'No statements that replace medical advice',
      'No medication or therapy recommendations',
      'No guarantee of effect, treatment success or healing',
      'Do not publicly use internal self-healing-process wording without review',
    ],
    allowedSupportTopics: [
      'App usage',
      'Device connection',
      'Usage flow',
      'Instructions',
      'Programs and frequencies without effect claims',
      'Support contact',
      'Data protection and legal guidance at a general level',
    ],
    escalationNotes:
        'Always route medical, legal, safety-critical or effect-related questions '
        'to Human Review. Answers must not be published automatically.',
    disclaimerText:
        'The products are intended for complementary use and do not replace medical diagnosis or treatment.',
  );

  static const BotConfiguration hbCureBotConfiguration = BotConfiguration(
    status: BotStatus.testReady,
    answerStyle: BotAnswerStyle.balanced,
    defaultLanguage: 'en',
    useDisclaimer: true,
    disclaimerText:
        'Note: The products are intended for complementary use and do not replace medical diagnosis or treatment.',
    alwaysEscalateRedFlags: true,
    escalateNoMatch: true,
    escalateYellowRisk: true,
    allowedTopics: [
      'App usage',
      'Device connection',
      'Usage flow',
      'Instructions',
      'Programs and frequencies without effect claims',
      'Support',
      'General legal guidance',
    ],
    blockedTopics: [
      'Diagnoses',
      'Healing promises',
      'Diseases',
      'Medication',
      'Therapy recommendations',
      'Guaranteed effect',
      'Treatment success',
    ],
    handoverMessage:
        'This question needs human review. Please contact support or a qualified professional.',
  );

  static final List<BusinessAuditItem> schnurrPurrAuditItems = [
    BusinessAuditItem(
      id: 'sp-a1',
      area: AuditArea.companyProfile,
      title: 'Company profile created',
      description:
          'Basic data and contact paths are available; positioning can still be refined.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.medium,
      recommendation:
          'Add a description with clear product and support boundaries.',
    ),
    BusinessAuditItem(
      id: 'sp-a2',
      area: AuditArea.website,
      title: 'Website available',
      description:
          'A website is stored; detail pages and support paths are not fully described yet.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.medium,
    ),
    BusinessAuditItem(
      id: 'sp-a3',
      area: AuditArea.products,
      title: 'App and product information partial',
      description:
          'Relax App and pillow are created, but specifications, prices and care notes should become more consistent.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      recommendation: 'Add a product sheet for app features and pillow care.',
    ),
    BusinessAuditItem(
      id: 'sp-a4',
      area: AuditArea.supportKnowledge,
      title: 'Support knowledge partial',
      description:
          'FAQ content for app, usage and support exists; returns, ordering and technical errors are still missing.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      recommendation:
          'Add support knowledge for purchase, usage, account and technical problems.',
    ),
    BusinessAuditItem(
      id: 'sp-a5',
      area: AuditArea.trustMaterial,
      title: 'Reviews and trust material missing',
      description:
          'Documented reviews, testimonials or press quotes are missing for external credibility.',
      status: AuditItemStatus.missing,
      priority: AuditPriority.medium,
      recommendation:
          'Collect permitted reviews and short trust sources and store them as source material.',
    ),
    BusinessAuditItem(
      id: 'sp-a6',
      area: AuditArea.socialPresence,
      title: 'Social and community can be improved',
      description:
          'Community and social media signals are barely documented for the demo workspace.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.low,
      recommendation:
          'Capture public channels and frequent community questions in a structured way.',
    ),
    BusinessAuditItem(
      id: 'sp-a7',
      area: AuditArea.sources,
      title: 'Expand source base',
      description:
          'App help and product data exist, but website, care and support sources should be separated clearly.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.medium,
    ),
    BusinessAuditItem(
      id: 'sp-a8',
      area: AuditArea.riskRules,
      title: 'No-go rules for wellness communication',
      description:
          'Rules against healing promises and diagnoses exist, but should be refined for relaxation and sleep questions.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      recommendation:
          'Document clearer boundaries for wellness statements and support handovers.',
    ),
    BusinessAuditItem(
      id: 'sp-a9',
      area: AuditArea.botReadiness,
      title: 'Bot readiness',
      description:
          'The bot can answer basic questions, but is not fully secured before marketing expansion.',
      status: AuditItemStatus.partial,
      priority: AuditPriority.high,
      recommendation:
          'Close review cases, expand the FAQ and test red rules with sample questions.',
    ),
  ];

  static const BusinessRules schnurrPurrBusinessRules = BusinessRules(
    brandVoice:
        'Calm, friendly and practical. Focus on usage, comfort and support.',
    doNotSay: [
      'No healing promises',
      'No diagnosis or therapy statements',
      'No guarantees for sleep, stress reduction or health',
    ],
    allowedSupportTopics: [
      'Relax App usage',
      'Break routines',
      'Pillow care',
      'Support and app version',
      'Notification settings',
    ],
    escalationNotes: 'Refer health or legal questions to professional advice.',
    disclaimerText:
        'SchnurrPurr provides comfort and relaxation information, not medical advice.',
  );

  static const BotConfiguration schnurrPurrBotConfiguration = BotConfiguration(
    status: BotStatus.draft,
    answerStyle: BotAnswerStyle.balanced,
    defaultLanguage: 'en',
    useDisclaimer: true,
    disclaimerText:
        'Note: SchnurrPurr provides comfort and relaxation information, not medical advice.',
    alwaysEscalateRedFlags: true,
    escalateNoMatch: true,
    escalateYellowRisk: false,
    allowedTopics: [
      'Relax App usage',
      'Break routines',
      'Pillow care',
      'Support',
    ],
    blockedTopics: [
      'Diagnoses',
      'Treatment',
      'Therapy',
      'Guaranteed health effect',
    ],
    handoverMessage:
        'This question should be reviewed by support. Please contact SchnurrPurr directly.',
  );

  static final List<SourceMaterial> hbCureSourceMaterials = [
    SourceMaterial(
      id: 'hb-sm1',
      title: 'Website FAQ',
      type: SourceMaterialType.faq,
      url: 'https://www.healing-balance.com',
      contentSnippet:
          'FAQ exists. The exact FAQ URL and bot-ready individual questions '
          'still need to be imported from the website and reviewed.',
      status: SourceMaterialStatus.converted,
      relatedKnowledgeEntryIds: ['k1', 'k2', 'k3', 'k11', 'k18'],
      createdAt: DateTime(2025, 5, 1),
      updatedAt: DateTime(2025, 5, 3),
      notes: 'Add FAQ content; do not import effect claims without review.',
    ),
    SourceMaterial(
      id: 'hb-sm2',
      title: 'Reviews and website testimonials',
      type: SourceMaterialType.review,
      contentSnippet:
          'Reviews exist, but platforms, links, counts and usage rights were '
          'not provided yet.',
      status: SourceMaterialStatus.newItem,
      createdAt: DateTime(2025, 5, 4),
      updatedAt: DateTime(2025, 5, 5),
      notes:
          'Create a review overview and check content approval before marketing use.',
    ),
    SourceMaterial(
      id: 'hb-sm3',
      title: 'App, device and product notes',
      type: SourceMaterialType.note,
      contentSnippet:
          'Main offer: frequency technology with devices, applications, '
          'programs and app support.',
      status: SourceMaterialStatus.converted,
      relatedKnowledgeEntryIds: ['k4', 'k5', 'k8', 'k17', 'k19'],
      createdAt: DateTime(2025, 5, 8),
      updatedAt: DateTime(2025, 5, 10),
      notes: 'Product priorities were not answered and remain open.',
    ),
    SourceMaterial(
      id: 'hb-sm4',
      title: 'Social media exists',
      type: SourceMaterialType.social,
      contentSnippet:
          'Social media was marked as present. Concrete platforms and profile '
          'links are still missing.',
      status: SourceMaterialStatus.newItem,
      createdAt: DateTime(2025, 5, 15),
      updatedAt: DateTime(2025, 5, 15),
      notes: 'Capture exact social media platforms.',
    ),
    SourceMaterial(
      id: 'hb-sm5',
      title: 'PDFs and instructions',
      type: SourceMaterialType.pdf,
      contentSnippet:
          'PDFs and instructions exist. Storage location, freshness and approved '
          'text passages still need to be documented.',
      status: SourceMaterialStatus.newItem,
      relatedKnowledgeEntryIds: ['k16', 'k17', 'k18'],
      createdAt: DateTime(2025, 5, 24),
      updatedAt: DateTime(2025, 5, 24),
      notes: 'Add document and check legal approval.',
    ),
    SourceMaterial(
      id: 'hb-sm6',
      title: 'Videos',
      type: SourceMaterialType.other,
      contentSnippet:
          'Videos exist. Links and content need to be connected before creating '
          'knowledge entries or marketing drafts from them.',
      status: SourceMaterialStatus.newItem,
      relatedKnowledgeEntryIds: ['k20'],
      createdAt: DateTime(2025, 5, 24),
      updatedAt: DateTime(2025, 5, 24),
      notes: 'Link video material.',
    ),
    SourceMaterial(
      id: 'hb-sm7',
      title: 'Open company details',
      type: SourceMaterialType.note,
      contentSnippet:
          'Open: most important offers, exact inquiry channels, marketing '
          'priority, website priority, automation priority, other priority, '
          'social platforms and advertising channels.',
      status: SourceMaterialStatus.newItem,
      createdAt: DateTime(2025, 5, 24),
      updatedAt: DateTime(2025, 5, 24),
      notes: 'These gaps must not be filled automatically with assumptions.',
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
          'Prepare FAQ-based education about use, operation, app setup, '
          'programs, frequencies and legal guidance. Knowledge base priority: '
          '5 out of 5.',
    ),
    MarketingAction(
      id: 'hb-marketing-reviews',
      type: MarketingActionType.collectReviews,
      priority: MarketingActionPriority.medium,
      effort: MarketingActionEffort.medium,
      impact: MarketingActionImpact.medium,
      status: MarketingActionStatus.notStarted,
      notes:
          'Create a review overview. Platforms, links and usage rights are '
          'still open.',
    ),
    MarketingAction(
      id: 'hb-marketing-seo',
      type: MarketingActionType.improveSeo,
      priority: MarketingActionPriority.medium,
      effort: MarketingActionEffort.medium,
      impact: MarketingActionImpact.high,
      status: MarketingActionStatus.planned,
      notes:
          'Prepare website content and legally careful educational copy. No '
          'medical claims without review.',
    ),
    MarketingAction(
      id: 'hb-marketing-newsletter',
      type: MarketingActionType.prepareNewsletter,
      priority: MarketingActionPriority.medium,
      effort: MarketingActionEffort.low,
      impact: MarketingActionImpact.medium,
      status: MarketingActionStatus.planned,
      notes:
          'Newsletter drafts only as prepared content. No automatic publishing; '
          'approval only after human review.',
    ),
    MarketingAction(
      id: 'hb-marketing-bot',
      type: MarketingActionType.integrateBotWebsite,
      priority: MarketingActionPriority.high,
      effort: MarketingActionEffort.high,
      impact: MarketingActionImpact.high,
      status: MarketingActionStatus.postponed,
      notes:
          'Do not publish the bot automatically. First secure Human Review, '
          'no-go rules and sensitive effect-related questions.',
    ),
  ];

  static final List<SourceMaterial> schnurrPurrSourceMaterials = [
    SourceMaterial(
      id: 'sp-sm1',
      title: 'Website product overview',
      type: SourceMaterialType.website,
      url: 'https://www.schnurrpurr.example',
      contentSnippet:
          'Short description of the Relax App and the Purr Pillow with support contact.',
      status: SourceMaterialStatus.reviewed,
      relatedKnowledgeEntryIds: ['sp-k1', 'sp-k4'],
      createdAt: DateTime(2025, 5, 2),
      updatedAt: DateTime(2025, 5, 4),
    ),
    SourceMaterial(
      id: 'sp-sm2',
      title: 'App store notes',
      type: SourceMaterialType.note,
      contentSnippet:
          'Draft text for soundscapes, timers, reminders and account features.',
      status: SourceMaterialStatus.converted,
      relatedKnowledgeEntryIds: ['sp-k2', 'sp-k3', 'sp-k10'],
      createdAt: DateTime(2025, 5, 6),
      updatedAt: DateTime(2025, 5, 8),
    ),
    SourceMaterial(
      id: 'sp-sm3',
      title: 'Pillow and relaxation concept notes',
      type: SourceMaterialType.note,
      contentSnippet:
          'Material and care notes plus usage context for breaks and comfort.',
      status: SourceMaterialStatus.converted,
      relatedKnowledgeEntryIds: ['sp-k4', 'sp-k5'],
      createdAt: DateTime(2025, 5, 10),
      updatedAt: DateTime(2025, 5, 12),
    ),
    SourceMaterial(
      id: 'sp-sm4',
      title: 'Review and trust material collection',
      type: SourceMaterialType.review,
      contentSnippet:
          'Trust material is only partially available and is not yet approved for the bot.',
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
          'Healing und Balance GmbH develops and distributes systems in the field of frequency technology. '
          'The products are intended for complementary use and do not replace medical diagnosis or treatment.',
      industry: 'Health / frequency technology',
      country: 'Austria',
      primaryLanguage: 'en',
      website: 'https://www.healing-balance.com',
      supportEmail: 'semper@healing-balance.com',
      supportPhone: '+43 660 6506900',
      hasWebsite: true,
      additionalLanguages: 'German',
      targetRegions: 'European Union',
    ),
    products: IntakeProducts(
      importantProducts: '',
      mainProduct:
          'Frequency technology and related devices, applications, programs and app support',
      explanationNeeded:
          'Use, operation, mode of action, programs and frequencies, app setup, '
          'usage flow, device connection, instructions, safety notes and legal guidance.',
      priorityProducts: '',
    ),
    targetGroups: IntakeTargetGroups(
      targetGroup: 'Doctors\nTherapists\nEnd customers',
      marketType: 'B2B and B2C',
      problemSolved:
          'Customers need clear information about use, app setup, device connection '
          'and safe legal boundaries.',
      customerBenefit:
          'Clearer usage guidance and safer support without medical healing claims.',
      differentiation:
          'Frequency technology with app support, instructions and human-reviewed communication.',
    ),
    websiteAndSupport: IntakeWebsiteAndSupport(
      websiteUrl: 'https://www.healing-balance.com',
      hasFaqArea: true,
      importantPages: 'Homepage, FAQ, legal notices, support',
      frequentQuestions:
          'Use, operation, mode of action, programs and frequencies, app setup, usage flow, device connection, instructions, safety notes, legal guidance.',
      hasSupportQuestions: true,
      supportChannels: '',
      preSalesQuestions:
          'Use\nMode of action\nPrograms and frequencies\nLegal guidance',
      afterSalesQuestions:
          'App setup\nUsage flow\nDevice connection\nInstructions',
      technicalProblems: 'App setup\nDevice connection',
      complaintsOrMisunderstandings:
          'Healing, diagnosis, therapy or guarantee expectations',
      supportOwner: 'Managing Director Klaus Semper',
      standardizableQuestions:
          'App setup\nInstructions\nDevice connection\ngeneral legal guidance',
      supportProblems:
          'Inquiry channels still need to be defined. Automatic answers: No. Human approval: Yes.',
      sensitiveTopics:
          'Medical, legal and effect-related questions; healing, diseases, diagnosis, therapy success and guarantees.',
      hasSensitiveTopics: true,
    ),
    sourcesAndReviews: IntakeSourcesAndReviews(
      existingSources:
          'FAQ\nPDFs\nInstructions\nVideos\nLegal guidance\nWebsite\nReviews',
      hasMaterials: true,
      materialDetails: 'FAQ\nPDF\nInstructions\nVideos\nLegal guidance',
      materialLocations: '',
      materialFreshness: '',
      importantMaterials: 'FAQ\nInstructions\nLegal guidance',
      materialsUsableForKnowledgeBase: true,
      reviews: 'Reviews exist; exact platforms and links are still missing.',
      reviewPlatforms: '',
      reviewLinksOrFiles: '',
      reviewTypes: '',
      hasReviews: true,
      socialMentions:
          'Social media exists; exact platforms and profile links are still missing.',
      trustMaterial:
          'Reviews and legal guidance exist, but must be reviewed before public use.',
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
          'Advertising across multiple channels; automated preparation where possible; easier customer acquisition.',
      futureAdChannels: '',
      channels:
          'Social media exists. Exact social media and advertising channels still need to be defined.',
      reachProblems:
          'Reach new customers more easily\nPrepare advertising for all channels',
    ),
    goalsAndRisks: IntakeGoalsAndRisks(
      hasSensitiveTopics: true,
      sensitiveTopics:
          'medical questions\nlegal questions\nmode of action\nhealing\ndiseases\ndiagnosis\ntherapy success\nguarantees',
      companyGoals:
          'Customer service\nKnowledge base\nApp setup\nMarketing preparation\nOrder handling\nLead generation',
      shortTermPriorities:
          'Customer service: 5 out of 5\nKnowledge base: 5 out of 5\nMarketing: not rated yet\nWebsite: not rated yet\nAutomation: not rated yet\nOther: not rated yet',
      prohibitedStatements:
          'No healing promises\nNo diagnoses\nNo therapy success claims\nNo guarantees\nNo unchecked claims about activating the body’s self-healing processes',
      forbiddenClaims:
          'Healing\nTreating diseases\nMaking diagnoses\nGuaranteeing therapy success\nReplacing medical treatment',
      botRestrictedTopics:
          'medical questions\nlegal questions\nsafety-critical use\neffect-related questions',
      alwaysEscalateTopics:
          'Healing\nDiseases\nDiagnosis\nTherapy success\nGuarantees\nLegal classification',
      legalRestrictions:
          'Answers must not be published or sent automatically. Human review is mandatory for sensitive content.',
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
          'Relaxation app and comfort products for calm everyday breaks.',
      industry: 'Relaxation app & comfort products',
      country: 'Germany',
      primaryLanguage: 'en',
      website: 'https://www.schnurrpurr.example',
      supportEmail: 'support@schnurrpurr.example',
    ),
    products: IntakeProducts(
      importantProducts: 'SchnurrPurr Relax App, Purr Pillow',
      mainProduct: 'SchnurrPurr Relax App',
      explanationNeeded: 'App usage, soundscapes, break routines, pillow care.',
      priorityProducts: 'Relax App and pillow comfort information.',
    ),
    targetGroups: IntakeTargetGroups(
      targetGroup:
          'People looking for short relaxed breaks and soft comfort products.',
      marketType: 'B2C',
      problemSolved:
          'Everyday breaks become easier to prepare and more pleasant.',
      customerBenefit:
          'Calm routines and clear product information without health promises.',
      differentiation:
          'Friendly tone, simple usage and a combination of app and product.',
    ),
    websiteAndSupport: IntakeWebsiteAndSupport(
      importantPages: 'Website, product page, support, app help',
      frequentQuestions:
          'App start, timer, soundscapes, pillow care, shipping.',
      supportProblems: 'Account, app reminders, care instructions.',
      sensitiveTopics: 'Stress, sleep, therapy or medical effect claims.',
    ),
  );

  static final List<BusinessGoal> hbCureBusinessGoals = [
    BusinessGoal(
      id: 'hb-goal-support',
      title: 'Secure customer service',
      description:
          'Customer service is prioritized as 5 out of 5. Recurring questions '
          'about use, operation, app setup and device connection should be '
          'prepared, but not published automatically.',
      priority: BusinessGoalPriority.high,
      startDate: DateTime(2025, 6, 1),
      targetDate: DateTime(2025, 9, 30),
      status: BusinessGoalStatus.inProgress,
      owner: 'Managing Director Klaus Semper',
      comment:
          'Human Review is active by default. Always review medical, legal and effect-related questions.',
      linkedAreas: [
        BusinessGoalArea.knowledgeBase,
        BusinessGoalArea.bot,
        BusinessGoalArea.humanReview,
        BusinessGoalArea.audit,
      ],
    ),
    BusinessGoal(
      id: 'hb-goal-knowledge',
      title: 'Complete the knowledge base',
      description:
          'The knowledge base is prioritized as 5 out of 5. FAQ, PDFs, '
          'instructions, videos and legal guidance should be imported in a structured way.',
      priority: BusinessGoalPriority.high,
      startDate: DateTime(2025, 6, 1),
      targetDate: DateTime(2025, 10, 15),
      status: BusinessGoalStatus.inProgress,
      owner: 'Managing Director Klaus Semper',
      comment:
          'Some concrete content is still missing; do not use placeholders as final bot answers.',
      linkedAreas: [
        BusinessGoalArea.knowledgeBase,
        BusinessGoalArea.sources,
        BusinessGoalArea.audit,
        BusinessGoalArea.humanReview,
      ],
    ),
    BusinessGoal(
      id: 'hb-goal-marketing',
      title: 'Prepare marketing',
      description:
          'Advertising and marketing content should be prepared for multiple '
          'channels. Exact channels and budgets are still open.',
      priority: BusinessGoalPriority.medium,
      startDate: DateTime(2025, 6, 1),
      targetDate: DateTime(2025, 11, 30),
      status: BusinessGoalStatus.planned,
      owner: 'Marketing / Human Review',
      comment:
          'No automatic publishing. Content approval and legal risk review remain mandatory.',
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
      title: 'Win more customers',
      description:
          'Expand website, social proof and simple content for app and comfort products.',
      priority: BusinessGoalPriority.high,
      startDate: DateTime(2025, 6, 1),
      targetDate: DateTime(2025, 11, 30),
      status: BusinessGoalStatus.inProgress,
      owner: 'Demo Team',
      comment:
          'Trust material and marketing basics are still partially missing.',
      linkedAreas: [
        BusinessGoalArea.marketing,
        BusinessGoalArea.sources,
        BusinessGoalArea.audit,
        BusinessGoalArea.knowledgeBase,
      ],
    ),
    BusinessGoal(
      id: 'sp-goal-bot',
      title: 'Expand the bot',
      description:
          'Safely answer support questions around app, break routines and pillow care.',
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
