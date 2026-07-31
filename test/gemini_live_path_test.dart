import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_controller.dart';
import 'package:universalbusiness/ai/ai_provider_config.dart';
import 'package:universalbusiness/ai/ai_provider_id.dart';
import 'package:universalbusiness/ai/ai_provider_selection.dart';
import 'package:universalbusiness/ai/ai_transport.dart';
import 'package:universalbusiness/ai/grounded_answer_service.dart';
import 'package:universalbusiness/ai/providers/gemini_provider.dart';
import 'package:universalbusiness/ai/providers/mock_ai_provider.dart';
import 'package:universalbusiness/ai/transports/edge_function_client.dart';
import 'package:universalbusiness/ai/transports/supabase_ai_transport.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/models/bot_configuration.dart';
import 'package:universalbusiness/models/business_rules.dart';
import 'package:universalbusiness/models/company.dart';
import 'package:universalbusiness/models/company_workspace.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';
import 'package:universalbusiness/screens/bot_test/grounded_answer_panel.dart';

/// Fake Supabase Edge client — captures the request body and replays a scripted
/// EdgeFunctionResponse or throws. No `supabase_flutter`, no network.
class FakeEdgeClient implements EdgeFunctionClient {
  FakeEdgeClient(this.responder);

  final FutureOr<EdgeFunctionResponse> Function(Map<String, Object?> body)
  responder;
  Map<String, Object?>? lastBody;
  String? lastFunction;
  int calls = 0;

  @override
  Future<EdgeFunctionResponse> invoke(
    String functionName, {
    required Map<String, Object?> body,
  }) async {
    calls++;
    lastFunction = functionName;
    lastBody = body;
    return responder(body);
  }
}

EdgeFunctionResponse edgeOk({
  String text = 'Wir rösten täglich frisch.',
  String model = 'gemini-3.6-flash',
}) {
  return EdgeFunctionResponse(
    status: 200,
    data: {
      'text': text,
      'model': model,
      'finishReason': 'STOP',
      'usage': {'inputTokens': 10, 'outputTokens': 5, 'totalTokens': 15},
      'requestId': 'req-live-1',
    },
  );
}

EdgeFunctionResponse edgeError(String code, int status) => EdgeFunctionResponse(
  status: status,
  data: {
    'error': {'code': code, 'message': 'x', 'requestId': 'r'},
  },
);

/// Builds the full live stack: buildAiController('gemini') → GeminiProvider →
/// SupabaseAiTransport → the fake edge client.
AiController liveController(FakeEdgeClient client) => buildAiController(
  providerFlag: 'gemini',
  geminiTransport: SupabaseAiTransport(client),
);

final _geminiConfig = AiProviderCatalog.defaults().firstWhere(
  (c) => c.id == AiProviderId.googleGemini,
);

// --- knowledge fixtures (mirrors the grounded service tests) ---------------

KnowledgeEntry entry(String id, String title, String content) => KnowledgeEntry(
  id: id,
  title: title,
  content: content,
  category: KnowledgeCategory.faq,
  riskLevel: RiskLevel.green,
  keywords: const ['kaffee'],
  source: 'Test',
  createdAt: DateTime(2026, 1, 1),
);

CompanyWorkspace workspace(List<KnowledgeEntry> entries) => CompanyWorkspace(
  company: const Company(
    id: 'co-a',
    name: 'Firma A',
    industry: '',
    description: '',
    website: '',
    email: 'a@example.invalid',
    address: '',
  ),
  products: const [],
  knowledgeEntries: entries,
  botLogs: const [],
  auditItems: const [],
  businessRules: const BusinessRules(
    brandVoice: '',
    doNotSay: [],
    allowedSupportTopics: [],
    escalationNotes: '',
  ),
  botConfiguration: const BotConfiguration(
    status: BotStatus.testReady,
    answerStyle: BotAnswerStyle.balanced,
    defaultLanguage: 'de',
    useDisclaimer: false,
    disclaimerText: '',
    alwaysEscalateRedFlags: true,
    escalateNoMatch: true,
    escalateYellowRisk: false,
    allowedTopics: [],
    blockedTopics: [],
    handoverMessage: '',
  ),
  sourceMaterials: const [],
);

CompanyWorkspace coffeeWorkspace() => workspace([
  entry('k1', 'Kaffee Thema 1', 'Alles über kaffee und rösterei eins.'),
  entry('k2', 'Kaffee Thema 2', 'Mehr über kaffee und rösterei zwei.'),
  entry('unrelated', 'Regenschirm', 'nichts mit dem heissen getränk zu tun'),
]);

GroundedAnswerRequest coffeeRequest() => GroundedAnswerRequest(
  question: 'kaffee',
  workspace: coffeeWorkspace(),
  language: 'de',
  maxSources: 2,
);

void main() {
  group('Live provider configuration', () {
    test('AI_PROVIDER=gemini yields a real GeminiProvider (not mock)', () {
      final controller = liveController(FakeEdgeClient((_) => edgeOk()));
      expect(controller.activeProviderId, AiProviderId.googleGemini);
      expect(controller.activeProvider, isA<GeminiProvider>());
      expect(controller.activeProvider, isNot(isA<MockAiProvider>()));
    });

    test(
      'gemini without a transport fails loudly (no silent mock fallback)',
      () {
        expect(
          () => buildAiController(providerFlag: 'gemini'),
          throwsA(isA<AiConfigurationException>()),
        );
      },
    );
  });

  group('Grounded answer over the live Gemini stack', () {
    test('returns a live (non-mock) answer with Gemini badge data', () async {
      final client = FakeEdgeClient((_) => edgeOk());
      final service = GroundedAnswerService(
        aiController: liveController(client),
      );

      final result = await service.answer(coffeeRequest());

      expect(result.grounded, isTrue);
      expect(result.isMock, isFalse);
      expect(result.providerId, AiProviderId.googleGemini);
      expect(result.providerDisplayName, _geminiConfig.displayName);
      expect(result.model, 'gemini-3.6-flash');
      expect(result.answer, 'Wir rösten täglich frisch.');
      // Sources are bound to the actually-used knowledge entries.
      expect(
        result.sources.map((s) => s.id),
        containsAll(<String>['k1', 'k2']),
      );
    });

    test('only the selected context reaches the edge function', () async {
      final client = FakeEdgeClient((_) => edgeOk());
      final service = GroundedAnswerService(
        aiController: liveController(client),
      );

      await service.answer(coffeeRequest());

      expect(client.calls, 1);
      expect(client.lastFunction, 'ai-generate');
      final messages = (client.lastBody!['messages'] as List)
          .cast<Map<String, Object?>>();
      final user = messages.firstWhere((m) => m['role'] == 'user');
      final content = user['content'] as String;
      // Selected entries present; the unrelated one and secrets are absent.
      expect(content, contains('Kaffee Thema 1'));
      expect(content, isNot(contains('Regenschirm')));
      expect(content, isNot(contains('GEMINI_API_KEY')));
      // Canonical transport shape, no sampling params leaked.
      expect(client.lastBody!['provider'], 'googleGemini');
      expect(client.lastBody!.containsKey('temperature'), isFalse);
      expect(client.lastBody!.containsKey('metadata'), isFalse);
    });

    test(
      'content_blocked from the edge surfaces as a transport error',
      () async {
        final client = FakeEdgeClient((_) => edgeError('content_blocked', 422));
        final service = GroundedAnswerService(
          aiController: liveController(client),
        );
        await expectLater(
          service.answer(coffeeRequest()),
          throwsA(
            isA<AiTransportException>().having(
              (e) => e.kind,
              'kind',
              AiTransportErrorKind.contentBlocked,
            ),
          ),
        );
      },
    );

    test('a timeout surfaces as a timeout transport error', () async {
      final client = FakeEdgeClient((_) => throw TimeoutException('slow'));
      final service = GroundedAnswerService(
        aiController: liveController(client),
      );
      await expectLater(
        service.answer(coffeeRequest()),
        throwsA(
          isA<AiTransportException>().having(
            (e) => e.kind,
            'kind',
            AiTransportErrorKind.timeout,
          ),
        ),
      );
    });

    test('an invalid edge response (no text) is a badResponse', () async {
      final client = FakeEdgeClient(
        (_) => const EdgeFunctionResponse(status: 200, data: {'model': 'x'}),
      );
      final service = GroundedAnswerService(
        aiController: liveController(client),
      );
      await expectLater(
        service.answer(coffeeRequest()),
        throwsA(
          isA<AiTransportException>().having(
            (e) => e.kind,
            'kind',
            AiTransportErrorKind.badResponse,
          ),
        ),
      );
    });

    test(
      'a live error never becomes a mock answer; provider stays Gemini',
      () async {
        final client = FakeEdgeClient(
          (_) => edgeError('upstream_unavailable', 502),
        );
        final controller = liveController(client);
        final service = GroundedAnswerService(aiController: controller);

        await expectLater(
          service.answer(coffeeRequest()),
          throwsA(isA<AiTransportException>()),
        );
        // No downgrade to mock after a failure.
        expect(controller.activeProviderId, AiProviderId.googleGemini);
        expect(controller.activeProvider, isNot(isA<MockAiProvider>()));
      },
    );
  });

  group('Provider badge (honest live/mock distinction)', () {
    testWidgets('shows Gemini provider and model for a live answer', (
      tester,
    ) async {
      final result = GroundedAnswerResult(
        outcome: GroundedOutcome.answered,
        answer: 'Live-Antwort',
        isMock: false,
        providerId: AiProviderId.googleGemini,
        providerDisplayName: 'Google Gemini',
        model: 'gemini-3.6-flash',
        sources: const [
          GroundedSource(
            id: 'k1',
            title: 'Kaffee',
            category: KnowledgeCategory.faq,
            excerpt: 'x',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppStateScope(
                notifier: AppState(),
                child: GroundedAnswerPanel(
                  serviceOverride: _StubService(result),
                ),
              ),
            ),
          ),
        ),
      );
      final l = AppLocalizations.of(
        tester.element(find.byType(GroundedAnswerPanel)),
      )!;

      await tester.enterText(find.byType(TextField), 'kaffee');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Live badge names the vendor + model, and is NOT the offline-mock label.
      expect(find.textContaining('Google Gemini'), findsOneWidget);
      expect(find.textContaining('gemini-3.6-flash'), findsOneWidget);
      expect(find.textContaining(l.botDemoProviderMock), findsNothing);
    });
  });
}

/// Minimal stub service for the widget badge test (no controller call).
class _StubService extends GroundedAnswerService {
  _StubService(this.result) : super(aiController: _throwingController());
  final GroundedAnswerResult result;

  @override
  Future<GroundedAnswerResult> answer(GroundedAnswerRequest request) async =>
      result;
}

AiController _throwingController() =>
    buildAiController(providerFlag: 'mock'); // never actually invoked
