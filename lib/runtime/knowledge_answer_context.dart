import '../models/bot_question_log.dart';
import '../models/knowledge_entry.dart';
import '../models/source_material.dart';

/// How well the retrieved knowledge supports an answer.
enum KnowledgeConfidenceLevel {
  /// >= 70: the answer is well backed by approved knowledge.
  high,

  /// 40–69: partial coverage; an answer is possible but incomplete.
  partial,

  /// < 40: little or no approved knowledge exists for this question.
  low,
}

/// A knowledge entry with its retrieval score and the reasons behind it.
class ScoredKnowledgeMatch {
  const ScoredKnowledgeMatch({
    required this.entry,
    required this.score,
    required this.reasons,
    required this.restricted,
  });

  final KnowledgeEntry entry;

  /// 0–100 relevance score, see [KnowledgeRanking].
  final int score;

  /// Human-readable ranking reasons ("Titel passt (kosten)").
  final List<String> reasons;

  /// True for red-risk entries: relevant, but the content must not be
  /// answered by a bot — it signals escalation instead.
  final bool restricted;
}

/// A source material with its retrieval score and reasons.
class ScoredSourceMatch {
  const ScoredSourceMatch({
    required this.source,
    required this.score,
    required this.reasons,
  });

  final SourceMaterial source;
  final int score;
  final List<String> reasons;
}

/// A detected hole in the approved knowledge: the question could not be
/// answered (well) from what exists. Pure value object — persisting it or
/// feeding it into Human Review is a later step; [toBotQuestionLog] already
/// provides the mapping for that hand-over.
class KnowledgeGap {
  const KnowledgeGap({
    required this.companyId,
    required this.question,
    required this.reason,
    required this.missingTerms,
    required this.confidence,
    required this.createdAt,
  });

  final String companyId;
  final String question;

  /// Why this counts as a gap ("Für diese Frage existiert noch kein
  /// freigegebenes Wissen.").
  final String reason;

  /// Question terms not covered by any approved knowledge.
  final List<String> missingTerms;

  /// The confidence (0–100) that triggered the gap.
  final int confidence;

  final DateTime createdAt;

  /// Maps the gap onto the existing Human-Review model so a later block can
  /// enqueue it without any model changes.
  BotQuestionLog toBotQuestionLog({String? id}) {
    return BotQuestionLog(
      id: id ?? 'gap_${createdAt.microsecondsSinceEpoch}',
      question: question,
      matched: false,
      timestamp: createdAt,
      reviewStatus: ReviewStatus.open,
      reviewReason: confidence <= 20
          ? ReviewReason.noMatch
          : ReviewReason.lowConfidence,
      humanNote: reason,
    );
  }
}

/// The structured result of the knowledge runtime for one user question:
/// everything a future answer generator (LLM or template) needs, without
/// generating an answer itself.
class KnowledgeAnswerContext {
  const KnowledgeAnswerContext({
    required this.question,
    required this.companyId,
    required this.queryTerms,
    required this.topEntries,
    required this.topSources,
    required this.confidence,
    required this.reasoning,
    required this.missingInformation,
    required this.openQuestions,
    required this.blockedTopicHits,
    required this.gap,
  });

  final String question;
  final String companyId;

  /// Normalized, stopword-free terms the retrieval worked with.
  final List<String> queryTerms;

  /// Best knowledge entries, highest score first.
  final List<ScoredKnowledgeMatch> topEntries;

  /// Best source materials, highest score first.
  final List<ScoredSourceMatch> topSources;

  /// 0–100: how well an answer is backed by approved knowledge.
  final int confidence;

  /// Human-readable explanation of how the result came about.
  final List<String> reasoning;

  /// What is missing to answer the question completely.
  final List<String> missingInformation;

  /// Follow-ups for humans (create entry X? clarify blocked topic Y?).
  final List<String> openQuestions;

  /// Blocked bot topics the question touches (from the bot configuration).
  final List<String> blockedTopicHits;

  /// Set when the approved knowledge cannot (sufficiently) answer the
  /// question; null when coverage is good enough.
  final KnowledgeGap? gap;

  bool get hasGap => gap != null;

  /// True when the question touches restricted (red) knowledge or a blocked
  /// topic — a future bot must hand over to a human instead of answering.
  bool get requiresHumanHandover =>
      blockedTopicHits.isNotEmpty ||
      topEntries.any((match) => match.restricted);

  KnowledgeConfidenceLevel get confidenceLevel {
    if (confidence >= 70) return KnowledgeConfidenceLevel.high;
    if (confidence >= 40) return KnowledgeConfidenceLevel.partial;
    return KnowledgeConfidenceLevel.low;
  }
}
