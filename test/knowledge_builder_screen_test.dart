import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/knowledge_builder/knowledge_import_analyzer.dart';
import 'package:universalbusiness/knowledge_builder/models/knowledge_import_models.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';
import 'package:universalbusiness/screens/knowledge_builder/knowledge_builder_screen.dart';

/// Returns a scripted analysis regardless of input — for deterministic UI tests.
class _FakeAnalyzer extends KnowledgeImportAnalyzer {
  const _FakeAnalyzer(this.result);
  final KnowledgeImportAnalysis result;

  @override
  KnowledgeImportAnalysis analyze(
    String rawText, {
    List<KnowledgeEntry> existingEntries = const [],
  }) => result;
}

const _scripted = KnowledgeImportAnalysis(
  analyzedSentences: 5,
  unclearStatements: 1,
  drafts: [
    KnowledgeImportDraft(
      id: 'd1',
      category: KnowledgeDraftCategory.faq,
      title: 'Muss Bluetooth aktiviert sein?',
      content: 'Bluetooth muss aktiviert sein',
      sourceSentence: 'Bluetooth muss aktiviert sein',
      question: 'Muss Bluetooth aktiviert sein?',
      keywords: ['bluetooth'],
    ),
    KnowledgeImportDraft(
      id: 'd2',
      category: KnowledgeDraftCategory.technicalRequirement,
      title: 'Android Version',
      content: 'Die App benötigt mindestens Android 9',
      sourceSentence: 'Die App benötigt mindestens Android 9',
      keywords: ['android', 'version'],
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
        child: KnowledgeBuilderScreen(analyzer: analyzer),
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

    expect(find.text(l.kbStatsTitle), findsOneWidget);
    expect(find.text(l.kbStatSentences), findsOneWidget);
    expect(find.text(l.kbDraftsTitle), findsOneWidget);
    // At least one FAQ category chip and a decision control are rendered.
    expect(find.text(l.kbCatFaq), findsWidgets);
    expect(find.text(l.kbDecisionAccept), findsWidgets);
  });

  testWidgets('renders duplicate badge, existing match and merge choices', (
    tester,
  ) async {
    await pumpScreen(tester, analyzer: const _FakeAnalyzer(_scripted));
    final l = l10n(tester);

    await analyze(tester, 'irgendein langer text');

    // Stats reflect the analysis.
    expect(find.text(l.kbStatsTitle), findsOneWidget);
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
  });

  testWidgets('edit decision reveals editable fields', (tester) async {
    await pumpScreen(tester, analyzer: const _FakeAnalyzer(_scripted));
    final l = l10n(tester);
    await analyze(tester, 'text');

    // Only the input field before editing.
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.text(l.kbDecisionEdit).first);
    await tester.pumpAndSettle();

    // Input + editable title + editable content.
    expect(find.byType(TextField), findsNWidgets(3));
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
