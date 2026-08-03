import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../knowledge/knowledge_context.dart';
import '../../knowledge_builder/knowledge_import_analyzer.dart';
import '../../knowledge_builder/models/knowledge_analysis_presentation.dart';
import '../../knowledge_builder/models/knowledge_demo_document.dart';
import '../../knowledge_builder/models/knowledge_import_models.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';

/// Knowledge Builder: paste unstructured company text, get a *preview* of
/// structured knowledge drafts. Analysis is deterministic and offline (no
/// Gemini, edge function or grounded retrieval), never invents facts and never
/// saves anything — the human decides per draft.
class KnowledgeBuilderScreen extends StatefulWidget {
  const KnowledgeBuilderScreen({super.key, this.analyzer});

  /// Test seam; production uses the default deterministic analyzer.
  final KnowledgeImportAnalyzer? analyzer;

  @override
  State<KnowledgeBuilderScreen> createState() => _KnowledgeBuilderScreenState();
}

class _KnowledgeBuilderScreenState extends State<KnowledgeBuilderScreen>
    with SingleTickerProviderStateMixin {
  static const _journeyDuration = Duration(milliseconds: 2400);

  final _input = TextEditingController();
  final _editorAnchor = GlobalKey();
  final _demoAnchor = GlobalKey();
  KnowledgeImportAnalysis? _analysis;
  KnowledgeAnalysisPresentation? _presentation;
  KnowledgeDemoDocument? _loadedDemo;
  late final AnimationController _journey;
  int _stage = 0;
  bool _hasRevealedDemo = false;

  KnowledgeImportAnalyzer get _analyzer =>
      widget.analyzer ?? const KnowledgeImportAnalyzer();

  @override
  void initState() {
    super.initState();
    _journey = AnimationController(vsync: this, duration: _journeyDuration)
      ..addListener(_updateStage)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted && _stage != 4) {
          setState(() => _stage = 4);
        }
      });
  }

  void _revealDemo() {
    if (_hasRevealedDemo) return;
    final target = _demoAnchor.currentContext;
    if (!mounted || target == null) return;
    _hasRevealedDemo = true;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    Scrollable.ensureVisible(
      target,
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
      alignment: 0.08,
    );
  }

  void _updateStage() {
    final next = switch (_journey.value) {
      < 0.30 => 0,
      < 0.60 => 1,
      < 0.82 => 2,
      _ => 3,
    };
    if (next != _stage && mounted) setState(() => _stage = next);
  }

  @override
  void dispose() {
    _journey.dispose();
    _input.dispose();
    super.dispose();
  }

  void _analyze() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final workspace = AppState.of(context).selectedWorkspace;
    final analysis = _analyzer.analyze(
      text,
      existingEntries: workspace.knowledgeEntries,
      workspace: workspace,
    );
    _journey.stop();
    _journey.value = 0;
    setState(() {
      _analysis = analysis;
      _presentation = KnowledgeAnalysisPresentation.fromAnalysis(analysis);
      _stage = 0;
      _hasRevealedDemo = false;
    });
    if (analysis.isEmpty || MediaQuery.of(context).disableAnimations) {
      _journey.value = 1;
      setState(() => _stage = 4);
    } else {
      _journey.forward();
    }
  }

  void _loadDemo(KnowledgeDemoDocument document) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final content = document.content(languageCode);
    _input.value = TextEditingValue(
      text: content,
      selection: TextSelection.collapsed(offset: content.length),
    );
    setState(() => _loadedDemo = document);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _editorAnchor.currentContext;
      if (!mounted || target == null) return;
      final reduceMotion = MediaQuery.of(context).disableAnimations;
      Scrollable.ensureVisible(
        target,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        alignment: 0.2,
      );
    });
  }

  void _onInputChanged(String _) {
    setState(() => _loadedDemo = null);
  }

  void _reset() {
    _journey.stop();
    _journey.value = 0;
    setState(() {
      _analysis = null;
      _presentation = null;
      _stage = 0;
      _hasRevealedDemo = false;
      _loadedDemo = null;
      _input.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final analysis = _analysis;

    return Scaffold(
      bottomNavigationBar: analysis == null
          ? _AnalyzeActionBar(
              canAnalyze: _input.text.trim().isNotEmpty,
              characterCount: _input.text.length,
              onAnalyze: _analyze,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_stories,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.kbTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.kbIntro,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _TrustNotice(),
                  const SizedBox(height: 16),
                  if (analysis == null) ...[
                    _DemoDocumentsSection(onLoad: _loadDemo),
                    const SizedBox(height: 16),
                    if (_loadedDemo case final loaded?) ...[
                      _LoadedDemoNotice(document: loaded),
                      const SizedBox(height: 12),
                    ],
                    KeyedSubtree(
                      key: _editorAnchor,
                      child: TextField(
                        key: const Key('kb-input'),
                        controller: _input,
                        onChanged: _onInputChanged,
                        minLines: 6,
                        maxLines: 14,
                        decoration: InputDecoration(
                          labelText: l.kbInputHint,
                          alignLabelWithHint: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    _AnalysisJourney(
                      presentation: _presentation!,
                      stage: _stage,
                      progress: _journey,
                      onReset: _reset,
                      demoAnchor: _demoAnchor,
                      onDemoReady: _revealDemo,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoDocumentsSection extends StatelessWidget {
  const _DemoDocumentsSection({required this.onLoad});

  final ValueChanged<KnowledgeDemoDocument> onLoad;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Container(
      key: const Key('kb-demo-documents'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_copy_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.kbDemoDocumentsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.kbDemoDocumentsIntro,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 680 ? 2 : 1;
              const spacing = 12.0;
              final cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final document in knowledgeDemoDocuments)
                    SizedBox(
                      width: cardWidth,
                      child: _DemoDocumentCard(
                        document: document,
                        languageCode: languageCode,
                        onLoad: () => onLoad(document),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DemoDocumentCard extends StatelessWidget {
  const _DemoDocumentCard({
    required this.document,
    required this.languageCode,
    required this.onLoad,
  });

  final KnowledgeDemoDocument document;
  final String languageCode;
  final VoidCallback onLoad;

  IconData get _icon => switch (document.id) {
    'hb-cure-app' => Icons.phone_android,
    'curebase' => Icons.electric_bolt,
    'schnurrpurr' => Icons.pets,
    _ => Icons.quiz_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      key: Key('kb-demo-document-${document.id}'),
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                _icon,
                size: 22,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    document.documentType(languageCode),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    key: Key('kb-load-demo-${document.id}'),
                    onPressed: onLoad,
                    icon: const Icon(Icons.file_download_outlined, size: 18),
                    label: Text(l.kbLoadExample),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedDemoNotice extends StatelessWidget {
  const _LoadedDemoNotice({required this.document});

  final KnowledgeDemoDocument document;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final language = _languageLabel(l, languageCode);
    return Container(
      key: const Key('kb-loaded-demo-notice'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(90)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.kbExampleLoaded,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _LoadedDemoFact(label: l.kbExampleLanguage, value: language),
              _LoadedDemoFact(label: l.kbExampleArea, value: document.area),
              _LoadedDemoFact(
                label: l.kbExampleDocumentType,
                value: document.documentType(languageCode),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l.kbExampleReady,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadedDemoFact extends StatelessWidget {
  const _LoadedDemoFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(190),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}

class _AnalyzeActionBar extends StatelessWidget {
  const _AnalyzeActionBar({
    required this.canAnalyze,
    required this.characterCount,
    required this.onAnalyze,
  });

  final bool canAnalyze;
  final int characterCount;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Material(
      key: const Key('kb-analyze-action-bar'),
      color: theme.colorScheme.surface,
      elevation: 8,
      shadowColor: theme.colorScheme.shadow.withAlpha(70),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final button = FilledButton.icon(
                  key: const Key('kb-analyze-action'),
                  onPressed: canAnalyze ? onAnalyze : null,
                  icon: const Icon(Icons.insights, size: 18),
                  label: Text(l.kbAnalyze),
                );
                final status = Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      canAnalyze ? l.kbAnalyzeReady : l.kbAnalyzeEmptyHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (canAnalyze)
                      Text(
                        '$characterCount ${l.kbCharacters}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                );

                if (constraints.maxWidth < 520) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [status, const SizedBox(height: 8), button],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: status),
                    const SizedBox(width: 12),
                    button,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 18,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.kbTrustNotice,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.inbox_outlined,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l.kbNoResults,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnalysisJourney extends StatelessWidget {
  const _AnalysisJourney({
    required this.presentation,
    required this.stage,
    required this.progress,
    required this.onReset,
    required this.demoAnchor,
    required this.onDemoReady,
  });

  final KnowledgeAnalysisPresentation presentation;
  final int stage;
  final Animation<double> progress;
  final VoidCallback onReset;
  final Key demoAnchor;
  final VoidCallback onDemoReady;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final analysis = presentation.analysis;
    final language = _languageLabel(l, analysis.inputLanguageCode);
    final area = KnowledgeAreas.label(
      analysis.knowledgeArea,
      languageCode: Localizations.localeOf(context).languageCode,
    );
    final documentType = _documentTypeLabel(l, presentation.documentType);

    if (analysis.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EmptyResults(),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l.kbReset),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _JourneyHeader(stage: stage, progress: progress, onReset: onReset),
        const SizedBox(height: 16),
        _ProgressPhaseCard(
          key: const Key('kb-phase-recognize'),
          index: 0,
          stage: stage,
          icon: Icons.manage_search,
          title: l.kbPhaseRecognizeTitle,
          facts: [
            _AnalysisFactData(l.kbDetectedLanguage, language),
            _AnalysisFactData(l.kbFieldArea, area),
            _AnalysisFactData(l.kbDetectedDocumentType, documentType),
            _AnalysisFactData(
              l.kbDetectedStatements,
              '${analysis.drafts.length}',
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ProgressPhaseCard(
          key: const Key('kb-phase-structure'),
          index: 1,
          stage: stage,
          icon: Icons.account_tree_outlined,
          title: l.kbPhaseStructureTitle,
          facts: [
            _AnalysisFactData(l.kbMetricFaq, '${presentation.faqCount}'),
            _AnalysisFactData(
              l.kbMetricProductFeatures,
              '${presentation.productFeatureCount}',
            ),
            _AnalysisFactData(l.kbMetricSteps, '${presentation.stepCount}'),
            _AnalysisFactData(
              l.kbMetricWarnings,
              '${presentation.warningCount}',
            ),
            _AnalysisFactData(
              l.kbMetricRequirements,
              '${presentation.requirementCount}',
            ),
            _AnalysisFactData(
              l.kbMetricDefinitions,
              '${presentation.definitionCount}',
            ),
            _AnalysisFactData(l.kbMetricTips, '${presentation.tipCount}'),
            _AnalysisFactData(
              l.kbMetricKeywords,
              '${presentation.keywordCount}',
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ProgressPhaseCard(
          key: const Key('kb-phase-compare'),
          index: 2,
          stage: stage,
          icon: Icons.fact_check_outlined,
          title: l.kbPhaseCompareTitle,
          facts: [
            _AnalysisFactData(l.kbStatExisting, '${analysis.existingMatches}'),
            _AnalysisFactData(
              l.kbStatDuplicates,
              '${analysis.possibleDuplicates}',
            ),
            _AnalysisFactData(l.kbStatNew, '${analysis.newEntries}'),
            _AnalysisFactData(
              l.kbMetricSimilarTopics,
              '${presentation.similarTopicCount}',
            ),
            _AnalysisFactData(
              l.kbMetricProducts,
              '${presentation.productCount}',
            ),
            _AnalysisFactData(l.kbMetricDevices, '${presentation.deviceCount}'),
            _AnalysisFactData(
              l.kbMetricFunctions,
              '${presentation.functionCount}',
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          child: stage >= 3
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _AnalysisSummary(
                    presentation: presentation,
                    language: language,
                    area: area,
                    documentType: documentType,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          onEnd: stage >= 4 ? onDemoReady : null,
          child: stage >= 4
              ? Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    children: [
                      if (presentation.demoQuestions.isNotEmpty) ...[
                        _KnowledgeUseDemo(
                          presentation: presentation,
                          answerButtonKey: demoAnchor,
                        ),
                        const SizedBox(height: 24),
                      ],
                      _DraftPreview(analysis: analysis),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _JourneyHeader extends StatelessWidget {
  const _JourneyHeader({
    required this.stage,
    required this.progress,
    required this.onReset,
  });

  final int stage;
  final Animation<double> progress;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final complete = stage >= 4;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  complete ? Icons.check_rounded : Icons.psychology_outlined,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      complete ? l.kbAnalysisComplete : l.kbAnalysisTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l.kbAnalysisIntro,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l.kbReset,
                onPressed: onReset,
                icon: const Icon(Icons.refresh),
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: progress,
            builder: (context, _) => LinearProgressIndicator(
              value: complete ? 1 : progress.value,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: theme.colorScheme.surface.withAlpha(120),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisFactData {
  const _AnalysisFactData(this.label, this.value);

  final String label;
  final String value;
}

class _ProgressPhaseCard extends StatelessWidget {
  const _ProgressPhaseCard({
    super.key,
    required this.index,
    required this.stage,
    required this.icon,
    required this.title,
    required this.facts,
  });

  final int index;
  final int stage;
  final IconData icon;
  final String title;
  final List<_AnalysisFactData> facts;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final complete = stage > index;
    final active = stage == index;
    final visible = active || complete;
    final color = complete
        ? theme.colorScheme.tertiary
        : active
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: visible
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: visible
              ? color.withAlpha(120)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: complete
                    ? Icon(
                        Icons.check_circle,
                        key: const ValueKey('complete'),
                        color: color,
                      )
                    : active
                    ? SizedBox(
                        key: const ValueKey('active'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: color,
                        ),
                      )
                    : Icon(icon, key: const ValueKey('pending'), color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: visible ? null : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                complete
                    ? l.kbPhaseComplete
                    : active
                    ? l.kbPhaseActive
                    : l.kbPhasePending,
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            child: visible
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final fact in facts)
                          _AnalysisFact(fact: fact, complete: complete),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _AnalysisFact extends StatelessWidget {
  const _AnalysisFact({required this.fact, required this.complete});

  final _AnalysisFactData fact;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = complete
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary;
    return Container(
      constraints: const BoxConstraints(minWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fact.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  fact.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisSummary extends StatelessWidget {
  const _AnalysisSummary({
    required this.presentation,
    required this.language,
    required this.area,
    required this.documentType,
  });

  final KnowledgeAnalysisPresentation presentation;
  final String language;
  final String area;
  final String documentType;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final analysis = presentation.analysis;
    final metrics = <_AnalysisFactData>[
      _AnalysisFactData(l.kbDetectedLanguage, language),
      _AnalysisFactData(l.kbFieldArea, area),
      _AnalysisFactData(l.kbDetectedDocumentType, documentType),
      _AnalysisFactData(l.kbDetectedStatements, '${analysis.drafts.length}'),
      _AnalysisFactData(l.kbMetricFaq, '${presentation.faqCount}'),
      _AnalysisFactData(
        l.kbMetricProductFeatures,
        '${presentation.productFeatureCount}',
      ),
      _AnalysisFactData(l.kbMetricWarnings, '${presentation.warningCount}'),
      _AnalysisFactData(
        l.kbMetricRequirements,
        '${presentation.requirementCount}',
      ),
      _AnalysisFactData(l.kbStatNew, '${analysis.newEntries}'),
      _AnalysisFactData(l.kbStatExisting, '${analysis.existingMatches}'),
      _AnalysisFactData(l.kbStatDuplicates, '${analysis.possibleDuplicates}'),
    ];

    return Container(
      key: const Key('kb-analysis-summary'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.task_alt,
                size: 30,
                color: theme.colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.kbSummaryTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.kbSummaryIntro,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720
                  ? 3
                  : constraints.maxWidth >= 460
                  ? 2
                  : 1;
              const gap = 10.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final metric in metrics)
                    SizedBox(
                      width: width,
                      child: _SummaryMetric(metric: metric),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.metric});

  final _AnalysisFactData metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(210),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            metric.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _KnowledgeUseDemo extends StatefulWidget {
  const _KnowledgeUseDemo({
    required this.presentation,
    required this.answerButtonKey,
  });

  final KnowledgeAnalysisPresentation presentation;
  final Key answerButtonKey;

  @override
  State<_KnowledgeUseDemo> createState() => _KnowledgeUseDemoState();
}

class _KnowledgeUseDemoState extends State<_KnowledgeUseDemo> {
  int _selected = 0;
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final questions = widget.presentation.demoQuestions;
    final selected = questions[_selected];

    return Container(
      key: const Key('kb-knowledge-use-demo'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l.kbDemoBadge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                l.kbDemoNotSaved,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.question_answer_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.kbDemoTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.kbDemoIntro,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            l.kbDemoQuestionLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < questions.length; index++) ...[
            _QuestionOption(
              key: Key('kb-demo-question-$index'),
              question: questions[index].question,
              selected: index == _selected,
              onTap: () => setState(() {
                _selected = index;
                _showAnswer = false;
              }),
            ),
            if (index != questions.length - 1) const SizedBox(height: 8),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            key: widget.answerButtonKey,
            onPressed: () => setState(() => _showAnswer = true),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: Text(l.kbDemoCreateAnswer),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            child: _showAnswer
                ? Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: _DemoAnswer(question: selected),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _QuestionOption extends StatelessWidget {
  const _QuestionOption({
    super.key,
    required this.question,
    required this.selected,
    required this.onTap,
  });

  final String question;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w600 : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoAnswer extends StatelessWidget {
  const _DemoAnswer({required this.question});

  final KnowledgeDemoQuestion question;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final draft = question.draft;
    return Column(
      key: const Key('kb-demo-answer'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 19,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.kbDemoAnswerTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SelectableText(
                question.answer,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l.kbDemoSourcesTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    draft.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _CategoryChip(label: _draftCategoryLabel(context, draft)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l.kbDemoSourceSentence,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              SelectableText(
                '“${question.sourceSentence}”',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DraftPreview extends StatelessWidget {
  const _DraftPreview({required this.analysis});

  final KnowledgeImportAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      key: const Key('kb-draft-preview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.kbDraftsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l.kbPreviewIntro,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        for (final draft in analysis.drafts) _DraftCard(draft: draft),
      ],
    );
  }
}

/// Self-contained: holds its own accept/edit/ignore decision, optional merge
/// choice and edit controllers. Nothing here persists — it is a preview only.
class _DraftCard extends StatefulWidget {
  const _DraftCard({required this.draft});

  final KnowledgeImportDraft draft;

  @override
  State<_DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends State<_DraftCard> {
  DraftDecision _decision = DraftDecision.undecided;
  MergeChoice? _merge;
  TextEditingController? _titleCtrl;
  TextEditingController? _contentCtrl;

  @override
  void dispose() {
    _titleCtrl?.dispose();
    _contentCtrl?.dispose();
    super.dispose();
  }

  void _setDecision(DraftDecision d) {
    setState(() {
      _decision = d;
      if (d == DraftDecision.edit) {
        _titleCtrl ??= TextEditingController(text: widget.draft.title);
        _contentCtrl ??= TextEditingController(text: widget.draft.content);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final draft = widget.draft;
    final editing = _decision == DraftDecision.edit;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _CategoryChip(label: _draftCategoryLabel(context, draft)),
                if (draft.isPossibleDuplicate)
                  _WarnChip(label: l.kbDuplicateBadge),
              ],
            ),
            const SizedBox(height: 10),
            _Labelled(
              label: l.kbFieldArea,
              value: KnowledgeAreas.label(
                draft.knowledgeArea,
                languageCode:
                    draft.languageCode ??
                    Localizations.localeOf(context).languageCode,
              ),
            ),
            const SizedBox(height: 6),
            _Labelled(
              label: l.kbFieldCategory,
              value: _draftCategoryLabel(context, draft),
            ),
            const SizedBox(height: 6),
            if (editing) ...[
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: l.kbFieldTitle,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentCtrl,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l.kbFieldContent,
                  border: const OutlineInputBorder(),
                ),
              ),
            ] else ...[
              _Labelled(label: l.kbFieldTitle, value: draft.title),
              if (draft.question != null) ...[
                const SizedBox(height: 6),
                _Labelled(label: l.kbFieldQuestion, value: draft.question!),
              ],
              const SizedBox(height: 6),
              _Labelled(label: l.kbFieldContent, value: draft.content),
            ],
            const SizedBox(height: 10),
            _OriginBlock(sourceSentence: draft.sourceSentence),
            if (draft.keywords.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                l.kbFieldKeywords,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final k in draft.keywords) _KeywordChip(term: k),
                ],
              ),
            ],
            if (draft.detectedTopics.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                l.kbFieldDetectedTopics,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final topic in draft.detectedTopics)
                    _TopicChip(topic: topic),
                ],
              ),
            ],
            if (draft.existingMatch != null) ...[
              const SizedBox(height: 12),
              _ExistingMatchBlock(
                match: draft.existingMatch!,
                newInfo: draft.content,
                selected: _merge,
                onSelected: (m) => setState(() => _merge = m),
              ),
            ],
            const SizedBox(height: 12),
            _DecisionBar(decision: _decision, onChanged: _setDecision),
          ],
        ),
      ),
    );
  }
}

class _DecisionBar extends StatelessWidget {
  const _DecisionBar({required this.decision, required this.onChanged});

  final DraftDecision decision;
  final ValueChanged<DraftDecision> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Align(
      alignment: Alignment.centerLeft,
      child: SegmentedButton<DraftDecision>(
        emptySelectionAllowed: true,
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: DraftDecision.accept,
            icon: const Icon(Icons.check, size: 16),
            label: Text(l.kbDecisionAccept),
          ),
          ButtonSegment(
            value: DraftDecision.edit,
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: Text(l.kbDecisionEdit),
          ),
          ButtonSegment(
            value: DraftDecision.ignore,
            icon: const Icon(Icons.block, size: 16),
            label: Text(l.kbDecisionIgnore),
          ),
        ],
        selected: decision == DraftDecision.undecided ? {} : {decision},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

class _ExistingMatchBlock extends StatelessWidget {
  const _ExistingMatchBlock({
    required this.match,
    required this.newInfo,
    required this.selected,
    required this.onSelected,
  });

  final KnowledgeImportMatch match;
  final String newInfo;
  final MergeChoice? selected;
  final ValueChanged<MergeChoice> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Labelled(label: l.kbExistingTitle, value: match.existingTitle),
          const SizedBox(height: 6),
          _Labelled(label: l.kbNewInfoTitle, value: newInfo),
          const SizedBox(height: 10),
          Text(
            l.kbSuggestionTitle,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MergeChoiceChip(
                label: l.kbMergeAugment,
                value: MergeChoice.augment,
                selected: selected,
                onSelected: onSelected,
              ),
              _MergeChoiceChip(
                label: l.kbMergeReplace,
                value: MergeChoice.replace,
                selected: selected,
                onSelected: onSelected,
              ),
              _MergeChoiceChip(
                label: l.kbMergeNew,
                value: MergeChoice.newEntry,
                selected: selected,
                onSelected: onSelected,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MergeChoiceChip extends StatelessWidget {
  const _MergeChoiceChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final MergeChoice value;
  final MergeChoice? selected;
  final ValueChanged<MergeChoice> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected == value,
      onSelected: (_) => onSelected(value),
    );
  }
}

class _OriginBlock extends StatelessWidget {
  const _OriginBlock({required this.sourceSentence});

  final String sourceSentence;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: const Key('kb-entry-origin'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(115),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.kbCreatedFrom,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  '“$sourceSentence”',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(height: 1.35)),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _WarnChip extends StatelessWidget {
  const _WarnChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.copy_all_outlined,
            size: 13,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip({required this.term});

  final String term;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(term, style: theme.textTheme.labelSmall),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.topic});

  final String topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        topic,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

String _draftCategoryLabel(BuildContext context, KnowledgeImportDraft draft) {
  if (draft.languageCode == null) {
    return knowledgeDraftCategoryLabel(context, draft.category);
  }
  final de = draft.languageCode == 'de';
  return switch (draft.category) {
    KnowledgeDraftCategory.faq => 'FAQ',
    KnowledgeDraftCategory.installation =>
      de ? 'Installationsanleitung' : 'Installation guide',
    KnowledgeDraftCategory.stepByStep =>
      de ? 'Schritt-für-Schritt' : 'Step-by-step',
    KnowledgeDraftCategory.technicalRequirement =>
      de ? 'Technische Voraussetzung' : 'Technical requirement',
    KnowledgeDraftCategory.warning => de ? 'Warnhinweis' : 'Warning',
    KnowledgeDraftCategory.troubleshooting =>
      de ? 'Problemlösung' : 'Troubleshooting',
    KnowledgeDraftCategory.productFeature =>
      de ? 'Produktfunktion' : 'Product feature',
    KnowledgeDraftCategory.tip => de ? 'Tipp' : 'Tip',
    KnowledgeDraftCategory.definition => 'Definition',
    KnowledgeDraftCategory.contact =>
      de ? 'Kontaktinformation' : 'Contact information',
    KnowledgeDraftCategory.general => de ? 'Allgemein' : 'General',
  };
}

String _languageLabel(AppLocalizations l, String? languageCode) =>
    switch (languageCode) {
      'de' => l.kbLanguageGerman,
      'en' => l.kbLanguageEnglish,
      _ => l.kbLanguageUnknown,
    };

String _documentTypeLabel(
  AppLocalizations l,
  KnowledgeDocumentType documentType,
) => switch (documentType) {
  KnowledgeDocumentType.faqCollection => l.kbDocTypeFaqCollection,
  KnowledgeDocumentType.productDescription => l.kbDocTypeProductDescription,
  KnowledgeDocumentType.instructions => l.kbDocTypeInstructions,
  KnowledgeDocumentType.technicalDocumentation =>
    l.kbDocTypeTechnicalDocumentation,
  KnowledgeDocumentType.companyKnowledge => l.kbDocTypeCompanyKnowledge,
};
