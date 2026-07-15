import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/project_status.dart';
import 'project_status_helpers.dart';

class ProjectPhaseTimeline extends StatelessWidget {
  final ProjectStatusSnapshot status;

  const ProjectPhaseTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const phases = [
      ProjectPhase.company,
      ProjectPhase.knowledge,
      ProjectPhase.ai,
      ProjectPhase.marketing,
      ProjectPhase.controlling,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.projectPhasesTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...phases.map((phase) {
              final phaseItems = status.items
                  .where((item) => item.phase == phase)
                  .toList();
              final completed = phaseItems
                  .where((item) => item.isComplete)
                  .length;
              final isCurrent = status.currentPhase == phase;
              final isComplete =
                  phaseItems.isNotEmpty && completed == phaseItems.length;
              final color = isComplete
                  ? Colors.green
                  : isCurrent
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: color.withAlpha(isCurrent ? 34 : 22),
                          child: Icon(
                            isComplete ? Icons.check : _phaseIcon(phase),
                            size: 17,
                            color: color,
                          ),
                        ),
                        if (phase != phases.last)
                          Container(
                            width: 2,
                            height: 36,
                            color: color.withAlpha(50),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    projectPhaseLabel(l, phase),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isCurrent
                                          ? theme.colorScheme.primary
                                          : null,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$completed/${phaseItems.length}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _phaseDescription(l, phase),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _phaseIcon(ProjectPhase phase) {
    return switch (phase) {
      ProjectPhase.company => Icons.business_outlined,
      ProjectPhase.knowledge => Icons.library_books_outlined,
      ProjectPhase.ai => Icons.smart_toy_outlined,
      ProjectPhase.marketing => Icons.campaign_outlined,
      ProjectPhase.controlling => Icons.bar_chart_outlined,
    };
  }

  String _phaseDescription(AppLocalizations l, ProjectPhase phase) {
    return switch (phase) {
      ProjectPhase.company => l.projectPhaseCompanyDescription,
      ProjectPhase.knowledge => l.projectPhaseKnowledgeDescription,
      ProjectPhase.ai => l.projectPhaseAiDescription,
      ProjectPhase.marketing => l.projectPhaseMarketingDescription,
      ProjectPhase.controlling => l.projectPhaseControllingDescription,
    };
  }
}
