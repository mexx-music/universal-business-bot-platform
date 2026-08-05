import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_provider_id.dart';
import 'package:universalbusiness/ai/ai_transport.dart';
import 'package:universalbusiness/ai/transports/edge_function_client.dart';
import 'package:universalbusiness/ai/transports/supabase_ai_transport.dart';

/// In-memory EdgeFunctionClient — records the invoked body and replays a
/// scripted response/error. No network.
class FakeEdgeFunctionClient implements EdgeFunctionClient {
  FakeEdgeFunctionClient({this.response, this.throwError, this.delay});

  EdgeFunctionResponse? response;
  Object? throwError;
  Duration? delay;

  String? lastName;
  Map<String, Object?>? lastBody;
  int calls = 0;

  @override
  Future<EdgeFunctionResponse> invoke(
    String functionName, {
    required Map<String, Object?> body,
  }) async {
    calls++;
    lastName = functionName;
    lastBody = body;
    if (delay != null) await Future<void>.delayed(delay!);
    if (throwError != null) throw throwError!;
    return response ??
        const EdgeFunctionResponse(
          status: 200,
          data: {
            'text': 'ok',
            'model': 'gemini-3.6-flash',
            'finishReason': 'STOP',
            'usage': {'inputTokens': 1, 'outputTokens': 1, 'totalTokens': 2},
          },
        );
  }
}

AiTransportRequest req({
  String? model,
  int? maxTokens,
  double? temperature,
  Map<String, String> metadata = const {},
}) {
  return AiTransportRequest(
    providerId: AiProviderId.googleGemini,
    model: model,
    maxTokens: maxTokens,
    temperature: temperature,
    metadata: metadata,
    messages: const [
      AiTransportMessage(role: 'system', content: 'Sei knapp.'),
      AiTransportMessage(role: 'user', content: 'Hallo'),
    ],
  );
}

void main() {
  group('send: serialization', () {
    test('targets ai-generate with the canonical body', () async {
      final client = FakeEdgeFunctionClient();
      final transport = SupabaseAiTransport(client);
      await transport.send(req(model: 'gemini-3.6-flash', maxTokens: 100));

      expect(client.lastName, 'ai-generate');
      final body = client.lastBody!;
      expect(body['provider'], 'googleGemini');
      expect(body.containsKey('providerId'), isFalse);
      expect(body['model'], 'gemini-3.6-flash');
      expect(body['maxTokens'], 100);
      expect(body['action'], 'generate');
      final messages = body['messages'] as List;
      expect(messages, hasLength(2));
      expect((messages.first as Map)['role'], 'system');
      expect((messages.last as Map)['content'], 'Hallo');
    });

    test('metadata and sampling params are not forwarded', () async {
      final client = FakeEdgeFunctionClient();
      final transport = SupabaseAiTransport(client);
      await transport.send(req(temperature: 0.9, metadata: {'ws': 'hb'}));

      final body = client.lastBody!;
      expect(body.containsKey('metadata'), isFalse);
      expect(body.containsKey('temperature'), isFalse);
      expect(body.containsKey('modelHint'), isFalse);
    });
  });

  group('send: success mapping', () {
    test('maps text, model, finishReason and usage', () async {
      final client = FakeEdgeFunctionClient(
        response: const EdgeFunctionResponse(
          status: 200,
          data: {
            'text': 'Antwort',
            'model': 'gemini-3.6-flash',
            'finishReason': 'MAX_TOKENS',
            'usage': {'inputTokens': 11, 'outputTokens': 4, 'totalTokens': 15},
          },
        ),
      );
      final response = await SupabaseAiTransport(client).send(req());
      expect(response.text, 'Antwort');
      expect(response.model, 'gemini-3.6-flash');
      expect(response.finishReason, 'MAX_TOKENS');
      expect(response.usage!.promptTokens, 11);
      expect(response.usage!.completionTokens, 4);
    });

    test('missing text field is a badResponse', () async {
      final client = FakeEdgeFunctionClient(
        response: const EdgeFunctionResponse(
          status: 200,
          data: {'model': 'gemini-3.6-flash'},
        ),
      );
      await expectLater(
        SupabaseAiTransport(client).send(req()),
        throwsA(
          isA<AiTransportException>().having(
            (e) => e.kind,
            'kind',
            AiTransportErrorKind.badResponse,
          ),
        ),
      );
    });
  });

  group('send: error-code mapping (machine-readable, not just status)', () {
    final cases = <String, (int, AiTransportErrorKind)>{
      'invalid_request': (400, AiTransportErrorKind.badRequest),
      'unauthorized': (401, AiTransportErrorKind.unauthorized),
      'missing_server_configuration': (500, AiTransportErrorKind.configuration),
      'rate_limited': (429, AiTransportErrorKind.rateLimited),
      'upstream_timeout': (504, AiTransportErrorKind.timeout),
      'upstream_unavailable': (502, AiTransportErrorKind.network),
      'content_blocked': (422, AiTransportErrorKind.contentBlocked),
      'malformed_upstream_response': (502, AiTransportErrorKind.badResponse),
      'internal_error': (500, AiTransportErrorKind.server),
    };

    cases.forEach((code, expected) {
      test('$code -> ${expected.$2.name}', () async {
        final client = FakeEdgeFunctionClient(
          response: EdgeFunctionResponse(
            status: expected.$1,
            data: {
              'error': {'code': code, 'message': 'x', 'requestId': 'r'},
            },
          ),
        );
        await expectLater(
          SupabaseAiTransport(client).send(req()),
          throwsA(
            isA<AiTransportException>().having(
              (e) => e.kind,
              'kind',
              expected.$2,
            ),
          ),
        );
      });
    });

    test('falls back to status when no error.code present', () async {
      final client = FakeEdgeFunctionClient(
        response: const EdgeFunctionResponse(status: 429, data: {}),
      );
      await expectLater(
        SupabaseAiTransport(client).send(req()),
        throwsA(
          isA<AiTransportException>().having(
            (e) => e.kind,
            'kind',
            AiTransportErrorKind.rateLimited,
          ),
        ),
      );
    });
  });

  group('send: infrastructure failures', () {
    test('network/SDK failure maps to network', () async {
      final client = FakeEdgeFunctionClient(throwError: Exception('boom'));
      await expectLater(
        SupabaseAiTransport(client).send(req()),
        throwsA(
          isA<AiTransportException>().having(
            (e) => e.kind,
            'kind',
            AiTransportErrorKind.network,
          ),
        ),
      );
    });

    test('client-side timeout maps to timeout', () async {
      final client = FakeEdgeFunctionClient(delay: const Duration(seconds: 5));
      final transport = SupabaseAiTransport(
        client,
        timeout: const Duration(milliseconds: 50),
      );
      await expectLater(
        transport.send(req()),
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

  group('ping', () {
    test('uses the free ping path, never a generate call', () async {
      final client = FakeEdgeFunctionClient(
        response: const EdgeFunctionResponse(
          status: 200,
          data: {'ok': true, 'provider': 'googleGemini'},
        ),
      );
      await SupabaseAiTransport(client).ping();
      expect(client.calls, 1);
      expect(client.lastBody!['action'], 'ping');
      expect(client.lastBody!.containsKey('messages'), isFalse);
    });

    test('ping surfaces a mapped error', () async {
      final client = FakeEdgeFunctionClient(
        response: const EdgeFunctionResponse(
          status: 500,
          data: {
            'error': {'code': 'missing_server_configuration'},
          },
        ),
      );
      await expectLater(
        SupabaseAiTransport(client).ping(),
        throwsA(
          isA<AiTransportException>().having(
            (e) => e.kind,
            'kind',
            AiTransportErrorKind.configuration,
          ),
        ),
      );
    });
  });
}
