import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:universalbusiness/ai/ai_controller.dart';
import 'package:universalbusiness/ai/ai_provider_registry.dart';
import 'package:universalbusiness/ai/ai_transport.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/knowledge_builder/knowledge_import_analyzer.dart';
import 'package:universalbusiness/knowledge_builder/models/knowledge_import_models.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';
import 'package:universalbusiness/models/company_workspace.dart';
import 'package:universalbusiness/screens/knowledge_builder/knowledge_builder_screen.dart';

import 'support/scripted_gemini_provider.dart';

/// Returns a scripted analysis regardless of input — for deterministic UI tests.
class _FakeAnalyzer extends KnowledgeImportAnalyzer {
  const _FakeAnalyzer(this.result);
  final KnowledgeImportAnalysis result;

  @override
  KnowledgeImportAnalysis analyze(
    String rawText, {
    List<KnowledgeEntry> existingEntries = const [],
    CompanyWorkspace? workspace,
  }) => result;
}

const _scripted = KnowledgeImportAnalysis(
  analyzedSentences: 5,
  unclearStatements: 1,
  inputLanguageCode: 'de',
  knowledgeArea: 'hb_cure_app',
  detectedTopicLabels: ['Bluetooth', 'App', 'Android'],
  drafts: [
    KnowledgeImportDraft(
      id: 'd1',
      category: KnowledgeDraftCategory.faq,
      title: 'Muss Bluetooth aktiviert sein?',
      content: 'Bluetooth muss aktiviert sein',
      sourceSentence: 'Bluetooth muss aktiviert sein',
      question: 'Muss Bluetooth aktiviert sein?',
      keywords: ['bluetooth'],
      languageCode: 'de',
      knowledgeArea: 'hb_cure_app',
      detectedTopics: ['Bluetooth', 'App'],
    ),
    KnowledgeImportDraft(
      id: 'd2',
      category: KnowledgeDraftCategory.technicalRequirement,
      title: 'Android Version',
      content: 'Die App benötigt mindestens Android 9',
      sourceSentence: 'Die App benötigt mindestens Android 9',
      keywords: ['android', 'version'],
      languageCode: 'de',
      knowledgeArea: 'hb_cure_app',
      detectedTopics: ['Android', 'App'],
      existingMatch: KnowledgeImportMatch(
        existingEntryId: 'e1',
        existingTitle: 'Systemvoraussetzungen',
        existingExcerpt: 'Unterstützte Betriebssysteme.',
        similarity: 0.5,
      ),
    ),
    KnowledgeImportDraft(
      id: 'd3',
      category: KnowledgeDraftCategory.faq,
      title: 'Muss Bluetooth aktiviert werden?',
      content: 'Bluetooth muss aktiviert werden',
      sourceSentence: 'Bluetooth muss aktiviert werden',
      question: 'Muss Bluetooth aktiviert werden?',
      languageCode: 'de',
      knowledgeArea: 'hb_cure_app',
      detectedTopics: ['Bluetooth'],
      isPossibleDuplicate: true,
    ),
  ],
);

Future<void> pumpScreen(
  WidgetTester tester, {
  KnowledgeImportAnalyzer? analyzer,
  AppState? state,
  Locale locale = const Locale('de'),
  Size size = const Size(1000, 1400),
  AiController? aiController,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  Widget screen = AppStateScope(
    notifier: state ?? AppState(),
    child: KnowledgeBuilderScreen(key: UniqueKey(), analyzer: analyzer),
  );
  if (aiController != null) {
    screen = AiScope(notifier: aiController, child: screen);
  }
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(KnowledgeBuilderScreen)))!;

Future<void> analyze(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const Key('kb-input')), text);
  await tester.pump();
  await tester.tap(find.byIcon(Icons.insights));
  await tester.pumpAndSettle();
}

/// Hosts the screen the way the guided demo does: a full [Scaffold] with
/// narration/controls chrome and the builder in a bounded [Expanded], at a
/// short desktop height. This is the exact context that previously overflowed
/// and swallowed the analyze tap.
Future<void> pumpEmbedded(
  WidgetTester tester, {
  KnowledgeImportAnalyzer? analyzer,
  AppState? state,
  Size size = const Size(1200, 640),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('de'),
      home: AppStateScope(
        notifier: state ?? AppState(),
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(height: 96, color: const Color(0xFFEFEFEF)),
                Expanded(
                  child: KnowledgeBuilderScreen(
                    key: UniqueKey(),
                    analyzer: analyzer,
                    embedded: true,
                  ),
                ),
                Container(height: 56, color: const Color(0xFFEFEFEF)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows document-bound Gemini insights and review suggestions', (
    tester,
  ) async {
    final provider = ScriptedGeminiProvider(
      responseText: '''
        {
          "summary": "Die App benötigt Bluetooth und Android 9.",
          "keyStatements": ["Bluetooth muss aktiviert sein."],
          "recommendedFaq": ["Muss Bluetooth aktiviert sein?"],
          "categories": ["Technische Voraussetzungen"],
          "missingInformation": ["Die unterstützte iOS-Version fehlt."],
          "possibleDuplicates": ["Systemvoraussetzungen prüfen."],
          "employeeQuestions": ["Welche iOS-Version wird unterstützt?"],
          "reviewSuggestions": ["Die beiden Bluetooth-FAQ überschneiden sich."]
        }
      ''',
    );
    await pumpScreen(
      tester,
      analyzer: const _FakeAnalyzer(_scripted),
      aiController: controllerWithScriptedGemini(provider),
      size: const Size(1000, 2600),
    );

    await analyze(
      tester,
      'Bluetooth muss aktiviert sein. Die App benötigt Android 9.',
    );

    expect(find.byKey(const Key('kb-gemini-insights')), findsOneWidget);
    expect(
      find.byKey(const Key('kb-gemini-review-suggestions')),
      findsOneWidget,
    );
    expect(
      find.text('Die App benötigt Bluetooth und Android 9.'),
      findsOneWidget,
    );
    expect(
      find.text('Die beiden Bluetooth-FAQ überschneiden sich.'),
      findsOneWidget,
    );
    expect(provider.calls, 1);
    expect(
      provider.requests.single.metadata['feature'],
      'knowledge-builder-insights',
    );
    expect(
      provider.requests.single.messages.last.content,
      contains('Bluetooth muss aktiviert sein'),
    );
  });

  testWidgets('long documents stay within the live Edge message limit', (
    tester,
  ) async {
    final provider = ScriptedGeminiProvider(
      responseText: '''
          {
            "summary": "Dokumentgebundene Zusammenfassung.",
            "keyStatements": [],
            "recommendedFaq": [],
            "categories": [],
            "missingInformation": [],
            "possibleDuplicates": [],
            "employeeQuestions": [],
            "reviewSuggestions": []
          }
        ''',
    );
    await pumpScreen(
      tester,
      analyzer: const _FakeAnalyzer(_scripted),
      aiController: controllerWithScriptedGemini(provider),
      size: const Size(1000, 2400),
    );

    final longDocument = List.filled(
      900,
      'Bluetooth-Verbindung und Firmware-Update.',
    ).join(' ');
    await analyze(tester, longDocument);

    expect(provider.calls, 1);
    final request = provider.requests.single;
    expect(request.maxTokens, 2048);
    final userMessage = request.messages.last.content;
    expect(userMessage.length, lessThanOrEqualTo(7800));
    final documentData = jsonDecode(userMessage) as Map<String, dynamic>;
    expect(documentData['languageCode'], 'de');
    expect(documentData['knowledgeArea'], 'hb_cure_app');
    expect(documentData['document'], isNotEmpty);
    expect(documentData['deterministicDrafts'], isNotEmpty);
    expect(find.byKey(const Key('kb-analysis-summary')), findsOneWidget);
    expect(find.byKey(const Key('kb-gemini-insights')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Gemini failure preserves the deterministic Knowledge Builder', (
    tester,
  ) async {
    final provider = ScriptedGeminiProvider(
      error: const AiTransportException(AiTransportErrorKind.network, 'down'),
    );
    await pumpScreen(
      tester,
      analyzer: const _FakeAnalyzer(_scripted),
      aiController: controllerWithScriptedGemini(provider),
      size: const Size(1000, 2400),
    );

    await analyze(tester, 'Bluetooth muss aktiviert sein.');

    expect(provider.calls, 1);
    expect(find.byKey(const Key('kb-analysis-summary')), findsOneWidget);
    expect(find.byKey(const Key('kb-draft-preview')), findsOneWidget);
    expect(find.byKey(const Key('kb-gemini-insights')), findsNothing);
    expect(find.byKey(const Key('kb-gemini-review-suggestions')), findsNothing);
    expect(find.byKey(const Key('kb-gemini-insights-error')), findsOneWidget);
    expect(find.text(l10n(tester).kbGeminiUnavailable), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Gemini Knowledge Builder cards are English and mobile-safe', (
    tester,
  ) async {
    final provider = ScriptedGeminiProvider(
      responseText: '''
        {
          "summary": "Bluetooth is required.",
          "keyStatements": ["Enable Bluetooth before connecting."],
          "recommendedFaq": ["How do I connect the app?"],
          "categories": ["Requirements"],
          "missingInformation": [],
          "possibleDuplicates": [],
          "employeeQuestions": ["Which iOS version is supported?"],
          "reviewSuggestions": ["Keep the answer concise."]
        }
      ''',
    );
    await pumpScreen(
      tester,
      analyzer: const _FakeAnalyzer(_scripted),
      aiController: controllerWithScriptedGemini(provider),
      locale: const Locale('en'),
      size: const Size(360, 3600),
    );

    await analyze(tester, 'Enable Bluetooth before connecting.');

    expect(find.text('Gemini Insights'), findsOneWidget);
    expect(find.text('✨ GEMINI PROPOSAL'), findsWidgets);
    expect(find.text('Key statements'), findsOneWidget);
    expect(find.text('Review Suggestions'), findsOneWidget);
    expect(
      find.text(
        'Review before applying. Gemini results are proposals '
        'only and are never saved automatically.',
      ),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('offline mock path does not present mock text as Gemini', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      analyzer: const _FakeAnalyzer(_scripted),
      aiController: AiController(AiProviderRegistry.mock()),
      size: const Size(1000, 2400),
    );

    await analyze(tester, 'Bluetooth muss aktiviert sein.');

    expect(find.byKey(const Key('kb-analysis-summary')), findsOneWidget);
    expect(find.byKey(const Key('kb-gemini-insights')), findsNothing);
    expect(find.byKey(const Key('kb-gemini-insights-error')), findsNothing);
    expect(find.textContaining('[mock:'), findsNothing);
  });

  testWidgets('shows four prepared demo documents', (tester) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    expect(find.text(l.kbDemoDocumentsTitle), findsOneWidget);
    expect(
      find.byKey(const Key('kb-demo-document-hb-cure-app')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('kb-demo-document-curebase')), findsOneWidget);
    expect(
      find.byKey(const Key('kb-demo-document-schnurrpurr')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('kb-demo-document-support-faq')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('kb-analyze-action-bar')), findsOneWidget);
  });

  testWidgets('loads an editable example without analyzing or saving', (
    tester,
  ) async {
    final state = AppState();
    final before = state.selectedWorkspace.knowledgeEntries.length;
    await pumpScreen(tester, state: state);
    final l = l10n(tester);
    final load = find.byKey(const Key('kb-load-demo-hb-cure-app'));

    await tester.tap(load);
    await tester.pumpAndSettle();

    final input = tester.widget<TextField>(find.byKey(const Key('kb-input')));
    expect(input.controller!.text, contains('HB Cure App'));
    expect(input.controller!.text, contains('Bluetooth'));
    expect(find.byKey(const Key('kb-loaded-demo-notice')), findsOneWidget);
    expect(find.text(l.kbExampleLoaded), findsOneWidget);
    expect(find.text('HB Cure App'), findsWidgets);
    expect(find.text('Bedienungsanleitung'), findsWidgets);
    expect(find.byKey(const Key('kb-analysis-summary')), findsNothing);
    expect(find.byKey(const Key('kb-phase-recognize')), findsNothing);
    expect(state.selectedWorkspace.knowledgeEntries.length, before);

    await tester.enterText(
      find.byKey(const Key('kb-input')),
      '${input.controller!.text}\nEigene Ergänzung.',
    );
    await tester.pump();

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('kb-input')))
          .controller!
          .text,
      endsWith('Eigene Ergänzung.'),
    );
    expect(find.byKey(const Key('kb-loaded-demo-notice')), findsNothing);
    expect(state.selectedWorkspace.knowledgeEntries.length, before);
  });

  testWidgets('loads English example content for an English interface', (
    tester,
  ) async {
    await pumpScreen(tester, locale: const Locale('en'));
    final load = find.byKey(const Key('kb-load-demo-curebase'));

    await tester.tap(load);
    await tester.pumpAndSettle();

    final input = tester.widget<TextField>(find.byKey(const Key('kb-input')));
    expect(input.controller!.text, contains('CureBase – Device description'));
    expect(
      input.controller!.text,
      contains('The battery must be fully charged'),
    );
    expect(find.text('Device description'), findsWidgets);
    expect(find.textContaining('English'), findsOneWidget);
  });

  testWidgets('loaded example enters the existing analysis flow in one click', (
    tester,
  ) async {
    final state = AppState();
    final before = state.selectedWorkspace.knowledgeEntries.length;
    await pumpScreen(tester, state: state);

    await tester.tap(find.byKey(const Key('kb-load-demo-support-faq')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('kb-analyze-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('kb-analysis-summary')), findsOneWidget);
    expect(find.byKey(const Key('kb-draft-preview')), findsOneWidget);
    expect(find.byKey(const Key('kb-analyze-action-bar')), findsNothing);
    expect(state.selectedWorkspace.knowledgeEntries.length, before);
  });

  testWidgets('accepts every draft into the active workspace', (tester) async {
    final state = AppState();
    final before = state.selectedWorkspace.knowledgeEntries.length;
    final seededIds = state.selectedWorkspace.knowledgeEntries
        .map((entry) => entry.id)
        .toSet();
    await pumpScreen(
      tester,
      analyzer: const _FakeAnalyzer(_scripted),
      state: state,
    );
    final l = l10n(tester);
    await analyze(tester, 'Text');

    final acceptAll = find.byKey(const Key('kb-import-all'));
    await tester.ensureVisible(acceptAll);
    await tester.pumpAndSettle();
    await tester.tap(acceptAll);
    await tester.pumpAndSettle();

    final workspaceEntries = state.selectedWorkspace.knowledgeEntries;
    final imported = workspaceEntries
        .where(
          (entry) => entry.source == KnowledgeEntrySources.knowledgeBuilder,
        )
        .toList();
    expect(workspaceEntries.length, before + _scripted.drafts.length);
    expect(imported, hasLength(_scripted.drafts.length));
    expect(imported.map((entry) => entry.title), [
      for (final draft in _scripted.drafts) draft.title,
    ]);
    expect(imported.map((entry) => entry.content), [
      for (final draft in _scripted.drafts) draft.content,
    ]);
    expect(find.byKey(const Key('kb-import-success')), findsOneWidget);
    expect(find.byKey(const Key('kb-import-success-dialog')), findsOneWidget);
    expect(find.text(l.kbSuccessDialogTitle), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('kb-growth-before')),
        matching: find.text(l.kbSuccessEntryValue(before)),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('kb-growth-after')),
        matching: find.text(
          l.kbSuccessEntryValue(before + _scripted.drafts.length),
        ),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('kb-learning-cycle')), findsOneWidget);
    expect(
      find.text(l.kbImportSuccessTitle(_scripted.drafts.length)),
      findsOneWidget,
    );
    expect(
      find.text(
        l.kbImportKnowledgeCount(before, before + _scripted.drafts.length),
      ),
      findsOneWidget,
    );
    expect(find.text(l.kbImportGroundedReady), findsOneWidget);
    expect(find.byKey(const Key('kb-import-all')), findsNothing);
    expect(find.text(l.kbDemoSaved), findsOneWidget);
    expect(find.text(l.kbDemoNotSaved), findsNothing);

    final groundedEntries = state.groundedAnswerWorkspace.knowledgeEntries;
    expect(groundedEntries, hasLength(_scripted.drafts.length));
    expect(
      groundedEntries.every(
        (entry) => entry.source == KnowledgeEntrySources.knowledgeBuilder,
      ),
      isTrue,
    );
    expect(
      groundedEntries.any((entry) => seededIds.contains(entry.id)),
      isFalse,
    );
    expect(state.groundedAnswerWorkspace.sourceMaterials, isEmpty);

    final workspaceFaq = workspaceEntries
        .where((entry) => entry.category == KnowledgeCategory.faq)
        .length;
    final workspaceKeywords = <String>{
      for (final entry in workspaceEntries)
        for (final keyword in entry.keywords)
          if (keyword.trim().isNotEmpty) keyword.trim().toLowerCase(),
    }.length;
    final expectedStats = {
      'documents': state.sourceMaterials.length,
      'entries': workspaceEntries.length,
      'faq': workspaceFaq,
      'keywords': workspaceKeywords,
    };
    for (final stat in expectedStats.entries) {
      expect(
        find.descendant(
          of: find.byKey(Key('kb-workspace-stat-${stat.key}')),
          matching: find.text('${stat.value}'),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets(
    'edits and imports optional website metadata without validation',
    (tester) async {
      final state = AppState();
      await pumpScreen(
        tester,
        analyzer: const _FakeAnalyzer(_scripted),
        state: state,
      );
      await analyze(tester, 'Text');

      final editor = find.byKey(const Key('kb-link-editor-d1'));
      await tester.ensureVisible(editor);
      await tester.tap(editor);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('kb-link-url-d1')),
        'https://company.example/support',
      );
      await tester.enterText(
        find.byKey(const Key('kb-link-title-d1')),
        'Support kontaktieren',
      );
      await tester.tap(find.byKey(const Key('kb-link-type-d1-none')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n(tester).knowledgeLinkSupport).last);
      await tester.pumpAndSettle();

      final importAll = find.byKey(const Key('kb-import-all'));
      await tester.ensureVisible(importAll);
      await tester.tap(importAll);
      await tester.pumpAndSettle();

      final imported = state.selectedWorkspace.knowledgeEntries.firstWhere(
        (entry) => entry.title == 'Muss Bluetooth aktiviert sein?',
      );
      expect(imported.websiteLink?.url, 'https://company.example/support');
      expect(imported.websiteLink?.title, 'Support kontaktieren');
      expect(imported.websiteLink?.type, KnowledgeLinkType.support);
    },
  );

  testWidgets('success dialog can reset the builder for another document', (
    tester,
  ) async {
    final state = AppState();
    await pumpScreen(
      tester,
      analyzer: const _FakeAnalyzer(_scripted),
      state: state,
    );
    await analyze(tester, 'Text');

    final acceptAll = find.byKey(const Key('kb-import-all'));
    await tester.ensureVisible(acceptAll);
    await tester.tap(acceptAll);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('kb-success-add-document')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('kb-import-success-dialog')), findsNothing);
    expect(find.byKey(const Key('kb-demo-documents')), findsOneWidget);
    expect(find.byKey(const Key('kb-analysis-summary')), findsNothing);
    expect(find.byKey(const Key('kb-draft-preview')), findsNothing);
    expect(find.byKey(const Key('kb-analyze-action-bar')), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('kb-input')))
          .controller!
          .text,
      isEmpty,
    );
  });

  testWidgets('success dialog navigates directly to Grounded Answer', (
    tester,
  ) async {
    final state = AppState();
    final router = GoRouter(
      initialLocation: '/knowledge-builder',
      routes: [
        GoRoute(
          path: '/knowledge-builder',
          builder: (context, routeState) =>
              const KnowledgeBuilderScreen(analyzer: _FakeAnalyzer(_scripted)),
        ),
        GoRoute(
          path: '/bot-test',
          builder: (context, routeState) => const Scaffold(
            body: Center(
              child: Text('Grounded Answer', key: Key('grounded-target')),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        builder: (context, child) =>
            AppStateScope(notifier: state, child: child!),
      ),
    );
    await tester.pumpAndSettle();
    await analyze(tester, 'Text');

    final acceptAll = find.byKey(const Key('kb-import-all'));
    await tester.ensureVisible(acceptAll);
    await tester.tap(acceptAll);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('kb-success-ask')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('grounded-target')), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/bot-test');
    expect(state.hasRecentKnowledgeImportForGroundedAnswer, isTrue);
  });

  testWidgets('success dialog is responsive and localized in English', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      analyzer: const _FakeAnalyzer(_scripted),
      locale: const Locale('en'),
      size: const Size(360, 800),
    );
    final l = l10n(tester);
    await analyze(tester, 'Text');

    final acceptAll = find.byKey(const Key('kb-import-all'));
    await tester.ensureVisible(acceptAll);
    await tester.tap(acceptAll);
    await tester.pumpAndSettle();

    expect(find.text(l.kbSuccessDialogTitle), findsOneWidget);
    expect(find.text(l.kbSuccessAddDocument), findsOneWidget);
    expect(find.text(l.kbSuccessAskNow), findsOneWidget);
    expect(
      find.byKey(const Key('kb-success-add-document')).hitTestable(),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('kb-success-ask')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the analyze action visible with a long mobile document', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(360, 800));
    final input = find.byKey(const Key('kb-input'));
    await tester.ensureVisible(input);
    await tester.enterText(
      input,
      List.filled(
        80,
        'Dies ist eine längere dokumentierte Aussage.',
      ).join('\n'),
    );
    await tester.pump();

    final action = find.byKey(const Key('kb-analyze-action'));
    final actionRect = tester.getRect(action);
    expect(action.hitTestable(), findsOneWidget);
    expect(actionRect.top, greaterThanOrEqualTo(0));
    expect(actionRect.bottom, lessThanOrEqualTo(800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('analyzes real free text and shows stats + drafts', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    await analyze(
      tester,
      'Die App läuft unter Android und iOS.\n'
      'Bluetooth muss aktiviert sein.\n'
      'Die App benötigt mindestens Android Version 9.',
    );

    expect(find.text(l.kbSummaryTitle), findsOneWidget);
    expect(find.text(l.kbDetectedStatements), findsWidgets);
    expect(find.text(l.kbDraftsTitle), findsOneWidget);
    // At least one FAQ category chip and a decision control are rendered.
    expect(find.text(l.kbCatFaq), findsWidgets);
    expect(find.text(l.kbDecisionAccept), findsWidgets);
    expect(find.text(l.kbFieldArea), findsWidgets);
    expect(find.text('HB Cure App'), findsWidgets);
    expect(find.text(l.kbFieldDetectedTopics), findsWidgets);
    expect(find.text(l.kbSummaryTitle), findsOneWidget);
    expect(find.byKey(const Key('kb-analysis-summary')), findsOneWidget);
    expect(find.byKey(const Key('kb-knowledge-use-demo')), findsOneWidget);
    expect(find.byKey(const Key('kb-demo-question-0')), findsOneWidget);
    final answerButton = tester.getRect(find.text(l.kbDemoCreateAnswer));
    expect(answerButton.top, greaterThanOrEqualTo(0));
    expect(answerButton.top, lessThan(1400));
  });

  testWidgets('reveals analysis phases before the entry preview', (
    tester,
  ) async {
    await pumpScreen(tester, analyzer: const _FakeAnalyzer(_scripted));
    final l = l10n(tester);

    await tester.enterText(find.byKey(const Key('kb-input')), 'Text');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.insights));
    await tester.pump();

    expect(find.text(l.kbAnalysisTitle), findsOneWidget);
    expect(find.byKey(const Key('kb-phase-recognize')), findsOneWidget);
    expect(find.byKey(const Key('kb-draft-preview')), findsNothing);

    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text(l.kbPhaseStructureTitle), findsOneWidget);
    expect(find.byKey(const Key('kb-draft-preview')), findsNothing);

    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text(l.kbPhaseCompareTitle), findsOneWidget);
    expect(find.byKey(const Key('kb-draft-preview')), findsNothing);

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('kb-analysis-summary')), findsOneWidget);
    expect(find.byKey(const Key('kb-draft-preview')), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text(l.kbAnalysisComplete), findsOneWidget);
    expect(find.byKey(const Key('kb-draft-preview')), findsOneWidget);
  });

  testWidgets('renders duplicate badge, existing match and merge choices', (
    tester,
  ) async {
    await pumpScreen(tester, analyzer: const _FakeAnalyzer(_scripted));
    final l = l10n(tester);

    await analyze(tester, 'irgendein langer text');

    // The transparent summary reflects the analysis.
    expect(find.text(l.kbSummaryTitle), findsOneWidget);
    // Duplicate detection is surfaced.
    expect(find.text(l.kbDuplicateBadge), findsOneWidget);
    // Existing entry suggestion with merge options.
    expect(find.text(l.kbExistingTitle), findsOneWidget);
    expect(find.text('Systemvoraussetzungen'), findsOneWidget);
    expect(find.text(l.kbMergeAugment), findsOneWidget);
    expect(find.text(l.kbMergeReplace), findsOneWidget);
    expect(find.text(l.kbMergeNew), findsOneWidget);
    // A generated FAQ question is shown.
    expect(find.text('Muss Bluetooth aktiviert sein?'), findsWidgets);
    expect(find.text(l.kbCreatedFrom), findsNWidgets(3));
    expect(find.text('“Bluetooth muss aktiviert sein”'), findsOneWidget);
  });

  testWidgets('prepared question creates a sourced answer without saving', (
    tester,
  ) async {
    final state = AppState();
    final before = state.selectedWorkspace.knowledgeEntries.length;
    await pumpScreen(
      tester,
      analyzer: const _FakeAnalyzer(_scripted),
      state: state,
    );
    final l = l10n(tester);
    await analyze(tester, 'Text');

    final firstQuestion = find.byKey(const Key('kb-demo-question-0'));
    expect(firstQuestion, findsOneWidget);
    expect(
      find.descendant(
        of: firstQuestion,
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('kb-demo-answer')), findsNothing);

    final createAnswer = find.text(l.kbDemoCreateAnswer);
    await tester.ensureVisible(createAnswer);
    await tester.pumpAndSettle();
    await tester.tap(createAnswer);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('kb-demo-answer')), findsOneWidget);
    expect(find.text(l.kbDemoSourcesTitle), findsOneWidget);
    expect(find.text(l.kbDemoSourceSentence), findsOneWidget);
    expect(find.text('“Bluetooth muss aktiviert sein”'), findsWidgets);
    expect(state.selectedWorkspace.knowledgeEntries.length, before);
  });

  testWidgets('generated category follows input language, not UI locale', (
    tester,
  ) async {
    await pumpScreen(tester, locale: const Locale('de'));
    await analyze(tester, 'The HB Cure App requires Android version 12.');

    expect(find.text('Technical requirement'), findsWidgets);
    expect(find.text('HB Cure App'), findsWidgets);
    expect(find.text('Android'), findsWidgets);
  });

  testWidgets('edit decision reveals editable fields', (tester) async {
    await pumpScreen(tester, analyzer: const _FakeAnalyzer(_scripted));
    final l = l10n(tester);
    await analyze(tester, 'text');

    // The source input is replaced by the analysis journey.
    expect(find.byType(TextField), findsNothing);

    final edit = find.text(l.kbDecisionEdit).first;
    await tester.ensureVisible(edit);
    await tester.pumpAndSettle();
    await tester.tap(edit);
    await tester.pumpAndSettle();

    // Editable title + editable content.
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('empty analysis shows the no-results hint', (tester) async {
    await pumpScreen(
      tester,
      analyzer: const _FakeAnalyzer(KnowledgeImportAnalysis.empty()),
    );
    final l = l10n(tester);
    await analyze(tester, 'text');
    expect(find.text(l.kbNoResults), findsOneWidget);
  });

  testWidgets('analysis never persists into the workspace', (tester) async {
    final state = AppState();
    final before = state.selectedWorkspace.knowledgeEntries.length;

    await pumpScreen(tester, state: state);
    await analyze(
      tester,
      'Bluetooth muss aktiviert sein.\n'
      'Die App benötigt mindestens Android Version 9.',
    );

    // Nothing is saved: the workspace is unchanged.
    expect(state.selectedWorkspace.knowledgeEntries.length, before);
  });

  testWidgets('lays out without overflow on mobile and desktop', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      analyzer: const _FakeAnalyzer(_scripted),
      size: const Size(360, 800),
    );
    await analyze(tester, 'text');
    expect(tester.takeException(), isNull);

    await pumpScreen(
      tester,
      analyzer: const _FakeAnalyzer(_scripted),
      size: const Size(1400, 1000),
    );
    await analyze(tester, 'text');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'embedded builder analyzes and reaches import at constrained desktop height',
    (tester) async {
      await pumpEmbedded(tester, analyzer: const _FakeAnalyzer(_scripted));

      // No overflow when embedded in a short, bounded host.
      expect(tester.takeException(), isNull);

      // Embedded hosts must not use the pinned bottom bar (root cause).
      final scaffold = tester.widget<Scaffold>(
        find.descendant(
          of: find.byType(KnowledgeBuilderScreen),
          matching: find.byType(Scaffold),
        ),
      );
      expect(scaffold.bottomNavigationBar, isNull);

      // Load a demo document, then analyze via the inline action.
      final load = find.byKey(const Key('kb-load-demo-hb-cure-app'));
      await tester.ensureVisible(load);
      await tester.tap(load);
      await tester.pumpAndSettle();

      final analyzeBtn = find.byKey(const Key('kb-analyze-action'));
      expect(analyzeBtn, findsOneWidget);
      await tester.ensureVisible(analyzeBtn);
      await tester.tap(analyzeBtn);
      await tester.pumpAndSettle();

      // The result renders (the bug was: nothing happened).
      expect(find.byKey(const Key('kb-analysis-summary')), findsOneWidget);
      expect(find.byKey(const Key('kb-draft-preview')), findsOneWidget);
      // The inline analyze action is replaced by the result once analysis exists.
      expect(analyzeBtn, findsNothing);
      // The import action is present and reachable in the scroll flow.
      final importBtn = find.byKey(const Key('kb-import-all'));
      expect(importBtn, findsOneWidget);
      await tester.ensureVisible(importBtn);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('standalone keeps the pinned bottomNavigationBar analyze action', (
    tester,
  ) async {
    await pumpScreen(tester, analyzer: const _FakeAnalyzer(_scripted));

    final scaffold = tester.widget<Scaffold>(
      find.descendant(
        of: find.byType(KnowledgeBuilderScreen),
        matching: find.byType(Scaffold),
      ),
    );
    expect(scaffold.bottomNavigationBar, isNotNull);
    expect(find.byKey(const Key('kb-analyze-action-bar')), findsOneWidget);

    // The existing bottom-bar analyze path still produces the result.
    await analyze(tester, 'text');
    expect(find.byKey(const Key('kb-draft-preview')), findsOneWidget);
  });
}
