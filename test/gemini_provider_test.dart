import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_models.dart';
import 'package:universalbusiness/ai/ai_provider_config.dart';
import 'package:universalbusiness/ai/ai_provider_id.dart';
import 'package:universalbusiness/ai/ai_transport.dart';
import 'package:universalbusiness/ai/providers/gemini_provider.dart';

/// Records what it was asked to send and replays a scripted outcome — no
/// network, no Google SDK, no key.
class FakeAiTransport implements AiTransport {
  FakeAiTransport({
    this.response,
    this.sendError,
    this.sendDelay,
    this.pingError,
    this.pingDelay,
  });

  AiTransportResponse? response;
  AiTransportException? sendError;
  Duration? sendDelay;
  AiTransportException? pingError;
  Duration? pingDelay;

  AiTransportRequest? lastRequest;
  Duration? lastTimeout;
  int sendCalls = 0;
  int pingCalls = 0;

  @override
  Future<AiTransportResponse> send(
    AiTransportRequest request, {
    Duration? timeout,
  }) async {
    sendCalls++;
    lastRequest = request;
    lastTimeout = timeout;
    if (sendDelay != null) await Future<void>.delayed(sendDelay!);
    if (sendError != null) throw sendError!;
    return response ??
        const AiTransportResponse(text: 'ok', model: 'gemini-3.6-flash');
  }

  @override
  Future<void> ping({Duration? timeout}) async {
    pingCalls++;
    if (pingDelay != null) await Future<void>.delayed(pingDelay!);
    if (pingError != null) throw pingError!;
  }
}

void main() {
  AiProviderConfig geminiConfig() => AiProviderCatalog.defaults().firstWhere(
    (c) => c.id == AiProviderId.googleGemini,
  );

  group('GeminiProvider.generate', () {
    test('maps a successful transport response to AiResponse', () async {
      final transport = FakeAiTransport(
        response: const AiTransportResponse(
          text: 'Hallo aus Gemini',
          model: 'gemini-3.6-flash',
          finishReason: 'STOP',
          usage: AiTransportUsage(promptTokens: 12, completionTokens: 8),
          raw: {'candidates': 1},
        ),
      );
      final provider = GeminiProvider(
        config: geminiConfig(),
        transport: transport,
      );

      final response = await provider.generate(
        AiRequest.prompt('Frage', system: 'Sei knapp.'),
      );

      expect(response.text, 'Hallo aus Gemini');
      expect(response.providerId, AiProviderId.googleGemini);
      expect(response.model, 'gemini-3.6-flash');
      expect(response.finishReason, AiFinishReason.stop);
      expect(response.usage!.promptTokens, 12);
      expect(response.usage!.completionTokens, 8);
      expect(response.usage!.totalTokens, 20);
      expect(response.raw['candidates'], 1);
    });

    test(
      'maps messages and context, sends default model hint when omitted',
      () async {
        final transport = FakeAiTransport();
        final provider = GeminiProvider(
          config: geminiConfig(),
          transport: transport,
        );

        await provider.generate(
          const AiRequest(
            messages: [
              AiMessage.system('System-Regel'),
              AiMessage.user('Nutzerfrage'),
            ],
            temperature: 0.3,
            maxTokens: 256,
            metadata: {'workspace': 'hb-cure'},
          ),
        );

        final sent = transport.lastRequest!;
        expect(sent.providerId, AiProviderId.googleGemini);
        expect(sent.model, 'gemini-3.6-flash'); // default hint from config
        expect(sent.messages.map((m) => m.role), ['system', 'user']);
        expect(sent.messages.map((m) => m.content), [
          'System-Regel',
          'Nutzerfrage',
        ]);
        expect(sent.temperature, 0.3);
        expect(sent.maxTokens, 256);
        expect(sent.metadata['workspace'], 'hb-cure');
      },
    );

    test('an explicit request model overrides the default hint', () async {
      final transport = FakeAiTransport();
      final provider = GeminiProvider(
        config: geminiConfig(),
        transport: transport,
      );

      await provider.generate(
        const AiRequest(
          messages: [AiMessage.user('x')],
          model: 'gemini-3.6-pro',
        ),
      );

      expect(transport.lastRequest!.model, 'gemini-3.6-pro');
    });

    test('maps finish reasons (safety -> contentFilter)', () async {
      final transport = FakeAiTransport(
        response: const AiTransportResponse(
          text: '',
          model: 'gemini-3.6-flash',
          finishReason: 'SAFETY',
        ),
      );
      final provider = GeminiProvider(
        config: geminiConfig(),
        transport: transport,
      );

      final response = await provider.generate(AiRequest.prompt('x'));
      expect(response.finishReason, AiFinishReason.contentFilter);
    });

    test('transport errors surface (no silent fallback)', () async {
      final transport = FakeAiTransport(
        sendError: const AiTransportException(
          AiTransportErrorKind.server,
          'Edge function 500',
          statusCode: 500,
        ),
      );
      final provider = GeminiProvider(
        config: geminiConfig(),
        transport: transport,
      );

      await expectLater(
        provider.generate(AiRequest.prompt('x')),
        throwsA(
          isA<AiTransportException>().having(
            (e) => e.kind,
            'kind',
            AiTransportErrorKind.server,
          ),
        ),
      );
    });

    test('a hanging transport hits the provider timeout', () async {
      final transport = FakeAiTransport(sendDelay: const Duration(seconds: 10));
      final provider = GeminiProvider(
        config: geminiConfig(),
        transport: transport,
        timeout: const Duration(milliseconds: 50),
      );

      await expectLater(
        provider.generate(AiRequest.prompt('x')),
        throwsA(
          isA<AiTransportException>().having(
            (e) => e.kind,
            'kind',
            AiTransportErrorKind.timeout,
          ),
        ),
      );
    });
  });

  group('GeminiProvider.testConnection', () {
    test('healthy when ping succeeds', () async {
      final provider = GeminiProvider(
        config: geminiConfig(),
        transport: FakeAiTransport(),
      );
      final health = await provider.testConnection();
      expect(health.status, AiProviderHealthStatus.healthy);
      expect(health.isHealthy, isTrue);
      expect(health.checkedAt, isNotNull);
    });

    test('unauthorized maps to unauthorized health (never throws)', () async {
      final provider = GeminiProvider(
        config: geminiConfig(),
        transport: FakeAiTransport(
          pingError: const AiTransportException(
            AiTransportErrorKind.unauthorized,
            'missing key on server',
          ),
        ),
      );
      final health = await provider.testConnection();
      expect(health.status, AiProviderHealthStatus.unauthorized);
      expect(health.isHealthy, isFalse);
    });

    test('network error maps to unreachable', () async {
      final provider = GeminiProvider(
        config: geminiConfig(),
        transport: FakeAiTransport(
          pingError: const AiTransportException(
            AiTransportErrorKind.network,
            'connection refused',
          ),
        ),
      );
      final health = await provider.testConnection();
      expect(health.status, AiProviderHealthStatus.unreachable);
    });

    test('ping timeout maps to unreachable', () async {
      final provider = GeminiProvider(
        config: geminiConfig(),
        transport: FakeAiTransport(pingDelay: const Duration(seconds: 10)),
        timeout: const Duration(milliseconds: 50),
      );
      final health = await provider.testConnection();
      expect(health.status, AiProviderHealthStatus.unreachable);
    });
  });

  group('Client isolation', () {
    test('provider only ever talks to the injected transport', () async {
      final transport = FakeAiTransport();
      final provider = GeminiProvider(
        config: geminiConfig(),
        transport: transport,
      );
      await provider.generate(AiRequest.prompt('a'));
      await provider.testConnection();
      // All work went through the transport; there is no other I/O path.
      expect(transport.sendCalls, 1);
      expect(transport.pingCalls, 1);
      // The config carries no key value (key lives only on the server).
      expect(provider.config.apiKey, isEmpty);
    });
  });
}
