import '../models/bot_configuration.dart';
import '../models/bot_question_log.dart';
import '../models/business_strategy.dart';
import '../models/company_workspace.dart';
import 'marketing_strategy_calculator.dart';
import 'project_status_calculator.dart';

class BusinessStrategyCalculator {
  final MarketingStrategyCalculator marketingStrategyCalculator;
  final ProjectStatusCalculator projectStatusCalculator;

  const BusinessStrategyCalculator({
    this.marketingStrategyCalculator = const MarketingStrategyCalculator(),
    this.projectStatusCalculator = const ProjectStatusCalculator(),
  });

  BusinessStrategySnapshot calculate(CompanyWorkspace workspace) {
    final goalProgress = workspace.businessGoals.map((goal) {
      final contributions = <BusinessGoalArea, double>{
        for (final area in goal.linkedAreas)
          area: _businessGoalAreaProgress(workspace, area),
      };
      final progress = contributions.isEmpty
          ? 0.0
          : contributions.values.fold<double>(0, (sum, value) => sum + value) /
                contributions.length;
      return BusinessGoalProgress(
        goal: goal,
        progress: goal.status == BusinessGoalStatus.achieved ? 1 : progress,
        moduleContributions: contributions,
      );
    }).toList();

    return BusinessStrategySnapshot(
      goals: goalProgress,
      nextRecommendation: _businessGoalRecommendation(goalProgress),
    );
  }

  double _businessGoalAreaProgress(
    CompanyWorkspace workspace,
    BusinessGoalArea area,
  ) {
    return switch (area) {
      BusinessGoalArea.marketing =>
        marketingStrategyCalculator.calculate(workspace).score / 100,
      BusinessGoalArea.audit => projectStatusCalculator.auditScoreFor(
        workspace,
      ),
      BusinessGoalArea.knowledgeBase => projectStatusCalculator.completionValue(
        projectStatusCalculator.countCompletion(
          workspace.knowledgeEntries.length,
          partialAt: 4,
          completeAt: 12,
        ),
      ),
      BusinessGoalArea.bot => switch (workspace.botConfiguration.status) {
        BotStatus.active => 1.0,
        BotStatus.testReady => 0.65,
        BotStatus.draft => 0.2,
      },
      BusinessGoalArea.humanReview => _humanReviewProgress(workspace),
      BusinessGoalArea.sources => projectStatusCalculator.completionValue(
        projectStatusCalculator.sourcesCompletion(workspace.sourceMaterials),
      ),
      BusinessGoalArea.companyProfile =>
        projectStatusCalculator.completionValue(
          projectStatusCalculator.companyProfileCompletion(workspace),
        ),
      BusinessGoalArea.projectStatus =>
        projectStatusCalculator.calculate(workspace).progress,
      BusinessGoalArea.controlling => projectStatusCalculator.completionValue(
        projectStatusCalculator.controllingCompletion(workspace),
      ),
    };
  }

  double _humanReviewProgress(CompanyWorkspace workspace) {
    final open = workspace.botLogs
        .where((log) => log.reviewStatus == ReviewStatus.open)
        .length;
    if (open == 0) return 1;
    return (1 - (open.clamp(0, 5) / 5)).clamp(0, 1).toDouble();
  }

  BusinessGoalRecommendation? _businessGoalRecommendation(
    List<BusinessGoalProgress> goals,
  ) {
    final active = goals
        .where(
          (entry) =>
              entry.goal.status != BusinessGoalStatus.achieved &&
              entry.goal.status != BusinessGoalStatus.canceled,
        )
        .toList();
    if (active.isEmpty) return null;
    active.sort((a, b) {
      final priority = _businessGoalPriorityRank(
        b.goal.priority,
      ).compareTo(_businessGoalPriorityRank(a.goal.priority));
      if (priority != 0) return priority;
      return a.progress.compareTo(b.progress);
    });
    final goal = active.first;
    if (goal.moduleContributions.isEmpty) return null;
    final weakest = goal.moduleContributions.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final area = weakest.first.key;
    return BusinessGoalRecommendation(
      goal: goal.goal,
      area: area,
      route: _routeForBusinessGoalArea(area),
    );
  }

  int _businessGoalPriorityRank(BusinessGoalPriority priority) {
    return switch (priority) {
      BusinessGoalPriority.high => 3,
      BusinessGoalPriority.medium => 2,
      BusinessGoalPriority.low => 1,
    };
  }

  String _routeForBusinessGoalArea(BusinessGoalArea area) {
    return switch (area) {
      BusinessGoalArea.marketing => '/marketing-strategy',
      BusinessGoalArea.audit => '/audit',
      BusinessGoalArea.knowledgeBase => '/knowledge',
      BusinessGoalArea.bot => '/bot-settings',
      BusinessGoalArea.humanReview => '/review',
      BusinessGoalArea.sources => '/sources',
      BusinessGoalArea.companyProfile => '/company',
      BusinessGoalArea.projectStatus => '/project-status',
      BusinessGoalArea.controlling => '/dashboard',
    };
  }
}
