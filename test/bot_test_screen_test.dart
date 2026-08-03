import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_controller.dart';
import 'package:universalbusiness/ai/ai_models.dart';
import 'package:universalbusiness/ai/ai_provider.dart';
import 'package:universalbusiness/ai/ai_provider_config.dart';
import 'package:universalbusiness/ai/ai_provider_id.dart';
import 'package:universalbusiness/ai/ai_provider_registry.dart';
import 'package:universalbusiness/ai/grounded_answer_service.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';
import 'package:universalbusiness/screens/bot_test/bot_test_screen.dart';
import 'package:universalbusiness/screens/bot_test/grounded_answer_panel.dart';

class _LanguageAwareProvider implements AiProvider {
  final List<AiRequest> requests = [];

  @override
  AiProviderId get id => AiProviderId.googleGemini;

  @override
  String get displayName => 'Test Gemini';

  @override
  AiProviderCapabilities get capabilities => const AiProviderCapabilities();

  @override
  Future<AiResponse> generate(AiRequest request) async {
    requests.add(request);
    final language = request.metadata['answer_language'];
    return AiResponse(
      text: language == 'de'
          ? 'Die App verbindet sich automatisch über Bluetooth.'
          : 'The app connects automatically through Bluetooth.',
      providerId: id,
      model: 'test-gemini',
    );
  }

  @override
  Future<AiProviderHealth> testConnection() async =>
      const AiProviderHealth.healthy();
}

class _CapturingGroundedService extends GroundedAnswerService {
  _CapturingGroundedService({required super.aiController});

  final List<GroundedAnswerRequest> requests = [];

  @override
  Future<GroundedAnswerResult> answer(GroundedAnswerRequest request) {
    requests.add(request);
    return super.answer(request);
  }
}

AiController _controller(_LanguageAwareProvider provider) {
  final config = AiProviderCatalog.defaults().firstWhere(
    (candidate) => candidate.id == AiProviderId.googleGemini,
  );
  return AiController(
    AiProviderRegistry(configs: [config], adapterFactory: (_) => provider),
    activeProviderId: AiProviderId.googleGemini,
  );
}

Future<AppState> _stateWithConfirmedKnowledge() async {
  final state = AppState();
  await state.addKnowledgeEntries([
    KnowledgeEntry(
      id: 'confirmed-de',
      title: 'Bestätigte Bluetooth-Verbindung',
      content: 'Die App verbindet sich automatisch über Bluetooth.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: const ['app', 'bluetooth', 'verbindet'],
      source: KnowledgeEntrySources.knowledgeBuilder,
      createdAt: DateTime.utc(2026, 8, 3),
      languageCode: 'de',
      knowledgeArea: 'hb_cure_app',
    ),
    KnowledgeEntry(
      id: 'confirmed-en',
      title: 'Confirmed Bluetooth connection',
      content: 'The app connects automatically through Bluetooth.',
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: const ['app', 'bluetooth', 'connects'],
      source: KnowledgeEntrySources.knowledgeBuilder,
      createdAt: DateTime.utc(2026, 8, 3),
      languageCode: 'en',
      knowledgeArea: 'hb_cure_app',
    ),
  ]);
  return state;
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required AppState state,
  required GroundedAnswerService service,
  Locale locale = const Locale('de'),
  Size size = const Size(1000, 1000),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: AppStateScope(
        notifier: state,
        child: BotTestScreen(serviceOverride: service),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _ask(WidgetTester tester, String question) async {
  await tester.enterText(
    find.byKey(const Key('grounded-question-field')),
    question,
  );
  await tester.pump();
  await tester.tap(find.byIcon(Icons.send));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'shows one grounded system with no legacy chat or duplicate input',
    (tester) async {
      final state = await _stateWithConfirmedKnowledge();
      final provider = _LanguageAwareProvider();
      final service = _CapturingGroundedService(
        aiController: _controller(provider),
      );
      await _pumpScreen(tester, state: state, service: service);
      final l = AppLocalizations.of(
        tester.element(find.byType(BotTestScreen)),
      )!;

      expect(find.byType(GroundedAnswerPanel), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.text(l.botTestGreeting), findsNothing);
      expect(find.text(l.botTestInputHint), findsNothing);
      expect(find.text(l.btnReset), findsNothing);

      await _ask(tester, 'Wie verbindet sich die App über Bluetooth?');
      expect(service.requests, hasLength(1));
      expect(provider.requests, hasLength(1));
    },
  );

  testWidgets('German and English questions share language-aware RAG', (
    tester,
  ) async {
    final state = await _stateWithConfirmedKnowledge();
    final provider = _LanguageAwareProvider();
    final service = _CapturingGroundedService(
      aiController: _controller(provider),
    );
    await _pumpScreen(tester, state: state, service: service);

    await _ask(tester, 'Wie verbindet sich die App über Bluetooth?');
    expect(
      find.text('Die App verbindet sich automatisch über Bluetooth.'),
      findsWidgets,
    );
    expect(find.text('Bestätigte Bluetooth-Verbindung'), findsOneWidget);
    expect(find.text('Confirmed Bluetooth connection'), findsNothing);
    expect(provider.requests.last.metadata['answer_language'], 'de');
    expect(
      provider.requests.last.messages.last.content,
      isNot(contains('The app connects automatically')),
    );

    await _ask(tester, 'How does the app connect through Bluetooth?');
    expect(
      find.text('The app connects automatically through Bluetooth.'),
      findsWidgets,
    );
    expect(find.text('Confirmed Bluetooth connection'), findsOneWidget);
    expect(find.text('Bestätigte Bluetooth-Verbindung'), findsNothing);
    expect(provider.requests.last.metadata['answer_language'], 'en');
    expect(
      provider.requests.last.messages.last.content,
      isNot(contains('Die App verbindet sich automatisch')),
    );
  });

  testWidgets('confirmed workspace replaces seed knowledge and binds sources', (
    tester,
  ) async {
    final state = await _stateWithConfirmedKnowledge();
    final seedIds = state.knowledgeEntries
        .where(
          (entry) => entry.source != KnowledgeEntrySources.knowledgeBuilder,
        )
        .map((entry) => entry.id)
        .toSet();
    final provider = _LanguageAwareProvider();
    final service = _CapturingGroundedService(
      aiController: _controller(provider),
    );
    await _pumpScreen(tester, state: state, service: service);

    await _ask(tester, 'Wie verbindet sich die App über Bluetooth?');

    final workspaceEntries = service.requests.single.workspace.knowledgeEntries;
    expect(workspaceEntries.map((entry) => entry.id).toSet(), {
      'confirmed-de',
      'confirmed-en',
    });
    expect(
      workspaceEntries.any((entry) => seedIds.contains(entry.id)),
      isFalse,
    );
    final prompt = provider.requests.single.messages.last.content;
    expect(prompt, contains('Bestätigte Bluetooth-Verbindung'));
    expect(prompt, isNot(contains('Confirmed Bluetooth connection')));
    expect(find.text('Bestätigte Bluetooth-Verbindung'), findsOneWidget);
  });

  testWidgets('knowledge gap uses the same honest grounded state', (
    tester,
  ) async {
    final state = await _stateWithConfirmedKnowledge();
    final provider = _LanguageAwareProvider();
    final service = _CapturingGroundedService(
      aiController: _controller(provider),
    );
    await _pumpScreen(tester, state: state, service: service);
    final l = AppLocalizations.of(tester.element(find.byType(BotTestScreen)))!;

    await _ask(tester, 'Wie hoch ist die Raketenreichweite?');

    expect(find.text(l.botDemoGapTitle), findsOneWidget);
    expect(find.text(l.botDemoNoKnowledge), findsOneWidget);
    expect(find.text(l.botDemoSources), findsNothing);
    expect(provider.requests, isEmpty);
  });

  testWidgets('single grounded page has no overflow on mobile and desktop', (
    tester,
  ) async {
    final mobileState = await _stateWithConfirmedKnowledge();
    final mobileProvider = _LanguageAwareProvider();
    await _pumpScreen(
      tester,
      state: mobileState,
      service: _CapturingGroundedService(
        aiController: _controller(mobileProvider),
      ),
      size: const Size(360, 800),
    );
    await _ask(tester, 'Wie verbindet sich die App über Bluetooth?');
    expect(tester.takeException(), isNull);

    final desktopState = await _stateWithConfirmedKnowledge();
    final desktopProvider = _LanguageAwareProvider();
    await _pumpScreen(
      tester,
      state: desktopState,
      service: _CapturingGroundedService(
        aiController: _controller(desktopProvider),
      ),
      size: const Size(1440, 1000),
    );
    await _ask(tester, 'How does the app connect through Bluetooth?');
    expect(tester.takeException(), isNull);
  });
}
