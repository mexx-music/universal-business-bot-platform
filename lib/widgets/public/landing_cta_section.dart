import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class LandingCtaSection extends StatelessWidget {
  final VoidCallback onDemo;
  final VoidCallback onExplore;
  final VoidCallback onVision;

  const LandingCtaSection({
    super.key,
    required this.onDemo,
    required this.onExplore,
    required this.onVision,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const cyan = Color(0xFF75D7FF);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 52),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A2136), Color(0xFF103C58)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cyan.withAlpha(70)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2400AEEF),
              blurRadius: 32,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.landingCtaTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l.landingCtaText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFFD2E4EF),
                    height: 1.42,
                  ),
                ),
              ],
            );
            final actions = _CtaActions(
              compact: compact,
              onDemo: onDemo,
              onExplore: onExplore,
              onVision: onVision,
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [copy, const SizedBox(height: 24), actions],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: copy),
                const SizedBox(width: 28),
                Flexible(child: actions),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CtaActions extends StatelessWidget {
  final bool compact;
  final VoidCallback onDemo;
  final VoidCallback onExplore;
  final VoidCallback onVision;

  const _CtaActions({
    required this.compact,
    required this.onDemo,
    required this.onExplore,
    required this.onVision,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    const cyan = Color(0xFF75D7FF);
    final minimum = Size(compact ? double.infinity : 0, 50);
    final actions = <Widget>[
      FilledButton.icon(
        key: const Key('landing-cta-demo'),
        onPressed: onDemo,
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(l.landingCtaButton),
        style: FilledButton.styleFrom(
          backgroundColor: cyan,
          foregroundColor: const Color(0xFF061624),
          minimumSize: minimum,
        ),
      ),
      OutlinedButton.icon(
        key: const Key('landing-cta-platform'),
        onPressed: onExplore,
        icon: const Icon(Icons.explore_outlined),
        label: Text(l.landingLearnMoreButton),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF7794A8)),
          minimumSize: minimum,
        ),
      ),
      TextButton.icon(
        key: const Key('landing-cta-vision'),
        onPressed: onVision,
        icon: const Icon(Icons.hub_outlined),
        label: Text(l.landingVisionButton),
        style: TextButton.styleFrom(
          foregroundColor: cyan,
          minimumSize: minimum,
        ),
      ),
    ];

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < actions.length; index++) ...[
            actions[index],
            if (index < actions.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: actions,
    );
  }
}
