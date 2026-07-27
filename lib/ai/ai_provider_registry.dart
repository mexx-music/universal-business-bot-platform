import 'ai_provider.dart';
import 'ai_provider_config.dart';
import 'ai_provider_id.dart';
import 'providers/mock_ai_provider.dart';

/// Builds and holds one [AiProvider] per configured vendor.
///
/// The [adapterFactory] decides which concrete implementation backs a config;
/// it defaults to [MockAiProvider], so this phase is fully offline. A future
/// phase swaps in real HTTP adapters by passing a different factory — the
/// registry, controller and all callers stay unchanged.
class AiProviderRegistry {
  AiProviderRegistry({
    required List<AiProviderConfig> configs,
    AiProvider Function(AiProviderConfig config)? adapterFactory,
  }) : _configs = List.unmodifiable(configs),
       _adapterFactory = adapterFactory ?? MockAiProvider.new {
    for (final config in _configs) {
      _providers[config.id] = _adapterFactory(config);
    }
  }

  /// Default registry: the full catalogue backed by offline mock adapters.
  factory AiProviderRegistry.mock() {
    return AiProviderRegistry(configs: AiProviderCatalog.defaults());
  }

  final List<AiProviderConfig> _configs;
  final AiProvider Function(AiProviderConfig config) _adapterFactory;
  final Map<AiProviderId, AiProvider> _providers = {};

  List<AiProviderConfig> get configs => _configs;

  List<AiProvider> get providers => _providers.values.toList(growable: false);

  Iterable<AiProviderId> get providerIds => _providers.keys;

  AiProvider? byId(AiProviderId id) => _providers[id];

  AiProviderConfig? configFor(AiProviderId id) {
    for (final config in _configs) {
      if (config.id == id) return config;
    }
    return null;
  }

  List<AiProvider> byRegion(AiProviderRegion region) {
    return [
      for (final config in _configs)
        if (config.region == region) _providers[config.id]!,
    ];
  }
}
