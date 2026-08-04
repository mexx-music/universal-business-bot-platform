import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_controller.dart';
import 'package:universalbusiness/ai/ai_models.dart';
import 'package:universalbusiness/ai/ai_provider.dart';
import 'package:universalbusiness/ai/ai_provider_config.dart';
import 'package:universalbusiness/ai/ai_provider_id.dart';
import 'package:universalbusiness/ai/ai_provider_registry.dart';
import 'package:universalbusiness/ai/grounded_answer_service.dart';
import 'package:universalbusiness/models/bot_configuration.dart';
import 'package:universalbusiness/models/business_rules.dart';
import 'package:universalbusiness/models/company.dart';
import 'package:universalbusiness/models/company_workspace.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';

class _ExactAnswerProvider implements AiProvider {
  _ExactAnswerProvider(this.answer);

  final String answer;
  AiRequest? request;

  @override
  AiProviderId get id => AiProviderId.googleGemini;

  @override
  String get displayName => 'Exact answer provider';

  @override
  AiProviderCapabilities get capabilities => const AiProviderCapabilities();

  @override
  Future<AiResponse> generate(AiRequest request) async {
    this.request = request;
    return AiResponse(
      text: answer,
      providerId: id,
      model: 'test-model',
      raw: const {},
    );
  }

  @override
  Future<AiProviderHealth> testConnection() async =>
      const AiProviderHealth.healthy();
}

AiController _controllerWith(_ExactAnswerProvider provider) {
  final config = AiProviderCatalog.defaults().firstWhere(
    (candidate) => candidate.id == provider.id,
  );
  return AiController(
    AiProviderRegistry(configs: [config], adapterFactory: (_) => provider),
    activeProviderId: provider.id,
  );
}

KnowledgeEntry _entry(
  String id,
  String content, {
  KnowledgeEntryLink? link,
  List<String> keywords = const ['CureBase'],
}) => KnowledgeEntry(
  id: id,
  title: 'CureBase $id',
  content: content,
  category: KnowledgeCategory.faq,
  riskLevel: RiskLevel.green,
  keywords: keywords,
  source: 'Bestätigte Quelle',
  createdAt: DateTime.utc(2026, 8, 4),
  languageCode: 'de',
  websiteLink: link,
);

CompanyWorkspace _workspace(List<KnowledgeEntry> entries) => CompanyWorkspace(
  company: const Company(
    id: 'website-links',
    name: 'Website Links',
    industry: '',
    description: '',
    website: '',
    email: 'test@example.invalid',
    address: '',
  ),
  products: const [],
  knowledgeEntries: entries,
  botLogs: const [],
  auditItems: const [],
  businessRules: const BusinessRules(
    brandVoice: '',
    doNotSay: [],
    allowedSupportTopics: [],
    escalationNotes: '',
  ),
  botConfiguration: const BotConfiguration(
    status: BotStatus.testReady,
    answerStyle: BotAnswerStyle.balanced,
    defaultLanguage: 'de',
    useDisclaimer: false,
    disclaimerText: '',
    alwaysEscalateRedFlags: true,
    escalateNoMatch: true,
    escalateYellowRisk: false,
    allowedTopics: [],
    blockedTopics: [],
    handoverMessage: '',
  ),
  sourceMaterials: const [],
);

Future<GroundedAnswerResult> _answer(
  String question,
  List<KnowledgeEntry> entries,
) =>
    GroundedAnswerService(
      aiController: AiController(AiProviderRegistry.mock()),
    ).answer(
      GroundedAnswerRequest(
        question: question,
        workspace: _workspace(entries),
        language: 'de',
      ),
    );

void main() {
  test(
    'knowledge entry without link keeps grounded answer unchanged',
    () async {
      final result = await _answer('Was ist CureBase?', [
        _entry('definition', 'CureBase ist das stationäre Gerät des Systems.'),
      ]);

      expect(result.outcome, GroundedOutcome.answered);
      expect(result.answer, 'CureBase ist das stationäre Gerät des Systems.');
      expect(result.sources.map((source) => source.id), ['definition']);
      expect(result.websiteLinks, isEmpty);
    },
  );

  test('one link comes only from the used knowledge entry', () async {
    const link = KnowledgeEntryLink(
      url: 'https://company.example/curebase',
      title: 'Mehr über CureBase',
      type: KnowledgeLinkType.productPage,
    );
    final result = await _answer('Was ist CureBase?', [
      _entry(
        'definition',
        'CureBase ist das stationäre Gerät des Systems.',
        link: link,
      ),
    ]);

    expect(result.websiteLinks, [same(link)]);
    expect(result.sources.single.websiteLink, same(link));
  });

  test('multiple links follow the required business order', () async {
    final result = await _answer('Was ist CureBase?', [
      _entry(
        'faq',
        'CureBase wird in den häufigen Fragen beschrieben.',
        link: const KnowledgeEntryLink(
          url: 'https://company.example/faq',
          title: 'FAQ',
          type: KnowledgeLinkType.faq,
        ),
      ),
      _entry(
        'prices',
        'CureBase kostet laut bestätigter Preisliste 1.490 Euro.',
        link: const KnowledgeEntryLink(
          url: 'https://company.example/prices',
          title: 'Aktuelle Preise',
          type: KnowledgeLinkType.prices,
        ),
      ),
      _entry(
        'product',
        'CureBase ist das stationäre Gerät des Systems.',
        link: const KnowledgeEntryLink(
          url: 'https://company.example/curebase',
          title: 'Mehr über CureBase',
          type: KnowledgeLinkType.productPage,
        ),
      ),
    ]);

    expect(result.websiteLinks.map((link) => link.type), [
      KnowledgeLinkType.productPage,
      KnowledgeLinkType.prices,
      KnowledgeLinkType.faq,
    ]);
  });

  test('duplicate URLs are collapsed even when titles differ', () async {
    final result = await _answer('Was ist CureBase?', [
      _entry(
        'one',
        'CureBase ist das stationäre Gerät.',
        link: const KnowledgeEntryLink(
          url: 'https://company.example/curebase/',
          title: 'CureBase öffnen',
          type: KnowledgeLinkType.productPage,
        ),
      ),
      _entry(
        'two',
        'CureBase wird über die App bedient.',
        link: const KnowledgeEntryLink(
          url: 'https://company.example/curebase',
          title: 'Mehr erfahren',
          type: KnowledgeLinkType.productPage,
        ),
      ),
    ]);

    expect(result.sources, hasLength(2));
    expect(result.websiteLinks, hasLength(1));
  });

  test('price gap retains the official price-page action', () async {
    final result = await _answer('Was kostet die CureBase?', [
      _entry(
        'overview',
        'CureBase ist das stationäre Gerät des Systems.',
        link: const KnowledgeEntryLink(
          url: 'https://company.example/prices',
          title: 'Aktuelle Preise ansehen',
          type: KnowledgeLinkType.prices,
        ),
      ),
    ]);

    expect(result.answer, startsWith('Ein bestätigter Preis für CureBase'));
    expect(result.websiteLinks.single.type, KnowledgeLinkType.prices);
    expect(result.websiteLinks.single.title, 'Aktuelle Preise ansehen');
  });

  test(
    'download question exposes only the used download destination',
    () async {
      final result = await _answer('Wo finde ich den Firmware Download?', [
        _entry(
          'firmware',
          'Der Firmware Download und die Anleitung stehen im Downloadbereich.',
          keywords: const ['Firmware', 'Download', 'Anleitung'],
          link: const KnowledgeEntryLink(
            url: 'https://company.example/downloads',
            title: 'Download öffnen',
            type: KnowledgeLinkType.download,
          ),
        ),
      ]);

      expect(result.outcome, GroundedOutcome.answered);
      expect(result.websiteLinks.single.type, KnowledgeLinkType.download);
    },
  );

  test('contact question exposes confirmed support destination', () async {
    final result = await _answer('Wer hilft bei Problemen?', [
      _entry(
        'support',
        'Bei Problemen hilft der bestätigte Support.',
        keywords: const ['Probleme', 'Support', 'Hilfe'],
        link: const KnowledgeEntryLink(
          url: 'https://company.example/support',
          title: 'Support kontaktieren',
          type: KnowledgeLinkType.support,
        ),
      ),
    ]);

    expect(result.outcome, GroundedOutcome.answered);
    expect(result.websiteLinks.single.type, KnowledgeLinkType.support);
  });

  test('website metadata does not alter prompt or provider answer', () async {
    final provider = _ExactAnswerProvider('CureBase ist das stationäre Gerät.');
    final entry = _entry(
      'definition',
      'CureBase ist das stationäre Gerät.',
      link: const KnowledgeEntryLink(
        url: 'https://company.example/curebase',
        title: 'CureBase',
        type: KnowledgeLinkType.productPage,
      ),
    );
    final result =
        await GroundedAnswerService(
          aiController: _controllerWith(provider),
        ).answer(
          GroundedAnswerRequest(
            question: 'Was ist CureBase?',
            workspace: _workspace([entry]),
            language: 'de',
          ),
        );

    expect(result.answer, 'CureBase ist das stationäre Gerät.');
    expect(
      provider.request!.messages.last.content,
      isNot(contains(entry.websiteLink!.url)),
    );
    expect(result.sources.map((source) => source.id), ['definition']);
  });
}
