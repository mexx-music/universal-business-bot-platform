import '../models/knowledge_entry.dart' show RiskLevel;
import 'models/community_enums.dart';
import 'models/community_member.dart';
import 'models/community_task.dart';
import 'models/discovered_content.dart';
import 'models/human_action_report.dart';
import 'models/profile_match.dart';

/// Fictional demo data for the Community Radar prototype.
///
/// Everything here is invented — no real people, accounts, URLs or posts.
/// It spans three demo companies, several countries, German and English,
/// multiple platforms and all three risk levels, with open, accepted and
/// completed tasks. Company ids match the existing demo workspaces
/// (`hb-cure`, `schnurr-purr`) plus one extra fictional company.
class CommunityDemoData {
  const CommunityDemoData._();

  static const String hbCure = 'hb-cure';
  static const String schnurrPurr = 'schnurr-purr';
  static const String nordlicht = 'nordlicht-kaffee';

  /// Human-readable company names for the demo (radar filter/labels).
  static const Map<String, String> companyNames = {
    hbCure: 'HB Cure',
    schnurrPurr: 'SchnurrPurr',
    nordlicht: 'Nordlicht Kaffee',
  };

  static List<DiscoveredContent> content() => [
    DiscoveredContent(
      id: 'dc-1',
      companyId: schnurrPurr,
      platform: CommunityPlatform.reddit,
      sourceUrl: 'https://example.invalid/r/cats/demo-1',
      title: 'Meine Katze ist ständig gestresst – was hilft wirklich?',
      originalText:
          'Unsere Wohnungskatze ist seit dem Umzug sehr unruhig. Habt ihr '
          'Erfahrungen mit Entspannungs-Apps oder speziellen Kissen? Ich bin '
          'skeptisch, aber offen für echte Erfahrungsberichte.',
      language: 'de',
      country: 'DE',
      topicTags: ['katzen', 'stress', 'entspannung'],
      detectedIntent: ContentIntent.recommendationRequest,
      sentiment: ContentSentiment.neutral,
      relevanceScore: 88,
      riskLevel: RiskLevel.green,
      discoveredAt: DateTime(2026, 7, 20, 9, 15),
      status: ContentStatus.matched,
      recommendedActionTypes: const [
        CommunityActionType.personalExperience,
        CommunityActionType.shortPersonalComment,
        CommunityActionType.askFollowUpQuestion,
      ],
      aiSummary:
          'Katzenhalterin sucht nach dem Umzug echte Erfahrungsberichte zu '
          'Entspannungshilfen; ausdrücklich skeptisch gegenüber Werbung.',
      relevanceReason:
          'Thema Katzenentspannung passt direkt zum Produktbereich; die '
          'Autorin bittet ausdrücklich um persönliche Erfahrungen.',
      riskNotes: const [
        'Keine Wirkversprechen – nur eigene Erfahrung schildern.',
      ],
      prohibitedClaims: const [
        'Heilt Angststörungen',
        'Medizinisch nachgewiesene Wirkung',
      ],
      relatedKnowledgeEntryIds: const ['sp-k1', 'sp-k4'],
    ),
    DiscoveredContent(
      id: 'dc-2',
      companyId: schnurrPurr,
      platform: CommunityPlatform.facebookGroup,
      sourceUrl: 'https://example.invalid/groups/catlovers/demo-2',
      title: 'Which relaxation pillow do you actually recommend?',
      originalText:
          'I keep seeing ads for cat relaxation products. Has anyone here '
          'genuinely used one and noticed a difference? Looking for honest '
          'opinions, not marketing.',
      language: 'en',
      country: 'US',
      topicTags: ['cats', 'products', 'relaxation'],
      detectedIntent: ContentIntent.recommendationRequest,
      sentiment: ContentSentiment.mixed,
      relevanceScore: 81,
      riskLevel: RiskLevel.green,
      discoveredAt: DateTime(2026, 7, 20, 14, 40),
      status: ContentStatus.newContent,
      recommendedActionTypes: const [
        CommunityActionType.personalExperience,
        CommunityActionType.like,
      ],
      aiSummary:
          'US group member asks for genuine, non-marketing experience with '
          'cat relaxation pillows.',
      relevanceReason:
          'Direct product-category request in English; suits a member with '
          'first-hand experience and US presence.',
      riskNotes: const ['Disclose any company connection if one exists.'],
      prohibitedClaims: const ['Cures anxiety', 'Vet-approved'],
      relatedKnowledgeEntryIds: const ['sp-k4'],
    ),
    DiscoveredContent(
      id: 'dc-3',
      companyId: hbCure,
      platform: CommunityPlatform.forum,
      sourceUrl: 'https://example.invalid/forum/wellness/demo-3',
      title: 'Erfahrungen mit Frequenz-Messgeräten für Wohlbefinden?',
      originalText:
          'Ich interessiere mich für Geräte, die angeblich das Wohlbefinden '
          'messen. Funktioniert das oder ist das Unsinn? Wer hat sowas '
          'wirklich benutzt?',
      language: 'de',
      country: 'AT',
      topicTags: ['wellness', 'messgerät', 'technik'],
      detectedIntent: ContentIntent.question,
      sentiment: ContentSentiment.neutral,
      relevanceScore: 74,
      riskLevel: RiskLevel.yellow,
      discoveredAt: DateTime(2026, 7, 19, 18, 5),
      status: ContentStatus.reviewing,
      recommendedActionTypes: const [
        CommunityActionType.factualAnswer,
        CommunityActionType.askFollowUpQuestion,
      ],
      aiSummary:
          'Nutzer fragt sachlich, ob Wohlbefinden-Messgeräte funktionieren.',
      relevanceReason:
          'Produktkategorie HB Cure; sachliche Frage, die faktisch und ohne '
          'Heilversprechen beantwortet werden kann.',
      riskNotes: const [
        'Sensibles Thema: streng bei Fakten bleiben, keine Gesundheitsaussagen.',
      ],
      prohibitedClaims: const [
        'Diagnostiziert Krankheiten',
        'Ersetzt einen Arztbesuch',
        'Klinisch bewiesen',
      ],
      relatedKnowledgeEntryIds: const ['hb-k2'],
    ),
    DiscoveredContent(
      id: 'dc-4',
      companyId: hbCure,
      platform: CommunityPlatform.reddit,
      sourceUrl: 'https://example.invalid/r/health/demo-4',
      title: 'Can this device cure my chronic condition?',
      originalText:
          'Saw a wellness gadget online. Someone said it healed their illness. '
          'Is that true? Should I stop my medication?',
      language: 'en',
      country: 'US',
      topicTags: ['health', 'device', 'medical'],
      detectedIntent: ContentIntent.question,
      sentiment: ContentSentiment.negative,
      relevanceScore: 62,
      riskLevel: RiskLevel.red,
      discoveredAt: DateTime(2026, 7, 19, 8, 30),
      status: ContentStatus.dismissed,
      recommendedActionTypes: const [
        CommunityActionType.viewOnly,
        CommunityActionType.skip,
      ],
      aiSummary:
          'User asks whether a device can cure illness and replace medication.',
      relevanceReason:
          'Mentions the product category, but frames it as a medical cure.',
      riskNotes: const [
        'High risk: medical/therapeutic context. No engagement recommended — '
            'any reply could be read as medical advice.',
      ],
      prohibitedClaims: const [
        'Cures illness',
        'Replaces medication',
        'Medical treatment',
      ],
      relatedKnowledgeEntryIds: const [],
    ),
    DiscoveredContent(
      id: 'dc-5',
      companyId: nordlicht,
      platform: CommunityPlatform.instagram,
      sourceUrl: 'https://example.invalid/p/demo-5',
      title: 'Suche fair gehandelten Kaffee aus dem Norden',
      originalText:
          'Kennt jemand kleine Röstereien mit fair gehandeltem Kaffee? Am '
          'liebsten aus Norddeutschland. Empfehlungen willkommen!',
      language: 'de',
      country: 'DE',
      topicTags: ['kaffee', 'fairtrade', 'rösterei'],
      detectedIntent: ContentIntent.recommendationRequest,
      sentiment: ContentSentiment.positive,
      relevanceScore: 79,
      riskLevel: RiskLevel.green,
      discoveredAt: DateTime(2026, 7, 21, 10, 0),
      status: ContentStatus.matched,
      recommendedActionTypes: const [
        CommunityActionType.shortPersonalComment,
        CommunityActionType.like,
      ],
      aiSummary:
          'Nutzerin sucht Empfehlungen für faire Kaffeeröstereien im Norden.',
      relevanceReason:
          'Passt exakt zum Angebot; positive Stimmung, geringe Risiken.',
      riskNotes: const [],
      prohibitedClaims: const ['Gesündester Kaffee'],
      relatedKnowledgeEntryIds: const [],
    ),
    DiscoveredContent(
      id: 'dc-6',
      companyId: nordlicht,
      platform: CommunityPlatform.x,
      sourceUrl: 'https://example.invalid/status/demo-6',
      title: 'Best beans for a mild morning coffee?',
      originalText:
          'Looking for a mild, low-acidity bean for pour-over. Any small '
          'roasters worth trying? Prefer European shipping.',
      language: 'en',
      country: 'DE',
      topicTags: ['coffee', 'beans', 'pourover'],
      detectedIntent: ContentIntent.recommendationRequest,
      sentiment: ContentSentiment.neutral,
      relevanceScore: 70,
      riskLevel: RiskLevel.green,
      discoveredAt: DateTime(2026, 7, 21, 7, 20),
      status: ContentStatus.newContent,
      recommendedActionTypes: const [
        CommunityActionType.repost,
        CommunityActionType.shortPersonalComment,
      ],
      aiSummary: 'User wants a mild, low-acidity bean and a small roaster.',
      relevanceReason: 'Matches product line; low risk, factual answer fits.',
      riskNotes: const [],
      prohibitedClaims: const [],
      relatedKnowledgeEntryIds: const [],
    ),
    DiscoveredContent(
      id: 'dc-7',
      companyId: schnurrPurr,
      platform: CommunityPlatform.forum,
      sourceUrl: 'https://example.invalid/forum/pets/demo-7',
      title: 'Kissenbezug waschen – geht das in der Maschine?',
      originalText:
          'Kurze Frage: Kann man den Bezug von so einem Entspannungskissen '
          'für Katzen in der Waschmaschine waschen?',
      language: 'de',
      country: 'DE',
      topicTags: ['katzen', 'pflege', 'produktfrage'],
      detectedIntent: ContentIntent.question,
      sentiment: ContentSentiment.neutral,
      relevanceScore: 66,
      riskLevel: RiskLevel.green,
      discoveredAt: DateTime(2026, 7, 18, 16, 45),
      status: ContentStatus.taskCreated,
      recommendedActionTypes: const [CommunityActionType.factualAnswer],
      aiSummary: 'Simple product-care question about washing the pillow cover.',
      relevanceReason:
          'Concrete product question that a knowledge-base fact answers.',
      riskNotes: const [],
      prohibitedClaims: const [],
      relatedKnowledgeEntryIds: const ['sp-k5'],
    ),
    DiscoveredContent(
      id: 'dc-8',
      companyId: hbCure,
      platform: CommunityPlatform.facebookGroup,
      sourceUrl: 'https://example.invalid/groups/wellnesstech/demo-8',
      title: 'App verbindet sich nicht mit dem Gerät',
      originalText:
          'Bei mir koppelt die App das Messgerät nicht per Bluetooth. Hat '
          'jemand einen Tipp, bevor ich es zurückschicke?',
      language: 'de',
      country: 'DE',
      topicTags: ['technik', 'support', 'bluetooth'],
      detectedIntent: ContentIntent.complaint,
      sentiment: ContentSentiment.negative,
      relevanceScore: 72,
      riskLevel: RiskLevel.green,
      discoveredAt: DateTime(2026, 7, 18, 11, 10),
      status: ContentStatus.actioned,
      recommendedActionTypes: const [
        CommunityActionType.factualAnswer,
        CommunityActionType.askFollowUpQuestion,
      ],
      aiSummary: 'User reports a Bluetooth pairing problem before returning.',
      relevanceReason:
          'Support-style question answerable with a factual troubleshooting '
          'tip from the knowledge base.',
      riskNotes: const ['Stay on technical support; no health claims.'],
      prohibitedClaims: const [],
      relatedKnowledgeEntryIds: const ['hb-k3'],
    ),
    DiscoveredContent(
      id: 'dc-9',
      companyId: schnurrPurr,
      platform: CommunityPlatform.youtube,
      sourceUrl: 'https://example.invalid/watch/demo-9',
      title: 'Does white noise really calm cats? (comments)',
      originalText:
          'Comment thread under a pet care video debates whether sound-based '
          'relaxation actually works for cats. Several ask for real stories.',
      language: 'en',
      country: 'GB',
      topicTags: ['cats', 'sound', 'relaxation'],
      detectedIntent: ContentIntent.discussion,
      sentiment: ContentSentiment.mixed,
      relevanceScore: 58,
      riskLevel: RiskLevel.yellow,
      discoveredAt: DateTime(2026, 7, 17, 20, 0),
      status: ContentStatus.newContent,
      recommendedActionTypes: const [
        CommunityActionType.shortPersonalComment,
        CommunityActionType.like,
      ],
      aiSummary:
          'Comment discussion on whether sound relaxation works for cats.',
      relevanceReason:
          'On-topic discussion; suitable only for members with genuine '
          'experience to avoid overstating effects.',
      riskNotes: const [
        'Mixed evidence — only share personal experience, do not generalise.',
      ],
      prohibitedClaims: const ['Scientifically proven to calm cats'],
      relatedKnowledgeEntryIds: const ['sp-k1'],
    ),
    DiscoveredContent(
      id: 'dc-10',
      companyId: nordlicht,
      platform: CommunityPlatform.forum,
      sourceUrl: 'https://example.invalid/forum/coffee/demo-10',
      title: 'Abo-Modelle für Kaffee – lohnt sich das?',
      originalText:
          'Überlege, ein Kaffee-Abo abzuschließen. Habt ihr Erfahrungen, ob '
          'sich das gegenüber Einzelkauf lohnt?',
      language: 'de',
      country: 'AT',
      topicTags: ['kaffee', 'abo', 'preis'],
      detectedIntent: ContentIntent.comparison,
      sentiment: ContentSentiment.neutral,
      relevanceScore: 64,
      riskLevel: RiskLevel.green,
      discoveredAt: DateTime(2026, 7, 17, 9, 30),
      status: ContentStatus.reviewing,
      recommendedActionTypes: const [
        CommunityActionType.personalExperience,
        CommunityActionType.factualAnswer,
      ],
      aiSummary: 'User weighs a coffee subscription against single purchases.',
      relevanceReason: 'Relevant to the subscription offer; low risk.',
      riskNotes: const [
        'Disclose connection if recommending own subscription.',
      ],
      prohibitedClaims: const [],
      relatedKnowledgeEntryIds: const [],
    ),
  ];

  static List<CommunityMember> members() => [
    const CommunityMember(
      id: 'm-1',
      displayName: 'Lena (Demo)',
      country: 'DE',
      languages: ['de', 'en'],
      platformProfiles: [
        MemberPlatformProfile(
          platform: CommunityPlatform.reddit,
          handle: 'demo_lena',
        ),
        MemberPlatformProfile(
          platform: CommunityPlatform.facebookGroup,
          handle: 'lena.demo',
        ),
      ],
      declaredInterests: ['katzen', 'tierpflege', 'entspannung'],
      verifiedTopics: ['katzen'],
      publicActivityTopics: ['katzen', 'haustiere'],
      writingStyle: 'warm, persönlich',
      experienceCategories: ['katzenhaltung', 'entspannungsprodukte'],
      isVerified: true,
      accountAuthenticityScore: 92,
      qualityScore: 88,
      availability: 'abends',
      compensationEnabled: true,
      disclosureRequirements: ['bezahlte Partnerschaft kennzeichnen'],
      status: MemberStatus.active,
      completedTaskCount: 12,
    ),
    const CommunityMember(
      id: 'm-2',
      displayName: 'Marco (Demo)',
      country: 'US',
      languages: ['en'],
      platformProfiles: [
        MemberPlatformProfile(
          platform: CommunityPlatform.facebookGroup,
          handle: 'marco.demo',
        ),
      ],
      declaredInterests: ['cats', 'pet products'],
      verifiedTopics: ['cats'],
      publicActivityTopics: ['cats', 'product reviews'],
      writingStyle: 'concise, factual',
      experienceCategories: ['cat ownership'],
      isVerified: true,
      accountAuthenticityScore: 84,
      qualityScore: 79,
      availability: 'weekends',
      compensationEnabled: false,
      disclosureRequirements: ['disclose paid partnership'],
      status: MemberStatus.active,
      completedTaskCount: 5,
    ),
    const CommunityMember(
      id: 'm-3',
      displayName: 'Sabine (Demo)',
      country: 'AT',
      languages: ['de'],
      platformProfiles: [
        MemberPlatformProfile(
          platform: CommunityPlatform.forum,
          handle: 'sabine_at',
        ),
      ],
      declaredInterests: ['wellness', 'technik'],
      verifiedTopics: [],
      publicActivityTopics: ['wellness', 'gadgets'],
      writingStyle: 'sachlich, neugierig',
      experienceCategories: ['wellness-technik'],
      isVerified: false,
      accountAuthenticityScore: 71,
      qualityScore: 66,
      availability: 'flexibel',
      compensationEnabled: true,
      disclosureRequirements: ['Verbindung zum Unternehmen offenlegen'],
      status: MemberStatus.active,
      completedTaskCount: 3,
    ),
    const CommunityMember(
      id: 'm-4',
      displayName: 'Jonas (Demo)',
      country: 'DE',
      languages: ['de', 'en'],
      platformProfiles: [
        MemberPlatformProfile(
          platform: CommunityPlatform.instagram,
          handle: 'jonas.roestet',
        ),
        MemberPlatformProfile(
          platform: CommunityPlatform.x,
          handle: 'jonas_coffee',
        ),
      ],
      declaredInterests: ['kaffee', 'fairtrade', 'nachhaltigkeit'],
      verifiedTopics: ['kaffee'],
      publicActivityTopics: ['kaffee', 'rösterei'],
      writingStyle: 'begeistert, detailliert',
      experienceCategories: ['kaffeezubereitung'],
      isVerified: true,
      accountAuthenticityScore: 90,
      qualityScore: 84,
      availability: 'morgens',
      compensationEnabled: true,
      disclosureRequirements: ['bezahlte Aufgaben kennzeichnen'],
      status: MemberStatus.active,
      completedTaskCount: 9,
    ),
    const CommunityMember(
      id: 'm-5',
      displayName: 'Aisha (Demo)',
      country: 'GB',
      languages: ['en'],
      platformProfiles: [
        MemberPlatformProfile(
          platform: CommunityPlatform.youtube,
          handle: 'aisha.demo',
        ),
        MemberPlatformProfile(
          platform: CommunityPlatform.reddit,
          handle: 'aisha_pets',
        ),
      ],
      declaredInterests: ['cats', 'sound therapy'],
      verifiedTopics: ['cats'],
      publicActivityTopics: ['cats', 'pet care'],
      writingStyle: 'friendly, story-driven',
      experienceCategories: ['cat ownership'],
      isVerified: true,
      accountAuthenticityScore: 81,
      qualityScore: 77,
      availability: 'evenings',
      compensationEnabled: false,
      disclosureRequirements: ['disclose paid partnership'],
      status: MemberStatus.active,
      completedTaskCount: 6,
    ),
    const CommunityMember(
      id: 'm-6',
      displayName: 'Peter (Demo)',
      country: 'AT',
      languages: ['de'],
      platformProfiles: [
        MemberPlatformProfile(
          platform: CommunityPlatform.forum,
          handle: 'peter_kaffee',
        ),
      ],
      declaredInterests: ['kaffee', 'abo-modelle'],
      verifiedTopics: [],
      publicActivityTopics: ['kaffee'],
      writingStyle: 'nüchtern, vergleichend',
      experienceCategories: ['kaffee-abos'],
      isVerified: false,
      accountAuthenticityScore: 68,
      qualityScore: 61,
      availability: 'flexibel',
      compensationEnabled: true,
      disclosureRequirements: ['Verbindung offenlegen'],
      status: MemberStatus.pending,
      completedTaskCount: 1,
    ),
    const CommunityMember(
      id: 'm-7',
      displayName: 'Nora (Demo)',
      country: 'DE',
      languages: ['de', 'en'],
      platformProfiles: [
        MemberPlatformProfile(
          platform: CommunityPlatform.reddit,
          handle: 'nora.demo',
        ),
      ],
      declaredInterests: ['technik', 'support', 'gadgets'],
      verifiedTopics: ['technik'],
      publicActivityTopics: ['technik-support'],
      writingStyle: 'hilfsbereit, präzise',
      experienceCategories: ['geräte-support'],
      isVerified: true,
      accountAuthenticityScore: 87,
      qualityScore: 82,
      availability: 'tagsüber',
      compensationEnabled: true,
      disclosureRequirements: ['bezahlte Partnerschaft kennzeichnen'],
      status: MemberStatus.active,
      completedTaskCount: 7,
    ),
    const CommunityMember(
      id: 'm-8',
      displayName: 'Tom (Demo)',
      country: 'US',
      languages: ['en'],
      platformProfiles: [
        MemberPlatformProfile(
          platform: CommunityPlatform.x,
          handle: 'tom.demo',
        ),
      ],
      declaredInterests: ['coffee', 'sustainability'],
      verifiedTopics: [],
      publicActivityTopics: ['coffee'],
      writingStyle: 'short, punchy',
      experienceCategories: ['coffee brewing'],
      isVerified: false,
      accountAuthenticityScore: 63,
      qualityScore: 58,
      availability: 'mornings',
      compensationEnabled: false,
      disclosureRequirements: ['disclose paid partnership'],
      status: MemberStatus.paused,
      completedTaskCount: 0,
    ),
  ];

  static List<ProfileMatch> matches() => [
    const ProfileMatch(
      id: 'pm-1',
      memberId: 'm-1',
      contentId: 'dc-1',
      languageMatch: true,
      countryMatch: true,
      topicMatch: true,
      experienceMatch: true,
      platformMatch: true,
      authenticityMatch: true,
      overallMatchScore: 94,
      matchReasons: [
        'Schreibt bereits öffentlich über Katzen',
        'Nutzt dieselbe Sprache (Deutsch)',
        'Auf derselben Plattform aktiv',
        'Hat freiwillig Interesse an Entspannungsprodukten angegeben',
      ],
    ),
    const ProfileMatch(
      id: 'pm-2',
      memberId: 'm-5',
      contentId: 'dc-1',
      languageMatch: false,
      countryMatch: false,
      topicMatch: true,
      experienceMatch: true,
      platformMatch: false,
      authenticityMatch: true,
      overallMatchScore: 61,
      matchReasons: [
        'Schreibt öffentlich über Katzen',
        'Berichtet über eigene Katzenhaltung',
      ],
      warnings: [
        'Andere Sprache (Englisch) als der Beitrag',
        'Nicht auf derselben Plattform aktiv',
      ],
    ),
    const ProfileMatch(
      id: 'pm-3',
      memberId: 'm-2',
      contentId: 'dc-2',
      languageMatch: true,
      countryMatch: true,
      topicMatch: true,
      experienceMatch: true,
      platformMatch: true,
      authenticityMatch: true,
      overallMatchScore: 89,
      matchReasons: [
        'Posts publicly about cats and product reviews',
        'Same language (English)',
        'Active in the same platform type',
        'Reports first-hand cat ownership',
      ],
    ),
    const ProfileMatch(
      id: 'pm-4',
      memberId: 'm-3',
      contentId: 'dc-3',
      languageMatch: true,
      countryMatch: true,
      topicMatch: true,
      experienceMatch: false,
      platformMatch: true,
      authenticityMatch: false,
      overallMatchScore: 58,
      matchReasons: [
        'Schreibt öffentlich über Wellness und Gadgets',
        'Gleiche Sprache und gleiches Land (AT)',
        'Auf derselben Plattform (Forum) aktiv',
      ],
      warnings: [
        'Keine eigene Produkterfahrung angegeben',
        'Profil nicht verifiziert',
        'Sensibles Thema (Wellness/Gesundheit) – besonders vorsichtig',
      ],
    ),
    const ProfileMatch(
      id: 'pm-5',
      memberId: 'm-4',
      contentId: 'dc-5',
      languageMatch: true,
      countryMatch: true,
      topicMatch: true,
      experienceMatch: true,
      platformMatch: true,
      authenticityMatch: true,
      overallMatchScore: 91,
      matchReasons: [
        'Schreibt bereits öffentlich über Kaffee und Röstereien',
        'Gleiche Sprache und gleiches Land (DE)',
        'Auf Instagram aktiv',
        'Freiwillig Interesse an Fairtrade angegeben',
      ],
    ),
    const ProfileMatch(
      id: 'pm-6',
      memberId: 'm-8',
      contentId: 'dc-6',
      languageMatch: true,
      countryMatch: false,
      topicMatch: true,
      experienceMatch: true,
      platformMatch: true,
      authenticityMatch: false,
      overallMatchScore: 55,
      matchReasons: [
        'Posts publicly about coffee',
        'Active on the same platform (X)',
      ],
      warnings: ['Account currently paused', 'Lower authenticity signal'],
    ),
    const ProfileMatch(
      id: 'pm-7',
      memberId: 'm-7',
      contentId: 'dc-8',
      languageMatch: true,
      countryMatch: true,
      topicMatch: true,
      experienceMatch: true,
      platformMatch: false,
      authenticityMatch: true,
      overallMatchScore: 78,
      matchReasons: [
        'Schreibt öffentlich über Technik-Support',
        'Gleiche Sprache und gleiches Land (DE)',
        'Erfahrung mit Geräte-Support',
      ],
      warnings: ['Nicht auf derselben Plattform aktiv'],
    ),
    const ProfileMatch(
      id: 'pm-8',
      memberId: 'm-6',
      contentId: 'dc-10',
      languageMatch: true,
      countryMatch: true,
      topicMatch: true,
      experienceMatch: true,
      platformMatch: true,
      authenticityMatch: false,
      overallMatchScore: 64,
      matchReasons: [
        'Schreibt öffentlich über Kaffee',
        'Erfahrung mit Kaffee-Abos angegeben',
        'Gleiche Sprache und gleiches Land (AT)',
        'Auf derselben Plattform (Forum) aktiv',
      ],
      warnings: ['Profil noch nicht verifiziert (Status: ausstehend)'],
    ),
  ];

  static List<CommunityTask> tasks() => [
    // Open task, not yet assigned.
    CommunityTask(
      id: 'ct-1',
      contentId: 'dc-1',
      companyId: schnurrPurr,
      allowedActions: const [
        CommunityActionType.personalExperience,
        CommunityActionType.shortPersonalComment,
        CommunityActionType.askFollowUpQuestion,
      ],
      guidance:
          'Reagiere nur, wenn du tatsächlich eigene Erfahrung mit diesem '
          'Thema hast. Schreibe in deinen eigenen Worten. Keine Heilwirkung '
          'behaupten und kein Produkt erwähnen, das du nicht selbst kennst.',
      status: CommunityTaskStatus.open,
      prohibitedClaims: const [
        'Heilt Angststörungen',
        'Medizinisch nachgewiesene Wirkung',
      ],
      disclosureRequired: true,
      compensation: '5 EUR',
      deadline: DateTime(2026, 7, 27),
    ),
    // Accepted task, assigned, in progress.
    CommunityTask(
      id: 'ct-2',
      contentId: 'dc-5',
      companyId: nordlicht,
      assignedMemberId: 'm-4',
      allowedActions: const [
        CommunityActionType.shortPersonalComment,
        CommunityActionType.personalExperience,
      ],
      guidance:
          'Teile deine echte Erfahrung mit fair gehandeltem Kaffee. Eigene '
          'Worte, keine Werbefloskeln.',
      status: CommunityTaskStatus.accepted,
      prohibitedClaims: const ['Gesündester Kaffee'],
      disclosureRequired: true,
      compensation: '4 EUR',
      deadline: DateTime(2026, 7, 26),
      acceptedAt: DateTime(2026, 7, 21, 11, 0),
    ),
    // Completed task with a completion note.
    CommunityTask(
      id: 'ct-3',
      contentId: 'dc-7',
      companyId: schnurrPurr,
      assignedMemberId: 'm-1',
      allowedActions: const [CommunityActionType.factualAnswer],
      guidance:
          'Beantworte die Pflegefrage sachlich anhand der Produktinfos. Keine '
          'Wirkversprechen.',
      status: CommunityTaskStatus.completed,
      prohibitedClaims: const [],
      disclosureRequired: false,
      compensation: null,
      acceptedAt: DateTime(2026, 7, 18, 17, 0),
      completedAt: DateTime(2026, 7, 18, 18, 30),
      completionNote: 'Sachliche Pflegeauskunft in eigenen Worten gepostet.',
    ),
    // Completed task, paid.
    CommunityTask(
      id: 'ct-4',
      contentId: 'dc-8',
      companyId: hbCure,
      assignedMemberId: 'm-7',
      allowedActions: const [
        CommunityActionType.factualAnswer,
        CommunityActionType.askFollowUpQuestion,
      ],
      guidance:
          'Gib einen echten, sachlichen Troubleshooting-Tipp aus eigener '
          'Erfahrung. Bleib beim technischen Thema.',
      status: CommunityTaskStatus.completed,
      prohibitedClaims: const [],
      disclosureRequired: true,
      compensation: '6 EUR',
      acceptedAt: DateTime(2026, 7, 18, 12, 0),
      completedAt: DateTime(2026, 7, 18, 13, 15),
      completionNote: 'Bluetooth-Tipp geteilt, Verbindung offengelegt.',
    ),
    // Declined task (member chose not to participate — no reason required).
    CommunityTask(
      id: 'ct-5',
      contentId: 'dc-3',
      companyId: hbCure,
      assignedMemberId: 'm-3',
      allowedActions: const [CommunityActionType.factualAnswer],
      guidance:
          'Nur beantworten, wenn du echte Erfahrung mit solchen Geräten hast. '
          'Streng bei Fakten bleiben, keine Gesundheitsaussagen.',
      status: CommunityTaskStatus.declined,
      prohibitedClaims: const [
        'Diagnostiziert Krankheiten',
        'Ersetzt einen Arztbesuch',
      ],
      disclosureRequired: true,
      compensation: '5 EUR',
    ),
  ];

  static List<HumanActionReport> reports() => [
    HumanActionReport(
      id: 'har-1',
      taskId: 'ct-3',
      actionType: CommunityActionType.factualAnswer,
      performedBy: 'm-1',
      performedAt: DateTime(2026, 7, 18, 18, 25),
      originalPlatformUrl: 'https://example.invalid/forum/pets/demo-7#reply',
      selfWrittenText:
          'Bei uns war der Bezug bei 30 Grad problemlos waschbar, danach '
          'einfach lufttrocknen.',
      wasEditedFromGuidance: true,
      disclosureUsed: false,
      resultStatus: 'published',
      moderationNotes: 'Sachlich, eigene Worte, keine unzulässigen Aussagen.',
    ),
    HumanActionReport(
      id: 'har-2',
      taskId: 'ct-4',
      actionType: CommunityActionType.factualAnswer,
      performedBy: 'm-7',
      performedAt: DateTime(2026, 7, 18, 13, 10),
      originalPlatformUrl:
          'https://example.invalid/groups/wellnesstech/demo-8#reply',
      selfWrittenText:
          'Hatte das gleiche Problem – bei mir half es, Bluetooth einmal aus- '
          'und wieder einzuschalten und die App neu zu koppeln. (Ich arbeite '
          'gelegentlich bezahlt mit dem Anbieter zusammen.)',
      wasEditedFromGuidance: true,
      disclosureUsed: true,
      resultStatus: 'published',
      moderationNotes: 'Offenlegung korrekt, rein technische Antwort.',
    ),
  ];
}
