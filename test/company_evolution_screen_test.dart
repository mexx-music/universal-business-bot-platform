import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:universalbusiness/app/app_dependencies.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/research/company_evolution_controller.dart';
import 'package:universalbusiness/research/local_research_repository.dart';
import 'package:universalbusiness/research/models/company_research.dart';
import 'package:universalbusiness/research/models/company_snapshot.dart';
import 'package:universalbusiness/research/models/company_timeline_event.dart';
import 'package:universalbusiness/research/models/research_document.dart';
import 'package:universalbusiness/research/models/research_enums.dart';
import 'package:universalbusiness/research/models/research_evidence.dart';
import 'package:universalbusiness/research/research_runtime.dart';
import 'package:universalbusiness/screens/company_evolution/company_evolution_screen.dart';

Future<void> pumpScreen(
  WidgetTester tester, {
  List<CompanyResearch>? companies,
  Size size = const Size(1400, 1200),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final runtime = ResearchRuntime(
    repository: companies == null
        ? LocalResearchRepository()
        : LocalResearchRepository(companies: companies),
  );
  final controller = CompanyEvolutionController(runtime);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('de'),
      home: CompanyEvolutionScope(
        notifier: controller,
        child: const CompanyEvolutionScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

CompanyResearch companyWith({
  required String id,
  required String name,
  List<CompanyTimelineEvent> timeline = const [],
  List<ResearchDocument> documents = const [],
  List<ResearchEvidence> evidence = const [],
}) {
  return CompanyResearch(
    companyId: id,
    companyName: name,
    snapshot: CompanySnapshot(
      companyId: id,
      companyName: name,
      capturedAt: DateTime(2026, 1, 1),
    ),
    timeline: timeline,
    documents: documents,
    evidence: evidence,
  );
}

void main() {
  testWidgets('renders the first company by default (via runtime)', (
    tester,
  ) async {
    await pumpScreen(tester);
    // Nordlicht is the first demo company; its name shows in the dropdown and
    // the snapshot card.
    expect(find.text('Nordlicht Kaffeerösterei'), findsWidgets);
    // A Nordlicht-specific timeline entry is visible.
    expect(find.text('Gründung in Kiel'), findsOneWidget);
  });

  testWidgets('switching company updates snapshot and timeline', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.text('Gründung in Kiel'), findsOneWidget);

    await tester.tap(find.byKey(const Key('company-evolution-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aurora Robotics').last);
    await tester.pumpAndSettle();

    // Aurora content appears, Nordlicht content is gone.
    expect(find.text('Aurora Robotics'), findsWidgets);
    expect(find.text('Europäisches Büro in München'), findsOneWidget);
    expect(find.text('Gründung in Kiel'), findsNothing);
  });

  testWidgets('timeline is displayed chronologically (oldest first)', (
    tester,
  ) async {
    await pumpScreen(tester);
    final founding = tester.getTopLeft(find.text('Gründung in Kiel')).dy;
    final expansion = tester
        .getTopLeft(find.text('Zweite Rösterei in Hamburg'))
        .dy;
    final coldBrew = tester.getTopLeft(find.text('Launch Cold-Brew-Linie')).dy;

    expect(founding, lessThan(expansion));
    expect(expansion, lessThan(coldBrew));
  });

  testWidgets('evidence appears only under its own document', (tester) async {
    await pumpScreen(tester);

    final doc1 = find.byKey(const ValueKey('doc-doc-nordlicht-1'));
    final doc2 = find.byKey(const ValueKey('doc-doc-nordlicht-2'));
    expect(doc1, findsOneWidget);
    expect(doc2, findsOneWidget);

    // ev-nordlicht-1/2 belong to doc-1; ev-nordlicht-3 belongs to doc-2.
    expect(
      find.descendant(
        of: doc1,
        matching: find.byKey(const ValueKey('ev-ev-nordlicht-1')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: doc1,
        matching: find.byKey(const ValueKey('ev-ev-nordlicht-3')),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: doc2,
        matching: find.byKey(const ValueKey('ev-ev-nordlicht-3')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows empty state when there are no companies', (tester) async {
    await pumpScreen(tester, companies: const []);
    final l = await AppLocalizations.delegate.load(const Locale('de'));
    expect(find.text(l.companyEvolutionEmptyCompanies), findsOneWidget);
  });

  testWidgets('shows empty states for timeline, documents and evidence', (
    tester,
  ) async {
    final l = await AppLocalizations.delegate.load(const Locale('de'));
    await pumpScreen(
      tester,
      companies: [
        companyWith(
          id: 'c1',
          name: 'Leerfirma',
          documents: [
            ResearchDocument(
              id: 'd1',
              companyId: 'c1',
              title: 'Dok ohne Belege',
              sourceName: 'Quelle',
              sourceUrl: 'https://example.com/x',
              publishedAt: DateTime(2026, 1, 1),
              language: 'de',
              country: 'DE',
              companyName: 'Leerfirma',
              documentType: ResearchDocumentType.news,
            ),
          ],
        ),
      ],
    );

    expect(find.text(l.companyEvolutionEmptyTimeline), findsOneWidget);
    // Document exists, but it has no evidence.
    expect(find.text(l.companyEvolutionEmptyEvidence), findsOneWidget);
  });

  testWidgets('lays out without overflow on desktop and mobile', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(1400, 1200));
    expect(tester.takeException(), isNull);

    await pumpScreen(tester, size: const Size(390, 900));
    expect(tester.takeException(), isNull);
  });

  testWidgets('is reachable through app navigation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final deps = AppDependencies.local();
    await tester.pumpWidget(UniversalBusinessApp(dependencies: deps));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Navigator).first);
    GoRouter.of(context).go('/company-evolution');
    await tester.pumpAndSettle();

    // The Company Evolution screen rendered (demo company name is locale-neutral).
    expect(find.text('Nordlicht Kaffeerösterei'), findsWidgets);
  });
}
