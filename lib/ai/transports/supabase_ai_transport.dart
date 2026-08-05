import 'dart:async';

import '../ai_transport.dart';
import 'edge_function_client.dart';

/// Real [AiTransport] that reaches Gemini exclusively through the `ai-generate`
/// Supabase Edge Function. The client never calls Google, never holds a key,
/// and never lets user input choose the function, headers or endpoint.
///
/// Errors are mapped from the function's machine-readable `error.code` (not
/// from the HTTP status alone). No prompts, responses or secrets are logged.
class SupabaseAiTransport implements AiTransport {
  SupabaseAiTransport(
    this._client, {
    Duration timeout = const Duration(seconds: 25),
    String functionName = 'ai-generate',
  }) : _timeout = timeout,
       _functionName = functionName;

  final EdgeFunctionClient _client;
  final Duration _timeout;
  final String _functionName;

  static const _provider = 'googleGemini';

  @override
  Future<AiTransportResponse> send(
    AiTransportRequest request, {
    Duration? timeout,
  }) async {
    // Canonical transport JSON. `metadata` is intentionally not forwarded —
    // the server ignores it and it must not influence the upstream call.
    final body = <String, Object?>{
      'provider': _provider,
      if (request.model != null) 'model': request.model,
      if (request.maxTokens != null) 'maxTokens': request.maxTokens,
      'action': 'generate',
      'messages': [
        for (final m in request.messages)
          {'role': m.role, 'content': m.content},
      ],
    };

    final response = await _invoke(body, timeout);
    final data = response.data;

    if (response.status == 200 && data != null) {
      return _mapSuccess(data, request);
    }
    throw _mapError(response);
  }

  @override
  Future<void> ping({Duration? timeout}) async {
    final response = await _invoke(const {
      'provider': _provider,
      'action': 'ping',
    }, timeout);
    if (response.status == 200) return;
    throw _mapError(response);
  }

  Future<EdgeFunctionResponse> _invoke(
    Map<String, Object?> body,
    Duration? timeout,
  ) async {
    try {
      return await _client
          .invoke(_functionName, body: body)
          .timeout(timeout ?? _timeout);
    } on TimeoutException {
      throw const AiTransportException(
        AiTransportErrorKind.timeout,
        'Edge function call timed out',
      );
    } on AiTransportException {
      rethrow;
    } catch (_) {
      // Pure network/SDK failure — no secret or detail is echoed.
      throw const AiTransportException(
        AiTransportErrorKind.network,
        'Edge function unreachable',
      );
    }
  }

  AiTransportResponse _mapSuccess(
    Map<String, Object?> data,
    AiTransportRequest request,
  ) {
    final text = data['text'];
    if (text is! String) {
      throw const AiTransportException(
        AiTransportErrorKind.badResponse,
        'Missing text in response',
      );
    }
    final model = data['model'] is String
        ? data['model'] as String
        : (request.model ?? '');
    final finishReason = data['finishReason'] is String
        ? data['finishReason'] as String
        : null;

    AiTransportUsage? usage;
    final rawUsage = data['usage'];
    if (rawUsage is Map) {
      usage = AiTransportUsage(
        promptTokens: _int(rawUsage['inputTokens']),
        completionTokens: _int(rawUsage['outputTokens']),
      );
    }

    return AiTransportResponse(
      text: text,
      model: model,
      finishReason: finishReason,
      usage: usage,
      raw: const {},
    );
  }

  /// Maps the function's machine-readable `error.code` to a transport error
  /// kind; falls back to the HTTP status only when no code is present.
  AiTransportException _mapError(EdgeFunctionResponse response) {
    final error = response.data?['error'];
    final code = error is Map && error['code'] is String
        ? error['code'] as String
        : null;
    final kind = _kindForCode(code) ?? _kindForStatus(response.status);
    // Deliberately generic message; never includes upstream detail/secrets.
    return AiTransportException(
      kind,
      'AI service error (${code ?? 'http_${response.status}'})',
      statusCode: response.status,
    );
  }

  AiTransportErrorKind? _kindForCode(String? code) {
    switch (code) {
      case 'invalid_request':
        return AiTransportErrorKind.badRequest;
      case 'unauthorized':
        return AiTransportErrorKind.unauthorized;
      case 'missing_server_configuration':
        return AiTransportErrorKind.configuration;
      case 'rate_limited':
        return AiTransportErrorKind.rateLimited;
      case 'upstream_timeout':
        return AiTransportErrorKind.timeout;
      case 'upstream_unavailable':
        return AiTransportErrorKind.network;
      case 'content_blocked':
        return AiTransportErrorKind.contentBlocked;
      case 'malformed_upstream_response':
        return AiTransportErrorKind.badResponse;
      case 'internal_error':
        return AiTransportErrorKind.server;
      default:
        return null;
    }
  }

  AiTransportErrorKind _kindForStatus(int status) {
    return switch (status) {
      400 => AiTransportErrorKind.badRequest,
      401 || 403 => AiTransportErrorKind.unauthorized,
      429 => AiTransportErrorKind.rateLimited,
      504 => AiTransportErrorKind.timeout,
      502 || 503 => AiTransportErrorKind.network,
      >= 500 => AiTransportErrorKind.server,
      _ => AiTransportErrorKind.unknown,
    };
  }

  int _int(Object? v) => v is num ? v.toInt() : 0;
}
