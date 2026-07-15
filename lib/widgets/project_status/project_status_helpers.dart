import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/project_status.dart';

String projectPhaseLabel(AppLocalizations l, ProjectPhase phase) {
  return switch (phase) {
    ProjectPhase.company => l.projectPhaseCompany,
    ProjectPhase.knowledge => l.projectPhaseKnowledge,
    ProjectPhase.ai => l.projectPhaseAi,
    ProjectPhase.marketing => l.projectPhaseMarketing,
    ProjectPhase.controlling => l.projectPhaseControlling,
  };
}

String projectTaskTitle(AppLocalizations l, ProjectTaskType type) {
  return switch (type) {
    ProjectTaskType.companyProfile => l.projectTaskCompanyProfileTitle,
    ProjectTaskType.intake => l.projectTaskIntakeTitle,
    ProjectTaskType.knowledgeBase => l.projectTaskKnowledgeTitle,
    ProjectTaskType.sources => l.projectTaskSourcesTitle,
    ProjectTaskType.audit => l.projectTaskAuditTitle,
    ProjectTaskType.websiteAnalysis => l.projectTaskWebsiteTitle,
    ProjectTaskType.marketing => l.projectTaskMarketingTitle,
    ProjectTaskType.botActivation => l.projectTaskBotTitle,
    ProjectTaskType.humanReview => l.projectTaskReviewTitle,
    ProjectTaskType.controlling => l.projectTaskControllingTitle,
  };
}

String projectTaskDescription(AppLocalizations l, ProjectTaskType type) {
  return switch (type) {
    ProjectTaskType.companyProfile => l.projectTaskCompanyProfileDescription,
    ProjectTaskType.intake => l.projectTaskIntakeDescription,
    ProjectTaskType.knowledgeBase => l.projectTaskKnowledgeDescription,
    ProjectTaskType.sources => l.projectTaskSourcesDescription,
    ProjectTaskType.audit => l.projectTaskAuditDescription,
    ProjectTaskType.websiteAnalysis => l.projectTaskWebsiteDescription,
    ProjectTaskType.marketing => l.projectTaskMarketingDescription,
    ProjectTaskType.botActivation => l.projectTaskBotDescription,
    ProjectTaskType.humanReview => l.projectTaskReviewDescription,
    ProjectTaskType.controlling => l.projectTaskControllingDescription,
  };
}

String projectRecommendationDescription(
  AppLocalizations l,
  ProjectTaskType type,
) {
  return switch (type) {
    ProjectTaskType.companyProfile => l.projectRecommendationProfile,
    ProjectTaskType.intake => l.projectRecommendationIntake,
    ProjectTaskType.knowledgeBase => l.projectRecommendationKnowledge,
    ProjectTaskType.sources => l.projectRecommendationSources,
    ProjectTaskType.audit => l.projectRecommendationAudit,
    ProjectTaskType.websiteAnalysis => l.projectRecommendationWebsite,
    ProjectTaskType.marketing => l.projectRecommendationMarketing,
    ProjectTaskType.botActivation => l.projectRecommendationBot,
    ProjectTaskType.humanReview => l.projectRecommendationReview,
    ProjectTaskType.controlling => l.projectRecommendationControlling,
  };
}

String projectPriorityLabel(AppLocalizations l, ProjectTaskPriority priority) {
  return switch (priority) {
    ProjectTaskPriority.low => l.projectPriorityLow,
    ProjectTaskPriority.medium => l.projectPriorityMedium,
    ProjectTaskPriority.high => l.projectPriorityHigh,
  };
}

String projectCompletionLabel(
  AppLocalizations l,
  ProjectCompletionState state,
) {
  return switch (state) {
    ProjectCompletionState.missing => l.projectCompletionMissing,
    ProjectCompletionState.partial => l.projectCompletionPartial,
    ProjectCompletionState.complete => l.projectCompletionComplete,
  };
}

IconData projectTaskIcon(ProjectTaskType type) {
  return switch (type) {
    ProjectTaskType.companyProfile => Icons.business_outlined,
    ProjectTaskType.intake => Icons.assignment_outlined,
    ProjectTaskType.knowledgeBase => Icons.library_books_outlined,
    ProjectTaskType.sources => Icons.source_outlined,
    ProjectTaskType.audit => Icons.fact_check_outlined,
    ProjectTaskType.websiteAnalysis => Icons.public_outlined,
    ProjectTaskType.marketing => Icons.campaign_outlined,
    ProjectTaskType.botActivation => Icons.smart_toy_outlined,
    ProjectTaskType.humanReview => Icons.rate_review_outlined,
    ProjectTaskType.controlling => Icons.bar_chart_outlined,
  };
}

Color projectPriorityColor(ProjectTaskPriority priority) {
  return switch (priority) {
    ProjectTaskPriority.high => Colors.red,
    ProjectTaskPriority.medium => Colors.orange,
    ProjectTaskPriority.low => Colors.blueGrey,
  };
}

Color projectCompletionColor(ProjectCompletionState state) {
  return switch (state) {
    ProjectCompletionState.complete => Colors.green,
    ProjectCompletionState.partial => Colors.orange,
    ProjectCompletionState.missing => Colors.grey,
  };
}
