import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class LandingHeroSection extends StatelessWidget {
  final VoidCallback onLearnMore;
  final VoidCallback onDemo;
  final VoidCallback onContact;

  const LandingHeroSection({
    super.key,
    required this.onLearnMore,
    required this.onDemo,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 38),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final copy = _HeroCopy(
              onLearnMore: onLearnMore,
              onDemo: onDemo,
              onContact: onContact,
            );
            const visual = _HeroIllustration();

            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [copy, const SizedBox(height: 28), visual],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 11, child: copy),
                const SizedBox(width: 38),
                const Expanded(flex: 9, child: visual),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  final VoidCallback onLearnMore;
  final VoidCallback onDemo;
  final VoidCallback onContact;

  const _HeroCopy({
    required this.onLearnMore,
    required this.onDemo,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 660),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(35),
              ),
            ),
            child: Text(
              l.landingHeroEyebrow,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            l.landingHeroTitle,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              height: 1.04,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l.landingHeroSubtitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onLearnMore,
                icon: const Icon(Icons.arrow_downward_rounded),
                label: Text(l.landingLearnMoreButton),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onDemo,
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: Text(l.landingDemoButton),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
              ),
              TextButton(
                onPressed: onContact,
                child: Text(l.landingContactButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = [
      (Icons.business_outlined, l.landingHeroFlowCompany),
      (Icons.library_books_outlined, l.landingHeroFlowKnowledge),
      (Icons.smart_toy_outlined, l.landingHeroFlowBot),
      (Icons.campaign_outlined, l.landingHeroFlowMarketing),
      (Icons.query_stats_outlined, l.landingHeroFlowControlling),
    ];

    return AspectRatio(
      aspectRatio: 0.98,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withAlpha(230),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withAlpha(20),
              blurRadius: 34,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  _FlowNode(
                    icon: items[index].$1,
                    label: items[index].$2,
                    compact: compact,
                    emphasized: index == 2,
                  ),
                  if (index < items.length - 1)
                    Container(
                      width: 2,
                      height: compact ? 14 : 18,
                      color: theme.colorScheme.primary.withAlpha(80),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FlowNode extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool compact;
  final bool emphasized;

  const _FlowNode({
    required this.icon,
    required this.label,
    required this.compact,
    required this.emphasized,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = emphasized
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final foreground = emphasized
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 11 : 14,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: foreground, size: compact ? 20 : 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
