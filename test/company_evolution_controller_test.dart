import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/research/company_evolution_controller.dart';
import 'package:universalbusiness/research/local_research_repository.dart';
import 'package:universalbusiness/research/research_runtime.dart';

CompanyEvolutionController buildController() =>
    CompanyEvolutionController(ResearchRuntime());

void main() {
  group('CompanyEvolutionController', () {
    test('loads companies through the runtime', () {
      final controller = buildController();
      expect(controller.hasCompanies, isTrue);
      expect(controller.companies.length, greaterThanOrEqualTo(2));
    });

    test('selects the first company by default', () {
      final controller = buildController();
      expect(
        controller.selectedCompanyId,
        controller.companies.first.companyId,
      );
      expect(
        controller.snapshot?.companyId,
        controller.companies.first.companyId,
      );
    });

    test('switching company updates snapshot and timeline and notifies', () {
      final controller = buildController();
      final second = controller.companies[1];
      var notified = 0;
      controller.addListener(() => notified++);

      controller.selectCompany(second.companyId);

      expect(notified, 1);
      expect(controller.selectedCompanyId, second.companyId);
      expect(controller.snapshot?.companyId, second.companyId);
      expect(
        controller.timeline.every((e) => e.companyId == second.companyId),
        isTrue,
      );
    });

    test('re-selecting the same company is a no-op (no notification)', () {
      final controller = buildController();
      var notified = 0;
      controller.addListener(() => notified++);
      controller.selectCompany(controller.selectedCompanyId!);
      expect(notified, 0);
    });

    test('selecting an unknown company id is ignored', () {
      final controller = buildController();
      final before = controller.selectedCompanyId;
      var notified = 0;
      controller.addListener(() => notified++);
      controller.selectCompany('does-not-exist');
      expect(controller.selectedCompanyId, before);
      expect(notified, 0);
    });

    test('timeline is chronological (oldest first)', () {
      final controller = buildController();
      final dates = controller.timeline.map((e) => e.date).toList();
      for (var i = 0; i < dates.length - 1; i++) {
        expect(dates[i].isAfter(dates[i + 1]), isFalse);
      }
    });

    test('evidence resolves per document and never leaks across documents', () {
      final controller = buildController();
      final docs = controller.documents;
      expect(docs.length, greaterThanOrEqualTo(2));

      for (final doc in docs) {
        final evidence = controller.evidenceForDocument(doc.id);
        expect(evidence.every((e) => e.documentId == doc.id), isTrue);
      }

      // Evidence of the first document must not appear under the second.
      final firstEvidenceIds = controller
          .evidenceForDocument(docs.first.id)
          .map((e) => e.id)
          .toSet();
      final secondEvidenceIds = controller
          .evidenceForDocument(docs[1].id)
          .map((e) => e.id)
          .toSet();
      expect(firstEvidenceIds.intersection(secondEvidenceIds), isEmpty);
    });

    test('empty repository yields no companies and safe empty views', () {
      final controller = CompanyEvolutionController(
        ResearchRuntime(
          repository: LocalResearchRepository(companies: const []),
        ),
      );
      expect(controller.hasCompanies, isFalse);
      expect(controller.selectedCompanyId, isNull);
      expect(controller.snapshot, isNull);
      expect(controller.timeline, isEmpty);
      expect(controller.documents, isEmpty);
      expect(controller.evidenceForDocument('any'), isEmpty);
    });
  });
}
