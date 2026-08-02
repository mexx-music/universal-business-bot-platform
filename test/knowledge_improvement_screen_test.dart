import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/screens/knowledge_improvement/knowledge_improvement_screen.dart';

Future<void> pumpScreen(
  WidgetTester tester, {
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
      home: const KnowledgeImprovementScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations l10n(WidgetTester tester) => AppLocalizations.of(
  tester.element(find.byType(KnowledgeImprovementScreen)),
)!;

Future<void> next(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_forward));
  await tester.pumpAndSettle();
}

/// Taps "Next" until the final stage (the button is gone).
Future<void> advanceToEnd(WidgetTester tester) async {
  while (find.byIcon(Icons.arrow_forward).evaluate().isNotEmpty) {
    await next(tester);
  }
}

void main() {
  testWidgets('starts on the customer-question stage', (tester) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    expect(find.text(l.kiTitle), findsOneWidget);
    expect(find.text(l.kiIntro), findsOneWidget);
    expect(find.text(l.kiTrustNotice), findsOneWidget);
    expect(find.text(l.kiStage1Title), findsOneWidget);
    expect(find.text(l.kiQuestion), findsOneWidget);
  });

  testWidgets('walks the full loop to the aha moment', (tester) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    // 1 -> 2: AI answer (honest gap).
    await next(tester);
    expect(find.text(l.kiStage2Title), findsOneWidget);
    expect(find.text(l.kiGapAnswer), findsOneWidget);

    // 2 -> 3: gap detected with missing-term chips.
    await next(tester);
    expect(find.text(l.kiStage3Title), findsOneWidget);
    expect(find.text('bluetooth'), findsOneWidget);

    // 3 -> 4: improvement suggestion (FAQ category + drafted title).
    await next(tester);
    expect(find.text(l.kiStage4Title), findsOneWidget);
    expect(find.text(l.kbCatFaq), findsOneWidget);
    expect(find.text(l.kiSuggestionTitle), findsWidgets);

    // 4 -> 5: employee accepts.
    await next(tester);
    expect(find.text(l.kiStage5Title), findsOneWidget);

    // 5 -> 6: knowledge base grows (8 -> 9).
    await next(tester);
    expect(find.text(l.kiStage6Title), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);

    // 6 -> 7: before/after + aha moment; no further "next".
    await next(tester);
    expect(find.text(l.kiStage7Title), findsOneWidget);
    expect(find.text(l.kiBeforeLabel), findsOneWidget);
    expect(find.text(l.kiAfterLabel), findsOneWidget);
    expect(find.text(l.kiGapAnswer), findsOneWidget);
    expect(find.text(l.kiImprovedAnswer), findsOneWidget);
    expect(find.text(l.kiAhaTitle), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsNothing);
  });

  testWidgets('restart returns to the first stage', (tester) async {
    await pumpScreen(tester);
    final l = l10n(tester);
    await next(tester);
    await next(tester);
    expect(find.text(l.kiStage3Title), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.text(l.kiStage1Title), findsOneWidget);
    expect(find.text(l.kiQuestion), findsOneWidget);
  });

  testWidgets('is localized in English', (tester) async {
    await pumpScreen(tester, locale: const Locale('en'));
    final l = l10n(tester);
    expect(l.kiStage1Title, 'Customer question');
    expect(find.text('Customer question'), findsOneWidget);
    expect(find.text(l.kiIntro), findsOneWidget);
  });

  testWidgets('final stage lays out without overflow on mobile and desktop', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(360, 900));
    await advanceToEnd(tester);
    expect(tester.takeException(), isNull);

    await pumpScreen(tester, size: const Size(1400, 1000));
    await advanceToEnd(tester);
    expect(tester.takeException(), isNull);
  });
}
