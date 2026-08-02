import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_controller.dart';
import 'package:universalbusiness/ai/ai_provider_registry.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/jury/jury_mode_controller.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/screens/jury/jury_start_screen.dart';
import 'package:universalbusiness/screens/jury/jury_tour_screen.dart';

Future<void> pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('de'),
  Size size = const Size(1200, 1600),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: JuryModeScope(
        notifier: JuryModeController(),
        child: AiScope(
          notifier: AiController(AiProviderRegistry.mock()),
          child: AppStateScope(notifier: AppState(), child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations l10nOf(WidgetTester tester, Type t) =>
    AppLocalizations.of(tester.element(find.byType(t)))!;

void main() {
  testWidgets('landing hero shows brand, positioning and two actions', (
    tester,
  ) async {
    await pump(tester, const JuryStartScreen());
    final l = l10nOf(tester, JuryStartScreen);

    expect(find.text('BusinessBrain'), findsWidgets);
    expect(find.text(l.heroSubtitle), findsOneWidget);
    expect(find.text(l.heroBody), findsOneWidget);
    expect(find.text(l.heroStartDemo), findsOneWidget);
    expect(find.text(l.heroExplore), findsOneWidget);
    // Atmosphere flow nodes are present.
    expect(find.text(l.heroFlow1), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('landing hero has no overflow on mobile', (tester) async {
    await pump(tester, const JuryStartScreen(), size: const Size(380, 900));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tour shows "Schritt X von 6" step counter', (tester) async {
    await pump(tester, const JuryTourScreen());
    final l = l10nOf(tester, JuryTourScreen);
    expect(
      find.text('${l.kiStep} 1 ${l.juryOf} ${JuryTourScreen.stepCount}'),
      findsOneWidget,
    );
    // Transition line for the first station.
    expect(find.text(l.juryTrans1), findsOneWidget);
  });

  testWidgets('tour ends on the polished closing page', (tester) async {
    await pump(tester, const JuryTourScreen());
    final l = l10nOf(tester, JuryTourScreen);

    for (var i = 0; i < JuryTourScreen.stepCount - 1; i++) {
      await tester.tap(find.byKey(const Key('jury-next')));
      await tester.pumpAndSettle();
    }

    expect(find.text(l.oxClosingTitle), findsOneWidget);
    expect(find.text(l.oxClosingSubtitle), findsOneWidget);
    expect(find.text(l.oxSeenTitle), findsOneWidget);
    expect(find.text(l.oxSeen1), findsOneWidget); // Grounded AI
    expect(find.text(l.oxSeen7), findsOneWidget); // Business Story
    expect(find.text(l.oxThanks), findsOneWidget);
    expect(find.text(l.oxLinkGithub), findsOneWidget);
    // At the end the "Next" button is gone.
    expect(find.text(l.juryNext), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('landing hero is localized in English', (tester) async {
    await pump(tester, const JuryStartScreen(), locale: const Locale('en'));
    expect(find.text('The learning company AI.'), findsOneWidget);
    expect(find.text('Start jury demo'), findsOneWidget);
  });
}
