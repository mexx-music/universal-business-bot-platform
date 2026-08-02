import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:universalbusiness/app/app_dependencies.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/screens/vision/businessbrain_vision_screen.dart';

Future<void> pumpScreen(
  WidgetTester tester, {
  Locale locale = const Locale('de'),
  Size size = const Size(1200, 3000),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: const BusinessBrainVisionScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations l10n(WidgetTester tester) => AppLocalizations.of(
  tester.element(find.byType(BusinessBrainVisionScreen)),
)!;

void main() {
  testWidgets('separates today from the three-phase future journey', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    expect(find.text(l.visionFutureLabel), findsOneWidget);
    expect(find.text(l.visionTodayTitle), findsOneWidget);
    expect(find.text(l.visionPhase1Title), findsOneWidget);
    expect(find.text(l.visionPhase2Title), findsOneWidget);
    expect(find.text(l.visionPhase3Title), findsOneWidget);
    expect(find.text(l.visionJourneyTitle), findsOneWidget);
  });

  testWidgets('marks every future capability with prominent vision badges', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    // Hero, two future phases, three future flow stages, 21 capability cards
    // and the closing all carry the same unmistakable VISION label.
    expect(
      find.text(l.visionBadge).evaluate().length,
      greaterThanOrEqualTo(28),
    );
    expect(find.text(l.visionWebsiteTitle), findsOneWidget);
    expect(find.text(l.visionEmailTitle), findsOneWidget);
    expect(find.text(l.visionCompetitorsTitle), findsOneWidget);
    expect(find.text(l.visionCampaignTitle), findsOneWidget);
    expect(find.text(l.visionMorningTitle), findsOneWidget);
  });

  testWidgets('shows every named public platform in the future view', (
    tester,
  ) async {
    await pumpScreen(tester);

    for (final platform in [
      'Facebook',
      'Instagram',
      'Reddit',
      'LinkedIn',
      'YouTube',
      'TikTok',
      'Google Business',
    ]) {
      expect(find.text(platform), findsOneWidget);
    }
  });

  testWidgets('makes the human-control boundaries explicit', (tester) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    expect(find.text(l.visionNeverDecides), findsOneWidget);
    expect(find.text(l.visionNeverPublishes), findsOneWidget);
    expect(find.text(l.visionNeverChanges), findsOneWidget);
    expect(find.text(l.visionOnlySuggests), findsOneWidget);
    expect(find.text(l.visionHumanAlways), findsOneWidget);
  });

  testWidgets('is fully localized in English', (tester) async {
    await pumpScreen(tester, locale: const Locale('en'));
    final l = l10n(tester);

    expect(find.text('Future development'), findsOneWidget);
    expect(find.text('Knowledge system'), findsOneWidget);
    expect(find.text('Business assistant'), findsOneWidget);
    expect(find.text('Digital business brain'), findsOneWidget);
    expect(find.text(l.visionHumanAlways), findsOneWidget);
  });

  testWidgets('lays out without overflow on mobile and desktop', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(360, 1800));
    expect(tester.takeException(), isNull);

    await pumpScreen(tester, size: const Size(1440, 2600));
    expect(tester.takeException(), isNull);
  });

  testWidgets('is reachable through the public vision route', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UniversalBusinessApp(dependencies: AppDependencies.local()),
    );
    await tester.pumpAndSettle();

    final router = GoRouter.of(tester.element(find.byType(Navigator).first));
    router.go('/vision');
    await tester.pumpAndSettle();

    expect(find.byType(BusinessBrainVisionScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
