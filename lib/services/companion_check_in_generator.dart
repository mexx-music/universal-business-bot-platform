import '../models/action_record.dart';
import '../models/bot_question_log.dart';
import '../models/companion_check_in.dart';
import '../models/company_workspace.dart';
import '../recommendations/next_best_action.dart';
import '../recommendations/next_best_action_engine.dart';

/// Builds a check-in proposal from the workspace state — pure business
/// logic, no mutations, deterministic for a given workspace and period.
///
/// Honest impact language throughout: the generator reports what the user
/// *said* about an action ("ein positiver Effekt wurde gemeldet"), never
/// what the action *caused*. [CompanionCheckIn.dataConfidence] makes the
/// data basis visible; causality claims would require real measurement
/// data the platform does not have yet.
class CompanionCheckInGenerator {
  const CompanionCheckInGenerator({
    this.engine = const NextBestActionEngine(),
    this.nextStepCount = 3,
  });

  final NextBestActionEngine engine;

  /// "Das sind die nächsten drei Schritte."
  final int nextStepCount;

  CompanionCheckIn generate({
    required CompanyWorkspace workspace,
    required DateTime periodStart,
    required DateTime periodEnd,
    NextBestActionPlan? plan,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final actionPlan = plan ?? engine.recommendPlan(workspace, now: timestamp);
    final records = workspace.actionRecords;

    bool inPeriod(DateTime? date) =>
        date != null && !date.isBefore(periodStart) && !date.isAfter(periodEnd);

    final completedInPeriod = [
      for (final record in records)
        if (record.status == ActionRecordStatus.completed &&
            inPeriod(record.completedAt))
          record,
    ];
    final openRecords = [
      for (final record in records)
        if (record.isOpen) record,
    ];
    final ratedInPeriod = [
      for (final record in completedInPeriod)
        if (!record.awaitsRating) record,
    ];
    final awaitingRating = [
      for (final record in records)
        if (record.awaitsRating) record,
    ];

    final positiveOutcomes = <String>[];
    final negativeOutcomes = <String>[];
    for (final record in ratedInPeriod) {
      final outcome = record.actualOutcome == null
          ? ''
          : ' Gemeldete Beobachtung: „${record.actualOutcome}". Es ist noch '
                'nicht sicher, ob die Veränderung durch diese Maßnahme '
                'verursacht wurde.';
      switch (record.resultRating!) {
        case ActionResultRating.helpedALot:
        case ActionResultRating.helpedSomewhat:
          positiveOutcomes.add(
            '„${record.titleSnapshot}": Nach dieser Maßnahme wurde ein '
            'positiver Effekt gemeldet.$outcome',
          );
        case ActionResultRating.noEffect:
          negativeOutcomes.add(
            '„${record.titleSnapshot}": Es wurde kein erkennbarer Effekt '
            'gemeldet.',
          );
        case ActionResultRating.negative:
          negativeOutcomes.add(
            '„${record.titleSnapshot}": Es wurde ein negativer Effekt '
            'gemeldet.$outcome',
          );
        case ActionResultRating.notYetRatable:
          break;
      }
    }

    final lessonsLearned = <String>[
      for (final record in ratedInPeriod)
        if (record.resultNote != null)
          '„${record.titleSnapshot}": ${record.resultNote}',
      for (final record in records)
        if (record.status == ActionRecordStatus.declined &&
            inPeriod(record.declinedAt) &&
            record.declineReason != null)
          'Bewusst nicht umgesetzt: „${record.titleSnapshot}" '
              '(${record.declineReason}).',
      if (awaitingRating.isNotEmpty)
        'Für eine bessere Bewertung fehlen noch Rückmeldungen zu '
            '${awaitingRating.length} abgeschlossenen Maßnahme(n).',
    ];

    final newKnowledge = workspace.knowledgeEntries
        .where((entry) => inPeriod(entry.createdAt))
        .length;
    final newSources = workspace.sourceMaterials
        .where((source) => inPeriod(source.createdAt))
        .length;
    final newBotQuestions = workspace.botLogs
        .where((log) => inPeriod(log.timestamp))
        .length;

    final dataConfidence = _confidence(
      ratedCount: ratedInPeriod.length,
      completedCount: completedInPeriod.length,
      awaitingCount: awaitingRating.length,
    );

    final openCriticalReviews = workspace.botLogs
        .where(
          (log) =>
              log.reviewStatus == ReviewStatus.open &&
              log.reviewReason == ReviewReason.redFlag,
        )
        .length;
    final contradictory =
        positiveOutcomes.isNotEmpty && negativeOutcomes.isNotEmpty;
    final needsHumanReview =
        dataConfidence == CheckInDataConfidence.low ||
        contradictory ||
        openCriticalReviews > 0 ||
        awaitingRating.length >= 2;

    final summary = [
      'Zeitraum ${_date(periodStart)} bis ${_date(periodEnd)}: '
          '${completedInPeriod.length} Maßnahme(n) abgeschlossen, '
          '${openRecords.length} in Arbeit, '
          '${awaitingRating.length} Bewertung(en) offen.',
      if (newKnowledge > 0) '$newKnowledge neue Wissenseinträge.',
      if (newSources > 0) '$newSources neue Quelle(n).',
      if (newBotQuestions > 0) '$newBotQuestions neue Bot-Anfrage(n).',
      if (completedInPeriod.isEmpty &&
          newKnowledge == 0 &&
          newSources == 0 &&
          newBotQuestions == 0)
        'In diesem Zeitraum wurden keine Veränderungen erfasst.',
    ].join(' ');

    return CompanionCheckIn(
      id: 'ci_${timestamp.microsecondsSinceEpoch}',
      workspaceId: workspace.company.id,
      periodStart: periodStart,
      periodEnd: periodEnd,
      createdAt: timestamp,
      status: CheckInStatus.draft,
      summary: summary,
      completedActionIds: [for (final r in completedInPeriod) r.id],
      openActionIds: [for (final r in openRecords) r.id],
      ratedActionIds: [for (final r in ratedInPeriod) r.id],
      awaitingRatingActionIds: [for (final r in awaitingRating) r.id],
      positiveOutcomes: positiveOutcomes,
      negativeOutcomes: negativeOutcomes,
      lessonsLearned: lessonsLearned,
      nextActionIds: [
        for (final action in actionPlan.actions.take(nextStepCount)) action.id,
      ],
      dataConfidence: dataConfidence,
      needsHumanReview: needsHumanReview,
    );
  }

  /// high: at least two rated actions and nothing awaiting rating;
  /// medium: at least one rated action; low: no ratings in the period.
  CheckInDataConfidence _confidence({
    required int ratedCount,
    required int completedCount,
    required int awaitingCount,
  }) {
    if (ratedCount >= 2 && awaitingCount == 0) {
      return CheckInDataConfidence.high;
    }
    if (ratedCount >= 1) return CheckInDataConfidence.medium;
    return CheckInDataConfidence.low;
  }

  String _date(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
