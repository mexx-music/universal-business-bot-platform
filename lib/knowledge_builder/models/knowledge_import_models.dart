// Models for the Knowledge Builder (AI Knowledge Import).
//
// The analysis is a *preview only*: it never persists anything and never
// invents facts. Drafts carry the user's own text verbatim as content — only
// titles, questions and keywords are generated (explicitly allowed), and
// duplicates/existing matches are detected, never merged automatically.

import 'company_knowledge_package.dart';

/// The category a detected statement most likely belongs to.
enum KnowledgeDraftCategory {
  faq,
  installation,
  stepByStep,
  technicalRequirement,
  warning,
  troubleshooting,
  productFeature,
  tip,
  definition,
  contact,
  general,
}

/// UI decision a human takes per draft. The decision controls the existing
/// per-entry review presentation; workspace writes still require the separate,
/// explicit confirmation action.
enum DraftDecision { undecided, accept, edit, ignore }

/// How a human wants to reconcile a draft with an existing entry.
enum MergeChoice { augment, replace, newEntry }

/// A match between a draft and an already-existing knowledge entry.
class KnowledgeImportMatch {
  const KnowledgeImportMatch({
    required this.existingEntryId,
    required this.existingTitle,
    required this.existingExcerpt,
    required this.similarity,
  });

  final String existingEntryId;
  final String existingTitle;
  final String existingExcerpt;

  /// 0.0–1.0 token overlap between the draft and the existing entry.
  final double similarity;
}

/// One proposed knowledge entry derived from the imported text.
class KnowledgeImportDraft {
  const KnowledgeImportDraft({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    required this.sourceSentence,
    this.question,
    this.keywords = const [],
    this.languageCode,
    this.knowledgeArea,
    this.detectedTopics = const [],
    this.packageMetadata,
    this.existingMatch,
    this.isPossibleDuplicate = false,
  });

  final String id;
  final KnowledgeDraftCategory category;

  /// Generated short heading (allowed to be generated).
  final String title;

  /// Verbatim source text — never rewritten or extended.
  final String content;

  /// The exact sentence this draft came from.
  final String sourceSentence;

  /// Generated question for FAQ drafts (allowed to be generated); null
  /// otherwise.
  final String? question;

  /// Generated keywords (allowed to be generated).
  final List<String> keywords;

  /// Detected ISO 639-1 input language. Null means that the text was
  /// ambiguous; no default language is assumed in that case.
  final String? languageCode;

  /// Stable content scope used as retrieval metadata. It never restricts
  /// visibility or introduces roles.
  final String? knowledgeArea;

  /// Topics recognized in the source text and shown in the preview.
  final List<String> detectedTopics;

  /// Present only when this draft came from a prepared multi-document package.
  /// The analyzer still derives the draft from the raw sentence; this metadata
  /// only preserves source, review and freshness context for human review.
  final KnowledgePackageDocumentMetadata? packageMetadata;

  /// Set when a similar entry already exists — the human decides how to merge.
  final KnowledgeImportMatch? existingMatch;

  /// True when another draft in the same batch is highly similar.
  final bool isPossibleDuplicate;

  bool get matchesExisting => existingMatch != null;
  bool get isFaq => category == KnowledgeDraftCategory.faq;
}

/// The full preview produced by the analyzer.
class KnowledgeImportAnalysis {
  const KnowledgeImportAnalysis({
    required this.analyzedSentences,
    required this.unclearStatements,
    required this.drafts,
    this.inputLanguageCode,
    this.knowledgeArea,
    this.detectedTopicLabels = const [],
  });

  const KnowledgeImportAnalysis.empty()
    : analyzedSentences = 0,
      unclearStatements = 0,
      drafts = const [],
      inputLanguageCode = null,
      knowledgeArea = null,
      detectedTopicLabels = const [];

  /// How many sentences were parsed from the raw text.
  final int analyzedSentences;

  /// Sentences too short/ambiguous to classify (counted, not turned into
  /// drafts).
  final int unclearStatements;

  final List<KnowledgeImportDraft> drafts;

  final String? inputLanguageCode;
  final String? knowledgeArea;
  final List<String> detectedTopicLabels;

  int get detectedTopics =>
      detectedTopicLabels.isEmpty ? drafts.length : detectedTopicLabels.length;

  /// Drafts that do not match any existing entry.
  int get newEntries => drafts.where((d) => !d.matchesExisting).length;

  /// Drafts that likely complement an existing entry.
  int get existingMatches => drafts.where((d) => d.matchesExisting).length;

  /// Drafts that look like near-duplicates of another draft in this batch.
  int get possibleDuplicates =>
      drafts.where((d) => d.isPossibleDuplicate).length;

  bool get isEmpty => drafts.isEmpty;
}
