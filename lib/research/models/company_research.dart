import 'company_snapshot.dart';
import 'company_timeline_event.dart';
import 'research_document.dart';
import 'research_evidence.dart';

/// Everything the research layer knows about a single company: its current
/// [snapshot], its [timeline], and the [documents] plus [evidence] those facts
/// were drawn from.
///
/// This is the aggregate the [ResearchRepository] and [ResearchRuntime] hand
/// out. It is a read-only bundle of demo data in G-5.
class CompanyResearch {
  const CompanyResearch({
    required this.companyId,
    required this.companyName,
    required this.snapshot,
    this.timeline = const [],
    this.documents = const [],
    this.evidence = const [],
  });

  final String companyId;
  final String companyName;
  final CompanySnapshot snapshot;
  final List<CompanyTimelineEvent> timeline;
  final List<ResearchDocument> documents;
  final List<ResearchEvidence> evidence;

  /// Timeline events ordered oldest → newest. Ties keep their insertion order.
  List<CompanyTimelineEvent> get timelineSorted {
    final sorted = [...timeline];
    sorted.sort((a, b) => a.date.compareTo(b.date));
    return List.unmodifiable(sorted);
  }

  ResearchDocument? findDocument(String documentId) {
    for (final doc in documents) {
      if (doc.id == documentId) return doc;
    }
    return null;
  }

  /// The evidence extracted from a given document, in stored order.
  List<ResearchEvidence> evidenceForDocument(String documentId) {
    return List.unmodifiable(evidence.where((e) => e.documentId == documentId));
  }
}
