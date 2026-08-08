import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../bot_test/grounded_answer_panel.dart';
import '../knowledge_builder/knowledge_builder_screen.dart';
import '../knowledge_improvement/knowledge_improvement_screen.dart';

/// Guided Demo (BLOCK 5): stitches the existing modules into one two-minute,
/// seven-step story. It adds no business logic — it embeds the real
/// KnowledgeBuilder, GroundedAnswerPanel and KnowledgeImprovement modules and
/// frames them with narration, a left step navigation and a progress bar.
class GuidedDemoScreen extends StatefulWidget {
  const GuidedDemoScreen({super.key});

  static const int stepCount = 7;

  @override
  State<GuidedDemoScreen> createState() => _GuidedDemoScreenState();
}

class _GuidedDemoScreenState extends State<GuidedDemoScreen> {
  int _step = 0;

  void _go(int i) =>
      setState(() => _step = i.clamp(0, GuidedDemoScreen.stepCount - 1));

  List<String> _titles(AppLocalizations l) => [
    l.gdStep1Title,
    l.gdStep2Title,
    l.gdStep3Title,
    l.gdStep4Title,
    l.gdStep5Title,
    l.gdStep6Title,
    l.gdStep7Title,
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final titles = _titles(l);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 820;
            final main = Column(
              children: [
                _ProgressHeader(
                  step: _step,
                  total: GuidedDemoScreen.stepCount,
                  title: titles[_step],
                ),
                if (!wide)
                  _HorizontalNav(titles: titles, current: _step, onSelect: _go),
                Expanded(
                  child: _StepContent(
                    step: _step,
                    onNext: () => _go(_step + 1),
                  ),
                ),
                _Controls(
                  step: _step,
                  total: GuidedDemoScreen.stepCount,
                  onBack: _step == 0 ? null : () => _go(_step - 1),
                  onNext: _step == GuidedDemoScreen.stepCount - 1
                      ? null
                      : () => _go(_step + 1),
                ),
              ],
            );

            if (!wide) return main;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 250,
                  child: _SideNav(
                    titles: titles,
                    current: _step,
                    onSelect: _go,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: main),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.step,
    required this.total,
    required this.title,
  });

  final int step;
  final int total;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${l.kiStep} ${step + 1} / $total',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (step + 1) / total,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.titles,
    required this.current,
    required this.onSelect,
  });

  final List<String> titles;
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: titles.length,
      itemBuilder: (context, i) {
        final active = i == current;
        final done = i < current;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: active
                ? theme.colorScheme.secondaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onSelect(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    _StepDot(number: i + 1, active: active, done: done),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        titles[i],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: active
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HorizontalNav extends StatelessWidget {
  const _HorizontalNav({
    required this.titles,
    required this.current,
    required this.onSelect,
  });

  final List<String> titles;
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: titles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return ActionChip(
            avatar: _StepDot(
              number: i + 1,
              active: i == current,
              done: i < current,
            ),
            label: Text(titles[i]),
            onPressed: () => onSelect(i),
          );
        },
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.number,
    required this.active,
    required this.done,
  });

  final int number;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final bg = active
        ? c.primary
        : done
        ? c.primaryContainer
        : c.surfaceContainerHighest;
    final fg = active
        ? c.onPrimary
        : done
        ? c.onPrimaryContainer
        : c.onSurfaceVariant;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: done
          ? Icon(Icons.check, size: 14, color: fg)
          : Text(
              '$number',
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.step,
    required this.total,
    required this.onBack,
    required this.onNext,
  });

  final int step;
  final int total;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: Text(l.gdBack),
          ),
          const Spacer(),
          if (onNext != null)
            FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(l.gdNext),
            ),
        ],
      ),
    );
  }
}

/// Renders the current step. Steps 2–5 embed the real existing modules; steps
/// 1, 6 and 7 are framing/summary panels.
class _StepContent extends StatelessWidget {
  const _StepContent({required this.step, required this.onNext});

  final int step;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return switch (step) {
      0 => _Welcome(onStart: onNext),
      1 => _Framed(
        narration: l.gdNarr2,
        child: const Expanded(child: KnowledgeBuilderScreen(embedded: true)),
      ),
      2 => _Framed(
        narration: l.gdNarr3,
        child: const Expanded(
          child: SingleChildScrollView(child: GroundedAnswerPanel()),
        ),
      ),
      3 => _Framed(
        narration: l.gdNarr4,
        child: const Expanded(
          child: SingleChildScrollView(child: GroundedAnswerPanel()),
        ),
      ),
      4 => _Framed(
        narration: l.gdNarr5,
        child: const Expanded(child: KnowledgeImprovementScreen()),
      ),
      5 => _LoopOverview(),
      _ => _Conclusion(),
    };
  }
}

/// Narration banner + embedded module (given via [child], usually Expanded).
class _Framed extends StatelessWidget {
  const _Framed({required this.narration, required this.child});

  final String narration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                size: 18,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  narration,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hub_rounded,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                l.gdWelcomeStatement,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l.gdWelcomeSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow),
                label: Text(l.gdStart),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
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

class _LoopOverview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final nodes = [
      l.gdLoop1,
      l.gdLoop2,
      l.gdLoop3,
      l.gdLoop4,
      l.gdLoop5,
      l.gdLoop6,
      l.gdLoop7,
      l.gdLoop8,
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.gdLoopTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.gdNarr6,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (var i = 0; i < nodes.length; i++) ...[
                    _LoopNode(label: nodes[i], index: i),
                    if (i < nodes.length - 1)
                      Icon(
                        Icons.arrow_right_alt,
                        color: theme.colorScheme.primary,
                      ),
                  ],
                  Icon(Icons.refresh, color: theme.colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoopNode extends StatelessWidget {
  const _LoopNode({required this.label, required this.index});

  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Conclusion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified,
                  size: 40,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  l.gdClosingTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                _ClosingLine(text: l.gdClosingLine1),
                const SizedBox(height: 8),
                _ClosingLine(text: l.gdClosingLine2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClosingLine extends StatelessWidget {
  const _ClosingLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle,
          size: 20,
          color: theme.colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
