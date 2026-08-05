import 'dart:async';

import '../ai_models.dart';
import '../ai_provider.dart';
import '../ai_provider_config.dart';
import '../ai_provider_id.dart';
import '../ai_transport.dart';

/// Gemini adapter behind the vendor-neutral [AiProvider] interface.
///
/// Security by construction: this provider has NO Google SDK, HTTP client or
/// API key. It only talks to an injected [AiTransport] (a Supabase Edge
/// Function), which is the sole holder of the key on the server. Swapping the
/// transport (e.g. a fake in tests) needs no change here.
///
/// The default model comes from [AiProviderConfig.defaultModel] and is sent as
/// a hint; the server stays free to enforce the final model. There are no
/// silent fallbacks: a transport failure surfaces as a thrown
/// [AiTransportException] from [generate], and as an unhealthy
/// [AiProviderHealth] from [testConnection].
class GeminiProvider implements AiProvider {
  GeminiProvider({
    required this.config,
    required AiTransport transport,
    Duration timeout = const Duration(seconds: 30),
  }) : _transport = transport,
       _timeout = timeout;

  final AiProviderConfig config;
  final AiTransport _transport;
  final Duration _timeout;

  @override
  AiProviderId get id => config.id;

  @override
  String get displayName => config.displayName;

  @override
  AiProviderCapabilities get capabilities => config.capabilities;

  @override
  Future<AiResponse> generate(AiRequest request) async {
    final transportRequest = AiTransportRequest(
      providerId: id,
      model: request.model ?? config.defaultModel,
      messages: [
        for (final m in request.messages)
          AiTransportMessage(role: m.role.name, content: m.content),
      ],
      temperature: request.temperature,
      maxTokens: request.maxTokens,
      metadata: request.metadata,
    );

    final AiTransportResponse response;
    try {
      response = await _transport
          .send(transportRequest, timeout: _timeout)
          .timeout(_timeout);
    } on TimeoutException catch (e) {
      // Provider-enforced timeout guards against a hanging transport.
      throw AiTransportException(
        AiTransportErrorKind.timeout,
        'Gemini transport timed out after ${_timeout.inSeconds}s: ${e.message ?? ''}'
            .trim(),
      );
    }

    return AiResponse(
      text: response.text,
      providerId: id,
      model: response.model.isEmpty
          ? (request.model ?? config.defaultModel)
          : response.model,
      finishReason: _mapFinishReason(response.finishReason),
      usage: response.usage == null
          ? null
          : AiUsage(
              promptTokens: response.usage!.promptTokens,
              completionTokens: response.usage!.completionTokens,
            ),
      raw: response.raw,
    );
  }

  @override
  Future<AiProviderHealth> testConnection() async {
    try {
      await _transport.ping(timeout: _timeout).timeout(_timeout);
      return AiProviderHealth(
        status: AiProviderHealthStatus.healthy,
        message: 'Gemini transport reachable',
        checkedAt: DateTime.now(),
      );
    } on TimeoutException {
      return AiProviderHealth(
        status: AiProviderHealthStatus.unreachable,
        message: 'Gemini transport timed out',
        checkedAt: DateTime.now(),
      );
    } on AiTransportException catch (e) {
      return AiProviderHealth(
        status: _mapHealthStatus(e.kind),
        message: e.message,
        checkedAt: DateTime.now(),
      );
    }
  }

  AiFinishReason _mapFinishReason(String? reason) {
    switch (reason?.toUpperCase()) {
      case 'STOP':
      case 'END_TURN':
        return AiFinishReason.stop;
      case 'MAX_TOKENS':
      case 'LENGTH':
        return AiFinishReason.length;
      case 'SAFETY':
      case 'RECITATION':
      case 'CONTENT_FILTER':
        return AiFinishReason.contentFilter;
      case 'ERROR':
        return AiFinishReason.error;
      case null:
        return AiFinishReason.stop;
      default:
        return AiFinishReason.unknown;
    }
  }

  AiProviderHealthStatus _mapHealthStatus(AiTransportErrorKind kind) {
    return switch (kind) {
      AiTransportErrorKind.unauthorized => AiProviderHealthStatus.unauthorized,
      AiTransportErrorKind.configuration =>
        AiProviderHealthStatus.notConfigured,
      AiTransportErrorKind.timeout ||
      AiTransportErrorKind.network => AiProviderHealthStatus.unreachable,
      AiTransportErrorKind.rateLimited ||
      AiTransportErrorKind.badRequest ||
      AiTransportErrorKind.server ||
      AiTransportErrorKind.badResponse ||
      AiTransportErrorKind.contentBlocked ||
      AiTransportErrorKind.unknown => AiProviderHealthStatus.error,
    };
  }
}
