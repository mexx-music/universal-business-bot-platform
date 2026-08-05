import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';
import 'package:universalbusiness/screens/knowledge_builder/knowledge_builder_screen.dart';

Future<void> _pump(
  WidgetTester tester, {
  required AppState state,
  Locale locale = const Locale('de'),
  Size size = const Size(1000, 1400),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: AppStateScope(
        notifier: state,
        child: const KnowledgeBuilderScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations _l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(KnowledgeBuilderScreen)))!;

Future<void> _loadPackage(WidgetTester tester) async {
  final load = find.byKey(const Key('kb-load-package-hb-cure-complete'));
  await tester.ensureVisible(load);
  await tester.tap(load);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('loads complete package without analysis or persistence', (
    tester,
  ) async {
    final state = AppState();
    final before = state.knowledgeEntries.length;
    await _pump(tester, state: state);
    final l = _l10n(tester);

    expect(
      find.byKey(const Key('kb-package-card-hb-cure-complete')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('kb-demo-document-hb-cure-app')),
      findsOneWidget,
    );
    await _loadPackage(tester);

    final input = tester.widget<TextField>(find.byKey(const Key('kb-input')));
    expect(input.controller!.text, contains('Healing & Balance GmbH'));
    expect(input.controller!.text, contains('CureBase'));
    expect(input.controller!.text, contains('CureClip'));
    expect(input.controller!.text, contains('über 2.500'));
    expect(find.byKey(const Key('kb-loaded-package-notice')), findsOneWidget);
    expect(find.text(l.kbPackageLoaded), findsOneWidget);
    expect(find.text(l.kbPackageNotAnalyzed), findsOneWidget);
    expect(find.byKey(const Key('kb-analysis-summary')), findsNothing);
    expect(find.byKey(const Key('kb-draft-preview')), findsNothing);
    expect(state.knowledgeEntries.length, before);
  });

  testWidgets('shows separated provenance, risks, and freshness metadata', (
    tester,
  ) async {
    final state = AppState();
    await _pump(tester, state: state);
    final l = _l10n(tester);
    await _loadPackage(tester);

    final sources = find.byKey(const Key('kb-package-source-documents'));
    await tester.ensureVisible(sources);
    await tester.tap(sources);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Healing-&-Balance-Website', findRichText: true),
      findsWidgets,
    );
    expect(
      find.textContaining(
        'Interne HB-Cure-Produktdokumentation',
        findRichText: true,
      ),
      findsWidgets,
    );
    expect(
      find.textContaining(
        'Interne HB-Cure-Support-Dokumentation',
        findRichText: true,
      ),
      findsWidgets,
    );
    expect(
      find.textContaining(
        'Öffentliche Unternehmenswebsite',
        findRichText: true,
      ),
      findsWidgets,
    );
    expect(
      find.textContaining(
        'Bestätigte Produktdokumentation',
        findRichText: true,
      ),
      findsWidgets,
    );
    expect(find.text(l.kbPackageRiskImpact), findsOneWidget);
    expect(find.text(l.kbPackageRiskTestimonial), findsOneWidget);
    expect(find.text(l.kbPackageTimeSensitiveBadge), findsWidgets);
    expect(
      find.textContaining(l.kbPackageLastCheckedLabel, findRichText: true),
      findsWidgets,
    );
    expect(
      find.textContaining(l.kbPackageReviewRecommended, findRichText: true),
      findsWidgets,
    );
  });

  testWidgets('analysis uses existing pipeline and keeps draft provenance', (
    tester,
  ) async {
    final state = AppState();
    final before = state.knowledgeEntries.length;
    await _pump(tester, state: state);
    await _loadPackage(tester);

    await tester.tap(find.byKey(const Key('kb-analyze-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('kb-analysis-summary')), findsOneWidget);
    expect(find.byKey(const Key('kb-draft-preview')), findsOneWidget);
    expect(find.byKey(const Key('kb-draft-package-metadata')), findsWidgets);
    expect(
      find.textContaining('Healing-&-Balance-Website', findRichText: true),
      findsWidgets,
    );
    expect(
      find.textContaining(
        'Interne HB-Cure-Produktdokumentation',
        findRichText: true,
      ),
      findsWidgets,
    );
    expect(state.knowledgeEntries.length, before);
  });

  testWidgets('explicit import uses existing workspace and excludes seeds', (
    tester,
  ) async {
    final state = AppState();
    final seededIds = state.knowledgeEntries.map((entry) => entry.id).toSet();
    await _pump(tester, state: state);
    await _loadPackage(tester);
    await tester.tap(find.byKey(const Key('kb-analyze-action')));
    await tester.pumpAndSettle();

    final import = find.byKey(const Key('kb-import-all'));
    await tester.ensureVisible(import);
    await tester.tap(import);
    await tester.pumpAndSettle();

    final confirmed = state.groundedAnswerWorkspace.knowledgeEntries;
    expect(confirmed, isNotEmpty);
    expect(
      confirmed.every(
        (entry) => KnowledgeEntrySources.isKnowledgeBuilder(entry.source),
      ),
      isTrue,
    );
    expect(confirmed.any((entry) => seededIds.contains(entry.id)), isFalse);
    expect(
      confirmed.any(
        (entry) => entry.source.contains('Healing-&-Balance-Website'),
      ),
      isTrue,
    );
    expect(find.byKey(const Key('kb-import-success-dialog')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('kb-workspace-stat-documents')),
        matching: find.text('12'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('English interface loads fully English package presentation', (
    tester,
  ) async {
    final state = AppState();
    await _pump(tester, state: state, locale: const Locale('en'));
    final l = _l10n(tester);
    await _loadPackage(tester);

    final input = tester.widget<TextField>(find.byKey(const Key('kb-input')));
    expect(input.controller!.text, contains('The HB Cure system consists'));
    expect(input.controller!.text, contains('There is no obligation'));
    expect(input.controller!.text, isNot(contains('Zum HB-Cure-System')));
    expect(find.text('HB Cure – complete demo knowledge'), findsOneWidget);
    expect(find.text(l.kbPackageLoaded), findsOneWidget);
    expect(find.text('Company'), findsWidgets);
    expect(find.text('Unternehmen'), findsNothing);
  });

  testWidgets('package entry and preview do not overflow mobile or desktop', (
    tester,
  ) async {
    await _pump(tester, state: AppState(), size: const Size(360, 800));
    await _loadPackage(tester);
    expect(tester.takeException(), isNull);

    await _pump(tester, state: AppState(), size: const Size(1440, 1000));
    await _loadPackage(tester);
    expect(tester.takeException(), isNull);
  });
}
