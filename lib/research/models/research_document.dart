import 'research_enums.dart';

/// A structured reference to a single external document about a company.
///
/// Foundation only (G-5): this is a plain data model. Nothing here fetches,
/// crawls or stores anything remotely — the [sourceUrl] is a reference, never
/// something this layer requests.
class ResearchDocument {
  const ResearchDocument({
    required this.id,
    required this.companyId,
    required this.title,
    required this.sourceName,
    required this.sourceUrl,
    required this.publishedAt,
    required this.language,
    required this.country,
    required this.companyName,
    required this.documentType,
  });

  final String id;

  /// Company this document is about — the referential link to a
  /// [CompanySnapshot] / [CompanyResearch].
  final String companyId;

  final String title;

  /// Human-readable name of the source (publication, platform, site).
  final String sourceName;

  /// Reference URL only — never requested by this layer.
  final String sourceUrl;

  final DateTime publishedAt;

  /// ISO 639-1 language code, e.g. 'de' / 'en'.
  final String language;

  /// ISO 3166-1 alpha-2 country code, e.g. 'DE' / 'AT' / 'US'.
  final String country;

  /// Denormalised company name for display without a snapshot lookup.
  final String companyName;

  final ResearchDocumentType documentType;
}
