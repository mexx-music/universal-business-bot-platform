import 'package:universalbusiness/ai/ai_controller.dart';
import 'package:universalbusiness/ai/ai_models.dart';
import 'package:universalbusiness/ai/ai_provider.dart';
import 'package:universalbusiness/ai/ai_provider_config.dart';
import 'package:universalbusiness/ai/ai_provider_id.dart';
import 'package:universalbusiness/ai/ai_provider_registry.dart';

class ScriptedGeminiProvider implements AiProvider {
  ScriptedGeminiProvider({this.responseText = '{}', this.error});

  final String responseText;
  final Object? error;
  final List<AiRequest> requests = [];

  int get calls => requests.length;

  @override
  AiProviderId get id => AiProviderId.googleGemini;

  @override
  String get displayName => 'Google Gemini';

  @override
  AiProviderCapabilities get capabilities => const AiProviderCapabilities();

  @override
  Future<AiResponse> generate(AiRequest request) async {
    requests.add(request);
    if (error case final error?) throw error;
    return AiResponse(text: responseText, providerId: id, model: 'gemini-test');
  }

  @override
  Future<AiProviderHealth> testConnection() async =>
      const AiProviderHealth.healthy();
}

AiController controllerWithScriptedGemini(ScriptedGeminiProvider provider) {
  final config = AiProviderCatalog.defaults().firstWhere(
    (candidate) => candidate.id == AiProviderId.googleGemini,
  );
  return AiController(
    AiProviderRegistry(configs: [config], adapterFactory: (_) => provider),
    activeProviderId: AiProviderId.googleGemini,
  );
}
