/// Lifecycle of a persisted action decision.
enum ActionRecordStatus {
  suggested,
  accepted,
  inProgress,
  completed,
  deferred,
  declined,
}

/// The user's verdict on a completed action.
enum ActionResultRating {
  helpedALot,
  helpedSomewhat,
  noEffect,
  negative,
  notYetRatable,
}

/// One persisted decision about a recommended action — the unit of the
/// company memory. The recommendation itself stays computed
/// (NextBestActionEngine); what is stored is only what the user decided,
/// when, and what came of it. Several records may exist for the same
/// [actionType] over time (done once, repeated later).
class ActionRecord {
  const ActionRecord({
    required this.id,
    required this.actionType,
    required this.titleSnapshot,
    required this.descriptionSnapshot,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.deferredUntil,
    this.declinedAt,
    this.declineReason,
    this.resultRating,
    this.resultNote,
    required this.expectedImpact,
    this.actualOutcome,
    this.repeatRequested,
    this.relatedGoalIds = const [],
    this.sourceReasonKeys = const [],
  });

  final String id;

  /// `NextBestActionType.name` at decision time. Stored as string so old
  /// history survives even if a future version renames or removes types.
  final String actionType;

  /// What the recommendation said when the user decided — recommendations
  /// are recomputed, so the wording is snapshotted here.
  final String titleSnapshot;
  final String descriptionSnapshot;

  final ActionRecordStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? deferredUntil;
  final DateTime? declinedAt;
  final String? declineReason;
  final ActionResultRating? resultRating;

  /// Free-text answer to "Was ist passiert?".
  final String? resultNote;

  /// `ActionImpact.name` at decision time.
  final String expectedImpact;

  /// Free-text answer to "Welche Kennzahl hat sich verändert?".
  final String? actualOutcome;

  /// Whether the user wants this action suggested again later.
  final bool? repeatRequested;

  final List<String> relatedGoalIds;

  /// The evidence strings the recommendation was based on when the user
  /// decided. The engine compares these against current evidence to detect
  /// a materially changed situation (e.g. re-recommending after a decline).
  final List<String> sourceReasonKeys;

  bool get isOpen =>
      status == ActionRecordStatus.accepted ||
      status == ActionRecordStatus.inProgress ||
      status == ActionRecordStatus.deferred;

  bool get awaitsRating =>
      status == ActionRecordStatus.completed &&
      (resultRating == null ||
          resultRating == ActionResultRating.notYetRatable);

  ActionRecord copyWith({
    ActionRecordStatus? status,
    Object? acceptedAt = _keep,
    Object? startedAt = _keep,
    Object? completedAt = _keep,
    Object? deferredUntil = _keep,
    Object? declinedAt = _keep,
    Object? declineReason = _keep,
    Object? resultRating = _keep,
    Object? resultNote = _keep,
    Object? actualOutcome = _keep,
    Object? repeatRequested = _keep,
    List<String>? relatedGoalIds,
    List<String>? sourceReasonKeys,
  }) {
    return ActionRecord(
      id: id,
      actionType: actionType,
      titleSnapshot: titleSnapshot,
      descriptionSnapshot: descriptionSnapshot,
      status: status ?? this.status,
      createdAt: createdAt,
      acceptedAt: identical(acceptedAt, _keep)
          ? this.acceptedAt
          : acceptedAt as DateTime?,
      startedAt: identical(startedAt, _keep)
          ? this.startedAt
          : startedAt as DateTime?,
      completedAt: identical(completedAt, _keep)
          ? this.completedAt
          : completedAt as DateTime?,
      deferredUntil: identical(deferredUntil, _keep)
          ? this.deferredUntil
          : deferredUntil as DateTime?,
      declinedAt: identical(declinedAt, _keep)
          ? this.declinedAt
          : declinedAt as DateTime?,
      declineReason: identical(declineReason, _keep)
          ? this.declineReason
          : declineReason as String?,
      resultRating: identical(resultRating, _keep)
          ? this.resultRating
          : resultRating as ActionResultRating?,
      resultNote: identical(resultNote, _keep)
          ? this.resultNote
          : resultNote as String?,
      expectedImpact: expectedImpact,
      actualOutcome: identical(actualOutcome, _keep)
          ? this.actualOutcome
          : actualOutcome as String?,
      repeatRequested: identical(repeatRequested, _keep)
          ? this.repeatRequested
          : repeatRequested as bool?,
      relatedGoalIds: relatedGoalIds ?? this.relatedGoalIds,
      sourceReasonKeys: sourceReasonKeys ?? this.sourceReasonKeys,
    );
  }
}

const Object _keep = Object();
