import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';
import '../../models/bot_configuration.dart';
import '../../models/bot_question_log.dart';
import '../../models/business_intelligence.dart';
import '../../models/business_strategy.dart';
import '../../models/intake_session.dart';
import '../../models/marketing_strategy.dart';
import '../../models/project_status.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/project_status/project_status_helpers.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final metrics = state.dashboardMetrics;

    final reviewOpen = metrics.reviewOpen;
    final reviewedBotQuestions = metrics.reviewedBotQuestions;
    final redirects = metrics.redirects;
    final auditPct = metrics.auditPct;
    final auditMissing = metrics.auditMissing;
    final auditPartial = metrics.auditPartial;
    final auditComplete = metrics.auditComplete;
    final auditHighPriorityOpen = metrics.auditHighPriorityOpen;
    final profileStatus = state.companyProfileStatus;
    final botStatus = metrics.botStatus;
    final sourcesTotal = metrics.sourcesTotal;
    final sourcesNew = metrics.sourcesNew;
    final intakeSession = metrics.intakeSession;
    final projectStatus = metrics.projectStatus;
    final marketingStrategy = metrics.marketingStrategy;
    final businessStrategy = metrics.businessStrategy;
    final businessIntelligence = metrics.businessIntelligence;

    final greenCount = metrics.greenKnowledgeCount;
    final yellowCount = metrics.yellowKnowledgeCount;
    final redCount = metrics.redKnowledgeCount;
    final total = metrics.totalKnowledgeCount;
    final recommendations = _buildRecommendations(context, state);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l.navDashboard,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.dashboardSubtitle(state.company.name),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),

          // ── KPI-Kacheln ──────────────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 800
                  ? 4
                  : constraints.maxWidth > 500
                  ? 2
                  : 1;
              final cards = [
                StatCard(
                  label: l.statKnowledgeEntries,
                  value: '$total',
                  icon: Icons.library_books,
                  color: Colors.indigo,
                ),
                StatCard(
                  label: l.statReviewOpen,
                  value: '$reviewOpen',
                  icon: Icons.rate_review_outlined,
                  color: reviewOpen > 0 ? Colors.orange : Colors.teal,
                ),
                StatCard(
                  label: l.statRedirects,
                  value: '$redirects',
                  icon: Icons.block_outlined,
                  color: redirects > 0 ? Colors.red : Colors.green,
                ),
                StatCard(
                  label: l.statReviewedBotQuestions,
                  value: '$reviewedBotQuestions',
                  icon: Icons.verified_outlined,
                  color: Colors.blue,
                ),
                StatCard(
                  label: l.statAuditScore,
                  value: '$auditPct%',
                  icon: Icons.fact_check_outlined,
                  color: auditPct >= 80
                      ? Colors.green
                      : auditPct >= 50
                      ? Colors.orange
                      : Colors.red,
                ),
                StatCard(
                  label: l.statAuditMissing,
                  value: '$auditMissing',
                  icon: Icons.cancel_outlined,
                  color: auditMissing > 0 ? Colors.red : Colors.green,
                ),
                StatCard(
                  label: l.statAuditPartial,
                  value: '$auditPartial',
                  icon: Icons.pending_outlined,
                  color: auditPartial > 0 ? Colors.orange : Colors.green,
                ),
                StatCard(
                  label: l.statAuditComplete,
                  value: '$auditComplete',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                StatCard(
                  label: l.statAuditHighPriorityOpen,
                  value: '$auditHighPriorityOpen',
                  icon: Icons.priority_high,
                  color: auditHighPriorityOpen > 0 ? Colors.red : Colors.green,
                ),
                StatCard(
                  label: l.statCompanyProfile,
                  value: _profileStatusLabel(l, profileStatus),
                  icon: Icons.business_outlined,
                  color: switch (profileStatus) {
                    CompanyProfileStatus.complete => Colors.green,
                    CompanyProfileStatus.partial => Colors.orange,
                    CompanyProfileStatus.incomplete => Colors.red,
                  },
                ),
                StatCard(
                  label: l.statBotStatus,
                  value: _botStatusLabel(l, botStatus),
                  icon: Icons.smart_toy_outlined,
                  color: switch (botStatus) {
                    BotStatus.draft => Colors.orange,
                    BotStatus.testReady => Colors.blue,
                    BotStatus.active => Colors.green,
                  },
                ),
                StatCard(
                  label: l.statSourcesTotal,
                  value: '$sourcesTotal',
                  icon: Icons.source_outlined,
                  color: Colors.teal,
                ),
                StatCard(
                  label: l.statSourcesNew,
                  value: '$sourcesNew',
                  icon: Icons.fiber_new_outlined,
                  color: sourcesNew > 0 ? Colors.orange : Colors.green,
                ),
                StatCard(
                  label: l.statIntakeStatus,
                  value: _intakeStatusLabel(l, intakeSession),
                  icon: Icons.assignment_outlined,
                  color: intakeSession?.importedAt != null
                      ? Colors.green
                      : switch (intakeSession?.status) {
                          IntakeStatus.completed => Colors.blue,
                          IntakeStatus.inProgress => Colors.orange,
                          IntakeStatus.draft => Colors.grey,
                          null => Colors.red,
                        },
                ),
              ];
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 152,
                ),
                itemCount: cards.length,
                itemBuilder: (_, i) => cards[i],
              );
            },
          ),
          const SizedBox(height: 28),

          _DashboardProjectStatusCard(status: projectStatus),
          const SizedBox(height: 28),

          _DashboardBusinessIntelligenceCard(snapshot: businessIntelligence),
          const SizedBox(height: 28),

          _DashboardBusinessStrategyCard(strategy: businessStrategy),
          const SizedBox(height: 28),

          _DashboardMarketingCard(strategy: marketingStrategy),
          const SizedBox(height: 28),

          Text(
            l.dashboardNextStepsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (recommendations.isEmpty)
            _RecommendationCard(
              icon: Icons.check_circle_outline,
              title: l.dashboardRecommendationAllDoneTitle,
              description: l.dashboardRecommendationAllDoneDescription,
              color: Colors.green,
              actionLabel: l.navDashboard,
              onTap: null,
            )
          else
            ...recommendations.map((item) => _RecommendationCard(item: item)),
          const SizedBox(height: 28),

          // ── Risiko-Verteilung ────────────────────────────────────────
          Text(
            l.dashboardRiskTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (total > 0)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          _RiskBar(
                            count: greenCount,
                            total: total,
                            color: Colors.green,
                          ),
                          _RiskBar(
                            count: yellowCount,
                            total: total,
                            color: Colors.orange,
                          ),
                          _RiskBar(
                            count: redCount,
                            total: total,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _RiskLegend(
                        color: Colors.green,
                        label: l.riskGreen,
                        count: greenCount,
                      ),
                      _RiskLegend(
                        color: Colors.orange,
                        label: l.riskYellow,
                        count: yellowCount,
                      ),
                      _RiskLegend(
                        color: Colors.red,
                        label: l.riskRed,
                        count: redCount,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Letzte Bot-Anfragen ──────────────────────────────────────
          Row(
            children: [
              Text(
                l.dashboardRecentRequests,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                l.dashboardTotal(state.botLogs.length),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.botLogs.isEmpty)
            _EmptyHint(message: l.dashboardNoLogs)
          else
            ...state.botLogs.reversed.take(5).map((log) {
              final status = log.reviewStatus;
              final (icon, iconColor, bgColor) = switch ((
                log.redirected,
                log.matched,
              )) {
                (true, _) => (
                  Icons.block,
                  Colors.red,
                  Colors.red.withAlpha(25),
                ),
                (_, true) => (
                  Icons.check,
                  Colors.green,
                  Colors.green.withAlpha(25),
                ),
                _ => (
                  Icons.help_outline,
                  Colors.grey,
                  Colors.grey.withAlpha(20),
                ),
              };
              final subtitle = log.redirected
                  ? l.riskRed
                  : log.matched
                  ? (log.answer ?? '')
                  : l.logNoAnswer;
              final dateStr =
                  '${log.timestamp.day.toString().padLeft(2, '0')}.'
                  '${log.timestamp.month.toString().padLeft(2, '0')}.'
                  '${log.timestamp.year}';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: bgColor,
                        child: Icon(icon, color: iconColor, size: 18),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              log.question,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: log.redirected
                                    ? Colors.red
                                    : log.matched
                                    ? theme.colorScheme.onSurfaceVariant
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (status != ReviewStatus.closed) ...[
                              const SizedBox(height: 4),
                              _ReviewStatusBadge(log: log),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(dateStr, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  List<_Recommendation> _buildRecommendations(
    BuildContext context,
    AppState state,
  ) {
    final l = AppLocalizations.of(context)!;
    final recommendations = <_Recommendation>[];

    if (state.auditHighPriorityMissingCount > 0) {
      recommendations.add(
        _Recommendation(
          icon: Icons.priority_high,
          title: l.dashboardRecommendationAuditTitle,
          description: l.dashboardRecommendationAuditDescription(
            state.auditHighPriorityMissingCount,
          ),
          color: Colors.red,
          actionLabel: l.navAudit,
          path: '/audit',
        ),
      );
    }

    if (state.selectedIntakeSession == null) {
      recommendations.add(
        _Recommendation(
          icon: Icons.assignment_outlined,
          title: l.dashboardRecommendationIntakeTitle,
          description: l.dashboardRecommendationIntakeDescription,
          color: Colors.deepPurple,
          actionLabel: l.navIntake,
          path: '/intake',
        ),
      );
    }

    if (state.selectedIntakeSession != null &&
        state.selectedIntakeSession!.status == IntakeStatus.completed &&
        state.selectedIntakeSession!.importedAt == null) {
      recommendations.add(
        _Recommendation(
          icon: Icons.move_down_outlined,
          title: l.dashboardRecommendationIntakeImportTitle,
          description: l.dashboardRecommendationIntakeImportDescription,
          color: Colors.deepPurple,
          actionLabel: l.navIntake,
          path: '/intake',
        ),
      );
    }

    if (state.knowledgeEntries.length < 12) {
      recommendations.add(
        _Recommendation(
          icon: Icons.library_add_outlined,
          title: l.dashboardRecommendationKnowledgeTitle,
          description: l.dashboardRecommendationKnowledgeDescription(
            state.knowledgeEntries.length,
          ),
          color: Colors.indigo,
          actionLabel: l.navKnowledge,
          path: '/knowledge',
        ),
      );
    }

    if (state.newSourceMaterialCount > 0) {
      recommendations.add(
        _Recommendation(
          icon: Icons.source_outlined,
          title: l.dashboardRecommendationSourcesTitle,
          description: l.dashboardRecommendationSourcesDescription(
            state.newSourceMaterialCount,
          ),
          color: Colors.teal,
          actionLabel: l.navSources,
          path: '/sources',
        ),
      );
    }

    if (state.openReviewCount > 0) {
      recommendations.add(
        _Recommendation(
          icon: Icons.rate_review_outlined,
          title: l.dashboardRecommendationReviewTitle,
          description: l.dashboardRecommendationReviewDescription(
            state.openReviewCount,
          ),
          color: Colors.orange,
          actionLabel: l.navReview,
          path: '/review',
        ),
      );
    }

    if (state.companyProfileStatus != CompanyProfileStatus.complete) {
      recommendations.add(
        _Recommendation(
          icon: Icons.business_outlined,
          title: l.dashboardRecommendationProfileTitle,
          description: l.dashboardRecommendationProfileDescription,
          color: Colors.teal,
          actionLabel: l.navCompany,
          path: '/company',
        ),
      );
    }

    if (state.botConfiguration.status == BotStatus.draft) {
      recommendations.add(
        _Recommendation(
          icon: Icons.tune_outlined,
          title: l.dashboardRecommendationBotSettingsTitle,
          description: l.dashboardRecommendationBotSettingsDescription,
          color: Colors.blue,
          actionLabel: l.navBotSettings,
          path: '/bot-settings',
        ),
      );
    }

    return recommendations;
  }
}

class _Recommendation {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String actionLabel;
  final String path;

  const _Recommendation({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.actionLabel,
    required this.path,
  });
}

class _RecommendationCard extends StatelessWidget {
  final _Recommendation? item;
  final IconData? icon;
  final String? title;
  final String? description;
  final Color? color;
  final String? actionLabel;
  final VoidCallback? onTap;

  const _RecommendationCard({
    this.item,
    this.icon,
    this.title,
    this.description,
    this.color,
    this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedIcon = item?.icon ?? icon!;
    final resolvedTitle = item?.title ?? title!;
    final resolvedDescription = item?.description ?? description!;
    final resolvedColor = item?.color ?? color!;
    final resolvedActionLabel = item?.actionLabel ?? actionLabel!;
    final resolvedOnTap = item != null ? () => context.go(item!.path) : onTap;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 460;
            final textBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resolvedTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  resolvedDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );

            final action = resolvedOnTap == null
                ? null
                : TextButton(
                    onPressed: resolvedOnTap,
                    child: Text(resolvedActionLabel),
                  );

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: resolvedColor.withAlpha(28),
                  child: Icon(resolvedIcon, color: resolvedColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: compact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textBlock,
                            if (action != null) ...[
                              const SizedBox(height: 8),
                              action,
                            ],
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: textBlock),
                            if (action != null) ...[
                              const SizedBox(width: 12),
                              action,
                            ],
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashboardProjectStatusCard extends StatelessWidget {
  final ProjectStatusSnapshot status;

  const _DashboardProjectStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final next = status.nextRecommendation;
    final percent = (status.progress * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            final progressBlock = Column(
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
                        color: theme.colorScheme.primary,
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
                    value: status.progress.clamp(0.0, 1.0),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  next == null
                      ? l.projectRecommendationsEmpty
                      : '${l.projectNextStep}: ${projectTaskTitle(l, next.type)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );

            final metrics = Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ProjectMetric(
                  label: l.projectOpenTasks(status.openTaskCount),
                  icon: Icons.pending_actions_outlined,
                  color: Colors.orange,
                ),
                _ProjectMetric(
                  label: l.projectHighPriorityTasks(
                    status.highPriorityOpenCount,
                  ),
                  icon: Icons.priority_high,
                  color: status.highPriorityOpenCount > 0
                      ? Colors.red
                      : Colors.green,
                ),
              ],
            );

            final action = FilledButton(
              onPressed: () => context.go('/project-status'),
              child: Text(l.projectOpenNow),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  progressBlock,
                  const SizedBox(height: 16),
                  metrics,
                  const SizedBox(height: 16),
                  action,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 3, child: progressBlock),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: metrics),
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

class _DashboardBusinessIntelligenceCard extends StatelessWidget {
  final BusinessIntelligenceSnapshot snapshot;

  const _DashboardBusinessIntelligenceCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final last = snapshot.lastImprovement;
    BusinessHighlight? biggest;
    for (final item in snapshot.highlights) {
      if (item.type == BusinessHighlightType.biggestProgress) {
        biggest = item;
        break;
      }
    }
    final firstSignal = snapshot.developmentSignals.isEmpty
        ? null
        : snapshot.developmentSignals.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.indigo.withAlpha(26),
                      child: const Icon(
                        Icons.insights_outlined,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.businessIntelligenceTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  last == null
                      ? l.businessNoActivity
                      : l.businessDashboardLastActivity(last.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ProjectMetric(
                      label: biggest == null
                          ? l.businessBiggestProgressNone
                          : l.businessDashboardBiggestProgress(
                              biggest.title,
                              biggest.description,
                            ),
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                    if (firstSignal != null)
                      _ProjectMetric(
                        label: l.businessDashboardDevelopment(
                          firstSignal.area,
                          firstSignal.value,
                        ),
                        icon: Icons.auto_graph,
                        color: firstSignal.positive
                            ? Colors.green
                            : Colors.orange,
                      ),
                  ],
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

class _DashboardBusinessStrategyCard extends StatelessWidget {
  final BusinessStrategySnapshot strategy;

  const _DashboardBusinessStrategyCard({required this.strategy});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mainGoal = strategy.mainGoal;
    final recommendation = strategy.nextRecommendation;
    final percent = (strategy.averageProgress * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.flag_outlined,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.businessActiveGoals(strategy.activeGoalCount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: strategy.averageProgress.clamp(0.0, 1.0),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  mainGoal == null
                      ? l.businessNoMainGoal
                      : l.businessMainGoal(mainGoal.goal.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (recommendation != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l.businessDashboardNextAction(recommendation.goal.title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            );
            final action = FilledButton(
              onPressed: () => context.go('/business-strategy'),
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

class _DashboardMarketingCard extends StatelessWidget {
  final MarketingStrategySnapshot strategy;

  const _DashboardMarketingCard({required this.strategy});

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
                      backgroundColor: color.withAlpha(22),
                      child: Icon(Icons.campaign_outlined, color: color),
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
                _ProjectMetric(
                  label: l.marketingOpenActions(strategy.openActionCount),
                  icon: Icons.pending_actions_outlined,
                  color: Colors.orange,
                ),
                _ProjectMetric(
                  label: l.marketingRunningActions(
                    strategy.inProgressActionCount,
                  ),
                  icon: Icons.play_circle_outline,
                  color: Colors.blue,
                ),
                _ProjectMetric(
                  label: l.marketingCompletedActions(
                    strategy.completedActionCount,
                  ),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ],
            );

            final action = FilledButton(
              onPressed: () => context.go('/marketing-strategy'),
              child: Text(l.projectOpenNow),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  scoreBlock,
                  const SizedBox(height: 16),
                  metrics,
                  const SizedBox(height: 16),
                  action,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 3, child: scoreBlock),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: metrics),
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

class _ProjectMetric extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _ProjectMetric({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(48)),
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

class _RiskBar extends StatelessWidget {
  final int count;
  final int total;
  final Color color;

  const _RiskBar({
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Flexible(
      flex: count,
      child: Container(height: 12, color: color),
    );
  }
}

String _profileStatusLabel(AppLocalizations l, CompanyProfileStatus status) {
  return switch (status) {
    CompanyProfileStatus.complete => l.companyProfileComplete,
    CompanyProfileStatus.partial => l.companyProfilePartial,
    CompanyProfileStatus.incomplete => l.companyProfileIncomplete,
  };
}

String _botStatusLabel(AppLocalizations l, BotStatus status) {
  return switch (status) {
    BotStatus.draft => l.botStatusDraft,
    BotStatus.testReady => l.botStatusTestReady,
    BotStatus.active => l.botStatusActive,
  };
}

String _intakeStatusLabel(AppLocalizations l, IntakeSession? session) {
  if (session == null) return l.intakeStatusNotStarted;
  if (session.importedAt != null) return l.intakeImportStatusImported;
  return switch (session.status) {
    IntakeStatus.draft => l.intakeStatusDraft,
    IntakeStatus.inProgress => l.intakeStatusInProgress,
    IntakeStatus.completed => l.intakeImportStatusReady,
  };
}

class _RiskLegend extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _RiskLegend({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ReviewStatusBadge extends StatelessWidget {
  final BotQuestionLog log;

  const _ReviewStatusBadge({required this.log});

  @override
  Widget build(BuildContext context) {
    final status = log.reviewStatus;
    final reason = log.reviewReason;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Badge(
          label: reviewStatusLabel(context, status),
          color: status.color,
          icon: status.icon,
        ),
        if (reason != null) ...[
          const SizedBox(width: 4),
          _Badge(
            label: reviewReasonLabel(context, reason),
            color: reason.color,
            icon: reason.icon,
          ),
        ],
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Badge({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String message;

  const _EmptyHint({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
