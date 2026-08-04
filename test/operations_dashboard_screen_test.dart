import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/demo_data/demo_data_controller.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/operations/operations_demo.dart';
import 'package:universalbusiness/screens/operations/operations_dashboard_screen.dart';

Future<void> pumpScreen(
  WidgetTester tester, {
  Locale locale = const Locale('de'),
  Size size = const Size(1100, 5200),
  bool demoEnabled = true,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: DemoDataScope(
        notifier: DemoDataController(enabled: demoEnabled),
        child: const OperationsDashboardScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations l10n(WidgetTester tester) => AppLocalizations.of(
  tester.element(find.byType(OperationsDashboardScreen)),
)!;

void main() {
  testWidgets('shows all five operations areas and the insight layer', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    expect(find.text(l.opTitle), findsOneWidget);
    expect(find.byKey(const Key('operations-demo-notice')), findsOneWidget);
    expect(find.byKey(const Key('operations-today-activity')), findsOneWidget);
    expect(
      find.byKey(const Key('operations-knowledge-growth')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('operations-customer-insights')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('operations-business-impact')), findsOneWidget);
    expect(
      find.byKey(const Key('operations-knowledge-quality')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('operations-business-insights')),
      findsOneWidget,
    );
    expect(find.text(l.opDemoBadge).evaluate().length, greaterThan(6));
  });

  testWidgets('today activity renders modest deterministic demo metrics', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);
    final day = OperationsDemo.today;

    expect(find.text('${day.answered}'), findsWidgets);
    expect(find.text('${day.knowledgeGaps}'), findsWidgets);
    expect(find.text('${day.humanReviews}'), findsWidgets);
    expect(find.text('${day.websiteRedirects}'), findsWidgets);
    expect(find.text(l.opMetricAnswered), findsOneWidget);
    expect(find.text(l.opMetricReviews), findsOneWidget);
    expect(find.text(l.opMetricRedirects), findsOneWidget);
    expect(find.text(l.opMetricDocumentsAnalyzed), findsOneWidget);
    expect(find.text(l.opMetricAvgResponseTime), findsOneWidget);
  });

  testWidgets('history switches both charts between 7 and 30 days', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    expect(
      find.byKey(const Key('operations-answer-history-7')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('operations-knowledge-history-7')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('operations-answer-history-30')), findsNothing);

    await tester.tap(find.text(l.opPeriod30));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('operations-answer-history-30')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('operations-knowledge-history-30')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('operations-answer-history-7')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('knowledge growth and quality use the fixed dataset', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    expect(
      find.text('${OperationsDemo.knowledgeGrowth.confirmedEntries}'),
      findsWidgets,
    );
    expect(find.text(l.opGrowthConfirmed), findsOneWidget);
    expect(find.text(l.opGrowthProduct), findsOneWidget);
    expect(find.text(l.opGrowthSupport), findsOneWidget);
    expect(
      find.byKey(const Key('operations-answerability-chart')),
      findsOneWidget,
    );
    expect(find.text(l.opQualityFull), findsOneWidget);
    expect(find.text(l.opQualitySensitive), findsOneWidget);
  });

  testWidgets('customer patterns and business insights are understandable', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    expect(find.text(l.opCustomerQuestions), findsOneWidget);
    expect(find.text(l.opCustomerProducts), findsOneWidget);
    expect(find.text(l.opCustomerGaps), findsOneWidget);
    expect(find.text(l.opCustomerTopics), findsOneWidget);
    expect(find.text(l.opCustomerSupport), findsOneWidget);
    expect(find.text(l.opItemCurebaseUsage), findsOneWidget);
    expect(find.text(l.opItemBluetoothConnection), findsOneWidget);
    expect(find.text(l.opInsightLeadingTitle), findsOneWidget);
    expect(find.text(l.opInsightSupportTitle), findsOneWidget);
    expect(find.text(l.opInsightFirmwareTitle), findsOneWidget);
    expect(find.text(l.opInsightPriceTitle), findsOneWidget);
    expect(find.text(l.opInsightFaqTitle), findsOneWidget);
    expect(find.text(l.opInsightsMethodNote), findsOneWidget);
  });

  testWidgets('business impact states its conservative calculation', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    expect(find.text(l.opImpactTimeSaved), findsOneWidget);
    expect(find.text(l.opImpactAvoidedSupport), findsOneWidget);
    expect(find.text(l.opImpactReviewRate), findsOneWidget);
    expect(find.text(l.opImpactMethodNote), findsOneWidget);
    expect(find.text(l.opClosingTitle), findsOneWidget);
    expect(find.text(l.opClosingBody), findsOneWidget);
  });

  testWidgets('is fully localized in English', (tester) async {
    await pumpScreen(tester, locale: const Locale('en'));
    final l = l10n(tester);

    expect(l.opTitle, 'AI Operations Center');
    expect(find.text('Today\'s Activity'), findsOneWidget);
    expect(find.text('Knowledge Growth'), findsOneWidget);
    expect(find.text('Customer Insights'), findsOneWidget);
    expect(find.text('Business Impact'), findsOneWidget);
    expect(find.text('Knowledge Quality'), findsOneWidget);
    expect(find.text('Business Insights'), findsOneWidget);
    expect(find.text(l.opDemoNoticeTitle), findsOneWidget);
  });

  testWidgets('never shows sample figures without demo identification', (
    tester,
  ) async {
    await pumpScreen(tester, demoEnabled: false, size: const Size(900, 900));
    final l = l10n(tester);

    expect(find.byKey(const Key('operations-demo-disabled')), findsOneWidget);
    expect(find.text(l.opDemoDisabledTitle), findsOneWidget);
    expect(find.text(l.opDemoBadge), findsNothing);
    expect(find.byKey(const Key('operations-today-activity')), findsNothing);
  });

  testWidgets('has no overflow on mobile, tablet and desktop', (tester) async {
    for (final size in const [
      Size(360, 900),
      Size(820, 1100),
      Size(1440, 1400),
    ]) {
      await pumpScreen(tester, size: size);
      expect(tester.takeException(), isNull, reason: 'overflow at $size');
    }
  });
}
