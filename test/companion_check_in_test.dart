import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/screens/check_in/check_in_screen.dart';
import 'package:universalbusiness/models/action_record.dart';
import 'package:universalbusiness/models/bot_configuration.dart';
import 'package:universalbusiness/models/business_rules.dart';
import 'package:universalbusiness/models/companion_check_in.dart';
import 'package:universalbusiness/models/company.dart';
import 'package:universalbusiness/models/company_workspace.dart';
import 'package:universalbusiness/recommendations/next_best_action_engine.dart';
import 'package:universalbusiness/services/check_in_service.dart';
import 'package:universalbusiness/services/companion_check_in_generator.dart';

void main() {
  final now = DateTime(2026, 7, 16);
  final periodStart = DateTime(2026, 6, 16);
  const generator = CompanionCheckInGenerator();
  const service = CheckInService();
  const engine = NextBestActionEngine();

  CompanyWorkspace buildWorkspace({List<ActionRecord> records = const []}) {
    return CompanyWorkspace(
      company: const Company(
        id: 'checkin-co',
        name: 'CheckIn GmbH',
        industry: '',
        description: '',
        website: '',
        email: '',
        address: '',
      ),
      products: const [],
      knowledgeEntries: const [],
      botLogs: const [],
      auditItems: const [],
      businessRules: const BusinessRules(
        brandVoice: '',
        doNotSay: [],
        allowedSupportTopics: [],
        escalationNotes: '',
      ),
      botConfiguration: const BotConfiguration(
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
      sourceMaterials: const [],
      actionRecords: records,
    );
  }

  ActionRecord record(
    String id, {
    required ActionRecordStatus status,
    DateTime? completedAt,
    ActionResultRating? rating,
    String? actualOutcome,
    String? resultNote,
  }) {
    return ActionRecord(
      id: id,
      actionType: 'expandFaq',
      titleSnapshot: 'Maßnahme $id',
      descriptionSnapshot: 'Beschreibung',
      status: status,
      createdAt: DateTime(2026, 6, 20),
      completedAt: completedAt,
      resultRating: rating,
      resultNote: resultNote,
      actualOutcome: actualOutcome,
      expectedImpact: 'high',
    );
  }

  group('CompanionCheckInGenerator', () {
    test('first check-in without history is honest about the empty period', () {
      final workspace = buildWorkspace();
      final checkIn = generator.generate(
        workspace: workspace,
        periodStart: periodStart,
        periodEnd: now,
        now: now,
      );

      expect(checkIn.workspaceId, 'checkin-co');
      expect(checkIn.status, CheckInStatus.draft);
      expect(checkIn.completedActionIds, isEmpty);
      expect(checkIn.summary, contains('keine Veränderungen'));
      expect(checkIn.dataConfidence, CheckInDataConfidence.low);
      expect(checkIn.needsHumanReview, isTrue);
      // Next steps come from the engine plan.
      final planIds = engine
          .recommendPlan(workspace, now: now)
          .actions
          .take(3)
          .map((a) => a.id)
          .toList();
      expect(checkIn.nextActionIds, planIds);
    });

    test('collects completed, open and awaiting actions for the period', () {
      final workspace = buildWorkspace(
        records: [
          record(
            'r1',
            status: ActionRecordStatus.completed,
            completedAt: DateTime(2026, 7, 1),
            rating: ActionResultRating.helpedALot,
            actualOutcome: 'Mehr Anfragen über die Website',
          ),
          record(
            'r2',
            status: ActionRecordStatus.completed,
            completedAt: DateTime(2026, 7, 5),
            rating: ActionResultRating.noEffect,
          ),
          record(
            'r3',
            status: ActionRecordStatus.completed,
            completedAt: DateTime(2026, 5, 1),
            rating: ActionResultRating.helpedSomewhat,
          ),
          record('r4', status: ActionRecordStatus.inProgress),
          record(
            'r5',
            status: ActionRecordStatus.completed,
            completedAt: DateTime(2026, 7, 10),
            rating: ActionResultRating.notYetRatable,
          ),
        ],
      );

      final checkIn = generator.generate(
        workspace: workspace,
        periodStart: periodStart,
        periodEnd: now,
        now: now,
      );

      expect(checkIn.completedActionIds, ['r1', 'r2', 'r5']);
      expect(checkIn.openActionIds, ['r4']);
      expect(checkIn.ratedActionIds, ['r1', 'r2']);
      expect(checkIn.awaitingRatingActionIds, ['r5']);
    });

    test('separates positive and negative outcomes with honest, '
        'non-causal language', () {
      final workspace = buildWorkspace(
        records: [
          record(
            'r1',
            status: ActionRecordStatus.completed,
            completedAt: DateTime(2026, 7, 1),
            rating: ActionResultRating.helpedALot,
            actualOutcome: 'Mehr Anfragen',
          ),
          record(
            'r2',
            status: ActionRecordStatus.completed,
            completedAt: DateTime(2026, 7, 5),
            rating: ActionResultRating.noEffect,
          ),
        ],
      );

      final checkIn = generator.generate(
        workspace: workspace,
        periodStart: periodStart,
        periodEnd: now,
        now: now,
      );

      expect(checkIn.positiveOutcomes, hasLength(1));
      expect(
        checkIn.positiveOutcomes.single,
        allOf(
          contains('positiver Effekt gemeldet'),
          contains('noch nicht sicher'),
        ),
      );
      expect(checkIn.negativeOutcomes, hasLength(1));
      expect(
        checkIn.negativeOutcomes.single,
        contains('kein erkennbarer Effekt'),
      );
      // No causal percentage claims anywhere.
      for (final sentence in [
        ...checkIn.positiveOutcomes,
        ...checkIn.negativeOutcomes,
      ]) {
        expect(sentence, isNot(contains('erhöht')));
      }
    });

    test('confidence levels and human review triggers', () {
      // Two ratings, nothing awaiting, consistent → high, no review needed.
      final consistent = buildWorkspace(
        records: [
          record(
            'r1',
            status: ActionRecordStatus.completed,
            completedAt: DateTime(2026, 7, 1),
            rating: ActionResultRating.helpedALot,
          ),
          record(
            'r2',
            status: ActionRecordStatus.completed,
            completedAt: DateTime(2026, 7, 5),
            rating: ActionResultRating.helpedSomewhat,
          ),
        ],
      );
      final high = generator.generate(
        workspace: consistent,
        periodStart: periodStart,
        periodEnd: now,
        now: now,
      );
      expect(high.dataConfidence, CheckInDataConfidence.high);
      expect(high.needsHumanReview, isFalse);

      // Contradictory results → human review even with ratings.
      final contradictory = buildWorkspace(
        records: [
          record(
            'r1',
            status: ActionRecordStatus.completed,
            completedAt: DateTime(2026, 7, 1),
            rating: ActionResultRating.helpedALot,
          ),
          record(
            'r2',
            status: ActionRecordStatus.completed,
            completedAt: DateTime(2026, 7, 5),
            rating: ActionResultRating.negative,
          ),
        ],
      );
      final mixed = generator.generate(
        workspace: contradictory,
        periodStart: periodStart,
        periodEnd: now,
        now: now,
      );
      expect(mixed.needsHumanReview, isTrue);

      // No ratings at all → low confidence → human review.
      final empty = generator.generate(
        workspace: buildWorkspace(),
        periodStart: periodStart,
        periodEnd: now,
        now: now,
      );
      expect(empty.dataConfidence, CheckInDataConfidence.low);
      expect(empty.needsHumanReview, isTrue);
    });

    test('is deterministic and has no side effects', () {
      final workspace = buildWorkspace(
        records: [
          record(
            'r1',
            status: ActionRecordStatus.completed,
            completedAt: DateTime(2026, 7, 1),
            rating: ActionResultRating.helpedALot,
          ),
        ],
      );
      final recordsBefore = workspace.actionRecords;
      final checkInsBefore = workspace.checkIns;

      final first = generator.generate(
        workspace: workspace,
        periodStart: periodStart,
        periodEnd: now,
        now: now,
      );
      final second = generator.generate(
        workspace: workspace,
        periodStart: periodStart,
        periodEnd: now,
        now: now,
      );

      expect(identical(workspace.actionRecords, recordsBefore), isTrue);
      expect(identical(workspace.checkIns, checkInsBefore), isTrue);
      expect(second.summary, first.summary);
      expect(second.positiveOutcomes, first.positiveOutcomes);
      expect(second.nextActionIds, first.nextActionIds);
      expect(second.dataConfidence, first.dataConfidence);
      expect(second.needsHumanReview, first.needsHumanReview);
    });
  });

  group('CheckInService', () {
    test('startCheckIn opens one active check-in; a second start is a '
        'no-op', () {
      final workspace = buildWorkspace();
      final started = service.startCheckIn(workspace, now: now);

      expect(started.checkIns, hasLength(1));
      expect(started.checkIns.single.status, CheckInStatus.inProgress);
      expect(
        started.checkIns.single.periodStart,
        now.subtract(const Duration(days: 30)),
      );

      final again = service.startCheckIn(started, now: now);
      expect(identical(again, started), isTrue);
    });

    test('completing freezes the check-in with notes and confirmed steps; '
        'later mutations are ignored', () {
      var workspace = service.startCheckIn(buildWorkspace(), now: now);
      final id = workspace.checkIns.single.id;

      workspace = service.completeCheckIn(
        workspace,
        id,
        userNotes: 'Guter Monat trotz Urlaub.',
        confirmedNextActionIds: const ['expandFaq'],
        now: now,
      );
      final completed = workspace.checkIns.single;
      expect(completed.status, CheckInStatus.completed);
      expect(completed.completedAt, now);
      expect(completed.userNotes, 'Guter Monat trotz Urlaub.');
      expect(completed.nextActionIds, ['expandFaq']);

      // Immutable from now on.
      final afterNotes = service.updateUserNotes(
        workspace,
        id,
        'Nachträglich geändert',
      );
      expect(identical(afterNotes, workspace), isTrue);
      final afterComplete = service.completeCheckIn(
        workspace,
        id,
        userNotes: 'Noch einmal',
        now: now.add(const Duration(days: 1)),
      );
      expect(identical(afterComplete, workspace), isTrue);
      final afterSkip = service.skipCheckIn(workspace, id, now: now);
      expect(identical(afterSkip, workspace), isTrue);
    });

    test('next check-in period starts where the last one ended', () {
      var workspace = service.startCheckIn(buildWorkspace(), now: now);
      workspace = service.completeCheckIn(
        workspace,
        workspace.checkIns.single.id,
        now: now,
      );

      expect(
        service.nextRecommendedCheckIn(workspace),
        now.add(const Duration(days: 30)),
      );

      final later = now.add(const Duration(days: 35));
      workspace = service.startCheckIn(workspace, now: later);
      final second = workspace.checkIns.last;
      expect(second.periodStart, now);
      expect(second.periodEnd, later);
    });

    test('cadence is configurable (weekly service)', () {
      const weekly = CheckInService(interval: Duration(days: 7));
      final workspace = weekly.startCheckIn(buildWorkspace(), now: now);
      expect(
        workspace.checkIns.single.periodStart,
        now.subtract(const Duration(days: 7)),
      );
    });
  });

  group('AppState integration', () {
    test('check-ins affect only the selected workspace', () {
      final state = AppState();
      final otherId = state.companies.last.company.id;

      state.startCheckIn();
      expect(state.checkIns, hasLength(1));
      expect(state.activeCheckIn, isNotNull);

      final other = state.companies.firstWhere((w) => w.company.id == otherId);
      expect(other.checkIns, isEmpty);

      state.completeCheckIn(
        state.activeCheckIn!.id,
        userNotes: 'Erster Check-in',
      );
      expect(state.activeCheckIn, isNull);
      expect(state.lastCompletedCheckIn, isNotNull);
      expect(state.lastCompletedCheckIn!.userNotes, 'Erster Check-in');
    });
  });

  group('CheckInScreen', () {
    testWidgets('start opens the guided flow, skip returns to the overview', (
      tester,
    ) async {
      final state = AppState();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: AppStateScope(notifier: state, child: const CheckInScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Monats-Check-in'), findsOneWidget);
      await tester.tap(find.text('Check-in starten'));
      await tester.pumpAndSettle();

      expect(state.activeCheckIn, isNotNull);
      expect(find.text('Seit dem letzten Check-in'), findsOneWidget);
      expect(find.text('Die nächsten drei Schritte'), findsOneWidget);

      await tester.tap(find.text('Check-in überspringen'));
      await tester.pumpAndSettle();

      expect(state.activeCheckIn, isNull);
      expect(state.checkIns.single.status, CheckInStatus.skipped);
      expect(find.text('Check-in starten'), findsOneWidget);
    });
  });
}
