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

  ({String title, String intro, Widget? child}) _stepData(AppLocalizations l) {
    return switch (_step) {
      0 => (
        title: l.juryStep1Title,
        intro: l.juryStep1Intro,
        child: const BusinessStoryScreen(),
      ),
      1 => (
        title: l.juryStep2Title,
        intro: l.juryStep2Intro,
        child: const OperationsDashboardScreen(),
      ),
      2 => (
        title: l.juryStep3Title,
        intro: l.juryStep3Intro,
        child: const GuidedDemoScreen(),
      ),
      3 => (
        title: l.juryStep4Title,
        intro: l.juryStep4Intro,
        child: const SingleChildScrollView(child: GroundedAnswerPanel()),
      ),
      4 => (
        title: l.juryStep5Title,
        intro: l.juryStep5Intro,
        child: const KnowledgeWorkflowScreen(),
      ),
      _ => (title: l.juryStep6Title, intro: '', child: null),
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
                    '${l.kiStep} ${_step + 1} / ${JuryTourScreen.stepCount}',
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
            _IntroBanner(title: data.title, intro: data.intro),
            Expanded(child: data.child ?? _ClosingView()),
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
  const _IntroBanner({required this.title, required this.intro});

  final String title;
  final String intro;

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
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  intro,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
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
                  Icons.emoji_events_outlined,
                  size: 44,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  l.juryClosingTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l.juryClosingBody,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
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
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: Text(l.juryBack),
          ),
          const Spacer(),
          if (onNext != null)
            FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(l.juryNext),
            )
          else if (onFinish != null)
            FilledButton.icon(
              onPressed: onFinish,
              icon: const Icon(Icons.check, size: 18),
              label: Text(l.juryFinish),
            ),
        ],
      ),
    );
  }
}
