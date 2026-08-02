import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/operations/operations_demo.dart';
import 'package:universalbusiness/screens/operations/operations_dashboard_screen.dart';

Future<void> pumpScreen(
  WidgetTester tester, {
  Locale locale = const Locale('de'),
  Size size = const Size(1100, 2600),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: const OperationsDashboardScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations l10n(WidgetTester tester) => AppLocalizations.of(
  tester.element(find.byType(OperationsDashboardScreen)),
)!;

void main() {
  testWidgets('shows the today card, closing and DEMO badges everywhere', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    expect(find.text(l.opTodayTitle), findsOneWidget);
    expect(find.text(l.opClosingTitle), findsOneWidget);
    expect(find.text(l.opClosingBody), findsOneWidget);
    // A DEMO badge on many cards makes clear it is a demonstration.
    expect(find.text(l.opDemoBadge).evaluate().length, greaterThan(5));
  });

  testWidgets('metrics show demo values with labels', (tester) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    expect(find.text('${OperationsDemo.customerQuestions}'), findsWidgets);
    expect(find.text('${OperationsDemo.sourcesUsed}'), findsWidgets);
    expect(find.text(l.opMetricQuestions), findsOneWidget);
    expect(find.text(l.opMetricSources), findsOneWidget);
  });

  testWidgets('activity timeline shows times and events', (tester) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    expect(find.text(l.opTimelineTitle), findsOneWidget);
    expect(find.text('09:12'), findsOneWidget);
    expect(find.text('10:03'), findsOneWidget);
    expect(find.text(l.opTl1), findsOneWidget);
  });

  testWidgets('detected section lists demo findings', (tester) async {
    await pumpScreen(tester);
    final l = l10n(tester);
    expect(find.text(l.opDetectedTitle), findsOneWidget);
    expect(find.text(l.opDetected1), findsOneWidget);
    expect(find.text(l.opDetected5), findsOneWidget);
  });

  testWidgets('human-decisions card makes the human-in-control point', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);
    expect(find.text(l.opDecisionsTitle), findsOneWidget);
    expect(find.text(l.opDecAdopted), findsOneWidget);
    expect(find.text(l.opDecRejected), findsOneWidget);
    expect(find.text(l.opDecisionsNote), findsOneWidget);
  });

  testWidgets('quality section renders labelled bars', (tester) async {
    await pumpScreen(tester);
    final l = l10n(tester);
    expect(find.text(l.opQualityTitle), findsOneWidget);
    expect(find.text(l.opQualFaq), findsOneWidget);
    expect(find.text(l.opQualDefinitions), findsOneWidget);
    // One bar per quality category.
    expect(
      find.byType(LinearProgressIndicator),
      findsNWidgets(OperationsDemo.qualityCounts.length),
    );
  });

  testWidgets('is localized in English', (tester) async {
    await pumpScreen(tester, locale: const Locale('en'));
    final l = l10n(tester);
    expect(l.opTodayTitle, 'BusinessBrain today');
    expect(find.text('BusinessBrain today'), findsOneWidget);
    expect(find.text(l.opDemoBadge), findsWidgets);
  });

  testWidgets('lays out without overflow on mobile and desktop', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(360, 3200));
    expect(tester.takeException(), isNull);

    await pumpScreen(tester, size: const Size(1400, 2400));
    expect(tester.takeException(), isNull);
  });
}
