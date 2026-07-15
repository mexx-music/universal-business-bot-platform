import '../models/business_audit.dart';
import '../models/bot_configuration.dart';
import '../models/bot_question_log.dart';
import '../models/company_workspace.dart';
import '../models/intake_session.dart';
import '../models/project_status.dart';
import '../models/source_material.dart';
import 'marketing_strategy_calculator.dart';

class ProjectStatusCalculator {
  final MarketingStrategyCalculator marketingStrategyCalculator;

  const ProjectStatusCalculator({
    this.marketingStrategyCalculator = const MarketingStrategyCalculator(),
  });

  ProjectStatusSnapshot calculate(CompanyWorkspace workspace) {
    final auditScore = auditScoreFor(workspace);
    final intake = workspace.intakeSession;
    final sources = workspace.sourceMaterials;
    final knowledgeCount = workspace.knowledgeEntries.length;
    final openReviews = openReviewCountFor(workspace);
    final botStatus = workspace.botConfiguration.status;
    final businessRules = workspace.businessRules;

    final items = [
      ProjectStatusItem(
        type: ProjectTaskType.companyProfile,
        phase: ProjectPhase.company,
        completion: companyProfileCompletion(workspace),
        priority: ProjectTaskPriority.high,
        route: '/company',
        weight: 1.2,
      ),
      ProjectStatusItem(
        type: ProjectTaskType.intake,
        phase: ProjectPhase.company,
        completion: intakeCompletion(intake),
        priority: ProjectTaskPriority.high,
        route: '/intake',
        weight: 1.2,
      ),
      ProjectStatusItem(
        type: ProjectTaskType.knowledgeBase,
        phase: ProjectPhase.knowledge,
        completion: countCompletion(
          knowledgeCount,
          partialAt: 4,
          completeAt: 12,
        ),
        priority: ProjectTaskPriority.high,
        route: '/knowledge',
        weight: 1.2,
      ),
      ProjectStatusItem(
        type: ProjectTaskType.sources,
        phase: ProjectPhase.knowledge,
        completion: sourcesCompletion(sources),
        priority: ProjectTaskPriority.medium,
        route: '/sources',
      ),
      ProjectStatusItem(
        type: ProjectTaskType.audit,
        phase: ProjectPhase.knowledge,
        completion: auditScore >= 0.8
            ? ProjectCompletionState.complete
            : auditScore >= 0.6
            ? ProjectCompletionState.partial
            : ProjectCompletionState.missing,
        priority: ProjectTaskPriority.high,
        route: '/audit',
        weight: 1.2,
      ),
      ProjectStatusItem(
        type: ProjectTaskType.websiteAnalysis,
        phase: ProjectPhase.knowledge,
        completion: websiteAnalysisCompletion(workspace),
        priority: ProjectTaskPriority.medium,
        route: '/sources',
      ),
      ProjectStatusItem(
        type: ProjectTaskType.botActivation,
        phase: ProjectPhase.ai,
        completion: switch (botStatus) {
          BotStatus.active => ProjectCompletionState.complete,
          BotStatus.testReady => ProjectCompletionState.partial,
          BotStatus.draft => ProjectCompletionState.missing,
        },
        priority: ProjectTaskPriority.high,
        route: '/bot-settings',
        weight: 1.2,
      ),
      ProjectStatusItem(
        type: ProjectTaskType.humanReview,
        phase: ProjectPhase.ai,
        completion: openReviews == 0
            ? ProjectCompletionState.complete
            : openReviews < 3
            ? ProjectCompletionState.partial
            : ProjectCompletionState.missing,
        priority: openReviews >= 3
            ? ProjectTaskPriority.high
            : ProjectTaskPriority.medium,
        route: '/review',
      ),
      ProjectStatusItem(
        type: ProjectTaskType.marketing,
        phase: ProjectPhase.marketing,
        completion: marketingStrategyCalculator.marketingCompletion(workspace),
        priority: ProjectTaskPriority.medium,
        route: '/marketing-strategy',
      ),
      ProjectStatusItem(
        type: ProjectTaskType.controlling,
        phase: ProjectPhase.controlling,
        completion: controllingCompletion(workspace),
        priority: ProjectTaskPriority.low,
        route: '/dashboard',
      ),
    ];

    final recommendations = _buildProjectRecommendations(
      workspace: workspace,
      items: items,
      auditScore: auditScore,
      knowledgeCount: knowledgeCount,
      openReviews: openReviews,
      businessRulesComplete:
          businessRules.brandVoice.trim().isNotEmpty &&
          businessRules.allowedSupportTopics.isNotEmpty,
    );

    return ProjectStatusSnapshot(
      progress: _weightedProjectProgress(items),
      currentPhase: _currentProjectPhase(items),
      items: items,
      recommendations: recommendations,
    );
  }

  ProjectCompletionState companyProfileCompletion(CompanyWorkspace workspace) {
    final c = workspace.company;
    final rules = workspace.businessRules;
    final checks = [
      c.name.isNotEmpty,
      c.description.isNotEmpty,
      c.industry.isNotEmpty,
      c.country.isNotEmpty,
      c.primaryLanguage.isNotEmpty,
      c.website.isNotEmpty,
      c.email.isNotEmpty,
      c.socialLinks.values.any((value) => value.trim().isNotEmpty),
      rules.brandVoice.isNotEmpty,
      rules.allowedSupportTopics.isNotEmpty,
    ];
    final complete = checks.where((check) => check).length;
    if (complete >= 8) return ProjectCompletionState.complete;
    if (complete >= 4) return ProjectCompletionState.partial;
    return ProjectCompletionState.missing;
  }

  ProjectCompletionState intakeCompletion(IntakeSession? session) {
    if (session == null) return ProjectCompletionState.missing;
    if (session.importedAt != null ||
        session.status == IntakeStatus.completed) {
      return ProjectCompletionState.complete;
    }
    if (session.status == IntakeStatus.inProgress ||
        session.chatStartedAt != null) {
      return ProjectCompletionState.partial;
    }
    return ProjectCompletionState.missing;
  }

  ProjectCompletionState countCompletion(
    int count, {
    required int partialAt,
    required int completeAt,
  }) {
    if (count >= completeAt) return ProjectCompletionState.complete;
    if (count >= partialAt) return ProjectCompletionState.partial;
    return ProjectCompletionState.missing;
  }

  ProjectCompletionState sourcesCompletion(List<SourceMaterial> sources) {
    if (sources.any(
      (source) => source.status == SourceMaterialStatus.converted,
    )) {
      return ProjectCompletionState.complete;
    }
    if (sources.isNotEmpty) return ProjectCompletionState.partial;
    return ProjectCompletionState.missing;
  }

  ProjectCompletionState websiteAnalysisCompletion(CompanyWorkspace workspace) {
    final website = workspace.company.website.trim();
    final intakeWebsite =
        workspace.intakeSession?.websiteAndSupport.websiteUrl.trim() ?? '';
    final hasWebsite = website.isNotEmpty || intakeWebsite.isNotEmpty;
    if (!hasWebsite) return ProjectCompletionState.missing;

    final websiteSources = workspace.sourceMaterials.where(
      (source) => source.type == SourceMaterialType.website,
    );
    if (websiteSources.any(
      (source) =>
          source.status == SourceMaterialStatus.reviewed ||
          source.status == SourceMaterialStatus.converted,
    )) {
      return ProjectCompletionState.complete;
    }
    if (websiteSources.isNotEmpty) return ProjectCompletionState.partial;
    return ProjectCompletionState.partial;
  }

  ProjectCompletionState controllingCompletion(CompanyWorkspace workspace) {
    final hasActivity = workspace.botLogs.length >= 5;
    final hasEnoughKnowledge = workspace.knowledgeEntries.length >= 12;
    final hasAuditBaseline = auditScoreFor(workspace) >= 0.6;
    if (hasActivity && hasEnoughKnowledge && hasAuditBaseline) {
      return ProjectCompletionState.complete;
    }
    if (workspace.botLogs.isNotEmpty || hasAuditBaseline) {
      return ProjectCompletionState.partial;
    }
    return ProjectCompletionState.missing;
  }

  double auditScoreFor(CompanyWorkspace workspace) {
    return _auditScoreForItems(workspace.auditItems);
  }

  int openReviewCountFor(CompanyWorkspace workspace) {
    return workspace.botLogs
        .where((log) => log.reviewStatus == ReviewStatus.open)
        .length;
  }

  double completionValue(ProjectCompletionState completion) {
    return switch (completion) {
      ProjectCompletionState.complete => 1,
      ProjectCompletionState.partial => 0.5,
      ProjectCompletionState.missing => 0,
    };
  }

  double _weightedProjectProgress(List<ProjectStatusItem> items) {
    if (items.isEmpty) return 0;
    final maxScore = items.fold<double>(0, (sum, item) => sum + item.weight);
    final score = items.fold<double>(
      0,
      (sum, item) => sum + item.weight * item.completionValue,
    );
    return maxScore == 0 ? 0 : score / maxScore;
  }

  ProjectPhase _currentProjectPhase(List<ProjectStatusItem> items) {
    const phases = [
      ProjectPhase.company,
      ProjectPhase.knowledge,
      ProjectPhase.ai,
      ProjectPhase.marketing,
      ProjectPhase.controlling,
    ];
    for (final phase in phases) {
      final phaseItems = items.where((item) => item.phase == phase);
      if (phaseItems.any((item) => item.isOpen)) return phase;
    }
    return ProjectPhase.controlling;
  }

  List<ProjectRecommendation> _buildProjectRecommendations({
    required CompanyWorkspace workspace,
    required List<ProjectStatusItem> items,
    required double auditScore,
    required int knowledgeCount,
    required int openReviews,
    required bool businessRulesComplete,
  }) {
    final recommendations = <ProjectRecommendation>[];
    void add(ProjectTaskType type, ProjectTaskPriority priority, String route) {
      final item = items.firstWhere((candidate) => candidate.type == type);
      if (item.isComplete) return;
      if (recommendations.any((entry) => entry.type == type)) return;
      recommendations.add(
        ProjectRecommendation(
          type: type,
          phase: item.phase,
          priority: priority,
          route: route,
        ),
      );
    }

    final highPriorityMissing = workspace.auditItems.where(
      (item) =>
          item.priority == AuditPriority.high &&
          item.status == AuditItemStatus.missing,
    );
    if (highPriorityMissing.isNotEmpty || auditScore < 0.6) {
      add(ProjectTaskType.audit, ProjectTaskPriority.high, '/audit');
    }
    if (companyProfileCompletion(workspace) !=
            ProjectCompletionState.complete ||
        !businessRulesComplete) {
      add(ProjectTaskType.companyProfile, ProjectTaskPriority.high, '/company');
    }
    if (workspace.intakeSession == null ||
        intakeCompletion(workspace.intakeSession) !=
            ProjectCompletionState.complete) {
      add(ProjectTaskType.intake, ProjectTaskPriority.high, '/intake');
    }
    if (knowledgeCount < 4) {
      add(
        ProjectTaskType.knowledgeBase,
        ProjectTaskPriority.high,
        '/knowledge',
      );
    } else if (knowledgeCount < 12) {
      add(
        ProjectTaskType.knowledgeBase,
        ProjectTaskPriority.medium,
        '/knowledge',
      );
    }
    final newSources = workspace.sourceMaterials.where(
      (source) => source.status == SourceMaterialStatus.newItem,
    );
    if (workspace.sourceMaterials.isEmpty || newSources.isNotEmpty) {
      add(ProjectTaskType.sources, ProjectTaskPriority.medium, '/sources');
    }
    if (websiteAnalysisCompletion(workspace) !=
        ProjectCompletionState.complete) {
      add(
        ProjectTaskType.websiteAnalysis,
        ProjectTaskPriority.medium,
        '/sources',
      );
    }
    if (workspace.botConfiguration.status == BotStatus.draft) {
      add(
        ProjectTaskType.botActivation,
        ProjectTaskPriority.high,
        '/bot-settings',
      );
    } else if (workspace.botConfiguration.status == BotStatus.testReady) {
      add(
        ProjectTaskType.botActivation,
        ProjectTaskPriority.medium,
        '/bot-test',
      );
    }
    if (openReviews > 0) {
      add(
        ProjectTaskType.humanReview,
        openReviews >= 3
            ? ProjectTaskPriority.high
            : ProjectTaskPriority.medium,
        '/review',
      );
    }
    if (marketingStrategyCalculator.marketingCompletion(workspace) !=
        ProjectCompletionState.complete) {
      add(
        ProjectTaskType.marketing,
        ProjectTaskPriority.medium,
        '/marketing-strategy',
      );
    }
    if (controllingCompletion(workspace) != ProjectCompletionState.complete) {
      add(ProjectTaskType.controlling, ProjectTaskPriority.low, '/dashboard');
    }

    recommendations.sort((a, b) {
      final priority = _projectPriorityRank(
        b.priority,
      ).compareTo(_projectPriorityRank(a.priority));
      if (priority != 0) return priority;
      return _phaseRank(a.phase).compareTo(_phaseRank(b.phase));
    });
    return recommendations;
  }

  double _auditScoreForItems(List<BusinessAuditItem> items) {
    if (items.isEmpty) return 0.0;
    double score = 0;
    double maxScore = 0;
    for (final item in items) {
      final weight = _priorityWeight(item.priority);
      maxScore += weight;
      score += switch (item.status) {
        AuditItemStatus.complete => weight,
        AuditItemStatus.partial => weight * 0.5,
        AuditItemStatus.missing => 0,
      };
    }
    return maxScore == 0 ? 0.0 : score / maxScore;
  }

  int _priorityWeight(AuditPriority priority) {
    return switch (priority) {
      AuditPriority.low => 1,
      AuditPriority.medium => 2,
      AuditPriority.high => 3,
    };
  }

  int _projectPriorityRank(ProjectTaskPriority priority) {
    return switch (priority) {
      ProjectTaskPriority.high => 3,
      ProjectTaskPriority.medium => 2,
      ProjectTaskPriority.low => 1,
    };
  }

  int _phaseRank(ProjectPhase phase) {
    return switch (phase) {
      ProjectPhase.company => 0,
      ProjectPhase.knowledge => 1,
      ProjectPhase.ai => 2,
      ProjectPhase.marketing => 3,
      ProjectPhase.controlling => 4,
    };
  }
}
