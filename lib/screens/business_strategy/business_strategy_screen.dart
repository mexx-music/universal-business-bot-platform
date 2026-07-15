import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/business_strategy.dart';

class BusinessStrategyScreen extends StatelessWidget {
  const BusinessStrategyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final strategy = state.businessStrategy;
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.businessStrategyTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.businessStrategySubtitle(state.company.name),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _openGoalDialog(context, state),
                icon: const Icon(Icons.add),
                label: Text(l.businessGoalAdd),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _StrategyOverviewCard(strategy: strategy),
          const SizedBox(height: 24),
          _StrategyFlowCard(),
          const SizedBox(height: 24),
          Text(
            l.businessGoalsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (strategy.goals.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(l.businessGoalsEmpty),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 980 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 352,
                  ),
                  itemCount: strategy.goals.length,
                  itemBuilder: (context, index) {
                    return _GoalCard(entry: strategy.goals[index]);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _openGoalDialog(BuildContext context, AppState state) async {
    final goal = await showDialog<BusinessGoal>(
      context: context,
      builder: (_) => const _GoalDialog(),
    );
    if (goal != null) state.addBusinessGoal(goal);
  }
}

class _StrategyOverviewCard extends StatelessWidget {
  final BusinessStrategySnapshot strategy;

  const _StrategyOverviewCard({required this.strategy});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mainGoal = strategy.mainGoal;
    final recommendation = strategy.nextRecommendation;
    final progress = (strategy.averageProgress * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 680;
            final left = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.businessActiveGoals(strategy.activeGoalCount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    minHeight: 12,
                    value: strategy.averageProgress.clamp(0, 1),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l.businessAverageProgress(progress),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
            final right = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainGoal == null
                      ? l.businessNoMainGoal
                      : l.businessMainGoal(mainGoal.goal.title),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation == null
                      ? l.businessNoRecommendation
                      : l.businessGoalRecommendation(
                          _areaLabel(l, recommendation.area),
                          recommendation.goal.title,
                        ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (recommendation != null) ...[
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.go(recommendation.route),
                    child: Text(l.projectOpenNow),
                  ),
                ],
              ],
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [left, const SizedBox(height: 18), right],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: left),
                const SizedBox(width: 24),
                Expanded(child: right),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StrategyFlowCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final items = [
      (Icons.flag_outlined, l.businessFlowGoal),
      (Icons.campaign_outlined, l.businessFlowMarketing),
      (Icons.smart_toy_outlined, l.businessFlowBot),
      (Icons.library_books_outlined, l.businessFlowKnowledge),
      (Icons.fact_check_outlined, l.businessFlowAudit),
      (Icons.rate_review_outlined, l.businessFlowReview),
      (Icons.bar_chart_outlined, l.businessFlowControlling),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _FlowChip(icon: items[i].$1, label: items[i].$2),
              if (i < items.length - 1)
                Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: Theme.of(context).colorScheme.outline,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final BusinessGoalProgress entry;

  const _GoalCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final goal = entry.goal;
    final percent = (entry.progress * 100).round();
    final color = _priorityColor(goal.priority);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withAlpha(22),
                  child: Icon(Icons.flag_outlined, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.description,
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
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: entry.progress.clamp(0, 1),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Pill(label: '$percent%', color: Colors.indigo),
                _Pill(label: _priorityLabel(l, goal.priority), color: color),
                _Pill(
                  label: _statusLabel(l, goal.status),
                  color: _statusColor(goal.status),
                ),
                _Pill(label: goal.owner, color: Colors.blueGrey),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.moduleContributions.entries.map((module) {
                  return _Pill(
                    label:
                        '${_areaLabel(l, module.key)} ${(module.value * 100).round()}%',
                    color: Colors.teal,
                  );
                }).toList(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_formatDate(goal.startDate)} - ${_formatDate(goal.targetDate)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final updated = await showDialog<BusinessGoal>(
                      context: context,
                      builder: (_) => _GoalDialog(goal: goal),
                    );
                    if (updated != null) state.updateBusinessGoal(updated);
                  },
                  child: Text(l.btnEdit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalDialog extends StatefulWidget {
  final BusinessGoal? goal;

  const _GoalDialog({this.goal});

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _ownerController;
  late final TextEditingController _commentController;
  late BusinessGoalPriority _priority;
  late BusinessGoalStatus _status;
  late Set<BusinessGoalArea> _areas;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _titleController = TextEditingController(text: goal?.title ?? '');
    _descriptionController = TextEditingController(
      text: goal?.description ?? '',
    );
    _ownerController = TextEditingController(text: goal?.owner ?? '');
    _commentController = TextEditingController(text: goal?.comment ?? '');
    _priority = goal?.priority ?? BusinessGoalPriority.medium;
    _status = goal?.status ?? BusinessGoalStatus.planned;
    _areas = {...?goal?.linkedAreas};
    if (_areas.isEmpty) {
      _areas = {
        BusinessGoalArea.marketing,
        BusinessGoalArea.knowledgeBase,
        BusinessGoalArea.projectStatus,
      };
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ownerController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.goal == null ? l.businessGoalAdd : l.businessGoalEdit),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l.businessGoalTitle),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l.businessGoalDescription,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ownerController,
                decoration: InputDecoration(labelText: l.businessGoalOwner),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<BusinessGoalPriority>(
                initialValue: _priority,
                decoration: InputDecoration(labelText: l.businessGoalPriority),
                items: BusinessGoalPriority.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(_priorityLabel(l, value)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<BusinessGoalStatus>(
                initialValue: _status,
                decoration: InputDecoration(labelText: l.businessGoalStatus),
                items: BusinessGoalStatus.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(_statusLabel(l, value)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l.businessGoalLinkedAreas),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: BusinessGoalArea.values.map((area) {
                  final selected = _areas.contains(area);
                  return FilterChip(
                    label: Text(_areaLabel(l, area)),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _areas.add(area);
                        } else if (_areas.length > 1) {
                          _areas.remove(area);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                maxLines: 2,
                decoration: InputDecoration(labelText: l.businessGoalComment),
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
            final title = _titleController.text.trim();
            if (title.isEmpty) return;
            final now = DateTime.now();
            Navigator.pop(
              context,
              BusinessGoal(
                id: widget.goal?.id ?? 'goal_${now.microsecondsSinceEpoch}',
                title: title,
                description: _descriptionController.text.trim(),
                priority: _priority,
                startDate: widget.goal?.startDate ?? now,
                targetDate:
                    widget.goal?.targetDate ??
                    now.add(const Duration(days: 90)),
                status: _status,
                owner: _ownerController.text.trim().isEmpty
                    ? l.businessGoalDefaultOwner
                    : _ownerController.text.trim(),
                comment: _commentController.text.trim(),
                linkedAreas: _areas.toList(),
              ),
            );
          },
          child: Text(l.btnSave),
        ),
      ],
    );
  }
}

class _FlowChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FlowChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium),
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

String _areaLabel(AppLocalizations l, BusinessGoalArea area) {
  return switch (area) {
    BusinessGoalArea.marketing => l.businessAreaMarketing,
    BusinessGoalArea.audit => l.businessAreaAudit,
    BusinessGoalArea.knowledgeBase => l.businessAreaKnowledge,
    BusinessGoalArea.bot => l.businessAreaBot,
    BusinessGoalArea.humanReview => l.businessAreaReview,
    BusinessGoalArea.sources => l.businessAreaSources,
    BusinessGoalArea.companyProfile => l.businessAreaCompany,
    BusinessGoalArea.projectStatus => l.businessAreaProject,
    BusinessGoalArea.controlling => l.businessAreaControlling,
  };
}

String _priorityLabel(AppLocalizations l, BusinessGoalPriority priority) {
  return switch (priority) {
    BusinessGoalPriority.low => l.projectPriorityLow,
    BusinessGoalPriority.medium => l.projectPriorityMedium,
    BusinessGoalPriority.high => l.projectPriorityHigh,
  };
}

String _statusLabel(AppLocalizations l, BusinessGoalStatus status) {
  return switch (status) {
    BusinessGoalStatus.notStarted => l.businessStatusNotStarted,
    BusinessGoalStatus.planned => l.businessStatusPlanned,
    BusinessGoalStatus.inProgress => l.businessStatusInProgress,
    BusinessGoalStatus.achieved => l.businessStatusAchieved,
    BusinessGoalStatus.paused => l.businessStatusPaused,
    BusinessGoalStatus.canceled => l.businessStatusCanceled,
  };
}

Color _priorityColor(BusinessGoalPriority priority) {
  return switch (priority) {
    BusinessGoalPriority.high => Colors.red,
    BusinessGoalPriority.medium => Colors.orange,
    BusinessGoalPriority.low => Colors.blueGrey,
  };
}

Color _statusColor(BusinessGoalStatus status) {
  return switch (status) {
    BusinessGoalStatus.notStarted => Colors.grey,
    BusinessGoalStatus.planned => Colors.indigo,
    BusinessGoalStatus.inProgress => Colors.blue,
    BusinessGoalStatus.achieved => Colors.green,
    BusinessGoalStatus.paused => Colors.orange,
    BusinessGoalStatus.canceled => Colors.red,
  };
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
}
