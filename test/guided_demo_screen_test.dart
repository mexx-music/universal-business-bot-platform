import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_controller.dart';
import 'package:universalbusiness/ai/ai_provider_registry.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/screens/bot_test/grounded_answer_panel.dart';
import 'package:universalbusiness/screens/guided_demo/guided_demo_screen.dart';
import 'package:universalbusiness/screens/knowledge_builder/knowledge_builder_screen.dart';
import 'package:universalbusiness/screens/knowledge_improvement/knowledge_improvement_screen.dart';

Future<void> pumpScreen(
  WidgetTester tester, {
  Locale locale = const Locale('de'),
  Size size = const Size(1200, 1000),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: AiScope(
        notifier: AiController(AiProviderRegistry.mock()),
        child: AppStateScope(
          notifier: AppState(),
          child: const GuidedDemoScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(GuidedDemoScreen)))!;

/// Jumps to a step by tapping its side-nav entry (wide layout).
Future<void> jumpTo(WidgetTester tester, String title) async {
  await tester.tap(find.text(title).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'starts on the welcome step with the statement and start button',
    (tester) async {
      await pumpScreen(tester);
      final l = l10n(tester);

      expect(find.text(l.gdWelcomeStatement), findsOneWidget);
      expect(find.text(l.gdStart), findsOneWidget);
      // Progress bar is always visible.
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('start button advances to the knowledge builder step', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    await tester.tap(find.text(l.gdStart));
    await tester.pumpAndSettle();

    expect(find.text(l.gdNarr2), findsOneWidget);
    expect(find.byType(KnowledgeBuilderScreen), findsOneWidget);
  });

  testWidgets('walks through every step embedding the existing modules', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    // Step 2: real Knowledge Builder module.
    await jumpTo(tester, l.gdStep2Title);
    expect(find.byType(KnowledgeBuilderScreen), findsOneWidget);

    // Step 3: real Grounded assistant.
    await jumpTo(tester, l.gdStep3Title);
    expect(find.byType(GroundedAnswerPanel), findsOneWidget);
    expect(find.text(l.gdNarr3), findsOneWidget);

    // Step 4: gap — same grounded module, different narration.
    await jumpTo(tester, l.gdStep4Title);
    expect(find.byType(GroundedAnswerPanel), findsOneWidget);
    expect(find.text(l.gdNarr4), findsOneWidget);

    // Step 5: real Knowledge Improvement module.
    await jumpTo(tester, l.gdStep5Title);
    expect(find.byType(KnowledgeImprovementScreen), findsOneWidget);

    // Step 6: learning-loop overview.
    await jumpTo(tester, l.gdStep6Title);
    expect(find.text(l.gdLoopTitle), findsOneWidget);
    expect(find.text(l.gdLoop1), findsOneWidget);
    expect(find.text(l.gdLoop8), findsOneWidget);

    // Step 7: conclusion card with the three statements.
    await jumpTo(tester, l.gdStep7Title);
    expect(find.text(l.gdClosingTitle), findsOneWidget);
    expect(find.text(l.gdClosingLine1), findsOneWidget);
    expect(find.text(l.gdClosingLine2), findsOneWidget);
  });

  testWidgets('is localized in English', (tester) async {
    await pumpScreen(tester, locale: const Locale('en'));
    final l = l10n(tester);
    expect(
      l.gdWelcomeStatement,
      "BusinessBrain is a company's digital knowledge centre.",
    );
    expect(find.text(l.gdWelcomeStatement), findsOneWidget);
    expect(find.text(l.gdStart), findsOneWidget);
  });

  testWidgets('lays out without overflow on mobile and desktop', (
    tester,
  ) async {
    // Mobile: welcome + advance one step.
    await pumpScreen(tester, size: const Size(400, 900));
    final l = l10n(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text(l.gdStart));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Desktop: jump to the conclusion.
    await pumpScreen(tester, size: const Size(1400, 1000));
    await jumpTo(tester, l.gdStep7Title);
    expect(tester.takeException(), isNull);
  });
}
