import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../jury/jury_mode_controller.dart';
import '../../l10n/app_localizations.dart';
import '../bot_test/grounded_answer_panel.dart';
import '../business_story/business_story_screen.dart';
import '../guided_demo/guided_demo_screen.dart';
import '../knowledge_workflow/knowledge_workflow_screen.dart';
import '../operations/operations_dashboard_screen.dart';

/// Guided Jury Demo (BLOCK 9). Walks a visitor through the most important
/// existing areas in a fixed order with short intro texts, so no developer
/// explanation is needed. It only embeds existing screens — no new logic.
class JuryTourScreen extends StatefulWidget {
  const JuryTourScreen({super.key});

  static const int stepCount = 6;

  @override
  State<JuryTourScreen> createState() => _JuryTourScreenState();
}

class _JuryTourScreenState extends State<JuryTourScreen> {
  int _step = 0;

  @override
  void initState() {
    super.initState();
    // Entering the tour puts the app into jury mode (simplified navigation).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) JuryModeController.maybeOf(context)?.enable();
    });
  }

  void _go(int i) =>
      setState(() => _step = i.clamp(0, JuryTourScreen.stepCount - 1));

  ({String title, String intro, String transition, Widget? child}) _stepData(
    AppLocalizations l,
  ) {
    return switch (_step) {
      0 => (
        title: l.juryStep1Title,
        intro: l.juryStep1Intro,
        transition: l.juryTrans1,
        child: const BusinessStoryScreen(),
      ),
      1 => (
        title: l.juryStep2Title,
        intro: l.juryStep2Intro,
        transition: l.juryTrans2,
        child: const OperationsDashboardScreen(),
      ),
      2 => (
        title: l.juryStep3Title,
        intro: l.juryStep3Intro,
        transition: l.juryTrans3,
        child: const GuidedDemoScreen(),
      ),
      3 => (
        title: l.juryStep4Title,
        intro: l.juryStep4Intro,
        transition: l.juryTrans4,
        child: const SingleChildScrollView(child: GroundedAnswerPanel()),
      ),
      4 => (
        title: l.juryStep5Title,
        intro: l.juryStep5Intro,
        transition: l.juryTrans5,
        child: const KnowledgeWorkflowScreen(),
      ),
      _ => (title: l.juryStep6Title, intro: '', transition: '', child: null),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = _stepData(l);
    final isLast = _step == JuryTourScreen.stepCount - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  Icon(Icons.slideshow, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.juryTourTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${l.kiStep} ${_step + 1} ${l.juryOf} ${JuryTourScreen.stepCount}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      JuryModeController.maybeOf(context)?.disable();
                      context.go('/');
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(l.juryExit),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (_step + 1) / JuryTourScreen.stepCount,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _IntroBanner(
              title: data.title,
              intro: data.intro,
              transition: data.transition,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: data.child ?? _ClosingView(),
                ),
              ),
            ),
            _Controls(
              onBack: _step == 0 ? null : () => _go(_step - 1),
              onNext: isLast ? null : () => _go(_step + 1),
              onFinish: isLast ? () => context.go('/business-story') : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroBanner extends StatelessWidget {
  const _IntroBanner({
    required this.title,
    required this.intro,
    required this.transition,
  });

  final String title;
  final String intro;
  final String transition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (intro.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Soft, high-quality station transition line (fades per step).
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    transition,
                    key: ValueKey(transition),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$title · $intro',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    height: 1.3,
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

class _ClosingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final seen = [
      l.oxSeen1,
      l.oxSeen2,
      l.oxSeen3,
      l.oxSeen4,
      l.oxSeen5,
      l.oxSeen6,
      l.oxSeen7,
    ];
    final links = [
      (Icons.qr_code_2, l.oxLinkProject),
      (Icons.code, l.oxLinkGithub),
      (Icons.play_circle_outline, l.oxLinkVideo),
      (Icons.description_outlined, l.oxLinkDocs),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
                      Icons.emoji_events_outlined,
                      size: 44,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.oxClosingTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l.oxClosingSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.45,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l.oxSeenTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final s in seen) _SeenChip(label: s)],
              ),
              const SizedBox(height: 20),
              Text(
                l.oxThanks,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final link in links)
                    Chip(avatar: Icon(link.$1, size: 18), label: Text(link.$2)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeenChip extends StatelessWidget {
  const _SeenChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withAlpha(120)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 15, color: Colors.green),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.onBack,
    required this.onNext,
    required this.onFinish,
  });

  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          OutlinedButton.icon(
            key: const Key('jury-back'),
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: Text(l.juryBack),
          ),
          const Spacer(),
          if (onNext != null)
            FilledButton.icon(
              key: const Key('jury-next'),
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(l.juryNext),
            )
          else if (onFinish != null)
            FilledButton.icon(
              key: const Key('jury-finish'),
              onPressed: onFinish,
              icon: const Icon(Icons.check, size: 18),
              label: Text(l.juryFinish),
            ),
        ],
      ),
    );
  }
}
