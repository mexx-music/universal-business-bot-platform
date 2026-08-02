import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_controller.dart';
import 'package:universalbusiness/ai/ai_provider_registry.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/screens/knowledge_workflow/knowledge_workflow_screen.dart';

Future<void> pumpScreen(
  WidgetTester tester,
  AppState state, {
  Locale locale = const Locale('de'),
  Size size = const Size(1100, 1400),
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
          notifier: state,
          child: const KnowledgeWorkflowScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(KnowledgeWorkflowScreen)))!;

Future<void> ask(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.send), warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String label) async {
  await tester.tap(find.text(label), warnIfMissed: false);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first ask detects the gap honestly (no hallucination)', (
    tester,
  ) async {
    final state = AppState();
    await pumpScreen(tester, state);
    final l = l10n(tester);

    await ask(tester);

    // Honest gap message, no fabricated answer, no sources.
    expect(find.text(l.botDemoNoKnowledge), findsWidgets);
    expect(find.text(l.botDemoSources), findsNothing);
    // The improvement suggestion (human review) appears automatically.
    expect(find.text(l.kwSuggestionTitle), findsOneWidget);
    // No "improved by new entry" banner yet.
    expect(find.text(l.kwImprovedInfo), findsNothing);
  });

  testWidgets('accepting creates a real entry; repeated question uses it', (
    tester,
  ) async {
    final state = AppState();
    final before = state.knowledgeEntries.length;
    await pumpScreen(tester, state);
    final l = l10n(tester);

    await ask(tester);
    await tapText(tester, l.kwAccept);

    // A real knowledge entry was added to the same knowledge base.
    expect(state.knowledgeEntries.length, before + 1);
    // The improved answer references the new entry as a source.
    expect(find.text(l.kwImprovedInfo), findsOneWidget);
    expect(find.text(l.botDemoSources), findsOneWidget);
    expect(find.text(l.kwSuggestedEntryTitle), findsWidgets);
    // The learning loop is marked complete.
    expect(find.text(l.kwClosingTitle), findsOneWidget);
  });

  testWidgets('rejecting leaves the knowledge base unchanged; gap persists', (
    tester,
  ) async {
    final state = AppState();
    final before = state.knowledgeEntries.length;
    await pumpScreen(tester, state);
    final l = l10n(tester);

    await ask(tester);
    await tapText(tester, l.kwReject);

    expect(state.knowledgeEntries.length, before);
    expect(find.text(l.kwRejectedInfo), findsOneWidget);
    // Same question still yields the honest gap, no improved answer.
    expect(find.text(l.botDemoNoKnowledge), findsWidgets);
    expect(find.text(l.kwImprovedInfo), findsNothing);
    expect(find.text(l.kwClosingTitle), findsNothing);
  });

  testWidgets('process rail marks steps complete after the loop', (
    tester,
  ) async {
    final state = AppState();
    await pumpScreen(tester, state);
    final l = l10n(tester);

    // Before asking: no green checks.
    expect(find.byIcon(Icons.check), findsNothing);

    await ask(tester);
    // Steps 1-3 done (question, gap, suggestion).
    expect(find.byIcon(Icons.check), findsNWidgets(3));

    await tapText(tester, l.kwAccept);
    // All six steps done.
    expect(find.byIcon(Icons.check), findsNWidgets(6));
  });

  testWidgets('is localized in English', (tester) async {
    final state = AppState();
    await pumpScreen(tester, state, locale: const Locale('en'));
    final l = l10n(tester);
    expect(l.kwClosingTitle, 'The learning loop completed successfully.');
    expect(find.text(l.kwQuestion), findsOneWidget);
  });

  testWidgets('completes the loop without overflow on mobile', (tester) async {
    await pumpScreen(tester, AppState(), size: const Size(380, 1600));
    final l = l10n(tester);
    await ask(tester);
    await tapText(tester, l.kwAccept);
    expect(find.text(l.kwClosingTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completes the loop without overflow on desktop', (tester) async {
    await pumpScreen(tester, AppState(), size: const Size(1400, 1200));
    final l = l10n(tester);
    await ask(tester);
    await tapText(tester, l.kwAccept);
    expect(find.text(l.kwClosingTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
