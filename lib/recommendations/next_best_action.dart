import '../models/business_strategy.dart';

/// How urgent a recommended action is.
enum ActionPriority { critical, high, medium, low }

/// Estimated effort to carry the action out.
enum ActionEffort { low, medium, high }

/// Expected benefit once the action is done.
enum ActionImpact { low, medium, high }

/// Lifecycle of a recommendation. The engine always emits [proposed];
/// the other states prepare the later accept/defer/reject/complete flow
/// (no UI for this yet).
enum NextBestActionStatus { proposed, accepted, deferred, rejected, completed }

/// Stable identity of a recommendation — the same business situation always
/// produces the same type, which later lets accept/defer/complete decisions
/// stick across recalculations.
enum NextBestActionType {
  completeIntake,
  completeCompanyProfile,
  workOffHumanReview,
  reviewSources,
  expandFaq,
  addKnowledge,
  activateBot,
  improveWebsite,
  prepareSocialMedia,
  collectAndAnswerReviews,
  startMarketing,
  focusMarketing,
  defineBusinessGoals,
}

/// One traceable reason behind a recommendation: a human-readable message
/// plus the concrete data point that produced it. No black box — every
/// recommendation can show exactly which numbers led to it.
class ActionReason {
  const ActionReason({required this.message, required this.evidence});

  /// Human-readable justification ("Es liegen 4 offene Review-Anfragen vor").
  final String message;

  /// The underlying data point ("botLogs: 4× reviewStatus=open").
  final String evidence;
}

/// One concrete, prioritized recommendation for a workspace.
class NextBestAction {
  const NextBestAction({
    required this.type,
    required this.title,
    required this.description,
    required this.reasons,
    required this.priority,
    required this.effort,
    required this.impact,
    required this.areas,
    required this.score,
    this.status = NextBestActionStatus.proposed,
  });

  final NextBestActionType type;
  final String title;
  final String description;

  /// Why this action is recommended — never empty.
  final List<ActionReason> reasons;

  final ActionPriority priority;
  final ActionEffort effort;
  final ActionImpact impact;

  /// Which parts of the business the action touches (reuses the existing
  /// strategy area model).
  final List<BusinessGoalArea> areas;

  /// The ranking score behind the ordering — exposed for transparency and
  /// tests, see [NextBestActionEngine].
  final int score;

  final NextBestActionStatus status;

  /// Stable identifier for later persistence of accept/defer decisions.
  String get id => type.name;

  NextBestAction copyWith({
    NextBestActionStatus? status,
    List<ActionReason>? reasons,
  }) {
    return NextBestAction(
      type: type,
      title: title,
      description: description,
      reasons: reasons ?? this.reasons,
      priority: priority,
      effort: effort,
      impact: impact,
      areas: areas,
      score: score,
      status: status ?? this.status,
    );
  }
}

/// A candidate the engine deliberately did not recommend because of the
/// action history — kept explainable instead of silently dropped.
class SuppressedAction {
  const SuppressedAction({
    required this.type,
    required this.title,
    required this.reason,
    required this.evidence,
  });

  final NextBestActionType type;
  final String title;

  /// Human-readable why ("am 12.05. abgelehnt, Datenlage unverändert").
  final String reason;

  /// The underlying record data ("actionRecord ar_x: status=declined").
  final String evidence;
}

/// The full engine result: what is recommended and what was held back
/// (and why).
class NextBestActionPlan {
  const NextBestActionPlan({required this.actions, required this.suppressed});

  /// Top recommendations, highest score first.
  final List<NextBestAction> actions;

  /// History-suppressed candidates with explanations.
  final List<SuppressedAction> suppressed;
}
