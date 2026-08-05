import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/app/app_dependencies.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/roadmap/businessbrain_roadmap.dart';
import 'package:universalbusiness/screens/roadmap/businessbrain_roadmap_screen.dart';

Future<void> pumpRoadmap(
  WidgetTester tester, {
  Locale locale = const Locale('de'),
  Size size = const Size(1200, 2800),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: const BusinessBrainRoadmapScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations roadmapL10n(WidgetTester tester) => AppLocalizations.of(
  tester.element(find.byType(BusinessBrainRoadmapScreen)),
)!;

void main() {
  test('roadmap definition separates one available and six vision stages', () {
    expect(businessBrainRoadmap, hasLength(7));
    expect(
      businessBrainRoadmap.where(
        (stage) => stage.status == RoadmapStageStatus.available,
      ),
      hasLength(1),
    );
    expect(
      businessBrainRoadmap.where(
        (stage) => stage.status == RoadmapStageStatus.vision,
      ),
      hasLength(6),
    );
    expect(businessBrainRoadmap.first.nextExpansion, isFalse);
    expect(businessBrainRoadmap[1].nextExpansion, isTrue);
  });

  testWidgets('renders seven stages with permanently distinct status badges', (
    tester,
  ) async {
    await pumpRoadmap(tester);
    final l = roadmapL10n(tester);

    for (final stage in businessBrainRoadmap) {
      expect(
        find.byKey(ValueKey('roadmap-stage-${stage.id.name}')),
        findsOneWidget,
      );
    }
    expect(find.text(l.roadmapStage1Title), findsWidgets);
    expect(find.text(l.roadmapStage7Title), findsOneWidget);
    expect(find.text(l.roadmapAvailableBadge), findsWidgets);
    expect(find.text(l.roadmapVisionBadge).evaluate().length, greaterThan(6));
    expect(find.byKey(const Key('roadmap-next-stage')), findsOneWidget);
  });

  testWidgets('starts with the available verified-knowledge detail', (
    tester,
  ) async {
    await pumpRoadmap(tester);
    final l = roadmapL10n(tester);

    expect(
      find.byKey(const ValueKey('roadmap-detail-verifiedCompanyKnowledge')),
      findsOneWidget,
    );
    expect(find.text(l.roadmapFeatureKnowledgeBuilder), findsOneWidget);
    expect(find.text(l.roadmapFeatureHumanReview), findsOneWidget);
    expect(find.text(l.roadmapFeatureGroundedAnswers), findsOneWidget);
    expect(find.text(l.roadmapFeatureWebsiteLinks), findsOneWidget);
    expect(find.text(l.roadmapFeatureOperationsCenter), findsOneWidget);
    expect(find.text(l.roadmapVisionDisclaimer), findsNothing);
  });

  testWidgets('opens a clearly labelled marketing vision detail on tap', (
    tester,
  ) async {
    await pumpRoadmap(tester);
    final l = roadmapL10n(tester);

    await tester.tap(
      find.byKey(const ValueKey('roadmap-stage-marketingIntelligence')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('roadmap-detail-marketingIntelligence')),
      findsOneWidget,
    );
    expect(find.text(l.roadmapStage4Benefit), findsOneWidget);
    expect(find.text(l.roadmapStage4Control), findsOneWidget);
    expect(find.text('Google Business'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('YouTube'), findsOneWidget);
    expect(find.text(l.roadmapFeatureContentSuggestions), findsOneWidget);
    expect(find.text(l.roadmapVisionDisclaimer), findsOneWidget);
  });

  testWidgets('states the human-control boundary in journey and closing', (
    tester,
  ) async {
    await pumpRoadmap(tester);
    final l = roadmapL10n(tester);

    expect(find.text(l.roadmapHeroControl), findsOneWidget);
    expect(find.text(l.roadmapHumanTitle), findsOneWidget);
    expect(find.text(l.roadmapHumanBody), findsOneWidget);
    expect(find.byKey(const Key('roadmap-closing')), findsOneWidget);
  });

  testWidgets('is fully localized in English', (tester) async {
    await pumpRoadmap(tester, locale: const Locale('en'));
    final l = roadmapL10n(tester);

    expect(find.text('BusinessBrain Roadmap'), findsOneWidget);
    expect(find.text('Seven credible development stages'), findsOneWidget);
    expect(find.text('AVAILABLE TODAY'), findsWidgets);
    expect(find.text('VISION'), findsWidgets);
    expect(find.text(l.roadmapStage2Description), findsOneWidget);
    expect(find.text(l.roadmapHumanBody), findsOneWidget);
  });

  testWidgets('lays out without overflow on mobile, tablet and desktop', (
    tester,
  ) async {
    for (final size in const [
      Size(360, 900),
      Size(820, 1100),
      Size(1440, 1500),
    ]) {
      await pumpRoadmap(tester, size: size);
      expect(tester.takeException(), isNull, reason: 'overflow at $size');
    }
  });

  testWidgets('landing navigation opens the public roadmap', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UniversalBusinessApp(dependencies: AppDependencies.local()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('landing-roadmap')));
    await tester.pumpAndSettle();

    expect(find.byType(BusinessBrainRoadmapScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
