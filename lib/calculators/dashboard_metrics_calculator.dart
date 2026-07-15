import '../models/bot_configuration.dart';
import '../models/bot_question_log.dart';
import '../models/business_audit.dart';
import '../models/business_strategy.dart';
import '../models/company_workspace.dart';
import '../models/intake_session.dart';
import '../models/knowledge_entry.dart';
import '../models/marketing_strategy.dart';
import '../models/project_status.dart';
import '../models/source_material.dart';
import 'business_strategy_calculator.dart';
import 'marketing_strategy_calculator.dart';
import 'project_status_calculator.dart';

class DashboardMetrics {
  final int reviewOpen;
  final int reviewedBotQuestions;
  final int redirects;
  final int auditPct;
  final int auditMissing;
  final int auditPartial;
  final int auditComplete;
  final int auditHighPriorityOpen;
  final int greenKnowledgeCount;
  final int yellowKnowledgeCount;
  final int redKnowledgeCount;
  final int totalKnowledgeCount;
  final BotStatus botStatus;
  final int sourcesTotal;
  final int sourcesNew;
  final IntakeSession? intakeSession;
  final ProjectStatusSnapshot projectStatus;
  final MarketingStrategySnapshot marketingStrategy;
  final BusinessStrategySnapshot businessStrategy;

  const DashboardMetrics({
    required this.reviewOpen,
    required this.reviewedBotQuestions,
    required this.redirects,
    required this.auditPct,
    required this.auditMissing,
    required this.auditPartial,
    required this.auditComplete,
    required this.auditHighPriorityOpen,
    required this.greenKnowledgeCount,
    required this.yellowKnowledgeCount,
    required this.redKnowledgeCount,
    required this.totalKnowledgeCount,
    required this.botStatus,
    required this.sourcesTotal,
    required this.sourcesNew,
    required this.intakeSession,
    required this.projectStatus,
    required this.marketingStrategy,
    required this.businessStrategy,
  });
}

class DashboardMetricsCalculator {
  final ProjectStatusCalculator projectStatusCalculator;
  final MarketingStrategyCalculator marketingStrategyCalculator;
  final BusinessStrategyCalculator businessStrategyCalculator;

  const DashboardMetricsCalculator({
    this.projectStatusCalculator = const ProjectStatusCalculator(),
    this.marketingStrategyCalculator = const MarketingStrategyCalculator(),
    this.businessStrategyCalculator = const BusinessStrategyCalculator(),
  });

  DashboardMetrics calculate(CompanyWorkspace workspace) {
    final botLogs = workspace.botLogs;
    final auditItems = workspace.auditItems;
    final knowledgeEntries = workspace.knowledgeEntries;
    final sourceMaterials = workspace.sourceMaterials;

    return DashboardMetrics(
      reviewOpen: botLogs
          .where((log) => log.reviewStatus == ReviewStatus.open)
          .length,
      reviewedBotQuestions: botLogs
          .where(
            (log) =>
                log.reviewStatus == ReviewStatus.reviewed ||
                log.reviewStatus == ReviewStatus.closed,
          )
          .length,
      redirects: botLogs.where((log) => log.redirected).length,
      auditPct: (projectStatusCalculator.auditScoreFor(workspace) * 100)
          .round(),
      auditMissing: auditItems
          .where((item) => item.status == AuditItemStatus.missing)
          .length,
      auditPartial: auditItems
          .where((item) => item.status == AuditItemStatus.partial)
          .length,
      auditComplete: auditItems
          .where((item) => item.status == AuditItemStatus.complete)
          .length,
      auditHighPriorityOpen: auditItems
          .where(
            (item) =>
                item.priority == AuditPriority.high &&
                item.status != AuditItemStatus.complete,
          )
          .length,
      greenKnowledgeCount: knowledgeEntries
          .where((entry) => entry.riskLevel == RiskLevel.green)
          .length,
      yellowKnowledgeCount: knowledgeEntries
          .where((entry) => entry.riskLevel == RiskLevel.yellow)
          .length,
      redKnowledgeCount: knowledgeEntries
          .where((entry) => entry.riskLevel == RiskLevel.red)
          .length,
      totalKnowledgeCount: knowledgeEntries.length,
      botStatus: workspace.botConfiguration.status,
      sourcesTotal: sourceMaterials.length,
      sourcesNew: sourceMaterials
          .where((source) => source.status == SourceMaterialStatus.newItem)
          .length,
      intakeSession: workspace.intakeSession,
      projectStatus: projectStatusCalculator.calculate(workspace),
      marketingStrategy: marketingStrategyCalculator.calculate(workspace),
      businessStrategy: businessStrategyCalculator.calculate(workspace),
    );
  }
}
