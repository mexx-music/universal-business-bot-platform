import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/mock_data.dart';
import 'package:universalbusiness/models/bot_configuration.dart';
import 'package:universalbusiness/models/bot_question_log.dart';
import 'package:universalbusiness/models/business_audit.dart';
import 'package:universalbusiness/models/business_rules.dart';
import 'package:universalbusiness/models/company.dart';
import 'package:universalbusiness/models/company_workspace.dart';
import 'package:universalbusiness/models/intake_session.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';
import 'package:universalbusiness/recommendations/next_best_action.dart';
import 'package:universalbusiness/recommendations/next_best_action_engine.dart';

void main() {
  final now = DateTime(2026, 7, 16);
  const engine = NextBestActionEngine();

  CompanyWorkspace buildEmptyishWorkspace() {
    return const CompanyWorkspace(
      company: Company(
        id: 'young-co',
        name: 'Junge Firma',
        industry: '',
        description: '',
        website: '',
        email: '',
        address: '',
      ),
      products: [],
      knowledgeEntries: [],
      botLogs: [],
      auditItems: [],
      businessRules: BusinessRules(
        brandVoice: '',
        doNotSay: [],
        allowedSupportTopics: [],
        escalationNotes: '',
      ),
      botConfiguration: BotConfiguration(
        status: BotStatus.draft,
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
      sourceMaterials: [],
    );
  }

  group('NextBestActionEngine', () {
    test('recommends at most five actions, sorted by score', () {
      final actions = engine.recommend(buildEmptyishWorkspace(), now: now);

      expect(actions, isNotEmpty);
      expect(actions.length, lessThanOrEqualTo(5));
      for (var i = 1; i < actions.length; i++) {
        expect(
          actions[i - 1].score,
          greaterThanOrEqualTo(actions[i].score),
        );
      }
    });

    test('young workspace is told to start with intake and foundations', () {
      final actions = engine.recommend(buildEmptyishWorkspace(), now: now);
      final types = actions.map((a) => a.type).toList();

      expect(types, contains(NextBestActionType.completeIntake));
      expect(types, contains(NextBestActionType.completeCompanyProfile));
      expect(types, contains(NextBestActionType.expandFaq));
      // A brand-new company without knowledge must not be told to
      // activate the bot or work off reviews.
      expect(types, isNot(contains(NextBestActionType.activateBot)));
      expect(types, isNot(contains(NextBestActionType.workOffHumanReview)));
    });

    test('open red-flag reviews outrank everything else', () {
      final workspace = buildEmptyishWorkspace().copyWith(
        botLogs: [
          for (var i = 0; i < 3; i++)
            BotQuestionLog(
              id: 'open-$i',
              question: 'Heikle Frage $i',
              matched: false,
              timestamp: DateTime(2026, 7, 1),
              reviewStatus: ReviewStatus.open,
              reviewReason: i == 0
                  ? ReviewReason.redFlag
                  : ReviewReason.noMatch,
            ),
        ],
      );

      final actions = engine.recommend(workspace, now: now);
      final review = actions.first;

      expect(review.type, NextBestActionType.workOffHumanReview);
      expect(review.priority, ActionPriority.critical);
      expect(
        review.reasons.any((r) => r.evidence.contains('reviewStatus=open')),
        isTrue,
      );
      expect(
        review.reasons.any((r) => r.evidence.contains('redFlag')),
        isTrue,
      );
    });

    test('mature workspace gets bot activation instead of basics', () {
      final mature = buildEmptyishWorkspace().copyWith(
        company: const Company(
          id: 'mature-co',
          name: 'Reife Firma',
          industry: 'Handel',
          description: 'Etabliert',
          country: 'AT',
          website: 'https://example.com',
          email: 'office@example.com',
          address: 'Hauptplatz 1',
          socialLinks: {'instagram': 'https://instagram.com/reif'},
        ),
        businessRules: const BusinessRules(
          brandVoice: 'freundlich',
          doNotSay: [],
          allowedSupportTopics: ['Preise'],
          escalationNotes: '',
        ),
        knowledgeEntries: [
          for (var i = 0; i < 12; i++)
            KnowledgeEntry(
              id: 'k$i',
              title: 'FAQ $i',
              content: 'Antwort $i',
              category: KnowledgeCategory.faq,
              riskLevel: RiskLevel.green,
              keywords: const ['faq'],
              source: 'Test',
              createdAt: DateTime(2026, 6, 1),
            ),
        ],
        auditItems: [
          for (var i = 0; i < 5; i++)
            BusinessAuditItem(
              id: 'a$i',
              area: AuditArea.companyProfile,
              title: 'Punkt $i',
              description: '',
              status: AuditItemStatus.complete,
              priority: AuditPriority.high,
            ),
        ],
        intakeSession: IntakeSession(
          id: 'intake-1',
          companyId: 'mature-co',
          status: IntakeStatus.completed,
          currentStepIndex: 7,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 2),
        ),
      );

      final actions = engine.recommend(mature, now: now);
      final types = actions.map((a) => a.type).toList();

      expect(types, contains(NextBestActionType.activateBot));
      expect(types, isNot(contains(NextBestActionType.completeIntake)));
      expect(types, isNot(contains(NextBestActionType.expandFaq)));
      expect(
        types,
        isNot(contains(NextBestActionType.completeCompanyProfile)),
      );
    });

    test('every recommendation is explainable — reasons with evidence', () {
      for (final workspace in [
        buildEmptyishWorkspace(),
        ...MockData.companyWorkspaces,
      ]) {
        for (final action in engine.recommend(workspace, now: now)) {
          expect(action.reasons, isNotEmpty,
              reason: '${action.type} must carry reasons');
          for (final reason in action.reasons) {
            expect(reason.message, isNotEmpty);
            expect(reason.evidence, isNotEmpty);
          }
          expect(action.areas, isNotEmpty);
          expect(action.status, NextBestActionStatus.proposed);
        }
      }
    });

    test('keeps workspaces separated', () {
      final hbActions = engine.recommend(
        MockData.companyWorkspaces.first,
        now: now,
      );
      final spActions = engine.recommend(
        MockData.companyWorkspaces.last,
        now: now,
      );

      expect(hbActions, isNotEmpty);
      expect(spActions, isNotEmpty);
      // Different data must lead to different recommendations or at least
      // different evidence.
      final hbSummary = [
        for (final action in hbActions)
          '${action.type.name}:'
              '${action.reasons.map((r) => r.evidence).join('|')}',
      ].join(';');
      final spSummary = [
        for (final action in spActions)
          '${action.type.name}:'
              '${action.reasons.map((r) => r.evidence).join('|')}',
      ].join(';');
      expect(hbSummary, isNot(spSummary));
    });

    test('is deterministic and has no side effects', () {
      final workspace = MockData.companyWorkspaces.first;
      final entriesBefore = workspace.knowledgeEntries;
      final auditBefore = workspace.auditItems;
      final logsBefore = workspace.botLogs;

      final first = engine.recommend(workspace, now: now);
      final second = engine.recommend(workspace, now: now);

      expect(identical(workspace.knowledgeEntries, entriesBefore), isTrue);
      expect(identical(workspace.auditItems, auditBefore), isTrue);
      expect(identical(workspace.botLogs, logsBefore), isTrue);

      expect(second.map((a) => a.type), first.map((a) => a.type));
      expect(second.map((a) => a.score), first.map((a) => a.score));
      expect(
        second.map((a) => a.reasons.map((r) => r.evidence).join('|')),
        first.map((a) => a.reasons.map((r) => r.evidence).join('|')),
      );
    });

    test('stale knowledge triggers a refresh recommendation', () {
      // Intake and profile are complete so foundation actions do not
      // crowd the knowledge recommendation out of the top five.
      final workspace = buildEmptyishWorkspace().copyWith(
        company: const Company(
          id: 'young-co',
          name: 'Junge Firma',
          industry: 'Handel',
          description: 'Etabliert',
          country: 'AT',
          website: 'https://example.com',
          email: 'office@example.com',
          address: 'Hauptplatz 1',
          socialLinks: {'instagram': 'https://instagram.com/x'},
        ),
        businessRules: const BusinessRules(
          brandVoice: 'freundlich',
          doNotSay: [],
          allowedSupportTopics: ['Preise'],
          escalationNotes: '',
        ),
        intakeSession: IntakeSession(
          id: 'intake-1',
          companyId: 'young-co',
          status: IntakeStatus.completed,
          currentStepIndex: 7,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 2),
        ),
        knowledgeEntries: [
          for (var i = 0; i < 13; i++)
            KnowledgeEntry(
              id: 'old-$i',
              title: 'Alt $i',
              content: 'Inhalt',
              category: KnowledgeCategory.allgemein,
              riskLevel: RiskLevel.green,
              keywords: const [],
              source: 'Archiv',
              createdAt: DateTime(2024, 1, 1),
            ),
        ],
      );

      final actions = engine.recommend(workspace, now: now);
      final refresh = actions
          .where((a) => a.type == NextBestActionType.addKnowledge)
          .toList();

      expect(refresh, hasLength(1));
      expect(
        refresh.first.reasons.any((r) => r.message.contains('älter als')),
        isTrue,
      );
    });
  });
}
