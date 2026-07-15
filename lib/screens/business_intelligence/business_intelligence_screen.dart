import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/business_intelligence.dart';

class BusinessIntelligenceScreen extends StatelessWidget {
  const BusinessIntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final snapshot = state.businessIntelligence;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l.businessIntelligenceTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.businessIntelligenceSubtitle(state.company.name),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _ResponsiveOverview(snapshot: snapshot),
          const SizedBox(height: 24),
          _SectionTitle(title: l.businessDevelopmentTitle),
          const SizedBox(height: 12),
          _DevelopmentGrid(signals: snapshot.developmentSignals),
          const SizedBox(height: 24),
          _SectionTitle(title: l.businessKpiTitle),
          const SizedBox(height: 12),
          _KpiGrid(trends: snapshot.kpiTrends),
          const SizedBox(height: 24),
          _SectionTitle(title: l.businessTimelineTitle),
          const SizedBox(height: 12),
          if (snapshot.timeline.isEmpty)
            _EmptyCard(message: l.businessNoActivity)
          else
            ...snapshot.timeline.map((event) => _TimelineEventCard(event)),
        ],
      ),
    );
  }
}

class _ResponsiveOverview extends StatelessWidget {
  final BusinessIntelligenceSnapshot snapshot;

  const _ResponsiveOverview({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final monthly = _MonthlyOverviewCard(snapshot.monthlyOverview);
        final highlights = _HighlightsCard(snapshot.highlights);
        final last = _LastImprovementCard(snapshot);

        if (!wide) {
          return Column(
            children: [
              last,
              const SizedBox(height: 16),
              monthly,
              const SizedBox(height: 16),
              highlights,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: last),
            const SizedBox(width: 16),
            Expanded(child: monthly),
            const SizedBox(width: 16),
            Expanded(child: highlights),
          ],
        );
      },
    );
  }
}

class _LastImprovementCard extends StatelessWidget {
  final BusinessIntelligenceSnapshot snapshot;

  const _LastImprovementCard(this.snapshot);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final event = snapshot.lastImprovement;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              icon: Icons.auto_graph_outlined,
              title: l.businessLastActivity,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              event?.title ?? l.businessNoActivity,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              event == null
                  ? l.businessNoActivity
                  : '${_eventTypeLabel(l, event.type)} · ${_dateLabel(event.date)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.projectSinceLastWeek(snapshot.weeklySummary),
              style: theme.textTheme.bodyMedium,
            ),
            if (event != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.go(event.route),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l.projectOpenNow),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MonthlyOverviewCard extends StatelessWidget {
  final BusinessMonthlyOverview overview;

  const _MonthlyOverviewCard(this.overview);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = [
      (
        Icons.change_circle_outlined,
        l.businessMonthlyChanges,
        '${overview.changeCount}',
      ),
      (
        Icons.source_outlined,
        l.businessMonthlySources,
        '${overview.newSources}',
      ),
      (
        Icons.library_add_outlined,
        l.businessMonthlyKnowledge,
        '${overview.newKnowledgeEntries}',
      ),
      (
        Icons.campaign_outlined,
        l.businessMonthlyMarketingCompleted,
        '${overview.completedMarketingActions}',
      ),
      (
        Icons.flag_outlined,
        l.businessMonthlyGoalsAchieved,
        '${overview.achievedGoals}',
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              icon: Icons.calendar_month_outlined,
              title: l.businessMonthlyTitle,
              color: Colors.indigo,
            ),
            const SizedBox(height: 12),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(item.$1, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item.$2)),
                    Text(
                      item.$3,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HighlightsCard extends StatelessWidget {
  final List<BusinessHighlight> highlights;

  const _HighlightsCard(this.highlights);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              icon: Icons.tips_and_updates_outlined,
              title: l.businessHighlightsTitle,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            if (highlights.isEmpty)
              Text(l.businessNoActivity)
            else
              for (final highlight in highlights.take(5))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    _highlightTypeLabel(l, highlight.type),
                    style: theme.textTheme.labelLarge,
                  ),
                  subtitle: Text(
                    '${highlight.title} · ${highlight.description}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(highlight.route),
                ),
          ],
        ),
      ),
    );
  }
}

class _DevelopmentGrid extends StatelessWidget {
  final List<BusinessDevelopmentSignal> signals;

  const _DevelopmentGrid({required this.signals});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 680
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 126,
          ),
          itemCount: signals.length,
          itemBuilder: (context, index) => _DevelopmentCard(signals[index]),
        );
      },
    );
  }
}

class _DevelopmentCard extends StatelessWidget {
  final BusinessDevelopmentSignal signal;

  const _DevelopmentCard(this.signal);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = signal.positive ? Colors.green : Colors.orange;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(signal.route),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha(30),
                child: Icon(
                  signal.positive
                      ? Icons.trending_up
                      : Icons.warning_amber_outlined,
                  color: color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      signal.area,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      signal.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final List<BusinessKpiTrend> trends;

  const _KpiGrid({required this.trends});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 680
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 132,
          ),
          itemCount: trends.length,
          itemBuilder: (context, index) => _KpiCard(trends[index]),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final BusinessKpiTrend trend;

  const _KpiCard(this.trend);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = trend.positive ? Colors.green : Colors.orange;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(trend.route),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _kpiLabel(l, trend.type),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                trend.currentValue,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    trend.positive ? Icons.north_east : Icons.priority_high,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    trend.changeValue,
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineEventCard extends StatelessWidget {
  final BusinessTimelineEvent event;

  const _TimelineEventCard(this.event);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = _priorityColor(event.priority);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go(event.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha(28),
                child: Icon(_categoryIcon(event.category), color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _eventTypeLabel(l, event.type),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(_categoryLabel(l, event.category)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.title,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (event.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _dateLabel(event.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _CardHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withAlpha(28),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(20), child: Text(message)),
    );
  }
}

String _kpiLabel(AppLocalizations l, BusinessKpiType type) {
  return switch (type) {
    BusinessKpiType.auditScore => l.businessKpiAuditScore,
    BusinessKpiType.marketingScore => l.businessKpiMarketingScore,
    BusinessKpiType.knowledgeEntries => l.businessKpiKnowledgeEntries,
    BusinessKpiType.sources => l.businessKpiSources,
    BusinessKpiType.reviews => l.businessKpiReviews,
    BusinessKpiType.botStatus => l.businessKpiBotStatus,
    BusinessKpiType.projectProgress => l.businessKpiProjectProgress,
    BusinessKpiType.strategyProgress => l.businessKpiStrategyProgress,
  };
}

String _categoryLabel(AppLocalizations l, BusinessTimelineCategory category) {
  return switch (category) {
    BusinessTimelineCategory.company => l.businessTimelineCategoryCompany,
    BusinessTimelineCategory.website => l.businessTimelineCategoryWebsite,
    BusinessTimelineCategory.bot => l.businessTimelineCategoryBot,
    BusinessTimelineCategory.audit => l.businessTimelineCategoryAudit,
    BusinessTimelineCategory.knowledge => l.businessTimelineCategoryKnowledge,
    BusinessTimelineCategory.review => l.businessTimelineCategoryReview,
    BusinessTimelineCategory.marketing => l.businessTimelineCategoryMarketing,
    BusinessTimelineCategory.strategy => l.businessTimelineCategoryStrategy,
    BusinessTimelineCategory.sources => l.businessTimelineCategorySources,
    BusinessTimelineCategory.projectStatus =>
      l.businessTimelineCategoryProjectStatus,
  };
}

String _eventTypeLabel(AppLocalizations l, BusinessTimelineEventType type) {
  return switch (type) {
    BusinessTimelineEventType.companyCreated => l.businessEventCompanyCreated,
    BusinessTimelineEventType.websiteAdded => l.businessEventWebsiteAdded,
    BusinessTimelineEventType.intakeCompleted => l.businessEventIntakeCompleted,
    BusinessTimelineEventType.botActivated => l.businessEventBotActivated,
    BusinessTimelineEventType.auditImproved => l.businessEventAuditImproved,
    BusinessTimelineEventType.knowledgeAdded => l.businessEventKnowledgeAdded,
    BusinessTimelineEventType.faqAdded => l.businessEventFaqAdded,
    BusinessTimelineEventType.reviewClosed => l.businessEventReviewClosed,
    BusinessTimelineEventType.marketingStarted =>
      l.businessEventMarketingStarted,
    BusinessTimelineEventType.marketingCompleted =>
      l.businessEventMarketingCompleted,
    BusinessTimelineEventType.strategyChanged => l.businessEventStrategyChanged,
    BusinessTimelineEventType.sourceAdded => l.businessEventSourceAdded,
    BusinessTimelineEventType.goalAdded => l.businessEventGoalAdded,
    BusinessTimelineEventType.projectStatusImproved =>
      l.businessEventProjectStatusImproved,
  };
}

String _highlightTypeLabel(AppLocalizations l, BusinessHighlightType type) {
  return switch (type) {
    BusinessHighlightType.biggestProgress => l.businessHighlightBiggestProgress,
    BusinessHighlightType.strongestModule => l.businessHighlightStrongestModule,
    BusinessHighlightType.lastImprovement => l.businessHighlightLastImprovement,
    BusinessHighlightType.openIssue => l.businessHighlightOpenIssue,
    BusinessHighlightType.nextChance => l.businessHighlightNextChance,
  };
}

IconData _categoryIcon(BusinessTimelineCategory category) {
  return switch (category) {
    BusinessTimelineCategory.company => Icons.business_outlined,
    BusinessTimelineCategory.website => Icons.language_outlined,
    BusinessTimelineCategory.bot => Icons.smart_toy_outlined,
    BusinessTimelineCategory.audit => Icons.fact_check_outlined,
    BusinessTimelineCategory.knowledge => Icons.library_books_outlined,
    BusinessTimelineCategory.review => Icons.rate_review_outlined,
    BusinessTimelineCategory.marketing => Icons.campaign_outlined,
    BusinessTimelineCategory.strategy => Icons.flag_outlined,
    BusinessTimelineCategory.sources => Icons.source_outlined,
    BusinessTimelineCategory.projectStatus => Icons.route_outlined,
  };
}

Color _priorityColor(BusinessTimelinePriority priority) {
  return switch (priority) {
    BusinessTimelinePriority.high => Colors.red,
    BusinessTimelinePriority.medium => Colors.orange,
    BusinessTimelinePriority.low => Colors.blueGrey,
  };
}

String _dateLabel(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
}
