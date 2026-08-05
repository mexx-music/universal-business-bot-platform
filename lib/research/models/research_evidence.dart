import 'research_enums.dart';

/// A single, source-backed statement extracted from a [ResearchDocument].
///
/// Examples: "Neue Produktlinie veröffentlicht", "Mitarbeiterzahl gestiegen",
/// "Expansion nach USA".
///
/// Every piece of evidence points back to exactly one document via
/// [documentId], so a claim can always be traced to its source — no free-
/// floating assertions.
class ResearchEvidence {
  const ResearchEvidence({
    required this.id,
    required this.documentId,
    required this.category,
    required this.summary,
    required this.confidence,
    required this.extractedAt,
  });

  final String id;

  /// The [ResearchDocument.id] this statement was drawn from.
  final String documentId;

  final ResearchEvidenceCategory category;

  /// Short, neutral statement of the fact.
  final String summary;

  /// 0–100: how strongly the source supports the statement.
  final int confidence;

  final DateTime extractedAt;
}
