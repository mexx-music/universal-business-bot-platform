import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_models.dart';
import 'package:universalbusiness/ai/ai_provider_id.dart';
import 'package:universalbusiness/ai/ai_provider_selection.dart';
import 'package:universalbusiness/ai/ai_transport.dart';
import 'package:universalbusiness/ai/providers/gemini_provider.dart';
import 'package:universalbusiness/ai/providers/mock_ai_provider.dart';
import 'package:universalbusiness/ai/transports/edge_function_client.dart';

/// Minimal AiTransport fake for selection tests: succeeds or fails.
class _FakeTransport implements AiTransport {
  _FakeTransport({this.fail = false});
  final bool fail;

  @override
  Future<AiTransportResponse> send(
    AiTransportRequest request, {
    Duration? timeout,
  }) async {
    if (fail) {
      throw const AiTransportException(AiTransportErrorKind.network, 'boom');
    }
    return const AiTransportResponse(text: 'ok', model: 'gemini-3.6-flash');
  }

  @override
  Future<void> ping({Duration? timeout}) async {}
}

void main() {
  test('AI_PROVIDER=mock selects the mock provider', () {
    final c = buildAiController(providerFlag: 'mock');
    expect(c.activeProviderId, AiProviderId.openAi);
    expect(c.activeProvider, isA<MockAiProvider>());
  });

  test('unset provider defaults to mock (local dev & tests)', () {
    final c = buildAiController(providerFlag: '');
    expect(c.activeProvider, isA<MockAiProvider>());
  });

  test('AI_PROVIDER=gemini selects the real Gemini provider', () {
    final c = buildAiController(
      providerFlag: 'gemini',
      geminiTransport: _FakeTransport(),
    );
    expect(c.activeProviderId, AiProviderId.googleGemini);
    expect(c.activeProvider, isA<GeminiProvider>());
  });

  test('provider flag is trimmed and case-insensitive', () {
    final c = buildAiController(
      providerFlag: '  GEMINI ',
      geminiTransport: _FakeTransport(),
    );
    expect(c.activeProviderId, AiProviderId.googleGemini);
  });

  test('gemini without a transport raises a clear configuration error', () {
    expect(
      () => buildAiController(providerFlag: 'gemini'),
      throwsA(isA<AiConfigurationException>()),
    );
  });

  test(
    'explicit gemini does NOT silently fall back to mock on failure',
    () async {
      final c = buildAiController(
        providerFlag: 'gemini',
        geminiTransport: _FakeTransport(fail: true),
      );
      // The failure surfaces as a real transport error...
      await expectLater(
        c.generate(AiRequest.prompt('x')),
        throwsA(isA<AiTransportException>()),
      );
      // ...and the active provider stays Gemini (no downgrade).
      expect(c.activeProviderId, AiProviderId.googleGemini);
      expect(c.activeProvider, isA<GeminiProvider>());
    },
  );

  test('the Gemini client carries no API key', () {
    final c = buildAiController(
      providerFlag: 'gemini',
      geminiTransport: _FakeTransport(),
    );
    final provider = c.activeProvider as GeminiProvider;
    expect(provider.config.apiKey, isEmpty);
  });
}
