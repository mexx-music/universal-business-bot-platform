import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_provider_id.dart';
import 'package:universalbusiness/ai/ai_transport.dart';
import 'package:universalbusiness/ai/transports/edge_function_client.dart';
import 'package:universalbusiness/ai/transports/supabase_ai_transport.dart';

/// Pins the single canonical JSON contract that BOTH sides honour:
/// - Client: the wire body produced by [SupabaseAiTransport].
/// - Server: the fields the Edge Function's validate.ts reads
///   (provider, model, maxTokens, action, messages[{role,content}]).
///
/// Keeping this test green keeps the Dart transport and the (not-yet-deployed)
/// Edge Function aligned on one schema — no duplicate/aliased field names.
class _CapturingClient implements EdgeFunctionClient {
  Map<String, Object?>? body;

  @override
  Future<EdgeFunctionResponse> invoke(
    String functionName, {
    required Map<String, Object?> body,
  }) async {
    this.body = body;
    return const EdgeFunctionResponse(
      status: 200,
      data: {'text': 'ok', 'model': 'gemini-3.6-flash', 'finishReason': 'STOP'},
    );
  }
}

// The exact field set the Edge Function validate.ts consumes.
const _allowedGenerateKeys = {
  'provider',
  'model',
  'maxTokens',
  'action',
  'messages',
};
const _allowedRoles = {'system', 'user', 'assistant'};

void main() {
  test('generate wire body uses only canonical fields', () async {
    final client = _CapturingClient();
    await SupabaseAiTransport(client).send(
      const AiTransportRequest(
        providerId: AiProviderId.googleGemini,
        model: 'gemini-3.6-flash',
        maxTokens: 256,
        temperature: 0.7,
        metadata: {'workspace': 'hb-cure'},
        messages: [
          AiTransportMessage(role: 'system', content: 'S'),
          AiTransportMessage(role: 'user', content: 'U'),
        ],
      ),
    );

    final body = client.body!;
    // Only canonical keys — no providerId/modelHint/metadata/temperature.
    expect(body.keys.toSet().difference(_allowedGenerateKeys), isEmpty);
    expect(body['provider'], 'googleGemini');
    expect(body['action'], 'generate');
    expect(body['model'], 'gemini-3.6-flash');
    expect(body['maxTokens'], 256);

    final messages = (body['messages'] as List).cast<Map>();
    for (final m in messages) {
      expect(m.keys.toSet(), {'role', 'content'});
      expect(_allowedRoles.contains(m['role']), isTrue);
      expect(m['content'], isA<String>());
    }
  });

  test('ping wire body carries only provider + action', () async {
    final client = _CapturingClient();
    await SupabaseAiTransport(client).ping();
    expect(client.body!.keys.toSet(), {'provider', 'action'});
    expect(client.body!['provider'], 'googleGemini');
    expect(client.body!['action'], 'ping');
  });
}
