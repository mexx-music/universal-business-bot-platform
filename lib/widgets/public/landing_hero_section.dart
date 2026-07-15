import 'dart:async';

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
      padding: const EdgeInsets.only(top: 14, bottom: 48),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 620),
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
            final width = constraints.maxWidth;
            final twoColumn = width >= 860;
            final copy = _HeroCopy(
              onLearnMore: onLearnMore,
              onDemo: onDemo,
              onContact: onContact,
            );
            const visual = _HeroIllustration();

            if (!twoColumn) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [copy, const SizedBox(height: 30), visual],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 10, child: copy),
                const SizedBox(width: 48),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(42),
                  ),
                ),
                child: Text(
                  l.landingHeroEyebrow,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l.landingHeroTitle,
                style:
                    (compact
                            ? theme.textTheme.displaySmall
                            : theme.textTheme.displayMedium)
                        ?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                          height: 1.03,
                        ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  l.landingHeroSubtitle,
                  style:
                      (compact
                              ? theme.textTheme.titleSmall
                              : theme.textTheme.titleMedium)
                          ?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.48,
                          ),
                ),
              ),
              const SizedBox(height: 30),
              _HeroActions(
                compact: compact,
                onLearnMore: onLearnMore,
                onDemo: onDemo,
                onContact: onContact,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroActions extends StatelessWidget {
  final bool compact;
  final VoidCallback onLearnMore;
  final VoidCallback onDemo;
  final VoidCallback onContact;

  const _HeroActions({
    required this.compact,
    required this.onLearnMore,
    required this.onDemo,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final buttons = [
      FilledButton.icon(
        onPressed: onLearnMore,
        icon: const Icon(Icons.arrow_downward_rounded),
        label: Text(l.landingLearnMoreButton),
        style: FilledButton.styleFrom(
          minimumSize: Size(compact ? double.infinity : 0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 22),
        ),
      ),
      OutlinedButton.icon(
        onPressed: onDemo,
        icon: const Icon(Icons.play_circle_outline_rounded),
        label: Text(l.landingDemoButton),
        style: OutlinedButton.styleFrom(
          minimumSize: Size(compact ? double.infinity : 0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      TextButton(
        onPressed: onContact,
        style: TextButton.styleFrom(
          minimumSize: Size(compact ? double.infinity : 0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(l.landingContactButton),
      ),
    ];

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < buttons.length; index++) ...[
            buttons[index],
            if (index < buttons.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }

    return Wrap(spacing: 12, runSpacing: 12, children: buttons);
  }
}

class _HeroIllustration extends StatefulWidget {
  const _HeroIllustration();

  @override
  State<_HeroIllustration> createState() => _HeroIllustrationState();
}

class _HeroIllustrationState extends State<_HeroIllustration> {
  int _activeIndex = 2;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _activeIndex = (_activeIndex + 1) % 5);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = [
      _FlowItem(Icons.apartment_rounded, l.landingHeroFlowCompany),
      _FlowItem(Icons.menu_book_rounded, l.landingHeroFlowKnowledge),
      _FlowItem(Icons.auto_awesome_rounded, l.landingHeroFlowBot),
      _FlowItem(Icons.campaign_rounded, l.landingHeroFlowMarketing),
      _FlowItem(Icons.query_stats_rounded, l.landingHeroFlowControlling),
    ];

    return MouseRegion(
      onExit: (_) => setState(() => _activeIndex = 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withAlpha(242),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withAlpha(26),
              blurRadius: 40,
              offset: const Offset(0, 24),
            ),
            BoxShadow(
              color: theme.colorScheme.shadow.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IllustrationTopBar(compact: compact),
                const SizedBox(height: 18),
                for (var index = 0; index < items.length; index++) ...[
                  _FlowNode(
                    item: items[index],
                    active: index == _activeIndex,
                    compact: compact,
                    onHover: () => setState(() => _activeIndex = index),
                  ),
                  if (index < items.length - 1)
                    _Connector(active: index == _activeIndex - 1),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _IllustrationTopBar extends StatelessWidget {
  final bool compact;

  const _IllustrationTopBar({required this.compact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        for (final color in [
          theme.colorScheme.primary,
          theme.colorScheme.tertiary,
          theme.colorScheme.secondary,
        ]) ...[
          Container(
            width: compact ? 8 : 10,
            height: compact ? 8 : 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
        ],
        const Spacer(),
        Container(
          width: compact ? 84 : 118,
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.outlineVariant.withAlpha(140),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _FlowNode extends StatelessWidget {
  final _FlowItem item;
  final bool active;
  final bool compact;
  final VoidCallback onHover;

  const _FlowNode({
    required this.item,
    required this.active,
    required this.compact,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => onHover(),
      child: AnimatedScale(
        scale: active ? 1.025 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 18,
            vertical: compact ? 13 : 16,
          ),
          decoration: BoxDecoration(
            color: active
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              if (active)
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(38),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: compact ? 38 : 44,
                height: compact ? 38 : 44,
                decoration: BoxDecoration(
                  color: active
                      ? theme.colorScheme.onPrimary.withAlpha(28)
                      : theme.colorScheme.primary.withAlpha(16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.icon,
                  color: active
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                  size: compact ? 21 : 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: active
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: active
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  final bool active;

  const _Connector({required this.active});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 3,
      height: 18,
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.primary
            : theme.colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _FlowItem {
  final IconData icon;
  final String label;

  const _FlowItem(this.icon, this.label);
}
