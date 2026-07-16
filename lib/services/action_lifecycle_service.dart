import '../models/action_record.dart';
import '../models/company_workspace.dart';
import '../recommendations/next_best_action.dart';

/// Pure mutation logic for the action lifecycle: every method takes a
/// workspace and returns an updated copy — no state, no side effects.
/// AppState delegates here (same pattern as WorkspaceMutationService).
///
/// Decisions on a *recommendation* create a new [ActionRecord] (snapshotting
/// title, description and evidence at decision time); transitions on an
/// existing open record (start, complete, rate) update that record in place.
class ActionLifecycleService {
  const ActionLifecycleService();

  CompanyWorkspace acceptAction(
    CompanyWorkspace workspace,
    NextBestAction action, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return _append(
      workspace,
      _newRecord(action, timestamp).copyWith(
        status: ActionRecordStatus.accepted,
        acceptedAt: timestamp,
      ),
    );
  }

  CompanyWorkspace deferAction(
    CompanyWorkspace workspace,
    NextBestAction action, {
    required DateTime until,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return _append(
      workspace,
      _newRecord(action, timestamp).copyWith(
        status: ActionRecordStatus.deferred,
        deferredUntil: until,
      ),
    );
  }

  CompanyWorkspace declineAction(
    CompanyWorkspace workspace,
    NextBestAction action, {
    String? reason,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return _append(
      workspace,
      _newRecord(action, timestamp).copyWith(
        status: ActionRecordStatus.declined,
        declinedAt: timestamp,
        declineReason: reason == null || reason.trim().isEmpty
            ? null
            : reason.trim(),
      ),
    );
  }

  /// Marks an action as started. Continues the open record for this action
  /// type if one exists (accepted/deferred), otherwise creates one directly
  /// from the recommendation.
  CompanyWorkspace startAction(
    CompanyWorkspace workspace,
    NextBestAction action, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final open = _openRecordFor(workspace, action.type.name);
    if (open != null) {
      return _replace(
        workspace,
        open.copyWith(
          status: ActionRecordStatus.inProgress,
          startedAt: timestamp,
          deferredUntil: null,
        ),
      );
    }
    return _append(
      workspace,
      _newRecord(action, timestamp).copyWith(
        status: ActionRecordStatus.inProgress,
        startedAt: timestamp,
      ),
    );
  }

  /// Marks an action as completed, straight from the recommendation or from
  /// an open record. The result questions are optional — rating can also
  /// happen later via [rateRecord].
  CompanyWorkspace completeAction(
    CompanyWorkspace workspace,
    NextBestAction action, {
    ActionResultRating? rating,
    String? resultNote,
    String? actualOutcome,
    bool? repeatRequested,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final open = _openRecordFor(workspace, action.type.name);
    final base = open ?? _newRecord(action, timestamp);
    return open != null
        ? _replace(workspace, _completed(base, timestamp, rating, resultNote,
            actualOutcome, repeatRequested))
        : _append(workspace, _completed(base, timestamp, rating, resultNote,
            actualOutcome, repeatRequested));
  }

  /// Completes an existing record by id (e.g. from the "In Umsetzung" list).
  CompanyWorkspace completeRecord(
    CompanyWorkspace workspace,
    String recordId, {
    ActionResultRating? rating,
    String? resultNote,
    String? actualOutcome,
    bool? repeatRequested,
    DateTime? now,
  }) {
    final record = _byId(workspace, recordId);
    if (record == null) return workspace;
    return _replace(
      workspace,
      _completed(record, now ?? DateTime.now(), rating, resultNote,
          actualOutcome, repeatRequested),
    );
  }

  /// Rates (or re-rates) a completed record later.
  CompanyWorkspace rateRecord(
    CompanyWorkspace workspace,
    String recordId, {
    required ActionResultRating rating,
    String? resultNote,
    String? actualOutcome,
    bool? repeatRequested,
  }) {
    final record = _byId(workspace, recordId);
    if (record == null || record.status != ActionRecordStatus.completed) {
      return workspace;
    }
    return _replace(
      workspace,
      record.copyWith(
        resultRating: rating,
        resultNote: _cleanText(resultNote) ?? record.resultNote,
        actualOutcome: _cleanText(actualOutcome) ?? record.actualOutcome,
        repeatRequested: repeatRequested ?? record.repeatRequested,
      ),
    );
  }

  // --- helpers ---

  ActionRecord _newRecord(NextBestAction action, DateTime timestamp) {
    return ActionRecord(
      id: 'ar_${action.type.name}_${timestamp.microsecondsSinceEpoch}',
      actionType: action.type.name,
      titleSnapshot: action.title,
      descriptionSnapshot: action.description,
      status: ActionRecordStatus.suggested,
      createdAt: timestamp,
      expectedImpact: action.impact.name,
      sourceReasonKeys: [
        for (final reason in action.reasons) reason.evidence,
      ],
    );
  }

  ActionRecord _completed(
    ActionRecord record,
    DateTime timestamp,
    ActionResultRating? rating,
    String? resultNote,
    String? actualOutcome,
    bool? repeatRequested,
  ) {
    return record.copyWith(
      status: ActionRecordStatus.completed,
      completedAt: timestamp,
      resultRating: rating,
      resultNote: _cleanText(resultNote),
      actualOutcome: _cleanText(actualOutcome),
      repeatRequested: repeatRequested,
    );
  }

  ActionRecord? _openRecordFor(CompanyWorkspace workspace, String actionType) {
    ActionRecord? latest;
    for (final record in workspace.actionRecords) {
      if (record.actionType != actionType || !record.isOpen) continue;
      if (latest == null || record.createdAt.isAfter(latest.createdAt)) {
        latest = record;
      }
    }
    return latest;
  }

  ActionRecord? _byId(CompanyWorkspace workspace, String recordId) {
    for (final record in workspace.actionRecords) {
      if (record.id == recordId) return record;
    }
    return null;
  }

  CompanyWorkspace _append(CompanyWorkspace workspace, ActionRecord record) {
    return workspace.copyWith(
      actionRecords: [...workspace.actionRecords, record],
    );
  }

  CompanyWorkspace _replace(CompanyWorkspace workspace, ActionRecord updated) {
    return workspace.copyWith(
      actionRecords: [
        for (final record in workspace.actionRecords)
          if (record.id == updated.id) updated else record,
      ],
    );
  }

  String? _cleanText(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }
}
