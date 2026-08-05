import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../jury/jury_mode_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../navigation/platform_entry.dart';
import '../../widgets/language_switcher.dart';

/// Landing experience / first 60 seconds (BLOCK 10). A calm, high-quality entry
/// with the brand, a one-line positioning, a short description and two clear
/// actions, over a subtle (atmosphere-only) flow animation. Presentation only —
/// no new features, no AI/backend changes.
class JuryStartScreen extends StatefulWidget {
  const JuryStartScreen({super.key});

  @override
  State<JuryStartScreen> createState() => _JuryStartScreenState();
}

class _JuryStartScreenState extends State<JuryStartScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // One-shot (no repeat) so tests settle and motion stays calm.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _guided() {
    JuryModeController.maybeOf(context)?.enable();
    context.go('/jury-demo');
  }

  Future<void> _explore() => openFullPlatform(context);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: _FlowBackground(controller: _controller),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Align(
                        alignment: Alignment.centerRight,
                        child: LanguageSwitcher(compact: true),
                      ),
                      Icon(
                        Icons.hub_rounded,
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'BusinessBrain',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.heroSubtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l.heroBody,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _guided,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(l.heroStartDemo),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _explore,
                          icon: const Icon(Icons.explore_outlined),
                          label: Text(l.heroExplore),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Atmosphere-only background: the value chain fades in slowly, node by node.
class _FlowBackground extends StatelessWidget {
  const _FlowBackground({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final nodes = [
      l.heroFlow1,
      l.heroFlow2,
      l.heroFlow3,
      l.heroFlow4,
      l.heroFlow5,
      l.heroFlow6,
    ];
    return Opacity(
      opacity: 0.12,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < nodes.length; i++) ...[
                _FadeInNode(
                  controller: controller,
                  index: i,
                  total: nodes.length,
                  child: Text(
                    nodes[i],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (i < nodes.length - 1)
                  _FadeInNode(
                    controller: controller,
                    index: i,
                    total: nodes.length,
                    child: const Icon(Icons.arrow_downward, size: 18),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FadeInNode extends StatelessWidget {
  const _FadeInNode({
    required this.controller,
    required this.index,
    required this.total,
    required this.child,
  });

  final AnimationController controller;
  final int index;
  final int total;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = (index / total) * 0.7;
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start,
        (start + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: FadeTransition(opacity: anim, child: child),
    );
  }
}
