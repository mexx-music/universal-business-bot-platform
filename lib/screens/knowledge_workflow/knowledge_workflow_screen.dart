import 'package:flutter/material.dart';

import '../../ai/ai_controller.dart';
import '../../ai/grounded_answer_service.dart';
import '../../data/app_state.dart';
import '../../knowledge_builder/knowledge_import_analyzer.dart';
import '../../knowledge_builder/models/knowledge_import_models.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';
import '../../models/knowledge_entry.dart';

/// Real end-to-end knowledge-improvement workflow (BLOCK 8). It only *connects*
/// existing modules — GroundedAnswerService (gap detection, grounded answers),
/// KnowledgeImportAnalyzer (suggestion), AppState.addKnowledgeEntry (the real
/// knowledge base) — into one reproducible loop. No new AI, no new heuristics,
/// no parallel data: the same workspace knowledge base is used throughout.
class KnowledgeWorkflowScreen extends StatefulWidget {
  const KnowledgeWorkflowScreen({super.key});

  @override
  State<KnowledgeWorkflowScreen> createState() =>
      _KnowledgeWorkflowScreenState();
}

enum _Phase { idle, gap, rejected, improved }

class _KnowledgeWorkflowScreenState extends State<KnowledgeWorkflowScreen> {
  static const _analyzer = KnowledgeImportAnalyzer();

  _Phase _phase = _Phase.idle;
  bool _busy = false;
  GroundedAnswerResult? _result; // gap or improved answer, by phase
  List<String> _keywords = const [];
  List<String> _detectedTopics = const [];
  String? _knowledgeArea;
  String? _languageCode;
  KnowledgeDraftCategory _category = KnowledgeDraftCategory.faq;
  TextEditingController? _title;
  TextEditingController? _content;

  @override
  void dispose() {
    _title?.dispose();
    _content?.dispose();
    super.dispose();
  }

  Future<GroundedAnswerResult> _run() {
    final l = AppLocalizations.of(context)!;
    final service = GroundedAnswerService(
      aiController: AiController.of(context),
    );
    return service.answer(
      GroundedAnswerRequest(
        question: l.kwQuestion,
        workspace: AppState.of(context).selectedWorkspace,
        language: Localizations.localeOf(context).languageCode,
      ),
    );
  }

  Future<void> _ask() async {
    if (_busy) return;
    final l = AppLocalizations.of(context)!;
    final workspace = AppState.of(context).selectedWorkspace;
    setState(() => _busy = true);
    final result = await _run();
    // Derive the suggestion from the existing analyzer (no new heuristic).
    final draft = _analyzer
        .analyze(
          l.kwQuestion,
          existingEntries: workspace.knowledgeEntries,
          workspace: workspace,
        )
        .drafts;
    if (!mounted) return;
    setState(() {
      _result = result;
      _keywords = draft.isEmpty ? const [] : draft.first.keywords;
      _detectedTopics = draft.isEmpty ? const [] : draft.first.detectedTopics;
      _knowledgeArea = draft.isEmpty ? null : draft.first.knowledgeArea;
      _languageCode = draft.isEmpty ? null : draft.first.languageCode;
      _category = draft.isEmpty
          ? KnowledgeDraftCategory.faq
          : draft.first.category;
      _title = TextEditingController(text: l.kwSuggestedEntryTitle);
      _content = TextEditingController(text: l.kwSuggestedEntryContent);
      _phase = _Phase.gap;
      _busy = false;
    });
  }

  Future<void> _accept() async {
    if (_busy) return;
    setState(() => _busy = true);
    final now = DateTime.now();
    final entry = KnowledgeEntry(
      id: 'k_${now.microsecondsSinceEpoch}',
      title: _title!.text.trim(),
      content: _content!.text.trim(),
      category: _category == KnowledgeDraftCategory.faq
          ? KnowledgeCategory.faq
          : KnowledgeCategory.allgemein,
      riskLevel: RiskLevel.green,
      keywords: _keywords,
      source: 'Knowledge Improvement',
      createdAt: now,
      languageCode:
          _languageCode ?? Localizations.localeOf(context).languageCode,
      knowledgeArea: _knowledgeArea,
      detectedTopics: _detectedTopics,
    );
    // Real mutation of the existing knowledge base.
    await AppState.of(context).addKnowledgeEntry(entry);
    final improved = await _run(); // same question, now grounded
    if (!mounted) return;
    setState(() {
      _result = improved;
      _phase = _Phase.improved;
      _busy = false;
    });
  }

  Future<void> _reject() async {
    if (_busy) return;
    setState(() => _busy = true);
    final still = await _run(); // knowledge base unchanged -> still a gap
    if (!mounted) return;
    setState(() {
      _result = still;
      _phase = _Phase.rejected;
      _busy = false;
    });
  }

  void _reset() {
    _title?.dispose();
    _content?.dispose();
    setState(() {
      _phase = _Phase.idle;
      _result = null;
      _title = null;
      _content = null;
      _keywords = const [];
      _detectedTopics = const [];
      _knowledgeArea = null;
      _languageCode = null;
    });
  }

  bool _stepDone(int step) {
    return switch (step) {
      1 => _phase != _Phase.idle,
      2 => _phase != _Phase.idle,
      3 => _phase != _Phase.idle,
      4 => _phase == _Phase.improved,
      5 => _phase == _Phase.improved,
      6 => _phase == _Phase.improved,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.kwTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.kwIntro,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, c) {
                      final rail = _ProcessRail(stepDone: _stepDone);
                      final main = _MainColumn(
                        phase: _phase,
                        busy: _busy,
                        result: _result,
                        titleCtrl: _title,
                        contentCtrl: _content,
                        category: _category,
                        onAsk: _ask,
                        onAccept: _accept,
                        onReject: _reject,
                        onReset: _reset,
                      );
                      if (c.maxWidth >= 760) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: main),
                            const SizedBox(width: 16),
                            SizedBox(width: 240, child: rail),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [rail, const SizedBox(height: 16), main],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MainColumn extends StatelessWidget {
  const _MainColumn({
    required this.phase,
    required this.busy,
    required this.result,
    required this.titleCtrl,
    required this.contentCtrl,
    required this.category,
    required this.onAsk,
    required this.onAccept,
    required this.onReject,
    required this.onReset,
  });

  final _Phase phase;
  final bool busy;
  final GroundedAnswerResult? result;
  final TextEditingController? titleCtrl;
  final TextEditingController? contentCtrl;
  final KnowledgeDraftCategory category;
  final VoidCallback onAsk;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuestionCard(
          question: l.kwQuestion,
          canAsk: phase == _Phase.idle && !busy,
          onAsk: onAsk,
        ),
        if (phase != _Phase.idle) ...[
          const SizedBox(height: 16),
          _AnswerCard(
            title: phase == _Phase.improved
                ? l.kwImprovedAnswerTitle
                : l.kwFirstAnswerTitle,
            result: result,
            improved: phase == _Phase.improved,
          ),
        ],
        if (phase == _Phase.gap) ...[
          const SizedBox(height: 16),
          _SuggestionCard(
            titleCtrl: titleCtrl!,
            contentCtrl: contentCtrl!,
            category: category,
            busy: busy,
            onAccept: onAccept,
            onReject: onReject,
          ),
        ],
        if (phase == _Phase.rejected) ...[
          const SizedBox(height: 12),
          _InfoBanner(icon: Icons.info_outline, text: l.kwRejectedInfo),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l.kwReset),
          ),
        ],
        if (phase == _Phase.improved) ...[
          const SizedBox(height: 16),
          _ClosingCard(),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l.kwReset),
          ),
        ],
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.canAsk,
    required this.onAsk,
  });

  final String question;
  final bool canAsk;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: canAsk ? onAsk : null,
            icon: const Icon(Icons.send, size: 18),
            label: Text(l.kwAsk),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.title,
    required this.result,
    required this.improved,
  });

  final String title;
  final GroundedAnswerResult? result;
  final bool improved;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final r = result;
    final grounded = improved && r != null && r.grounded;
    final answerText = grounded ? r.answer : l.botDemoNoKnowledge;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: grounded ? Colors.green : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                grounded ? Icons.check_circle_outline : Icons.help_outline,
                color: grounded ? Colors.green : theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (improved) ...[
            const SizedBox(height: 10),
            _InfoBanner(
              icon: Icons.auto_awesome,
              text: l.kwImprovedInfo,
              highlight: true,
            ),
          ],
          const SizedBox(height: 10),
          SelectableText(
            answerText,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
          ),
          if (grounded && r.sources.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              l.botDemoSources,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            for (final s in r.sources) _SourceCard(source: s),
          ],
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source});

  final GroundedSource source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    source.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  knowledgeCategoryLabel(context, source.category),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(source.excerpt, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.titleCtrl,
    required this.contentCtrl,
    required this.category,
    required this.busy,
    required this.onAccept,
    required this.onReject,
  });

  final TextEditingController titleCtrl;
  final TextEditingController contentCtrl;
  final KnowledgeDraftCategory category;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_fix_high_outlined,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.kwSuggestionTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  knowledgeDraftCategoryLabel(context, category),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: titleCtrl,
            decoration: InputDecoration(
              labelText: l.kbFieldTitle,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: contentCtrl,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: l.kbFieldContent,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: busy ? null : onAccept,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: Text(l.kwAccept),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : onReject,
                icon: const Icon(Icons.block, size: 18),
                label: Text(l.kwReject),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.text,
    this.highlight = false,
  });

  final IconData icon;
  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = highlight
        ? theme.colorScheme.tertiaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final fg = highlight
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: fg,
                height: 1.3,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClosingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: theme.colorScheme.onPrimaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.kwClosingTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.kwClosingBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessRail extends StatelessWidget {
  const _ProcessRail({required this.stepDone});

  final bool Function(int step) stepDone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final steps = [
      l.kwStep1,
      l.kwStep2,
      l.kwStep3,
      l.kwStep4,
      l.kwStep5,
      l.kwStep6,
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.kwProcessTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < steps.length; i++)
            _ProcessStep(
              label: steps[i],
              done: stepDone(i + 1),
              last: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ProcessStep extends StatelessWidget {
  const _ProcessStep({
    required this.label,
    required this.done,
    required this.last,
  });

  final String label;
  final bool done;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = done
        ? Colors.green
        : theme.colorScheme.surfaceContainerHighest;
    final fg = done ? Colors.white : theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  done ? Icons.check : Icons.circle_outlined,
                  size: 14,
                  color: fg,
                ),
              ),
              if (!last)
                Container(
                  width: 2,
                  height: 16,
                  color: theme.colorScheme.outlineVariant,
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: done ? FontWeight.bold : FontWeight.normal,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
