import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_controller.dart';
import 'package:universalbusiness/ai/ai_models.dart';
import 'package:universalbusiness/ai/ai_provider.dart';
import 'package:universalbusiness/ai/ai_provider_config.dart';
import 'package:universalbusiness/ai/ai_provider_id.dart';
import 'package:universalbusiness/ai/ai_provider_registry.dart';
import 'package:universalbusiness/ai/grounded_answer_service.dart';
import 'package:universalbusiness/ai/grounded_question_strategy.dart';
import 'package:universalbusiness/models/bot_configuration.dart';
import 'package:universalbusiness/models/business_rules.dart';
import 'package:universalbusiness/models/company.dart';
import 'package:universalbusiness/models/company_workspace.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';

class _PromptProvider implements AiProvider {
  _PromptProvider(this.text);

  final String text;
  AiRequest? lastRequest;
  int calls = 0;

  @override
  AiProviderId get id => AiProviderId.googleGemini;

  @override
  String get displayName => 'Prompt test provider';

  @override
  AiProviderCapabilities get capabilities => const AiProviderCapabilities();

  @override
  Future<AiResponse> generate(AiRequest request) async {
    calls++;
    lastRequest = request;
    return AiResponse(
      text: text,
      providerId: id,
      model: 'test-model',
      raw: const {},
    );
  }

  @override
  Future<AiProviderHealth> testConnection() async =>
      const AiProviderHealth.healthy();
}

AiController _controllerWith(_PromptProvider provider) {
  final config = AiProviderCatalog.defaults().firstWhere(
    (candidate) => candidate.id == provider.id,
  );
  return AiController(
    AiProviderRegistry(configs: [config], adapterFactory: (_) => provider),
    activeProviderId: provider.id,
  );
}

AiController _mockController() => AiController(AiProviderRegistry.mock());

KnowledgeEntry _entry(
  String id,
  String title,
  String content, {
  List<String> keywords = const [],
  String languageCode = 'de',
  RiskLevel risk = RiskLevel.green,
  DateTime? createdAt,
}) => KnowledgeEntry(
  id: id,
  title: title,
  content: content,
  category: KnowledgeCategory.faq,
  riskLevel: risk,
  keywords: keywords,
  source: 'Bestätigte Testquelle',
  createdAt: createdAt ?? DateTime.utc(2026, 7, 15),
  languageCode: languageCode,
);

CompanyWorkspace _workspace(List<KnowledgeEntry> entries) => CompanyWorkspace(
  company: const Company(
    id: 'precision-company',
    name: 'Precision Company',
    industry: '',
    description: '',
    website: '',
    email: 'support@example.invalid',
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

Future<GroundedAnswerResult> _mockAnswer(
  String question,
  List<KnowledgeEntry> entries, {
  String language = 'de',
  DateTime? currentDate,
}) =>
    GroundedAnswerService(
      aiController: _mockController(),
      currentDate: currentDate,
    ).answer(
      GroundedAnswerRequest(
        question: question,
        workspace: _workspace(entries),
        language: language,
      ),
    );

void main() {
  group('question type recognition', () {
    const analyzer = GroundedQuestionAnalyzer();

    test('recognizes every supported business question type', () {
      final cases = <String, GroundedQuestionType>{
        'Was kostet das Produkt?': GroundedQuestionType.price,
        'Ist das Produkt verfügbar?': GroundedQuestionType.availability,
        'Wo kann ich das Produkt bestellen?': GroundedQuestionType.purchase,
        'Gibt es ein Kennenlernangebot?': GroundedQuestionType.offer,
        'Was ist CureClip?': GroundedQuestionType.productDefinition,
        'Was macht die App?': GroundedQuestionType.productFunction,
        'Wie starte ich das Programm?': GroundedQuestionType.usage,
        'Wie verbinde ich das Gerät?': GroundedQuestionType.connection,
        'Was tun bei einem Fehler?': GroundedQuestionType.troubleshooting,
        'Welche technischen Voraussetzungen gelten?':
            GroundedQuestionType.technicalRequirement,
        'Wie erreiche ich den Support?': GroundedQuestionType.contact,
        'Welche Garantie gilt?': GroundedQuestionType.warranty,
        'Wann erfolgt die Lieferung?': GroundedQuestionType.delivery,
        'Kann das Krankheiten heilen?': GroundedQuestionType.medicalSensitive,
        'Wo sitzt das Unternehmen?': GroundedQuestionType.company,
      };

      for (final MapEntry(key: question, value: expected) in cases.entries) {
        expect(analyzer.analyze(question).type, expected, reason: question);
      }
    });

    test('extracts the affected object without producing facts', () {
      final profile = analyzer.analyze('Was kostet die CureBase?');
      expect(profile.type, GroundedQuestionType.price);
      expect(profile.objectTerms, ['curebase']);
      expect(profile.objectLabel, 'CureBase');
    });
  });

  group('question-oriented grounded answers', () {
    test(
      'price question with confirmed price answers directly and fully',
      () async {
        final result = await _mockAnswer('Was kostet die CureBase?', [
          _entry(
            'general',
            'CureBase Überblick',
            'Die CureBase ist das stationäre Gerät des Systems.',
            keywords: const ['CureBase'],
          ),
          _entry(
            'price',
            'CureBase Preis',
            'Die CureBase kostet aktuell 1.490 Euro.',
            keywords: const ['CureBase', 'Preis'],
          ),
        ]);

        expect(result.questionType, GroundedQuestionType.price);
        expect(result.coverage, GroundedEvidenceCoverage.fullyAnswerable);
        expect(
          result.answer,
          startsWith('Die CureBase kostet aktuell 1.490 Euro.'),
        );
        expect(result.sources.map((source) => source.id), ['price']);
      },
    );

    test(
      'price question without price states the missing fact first',
      () async {
        final result = await _mockAnswer('Was kostet die CureBase?', [
          _entry(
            'definition',
            'CureBase Überblick',
            'Die CureBase ist das stationäre Gerät des HB-Cure-Systems.',
            keywords: const ['CureBase'],
          ),
          _entry(
            'trial',
            'CureBase kennenlernen',
            'Die CureBase kann im 30-Tage-Kennenlernangebot getestet werden.',
            keywords: const ['CureBase', 'Kennenlernangebot'],
          ),
        ]);

        expect(result.coverage, GroundedEvidenceCoverage.partiallyAnswerable);
        expect(result.missingCoreInformation, isTrue);
        expect(
          result.answer,
          startsWith(
            'Ein bestätigter Preis für CureBase ist in der aktuellen '
            'Wissensbasis nicht hinterlegt.',
          ),
        );
        expect(result.answer, contains('stationäre Gerät'));
        expect(result.answer, contains('30-Tage-Kennenlernangebot'));
      },
    );

    test(
      'stale confirmed price is dated and not presented as guaranteed current',
      () async {
        final result = await _mockAnswer('Was kostet die CureBase?', [
          _entry(
            'stale-price',
            'CureBase Preis',
            'Die CureBase kostet 1.490 Euro.',
            keywords: const ['CureBase', 'Preis'],
            createdAt: DateTime.utc(2024, 7, 15),
          ),
        ], currentDate: DateTime.utc(2026, 8, 4));

        expect(result.coverage, GroundedEvidenceCoverage.fullyAnswerable);
        expect(result.stalePriceDate, DateTime.utc(2024, 7, 15));
        expect(result.answer, contains('15.07.2024'));
        expect(result.answer, contains('erneut bestätigt'));
      },
    );

    test('product definition uses only the matching definition', () async {
      final result = await _mockAnswer('Was ist CureClip?', [
        _entry(
          'clip',
          'CureClip Produktbeschreibung',
          'CureClip ist das mobile Gerät des Systems.',
          keywords: const ['CureClip', 'mobil'],
        ),
        _entry(
          'base',
          'CureBase Produktbeschreibung',
          'CureBase ist das stationäre Gerät des Systems.',
          keywords: const ['CureBase'],
        ),
      ]);

      expect(result.questionType, GroundedQuestionType.productDefinition);
      expect(result.coverage, GroundedEvidenceCoverage.fullyAnswerable);
      expect(result.answer, startsWith('CureClip ist das mobile Gerät'));
      expect(result.sources.map((source) => source.id), ['clip']);
    });

    test('usage question prioritizes confirmed operating steps', () async {
      final result = await _mockAnswer('Wie starte ich ein Programm?', [
        _entry(
          'usage',
          'Programm starten',
          'Ein Programm wird in der App ausgewählt und über Start gestartet.',
          keywords: const ['Programm', 'Start', 'App'],
        ),
      ]);

      expect(result.questionType, GroundedQuestionType.usage);
      expect(result.coverage, GroundedEvidenceCoverage.fullyAnswerable);
      expect(result.answer, contains('über Start gestartet'));
    });

    test('troubleshooting question prioritizes the corrective action', () async {
      final result = await _mockAnswer('Was tun bei einem Bluetooth-Problem?', [
        _entry(
          'problem',
          'Bluetooth-Problem lösen',
          'Bei einem Bluetooth-Problem werden Akkustand und Reichweite geprüft.',
          keywords: const ['Bluetooth', 'Problem', 'Akkustand', 'Reichweite'],
        ),
      ]);

      expect(result.questionType, GroundedQuestionType.troubleshooting);
      expect(result.coverage, GroundedEvidenceCoverage.fullyAnswerable);
      expect(result.answer, contains('Akkustand und Reichweite'));
    });

    test('contact question returns confirmed contact data', () async {
      final result = await _mockAnswer('Wie erreiche ich Healing & Balance?', [
        _entry(
          'contact',
          'Kontakt Healing & Balance',
          'Healing & Balance ist per E-Mail unter hallo@example.invalid erreichbar.',
          keywords: const ['Kontakt', 'E-Mail'],
        ),
      ]);

      expect(result.questionType, GroundedQuestionType.contact);
      expect(result.outcome, GroundedOutcome.answered);
      expect(result.answer, contains('hallo@example.invalid'));
    });

    test(
      'medical question is marked sensitive and never reaches a model',
      () async {
        final provider = _PromptProvider('This must never be shown.');
        final result =
            await GroundedAnswerService(
              aiController: _controllerWith(provider),
            ).answer(
              GroundedAnswerRequest(
                question: 'Kann HB Cure Krankheiten heilen?',
                workspace: _workspace([
                  _entry(
                    'claim',
                    'Geprüfte Wirkungsbeschreibung',
                    'Es werden keine Heilversprechen abgegeben.',
                    keywords: const ['Heilversprechen'],
                    risk: RiskLevel.yellow,
                  ),
                ]),
                language: 'de',
              ),
            );

        expect(result.questionType, GroundedQuestionType.medicalSensitive);
        expect(result.outcome, GroundedOutcome.blockedTopic);
        expect(result.coverage, GroundedEvidenceCoverage.sensitiveReview);
        expect(provider.calls, 0);
      },
    );

    test('uncovered question has no answer, source or provider call', () async {
      final provider = _PromptProvider('This must never be shown.');
      final result =
          await GroundedAnswerService(
            aiController: _controllerWith(provider),
          ).answer(
            GroundedAnswerRequest(
              question: 'Welche Garantie hat das Xylophon?',
              workspace: _workspace([
                _entry('coffee', 'Kaffee', 'Der Kaffee wird täglich geröstet.'),
              ]),
              language: 'de',
            ),
          );

      expect(result.outcome, GroundedOutcome.noKnowledge);
      expect(result.coverage, GroundedEvidenceCoverage.notAnswerable);
      expect(result.sources, isEmpty);
      expect(provider.calls, 0);
    });

    test(
      'German and English questions keep their own answer language',
      () async {
        final de = await _mockAnswer('Was kostet die CureBase?', [
          _entry(
            'de-general',
            'CureBase Überblick',
            'Die CureBase ist das stationäre Gerät.',
            keywords: const ['CureBase'],
          ),
        ]);
        final en = await _mockAnswer('How much does CureBase cost?', [
          _entry(
            'en-general',
            'CureBase overview',
            'CureBase is the stationary device.',
            keywords: const ['CureBase'],
            languageCode: 'en',
          ),
        ], language: 'de');

        expect(de.answer, startsWith('Ein bestätigter Preis'));
        expect(en.answer, startsWith('A confirmed price for CureBase'));
        expect(en.answer, isNot(contains('Wissensbasis')));
      },
    );

    test(
      'specific price evidence displaces general and unrelated sources',
      () async {
        final provider = _PromptProvider('Die CureBase kostet 1.490 Euro.');
        final result =
            await GroundedAnswerService(
              aiController: _controllerWith(provider),
            ).answer(
              GroundedAnswerRequest(
                question: 'Was kostet die CureBase?',
                workspace: _workspace([
                  _entry(
                    'general',
                    'CureBase Überblick',
                    'Die CureBase ist ein Gerät.',
                    keywords: const ['CureBase'],
                  ),
                  _entry(
                    'price',
                    'CureBase Preis',
                    'Die CureBase kostet 1.490 Euro.',
                    keywords: const ['CureBase', 'Preis'],
                  ),
                  _entry(
                    'clip-price',
                    'CureClip Preis',
                    'Der CureClip kostet 490 Euro.',
                    keywords: const ['CureClip', 'Preis'],
                  ),
                ]),
                language: 'de',
              ),
            );

        expect(result.sources.map((source) => source.id), ['price']);
        final prompt = provider.lastRequest!.messages.last.content;
        expect(prompt, contains('Die CureBase kostet 1.490 Euro.'));
        expect(prompt, isNot(contains('Die CureBase ist ein Gerät.')));
        expect(prompt, isNot(contains('Der CureClip kostet 490 Euro.')));
      },
    );

    test('duplicate evidence is shown and formulated only once', () async {
      final result = await _mockAnswer('Was kostet die CureBase?', [
        _entry(
          'price-a',
          'CureBase Preis A',
          'Die CureBase kostet 1.490 Euro.',
          keywords: const ['CureBase', 'Preis'],
        ),
        _entry(
          'price-b',
          'CureBase Preis B',
          'Die CureBase kostet 1.490 Euro.',
          keywords: const ['CureBase', 'Preis'],
        ),
      ]);

      expect(result.sources, hasLength(1));
      expect('1.490 Euro'.allMatches(result.answer), hasLength(1));
    });

    test(
      'mock mode uses the same direct strategy without diagnostic wording',
      () async {
        final result = await _mockAnswer('Was kostet die CureBase?', [
          _entry(
            'general',
            'CureBase Überblick',
            'Die CureBase ist das stationäre Gerät.',
            keywords: const ['CureBase'],
          ),
        ]);

        expect(result.isMock, isTrue);
        expect(result.answer, startsWith('Ein bestätigter Preis'));
        expect(result.answer, isNot(contains('[mock:')));
        expect(
          result.answer,
          isNot(contains('Die Wissensbasis enthält dazu folgende')),
        );
      },
    );
  });
}
