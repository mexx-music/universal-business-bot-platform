import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_controller.dart';
import 'package:universalbusiness/ai/ai_provider_id.dart';
import 'package:universalbusiness/ai/ai_provider_registry.dart';
import 'package:universalbusiness/ai/ai_transport.dart';
import 'package:universalbusiness/ai/grounded_answer_service.dart';
import 'package:universalbusiness/ai/transports/edge_function_client.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';
import 'package:universalbusiness/screens/bot_test/grounded_answer_panel.dart';

/// Replaces the real service so the widget test never touches KnowledgeRuntime,
/// AppState content or any network — it just replays a scripted answer/error.
class StubService extends GroundedAnswerService {
  StubService(this.script)
    : super(aiController: AiController(AiProviderRegistry.mock()));

  final Future<GroundedAnswerResult> Function(int call) script;
  int calls = 0;

  @override
  Future<GroundedAnswerResult> answer(GroundedAnswerRequest request) {
    return script(calls++);
  }
}

GroundedAnswerResult answered({
  String answer = 'Wir haben täglich geöffnet.',
  bool isMock = true,
}) {
  return GroundedAnswerResult(
    outcome: GroundedOutcome.answered,
    answer: answer,
    isMock: isMock,
    providerId: isMock ? AiProviderId.openAi : AiProviderId.googleGemini,
    providerDisplayName: isMock ? 'Mock' : 'Google Gemini',
    model: isMock ? null : 'gemini-3.6-flash',
    sources: const [
      GroundedSource(
        id: 'k1',
        title: 'Öffnungszeiten',
        category: KnowledgeCategory.faq,
        excerpt: 'Täglich von 8 bis 18 Uhr.',
      ),
    ],
  );
}

GroundedAnswerResult noKnowledge() => const GroundedAnswerResult(
  outcome: GroundedOutcome.noKnowledge,
  providerId: AiProviderId.openAi,
  providerDisplayName: 'Mock',
  isMock: true,
);

Future<void> pumpPanel(WidgetTester tester, GroundedAnswerService service) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: AppStateScope(
            notifier: AppState(),
            child: GroundedAnswerPanel(serviceOverride: service),
          ),
        ),
      ),
    ),
  );
}

AppLocalizations l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(GroundedAnswerPanel)))!;

Future<void> ask(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  await tester.tap(find.byIcon(Icons.send));
}

void main() {
  testWidgets('shows answer, source and human-review hint', (tester) async {
    await pumpPanel(tester, StubService((_) async => answered()));
    final l = l10n(tester);

    await ask(tester, 'Wann habt ihr offen?');
    await tester.pumpAndSettle();

    expect(find.text('Wir haben täglich geöffnet.'), findsOneWidget);
    expect(find.text('Öffnungszeiten'), findsOneWidget); // source title
    expect(find.text('k1'), findsOneWidget); // source id
    expect(find.text(l.botDemoHumanReview), findsOneWidget);
    // Mock provider is labelled as the offline mock, not a vendor.
    expect(find.textContaining(l.botDemoProviderMock), findsOneWidget);
    expect(find.text(l.botDemoGrounded), findsOneWidget);
  });

  testWidgets('shows a loading indicator while the answer is pending', (
    tester,
  ) async {
    final completer = Completer<GroundedAnswerResult>();
    await pumpPanel(tester, StubService((_) => completer.future));
    final l = l10n(tester);

    await ask(tester, 'Frage');
    await tester.pump(); // enter loading state

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(l.botDemoLoading), findsOneWidget);

    completer.complete(answered());
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('honest not-found state without sources', (tester) async {
    await pumpPanel(tester, StubService((_) async => noKnowledge()));
    final l = l10n(tester);

    await ask(tester, 'Etwas Unbekanntes');
    await tester.pumpAndSettle();

    expect(find.text(l.botDemoNoKnowledge), findsWidgets);
    expect(find.text(l.botDemoSources), findsNothing);
    expect(find.text(l.botDemoHumanReview), findsOneWidget);
  });

  testWidgets('maps a transport error to a localized message with retry', (
    tester,
  ) async {
    await pumpPanel(
      tester,
      StubService(
        (_) async => throw const AiTransportException(
          AiTransportErrorKind.network,
          'down',
        ),
      ),
    );
    final l = l10n(tester);

    await ask(tester, 'Frage');
    await tester.pumpAndSettle();

    expect(find.text(l.botDemoErrorNetwork), findsOneWidget);
    expect(find.text(l.botDemoRetry), findsOneWidget);
  });

  testWidgets('maps a configuration error to the config message', (
    tester,
  ) async {
    await pumpPanel(
      tester,
      StubService((_) async => throw const AiConfigurationException('no key')),
    );
    final l = l10n(tester);

    await ask(tester, 'Frage');
    await tester.pumpAndSettle();

    expect(find.text(l.botDemoErrorConfig), findsOneWidget);
  });

  testWidgets('can re-run with a new question', (tester) async {
    await pumpPanel(
      tester,
      StubService(
        (call) async =>
            answered(answer: call == 0 ? 'Erste Antwort' : 'Zweite Antwort'),
      ),
    );

    await ask(tester, 'Frage 1');
    await tester.pumpAndSettle();
    expect(find.text('Erste Antwort'), findsOneWidget);

    await ask(tester, 'Frage 2');
    await tester.pumpAndSettle();
    expect(find.text('Zweite Antwort'), findsOneWidget);
    expect(find.text('Erste Antwort'), findsNothing);
  });

  testWidgets('does not submit an empty question', (tester) async {
    final stub = StubService((_) async => answered());
    await pumpPanel(tester, stub);

    // Tapping with empty input triggers no service call.
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    expect(stub.calls, 0);
  });
}
