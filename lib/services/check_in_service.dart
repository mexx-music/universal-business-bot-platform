import '../models/companion_check_in.dart';
import '../models/company_workspace.dart';
import 'companion_check_in_generator.dart';

/// Pure mutation logic for the check-in rhythm. AppState delegates here.
///
/// Cadence is a parameter, not a rule: the default is monthly, but weekly,
/// quarterly or manual check-ins work by passing a different [interval] /
/// starting one manually — deliberately no settings UI yet.
///
/// Completed (and skipped) check-ins are immutable: every mutation method
/// silently ignores them, so history stays trustworthy.
class CheckInService {
  const CheckInService({
    this.generator = const CompanionCheckInGenerator(),
    this.interval = const Duration(days: 30),
  });

  final CompanionCheckInGenerator generator;

  /// Default companion rhythm (monthly).
  final Duration interval;

  CompanionCheckIn? activeCheckIn(CompanyWorkspace workspace) {
    for (final checkIn in workspace.checkIns.reversed) {
      if (checkIn.isActive) return checkIn;
    }
    return null;
  }

  CompanionCheckIn? lastCompletedCheckIn(CompanyWorkspace workspace) {
    CompanionCheckIn? latest;
    for (final checkIn in workspace.checkIns) {
      if (!checkIn.isCompleted) continue;
      if (latest == null || checkIn.periodEnd.isAfter(latest.periodEnd)) {
        latest = checkIn;
      }
    }
    return latest;
  }

  /// When the next check-in is due: one [interval] after the last completed
  /// one, or now for workspaces that never had one.
  DateTime nextRecommendedCheckIn(CompanyWorkspace workspace, {DateTime? now}) {
    final last = lastCompletedCheckIn(workspace);
    if (last == null) return now ?? DateTime.now();
    return last.periodEnd.add(interval);
  }

  /// Starts a check-in (or returns the workspace unchanged when one is
  /// already active). The period runs from the end of the last completed
  /// check-in (or one [interval] back) until now.
  CompanyWorkspace startCheckIn(CompanyWorkspace workspace, {DateTime? now}) {
    if (activeCheckIn(workspace) != null) return workspace;
    final timestamp = now ?? DateTime.now();
    final last = lastCompletedCheckIn(workspace);
    final periodStart = last?.periodEnd ?? timestamp.subtract(interval);
    final draft = generator
        .generate(
          workspace: workspace,
          periodStart: periodStart,
          periodEnd: timestamp,
          now: timestamp,
        )
        .copyWith(status: CheckInStatus.inProgress);
    return workspace.copyWith(checkIns: [...workspace.checkIns, draft]);
  }

  /// Live view of an active check-in's content: same period, current data.
  /// Used by the UI while the user catches up on ratings mid-check-in; the
  /// persisted check-in is only refreshed once, at completion.
  CompanionCheckIn preview(
    CompanyWorkspace workspace,
    CompanionCheckIn active, {
    DateTime? now,
  }) {
    return generator.generate(
      workspace: workspace,
      periodStart: active.periodStart,
      periodEnd: active.periodEnd,
      now: now,
    );
  }

  CompanyWorkspace updateUserNotes(
    CompanyWorkspace workspace,
    String checkInId,
    String notes,
  ) {
    return _updateActive(
      workspace,
      checkInId,
      (checkIn) => checkIn.copyWith(userNotes: notes),
    );
  }

  /// Completes the check-in: the situation is re-captured from the current
  /// workspace state (ratings caught up during the check-in are included),
  /// user notes and confirmed next steps are preserved, then the check-in
  /// freezes as part of the company memory.
  CompanyWorkspace completeCheckIn(
    CompanyWorkspace workspace,
    String checkInId, {
    String? userNotes,
    List<String>? confirmedNextActionIds,
    DateTime? now,
  }) {
    return _updateActive(workspace, checkInId, (checkIn) {
      final timestamp = now ?? DateTime.now();
      final refreshed = generator.generate(
        workspace: workspace,
        periodStart: checkIn.periodStart,
        periodEnd: checkIn.periodEnd,
        now: timestamp,
      );
      return checkIn.copyWith(
        status: CheckInStatus.completed,
        completedAt: timestamp,
        summary: refreshed.summary,
        completedActionIds: refreshed.completedActionIds,
        openActionIds: refreshed.openActionIds,
        ratedActionIds: refreshed.ratedActionIds,
        awaitingRatingActionIds: refreshed.awaitingRatingActionIds,
        positiveOutcomes: refreshed.positiveOutcomes,
        negativeOutcomes: refreshed.negativeOutcomes,
        lessonsLearned: refreshed.lessonsLearned,
        userNotes: userNotes ?? checkIn.userNotes,
        nextActionIds: confirmedNextActionIds ?? refreshed.nextActionIds,
        dataConfidence: refreshed.dataConfidence,
        needsHumanReview: refreshed.needsHumanReview,
      );
    });
  }

  CompanyWorkspace skipCheckIn(
    CompanyWorkspace workspace,
    String checkInId, {
    DateTime? now,
  }) {
    return _updateActive(
      workspace,
      checkInId,
      (checkIn) => checkIn.copyWith(
        status: CheckInStatus.skipped,
        completedAt: now ?? DateTime.now(),
      ),
    );
  }

  /// Applies [update] only to an *active* check-in with [checkInId] —
  /// completed/skipped check-ins are immutable.
  CompanyWorkspace _updateActive(
    CompanyWorkspace workspace,
    String checkInId,
    CompanionCheckIn Function(CompanionCheckIn checkIn) update,
  ) {
    var changed = false;
    final checkIns = [
      for (final checkIn in workspace.checkIns)
        if (checkIn.id == checkInId && checkIn.isActive)
          (() {
            changed = true;
            return update(checkIn);
          })()
        else
          checkIn,
    ];
    return changed ? workspace.copyWith(checkIns: checkIns) : workspace;
  }
}
