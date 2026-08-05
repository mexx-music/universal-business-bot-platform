import 'models/company_research.dart';

/// Data-access boundary for the Research Engine.
///
/// Fully local in G-5: implementations serve demo data only — no database, no
/// APIs, no crawling. Later modules (Market Intelligence, Company Evolution,
/// Competitor Analysis) depend on this interface, so they never learn whether
/// the data is in-memory, persisted or, eventually, gathered from real sources
/// behind a server-side boundary.
abstract interface class ResearchRepository {
  /// All researched companies, in stable order.
  List<CompanyResearch> get companies;

  /// The research bundle for one company, or null if unknown.
  CompanyResearch? findCompany(String companyId);
}
