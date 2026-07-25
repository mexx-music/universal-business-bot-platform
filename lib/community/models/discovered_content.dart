import '../../models/knowledge_entry.dart' show RiskLevel;
import 'community_enums.dart';

/// A public online discussion the AI has surfaced for a company. Company-
/// scoped via [companyId]; the AI only analyses it — nothing is ever posted
/// automatically. Reuses the app-wide [RiskLevel] (green/yellow/red).
class DiscoveredContent {
  const DiscoveredContent({
    required this.id,
    required this.companyId,
    required this.platform,
    required this.sourceUrl,
    required this.title,
    required this.originalText,
    required this.language,
    required this.country,
    required this.topicTags,
    required this.detectedIntent,
    required this.sentiment,
    required this.relevanceScore,
    required this.riskLevel,
    required this.discoveredAt,
    required this.status,
    required this.recommendedActionTypes,
    this.aiSummary = '',
    this.relevanceReason = '',
    this.riskNotes = const [],
    this.prohibitedClaims = const [],
    this.relatedKnowledgeEntryIds = const [],
  });

  final String id;
  final String companyId;
  final CommunityPlatform platform;
  final String sourceUrl;
  final String title;
  final String originalText;

  /// ISO 639-1 language code, e.g. 'de' / 'en'.
  final String language;

  /// ISO 3166-1 alpha-2 country code, e.g. 'DE' / 'AT' / 'US'.
  final String country;

  final List<String> topicTags;
  final ContentIntent detectedIntent;
  final ContentSentiment sentiment;

  /// 0–100 relevance for the company.
  final int relevanceScore;

  final RiskLevel riskLevel;
  final DateTime discoveredAt;
  final ContentStatus status;

  /// Actions the AI suggests as suitable — never actions it performs.
  final List<CommunityActionType> recommendedActionTypes;

  // --- AI analysis (shown read-only on the detail screen) ---

  /// Short, neutral AI summary of the discussion.
  final String aiSummary;

  /// Why this content is relevant for the company — factual, not a verdict.
  final String relevanceReason;

  /// Risks a human should be aware of before engaging.
  final List<String> riskNotes;

  /// Statements that must never be made (e.g. medical claims). A compliance
  /// guard in a later block reads this list.
  final List<String> prohibitedClaims;

  /// Knowledge base entries that could inform a factual, honest reply.
  final List<String> relatedKnowledgeEntryIds;

  DiscoveredContent copyWith({ContentStatus? status}) {
    return DiscoveredContent(
      id: id,
      companyId: companyId,
      platform: platform,
      sourceUrl: sourceUrl,
      title: title,
      originalText: originalText,
      language: language,
      country: country,
      topicTags: topicTags,
      detectedIntent: detectedIntent,
      sentiment: sentiment,
      relevanceScore: relevanceScore,
      riskLevel: riskLevel,
      discoveredAt: discoveredAt,
      status: status ?? this.status,
      recommendedActionTypes: recommendedActionTypes,
      aiSummary: aiSummary,
      relevanceReason: relevanceReason,
      riskNotes: riskNotes,
      prohibitedClaims: prohibitedClaims,
      relatedKnowledgeEntryIds: relatedKnowledgeEntryIds,
    );
  }
}
