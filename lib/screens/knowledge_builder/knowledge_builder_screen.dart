import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../knowledge/knowledge_context.dart';
import '../../knowledge_builder/knowledge_import_analyzer.dart';
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

class _KnowledgeBuilderScreenState extends State<KnowledgeBuilderScreen> {
  final _input = TextEditingController();
  KnowledgeImportAnalysis? _analysis;

  KnowledgeImportAnalyzer get _analyzer =>
      widget.analyzer ?? const KnowledgeImportAnalyzer();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _analyze() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    final workspace = AppState.of(context).selectedWorkspace;
    setState(() {
      _analysis = _analyzer.analyze(
        text,
        existingEntries: workspace.knowledgeEntries,
        workspace: workspace,
      );
    });
  }

  void _reset() => setState(() {
    _analysis = null;
    _input.clear();
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final analysis = _analysis;

    return Scaffold(
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
                  TextField(
                    key: const Key('kb-input'),
                    controller: _input,
                    minLines: 6,
                    maxLines: 14,
                    decoration: InputDecoration(
                      labelText: l.kbInputHint,
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _analyze,
                        icon: const Icon(Icons.insights, size: 18),
                        label: Text(l.kbAnalyze),
                      ),
                      if (analysis != null)
                        OutlinedButton.icon(
                          onPressed: _reset,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(l.kbReset),
                        ),
                    ],
                  ),
                  if (analysis != null) ...[
                    const SizedBox(height: 20),
                    if (analysis.isEmpty)
                      _EmptyResults()
                    else ...[
                      _StatsCard(analysis: analysis),
                      const SizedBox(height: 20),
                      Text(
                        l.kbDraftsTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final draft in analysis.drafts)
                        _DraftCard(draft: draft),
                    ],
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

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.analysis});

  final KnowledgeImportAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tiles = <(String, int)>[
      (l.kbStatSentences, analysis.analyzedSentences),
      (l.kbStatTopics, analysis.detectedTopics),
      (l.kbStatNew, analysis.newEntries),
      (l.kbStatExisting, analysis.existingMatches),
      (l.kbStatDuplicates, analysis.possibleDuplicates),
      (l.kbStatUnclear, analysis.unclearStatements),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.kbStatsTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final t in tiles) _StatTile(label: t.$1, value: t.$2),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
