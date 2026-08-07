import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/app/app_dependencies.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/screens/public/landing_screen.dart';
import 'package:universalbusiness/widgets/public/landing_cta_section.dart';
import 'package:universalbusiness/widgets/public/landing_features_section.dart';
import 'package:universalbusiness/widgets/public/landing_workflow_section.dart';

Future<void> pumpLanding(
  WidgetTester tester, {
  Size size = const Size(1440, 1100),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    UniversalBusinessApp(dependencies: AppDependencies.local()),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpSection(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('de'),
  Size size = const Size(1200, 1000),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('hero positions BusinessBrain as the digital company brain', (
    tester,
  ) async {
    await pumpLanding(tester);
    final l = AppLocalizations.of(tester.element(find.byType(LandingScreen)))!;

    expect(find.text(l.landingHeroTitle), findsOneWidget);
    expect(find.text(l.landingHeroPromise), findsOneWidget);
    expect(find.text(l.landingHeroInputTitle), findsOneWidget);
    expect(find.text(l.landingHeroOutputTitle), findsOneWidget);
    expect(find.text(l.landingHeroHumanControl), findsOneWidget);
    expect(find.byKey(const Key('landing-start-demo')), findsOneWidget);
    expect(find.byKey(const Key('landing-explore-platform')), findsOneWidget);
    expect(find.byKey(const Key('landing-explore-vision')), findsOneWidget);
    expect(find.text('Universal Business Bot Platform'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('premium hero is fully localized in English', (tester) async {
    await pumpLanding(tester);
    await tester.tap(find.text('EN').first);
    await tester.pumpAndSettle();

    expect(find.text('The digital brain\nfor your business.'), findsOneWidget);
    expect(find.text('Know. Understand. Act. Learn.'), findsOneWidget);
    expect(find.text('Company knowledge'), findsOneWidget);
    expect(find.text('Useful for people and AI'), findsOneWidget);
    expect(find.text('Explore the vision'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('today and vision remain visibly separate', (tester) async {
    await pumpSection(tester, const LandingFeaturesSection());
    final l = AppLocalizations.of(
      tester.element(find.byType(LandingFeaturesSection)),
    )!;

    expect(find.byKey(const Key('landing-available-now')), findsOneWidget);
    expect(find.byKey(const Key('landing-vision-stage')), findsOneWidget);
    expect(find.text(l.landingAvailableNow), findsOneWidget);
    expect(find.text(l.landingVisionStage), findsOneWidget);
    expect(find.text(l.landingFeatureKnowledgeBuilder), findsOneWidget);
    expect(find.text(l.landingFeatureGroundedAnswers), findsOneWidget);
    expect(find.text(l.landingVisionExternalSignals), findsOneWidget);
    expect(find.text(l.landingGeminiTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('human-controlled learning loop shows all six steps', (
    tester,
  ) async {
    await pumpSection(tester, const LandingWorkflowSection());
    final l = AppLocalizations.of(
      tester.element(find.byType(LandingWorkflowSection)),
    )!;

    expect(find.text(l.landingTimelineStep1), findsOneWidget);
    expect(find.text(l.landingTimelineStep2), findsOneWidget);
    expect(find.text(l.landingTimelineStep3), findsOneWidget);
    expect(find.text(l.landingTimelineStep4), findsOneWidget);
    expect(find.text(l.landingTimelineStep5), findsOneWidget);
    expect(find.text(l.landingTimelineStep6), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'landing message and actions remain visible without overflow on mobile',
    (tester) async {
      await pumpLanding(tester, size: const Size(390, 844));
      final l = AppLocalizations.of(
        tester.element(find.byType(LandingScreen)),
      )!;

      expect(find.text(l.landingHeroTitle), findsOneWidget);
      expect(find.text(l.landingHeroPromise), findsOneWidget);
      expect(find.byKey(const Key('landing-start-demo')), findsOneWidget);
      expect(find.byKey(const Key('landing-explore-platform')), findsOneWidget);
      expect(find.byKey(const Key('landing-explore-vision')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('status panels and learning loop do not overflow on mobile', (
    tester,
  ) async {
    await pumpSection(
      tester,
      const Column(
        children: [LandingWorkflowSection(), LandingFeaturesSection()],
      ),
      size: const Size(390, 844),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('final mobile CTA keeps all three public journeys reachable', (
    tester,
  ) async {
    await pumpSection(
      tester,
      LandingCtaSection(onDemo: () {}, onExplore: () {}, onVision: () {}),
      size: const Size(390, 844),
    );

    expect(find.byKey(const Key('landing-cta-demo')), findsOneWidget);
    expect(find.byKey(const Key('landing-cta-platform')), findsOneWidget);
    expect(find.byKey(const Key('landing-cta-vision')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
