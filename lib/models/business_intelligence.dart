enum BusinessTimelineCategory {
  company,
  website,
  bot,
  audit,
  knowledge,
  review,
  marketing,
  strategy,
  sources,
  projectStatus,
}

enum BusinessTimelineEventType {
  companyCreated,
  websiteAdded,
  intakeCompleted,
  botActivated,
  auditImproved,
  knowledgeAdded,
  faqAdded,
  reviewClosed,
  marketingStarted,
  marketingCompleted,
  strategyChanged,
  sourceAdded,
  goalAdded,
  projectStatusImproved,
}

enum BusinessTimelinePriority { low, medium, high }

class BusinessTimelineEvent {
  final DateTime date;
  final BusinessTimelineCategory category;
  final BusinessTimelineEventType type;
  final BusinessTimelinePriority priority;
  final String workspaceId;
  final String route;
  final String? referenceId;
  final String title;
  final String description;

  const BusinessTimelineEvent({
    required this.date,
    required this.category,
    required this.type,
    required this.priority,
    required this.workspaceId,
    required this.route,
    this.referenceId,
    required this.title,
    required this.description,
  });
}

enum BusinessKpiType {
  auditScore,
  marketingScore,
  knowledgeEntries,
  sources,
  reviews,
  botStatus,
  projectProgress,
  strategyProgress,
}

class BusinessKpiTrend {
  final BusinessKpiType type;
  final String currentValue;
  final String changeValue;
  final bool positive;
  final String route;

  const BusinessKpiTrend({
    required this.type,
    required this.currentValue,
    required this.changeValue,
    required this.positive,
    required this.route,
  });
}

class BusinessDevelopmentSignal {
  final String area;
  final String value;
  final bool positive;
  final String route;

  const BusinessDevelopmentSignal({
    required this.area,
    required this.value,
    required this.positive,
    required this.route,
  });
}

enum BusinessHighlightType {
  biggestProgress,
  strongestModule,
  lastImprovement,
  openIssue,
  nextChance,
}

class BusinessHighlight {
  final BusinessHighlightType type;
  final String title;
  final String description;
  final String route;

  const BusinessHighlight({
    required this.type,
    required this.title,
    required this.description,
    required this.route,
  });
}

class BusinessMonthlyOverview {
  final int changeCount;
  final int newSources;
  final int newKnowledgeEntries;
  final int completedMarketingActions;
  final int achievedGoals;

  const BusinessMonthlyOverview({
    required this.changeCount,
    required this.newSources,
    required this.newKnowledgeEntries,
    required this.completedMarketingActions,
    required this.achievedGoals,
  });
}

class BusinessIntelligenceSnapshot {
  final List<BusinessTimelineEvent> timeline;
  final List<BusinessKpiTrend> kpiTrends;
  final List<BusinessDevelopmentSignal> developmentSignals;
  final List<BusinessHighlight> highlights;
  final BusinessMonthlyOverview monthlyOverview;
  final BusinessTimelineEvent? lastImprovement;
  final String weeklySummary;

  const BusinessIntelligenceSnapshot({
    required this.timeline,
    required this.kpiTrends,
    required this.developmentSignals,
    required this.highlights,
    required this.monthlyOverview,
    required this.lastImprovement,
    required this.weeklySummary,
  });
}
