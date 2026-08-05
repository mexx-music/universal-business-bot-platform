import 'ai_controller.dart';
import 'ai_provider_id.dart';
import 'ai_provider_registry.dart';
import 'ai_transport.dart';
import 'transports/edge_function_client.dart';

/// Vendor-neutral provider selection. Pure and testable: the `AI_PROVIDER`
/// flag is passed in (the composition root reads it from a non-secret
/// dart-define), so selection can be unit-tested without any build variable.
///
/// Rules:
/// - `gemini`            -> real GeminiProvider via [geminiTransport].
/// - `mock` / unset / other -> offline mock adapters (local dev & tests).
///
/// When `gemini` is selected but no [geminiTransport] is available (Supabase
/// not initialized), this throws [AiConfigurationException] — a clear
/// configuration error, never a silent downgrade to mock. Once Gemini is
/// active, a failing call surfaces as a real transport error; there is no
/// automatic switch to mock afterwards.
AiController buildAiController({
  required String providerFlag,
  AiTransport? geminiTransport,
}) {
  final flag = providerFlag.trim().toLowerCase();

  if (flag == 'gemini') {
    if (geminiTransport == null) {
      throw const AiConfigurationException(
        'AI_PROVIDER=gemini requires an initialized Supabase transport '
        '(SUPABASE_URL / SUPABASE_PUBLISHABLE_KEY). No mock fallback is used '
        'when Gemini is explicitly selected.',
      );
    }
    return AiController(
      AiProviderRegistry.gemini(geminiTransport),
      activeProviderId: AiProviderId.googleGemini,
    );
  }

  // Default: offline mock (flag empty, 'mock', or anything unrecognised).
  return AiController(AiProviderRegistry.mock());
}
