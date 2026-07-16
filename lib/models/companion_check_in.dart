/// Lifecycle of one check-in.
enum CheckInStatus { draft, inProgress, completed, skipped }

/// How well the period's statements are backed by actual ratings and data.
enum CheckInDataConfidence { low, medium, high }

/// One (periodic) check-in: a persisted moment in the company memory.
///
/// A completed check-in is immutable — it preserves what the situation,
/// insights and next steps looked like at that time. Outcome statements use
/// honest observation language ("ein positiver Effekt wurde gemeldet"),
/// never causal claims; [dataConfidence] makes the basis visible.
class CompanionCheckIn {
  const CompanionCheckIn({
    required this.id,
    required this.workspaceId,
    required this.periodStart,
    required this.periodEnd,
    required this.createdAt,
    this.completedAt,
    required this.status,
    required this.summary,
    this.completedActionIds = const [],
    this.openActionIds = const [],
    this.ratedActionIds = const [],
    this.awaitingRatingActionIds = const [],
    this.positiveOutcomes = const [],
    this.negativeOutcomes = const [],
    this.lessonsLearned = const [],
    this.userNotes = '',
    this.nextActionIds = const [],
    required this.dataConfidence,
    required this.needsHumanReview,
  });

  final String id;
  final String workspaceId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime createdAt;
  final DateTime? completedAt;
  final CheckInStatus status;

  /// Short human-readable overview of the period.
  final String summary;

  /// ActionRecord ids completed within the period.
  final List<String> completedActionIds;

  /// ActionRecord ids still open (accepted / in progress / deferred).
  final List<String> openActionIds;

  /// ActionRecord ids completed in the period with an actual rating.
  final List<String> ratedActionIds;

  /// ActionRecord ids completed but still waiting for a rating.
  final List<String> awaitingRatingActionIds;

  /// Honest observation sentences — reported effects, never causal claims.
  final List<String> positiveOutcomes;
  final List<String> negativeOutcomes;
  final List<String> lessonsLearned;

  /// Free-text observations the user added during the check-in.
  final String userNotes;

  /// The confirmed next steps (NextBestActionType names) at check-in time.
  final List<String> nextActionIds;

  final CheckInDataConfidence dataConfidence;

  /// True when a short human review would be sensible (contradictory
  /// results, low confidence, open critical reviews, several unrated
  /// actions).
  final bool needsHumanReview;

  bool get isCompleted => status == CheckInStatus.completed;

  bool get isActive =>
      status == CheckInStatus.draft || status == CheckInStatus.inProgress;

  CompanionCheckIn copyWith({
    CheckInStatus? status,
    DateTime? completedAt,
    String? summary,
    List<String>? completedActionIds,
    List<String>? openActionIds,
    List<String>? ratedActionIds,
    List<String>? awaitingRatingActionIds,
    List<String>? positiveOutcomes,
    List<String>? negativeOutcomes,
    List<String>? lessonsLearned,
    String? userNotes,
    List<String>? nextActionIds,
    CheckInDataConfidence? dataConfidence,
    bool? needsHumanReview,
  }) {
    return CompanionCheckIn(
      id: id,
      workspaceId: workspaceId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      completedActionIds: completedActionIds ?? this.completedActionIds,
      openActionIds: openActionIds ?? this.openActionIds,
      ratedActionIds: ratedActionIds ?? this.ratedActionIds,
      awaitingRatingActionIds:
          awaitingRatingActionIds ?? this.awaitingRatingActionIds,
      positiveOutcomes: positiveOutcomes ?? this.positiveOutcomes,
      negativeOutcomes: negativeOutcomes ?? this.negativeOutcomes,
      lessonsLearned: lessonsLearned ?? this.lessonsLearned,
      userNotes: userNotes ?? this.userNotes,
      nextActionIds: nextActionIds ?? this.nextActionIds,
      dataConfidence: dataConfidence ?? this.dataConfidence,
      needsHumanReview: needsHumanReview ?? this.needsHumanReview,
    );
  }
}
