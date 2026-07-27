import 'ai_provider_id.dart';

/// Vendor-neutral request/response value types. Deliberately minimal and
/// provider-agnostic: adapters map these to/from each vendor's wire format.

enum AiMessageRole { system, user, assistant, tool }

class AiMessage {
  const AiMessage(this.role, this.content);

  const AiMessage.system(String content) : this(AiMessageRole.system, content);
  const AiMessage.user(String content) : this(AiMessageRole.user, content);
  const AiMessage.assistant(String content)
    : this(AiMessageRole.assistant, content);

  final AiMessageRole role;
  final String content;
}

/// A single generation request. `model` and sampling params are optional; when
/// null the adapter falls back to the provider config's defaults.
class AiRequest {
  const AiRequest({
    required this.messages,
    this.model,
    this.temperature,
    this.maxTokens,
    this.metadata = const {},
  });

  /// Convenience for a one-shot prompt with an optional system instruction.
  factory AiRequest.prompt(String prompt, {String? system}) {
    return AiRequest(
      messages: [
        if (system != null) AiMessage.system(system),
        AiMessage.user(prompt),
      ],
    );
  }

  final List<AiMessage> messages;
  final String? model;
  final double? temperature;
  final int? maxTokens;

  /// Free-form, non-secret metadata (e.g. workspace id) for logging/routing.
  final Map<String, String> metadata;
}

enum AiFinishReason { stop, length, contentFilter, error, unknown }

class AiUsage {
  const AiUsage({this.promptTokens = 0, this.completionTokens = 0});

  final int promptTokens;
  final int completionTokens;

  int get totalTokens => promptTokens + completionTokens;
}

/// A vendor-neutral generation result.
class AiResponse {
  const AiResponse({
    required this.text,
    required this.providerId,
    required this.model,
    this.finishReason = AiFinishReason.stop,
    this.usage,
    this.raw = const {},
  });

  final String text;
  final AiProviderId providerId;
  final String model;
  final AiFinishReason finishReason;
  final AiUsage? usage;

  /// Provider-specific extras, kept opaque so business logic stays neutral.
  final Map<String, Object?> raw;
}

/// What a provider can do — lets business logic degrade gracefully instead of
/// assuming every vendor supports every feature.
class AiProviderCapabilities {
  const AiProviderCapabilities({
    this.chat = true,
    this.streaming = false,
    this.tools = false,
    this.jsonMode = false,
    this.embeddings = false,
    this.vision = false,
    this.maxContextTokens,
  });

  final bool chat;
  final bool streaming;
  final bool tools;
  final bool jsonMode;
  final bool embeddings;
  final bool vision;
  final int? maxContextTokens;
}

enum AiProviderHealthStatus {
  unknown,
  healthy,
  notConfigured,
  unauthorized,
  unreachable,
  error,
}

/// Result of a lightweight connectivity/config check.
class AiProviderHealth {
  const AiProviderHealth({required this.status, this.message, this.checkedAt});

  const AiProviderHealth.healthy({String? message})
    : this(status: AiProviderHealthStatus.healthy, message: message);

  const AiProviderHealth.notConfigured({String? message})
    : this(status: AiProviderHealthStatus.notConfigured, message: message);

  final AiProviderHealthStatus status;
  final String? message;
  final DateTime? checkedAt;

  bool get isHealthy => status == AiProviderHealthStatus.healthy;
}
