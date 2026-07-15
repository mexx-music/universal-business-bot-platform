enum BusinessGoalPriority { low, medium, high }

enum BusinessGoalStatus {
  notStarted,
  planned,
  inProgress,
  achieved,
  paused,
  canceled,
}

enum BusinessGoalArea {
  marketing,
  audit,
  knowledgeBase,
  bot,
  humanReview,
  sources,
  companyProfile,
  projectStatus,
  controlling,
}

class BusinessGoal {
  final String id;
  final String title;
  final String description;
  final BusinessGoalPriority priority;
  final DateTime startDate;
  final DateTime targetDate;
  final BusinessGoalStatus status;
  final String owner;
  final String comment;
  final List<BusinessGoalArea> linkedAreas;

  const BusinessGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.startDate,
    required this.targetDate,
    required this.status,
    required this.owner,
    this.comment = '',
    required this.linkedAreas,
  });

  BusinessGoal copyWith({
    String? title,
    String? description,
    BusinessGoalPriority? priority,
    DateTime? startDate,
    DateTime? targetDate,
    BusinessGoalStatus? status,
    String? owner,
    String? comment,
    List<BusinessGoalArea>? linkedAreas,
  }) {
    return BusinessGoal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      owner: owner ?? this.owner,
      comment: comment ?? this.comment,
      linkedAreas: linkedAreas ?? this.linkedAreas,
    );
  }
}

class BusinessGoalProgress {
  final BusinessGoal goal;
  final double progress;
  final Map<BusinessGoalArea, double> moduleContributions;

  const BusinessGoalProgress({
    required this.goal,
    required this.progress,
    required this.moduleContributions,
  });
}

class BusinessGoalRecommendation {
  final BusinessGoal goal;
  final BusinessGoalArea area;
  final String route;

  const BusinessGoalRecommendation({
    required this.goal,
    required this.area,
    required this.route,
  });
}

class BusinessStrategySnapshot {
  final List<BusinessGoalProgress> goals;
  final BusinessGoalRecommendation? nextRecommendation;

  const BusinessStrategySnapshot({
    required this.goals,
    required this.nextRecommendation,
  });

  List<BusinessGoalProgress> get activeGoals => goals
      .where(
        (entry) =>
            entry.goal.status != BusinessGoalStatus.achieved &&
            entry.goal.status != BusinessGoalStatus.canceled,
      )
      .toList();

  BusinessGoalProgress? get mainGoal {
    if (activeGoals.isEmpty) return goals.isEmpty ? null : goals.first;
    final sorted = [...activeGoals]
      ..sort((a, b) {
        final priority = _priorityRank(
          b.goal.priority,
        ).compareTo(_priorityRank(a.goal.priority));
        if (priority != 0) return priority;
        return a.progress.compareTo(b.progress);
      });
    return sorted.first;
  }

  double get averageProgress {
    if (goals.isEmpty) return 0;
    return goals.fold<double>(0, (sum, entry) => sum + entry.progress) /
        goals.length;
  }

  int get activeGoalCount => activeGoals.length;

  BusinessGoalPriority? get highestPriority => mainGoal?.goal.priority;
}

int _priorityRank(BusinessGoalPriority priority) {
  return switch (priority) {
    BusinessGoalPriority.high => 3,
    BusinessGoalPriority.medium => 2,
    BusinessGoalPriority.low => 1,
  };
}
