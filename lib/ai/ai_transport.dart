import 'ai_provider_id.dart';

/// Vendor-neutral transport for server-side AI calls.
///
/// This is the boundary between an [AiProvider] adapter and the server that
/// actually holds the API key (a Supabase Edge Function). A provider NEVER
/// calls a vendor directly — it builds an [AiTransportRequest], hands it to an
/// [AiTransport], and maps the [AiTransportResponse] back. The concrete
/// transport (added in a later block) is the only place that performs I/O, so
/// no API key ever reaches the client, and the provider stays free of any
/// Google/HTTP/SDK dependency.
abstract interface class AiTransport {
  /// Sends a generation request. Implementations must throw
  /// [AiTransportException] for any failure (never return a partial/fake
  /// success), and should honour [timeout] when given.
  Future<AiTransportResponse> send(
    AiTransportRequest request, {
    Duration? timeout,
  });

  /// Lightweight reachability/config check. Must not perform a billed
  /// generation. Throws [AiTransportException] when unhealthy.
  Future<void> ping({Duration? timeout});
}

/// A transport-level message (role as a plain string, so the transport layer
/// carries no enum coupling to the neutral model types).
class AiTransportMessage {
  const AiTransportMessage({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, Object?> toJson() => {'role': role, 'content': content};
}

/// A transport-level request. The provider id and model are hints; the server
/// remains free to enforce the final model/policy.
class AiTransportRequest {
  const AiTransportRequest({
    required this.providerId,
    required this.messages,
    this.model,
    this.temperature,
    this.maxTokens,
    this.metadata = const {},
  });

  final AiProviderId providerId;
  final List<AiTransportMessage> messages;
  final String? model;
  final double? temperature;
  final int? maxTokens;
  final Map<String, String> metadata;

  Map<String, Object?> toJson() => {
    'provider': providerId.name,
    if (model != null) 'model': model,
    if (temperature != null) 'temperature': temperature,
    if (maxTokens != null) 'maxTokens': maxTokens,
    'messages': [for (final m in messages) m.toJson()],
    if (metadata.isNotEmpty) 'metadata': metadata,
  };
}

class AiTransportUsage {
  const AiTransportUsage({this.promptTokens = 0, this.completionTokens = 0});

  final int promptTokens;
  final int completionTokens;
}

class AiTransportResponse {
  const AiTransportResponse({
    required this.text,
    required this.model,
    this.finishReason,
    this.usage,
    this.raw = const {},
  });

  final String text;
  final String model;

  /// Provider-native finish reason string (e.g. 'STOP', 'MAX_TOKENS',
  /// 'SAFETY'); mapped to the neutral enum by the provider.
  final String? finishReason;
  final AiTransportUsage? usage;
  final Map<String, Object?> raw;
}

/// Why a transport call failed. Providers map these to health/exception state.
enum AiTransportErrorKind {
  timeout,
  network,
  unauthorized,
  rateLimited,
  badRequest,
  server,
  badResponse,
  unknown,
}

/// The single error type a transport raises. Explicit and typed so providers
/// can react precisely and never need to guess or silently recover.
class AiTransportException implements Exception {
  const AiTransportException(this.kind, this.message, {this.statusCode});

  final AiTransportErrorKind kind;
  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'AiTransportException(${kind.name}${statusCode == null ? '' : ' $statusCode'}): $message';
}
