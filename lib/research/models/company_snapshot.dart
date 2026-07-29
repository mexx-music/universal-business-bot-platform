/// A point-in-time snapshot of what is known about a company.
///
/// Pure data — no AI, no scoring, no derivation. Later modules (Market
/// Intelligence, Competitor Analysis) read snapshots; they are never produced
/// by this foundation layer from live sources.
class CompanySnapshot {
  const CompanySnapshot({
    required this.companyId,
    required this.companyName,
    required this.capturedAt,
    this.knownProducts = const [],
    this.countries = const [],
    this.website = '',
    this.socialMedia = const {},
    this.rating,
    this.marketSegment = '',
  });

  final String companyId;
  final String companyName;

  /// When this snapshot was taken.
  final DateTime capturedAt;

  final List<String> knownProducts;

  /// ISO 3166-1 alpha-2 country codes the company is active in.
  final List<String> countries;

  final String website;

  /// Platform name -> profile URL/handle, e.g. {'linkedin': '...'}.
  final Map<String, String> socialMedia;

  /// Average public rating (e.g. 0.0–5.0), or null if unknown.
  final double? rating;

  final String marketSegment;
}
