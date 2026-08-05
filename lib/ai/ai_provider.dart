import 'ai_models.dart';
import 'ai_provider_id.dart';

/// The single boundary between business logic and any AI vendor.
///
/// All AI-using code depends only on this interface — never on OpenAI,
/// Gemini, Anthropic, a Chinese vendor or a local endpoint directly. Swapping
/// or adding a vendor means providing another implementation; no caller
/// changes. In this phase implementations are local mock adapters
/// ([MockAiProvider]); real HTTP adapters slot in behind the same contract.
abstract interface class AiProvider {
  AiProviderId get id;
  String get displayName;
  AiProviderCapabilities get capabilities;

  /// Generates a completion for [request]. Implementations must not throw for
  /// expected provider errors; they encode them in the response/finish reason.
  Future<AiResponse> generate(AiRequest request);

  /// Cheap check of configuration/connectivity. Must never perform a billed
  /// generation and must never leak secrets.
  Future<AiProviderHealth> testConnection();
}
