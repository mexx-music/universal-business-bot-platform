import '../models/bot_configuration.dart';
import '../models/bot_question_log.dart';
import '../models/business_intelligence.dart';
import '../models/business_strategy.dart';
import '../models/company_workspace.dart';
import '../models/knowledge_entry.dart';
import '../models/marketing_strategy.dart';
import '../models/project_status.dart';
import 'business_strategy_calculator.dart';
import 'marketing_strategy_calculator.dart';
import 'project_status_calculator.dart';

class BusinessIntelligenceCalculator {
  final ProjectStatusCalculator projectStatusCalculator;
  final MarketingStrategyCalculator marketingStrategyCalculator;
  final BusinessStrategyCalculator businessStrategyCalculator;

  const BusinessIntelligenceCalculator({
    this.projectStatusCalculator = const ProjectStatusCalculator(),
    this.marketingStrategyCalculator = const MarketingStrategyCalculator(),
    this.businessStrategyCalculator = const BusinessStrategyCalculator(),
  });

  BusinessIntelligenceSnapshot calculate(CompanyWorkspace workspace) {
    final now = DateTime.now();
    final projectStatus = projectStatusCalculator.calculate(workspace);
    final marketing = marketingStrategyCalculator.calculate(workspace);
    final strategy = businessStrategyCalculator.calculate(workspace);
    final timeline = _timeline(workspace, projectStatus, marketing, now)
      ..sort((a, b) => b.date.compareTo(a.date));
    final monthly = _monthlyOverview(workspace, timeline, now);
    final highlights = _highlights(
      workspace,
      timeline,
      projectStatus,
      marketing,
      strategy,
    );

    return BusinessIntelligenceSnapshot(
      timeline: timeline,
      kpiTrends: _kpis(workspace, projectStatus, marketing, strategy),
      developmentSignals: _developmentSignals(
        workspace,
        projectStatus,
        marketing,
        strategy,
      ),
      highlights: highlights,
      monthlyOverview: monthly,
      lastImprovement: timeline.isEmpty ? null : timeline.first,
      weeklySummary: _weeklySummary(timeline, now),
    );
  }

  List<BusinessTimelineEvent> _timeline(
    CompanyWorkspace workspace,
    ProjectStatusSnapshot projectStatus,
    MarketingStrategySnapshot marketing,
    DateTime now,
  ) {
    final events = <BusinessTimelineEvent>[];
    final companyId = workspace.company.id;
    final fallback =
        workspace.intakeSession?.createdAt ??
        _earliestDate(workspace) ??
        DateTime(now.year, now.month, now.day);

    void add({
      required DateTime date,
      required BusinessTimelineCategory category,
      required BusinessTimelineEventType type,
      required BusinessTimelinePriority priority,
      required String route,
      required String title,
      required String description,
      String? referenceId,
    }) {
      events.add(
        BusinessTimelineEvent(
          date: date,
          category: category,
          type: type,
          priority: priority,
          workspaceId: companyId,
          route: route,
          referenceId: referenceId,
          title: title,
          description: description,
        ),
      );
    }

    add(
      date: fallback,
      category: BusinessTimelineCategory.company,
      type: BusinessTimelineEventType.companyCreated,
      priority: BusinessTimelinePriority.high,
      route: '/company',
      title: workspace.company.name,
      description: workspace.company.description,
      referenceId: workspace.company.id,
    );

    if (workspace.company.website.trim().isNotEmpty) {
      add(
        date: workspace.intakeSession?.updatedAt ?? fallback,
        category: BusinessTimelineCategory.website,
        type: BusinessTimelineEventType.websiteAdded,
        priority: BusinessTimelinePriority.medium,
        route: '/company',
        title: workspace.company.website,
        description: workspace.company.name,
        referenceId: workspace.company.id,
      );
    }

    final intake = workspace.intakeSession;
    if (intake?.status.name == 'completed' || intake?.importedAt != null) {
      add(
        date:
            intake?.importedAt ?? intake?.chatCompletedAt ?? intake!.updatedAt,
        category: BusinessTimelineCategory.company,
        type: BusinessTimelineEventType.intakeCompleted,
        priority: BusinessTimelinePriority.high,
        route: '/intake',
        title: workspace.company.name,
        description: 'Intake',
        referenceId: intake?.id,
      );
    }

    if (workspace.botConfiguration.status != BotStatus.draft) {
      add(
        date: _latestBotLogDate(workspace) ?? now,
        category: BusinessTimelineCategory.bot,
        type: BusinessTimelineEventType.botActivated,
        priority: BusinessTimelinePriority.high,
        route: '/bot-settings',
        title: workspace.botConfiguration.status.name,
        description: workspace.botConfiguration.handoverMessage,
      );
    }

    if (projectStatusCalculator.auditScoreFor(workspace) >= 0.5) {
      add(
        date: now,
        category: BusinessTimelineCategory.audit,
        type: BusinessTimelineEventType.auditImproved,
        priority: BusinessTimelinePriority.medium,
        route: '/audit',
        title:
            '${(projectStatusCalculator.auditScoreFor(workspace) * 100).round()}%',
        description: 'Audit',
      );
    }

    for (final entry in workspace.knowledgeEntries) {
      add(
        date: entry.createdAt,
        category: BusinessTimelineCategory.knowledge,
        type: entry.category == KnowledgeCategory.faq
            ? BusinessTimelineEventType.faqAdded
            : BusinessTimelineEventType.knowledgeAdded,
        priority: entry.category == KnowledgeCategory.faq
            ? BusinessTimelinePriority.medium
            : BusinessTimelinePriority.low,
        route: '/knowledge',
        title: entry.title,
        description: entry.source,
        referenceId: entry.id,
      );
    }

    for (final source in workspace.sourceMaterials) {
      add(
        date: source.createdAt,
        category: BusinessTimelineCategory.sources,
        type: BusinessTimelineEventType.sourceAdded,
        priority: BusinessTimelinePriority.medium,
        route: '/sources',
        title: source.title,
        description: source.contentSnippet ?? source.notes ?? '',
        referenceId: source.id,
      );
    }

    for (final log in workspace.botLogs) {
      if (log.reviewStatus == ReviewStatus.reviewed ||
          log.reviewStatus == ReviewStatus.closed) {
        add(
          date: log.reviewedAt ?? log.timestamp,
          category: BusinessTimelineCategory.review,
          type: BusinessTimelineEventType.reviewClosed,
          priority: BusinessTimelinePriority.medium,
          route: '/review',
          title: log.question,
          description: log.humanNote ?? log.answer ?? '',
          referenceId: log.id,
        );
      }
    }

    for (final action in marketing.actions) {
      if (action.status == MarketingActionStatus.inProgress ||
          action.status == MarketingActionStatus.planned) {
        add(
          date: now,
          category: BusinessTimelineCategory.marketing,
          type: BusinessTimelineEventType.marketingStarted,
          priority: _priority(action.priority),
          route: '/marketing-strategy',
          title: action.type.name,
          description: action.notes,
          referenceId: action.id,
        );
      }
      if (action.status == MarketingActionStatus.completed) {
        add(
          date: now,
          category: BusinessTimelineCategory.marketing,
          type: BusinessTimelineEventType.marketingCompleted,
          priority: _priority(action.priority),
          route: '/marketing-strategy',
          title: action.type.name,
          description: action.notes,
          referenceId: action.id,
        );
      }
    }

    for (final goal in workspace.businessGoals) {
      add(
        date: goal.startDate,
        category: BusinessTimelineCategory.strategy,
        type: BusinessTimelineEventType.goalAdded,
        priority: switch (goal.priority) {
          BusinessGoalPriority.high => BusinessTimelinePriority.high,
          BusinessGoalPriority.medium => BusinessTimelinePriority.medium,
          BusinessGoalPriority.low => BusinessTimelinePriority.low,
        },
        route: '/business-strategy',
        title: goal.title,
        description: goal.description,
        referenceId: goal.id,
      );
      if (goal.comment.trim().isNotEmpty) {
        add(
          date: goal.startDate,
          category: BusinessTimelineCategory.strategy,
          type: BusinessTimelineEventType.strategyChanged,
          priority: BusinessTimelinePriority.medium,
          route: '/business-strategy',
          title: goal.title,
          description: goal.comment,
          referenceId: goal.id,
        );
      }
    }

    if (projectStatus.progress >= 0.5) {
      add(
        date: now,
        category: BusinessTimelineCategory.projectStatus,
        type: BusinessTimelineEventType.projectStatusImproved,
        priority: BusinessTimelinePriority.medium,
        route: '/project-status',
        title: '${(projectStatus.progress * 100).round()}%',
        description: 'Project Status',
      );
    }

    return events;
  }

  List<BusinessKpiTrend> _kpis(
    CompanyWorkspace workspace,
    ProjectStatusSnapshot projectStatus,
    MarketingStrategySnapshot marketing,
    BusinessStrategySnapshot strategy,
  ) {
    final auditPct = (projectStatusCalculator.auditScoreFor(workspace) * 100)
        .round();
    final projectPct = (projectStatus.progress * 100).round();
    final strategyPct = (strategy.averageProgress * 100).round();
    final closedReviews = workspace.botLogs
        .where(
          (log) =>
              log.reviewStatus == ReviewStatus.reviewed ||
              log.reviewStatus == ReviewStatus.closed,
        )
        .length;

    return [
      BusinessKpiTrend(
        type: BusinessKpiType.auditScore,
        currentValue: '$auditPct%',
        changeValue: _signedPercent(auditPct - 50),
        positive: auditPct >= 50,
        route: '/audit',
      ),
      BusinessKpiTrend(
        type: BusinessKpiType.marketingScore,
        currentValue: '${marketing.score}',
        changeValue: _signedPercent(marketing.score - 40),
        positive: marketing.score >= 40,
        route: '/marketing-strategy',
      ),
      BusinessKpiTrend(
        type: BusinessKpiType.knowledgeEntries,
        currentValue: '${workspace.knowledgeEntries.length}',
        changeValue: '+${workspace.knowledgeEntries.length}',
        positive: workspace.knowledgeEntries.isNotEmpty,
        route: '/knowledge',
      ),
      BusinessKpiTrend(
        type: BusinessKpiType.sources,
        currentValue: '${workspace.sourceMaterials.length}',
        changeValue: '+${workspace.sourceMaterials.length}',
        positive: workspace.sourceMaterials.isNotEmpty,
        route: '/sources',
      ),
      BusinessKpiTrend(
        type: BusinessKpiType.reviews,
        currentValue: '$closedReviews',
        changeValue: '+$closedReviews',
        positive: closedReviews > 0,
        route: '/review',
      ),
      BusinessKpiTrend(
        type: BusinessKpiType.botStatus,
        currentValue: workspace.botConfiguration.status.name,
        changeValue: workspace.botConfiguration.status == BotStatus.active
            ? 'aktiv'
            : workspace.botConfiguration.status == BotStatus.testReady
            ? 'testbereit'
            : 'Entwurf',
        positive: workspace.botConfiguration.status != BotStatus.draft,
        route: '/bot-settings',
      ),
      BusinessKpiTrend(
        type: BusinessKpiType.projectProgress,
        currentValue: '$projectPct%',
        changeValue: _signedPercent(projectPct - 50),
        positive: projectPct >= 50,
        route: '/project-status',
      ),
      BusinessKpiTrend(
        type: BusinessKpiType.strategyProgress,
        currentValue: '$strategyPct%',
        changeValue: _signedPercent(strategyPct - 40),
        positive: strategyPct >= 40,
        route: '/business-strategy',
      ),
    ];
  }

  List<BusinessDevelopmentSignal> _developmentSignals(
    CompanyWorkspace workspace,
    ProjectStatusSnapshot projectStatus,
    MarketingStrategySnapshot marketing,
    BusinessStrategySnapshot strategy,
  ) {
    final auditPct = (projectStatusCalculator.auditScoreFor(workspace) * 100)
        .round();
    final projectPct = (projectStatus.progress * 100).round();
    final strategyPct = (strategy.averageProgress * 100).round();
    final openReviews = workspace.botLogs
        .where((log) => log.reviewStatus == ReviewStatus.open)
        .length;

    return [
      BusinessDevelopmentSignal(
        area: 'Audit',
        value: _signedPercent(auditPct - 50),
        positive: auditPct >= 50,
        route: '/audit',
      ),
      BusinessDevelopmentSignal(
        area: 'Marketing',
        value: _signedPercent(marketing.score - 40),
        positive: marketing.score >= 40,
        route: '/marketing-strategy',
      ),
      BusinessDevelopmentSignal(
        area: 'Knowledge',
        value: '+${workspace.knowledgeEntries.length}',
        positive: workspace.knowledgeEntries.isNotEmpty,
        route: '/knowledge',
      ),
      BusinessDevelopmentSignal(
        area: 'Projektstatus',
        value: _signedPercent(projectPct - 50),
        positive: projectPct >= 50,
        route: '/project-status',
      ),
      BusinessDevelopmentSignal(
        area: 'Bot',
        value: workspace.botConfiguration.status == BotStatus.draft
            ? 'Entwurf'
            : 'aktiv',
        positive: workspace.botConfiguration.status != BotStatus.draft,
        route: '/bot-settings',
      ),
      BusinessDevelopmentSignal(
        area: 'Support',
        value: openReviews == 0 ? 'keine offenen Fragen' : '$openReviews offen',
        positive: openReviews <= 2,
        route: '/review',
      ),
      BusinessDevelopmentSignal(
        area: 'Strategie',
        value: '$strategyPct%',
        positive: strategyPct >= 40,
        route: '/business-strategy',
      ),
    ];
  }

  List<BusinessHighlight> _highlights(
    CompanyWorkspace workspace,
    List<BusinessTimelineEvent> timeline,
    ProjectStatusSnapshot projectStatus,
    MarketingStrategySnapshot marketing,
    BusinessStrategySnapshot strategy,
  ) {
    final auditPct = (projectStatusCalculator.auditScoreFor(workspace) * 100)
        .round();
    final modules = <({String name, int value, String route})>[
      (name: 'Audit', value: auditPct, route: '/audit'),
      (name: 'Marketing', value: marketing.score, route: '/marketing-strategy'),
      (
        name: 'Projektstatus',
        value: (projectStatus.progress * 100).round(),
        route: '/project-status',
      ),
      (
        name: 'Strategie',
        value: (strategy.averageProgress * 100).round(),
        route: '/business-strategy',
      ),
      (
        name: 'Knowledge',
        value: (workspace.knowledgeEntries.length * 6).clamp(0, 100).toInt(),
        route: '/knowledge',
      ),
    ]..sort((a, b) => b.value.compareTo(a.value));

    final last = timeline.isEmpty ? null : timeline.first;
    final open = projectStatus.recommendations.isNotEmpty
        ? projectStatus.recommendations.first
        : null;

    return [
      BusinessHighlight(
        type: BusinessHighlightType.biggestProgress,
        title: modules.first.name,
        description: '${modules.first.value}%',
        route: modules.first.route,
      ),
      BusinessHighlight(
        type: BusinessHighlightType.strongestModule,
        title: modules.first.name,
        description: '${modules.first.value}%',
        route: modules.first.route,
      ),
      if (last != null)
        BusinessHighlight(
          type: BusinessHighlightType.lastImprovement,
          title: last.title,
          description: last.description,
          route: last.route,
        ),
      if (open != null)
        BusinessHighlight(
          type: BusinessHighlightType.openIssue,
          title: open.type.name,
          description: open.route,
          route: open.route,
        ),
      BusinessHighlight(
        type: BusinessHighlightType.nextChance,
        title: marketing.recommendedActionTypes.isEmpty
            ? 'Projektstatus'
            : marketing.recommendedActionTypes.first.name,
        description: marketing.recommendedActionTypes.isEmpty
            ? 'Nächsten Projektschritt prüfen'
            : 'Marketingchance',
        route: marketing.recommendedActionTypes.isEmpty
            ? '/project-status'
            : '/marketing-strategy',
      ),
    ];
  }

  BusinessMonthlyOverview _monthlyOverview(
    CompanyWorkspace workspace,
    List<BusinessTimelineEvent> timeline,
    DateTime now,
  ) {
    bool currentMonth(DateTime date) =>
        date.year == now.year && date.month == now.month;

    return BusinessMonthlyOverview(
      changeCount: timeline.where((event) => currentMonth(event.date)).length,
      newSources: workspace.sourceMaterials
          .where((source) => currentMonth(source.createdAt))
          .length,
      newKnowledgeEntries: workspace.knowledgeEntries
          .where((entry) => currentMonth(entry.createdAt))
          .length,
      completedMarketingActions: marketingStrategyCalculator
          .actionsFor(workspace)
          .where((action) => action.status == MarketingActionStatus.completed)
          .length,
      achievedGoals: workspace.businessGoals
          .where((goal) => goal.status == BusinessGoalStatus.achieved)
          .length,
    );
  }

  String _weeklySummary(List<BusinessTimelineEvent> timeline, DateTime now) {
    final since = now.subtract(const Duration(days: 7));
    final count = timeline.where((event) => event.date.isAfter(since)).length;
    if (count == 0) return '0';
    return '+$count';
  }

  DateTime? _earliestDate(CompanyWorkspace workspace) {
    final dates = <DateTime>[
      if (workspace.intakeSession != null) workspace.intakeSession!.createdAt,
      for (final entry in workspace.knowledgeEntries) entry.createdAt,
      for (final source in workspace.sourceMaterials) source.createdAt,
      for (final log in workspace.botLogs) log.timestamp,
      for (final goal in workspace.businessGoals) goal.startDate,
    ]..sort();
    return dates.isEmpty ? null : dates.first;
  }

  DateTime? _latestBotLogDate(CompanyWorkspace workspace) {
    final dates = workspace.botLogs.map((log) => log.timestamp).toList()
      ..sort();
    return dates.isEmpty ? null : dates.last;
  }

  BusinessTimelinePriority _priority(MarketingActionPriority priority) {
    return switch (priority) {
      MarketingActionPriority.high => BusinessTimelinePriority.high,
      MarketingActionPriority.medium => BusinessTimelinePriority.medium,
      MarketingActionPriority.low => BusinessTimelinePriority.low,
    };
  }

  String _signedPercent(int value) {
    if (value > 0) return '+$value%';
    return '$value%';
  }
}
