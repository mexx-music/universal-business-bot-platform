import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/screens/next_actions/next_actions_screen.dart';
import 'package:universalbusiness/models/action_record.dart';
import 'package:universalbusiness/models/bot_configuration.dart';
import 'package:universalbusiness/models/business_rules.dart';
import 'package:universalbusiness/models/company.dart';
import 'package:universalbusiness/models/company_workspace.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';
import 'package:universalbusiness/recommendations/next_best_action.dart';
import 'package:universalbusiness/recommendations/next_best_action_engine.dart';
import 'package:universalbusiness/services/action_lifecycle_service.dart';

void main() {
  final now = DateTime(2026, 7, 16);
  const engine = NextBestActionEngine();
  const service = ActionLifecycleService();

  CompanyWorkspace buildWorkspace() {
    return const CompanyWorkspace(
      company: Company(
        id: 'lifecycle-co',
        name: 'Lifecycle GmbH',
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

  NextBestAction actionOf(CompanyWorkspace workspace, NextBestActionType type) {
    return engine
        .recommendPlan(workspace, now: now)
        .actions
        .firstWhere((action) => action.type == type);
  }

  group('ActionLifecycleService', () {
    test('accepting creates a record with snapshots and evidence', () {
      final workspace = buildWorkspace();
      final action = actionOf(workspace, NextBestActionType.completeIntake);

      final updated = service.acceptAction(workspace, action, now: now);

      expect(updated.actionRecords, hasLength(1));
      final record = updated.actionRecords.single;
      expect(record.status, ActionRecordStatus.accepted);
      expect(record.acceptedAt, now);
      expect(record.actionType, 'completeIntake');
      expect(record.titleSnapshot, action.title);
      expect(record.descriptionSnapshot, action.description);
      expect(record.expectedImpact, action.impact.name);
      expect(
        record.sourceReasonKeys,
        action.reasons.map((r) => r.evidence).toList(),
      );
      // Input workspace untouched.
      expect(workspace.actionRecords, isEmpty);
    });

    test('starting continues the accepted record instead of duplicating', () {
      final workspace = buildWorkspace();
      final action = actionOf(workspace, NextBestActionType.completeIntake);

      var updated = service.acceptAction(workspace, action, now: now);
      final acceptedId = updated.actionRecords.single.id;
      updated = service.startAction(updated, action, now: now);

      expect(updated.actionRecords, hasLength(1));
      final record = updated.actionRecords.single;
      expect(record.id, acceptedId);
      expect(record.status, ActionRecordStatus.inProgress);
      expect(record.startedAt, now);
    });

    test('deferring stores the date, declining stores the reason', () {
      final workspace = buildWorkspace();
      final action = actionOf(workspace, NextBestActionType.expandFaq);
      final until = now.add(const Duration(days: 30));

      final deferred = service.deferAction(
        workspace,
        action,
        until: until,
        now: now,
      );
      expect(deferred.actionRecords.single.status, ActionRecordStatus.deferred);
      expect(deferred.actionRecords.single.deferredUntil, until);

      final declined = service.declineAction(
        workspace,
        action,
        reason: 'Machen wir bewusst nicht',
        now: now,
      );
      expect(declined.actionRecords.single.status, ActionRecordStatus.declined);
      expect(declined.actionRecords.single.declinedAt, now);
      expect(
        declined.actionRecords.single.declineReason,
        'Machen wir bewusst nicht',
      );
    });

    test('completing captures the result; rating can happen later', () {
      final workspace = buildWorkspace();
      final action = actionOf(workspace, NextBestActionType.expandFaq);

      var updated = service.completeAction(
        workspace,
        action,
        rating: ActionResultRating.notYetRatable,
        now: now,
      );
      final record = updated.actionRecords.single;
      expect(record.status, ActionRecordStatus.completed);
      expect(record.completedAt, now);
      expect(record.awaitsRating, isTrue);

      updated = service.rateRecord(
        updated,
        record.id,
        rating: ActionResultRating.helpedALot,
        resultNote: 'FAQ von 0 auf 10 Einträge ausgebaut',
        actualOutcome: 'Bot-Trefferquote gestiegen',
        repeatRequested: true,
      );
      final rated = updated.actionRecords.single;
      expect(rated.resultRating, ActionResultRating.helpedALot);
      expect(rated.resultNote, 'FAQ von 0 auf 10 Einträge ausgebaut');
      expect(rated.actualOutcome, 'Bot-Trefferquote gestiegen');
      expect(rated.repeatRequested, isTrue);
      expect(rated.awaitsRating, isFalse);
    });
  });

  group('Engine + history', () {
    test('accepted and in-progress actions are suppressed, explained, and '
        'not duplicated', () {
      final workspace = buildWorkspace();
      final action = actionOf(workspace, NextBestActionType.completeIntake);

      var updated = service.acceptAction(workspace, action, now: now);
      var plan = engine.recommendPlan(updated, now: now);
      expect(
        plan.actions.map((a) => a.type),
        isNot(contains(NextBestActionType.completeIntake)),
      );
      final suppression = plan.suppressed.singleWhere(
        (s) => s.type == NextBestActionType.completeIntake,
      );
      expect(suppression.reason, contains('angenommen'));
      expect(suppression.evidence, contains('status=accepted'));

      updated = service.startAction(updated, action, now: now);
      plan = engine.recommendPlan(updated, now: now);
      expect(
        plan.actions.map((a) => a.type),
        isNot(contains(NextBestActionType.completeIntake)),
      );
      expect(
        plan.suppressed
            .where((s) => s.type == NextBestActionType.completeIntake)
            .single
            .reason,
        contains('Läuft bereits'),
      );
    });

    test('deferred actions return after deferredUntil with explanation', () {
      final workspace = buildWorkspace();
      final action = actionOf(workspace, NextBestActionType.expandFaq);
      final until = now.add(const Duration(days: 30));
      final updated = service.deferAction(
        workspace,
        action,
        until: until,
        now: now,
      );

      final before = engine.recommendPlan(updated, now: now);
      expect(
        before.actions.map((a) => a.type),
        isNot(contains(NextBestActionType.expandFaq)),
      );
      expect(
        before.suppressed
            .singleWhere((s) => s.type == NextBestActionType.expandFaq)
            .reason,
        contains('Zurückgestellt'),
      );

      final after = engine.recommendPlan(
        updated,
        now: until.add(const Duration(days: 1)),
      );
      final again = after.actions.firstWhere(
        (a) => a.type == NextBestActionType.expandFaq,
      );
      expect(
        again.reasons.any((r) => r.message.contains('abgelaufen')),
        isTrue,
      );
    });

    test('declined actions stay suppressed until the data changes '
        'materially', () {
      final workspace = buildWorkspace();
      final action = actionOf(workspace, NextBestActionType.expandFaq);
      final declined = service.declineAction(
        workspace,
        action,
        reason: 'Kein Bedarf',
        now: now,
      );

      final unchanged = engine.recommendPlan(declined, now: now);
      expect(
        unchanged.actions.map((a) => a.type),
        isNot(contains(NextBestActionType.expandFaq)),
      );
      expect(
        unchanged.suppressed
            .singleWhere((s) => s.type == NextBestActionType.expandFaq)
            .reason,
        allOf(contains('abgelehnt'), contains('Kein Bedarf')),
      );

      // Materially changed data: FAQ count moves from 0 to 2.
      final changed = declined.copyWith(
        knowledgeEntries: [
          for (var i = 0; i < 2; i++)
            KnowledgeEntry(
              id: 'faq-$i',
              title: 'FAQ $i',
              content: 'Antwort',
              category: KnowledgeCategory.faq,
              riskLevel: RiskLevel.green,
              keywords: const [],
              source: 'Test',
              createdAt: DateTime(2026, 7, 1),
            ),
        ],
      );
      final replan = engine.recommendPlan(changed, now: now);
      final again = replan.actions.firstWhere(
        (a) => a.type == NextBestActionType.expandFaq,
      );
      expect(
        again.reasons.any(
          (r) => r.message.contains('Datenlage hat sich seitdem wesentlich'),
        ),
        isTrue,
      );
    });

    test('completed actions rest during cooldown; successful ones may '
        'repeat later, unsuccessful ones need new data', () {
      final workspace = buildWorkspace();
      final action = actionOf(workspace, NextBestActionType.expandFaq);

      final successful = service.completeAction(
        workspace,
        action,
        rating: ActionResultRating.helpedSomewhat,
        now: now,
      );
      final inCooldown = engine.recommendPlan(
        successful,
        now: now.add(const Duration(days: 10)),
      );
      expect(
        inCooldown.suppressed
            .singleWhere((s) => s.type == NextBestActionType.expandFaq)
            .reason,
        contains('abgeschlossen'),
      );

      final afterCooldown = engine.recommendPlan(
        successful,
        now: now.add(const Duration(days: 120)),
      );
      final repeat = afterCooldown.actions.firstWhere(
        (a) => a.type == NextBestActionType.expandFaq,
      );
      expect(
        repeat.reasons.any((r) => r.message.contains('Wiederholung')),
        isTrue,
      );

      final unsuccessful = service.completeAction(
        workspace,
        action,
        rating: ActionResultRating.noEffect,
        now: now,
      );
      final stillSuppressed = engine.recommendPlan(
        unsuccessful,
        now: now.add(const Duration(days: 120)),
      );
      expect(
        stillSuppressed.suppressed
            .singleWhere((s) => s.type == NextBestActionType.expandFaq)
            .reason,
        contains('ohne erkennbaren Erfolg'),
      );
    });

    test('engine stays deterministic and does not mutate the workspace', () {
      final workspace = service.acceptAction(
        buildWorkspace(),
        actionOf(buildWorkspace(), NextBestActionType.completeIntake),
        now: now,
      );
      final recordsBefore = workspace.actionRecords;

      final first = engine.recommendPlan(workspace, now: now);
      final second = engine.recommendPlan(workspace, now: now);

      expect(identical(workspace.actionRecords, recordsBefore), isTrue);
      expect(recordsBefore.single.status, ActionRecordStatus.accepted);
      expect(
        second.actions.map((a) => a.type),
        first.actions.map((a) => a.type),
      );
      expect(
        second.suppressed.map((s) => '${s.type}:${s.reason}'),
        first.suppressed.map((s) => '${s.type}:${s.reason}'),
      );
    });
  });

  group('AppState integration', () {
    test('decisions affect only the selected workspace', () {
      final state = AppState();
      final otherId = state.companies.last.company.id;
      expect(state.selectedCompanyId, isNot(otherId));

      final action = state.nextBestActions.first;
      state.acceptNextAction(action);

      expect(state.actionRecords, hasLength(1));
      expect(state.actionRecords.single.status, ActionRecordStatus.accepted);
      final other = state.companies.firstWhere((w) => w.company.id == otherId);
      expect(other.actionRecords, isEmpty);
    });

    test('complete and rate flow via AppState', () {
      final state = AppState();
      final action = state.nextBestActions.first;

      state.startNextAction(action);
      expect(state.inProgressActionRecords, hasLength(1));

      final recordId = state.inProgressActionRecords.single.id;
      state.completeActionRecord(
        recordId,
        rating: ActionResultRating.notYetRatable,
      );
      expect(state.inProgressActionRecords, isEmpty);
      expect(state.actionRecordsAwaitingRating, hasLength(1));

      state.rateActionRecord(
        recordId,
        rating: ActionResultRating.helpedALot,
        resultNote: 'Mehr Anfragen beantwortet',
      );
      expect(state.actionRecordsAwaitingRating, isEmpty);
      expect(
        state.actionRecords.single.resultRating,
        ActionResultRating.helpedALot,
      );
    });
  });

  group('NextActionsScreen', () {
    testWidgets('renders cards, accepting moves the action into the history', (
      tester,
    ) async {
      final state = AppState();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: AppStateScope(
            notifier: state,
            child: const NextActionsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Meine nächsten Schritte'), findsOneWidget);
      expect(find.text('Warum jetzt?'), findsWidgets);
      // The history section sits below the fold of the lazy ListView.
      await tester.scrollUntilVisible(
        find.text('Maßnahmenhistorie'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Maßnahmenhistorie'), findsOneWidget);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 4000));
      await tester.pumpAndSettle();

      final topActionTitle = state.nextBestActions.first.title;
      await tester.tap(find.text('Annehmen').first);
      await tester.pumpAndSettle();

      expect(state.actionRecords, hasLength(1));
      expect(state.actionRecords.single.titleSnapshot, topActionTitle);
      expect(state.actionRecords.single.status, ActionRecordStatus.accepted);
      // The accepted action is no longer offered as a card.
      expect(
        state.nextBestActions.map((a) => a.title),
        isNot(contains(topActionTitle)),
      );
    });
  });
}
