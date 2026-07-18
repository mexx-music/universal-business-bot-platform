import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/action_record.dart';
import '../../recommendations/next_best_action.dart';
import '../../widgets/action_result_dialog.dart';

/// The companion's central page: the 3–5 most important next steps, each
/// with reasoning and data basis, plus the growing action history
/// (company memory) below.
class NextActionsScreen extends StatelessWidget {
  const NextActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final plan = state.nextBestActionPlan;
    final inProgress = state.inProgressActionRecords;
    final awaitingRating = state.actionRecordsAwaitingRating;
    final history = [...state.actionRecords]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                l.nextActionsTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.nextActionsIntro,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              if (plan.actions.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(l.nextActionsEmpty)),
                      ],
                    ),
                  ),
                )
              else
                for (final action in plan.actions) ...[
                  _NextActionCard(action: action),
                  const SizedBox(height: 16),
                ],
              if (inProgress.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionHeader(title: l.inProgressSectionTitle),
                for (final record in inProgress)
                  _RecordTile(
                    record: record,
                    trailing: TextButton(
                      onPressed: () => showActionResultDialog(
                        context,
                        onSave: (result) => state.completeActionRecord(
                          record.id,
                          rating: result.rating,
                          resultNote: result.note,
                          actualOutcome: result.outcome,
                          repeatRequested: result.repeat,
                        ),
                      ),
                      child: Text(l.actionComplete),
                    ),
                  ),
              ],
              if (awaitingRating.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionHeader(title: l.awaitingRatingSectionTitle),
                for (final record in awaitingRating)
                  _RecordTile(
                    record: record,
                    trailing: TextButton(
                      onPressed: () => showActionResultDialog(
                        context,
                        onSave: (result) => state.rateActionRecord(
                          record.id,
                          rating:
                              result.rating ?? ActionResultRating.notYetRatable,
                          resultNote: result.note,
                          actualOutcome: result.outcome,
                          repeatRequested: result.repeat,
                        ),
                      ),
                      child: Text(l.rateNow),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              _SectionHeader(title: l.historyTitle),
              if (history.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    l.historyEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                for (final record in history) _RecordTile(record: record),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _NextActionCard extends StatelessWidget {
  final NextBestAction action;

  const _NextActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              action.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(
                  context,
                  '${l.actionPriorityPrefix}: '
                  '${_priorityLabel(l, action.priority)}',
                  _priorityColor(theme, action.priority),
                ),
                _chip(
                  context,
                  '${l.actionEffortPrefix}: '
                  '${_levelLabel(l, action.effort.name)}',
                  theme.colorScheme.secondaryContainer,
                ),
                _chip(
                  context,
                  '${l.actionImpactPrefix}: '
                  '${_levelLabel(l, action.impact.name)}',
                  theme.colorScheme.tertiaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(action.description),
            const SizedBox(height: 12),
            Text(
              l.actionWhyNow,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            for (final reason in action.reasons)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('• ${reason.message}'),
              ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.actionEvidenceLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (final reason in action.reasons)
                    Text(
                      reason.evidence,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () => state.acceptNextAction(action),
                  child: Text(l.actionAccept),
                ),
                OutlinedButton(
                  onPressed: () => _showDeferDialog(context, action),
                  child: Text(l.actionDefer),
                ),
                OutlinedButton(
                  onPressed: () => _showDeclineDialog(context, action),
                  child: Text(l.actionDecline),
                ),
                TextButton(
                  onPressed: () => state.startNextAction(action),
                  child: Text(l.actionStart),
                ),
                TextButton(
                  onPressed: () => showActionResultDialog(
                    context,
                    onSave: (result) => state.completeNextAction(
                      action,
                      rating: result.rating,
                      resultNote: result.note,
                      actualOutcome: result.outcome,
                      repeatRequested: result.repeat,
                    ),
                  ),
                  child: Text(l.actionComplete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, Color background) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: theme.textTheme.labelSmall),
    );
  }

  Color _priorityColor(ThemeData theme, ActionPriority priority) {
    return switch (priority) {
      ActionPriority.critical => theme.colorScheme.errorContainer,
      ActionPriority.high => theme.colorScheme.primaryContainer,
      ActionPriority.medium => theme.colorScheme.secondaryContainer,
      ActionPriority.low => theme.colorScheme.surfaceContainerHighest,
    };
  }
}

class _RecordTile extends StatelessWidget {
  final ActionRecord record;
  final Widget? trailing;

  const _RecordTile({required this.record, this.trailing});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final details = <String>[
      '${_statusLabel(l, record.status)} · ${_date(record.createdAt)}',
      if (record.deferredUntil != null)
        '${l.actionStatusDeferred}: ${_date(record.deferredUntil!)}',
      if (record.declineReason != null) '„${record.declineReason}"',
      if (record.resultRating != null)
        actionRatingLabel(l, record.resultRating!),
      if (record.resultNote != null) record.resultNote!,
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _statusIcon(record.status),
          color: _statusColor(theme, record.status),
        ),
        title: Text(record.titleSnapshot),
        subtitle: Text(details.join(' · ')),
        trailing: trailing,
      ),
    );
  }

  IconData _statusIcon(ActionRecordStatus status) {
    return switch (status) {
      ActionRecordStatus.suggested => Icons.lightbulb_outline,
      ActionRecordStatus.accepted => Icons.thumb_up_outlined,
      ActionRecordStatus.inProgress => Icons.play_circle_outline,
      ActionRecordStatus.completed => Icons.check_circle_outline,
      ActionRecordStatus.deferred => Icons.schedule,
      ActionRecordStatus.declined => Icons.cancel_outlined,
    };
  }

  Color _statusColor(ThemeData theme, ActionRecordStatus status) {
    return switch (status) {
      ActionRecordStatus.completed => Colors.green,
      ActionRecordStatus.inProgress => theme.colorScheme.primary,
      ActionRecordStatus.declined => theme.colorScheme.error,
      _ => theme.colorScheme.onSurfaceVariant,
    };
  }
}

// --- dialogs ---

Future<void> _showDeferDialog(
  BuildContext context,
  NextBestAction action,
) async {
  final state = AppState.of(context);
  final l = AppLocalizations.of(context)!;
  final days = await showDialog<int>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: Text(l.deferDialogTitle),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.pop(dialogContext, 7),
          child: Text(l.deferOneWeek),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(dialogContext, 30),
          child: Text(l.deferOneMonth),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(dialogContext, 90),
          child: Text(l.deferThreeMonths),
        ),
      ],
    ),
  );
  if (days == null) return;
  state.deferNextAction(
    action,
    until: DateTime.now().add(Duration(days: days)),
  );
}

Future<void> _showDeclineDialog(
  BuildContext context,
  NextBestAction action,
) async {
  final state = AppState.of(context);
  final l = AppLocalizations.of(context)!;
  final controller = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l.declineDialogTitle),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: l.declineReasonLabel),
        maxLines: 2,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l.btnCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l.actionDecline),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    state.declineNextAction(action, reason: controller.text);
  }
  controller.dispose();
}

// --- shared label helpers ---

String _priorityLabel(AppLocalizations l, ActionPriority priority) {
  return switch (priority) {
    ActionPriority.critical => l.actionPriorityCritical,
    ActionPriority.high => l.actionPriorityHigh,
    ActionPriority.medium => l.actionPriorityMedium,
    ActionPriority.low => l.actionPriorityLow,
  };
}

String _levelLabel(AppLocalizations l, String level) {
  return switch (level) {
    'low' => l.actionLevelLow,
    'high' => l.actionLevelHigh,
    _ => l.actionLevelMedium,
  };
}

String _statusLabel(AppLocalizations l, ActionRecordStatus status) {
  return switch (status) {
    ActionRecordStatus.suggested => l.actionStatusSuggested,
    ActionRecordStatus.accepted => l.actionStatusAccepted,
    ActionRecordStatus.inProgress => l.actionStatusInProgress,
    ActionRecordStatus.completed => l.actionStatusCompleted,
    ActionRecordStatus.deferred => l.actionStatusDeferred,
    ActionRecordStatus.declined => l.actionStatusDeclined,
  };
}

String _date(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.${date.year}';
}
