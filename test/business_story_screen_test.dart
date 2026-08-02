import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/screens/business_story/business_story_screen.dart';

Future<void> pumpScreen(
  WidgetTester tester, {
  Locale locale = const Locale('de'),
  Size size = const Size(1100, 2200),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: const BusinessStoryScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(BusinessStoryScreen)))!;

void main() {
  testWidgets('renders all six sections and the closing', (tester) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    expect(find.text(l.bsProblemTitle), findsOneWidget);
    expect(find.text(l.bsSolutionTitle), findsOneWidget);
    expect(find.text(l.bsCycleTitle), findsOneWidget);
    expect(find.text(l.bsBenefitsTitle), findsOneWidget);
    expect(find.text(l.bsContrastTitle), findsOneWidget);
    expect(find.text(l.bsVisionTitle), findsOneWidget);
    expect(find.text(l.bsStatusTitle), findsOneWidget);
    expect(find.text(l.bsClosingTitle), findsOneWidget);
    expect(find.text(l.bsClosingBody), findsOneWidget);
  });

  testWidgets('cycle shows the full loop chain', (tester) async {
    await pumpScreen(tester);
    final l = l10n(tester);
    expect(find.text(l.gdLoop1), findsOneWidget);
    expect(find.text(l.gdLoop8), findsOneWidget);
  });

  testWidgets('benefits and contrast are rendered', (tester) async {
    await pumpScreen(tester);
    final l = l10n(tester);
    // A few grounded benefits.
    expect(find.text(l.bsBenefit1Title), findsOneWidget);
    expect(find.text(l.bsBenefit7Title), findsOneWidget); // no hallucinations
    // Contrast: does-not vs does.
    expect(find.text(l.bsNotTitle), findsOneWidget);
    expect(find.text(l.bsDoesTitle), findsOneWidget);
    expect(find.text(l.bsNot1), findsOneWidget);
    expect(find.text(l.bsDoes1), findsOneWidget);
  });

  testWidgets('vision is clearly labelled as future development', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);
    expect(find.textContaining(l.bsVisionBadge), findsOneWidget);
    // Vision items appear (vision section + status vision group).
    expect(find.text(l.bsVision1), findsWidgets);
  });

  testWidgets('status overview categorizes features into three groups', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);
    expect(find.textContaining(l.bsStatusAvailable), findsOneWidget);
    expect(find.textContaining(l.bsStatusInDev), findsOneWidget);
    expect(find.textContaining(l.bsStatusVision), findsOneWidget);
    // A real, available feature and an in-development one.
    expect(find.text(l.bsFeatGrounded), findsOneWidget); // available
    expect(find.text(l.bsFeatLiveGemini), findsOneWidget); // in development
  });

  testWidgets('is localized in English', (tester) async {
    await pumpScreen(tester, locale: const Locale('en'));
    final l = l10n(tester);
    expect(l.bsProblemTitle, 'The problem');
    expect(find.text('The problem'), findsOneWidget);
    expect(find.textContaining(l.bsStatusAvailable), findsOneWidget);
  });

  testWidgets('lays out without overflow on mobile and desktop', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(360, 2600));
    expect(tester.takeException(), isNull);

    await pumpScreen(tester, size: const Size(1400, 2000));
    expect(tester.takeException(), isNull);
  });
}
