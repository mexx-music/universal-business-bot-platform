import 'ai_models.dart';
import 'ai_provider_id.dart';

/// Non-secret configuration for one provider.
///
/// Security: this type never stores a real API key in source. [apiKeyEnvVar]
/// only names the environment variable a real key would be read from at
/// runtime; [apiKey] is a transient, in-memory field that defaults to empty
/// and must be populated from secure runtime input, never hardcoded.
class AiProviderConfig {
  const AiProviderConfig({
    required this.id,
    required this.displayName,
    required this.region,
    required this.defaultModel,
    required this.capabilities,
    this.baseUrl,
    this.apiKeyEnvVar,
    this.requiresApiKey = true,
    this.apiKey = '',
    this.enabled = true,
  });

  final AiProviderId id;
  final String displayName;
  final AiProviderRegion region;

  /// Default model name used when a request omits `model`.
  final String defaultModel;

  final AiProviderCapabilities capabilities;

  /// Public API base URL / endpoint (or a local URL for self-hosted).
  final String? baseUrl;

  /// Name of the env var holding the key at runtime — NOT the key itself.
  final String? apiKeyEnvVar;

  /// Whether this provider needs an API key (false for most local runtimes).
  final bool requiresApiKey;

  /// Transient key value (empty by default; never a hardcoded secret).
  final String apiKey;

  final bool enabled;

  /// Configured enough to attempt a call: enabled, and either no key required
  /// (local) or a key present.
  bool get isConfigured => enabled && (!requiresApiKey || apiKey.isNotEmpty);

  AiProviderConfig copyWith({
    String? baseUrl,
    String? apiKey,
    String? defaultModel,
    bool? enabled,
  }) {
    return AiProviderConfig(
      id: id,
      displayName: displayName,
      region: region,
      defaultModel: defaultModel ?? this.defaultModel,
      capabilities: capabilities,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKeyEnvVar: apiKeyEnvVar,
      requiresApiKey: requiresApiKey,
      apiKey: apiKey ?? this.apiKey,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// The default, secret-free catalogue of every supported provider. Endpoints
/// are public defaults; keys are absent by design.
class AiProviderCatalog {
  const AiProviderCatalog._();

  static const _cloudCaps = AiProviderCapabilities(
    chat: true,
    streaming: true,
    tools: true,
    jsonMode: true,
    maxContextTokens: 128000,
  );

  static const _localCaps = AiProviderCapabilities(chat: true, streaming: true);

  /// A config for every [AiProviderId]. Completeness is guarded by tests.
  static List<AiProviderConfig> defaults() => const [
    // Western
    AiProviderConfig(
      id: AiProviderId.openAi,
      displayName: 'OpenAI',
      region: AiProviderRegion.western,
      defaultModel: 'gpt-4o-mini',
      capabilities: _cloudCaps,
      baseUrl: 'https://api.openai.com/v1',
      apiKeyEnvVar: 'OPENAI_API_KEY',
    ),
    AiProviderConfig(
      id: AiProviderId.googleGemini,
      displayName: 'Google Gemini',
      region: AiProviderRegion.western,
      defaultModel: 'gemini-1.5-flash',
      capabilities: _cloudCaps,
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
      apiKeyEnvVar: 'GEMINI_API_KEY',
    ),
    AiProviderConfig(
      id: AiProviderId.anthropicClaude,
      displayName: 'Anthropic Claude',
      region: AiProviderRegion.western,
      defaultModel: 'claude-3-5-sonnet',
      capabilities: _cloudCaps,
      baseUrl: 'https://api.anthropic.com/v1',
      apiKeyEnvVar: 'ANTHROPIC_API_KEY',
    ),
    AiProviderConfig(
      id: AiProviderId.xaiGrok,
      displayName: 'xAI Grok',
      region: AiProviderRegion.western,
      defaultModel: 'grok-beta',
      capabilities: _cloudCaps,
      baseUrl: 'https://api.x.ai/v1',
      apiKeyEnvVar: 'XAI_API_KEY',
    ),
    // Chinese
    AiProviderConfig(
      id: AiProviderId.deepSeek,
      displayName: 'DeepSeek',
      region: AiProviderRegion.chinese,
      defaultModel: 'deepseek-chat',
      capabilities: _cloudCaps,
      baseUrl: 'https://api.deepseek.com/v1',
      apiKeyEnvVar: 'DEEPSEEK_API_KEY',
    ),
    AiProviderConfig(
      id: AiProviderId.alibabaQwen,
      displayName: 'Alibaba Qwen',
      region: AiProviderRegion.chinese,
      defaultModel: 'qwen-plus',
      capabilities: _cloudCaps,
      baseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
      apiKeyEnvVar: 'QWEN_API_KEY',
    ),
    AiProviderConfig(
      id: AiProviderId.zhipuGlm,
      displayName: 'Zhipu GLM',
      region: AiProviderRegion.chinese,
      defaultModel: 'glm-4',
      capabilities: _cloudCaps,
      baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
      apiKeyEnvVar: 'ZHIPU_API_KEY',
    ),
    AiProviderConfig(
      id: AiProviderId.moonshotKimi,
      displayName: 'Moonshot AI / Kimi',
      region: AiProviderRegion.chinese,
      defaultModel: 'moonshot-v1-8k',
      capabilities: _cloudCaps,
      baseUrl: 'https://api.moonshot.cn/v1',
      apiKeyEnvVar: 'MOONSHOT_API_KEY',
    ),
    // Local / self-hosted (no key by default)
    AiProviderConfig(
      id: AiProviderId.ollama,
      displayName: 'Ollama (lokal)',
      region: AiProviderRegion.local,
      defaultModel: 'llama3.1',
      capabilities: _localCaps,
      baseUrl: 'http://localhost:11434',
      requiresApiKey: false,
    ),
    AiProviderConfig(
      id: AiProviderId.openAiCompatibleLocal,
      displayName: 'OpenAI-kompatibel (lokal)',
      region: AiProviderRegion.local,
      defaultModel: 'local-model',
      capabilities: _localCaps,
      baseUrl: 'http://localhost:8000/v1',
      requiresApiKey: false,
    ),
    AiProviderConfig(
      id: AiProviderId.customOpenAiCompatible,
      displayName: 'Benutzerdefinierter Endpoint',
      region: AiProviderRegion.local,
      defaultModel: 'custom-model',
      capabilities: _localCaps,
      baseUrl: null,
      requiresApiKey: false,
    ),
  ];
}
