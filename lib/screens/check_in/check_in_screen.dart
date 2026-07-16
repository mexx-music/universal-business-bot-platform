import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/action_record.dart';
import '../../models/companion_check_in.dart';
import '../../widgets/action_result_dialog.dart';

/// The companion ritual: a short, guided review — what happened, what
/// helped, what did we learn, what comes next. Deliberately simple; one
/// column, six steps, honest language.
class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  int _currentStep = 0;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final active = state.activeCheckIn;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                l.checkInTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.checkInIntro,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              if (active == null)
                ..._buildOverview(context, state, l, theme)
              else
                ..._buildGuidedFlow(context, state, l, theme, active),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOverview(
    BuildContext context,
    AppState state,
    AppLocalizations l,
    ThemeData theme,
  ) {
    final last = state.lastCompletedCheckIn;
    final next = state.nextRecommendedCheckIn;
    final awaiting = state.actionRecordsAwaitingRating.length;
    final history = [...state.checkIns]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l.checkInLastLabel}: '
                '${last == null ? l.checkInNever : _date(last.periodEnd)}',
              ),
              const SizedBox(height: 4),
              Text('${l.checkInNextLabel}: ${_date(next)}'),
              const SizedBox(height: 4),
              Text('${l.awaitingRatingSectionTitle}: $awaiting'),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () {
                  state.startCheckIn();
                  setState(() => _currentStep = 0);
                  _notesController.clear();
                },
                icon: const Icon(Icons.flag_outlined),
                label: Text(l.checkInStart),
              ),
            ],
          ),
        ),
      ),
      if (history.isNotEmpty) ...[
        const SizedBox(height: 24),
        Text(
          l.checkInHistoryTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        for (final checkIn in history) _CheckInHistoryTile(checkIn: checkIn),
      ],
    ];
  }

  List<Widget> _buildGuidedFlow(
    BuildContext context,
    AppState state,
    AppLocalizations l,
    ThemeData theme,
    CompanionCheckIn active,
  ) {
    final preview = state.activeCheckInPreview ?? active;
    final awaiting = state.actionRecordsAwaitingRating;
    final nextActions = state.nextBestActions.take(3).toList();
    final isLastStep = _currentStep == 5;

    return [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            state.skipCheckIn(active.id);
            setState(() => _currentStep = 0);
          },
          child: Text(l.checkInSkip),
        ),
      ),
      Stepper(
        physics: const NeverScrollableScrollPhysics(),
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          if (isLastStep) {
            state.completeCheckIn(
              active.id,
              userNotes: _notesController.text,
              confirmedNextActionIds: [
                for (final action in nextActions) action.id,
              ],
            );
            setState(() => _currentStep = 0);
            return;
          }
          setState(() => _currentStep += 1);
        },
        onStepCancel: _currentStep == 0
            ? null
            : () => setState(() => _currentStep -= 1),
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              FilledButton(
                onPressed: details.onStepContinue,
                child: Text(isLastStep ? l.checkInComplete : l.btnNext),
              ),
              const SizedBox(width: 8),
              if (details.onStepCancel != null)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(l.btnBack),
                ),
            ],
          ),
        ),
        steps: [
          Step(
            title: Text(l.checkInStep1),
            isActive: _currentStep >= 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(preview.summary),
                const SizedBox(height: 10),
                _ConfidenceRow(checkIn: preview),
              ],
            ),
          ),
          Step(
            title: Text(l.checkInStep2),
            isActive: _currentStep >= 1,
            content: awaiting.isEmpty
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l.checkInNoOpenRatings),
                  )
                : Column(
                    children: [
                      for (final record in awaiting)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(record.titleSnapshot),
                            subtitle: record.completedAt == null
                                ? null
                                : Text(_date(record.completedAt!)),
                            trailing: TextButton(
                              onPressed: () => showActionResultDialog(
                                context,
                                onSave: (result) => state.rateActionRecord(
                                  record.id,
                                  rating: result.rating ??
                                      ActionResultRating.notYetRatable,
                                  resultNote: result.note,
                                  actualOutcome: result.outcome,
                                  repeatRequested: result.repeat,
                                ),
                              ),
                              child: Text(l.rateNow),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          Step(
            title: Text(l.checkInStep3),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (preview.positiveOutcomes.isEmpty &&
                    preview.negativeOutcomes.isEmpty)
                  Text(l.checkInNoOutcomes)
                else ...[
                  if (preview.positiveOutcomes.isNotEmpty) ...[
                    Text(
                      l.checkInPositiveTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (final outcome in preview.positiveOutcomes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $outcome'),
                      ),
                    const SizedBox(height: 8),
                  ],
                  if (preview.negativeOutcomes.isNotEmpty) ...[
                    Text(
                      l.checkInNegativeTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (final outcome in preview.negativeOutcomes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $outcome'),
                      ),
                    const SizedBox(height: 8),
                  ],
                ],
                Text(
                  l.checkInCausalityNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: Text(l.checkInStep4),
            isActive: _currentStep >= 3,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (preview.lessonsLearned.isNotEmpty) ...[
                  Text(
                    l.checkInLessonsTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (final lesson in preview.lessonsLearned)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $lesson'),
                    ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: l.checkInNotesLabel,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          Step(
            title: Text(l.checkInStep5),
            isActive: _currentStep >= 4,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.checkInNextStepsIntro),
                const SizedBox(height: 8),
                for (final action in nextActions)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.arrow_forward),
                      title: Text(action.title),
                      subtitle: Text(
                        action.reasons.isEmpty
                            ? action.description
                            : action.reasons.first.message,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Step(
            title: Text(l.checkInStep6),
            isActive: _currentStep >= 5,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(preview.summary),
                const SizedBox(height: 10),
                _ConfidenceRow(checkIn: preview),
              ],
            ),
          ),
        ],
      ),
    ];
  }
}

/// Confidence chip plus the gentle human-review hint.
class _ConfidenceRow extends StatelessWidget {
  final CompanionCheckIn checkIn;

  const _ConfidenceRow({required this.checkIn});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final confidenceLabel = switch (checkIn.dataConfidence) {
      CheckInDataConfidence.low => l.checkInConfidenceLow,
      CheckInDataConfidence.medium => l.checkInConfidenceMedium,
      CheckInDataConfidence.high => l.checkInConfidenceHigh,
    };
    final confidenceColor = switch (checkIn.dataConfidence) {
      CheckInDataConfidence.low => theme.colorScheme.errorContainer,
      CheckInDataConfidence.medium => theme.colorScheme.secondaryContainer,
      CheckInDataConfidence.high => theme.colorScheme.tertiaryContainer,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: confidenceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${l.checkInConfidenceLabel}: $confidenceLabel',
            style: theme.textTheme.labelSmall,
          ),
        ),
        if (checkIn.needsHumanReview) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.support_agent,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l.checkInHumanReviewHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CheckInHistoryTile extends StatelessWidget {
  final CompanionCheckIn checkIn;

  const _CheckInHistoryTile({required this.checkIn});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final statusLabel = switch (checkIn.status) {
      CheckInStatus.completed => l.checkInStatusCompleted,
      CheckInStatus.skipped => l.checkInStatusSkipped,
      _ => l.checkInStatusActive,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          checkIn.status == CheckInStatus.completed
              ? Icons.event_available
              : Icons.event_busy,
          color: checkIn.status == CheckInStatus.completed
              ? Colors.green
              : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          '${_date(checkIn.periodStart)} – ${_date(checkIn.periodEnd)} · '
          '$statusLabel',
        ),
        subtitle: Text(
          [
            checkIn.summary,
            if (checkIn.userNotes.isNotEmpty) '„${checkIn.userNotes}"',
            if (checkIn.needsHumanReview) l.checkInHumanReviewHint,
          ].join('\n'),
        ),
        isThreeLine: true,
      ),
    );
  }
}

String _date(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.${date.year}';
}
