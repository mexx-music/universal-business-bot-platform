enum ProjectPhase { company, knowledge, ai, marketing, controlling }

enum ProjectCompletionState { missing, partial, complete }

enum ProjectTaskPriority { low, medium, high }

enum ProjectTaskType {
  companyProfile,
  intake,
  knowledgeBase,
  sources,
  audit,
  websiteAnalysis,
  marketing,
  botActivation,
  humanReview,
  controlling,
}

class ProjectStatusItem {
  final ProjectTaskType type;
  final ProjectPhase phase;
  final ProjectCompletionState completion;
  final ProjectTaskPriority priority;
  final String route;
  final double weight;

  const ProjectStatusItem({
    required this.type,
    required this.phase,
    required this.completion,
    required this.priority,
    required this.route,
    this.weight = 1,
  });

  bool get isComplete => completion == ProjectCompletionState.complete;

  bool get isOpen => !isComplete;

  double get completionValue {
    return switch (completion) {
      ProjectCompletionState.complete => 1,
      ProjectCompletionState.partial => 0.5,
      ProjectCompletionState.missing => 0,
    };
  }
}

class ProjectRecommendation {
  final ProjectTaskType type;
  final ProjectPhase phase;
  final ProjectTaskPriority priority;
  final String route;

  const ProjectRecommendation({
    required this.type,
    required this.phase,
    required this.priority,
    required this.route,
  });
}

class ProjectStatusSnapshot {
  final double progress;
  final ProjectPhase currentPhase;
  final List<ProjectStatusItem> items;
  final List<ProjectRecommendation> recommendations;

  const ProjectStatusSnapshot({
    required this.progress,
    required this.currentPhase,
    required this.items,
    required this.recommendations,
  });

  int get totalTaskCount => items.length;

  int get completedTaskCount => items.where((item) => item.isComplete).length;

  int get openTaskCount => items.where((item) => item.isOpen).length;

  int get highPriorityOpenCount => items
      .where((item) => item.isOpen && item.priority == ProjectTaskPriority.high)
      .length;

  ProjectRecommendation? get nextRecommendation {
    return recommendations.isEmpty ? null : recommendations.first;
  }
}
