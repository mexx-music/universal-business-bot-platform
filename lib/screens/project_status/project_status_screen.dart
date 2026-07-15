import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/business_intelligence.dart';
import '../../models/business_strategy.dart';
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
    final businessStrategy = state.businessStrategy;
    final businessIntelligence = state.businessIntelligence;
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
          _ProjectBusinessGoalCard(strategy: businessStrategy),
          const SizedBox(height: 24),
          _ProjectBusinessIntelligenceCard(snapshot: businessIntelligence),
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

class _ProjectBusinessIntelligenceCard extends StatelessWidget {
  final BusinessIntelligenceSnapshot snapshot;

  const _ProjectBusinessIntelligenceCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final last = snapshot.lastImprovement;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            final content = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.insights_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.projectLatestImprovementTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        last == null ? l.businessNoActivity : last.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.projectSinceLastWeek(snapshot.weeklySummary),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
            final action = FilledButton(
              onPressed: () => context.go('/business-intelligence'),
              child: Text(l.projectOpenNow),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [content, const SizedBox(height: 16), action],
              );
            }
            return Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 16),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProjectBusinessGoalCard extends StatelessWidget {
  final BusinessStrategySnapshot strategy;

  const _ProjectBusinessGoalCard({required this.strategy});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mainGoal = strategy.mainGoal;
    if (mainGoal == null) return const SizedBox.shrink();
    final percent = (mainGoal.progress * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.projectMainGoalTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mainGoal.goal.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: mainGoal.progress.clamp(0, 1),
              ),
            ),
            const SizedBox(height: 8),
            Text(l.businessAverageProgress(percent)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mainGoal.moduleContributions.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_areaLabel(l, entry.key)} ${(entry.value * 100).round()}%',
                    style: theme.textTheme.labelMedium,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
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
}
