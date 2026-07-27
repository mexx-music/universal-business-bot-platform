import '../ai_models.dart';
import '../ai_provider.dart';
import '../ai_provider_config.dart';
import '../ai_provider_id.dart';

/// Deterministic, offline [AiProvider] used for this architecture phase.
///
/// Makes NO network calls and needs NO API key: [generate] returns a canned,
/// reproducible response derived from the request, and [testConnection]
/// reports health purely from the config. Real HTTP adapters will implement
/// the same [AiProvider] interface and can replace this without touching any
/// caller.
class MockAiProvider implements AiProvider {
  const MockAiProvider(this.config);

  final AiProviderConfig config;

  @override
  AiProviderId get id => config.id;

  @override
  String get displayName => config.displayName;

  @override
  AiProviderCapabilities get capabilities => config.capabilities;

  @override
  Future<AiResponse> generate(AiRequest request) async {
    final model = request.model ?? config.defaultModel;
    final lastUser = request.messages.lastWhere(
      (m) => m.role == AiMessageRole.user,
      orElse: () => request.messages.isEmpty
          ? const AiMessage.user('')
          : request.messages.last,
    );
    final text =
        '[mock:${config.id.name}] $displayName would answer '
        '"${lastUser.content}" using $model.';
    return AiResponse(
      text: text,
      providerId: id,
      model: model,
      finishReason: AiFinishReason.stop,
      usage: AiUsage(
        promptTokens: _estimateTokens(request),
        completionTokens: (text.length / 4).ceil(),
      ),
      raw: const {'mock': true},
    );
  }

  @override
  Future<AiProviderHealth> testConnection() async {
    if (!config.enabled) {
      return AiProviderHealth(
        status: AiProviderHealthStatus.notConfigured,
        message: 'Provider disabled',
        checkedAt: DateTime.now(),
      );
    }
    if (config.requiresApiKey && config.apiKey.isEmpty) {
      return AiProviderHealth(
        status: AiProviderHealthStatus.notConfigured,
        message: 'No API key configured (set ${config.apiKeyEnvVar})',
        checkedAt: DateTime.now(),
      );
    }
    return AiProviderHealth(
      status: AiProviderHealthStatus.healthy,
      message: 'Mock provider reachable',
      checkedAt: DateTime.now(),
    );
  }

  int _estimateTokens(AiRequest request) {
    final chars = request.messages.fold<int>(
      0,
      (sum, m) => sum + m.content.length,
    );
    return (chars / 4).ceil();
  }
}
