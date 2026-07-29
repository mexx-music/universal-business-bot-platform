import 'local_research_repository.dart';
import 'models/company_research.dart';
import 'models/company_timeline_event.dart';
import 'models/research_evidence.dart';
import 'research_repository.dart';

/// Central entry point for the Research Engine.
///
/// In later blocks this class will orchestrate the full pipeline — collecting
/// sources, filtering them, running AI preparation and assembling a timeline.
/// In G-5 it does exactly one thing: serve the demo research bundles from the
/// [ResearchRepository] and expose a few pure read helpers on top of them.
/// It performs no web research, crawling or API access.
class ResearchRuntime {
  ResearchRuntime({ResearchRepository? repository})
    : _repository = repository ?? LocalResearchRepository();

  final ResearchRepository _repository;

  /// All researched companies.
  List<CompanyResearch> get companies => _repository.companies;

  /// The research bundle for one company, or null if unknown.
  CompanyResearch? company(String companyId) =>
      _repository.findCompany(companyId);

  /// A company's timeline, oldest → newest. Empty if the company is unknown.
  List<CompanyTimelineEvent> timeline(String companyId) =>
      _repository.findCompany(companyId)?.timelineSorted ?? const [];

  /// Evidence extracted from a specific document within a company. Empty if the
  /// company or document is unknown.
  List<ResearchEvidence> evidenceForDocument(
    String companyId,
    String documentId,
  ) =>
      _repository.findCompany(companyId)?.evidenceForDocument(documentId) ??
      const [];
}
