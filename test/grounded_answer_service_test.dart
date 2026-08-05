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
  String? languageCode,
  String? knowledgeArea,
  List<String> detectedTopics = const [],
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
    languageCode: languageCode,
    knowledgeArea: knowledgeArea,
    detectedTopics: detectedTopics,
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
        // An answered result never carries gap terms.
        expect(result.missingTerms, isEmpty);
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

    test('prefers the matching knowledge area over another product', () async {
      final fake = FakeAiProvider();
      final service = GroundedAnswerService(aiController: controllerWith(fake));
      final result = await service.answer(
        GroundedAnswerRequest(
          question: 'Wie funktioniert die HB Cure App?',
          workspace: workspace(
            entries: [
              entry(
                'a-businessbrain',
                'Wie funktioniert die HB Cure App?',
                'Die App zeigt Wissen aus BusinessBrain.',
                keywords: const ['app', 'funktioniert', 'hb', 'cure'],
                knowledgeArea: 'businessbrain_platform',
              ),
              entry(
                'z-hb-app',
                'Wie funktioniert die HB Cure App?',
                'Die HB Cure App verbindet sich mit dem Gerät.',
                keywords: const ['app', 'funktioniert', 'hb', 'cure'],
                knowledgeArea: 'hb_cure_app',
              ),
            ],
          ),
          language: 'de',
        ),
      );

      expect(result.sources.first.id, 'z-hb-app');
    });

    test('prefers source language when matching entries exist', () async {
      final fake = FakeAiProvider();
      final service = GroundedAnswerService(aiController: controllerWith(fake));
      final result = await service.answer(
        GroundedAnswerRequest(
          question: 'Wie funktioniert die App?',
          workspace: workspace(
            entries: [
              entry(
                'a-en',
                'Wie funktioniert die App?',
                'English source content about the app.',
                keywords: const ['app', 'funktioniert'],
                languageCode: 'en',
                knowledgeArea: 'other_product',
              ),
              entry(
                'z-de',
                'Wie funktioniert die App?',
                'Deutscher Quelleninhalt zur App.',
                keywords: const ['app', 'funktioniert'],
                languageCode: 'de',
                knowledgeArea: 'other_product',
              ),
            ],
          ),
          language: 'de',
        ),
      );

      expect(result.sources.map((source) => source.id), ['z-de']);
      expect(
        fake.lastRequest!.messages.last.content,
        isNot(contains('English source content')),
      );
    });

    test('known foreign-language entries never reach Gemini', () async {
      final fake = FakeAiProvider(text: 'Die Verbindung erfolgt automatisch.');
      final service = GroundedAnswerService(aiController: controllerWith(fake));
      final result = await service.answer(
        GroundedAnswerRequest(
          question: 'Wie funktioniert die Bluetooth-Verbindung?',
          workspace: workspace(
            entries: [
              entry(
                'en',
                'Bluetooth connection',
                'The device connects automatically through Bluetooth.',
                keywords: const ['bluetooth', 'verbindung'],
                languageCode: 'en',
              ),
              entry(
                'de',
                'Bluetooth-Verbindung',
                'Das Gerät verbindet sich automatisch über Bluetooth.',
                keywords: const ['bluetooth', 'verbindung'],
                languageCode: 'de',
              ),
            ],
          ),
          language: 'en',
        ),
      );

      expect(result.sources.map((source) => source.id), ['de']);
      final prompt = fake.lastRequest!.messages.last.content;
      expect(prompt, contains('Das Gerät verbindet sich'));
      expect(prompt, isNot(contains('The device connects')));
    });

    test(
      'only foreign-language knowledge is treated as insufficient',
      () async {
        final fake = FakeAiProvider();
        final service = GroundedAnswerService(
          aiController: controllerWith(fake),
        );
        final result = await service.answer(
          GroundedAnswerRequest(
            question: 'Wie funktioniert die Bluetooth-Verbindung?',
            workspace: workspace(
              entries: [
                entry(
                  'en',
                  'Bluetooth connection',
                  'The device connects automatically through Bluetooth.',
                  keywords: const ['bluetooth', 'verbindung'],
                  languageCode: 'en',
                ),
              ],
            ),
            language: 'de',
          ),
        );

        expect(result.outcome, GroundedOutcome.noKnowledge);
        expect(result.sources, isEmpty);
        expect(fake.calls, 0);
      },
    );

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
      final result = await service.answer(
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
      expect(result.sources.single.excerpt, contains('…'));
      expect(userMsg, contains(result.sources.single.excerpt));
    });

    test('question language overrides a different UI language', () async {
      final fake = FakeAiProvider();
      final service = GroundedAnswerService(aiController: controllerWith(fake));
      await service.answer(
        GroundedAnswerRequest(
          question: 'Wie wird der Kaffee geröstet?',
          workspace: workspace(
            entries: [
              entry(
                'de',
                'Kaffee rösten',
                'Der Kaffee wird täglich frisch geröstet.',
                keywords: const ['kaffee', 'geröstet'],
                languageCode: 'de',
              ),
            ],
          ),
          language: 'en',
        ),
      );
      final sys = fake.lastRequest!.messages.first.content;
      expect(sys, contains('"de"'));
      expect(fake.lastRequest!.metadata['answer_language'], 'de');
    });

    test('English question produces an English-only model contract', () async {
      final fake = FakeAiProvider(text: 'The app connects automatically.');
      final service = GroundedAnswerService(aiController: controllerWith(fake));
      final result = await service.answer(
        GroundedAnswerRequest(
          question: 'How does the app connect?',
          workspace: workspace(
            entries: [
              entry(
                'en',
                'App connection',
                'The app connects automatically through Bluetooth.',
                keywords: const ['app', 'connect'],
                languageCode: 'en',
              ),
            ],
          ),
          language: 'de',
        ),
      );

      expect(result.answer, 'The app connects automatically.');
      expect(fake.lastRequest!.messages.first.content, contains('"en"'));
      expect(fake.lastRequest!.metadata['answer_language'], 'en');
    });

    test('recognizably wrong-language model output is not displayed', () async {
      final fake = FakeAiProvider(
        text: 'The device connects automatically with the application.',
      );
      final service = GroundedAnswerService(aiController: controllerWith(fake));
      final result = await service.answer(
        GroundedAnswerRequest(
          question: 'Wie verbindet sich das Gerät mit der App?',
          workspace: workspace(
            entries: [
              entry(
                'de',
                'Gerät verbinden',
                'Das Gerät verbindet sich automatisch mit der App.',
                keywords: const ['gerät', 'app', 'verbindet'],
                languageCode: 'de',
              ),
            ],
          ),
          language: 'de',
        ),
      );

      expect(
        result.answer,
        'Die Wissensbasis enthält nicht genügend Informationen, um diese '
        'Frage zuverlässig zu beantworten.',
      );
      expect(result.answer, isNot(contains('The device')));
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
      // Missing terms come verbatim from the question (never invented).
      expect(result.missingTerms, isNotEmpty);
      expect(result.missingTerms, contains('xylophonbau'));
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

        expect(sys, contains('ONLY allowed source'));
        expect(sys, contains('Never add facts from general knowledge'));
        expect(sys, contains('synthesize ALL documents'));
        expect(sys, contains('explicitly say so'));
        // Selected entries present; unrelated one absent.
        expect(user, contains('Kaffee Thema 1'));
        expect(user, isNot(contains('Regenschirm')));
        // No secrets and no full dump (bounded number of blocks).
        expect(user, isNot(contains('GEMINI_API_KEY')));
        expect(user, isNot(contains('AIza')));
        expect('<document'.allMatches(user).length, lessThanOrEqualTo(2));
      },
    );

    test('all selected matching entries are sent for synthesis', () async {
      final fake = FakeAiProvider(
        text: 'Die App verbindet, startet und stoppt.',
      );
      final service = GroundedAnswerService(aiController: controllerWith(fake));
      final result = await service.answer(
        GroundedAnswerRequest(
          question: 'Was kann die CureBase App?',
          workspace: workspace(
            entries: [
              entry(
                'one',
                'CureBase verbinden',
                'Die CureBase App verbindet sich mit dem Gerät.',
                keywords: const ['curebase', 'app'],
                languageCode: 'de',
              ),
              entry(
                'two',
                'CureBase starten',
                'Die CureBase App startet gespeicherte Programme.',
                keywords: const ['curebase', 'app'],
                languageCode: 'de',
              ),
              entry(
                'three',
                'CureBase stoppen',
                'Die CureBase App stoppt ein laufendes Programm.',
                keywords: const ['curebase', 'app'],
                languageCode: 'de',
              ),
            ],
          ),
          language: 'de',
        ),
      );

      expect(result.sources.map((source) => source.id).toSet(), {
        'one',
        'two',
        'three',
      });
      final prompt = fake.lastRequest!.messages.last.content;
      for (final source in result.sources) {
        expect(prompt, contains(source.excerpt));
      }
      expect('<document'.allMatches(prompt).length, 3);
    });

    test(
      'partial retrieval requires an explicit insufficiency statement',
      () async {
        final fake = FakeAiProvider();
        final service = GroundedAnswerService(
          aiController: controllerWith(fake),
        );
        await service.answer(
          GroundedAnswerRequest(
            question:
                'Wie verbindet sich die App mit dem unbekannten Satellit?',
            workspace: workspace(
              entries: [
                entry(
                  'de',
                  'App verbinden',
                  'Die App verbindet sich automatisch über Bluetooth.',
                  keywords: const ['app', 'verbindet', 'bluetooth'],
                  languageCode: 'de',
                ),
              ],
            ),
            language: 'de',
          ),
        );

        final request = fake.lastRequest!;
        expect(
          request.messages.last.content,
          contains('Knowledge coverage: PARTIAL'),
        );
        expect(request.messages.last.content, contains('satellit'));
        expect(
          request.messages.first.content,
          contains('explicitly say so and answer only the supported part'),
        );
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
      expect(result.answer, contains('nummer 1'));
      expect(result.answer, contains('nummer 2'));
      expect(result.answer, isNot(contains('[mock:')));
      expect(result.answer, isNot(contains('Company knowledge:')));
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
