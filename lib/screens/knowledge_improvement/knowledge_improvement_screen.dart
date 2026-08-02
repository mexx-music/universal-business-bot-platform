import 'package:flutter/material.dart';

import '../../knowledge_loop/knowledge_loop.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';

/// Knowledge Improvement Loop (BLOCK 4): a guided, seven-step visualisation of
/// the platform's core differentiator — how one customer question turns a
/// knowledge gap into permanent knowledge that every future answer benefits
/// from. Scripted demo, no live AI, no backend, no persistence.
class KnowledgeImprovementScreen extends StatefulWidget {
  const KnowledgeImprovementScreen({super.key});

  @override
  State<KnowledgeImprovementScreen> createState() =>
      _KnowledgeImprovementScreenState();
}

class _KnowledgeImprovementScreenState
    extends State<KnowledgeImprovementScreen> {
  int _step = 0;

  List<KnowledgeLoopStage> get _stages => KnowledgeImprovementDemo.stages;
  bool get _isLast => _step == _stages.length - 1;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final stage = _stages[_step];

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
                      Icon(Icons.loop, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.kiTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.kiIntro,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _TrustNotice(),
                  const SizedBox(height: 16),
                  _StepIndicator(current: _step, total: _stages.length),
                  const SizedBox(height: 16),
                  _StageCard(stage: stage, index: _step),
                  const SizedBox(height: 16),
                  _Controls(
                    step: _step,
                    total: _stages.length,
                    onNext: _isLast ? null : () => setState(() => _step++),
                    onRestart: () => setState(() => _step = 0),
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

class _Controls extends StatelessWidget {
  const _Controls({
    required this.step,
    required this.total,
    required this.onNext,
    required this.onRestart,
  });

  final int step;
  final int total;
  final VoidCallback? onNext;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (onNext != null)
          FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: Text(l.kiNext),
          ),
        OutlinedButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(l.kiRestart),
        ),
        Text(
          '${l.kiStep} ${step + 1} / $total',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < total; i++)
          _StepDot(
            number: i + 1,
            done: i < current,
            active: i == current,
            color: theme.colorScheme,
          ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.number,
    required this.done,
    required this.active,
    required this.color,
  });

  final int number;
  final bool done;
  final bool active;
  final ColorScheme color;

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? color.primary
        : done
        ? color.primaryContainer
        : color.surfaceContainerHighest;
    final fg = active
        ? color.onPrimary
        : done
        ? color.onPrimaryContainer
        : color.onSurfaceVariant;
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: done
          ? Icon(Icons.check, size: 16, color: fg)
          : Text(
              '$number',
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.stage, required this.index});

  final KnowledgeLoopStage stage;
  final int index;

  ({IconData icon, String title, String body}) _meta(AppLocalizations l) {
    return switch (stage) {
      KnowledgeLoopStage.customerQuestion => (
        icon: Icons.help_outline,
        title: l.kiStage1Title,
        body: l.kiStage1Body,
      ),
      KnowledgeLoopStage.aiAnswerGap => (
        icon: Icons.smart_toy_outlined,
        title: l.kiStage2Title,
        body: l.kiStage2Body,
      ),
      KnowledgeLoopStage.gapDetected => (
        icon: Icons.lightbulb_outline,
        title: l.kiStage3Title,
        body: l.kiStage3Body,
      ),
      KnowledgeLoopStage.improvementSuggested => (
        icon: Icons.auto_fix_high_outlined,
        title: l.kiStage4Title,
        body: l.kiStage4Body,
      ),
      KnowledgeLoopStage.employeeAccepts => (
        icon: Icons.how_to_reg_outlined,
        title: l.kiStage5Title,
        body: l.kiStage5Body,
      ),
      KnowledgeLoopStage.knowledgeGrows => (
        icon: Icons.trending_up,
        title: l.kiStage6Title,
        body: l.kiStage6Body,
      ),
      KnowledgeLoopStage.futureAnswersImprove => (
        icon: Icons.verified_outlined,
        title: l.kiStage7Title,
        body: l.kiStage7Body,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final meta = _meta(l);
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
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  meta.icon,
                  size: 18,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  meta.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            meta.body,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 14),
          _StageBody(stage: stage),
        ],
      ),
    );
  }
}

/// Stage-specific illustration.
class _StageBody extends StatelessWidget {
  const _StageBody({required this.stage});

  final KnowledgeLoopStage stage;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return switch (stage) {
      KnowledgeLoopStage.customerQuestion => _Bubble(
        text: l.kiQuestion,
        fromUser: true,
      ),
      KnowledgeLoopStage.aiAnswerGap => _Bubble(
        text: l.kiGapAnswer,
        fromUser: false,
      ),
      KnowledgeLoopStage.gapDetected => _GapChips(),
      KnowledgeLoopStage.improvementSuggested => _SuggestionCard(),
      KnowledgeLoopStage.employeeAccepts => _AcceptRow(),
      KnowledgeLoopStage.knowledgeGrows => _GrowthCounter(),
      KnowledgeLoopStage.futureAnswersImprove => _BeforeAfter(),
    };
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.fromUser});

  final String text;
  final bool fromUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fromUser
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.4,
            color: fromUser
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _GapChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final term in KnowledgeImprovementDemo.missingTerms)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              term,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              knowledgeDraftCategoryLabel(
                context,
                KnowledgeImprovementDemo.suggestionCategory,
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.kiSuggestionTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.kiSuggestionContent,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final k in KnowledgeImprovementDemo.suggestionKeywords)
                Chip(
                  label: Text(k),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AcceptRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(28),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l.kiStage5Body,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _CountBox(
          value: KnowledgeImprovementDemo.knowledgeBefore,
          label: l.kiKbCountLabel,
          muted: true,
        ),
        Icon(Icons.arrow_right_alt, color: theme.colorScheme.primary),
        _CountBox(
          value: KnowledgeImprovementDemo.knowledgeAfter,
          label: l.kiKbCountLabel,
          muted: false,
        ),
      ],
    );
  }
}

class _CountBox extends StatelessWidget {
  const _CountBox({
    required this.value,
    required this.label,
    required this.muted,
  });

  final int value;
  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: muted
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: muted
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: muted
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _BeforeAfter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final before = _AnswerColumn(
      label: l.kiBeforeLabel,
      text: l.kiGapAnswer,
      good: false,
    );
    final after = _AnswerColumn(
      label: l.kiAfterLabel,
      text: l.kiImprovedAnswer,
      good: true,
      sourceLabel: l.kiSourceLabel,
      sourceTitle: l.kiSuggestionTitle,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth >= 640) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: before),
                  const SizedBox(width: 12),
                  Expanded(child: after),
                ],
              );
            }
            return Column(
              children: [before, const SizedBox(height: 12), after],
            );
          },
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.celebration_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.kiAhaTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l.kiAhaBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnswerColumn extends StatelessWidget {
  const _AnswerColumn({
    required this.label,
    required this.text,
    required this.good,
    this.sourceLabel,
    this.sourceTitle,
  });

  final String label;
  final String text;
  final bool good;
  final String? sourceLabel;
  final String? sourceTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = good ? Colors.green : theme.colorScheme.tertiary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withAlpha(120)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                good ? Icons.check_circle_outline : Icons.help_outline,
                size: 16,
                color: accent,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(text, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
          if (sourceLabel != null && sourceTitle != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '$sourceLabel: $sourceTitle',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
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
            Icons.info_outline,
            size: 18,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.kiTrustNotice,
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
