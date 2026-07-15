import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/marketing_strategy.dart';

class MarketingStrategyScreen extends StatelessWidget {
  const MarketingStrategyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final strategy = state.marketingStrategy;
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l.marketingStrategyTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.marketingStrategySubtitle(state.company.name),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _MarketingScoreCard(strategy: strategy),
          const SizedBox(height: 24),
          Text(
            l.marketingRecommendationsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (strategy.recommendedActions.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.marketingRecommendationsEmpty)),
                  ],
                ),
              ),
            )
          else
            _ActionGrid(
              actions: strategy.recommendedActions,
              highlighted: true,
            ),
          const SizedBox(height: 24),
          Text(
            l.marketingActionsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _ActionGrid(actions: strategy.actions),
        ],
      ),
    );
  }
}

class _MarketingScoreCard extends StatelessWidget {
  final MarketingStrategySnapshot strategy;

  const _MarketingScoreCard({required this.strategy});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final score = strategy.score;
    final color = score >= 75
        ? Colors.green
        : score >= 45
        ? Colors.orange
        : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            final scoreBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withAlpha(24),
                      child: Icon(Icons.trending_up, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.marketingScore,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '$score',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: score / 100,
                    color: color,
                  ),
                ),
              ],
            );

            final metrics = Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricChip(
                  icon: Icons.pending_actions_outlined,
                  label: l.marketingOpenActions(strategy.openActionCount),
                  color: Colors.orange,
                ),
                _MetricChip(
                  icon: Icons.play_circle_outline,
                  label: l.marketingRunningActions(
                    strategy.inProgressActionCount,
                  ),
                  color: Colors.blue,
                ),
                _MetricChip(
                  icon: Icons.check_circle_outline,
                  label: l.marketingCompletedActions(
                    strategy.completedActionCount,
                  ),
                  color: Colors.green,
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [scoreBlock, const SizedBox(height: 16), metrics],
              );
            }
            return Row(
              children: [
                Expanded(flex: 3, child: scoreBlock),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: metrics),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final List<MarketingAction> actions;
  final bool highlighted;

  const _ActionGrid({required this.actions, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 720
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: highlighted ? 252 : 276,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return _MarketingActionCard(
              action: actions[index],
              highlighted: highlighted,
            );
          },
        );
      },
    );
  }
}

class _MarketingActionCard extends StatelessWidget {
  final MarketingAction action;
  final bool highlighted;

  const _MarketingActionCard({required this.action, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final priorityColor = _priorityColor(action.priority);
    final statusColor = _statusColor(action.status);

    return Card(
      elevation: highlighted ? 2 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: priorityColor.withAlpha(22),
                  child: Icon(_actionIcon(action.type), color: priorityColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _actionTitle(l, action.type),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _actionDescription(l, action.type),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Pill(
                  label: _priorityLabel(l, action.priority),
                  color: priorityColor,
                ),
                _Pill(
                  label: _effortLabel(l, action.effort),
                  color: Colors.blue,
                ),
                _Pill(
                  label: _impactLabel(l, action.impact),
                  color: Colors.green,
                ),
                _Pill(
                  label: _statusLabel(l, action.status),
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              action.notes.trim().isEmpty
                  ? l.marketingNoNotes
                  : action.notes.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _budgetSummary(l, action),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final updated = await showDialog<MarketingAction>(
                      context: context,
                      builder: (_) => _MarketingActionDialog(action: action),
                    );
                    if (updated != null) {
                      state.updateMarketingAction(updated);
                    }
                  },
                  child: Text(l.marketingEditAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketingActionDialog extends StatefulWidget {
  final MarketingAction action;

  const _MarketingActionDialog({required this.action});

  @override
  State<_MarketingActionDialog> createState() => _MarketingActionDialogState();
}

class _MarketingActionDialogState extends State<_MarketingActionDialog> {
  late MarketingActionStatus _status;
  late final TextEditingController _notesController;
  late final TextEditingController _plannedBudgetController;
  late final TextEditingController _usedBudgetController;
  late final TextEditingController _budgetCommentController;

  @override
  void initState() {
    super.initState();
    _status = widget.action.status;
    _notesController = TextEditingController(text: widget.action.notes);
    _plannedBudgetController = TextEditingController(
      text: _formatBudgetValue(widget.action.plannedBudget),
    );
    _usedBudgetController = TextEditingController(
      text: _formatBudgetValue(widget.action.usedBudget),
    );
    _budgetCommentController = TextEditingController(
      text: widget.action.budgetComment,
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _plannedBudgetController.dispose();
    _usedBudgetController.dispose();
    _budgetCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(_actionTitle(l, widget.action.type)),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<MarketingActionStatus>(
                initialValue: _status,
                decoration: InputDecoration(labelText: l.marketingActionStatus),
                items: MarketingActionStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(_statusLabel(l, status)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(labelText: l.marketingActionNotes),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _plannedBudgetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l.marketingBudgetPlanned,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _usedBudgetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l.marketingBudgetUsed),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _budgetCommentController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l.marketingBudgetComment,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.btnCancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(
              context,
              widget.action.copyWith(
                status: _status,
                notes: _notesController.text.trim(),
                plannedBudget: _parseBudget(_plannedBudgetController.text),
                usedBudget: _parseBudget(_usedBudgetController.text),
                budgetComment: _budgetCommentController.text.trim(),
              ),
            );
          },
          child: Text(l.btnSave),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

IconData _actionIcon(MarketingActionType type) {
  return switch (type) {
    MarketingActionType.optimizeWebsite => Icons.public_outlined,
    MarketingActionType.createGoogleBusiness => Icons.storefront_outlined,
    MarketingActionType.maintainFacebook => Icons.groups_outlined,
    MarketingActionType.startInstagram => Icons.photo_camera_outlined,
    MarketingActionType.useLinkedIn => Icons.business_center_outlined,
    MarketingActionType.expandFaq => Icons.help_outline,
    MarketingActionType.collectReviews => Icons.star_outline,
    MarketingActionType.prepareNewsletter => Icons.mail_outline,
    MarketingActionType.integrateBotWebsite => Icons.smart_toy_outlined,
    MarketingActionType.improveSeo => Icons.manage_search_outlined,
    MarketingActionType.checkGoogleAds => Icons.ads_click_outlined,
    MarketingActionType.checkFacebookAds => Icons.campaign_outlined,
  };
}

Color _priorityColor(MarketingActionPriority priority) {
  return switch (priority) {
    MarketingActionPriority.high => Colors.red,
    MarketingActionPriority.medium => Colors.orange,
    MarketingActionPriority.low => Colors.blueGrey,
  };
}

Color _statusColor(MarketingActionStatus status) {
  return switch (status) {
    MarketingActionStatus.notStarted => Colors.grey,
    MarketingActionStatus.planned => Colors.indigo,
    MarketingActionStatus.inProgress => Colors.blue,
    MarketingActionStatus.completed => Colors.green,
    MarketingActionStatus.postponed => Colors.blueGrey,
  };
}

String _actionTitle(AppLocalizations l, MarketingActionType type) {
  return switch (type) {
    MarketingActionType.optimizeWebsite => l.marketingActionOptimizeWebsite,
    MarketingActionType.createGoogleBusiness => l.marketingActionGoogleBusiness,
    MarketingActionType.maintainFacebook => l.marketingActionFacebook,
    MarketingActionType.startInstagram => l.marketingActionInstagram,
    MarketingActionType.useLinkedIn => l.marketingActionLinkedIn,
    MarketingActionType.expandFaq => l.marketingActionFaq,
    MarketingActionType.collectReviews => l.marketingActionReviews,
    MarketingActionType.prepareNewsletter => l.marketingActionNewsletter,
    MarketingActionType.integrateBotWebsite => l.marketingActionBotWebsite,
    MarketingActionType.improveSeo => l.marketingActionSeo,
    MarketingActionType.checkGoogleAds => l.marketingActionGoogleAds,
    MarketingActionType.checkFacebookAds => l.marketingActionFacebookAds,
  };
}

String _actionDescription(AppLocalizations l, MarketingActionType type) {
  return switch (type) {
    MarketingActionType.optimizeWebsite => l.marketingActionOptimizeWebsiteDesc,
    MarketingActionType.createGoogleBusiness =>
      l.marketingActionGoogleBusinessDesc,
    MarketingActionType.maintainFacebook => l.marketingActionFacebookDesc,
    MarketingActionType.startInstagram => l.marketingActionInstagramDesc,
    MarketingActionType.useLinkedIn => l.marketingActionLinkedInDesc,
    MarketingActionType.expandFaq => l.marketingActionFaqDesc,
    MarketingActionType.collectReviews => l.marketingActionReviewsDesc,
    MarketingActionType.prepareNewsletter => l.marketingActionNewsletterDesc,
    MarketingActionType.integrateBotWebsite => l.marketingActionBotWebsiteDesc,
    MarketingActionType.improveSeo => l.marketingActionSeoDesc,
    MarketingActionType.checkGoogleAds => l.marketingActionGoogleAdsDesc,
    MarketingActionType.checkFacebookAds => l.marketingActionFacebookAdsDesc,
  };
}

String _priorityLabel(AppLocalizations l, MarketingActionPriority priority) {
  return switch (priority) {
    MarketingActionPriority.low => l.projectPriorityLow,
    MarketingActionPriority.medium => l.projectPriorityMedium,
    MarketingActionPriority.high => l.projectPriorityHigh,
  };
}

String _effortLabel(AppLocalizations l, MarketingActionEffort effort) {
  return switch (effort) {
    MarketingActionEffort.low => l.marketingEffortLow,
    MarketingActionEffort.medium => l.marketingEffortMedium,
    MarketingActionEffort.high => l.marketingEffortHigh,
  };
}

String _impactLabel(AppLocalizations l, MarketingActionImpact impact) {
  return switch (impact) {
    MarketingActionImpact.low => l.marketingImpactLow,
    MarketingActionImpact.medium => l.marketingImpactMedium,
    MarketingActionImpact.high => l.marketingImpactHigh,
  };
}

String _statusLabel(AppLocalizations l, MarketingActionStatus status) {
  return switch (status) {
    MarketingActionStatus.notStarted => l.marketingStatusNotStarted,
    MarketingActionStatus.planned => l.marketingStatusPlanned,
    MarketingActionStatus.inProgress => l.marketingStatusInProgress,
    MarketingActionStatus.completed => l.marketingStatusCompleted,
    MarketingActionStatus.postponed => l.marketingStatusPostponed,
  };
}

String _budgetSummary(AppLocalizations l, MarketingAction action) {
  final planned = action.plannedBudget;
  final used = action.usedBudget;
  if (planned == null && used == null) return l.marketingNoBudget;
  return l.marketingBudgetSummary(
    _formatBudgetValue(planned),
    _formatBudgetValue(used),
  );
}

String _formatBudgetValue(double? value) {
  if (value == null) return '';
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}

double? _parseBudget(String value) {
  final clean = value.trim().replaceAll(',', '.');
  if (clean.isEmpty) return null;
  return double.tryParse(clean);
}
