enum MarketingActionType {
  optimizeWebsite,
  createGoogleBusiness,
  maintainFacebook,
  startInstagram,
  useLinkedIn,
  expandFaq,
  collectReviews,
  prepareNewsletter,
  integrateBotWebsite,
  improveSeo,
  checkGoogleAds,
  checkFacebookAds,
}

enum MarketingActionStatus {
  notStarted,
  planned,
  inProgress,
  completed,
  postponed,
}

enum MarketingActionPriority { low, medium, high }

enum MarketingActionEffort { low, medium, high }

enum MarketingActionImpact { low, medium, high }

class MarketingAction {
  final String id;
  final MarketingActionType type;
  final MarketingActionPriority priority;
  final MarketingActionEffort effort;
  final MarketingActionImpact impact;
  final MarketingActionStatus status;
  final String notes;
  final double? plannedBudget;
  final double? usedBudget;
  final String budgetComment;

  const MarketingAction({
    required this.id,
    required this.type,
    required this.priority,
    required this.effort,
    required this.impact,
    this.status = MarketingActionStatus.notStarted,
    this.notes = '',
    this.plannedBudget,
    this.usedBudget,
    this.budgetComment = '',
  });

  MarketingAction copyWith({
    MarketingActionPriority? priority,
    MarketingActionEffort? effort,
    MarketingActionImpact? impact,
    MarketingActionStatus? status,
    String? notes,
    Object? plannedBudget = _keep,
    Object? usedBudget = _keep,
    String? budgetComment,
  }) {
    return MarketingAction(
      id: id,
      type: type,
      priority: priority ?? this.priority,
      effort: effort ?? this.effort,
      impact: impact ?? this.impact,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      plannedBudget: identical(plannedBudget, _keep)
          ? this.plannedBudget
          : (plannedBudget as num?)?.toDouble(),
      usedBudget: identical(usedBudget, _keep)
          ? this.usedBudget
          : (usedBudget as num?)?.toDouble(),
      budgetComment: budgetComment ?? this.budgetComment,
    );
  }
}

class MarketingStrategySnapshot {
  final int score;
  final List<MarketingAction> actions;
  final List<MarketingActionType> recommendedActionTypes;

  const MarketingStrategySnapshot({
    required this.score,
    required this.actions,
    required this.recommendedActionTypes,
  });

  int get openActionCount => actions
      .where(
        (action) =>
            action.status == MarketingActionStatus.notStarted ||
            action.status == MarketingActionStatus.planned,
      )
      .length;

  int get inProgressActionCount => actions
      .where((action) => action.status == MarketingActionStatus.inProgress)
      .length;

  int get completedActionCount => actions
      .where((action) => action.status == MarketingActionStatus.completed)
      .length;

  List<MarketingAction> get recommendedActions => actions
      .where((action) => recommendedActionTypes.contains(action.type))
      .toList();
}

const Object _keep = Object();
