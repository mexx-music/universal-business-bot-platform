import 'package:flutter/widgets.dart';

import 'ai_models.dart';
import 'ai_provider.dart';
import 'ai_provider_id.dart';
import 'ai_provider_registry.dart';

/// The single entry point business logic uses to reach AI models.
///
/// Callers never touch a vendor SDK or the [AiProviderRegistry] directly —
/// they hold an [AiController], read the active provider, and call [generate].
/// Switching vendors is a [selectProvider] call; the interface is identical
/// for OpenAI, a Chinese vendor or a local Ollama endpoint.
class AiController extends ChangeNotifier {
  AiController(this.registry, {AiProviderId? activeProviderId})
    : _activeProviderId =
          activeProviderId ??
          (registry.providerIds.isNotEmpty
              ? registry.providerIds.first
              : AiProviderId.openAi);

  final AiProviderRegistry registry;
  AiProviderId _activeProviderId;

  AiProviderId get activeProviderId => _activeProviderId;

  AiProvider? get activeProvider => registry.byId(_activeProviderId);

  List<AiProvider> get providers => registry.providers;

  void selectProvider(AiProviderId id) {
    if (_activeProviderId == id) return;
    if (registry.byId(id) == null) return;
    _activeProviderId = id;
    notifyListeners();
  }

  /// Generates via the active provider. Throws [StateError] only if no
  /// provider is registered at all (a programming error).
  Future<AiResponse> generate(AiRequest request) {
    final provider = activeProvider;
    if (provider == null) {
      throw StateError('No active AI provider registered');
    }
    return provider.generate(request);
  }

  Future<AiProviderHealth> testActiveConnection() {
    final provider = activeProvider;
    if (provider == null) {
      throw StateError('No active AI provider registered');
    }
    return provider.testConnection();
  }

  static AiController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AiScope>()!.notifier!;
  }
}

class AiScope extends InheritedNotifier<AiController> {
  const AiScope({super.key, required super.notifier, required super.child});
}
