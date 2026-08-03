import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/knowledge_builder/knowledge_import_analyzer.dart';
import 'package:universalbusiness/knowledge_builder/models/knowledge_import_models.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';
import 'package:universalbusiness/models/company_workspace.dart';
import 'package:universalbusiness/screens/knowledge_builder/knowledge_builder_screen.dart';

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
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: AppStateScope(
        notifier: state ?? AppState(),
        child: KnowledgeBuilderScreen(key: UniqueKey(), analyzer: analyzer),
      ),
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

void main() {
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
}
