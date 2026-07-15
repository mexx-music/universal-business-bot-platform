import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/project_status.dart';
import 'project_status_helpers.dart';

class ProjectProgressCard extends StatelessWidget {
  final ProjectStatusSnapshot status;
  final bool compact;

  const ProjectProgressCard({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final percent = (status.progress * 100).round();
    final next = status.nextRecommendation;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.route_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.projectStatusTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$percent%',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: status.progress.clamp(0, 1),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  icon: Icons.check_circle_outline,
                  label: l.projectCompletedTasks(status.completedTaskCount),
                  color: Colors.green,
                ),
                _MetricChip(
                  icon: Icons.pending_actions_outlined,
                  label: l.projectOpenTasks(status.openTaskCount),
                  color: Colors.orange,
                ),
                _MetricChip(
                  icon: Icons.priority_high,
                  label: l.projectHighPriorityTasks(
                    status.highPriorityOpenCount,
                  ),
                  color: status.highPriorityOpenCount > 0
                      ? Colors.red
                      : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l.projectCurrentPhase(projectPhaseLabel(l, status.currentPhase)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (next != null) ...[
              const SizedBox(height: 10),
              Text(
                '${l.projectNextStep}: ${projectTaskTitle(l, next.type)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
