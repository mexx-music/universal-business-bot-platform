import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/project_status/project_phase_timeline.dart';
import '../../widgets/project_status/project_progress_card.dart';
import '../../widgets/project_status/project_recommendation_card.dart';
import '../../widgets/project_status/project_task_list.dart';

class ProjectStatusScreen extends StatelessWidget {
  const ProjectStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final status = state.projectStatus;
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l.projectStatusTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.projectStatusSubtitle(state.company.name),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final timeline = ProjectPhaseTimeline(status: status);
              final rightColumn = Column(
                children: [
                  ProjectProgressCard(status: status),
                  const SizedBox(height: 16),
                  ProjectTaskList(status: status),
                ],
              );
              if (!wide) {
                return Column(
                  children: [timeline, const SizedBox(height: 16), rightColumn],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: timeline),
                  const SizedBox(width: 16),
                  Expanded(flex: 6, child: rightColumn),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            l.projectRecommendationsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (status.recommendations.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.projectRecommendationsEmpty)),
                  ],
                ),
              ),
            )
          else
            ...status.recommendations.map(
              (recommendation) =>
                  ProjectRecommendationCard(recommendation: recommendation),
            ),
        ],
      ),
    );
  }
}
