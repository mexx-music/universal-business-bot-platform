import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_controller.dart';
import 'package:universalbusiness/ai/ai_models.dart';
import 'package:universalbusiness/ai/ai_provider.dart';
import 'package:universalbusiness/ai/ai_provider_config.dart';
import 'package:universalbusiness/ai/ai_provider_id.dart';
import 'package:universalbusiness/ai/ai_provider_registry.dart';
import 'package:universalbusiness/ai/ai_transport.dart';
import 'package:universalbusiness/ai/grounded_answer_service.dart';
import 'package:universalbusiness/ai/providers/mock_ai_provider.dart';
import 'package:universalbusiness/models/bot_configuration.dart';
import 'package:universalbusiness/models/business_rules.dart';
import 'package:universalbusiness/models/company.dart';
import 'package:universalbusiness/models/company_workspace.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';

/// Records the request and replays a scripted response/error. No network.
class FakeAiProvider implements AiProvider {
  FakeAiProvider({this.text = 'ECHO', this.error});

  final String text;
  final Object? error;
  AiRequest? lastRequest;
  int calls = 0;

  @override
  AiProviderId get id => AiProviderId.googleGemini;
  @override
  String get displayName => 'FakeVendor';
  @override
  AiProviderCapabilities get capabilities => const AiProviderCapabilities();

  @override
  Future<AiResponse> generate(AiRequest request) async {
    calls++;
    lastRequest = request;
    if (error != null) throw error!;
    return AiResponse(
      text: text,
      providerId: id,
      model: 'gemini-3.6-flash',
      raw: const {'requestId': 'req-xyz'},
    );
  }

  @override
  Future<AiProviderHealth> testConnection() async =>
      const AiProviderHealth.healthy();
}

AiController controllerWith(FakeAiProvider provider) {
  final config = AiProviderCatalog.defaults().firstWhere(
    (c) => c.id == provider.id,
  );
  return AiController(
    AiProviderRegistry(configs: [config], adapterFactory: (_) => provider),
    activeProviderId: provider.id,
  );
}

KnowledgeEntry entry(
  String id,
  String title,
  String content, {
  RiskLevel risk = RiskLevel.green,
  List<String> keywords = const [],
}) {
  return KnowledgeEntry(
    id: id,
    title: title,
    content: content,
    category: KnowledgeCategory.faq,
    riskLevel: risk,
    keywords: keywords,
    source: 'Test',
    createdAt: DateTime(2026, 1, 1),
  );
}

CompanyWorkspace workspace({
  required List<KnowledgeEntry> entries,
  List<String> blockedTopics = const [],
}) {
  return CompanyWorkspace(
    company: const Company(
      id: 'co-a',
      name: 'Firma A',
      industry: '',
      description: '',
      website: '',
      email: 'a@example.invalid',
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
    botConfiguration: BotConfiguration(
      status: BotStatus.testReady,
      answerStyle: BotAnswerStyle.balanced,
      defaultLanguage: 'de',
      useDisclaimer: false,
      disclaimerText: '',
      alwaysEscalateRedFlags: true,
      escalateNoMatch: true,
      escalateYellowRisk: false,
      allowedTopics: const [],
      blockedTopics: blockedTopics,
      handoverMessage: '',
    ),
    sourceMaterials: const [],
  );
}

List<KnowledgeEntry> coffeeEntries(int n) => [
  for (var i = 1; i <= n; i++)
    entry(
      'k$i',
      'Kaffee Thema $i',
      'Ausführliche Infos über kaffee und rösterei nummer $i. '
          'Kaffee schmeckt gut.',
      keywords: const ['kaffee', 'rösterei'],
    ),
];

void main() {
  group('GroundedAnswerService', () {
    test('empty question throws (no AI call)', () async {
      final fake = FakeAiProvider();
      final service = GroundedAnswerService(aiController: controllerWith(fake));
      await expectLater(
        service.answer(
          GroundedAnswerRequest(
            question: '   ',
            workspace: workspace(entries: coffeeEntries(2)),
            language: 'de',
          ),
        ),
        throwsA(isA<GroundedAnswerException>()),
      );
      expect(fake.calls, 0);
    });

    test(
      'uses relevant entries; sources match exactly the used entries',
      () async {
        final fake = FakeAiProvider();
        final service = GroundedAnswerService(
          aiController: controllerWith(fake),
        );
        final result = await service.answer(
          GroundedAnswerRequest(
            question: 'kaffee',
            workspace: workspace(entries: coffeeEntries(3)),
            language: 'de',
          ),
        );
        expect(result.outcome, GroundedOutcome.answered);
        expect(result.grounded, isTrue);
        expect(result.usedKnowledge, isTrue);
        expect(result.sources, isNotEmpty);
        // Every source id is one of the used entries, and appears in the prompt.
        final userMsg = fake.lastRequest!.messages.last.content;
        for (final s in result.sources) {
          expect(s.id, startsWith('k'));
          expect(userMsg, contains(s.title));
        }
        expect(result.model, 'gemini-3.6-flash');
        expect(result.requestId, 'req-xyz');
      },
    );

    test('limits the number of sources', () async {
      final fake = FakeAiProvider();
      final service = GroundedAnswerService(aiController: controllerWith(fake));
      final result = await service.answer(
        GroundedAnswerRequest(
          question: 'kaffee',
          workspace: workspace(entries: coffeeEntries(10)),
          language: 'de',
          maxSources: 3,
        ),
      );
      expect(result.sources.length, lessThanOrEqualTo(3));
    });

    test('limits context size and excerpt length', () async {
      final fake = FakeAiProvider();
      final long = entry(
        'k1',
        'Kaffee lang',
        'kaffee ${'sehr langer inhalt ' * 200}',
        keywords: const ['kaffee'],
      );
      final service = GroundedAnswerService(
        aiController: controllerWith(fake),
        maxEntryChars: 100,
        maxContextChars: 500,
      );
      await service.answer(
        GroundedAnswerRequest(
          question: 'kaffee',
          workspace: workspace(entries: [long]),
          language: 'de',
        ),
      );
      final userMsg = fake.lastRequest!.messages.last.content;
      // Context is bounded; the ellipsis marks truncation.
      expect(userMsg.length, lessThan(1200));
      expect(userMsg, contains('…'));
    });

    test('passes the requested language into the system prompt', () async {
      final fake = FakeAiProvider();
      final service = GroundedAnswerService(aiController: controllerWith(fake));
      await service.answer(
        GroundedAnswerRequest(
          question: 'kaffee',
          workspace: workspace(entries: coffeeEntries(1)),
          language: 'en',
        ),
      );
      final sys = fake.lastRequest!.messages.first.content;
      expect(sys, contains('"en"'));
    });

    test('no usable knowledge -> no AI call, grounded false', () async {
      final fake = FakeAiProvider();
      final service = GroundedAnswerService(aiController: controllerWith(fake));
      final result = await service.answer(
        GroundedAnswerRequest(
          question: 'xylophonbau',
          workspace: workspace(entries: coffeeEntries(3)),
          language: 'de',
        ),
      );
      expect(result.outcome, GroundedOutcome.noKnowledge);
      expect(result.grounded, isFalse);
      expect(result.usedKnowledge, isFalse);
      expect(result.sources, isEmpty);
      expect(fake.calls, 0);
    });

    test('blocked topic -> no AI call, blockedTopic outcome', () async {
      final fake = FakeAiProvider();
      final service = GroundedAnswerService(aiController: controllerWith(fake));
      final result = await service.answer(
        GroundedAnswerRequest(
          question: 'diagnose bitte',
          workspace: workspace(
            entries: coffeeEntries(2),
            blockedTopics: const ['diagnose'],
          ),
          language: 'de',
        ),
      );
      expect(result.outcome, GroundedOutcome.blockedTopic);
      expect(fake.calls, 0);
    });

    test('provider errors are not swallowed', () async {
      final fake = FakeAiProvider(
        error: const AiTransportException(
          AiTransportErrorKind.rateLimited,
          'slow down',
        ),
      );
      final service = GroundedAnswerService(aiController: controllerWith(fake));
      await expectLater(
        service.answer(
          GroundedAnswerRequest(
            question: 'kaffee',
            workspace: workspace(entries: coffeeEntries(2)),
            language: 'de',
          ),
        ),
        throwsA(isA<AiTransportException>()),
      );
    });

    test('sources come only from the given workspace', () async {
      final fake = FakeAiProvider();
      final service = GroundedAnswerService(aiController: controllerWith(fake));
      final ws = workspace(entries: coffeeEntries(4));
      final ids = ws.knowledgeEntries.map((e) => e.id).toSet();
      final result = await service.answer(
        GroundedAnswerRequest(
          question: 'kaffee',
          workspace: ws,
          language: 'de',
        ),
      );
      for (final s in result.sources) {
        expect(ids.contains(s.id), isTrue);
      }
    });
  });

  group('Prompt rules and content', () {
    test(
      'system rules present; only selected knowledge; no key/dump',
      () async {
        final fake = FakeAiProvider();
        final service = GroundedAnswerService(
          aiController: controllerWith(fake),
        );
        final entries = [
          ...coffeeEntries(2),
          entry(
            'unrelated',
            'Regenschirm',
            'nichts mit kaffee',
            keywords: const ['regen'],
          ),
        ];
        await service.answer(
          GroundedAnswerRequest(
            question: 'kaffee',
            workspace: workspace(entries: entries),
            language: 'de',
            maxSources: 2,
          ),
        );
        final sys = fake.lastRequest!.messages.first.content;
        final user = fake.lastRequest!.messages.last.content;

        expect(sys, contains('Answer ONLY using'));
        expect(sys, contains('not found in the knowledge base'));
        // Selected entries present; unrelated one absent.
        expect(user, contains('Kaffee Thema 1'));
        expect(user, isNot(contains('Regenschirm')));
        // No secrets and no full dump (bounded number of blocks).
        expect(user, isNot(contains('GEMINI_API_KEY')));
        expect(user, isNot(contains('AIza')));
        expect('['.allMatches(user).length, lessThanOrEqualTo(2));
      },
    );
  });

  group('Provider behaviour', () {
    test('mock provider stays offline and reacts to context', () async {
      // Real MockAiProvider via the standard registry (active = openAi).
      final controller = AiController(AiProviderRegistry.mock());
      final service = GroundedAnswerService(aiController: controller);
      final result = await service.answer(
        GroundedAnswerRequest(
          question: 'kaffee',
          workspace: workspace(entries: coffeeEntries(2)),
          language: 'de',
        ),
      );
      expect(result.isMock, isTrue);
      expect(result.grounded, isTrue);
      // Mock echoes the context-bearing user message.
      expect(result.answer.toLowerCase(), contains('kaffee'));
    });

    test(
      'gemini error does not become a mock answer; provider stays gemini',
      () async {
        final fake = FakeAiProvider(
          error: const AiTransportException(
            AiTransportErrorKind.network,
            'down',
          ),
        );
        final controller = controllerWith(fake);
        final service = GroundedAnswerService(aiController: controller);
        await expectLater(
          service.answer(
            GroundedAnswerRequest(
              question: 'kaffee',
              workspace: workspace(entries: coffeeEntries(2)),
              language: 'de',
            ),
          ),
          throwsA(isA<AiTransportException>()),
        );
        expect(controller.activeProviderId, AiProviderId.googleGemini);
        expect(activeIsNotMock(controller), isTrue);
      },
    );
  });
}

bool activeIsNotMock(AiController c) => c.activeProvider is! MockAiProvider;
