import '../models/bot_configuration.dart';
import '../models/bot_question_log.dart';
import '../models/company_workspace.dart';
import '../models/knowledge_entry.dart';
import '../models/marketing_strategy.dart';
import '../models/project_status.dart';
import '../models/source_material.dart';

class MarketingStrategyCalculator {
  const MarketingStrategyCalculator();

  MarketingStrategySnapshot calculate(CompanyWorkspace workspace) {
    final actions = actionsFor(workspace);
    return MarketingStrategySnapshot(
      score: _marketingScoreFor(workspace, actions),
      actions: actions,
      recommendedActionTypes: _recommendedMarketingActionsFor(workspace),
    );
  }

  List<MarketingAction> actionsFor(CompanyWorkspace workspace) {
    final stored = {
      for (final action in workspace.marketingActions) action.type: action,
    };
    return MarketingActionType.values
        .map(
          (type) =>
              stored[type] ??
              MarketingAction(
                id: 'marketing_${type.name}',
                type: type,
                priority: _defaultMarketingPriority(type),
                effort: _defaultMarketingEffort(type),
                impact: _defaultMarketingImpact(type),
              ),
        )
        .toList();
  }

  ProjectCompletionState marketingCompletion(CompanyWorkspace workspace) {
    final marketing = workspace.intakeSession?.marketingAndChannels;
    final actions = actionsFor(workspace);
    final completedActions = actions
        .where((action) => action.status == MarketingActionStatus.completed)
        .length;
    final activeActions = actions.where(
      (action) =>
          action.status == MarketingActionStatus.inProgress ||
          action.status == MarketingActionStatus.planned,
    );
    final hasSocialLinks = workspace.company.socialLinks.values.any(
      (value) => value.trim().isNotEmpty,
    );
    if (completedActions >= 3) {
      return ProjectCompletionState.complete;
    }
    if (marketing == null) {
      return hasSocialLinks || activeActions.isNotEmpty
          ? ProjectCompletionState.partial
          : ProjectCompletionState.missing;
    }
    final details = _joinNonEmpty([
      marketing.channels,
      marketing.campaigns,
      marketing.socialPlatforms,
      marketing.socialProfileLinks,
      marketing.workingChannels,
      marketing.advertisingChannels,
      marketing.availableMetrics,
      marketing.futureSocialPlatforms,
      marketing.futureAdChannels,
    ]);
    if (details.isNotEmpty && hasSocialLinks && completedActions > 0) {
      return ProjectCompletionState.complete;
    }
    if (details.isNotEmpty || hasSocialLinks || activeActions.isNotEmpty) {
      return ProjectCompletionState.partial;
    }
    return ProjectCompletionState.missing;
  }

  int _marketingScoreFor(
    CompanyWorkspace workspace,
    List<MarketingAction> actions,
  ) {
    final company = workspace.company;
    final social = company.socialLinks.map(
      (key, value) => MapEntry(key.toLowerCase(), value.trim()),
    );
    final faqCount = workspace.knowledgeEntries
        .where((entry) => entry.category == KnowledgeCategory.faq)
        .length;
    final hasReviewMaterial = workspace.sourceMaterials.any(
      (source) =>
          source.type == SourceMaterialType.review &&
          source.status != SourceMaterialStatus.ignored,
    );
    final convertedOrReviewedSources = workspace.sourceMaterials
        .where(
          (source) =>
              source.status == SourceMaterialStatus.converted ||
              source.status == SourceMaterialStatus.reviewed,
        )
        .length;
    final completedActions = actions
        .where((action) => action.status == MarketingActionStatus.completed)
        .length;

    var score = 0;
    if (company.website.trim().isNotEmpty) score += 12;
    if (_hasSocial(social, ['google', 'googlebusiness', 'google business'])) {
      score += 8;
    }
    if (_hasSocial(social, ['facebook'])) score += 8;
    if (_hasSocial(social, ['instagram'])) score += 8;
    if (_hasSocial(social, ['linkedin'])) score += 8;
    if (_hasSocial(social, ['tiktok'])) score += 6;
    if (faqCount >= 5) {
      score += 12;
    } else if (faqCount > 0) {
      score += 6;
    }
    if (hasReviewMaterial) score += 10;
    if (workspace.knowledgeEntries.length >= 12) {
      score += 10;
    } else if (workspace.knowledgeEntries.length >= 4) {
      score += 5;
    }
    if (workspace.botConfiguration.status == BotStatus.active) {
      score += 10;
    } else if (workspace.botConfiguration.status == BotStatus.testReady) {
      score += 6;
    }
    if (convertedOrReviewedSources >= 3) {
      score += 10;
    } else if (convertedOrReviewedSources > 0) {
      score += 5;
    }
    if (_openReviewCountFor(workspace) == 0) score += 6;
    score += completedActions.clamp(0, 4);
    return score.clamp(0, 100);
  }

  List<MarketingActionType> _recommendedMarketingActionsFor(
    CompanyWorkspace workspace,
  ) {
    final recommendations = <MarketingActionType>[];
    final company = workspace.company;
    final social = company.socialLinks.map(
      (key, value) => MapEntry(key.toLowerCase(), value.trim()),
    );
    final faqCount = workspace.knowledgeEntries
        .where((entry) => entry.category == KnowledgeCategory.faq)
        .length;
    final reviewSources = workspace.sourceMaterials.where(
      (source) => source.type == SourceMaterialType.review,
    );
    final newSources = workspace.sourceMaterials.where(
      (source) => source.status == SourceMaterialStatus.newItem,
    );

    void add(MarketingActionType type) {
      if (!recommendations.contains(type)) recommendations.add(type);
    }

    if (company.website.trim().isEmpty) {
      add(MarketingActionType.optimizeWebsite);
    } else {
      add(MarketingActionType.improveSeo);
    }
    if (!_hasSocial(social, ['google', 'googlebusiness', 'google business'])) {
      add(MarketingActionType.createGoogleBusiness);
    }
    if (!_hasSocial(social, ['facebook'])) {
      add(MarketingActionType.maintainFacebook);
    }
    if (!_hasSocial(social, ['instagram'])) {
      add(MarketingActionType.startInstagram);
    }
    if (!_hasSocial(social, ['linkedin'])) {
      add(MarketingActionType.useLinkedIn);
    }
    if (faqCount < 8) {
      add(MarketingActionType.expandFaq);
    }
    if (reviewSources.isEmpty) {
      add(MarketingActionType.collectReviews);
    } else if (reviewSources.length >= 2) {
      add(MarketingActionType.optimizeWebsite);
    }
    if (workspace.sourceMaterials.isEmpty || newSources.isNotEmpty) {
      add(MarketingActionType.improveSeo);
    }
    if (workspace.botConfiguration.status != BotStatus.active) {
      add(MarketingActionType.integrateBotWebsite);
    }
    if (marketingCompletion(workspace) != ProjectCompletionState.complete) {
      add(MarketingActionType.prepareNewsletter);
    }
    add(MarketingActionType.checkGoogleAds);
    add(MarketingActionType.checkFacebookAds);
    return recommendations;
  }

  bool _hasSocial(Map<String, String> social, List<String> aliases) {
    return social.entries.any(
      (entry) =>
          entry.value.isNotEmpty &&
          aliases.any(
            (alias) => entry.key
                .replaceAll(' ', '')
                .contains(alias.replaceAll(' ', '')),
          ),
    );
  }

  int _openReviewCountFor(CompanyWorkspace workspace) {
    return workspace.botLogs
        .where((log) => log.reviewStatus == ReviewStatus.open)
        .length;
  }

  String _joinNonEmpty(Iterable<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join('\n\n');
  }

  MarketingActionPriority _defaultMarketingPriority(MarketingActionType type) {
    return switch (type) {
      MarketingActionType.optimizeWebsite ||
      MarketingActionType.createGoogleBusiness ||
      MarketingActionType.expandFaq ||
      MarketingActionType.collectReviews ||
      MarketingActionType.integrateBotWebsite ||
      MarketingActionType.improveSeo => MarketingActionPriority.high,
      MarketingActionType.startInstagram ||
      MarketingActionType.useLinkedIn ||
      MarketingActionType.prepareNewsletter => MarketingActionPriority.medium,
      MarketingActionType.maintainFacebook ||
      MarketingActionType.checkGoogleAds ||
      MarketingActionType.checkFacebookAds => MarketingActionPriority.low,
    };
  }

  MarketingActionEffort _defaultMarketingEffort(MarketingActionType type) {
    return switch (type) {
      MarketingActionType.optimizeWebsite ||
      MarketingActionType.improveSeo ||
      MarketingActionType.integrateBotWebsite => MarketingActionEffort.high,
      MarketingActionType.expandFaq ||
      MarketingActionType.prepareNewsletter ||
      MarketingActionType.checkGoogleAds ||
      MarketingActionType.checkFacebookAds => MarketingActionEffort.medium,
      MarketingActionType.createGoogleBusiness ||
      MarketingActionType.maintainFacebook ||
      MarketingActionType.startInstagram ||
      MarketingActionType.useLinkedIn ||
      MarketingActionType.collectReviews => MarketingActionEffort.low,
    };
  }

  MarketingActionImpact _defaultMarketingImpact(MarketingActionType type) {
    return switch (type) {
      MarketingActionType.optimizeWebsite ||
      MarketingActionType.createGoogleBusiness ||
      MarketingActionType.expandFaq ||
      MarketingActionType.collectReviews ||
      MarketingActionType.integrateBotWebsite ||
      MarketingActionType.improveSeo => MarketingActionImpact.high,
      MarketingActionType.startInstagram ||
      MarketingActionType.useLinkedIn ||
      MarketingActionType.prepareNewsletter ||
      MarketingActionType.checkGoogleAds => MarketingActionImpact.medium,
      MarketingActionType.maintainFacebook ||
      MarketingActionType.checkFacebookAds => MarketingActionImpact.low,
    };
  }
}
