// Deterministic Operations Center demo data. There is no backend, AI call,
// tracking or background process behind these figures. The dashboard labels
// every value as DEMO and hides the dataset when demo mode is disabled.

class OperationsDay {
  const OperationsDay({
    required this.questions,
    required this.answered,
    required this.knowledgeGaps,
    required this.humanReviews,
    required this.newEntries,
    required this.websiteRedirects,
    required this.documentsAnalyzed,
    required this.sourcesUsed,
    required this.averageResponseSeconds,
    required this.supportQuestions,
  });

  final int questions;
  final int answered;
  final int knowledgeGaps;
  final int humanReviews;
  final int newEntries;
  final int websiteRedirects;
  final int documentsAnalyzed;
  final int sourcesUsed;
  final double averageResponseSeconds;
  final int supportQuestions;
}

class OperationsRankedItem {
  const OperationsRankedItem(this.key, this.count);

  final String key;
  final int count;
}

class KnowledgeGrowthDemo {
  const KnowledgeGrowthDemo({
    required this.confirmedEntries,
    required this.newFaq,
    required this.productKnowledge,
    required this.supportKnowledge,
    required this.documents,
    required this.tags,
  });

  final int confirmedEntries;
  final int newFaq;
  final int productKnowledge;
  final int supportKnowledge;
  final int documents;
  final int tags;
}

class KnowledgeQualityDemo {
  const KnowledgeQualityDemo({
    required this.fullyAnswerable,
    required this.partlyAnswerable,
    required this.noInformation,
    required this.medicallySensitive,
    required this.redirects,
  });

  final int fullyAnswerable;
  final int partlyAnswerable;
  final int noInformation;
  final int medicallySensitive;
  final int redirects;

  int get answerabilityTotal =>
      fullyAnswerable + partlyAnswerable + noInformation;
}

class OperationsDemo {
  const OperationsDemo._();

  static const today = OperationsDay(
    questions: 24,
    answered: 21,
    knowledgeGaps: 4,
    humanReviews: 6,
    newEntries: 2,
    websiteRedirects: 12,
    documentsAnalyzed: 3,
    sourcesUsed: 57,
    averageResponseSeconds: 1.8,
    supportQuestions: 7,
  );

  /// Oldest to newest. The final element is [today]. Values stay deliberately
  /// modest and make a coherent 30-day demonstration, not a growth claim.
  static const List<OperationsDay> history = [
    OperationsDay(
      questions: 12,
      answered: 10,
      knowledgeGaps: 3,
      humanReviews: 2,
      newEntries: 1,
      websiteRedirects: 4,
      documentsAnalyzed: 1,
      sourcesUsed: 23,
      averageResponseSeconds: 2.4,
      supportQuestions: 2,
    ),
    OperationsDay(
      questions: 14,
      answered: 12,
      knowledgeGaps: 3,
      humanReviews: 3,
      newEntries: 1,
      websiteRedirects: 5,
      documentsAnalyzed: 1,
      sourcesUsed: 27,
      averageResponseSeconds: 2.3,
      supportQuestions: 2,
    ),
    OperationsDay(
      questions: 11,
      answered: 9,
      knowledgeGaps: 2,
      humanReviews: 2,
      newEntries: 0,
      websiteRedirects: 3,
      documentsAnalyzed: 0,
      sourcesUsed: 21,
      averageResponseSeconds: 2.5,
      supportQuestions: 2,
    ),
    OperationsDay(
      questions: 15,
      answered: 13,
      knowledgeGaps: 3,
      humanReviews: 3,
      newEntries: 1,
      websiteRedirects: 5,
      documentsAnalyzed: 1,
      sourcesUsed: 29,
      averageResponseSeconds: 2.3,
      supportQuestions: 3,
    ),
    OperationsDay(
      questions: 13,
      answered: 11,
      knowledgeGaps: 2,
      humanReviews: 2,
      newEntries: 1,
      websiteRedirects: 4,
      documentsAnalyzed: 1,
      sourcesUsed: 25,
      averageResponseSeconds: 2.2,
      supportQuestions: 2,
    ),
    OperationsDay(
      questions: 16,
      answered: 14,
      knowledgeGaps: 3,
      humanReviews: 3,
      newEntries: 1,
      websiteRedirects: 6,
      documentsAnalyzed: 1,
      sourcesUsed: 31,
      averageResponseSeconds: 2.2,
      supportQuestions: 3,
    ),
    OperationsDay(
      questions: 14,
      answered: 12,
      knowledgeGaps: 2,
      humanReviews: 2,
      newEntries: 0,
      websiteRedirects: 5,
      documentsAnalyzed: 0,
      sourcesUsed: 28,
      averageResponseSeconds: 2.3,
      supportQuestions: 3,
    ),
    OperationsDay(
      questions: 17,
      answered: 15,
      knowledgeGaps: 3,
      humanReviews: 4,
      newEntries: 1,
      websiteRedirects: 6,
      documentsAnalyzed: 1,
      sourcesUsed: 34,
      averageResponseSeconds: 2.1,
      supportQuestions: 3,
    ),
    OperationsDay(
      questions: 15,
      answered: 13,
      knowledgeGaps: 3,
      humanReviews: 3,
      newEntries: 1,
      websiteRedirects: 5,
      documentsAnalyzed: 1,
      sourcesUsed: 30,
      averageResponseSeconds: 2.2,
      supportQuestions: 3,
    ),
    OperationsDay(
      questions: 18,
      answered: 16,
      knowledgeGaps: 3,
      humanReviews: 4,
      newEntries: 1,
      websiteRedirects: 7,
      documentsAnalyzed: 1,
      sourcesUsed: 37,
      averageResponseSeconds: 2.1,
      supportQuestions: 4,
    ),
    OperationsDay(
      questions: 16,
      answered: 14,
      knowledgeGaps: 2,
      humanReviews: 3,
      newEntries: 1,
      websiteRedirects: 6,
      documentsAnalyzed: 1,
      sourcesUsed: 33,
      averageResponseSeconds: 2.1,
      supportQuestions: 3,
    ),
    OperationsDay(
      questions: 19,
      answered: 16,
      knowledgeGaps: 4,
      humanReviews: 4,
      newEntries: 1,
      websiteRedirects: 7,
      documentsAnalyzed: 1,
      sourcesUsed: 39,
      averageResponseSeconds: 2.0,
      supportQuestions: 4,
    ),
    OperationsDay(
      questions: 17,
      answered: 15,
      knowledgeGaps: 3,
      humanReviews: 3,
      newEntries: 1,
      websiteRedirects: 6,
      documentsAnalyzed: 1,
      sourcesUsed: 35,
      averageResponseSeconds: 2.1,
      supportQuestions: 4,
    ),
    OperationsDay(
      questions: 20,
      answered: 17,
      knowledgeGaps: 4,
      humanReviews: 4,
      newEntries: 1,
      websiteRedirects: 8,
      documentsAnalyzed: 1,
      sourcesUsed: 42,
      averageResponseSeconds: 2.0,
      supportQuestions: 4,
    ),
    OperationsDay(
      questions: 18,
      answered: 16,
      knowledgeGaps: 3,
      humanReviews: 4,
      newEntries: 1,
      websiteRedirects: 7,
      documentsAnalyzed: 1,
      sourcesUsed: 38,
      averageResponseSeconds: 2.0,
      supportQuestions: 4,
    ),
    OperationsDay(
      questions: 21,
      answered: 18,
      knowledgeGaps: 4,
      humanReviews: 5,
      newEntries: 2,
      websiteRedirects: 8,
      documentsAnalyzed: 2,
      sourcesUsed: 45,
      averageResponseSeconds: 1.9,
      supportQuestions: 5,
    ),
    OperationsDay(
      questions: 19,
      answered: 17,
      knowledgeGaps: 3,
      humanReviews: 4,
      newEntries: 1,
      websiteRedirects: 7,
      documentsAnalyzed: 1,
      sourcesUsed: 41,
      averageResponseSeconds: 2.0,
      supportQuestions: 4,
    ),
    OperationsDay(
      questions: 22,
      answered: 19,
      knowledgeGaps: 4,
      humanReviews: 5,
      newEntries: 2,
      websiteRedirects: 9,
      documentsAnalyzed: 2,
      sourcesUsed: 48,
      averageResponseSeconds: 1.9,
      supportQuestions: 5,
    ),
    OperationsDay(
      questions: 20,
      answered: 18,
      knowledgeGaps: 3,
      humanReviews: 4,
      newEntries: 1,
      websiteRedirects: 8,
      documentsAnalyzed: 1,
      sourcesUsed: 44,
      averageResponseSeconds: 1.9,
      supportQuestions: 5,
    ),
    OperationsDay(
      questions: 23,
      answered: 20,
      knowledgeGaps: 4,
      humanReviews: 5,
      newEntries: 2,
      websiteRedirects: 10,
      documentsAnalyzed: 2,
      sourcesUsed: 51,
      averageResponseSeconds: 1.8,
      supportQuestions: 5,
    ),
    OperationsDay(
      questions: 21,
      answered: 18,
      knowledgeGaps: 4,
      humanReviews: 5,
      newEntries: 1,
      websiteRedirects: 9,
      documentsAnalyzed: 1,
      sourcesUsed: 46,
      averageResponseSeconds: 1.9,
      supportQuestions: 5,
    ),
    OperationsDay(
      questions: 22,
      answered: 19,
      knowledgeGaps: 4,
      humanReviews: 5,
      newEntries: 2,
      websiteRedirects: 9,
      documentsAnalyzed: 2,
      sourcesUsed: 49,
      averageResponseSeconds: 1.8,
      supportQuestions: 5,
    ),
    OperationsDay(
      questions: 20,
      answered: 17,
      knowledgeGaps: 4,
      humanReviews: 4,
      newEntries: 1,
      websiteRedirects: 8,
      documentsAnalyzed: 1,
      sourcesUsed: 43,
      averageResponseSeconds: 1.9,
      supportQuestions: 5,
    ),
    OperationsDay(
      questions: 23,
      answered: 20,
      knowledgeGaps: 4,
      humanReviews: 5,
      newEntries: 2,
      websiteRedirects: 10,
      documentsAnalyzed: 2,
      sourcesUsed: 52,
      averageResponseSeconds: 1.8,
      supportQuestions: 6,
    ),
    OperationsDay(
      questions: 21,
      answered: 18,
      knowledgeGaps: 4,
      humanReviews: 5,
      newEntries: 1,
      websiteRedirects: 9,
      documentsAnalyzed: 1,
      sourcesUsed: 47,
      averageResponseSeconds: 1.9,
      supportQuestions: 5,
    ),
    OperationsDay(
      questions: 22,
      answered: 19,
      knowledgeGaps: 4,
      humanReviews: 5,
      newEntries: 2,
      websiteRedirects: 10,
      documentsAnalyzed: 2,
      sourcesUsed: 50,
      averageResponseSeconds: 1.8,
      supportQuestions: 6,
    ),
    OperationsDay(
      questions: 23,
      answered: 20,
      knowledgeGaps: 4,
      humanReviews: 5,
      newEntries: 2,
      websiteRedirects: 11,
      documentsAnalyzed: 2,
      sourcesUsed: 53,
      averageResponseSeconds: 1.8,
      supportQuestions: 6,
    ),
    OperationsDay(
      questions: 22,
      answered: 19,
      knowledgeGaps: 4,
      humanReviews: 5,
      newEntries: 1,
      websiteRedirects: 10,
      documentsAnalyzed: 1,
      sourcesUsed: 50,
      averageResponseSeconds: 1.9,
      supportQuestions: 6,
    ),
    OperationsDay(
      questions: 23,
      answered: 20,
      knowledgeGaps: 4,
      humanReviews: 6,
      newEntries: 2,
      websiteRedirects: 11,
      documentsAnalyzed: 2,
      sourcesUsed: 54,
      averageResponseSeconds: 1.8,
      supportQuestions: 7,
    ),
    today,
  ];

  static const knowledgeGrowth = KnowledgeGrowthDemo(
    confirmedEntries: 27,
    newFaq: 2,
    productKnowledge: 9,
    supportKnowledge: 6,
    documents: 9,
    tags: 34,
  );

  static const knowledgeQuality = KnowledgeQualityDemo(
    fullyAnswerable: 21,
    partlyAnswerable: 2,
    noInformation: 1,
    medicallySensitive: 2,
    redirects: 12,
  );

  static const List<OperationsRankedItem> frequentQuestions = [
    OperationsRankedItem('curebaseUsage', 8),
    OperationsRankedItem('appConnection', 6),
    OperationsRankedItem('pricing', 5),
  ];

  static const List<OperationsRankedItem> frequentProducts = [
    OperationsRankedItem('curebase', 11),
    OperationsRankedItem('hbCureApp', 8),
    OperationsRankedItem('cureclip', 5),
  ];

  static const List<OperationsRankedItem> openKnowledgeGaps = [
    OperationsRankedItem('priceDetails', 3),
    OperationsRankedItem('firmwareHelp', 2),
    OperationsRankedItem('compatibility', 1),
  ];

  static const List<OperationsRankedItem> searchedTopics = [
    OperationsRankedItem('bluetooth', 9),
    OperationsRankedItem('firmware', 7),
    OperationsRankedItem('programs', 6),
  ];

  static const List<OperationsRankedItem> supportProblems = [
    OperationsRankedItem('bluetoothConnection', 5),
    OperationsRankedItem('firmwareUpdate', 3),
    OperationsRankedItem('appPairing', 2),
  ];

  static const int priceRedirects = 7;
  static const int minutesSavedPerAnsweredQuestion = 7;
  static const int decisionsTotal = 6;
  static const int decisionsAdopted = 3;
  static const int decisionsInProgress = 2;
  static const int decisionsRejected = 1;

  static int get estimatedMinutesSaved =>
      today.answered * minutesSavedPerAnsweredQuestion;

  static int get avoidedSupportRequests => (today.answered * 2 / 3).round();

  static int get consistentAnswers => today.answered;

  static int get completedHumanReviews => decisionsAdopted + decisionsRejected;

  static int get humanReviewRate =>
      (completedHumanReviews / decisionsTotal * 100).round();

  static List<OperationsDay> historyForDays(int days) =>
      List.unmodifiable(history.skip(history.length - days));

  // Backward-compatible aliases for existing dashboard consumers.
  static int get customerQuestions => today.questions;
  static int get answered => today.answered;
  static int get gapsDetected => today.knowledgeGaps;
  static int get suggestionsCreated => decisionsTotal;
  static int get sourcesUsed => today.sourcesUsed;
  static int get entriesAdopted => today.newEntries;
}
