import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/mock_data.dart';
import 'package:universalbusiness/models/bot_configuration.dart';
import 'package:universalbusiness/models/bot_question_log.dart';
import 'package:universalbusiness/models/business_rules.dart';
import 'package:universalbusiness/models/company.dart';
import 'package:universalbusiness/models/company_workspace.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';
import 'package:universalbusiness/models/source_material.dart';
import 'package:universalbusiness/runtime/knowledge_answer_context.dart';
import 'package:universalbusiness/runtime/knowledge_retriever.dart';
import 'package:universalbusiness/runtime/knowledge_runtime.dart';

void main() {
  final now = DateTime(2026, 7, 16);
  const runtime = KnowledgeRuntime();

  CompanyWorkspace buildWorkspace() {
    return CompanyWorkspace(
      company: const Company(
        id: 'test-co',
        name: 'Test GmbH',
        industry: 'Software',
        description: 'Testfirma',
        website: 'https://example.com',
        email: 'support@example.com',
        address: 'Teststraße 1',
      ),
      products: const [],
      knowledgeEntries: [
        KnowledgeEntry(
          id: 'e-price',
          title: 'Was kostet der Premium-Tarif?',
          content: 'Der Premium-Tarif kostet 9 Euro pro Monat.',
          category: KnowledgeCategory.faq,
          riskLevel: RiskLevel.green,
          keywords: const ['preis', 'abo'],
          source: 'Preisliste',
          createdAt: DateTime(2026, 6, 1),
        ),
        KnowledgeEntry(
          id: 'e-shipping',
          title: 'Lieferzeiten',
          content: 'Der Versand dauert in der Regel drei Werktage.',
          category: KnowledgeCategory.prozess,
          riskLevel: RiskLevel.green,
          keywords: const ['versand'],
          source: 'Logistik-Handbuch',
          createdAt: DateTime(2024, 1, 1),
        ),
        KnowledgeEntry(
          id: 'e-restricted',
          title: 'Medizinische Diagnosen',
          content: 'Der Bot stellt keine Diagnosen.',
          category: KnowledgeCategory.allgemein,
          riskLevel: RiskLevel.red,
          keywords: const ['diagnose'],
          source: 'Rechtliche Richtlinien',
          createdAt: DateTime(2026, 6, 1),
        ),
      ],
      botLogs: [
        BotQuestionLog(
          id: 'log-closed',
          question: 'Was kostet Premium?',
          answer: 'Premium kostet 9 Euro pro Monat.',
          matched: true,
          timestamp: DateTime(2026, 5, 1),
          reviewStatus: ReviewStatus.closed,
        ),
        BotQuestionLog(
          id: 'log-open',
          question: 'Was kostet der Versand?',
          matched: false,
          timestamp: DateTime(2026, 5, 2),
          reviewStatus: ReviewStatus.open,
          reviewReason: ReviewReason.noMatch,
        ),
      ],
      auditItems: const [],
      businessRules: const BusinessRules(
        brandVoice: 'freundlich',
        doNotSay: [],
        allowedSupportTopics: ['Preise'],
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
        allowedTopics: ['Preise'],
        blockedTopics: ['Diagnosen'],
        handoverMessage: 'Bitte an den Support wenden.',
      ),
      sourceMaterials: [
        SourceMaterial(
          id: 's-pricelist',
          title: 'Preisliste 2026',
          type: SourceMaterialType.pdf,
          contentSnippet: 'Premium 9 Euro pro Monat',
          status: SourceMaterialStatus.reviewed,
          createdAt: DateTime(2026, 5, 1),
          updatedAt: DateTime(2026, 6, 1),
        ),
        SourceMaterial(
          id: 's-ignored',
          title: 'Alte Preisliste',
          type: SourceMaterialType.pdf,
          contentSnippet: 'Premium 5 Euro',
          status: SourceMaterialStatus.ignored,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        ),
      ],
    );
  }

  group('KnowledgeRetriever', () {
    test('drops stopwords and expands simple synonyms', () {
      const retriever = KnowledgeRetriever();
      final profile = retriever.profile('Was kostet der Premium-Tarif?');

      expect(profile.baseTerms, ['kostet', 'premium', 'tarif']);
      expect(profile.expansions['kostet'], contains('preis'));
      expect(profile.expansions['kostet'], contains('kosten'));
    });

    test(
      'searches entries, sources, reviewed logs and bot rules; '
      'ignored sources and open logs are excluded',
      () {
        const retriever = KnowledgeRetriever();
        final workspace = buildWorkspace();
        final result = retriever.retrieve(
          'Was kostet das Premium-Abo?',
          workspace,
        );

        expect(
          result.entrySignals.map((s) => s.entry.id),
          contains('e-price'),
        );
        expect(
          result.sourceSignals.map((s) => s.source.id),
          ['s-pricelist'],
        );
        expect(
          result.reviewedSimilarLogs.map((log) => log.id),
          ['log-closed'],
        );
        expect(result.allowedTopicHits, contains('Preise'));
        expect(result.blockedTopicHits, isEmpty);
      },
    );
  });

  group('KnowledgeRuntime', () {
    test('well-covered question yields high confidence, no gap', () {
      final context = runtime.buildContext(
        userQuestion: 'Was kostet das Premium-Abo?',
        workspace: buildWorkspace(),
        now: now,
      );

      expect(context.topEntries.first.entry.id, 'e-price');
      expect(context.topSources.first.source.id, 's-pricelist');
      expect(context.confidence, greaterThanOrEqualTo(70));
      expect(context.confidenceLevel, KnowledgeConfidenceLevel.high);
      expect(context.hasGap, isFalse);
      expect(context.requiresHumanHandover, isFalse);
      expect(
        context.topEntries.first.reasons,
        contains('Durch Human Review bestätigt'),
      );
      expect(
        context.reasoning,
        contains('Confidence: ${context.confidence} %.'),
      );
    });

    test('partially covered question yields medium confidence and names '
        'the missing term', () {
      final context = runtime.buildContext(
        userQuestion: 'Was kostet die Zusatzversicherung?',
        workspace: buildWorkspace(),
        now: now,
      );

      expect(context.confidence, inInclusiveRange(40, 69));
      expect(context.confidenceLevel, KnowledgeConfidenceLevel.partial);
      expect(
        context.missingInformation,
        contains('Kein freigegebenes Wissen zum Begriff „zusatzversicherung".'),
      );
      expect(
        context.openQuestions,
        contains('Soll zu „zusatzversicherung" ein Wissenseintrag angelegt '
            'werden?'),
      );
    });

    test('unknown question yields low confidence and a knowledge gap that '
        'maps onto Human Review', () {
      final context = runtime.buildContext(
        userQuestion: 'Bietet ihr auch Katzensitting an?',
        workspace: buildWorkspace(),
        now: now,
      );

      expect(context.topEntries, isEmpty);
      expect(context.confidence, lessThan(40));
      expect(context.confidenceLevel, KnowledgeConfidenceLevel.low);
      expect(context.hasGap, isTrue);

      final gap = context.gap!;
      expect(gap.companyId, 'test-co');
      expect(
        gap.reason,
        'Für diese Frage existiert noch kein freigegebenes Wissen.',
      );
      expect(gap.missingTerms, contains('katzensitting'));

      final log = gap.toBotQuestionLog();
      expect(log.question, 'Bietet ihr auch Katzensitting an?');
      expect(log.matched, isFalse);
      expect(log.reviewStatus, ReviewStatus.open);
      expect(log.reviewReason, ReviewReason.noMatch);
      expect(log.humanNote, gap.reason);
    });

    test('blocked and restricted topics cap confidence and demand human '
        'handover', () {
      final context = runtime.buildContext(
        userQuestion: 'Können Sie eine Diagnose stellen?',
        workspace: buildWorkspace(),
        now: now,
      );

      expect(context.blockedTopicHits, ['Diagnosen']);
      expect(context.requiresHumanHandover, isTrue);
      expect(context.confidence, lessThanOrEqualTo(25));
      expect(
        context.topEntries.any(
          (match) => match.entry.id == 'e-restricted' && match.restricted,
        ),
        isTrue,
      );
      expect(
        context.openQuestions.any((q) => q.contains('Diagnosen')),
        isTrue,
      );
    });

    test('title match outranks content-only match', () {
      final context = runtime.buildContext(
        userQuestion: 'Wie lange dauert die Lieferung?',
        workspace: buildWorkspace(),
        now: now,
      );

      // 'Lieferzeiten' matches via title/keywords, the price entry not at all.
      expect(context.topEntries.first.entry.id, 'e-shipping');
      expect(
        context.topEntries.map((m) => m.entry.id),
        isNot(contains('e-price')),
      );
    });

    test('keeps workspaces separated', () {
      final hbCure = MockData.companyWorkspaces.first;
      final schnurrPurr = MockData.companyWorkspaces.last;
      const question = 'Wie reinige ich den Kissenbezug?';

      final hbContext = runtime.buildContext(
        userQuestion: question,
        workspace: hbCure,
        now: now,
      );
      final spContext = runtime.buildContext(
        userQuestion: question,
        workspace: schnurrPurr,
        now: now,
      );

      expect(spContext.companyId, isNot(hbContext.companyId));
      expect(
        spContext.topEntries.first.entry.title,
        'Wie reinige ich den Kissenbezug?',
      );
      final spTop = spContext.topEntries.first.score;
      final hbTop = hbContext.topEntries.isEmpty
          ? 0
          : hbContext.topEntries.first.score;
      expect(spTop, greaterThan(hbTop));
    });

    test('is deterministic and has no side effects on the workspace', () {
      final workspace = buildWorkspace();
      final entriesBefore = workspace.knowledgeEntries;
      final logsBefore = workspace.botLogs;
      final sourcesBefore = workspace.sourceMaterials;

      final first = runtime.buildContext(
        userQuestion: 'Was kostet das Premium-Abo?',
        workspace: workspace,
        now: now,
      );
      final second = runtime.buildContext(
        userQuestion: 'Was kostet das Premium-Abo?',
        workspace: workspace,
        now: now,
      );

      expect(identical(workspace.knowledgeEntries, entriesBefore), isTrue);
      expect(identical(workspace.botLogs, logsBefore), isTrue);
      expect(identical(workspace.sourceMaterials, sourcesBefore), isTrue);
      expect(workspace.knowledgeEntries, hasLength(3));
      expect(workspace.botLogs, hasLength(2));

      expect(second.confidence, first.confidence);
      expect(
        second.topEntries.map((m) => m.entry.id),
        first.topEntries.map((m) => m.entry.id),
      );
      expect(second.reasoning, first.reasoning);
    });
  });
}
