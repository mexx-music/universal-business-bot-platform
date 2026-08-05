import 'models/company_research.dart';
import 'research_demo_data.dart';
import 'research_repository.dart';

/// In-memory [ResearchRepository] backed by brand-neutral demo companies.
///
/// G-5 is entirely local: no database, no APIs, no crawling, nothing published.
/// The same interface will later be satisfied by a real, server-mediated
/// research pipeline without any UI or module change.
class LocalResearchRepository implements ResearchRepository {
  LocalResearchRepository({List<CompanyResearch>? companies})
    : _companies = companies ?? ResearchDemoData.companies();

  final List<CompanyResearch> _companies;

  @override
  List<CompanyResearch> get companies => List.unmodifiable(_companies);

  @override
  CompanyResearch? findCompany(String companyId) {
    for (final company in _companies) {
      if (company.companyId == companyId) return company;
    }
    return null;
  }
}
