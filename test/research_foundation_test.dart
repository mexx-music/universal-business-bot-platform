import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/research/local_research_repository.dart';
import 'package:universalbusiness/research/models/company_research.dart';
import 'package:universalbusiness/research/research_demo_data.dart';
import 'package:universalbusiness/research/research_runtime.dart';

void main() {
  group('CompanyResearch', () {
    test('timeline is returned sorted oldest -> newest', () {
      final company = ResearchDemoData.companies().first;
      // Precondition: the stored order is intentionally not chronological.
      final stored = company.timeline.map((e) => e.date).toList();
      final sorted = company.timelineSorted.map((e) => e.date).toList();

      expect(sorted.length, stored.length);
      for (var i = 0; i < sorted.length - 1; i++) {
        expect(
          sorted[i].isAfter(sorted[i + 1]),
          isFalse,
          reason: 'timeline must be non-decreasing by date',
        );
      }
      expect(
        sorted,
        isNot(equals(stored)),
        reason: 'demo data should exercise the sort',
      );
    });

    test('every evidence entry references an existing document', () {
      for (final company in ResearchDemoData.companies()) {
        final docIds = company.documents.map((d) => d.id).toSet();
        for (final ev in company.evidence) {
          expect(
            docIds.contains(ev.documentId),
            isTrue,
            reason:
                'evidence ${ev.id} points to unknown document ${ev.documentId}',
          );
        }
      }
    });

    test('evidenceForDocument returns only that document\'s evidence', () {
      final company = ResearchDemoData.companies().first;
      final doc = company.documents.first;
      final evidence = company.evidenceForDocument(doc.id);

      expect(evidence, isNotEmpty);
      expect(evidence.every((e) => e.documentId == doc.id), isTrue);
    });
  });

  group('CompanySnapshot demo data', () {
    test('every company has a complete snapshot', () {
      for (final company in ResearchDemoData.companies()) {
        final snap = company.snapshot;
        expect(snap.companyId, company.companyId);
        expect(snap.companyName, isNotEmpty);
        expect(snap.knownProducts, isNotEmpty);
        expect(snap.countries, isNotEmpty);
        expect(snap.website, isNotEmpty);
        expect(snap.marketSegment, isNotEmpty);
        expect(snap.rating, isNotNull);
      }
    });
  });

  group('LocalResearchRepository', () {
    test('serves the demo companies', () {
      final repo = LocalResearchRepository();
      expect(repo.companies.length, greaterThanOrEqualTo(2));
    });

    test('findCompany resolves a known id and returns null otherwise', () {
      final repo = LocalResearchRepository();
      final first = repo.companies.first;

      expect(repo.findCompany(first.companyId), isNotNull);
      expect(repo.findCompany('does-not-exist'), isNull);
    });

    test('exposes an unmodifiable company list', () {
      final repo = LocalResearchRepository();
      expect(
        () => repo.companies.add(repo.companies.first),
        throwsUnsupportedError,
      );
    });
  });

  group('ResearchRuntime', () {
    test('returns companies from the repository', () {
      final runtime = ResearchRuntime();
      expect(runtime.companies, isNotEmpty);
    });

    test('timeline() delegates and sorts, empty for unknown company', () {
      final runtime = ResearchRuntime();
      final id = runtime.companies.first.companyId;
      final timeline = runtime.timeline(id);

      expect(timeline, isNotEmpty);
      for (var i = 0; i < timeline.length - 1; i++) {
        expect(timeline[i].date.isAfter(timeline[i + 1].date), isFalse);
      }
      expect(runtime.timeline('unknown'), isEmpty);
    });

    test('evidenceForDocument() resolves through the runtime', () {
      final runtime = ResearchRuntime();
      final company = runtime.companies.first;
      final doc = company.documents.first;

      final evidence = runtime.evidenceForDocument(company.companyId, doc.id);
      expect(evidence, isNotEmpty);
      expect(evidence.every((e) => e.documentId == doc.id), isTrue);

      expect(runtime.evidenceForDocument('unknown', doc.id), isEmpty);
      expect(
        runtime.evidenceForDocument(company.companyId, 'unknown'),
        isEmpty,
      );
    });

    test('accepts an injected repository', () {
      final repo = LocalResearchRepository(
        companies: const <CompanyResearch>[],
      );
      final runtime = ResearchRuntime(repository: repo);
      expect(runtime.companies, isEmpty);
    });
  });
}
