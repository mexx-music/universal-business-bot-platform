import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_controller.dart';
import 'package:universalbusiness/ai/ai_models.dart';
import 'package:universalbusiness/ai/ai_provider_config.dart';
import 'package:universalbusiness/ai/ai_provider_id.dart';
import 'package:universalbusiness/ai/ai_provider_registry.dart';
import 'package:universalbusiness/ai/providers/mock_ai_provider.dart';

void main() {
  group('Provider identity and regions', () {
    test('all required vendors are declared', () {
      expect(AiProviderId.values, hasLength(11));
      // Western
      expect(
        AiProviderId.values,
        containsAll([
          AiProviderId.openAi,
          AiProviderId.googleGemini,
          AiProviderId.anthropicClaude,
          AiProviderId.xaiGrok,
        ]),
      );
      // Chinese
      expect(
        AiProviderId.values,
        containsAll([
          AiProviderId.deepSeek,
          AiProviderId.alibabaQwen,
          AiProviderId.zhipuGlm,
          AiProviderId.moonshotKimi,
        ]),
      );
      // Local
      expect(
        AiProviderId.values,
        containsAll([
          AiProviderId.ollama,
          AiProviderId.openAiCompatibleLocal,
          AiProviderId.customOpenAiCompatible,
        ]),
      );
    });

    test('region partitioning is 4 western / 4 chinese / 3 local', () {
      int count(AiProviderRegion r) =>
          AiProviderId.values.where((id) => id.region == r).length;
      expect(count(AiProviderRegion.western), 4);
      expect(count(AiProviderRegion.chinese), 4);
      expect(count(AiProviderRegion.local), 3);
    });
  });

  group('Config catalogue', () {
    final configs = AiProviderCatalog.defaults();

    test('has exactly one config per provider id', () {
      final ids = configs.map((c) => c.id).toSet();
      expect(ids, AiProviderId.values.toSet());
      expect(configs, hasLength(AiProviderId.values.length));
    });

    test('contains no secrets and no hardcoded api keys', () {
      for (final c in configs) {
        expect(c.apiKey, isEmpty, reason: '${c.id} must ship without a key');
        // Env var names are references, never key material.
        if (c.apiKeyEnvVar != null) {
          expect(c.apiKeyEnvVar, endsWith('_API_KEY'));
        }
      }
    });

    test('local providers need no key; cloud providers do', () {
      for (final c in configs) {
        if (c.region == AiProviderRegion.local) {
          expect(c.requiresApiKey, isFalse, reason: '${c.id}');
        } else {
          expect(c.requiresApiKey, isTrue, reason: '${c.id}');
        }
      }
    });
  });

  group('Registry (offline mock adapters)', () {
    test('builds one provider per config, all mock', () {
      final registry = AiProviderRegistry.mock();
      expect(registry.providers, hasLength(AiProviderId.values.length));
      for (final id in AiProviderId.values) {
        expect(registry.byId(id), isA<MockAiProvider>());
      }
    });

    test('byRegion groups correctly', () {
      final registry = AiProviderRegistry.mock();
      expect(registry.byRegion(AiProviderRegion.western), hasLength(4));
      expect(registry.byRegion(AiProviderRegion.chinese), hasLength(4));
      expect(registry.byRegion(AiProviderRegion.local), hasLength(3));
    });
  });

  group('MockAiProvider', () {
    test('generate is deterministic, offline and vendor-tagged', () async {
      final provider = MockAiProvider(
        AiProviderCatalog.defaults().firstWhere(
          (c) => c.id == AiProviderId.deepSeek,
        ),
      );
      final request = AiRequest.prompt('Hallo', system: 'Sei knapp.');
      final a = await provider.generate(request);
      final b = await provider.generate(request);

      expect(a.text, b.text); // deterministic
      expect(a.providerId, AiProviderId.deepSeek);
      expect(a.text, contains('mock:deepSeek'));
      expect(a.text, contains('Hallo'));
      expect(a.model, 'deepseek-chat');
      expect(a.finishReason, AiFinishReason.stop);
      expect(a.usage, isNotNull);
      expect(a.usage!.totalTokens, greaterThan(0));
    });

    test('request model overrides the default', () async {
      final provider = MockAiProvider(
        AiProviderCatalog.defaults().firstWhere(
          (c) => c.id == AiProviderId.openAi,
        ),
      );
      final response = await provider.generate(
        const AiRequest(messages: [AiMessage.user('hi')], model: 'gpt-4o'),
      );
      expect(response.model, 'gpt-4o');
    });

    test('testConnection: local healthy, cloud without key not configured, '
        'cloud with key healthy', () async {
      final ollama = MockAiProvider(
        AiProviderCatalog.defaults().firstWhere(
          (c) => c.id == AiProviderId.ollama,
        ),
      );
      expect(
        (await ollama.testConnection()).status,
        AiProviderHealthStatus.healthy,
      );

      final openAiNoKey = MockAiProvider(
        AiProviderCatalog.defaults().firstWhere(
          (c) => c.id == AiProviderId.openAi,
        ),
      );
      expect(
        (await openAiNoKey.testConnection()).status,
        AiProviderHealthStatus.notConfigured,
      );

      // Dummy in-memory key (not a real secret) exercises the healthy path.
      final openAiWithKey = MockAiProvider(
        AiProviderCatalog.defaults()
            .firstWhere((c) => c.id == AiProviderId.openAi)
            .copyWith(apiKey: 'test-dummy'),
      );
      expect(
        (await openAiWithKey.testConnection()).status,
        AiProviderHealthStatus.healthy,
      );
    });
  });

  group('AiController', () {
    test('defaults to the first provider and delegates generate', () async {
      final controller = AiController(AiProviderRegistry.mock());
      expect(controller.activeProviderId, AiProviderId.openAi);

      final response = await controller.generate(AiRequest.prompt('x'));
      expect(response.providerId, AiProviderId.openAi);
    });

    test('selectProvider switches the active vendor and notifies', () async {
      final controller = AiController(AiProviderRegistry.mock());
      var notified = 0;
      controller.addListener(() => notified++);

      controller.selectProvider(AiProviderId.alibabaQwen);
      expect(controller.activeProviderId, AiProviderId.alibabaQwen);
      expect(notified, 1);

      // Selecting the same again does not notify.
      controller.selectProvider(AiProviderId.alibabaQwen);
      expect(notified, 1);

      final response = await controller.generate(AiRequest.prompt('x'));
      expect(response.providerId, AiProviderId.alibabaQwen);
      expect(response.text, contains('mock:alibabaQwen'));
    });

    test(
      'business logic stays vendor-neutral: same request, any provider',
      () async {
        final controller = AiController(AiProviderRegistry.mock());
        const request = AiRequest(messages: [AiMessage.user('same input')]);
        final results = <AiProviderId, String>{};
        for (final id in AiProviderId.values) {
          controller.selectProvider(id);
          results[id] = (await controller.generate(request)).text;
        }
        // Every provider answered; each response is tagged with its own vendor.
        expect(results.length, AiProviderId.values.length);
        for (final id in AiProviderId.values) {
          expect(results[id], contains('mock:${id.name}'));
        }
      },
    );
  });
}
