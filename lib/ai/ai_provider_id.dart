/// Stable identity of every AI provider the platform is prepared to talk to.
///
/// The platform must never be technically bound to a single vendor: all
/// business logic goes through the [AiProvider] interface, and providers are
/// identified only by this enum. Adding a provider means adding an id + a
/// config + an adapter — no business logic changes.
enum AiProviderId {
  // Western
  openAi,
  googleGemini,
  anthropicClaude,
  xaiGrok,
  // Chinese
  deepSeek,
  alibabaQwen,
  zhipuGlm,
  moonshotKimi,
  // Local / self-hosted
  ollama,
  openAiCompatibleLocal,
  customOpenAiCompatible,
}

/// Where a provider runs — used for grouping and for defaults (local
/// providers usually need no API key).
enum AiProviderRegion { western, chinese, local }

extension AiProviderIdX on AiProviderId {
  AiProviderRegion get region => switch (this) {
    AiProviderId.openAi ||
    AiProviderId.googleGemini ||
    AiProviderId.anthropicClaude ||
    AiProviderId.xaiGrok => AiProviderRegion.western,
    AiProviderId.deepSeek ||
    AiProviderId.alibabaQwen ||
    AiProviderId.zhipuGlm ||
    AiProviderId.moonshotKimi => AiProviderRegion.chinese,
    AiProviderId.ollama ||
    AiProviderId.openAiCompatibleLocal ||
    AiProviderId.customOpenAiCompatible => AiProviderRegion.local,
  };

  /// Human-readable default name (proper nouns — not localized).
  String get defaultDisplayName => switch (this) {
    AiProviderId.openAi => 'OpenAI',
    AiProviderId.googleGemini => 'Google Gemini',
    AiProviderId.anthropicClaude => 'Anthropic Claude',
    AiProviderId.xaiGrok => 'xAI Grok',
    AiProviderId.deepSeek => 'DeepSeek',
    AiProviderId.alibabaQwen => 'Alibaba Qwen',
    AiProviderId.zhipuGlm => 'Zhipu GLM',
    AiProviderId.moonshotKimi => 'Moonshot AI / Kimi',
    AiProviderId.ollama => 'Ollama (lokal)',
    AiProviderId.openAiCompatibleLocal => 'OpenAI-kompatibel (lokal)',
    AiProviderId.customOpenAiCompatible => 'Benutzerdefinierter Endpoint',
  };

  bool get isLocal => region == AiProviderRegion.local;
}
