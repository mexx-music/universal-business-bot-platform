import '../knowledge_builder/models/knowledge_import_models.dart';

// Knowledge Improvement Loop (BLOCK 4) — a scripted, illustrative demo of the
// platform's core differentiator. No live AI, no backend, no persistence: it
// visualises how one customer question turns a knowledge gap into permanent
// knowledge that every future answer benefits from. Displayed text is
// localized in the screen; this holds only the structural scenario.

/// The seven stages of the learning loop, in order.
enum KnowledgeLoopStage {
  customerQuestion,
  aiAnswerGap,
  gapDetected,
  improvementSuggested,
  employeeAccepts,
  knowledgeGrows,
  futureAnswersImprove,
}

/// Structural facts of the demo scenario (text comes from l10n).
class KnowledgeImprovementDemo {
  const KnowledgeImprovementDemo._();

  static const List<KnowledgeLoopStage> stages = KnowledgeLoopStage.values;

  /// Knowledge-base entry count before and after the accepted improvement.
  static const int knowledgeBefore = 8;
  static const int knowledgeAfter = 9;

  /// Uncovered question terms shown as chips (language-neutral tokens).
  static const List<String> missingTerms = ['bluetooth', 'verbindung'];

  /// The category the suggested entry would belong to.
  static const KnowledgeDraftCategory suggestionCategory =
      KnowledgeDraftCategory.faq;

  /// Keywords of the suggested entry.
  static const List<String> suggestionKeywords = ['bluetooth', 'verbindung'];
}
