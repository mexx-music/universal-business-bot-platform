import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class LandingHeroSection extends StatelessWidget {
  final VoidCallback onStartDemo;
  final VoidCallback onExplore;
  final VoidCallback onVision;

  const LandingHeroSection({
    super.key,
    required this.onStartDemo,
    required this.onExplore,
    required this.onVision,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 38),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF071526), Color(0xFF0A2239), Color(0xFF07131F)],
            ),
          ),
          child: CustomPaint(
            painter: const _NetworkBackdropPainter(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final twoColumn = constraints.maxWidth >= 940;
                  final copy = _HeroCopy(
                    compact: constraints.maxWidth < 560,
                    onStartDemo: onStartDemo,
                    onExplore: onExplore,
                    onVision: onVision,
                  );
                  const story = _KnowledgeStory();

                  if (!twoColumn) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [copy, const SizedBox(height: 34), story],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 10, child: copy),
                      const SizedBox(width: 44),
                      const Expanded(flex: 11, child: story),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  final bool compact;
  final VoidCallback onStartDemo;
  final VoidCallback onExplore;
  final VoidCallback onVision;

  const _HeroCopy({
    required this.compact,
    required this.onStartDemo,
    required this.onExplore,
    required this.onVision,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const cyan = Color(0xFF75D7FF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: cyan.withAlpha(20),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cyan.withAlpha(70)),
          ),
          child: Text(
            l.landingHeroEyebrow,
            style: theme.textTheme.labelLarge?.copyWith(
              color: cyan,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Semantics(
          header: true,
          child: Text(
            l.landingHeroTitle,
            style:
                (compact
                        ? theme.textTheme.displaySmall
                        : theme.textTheme.displayMedium)
                    ?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                      height: 1.03,
                    ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l.landingHeroPromise,
          style: theme.textTheme.titleLarge?.copyWith(
            color: cyan,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 610),
          child: Text(
            l.landingHeroSubtitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: const Color(0xFFD5E5F1),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 28),
        _HeroActions(
          compact: compact,
          onStartDemo: onStartDemo,
          onExplore: onExplore,
          onVision: onVision,
        ),
      ],
    );
  }
}

class _HeroActions extends StatelessWidget {
  final bool compact;
  final VoidCallback onStartDemo;
  final VoidCallback onExplore;
  final VoidCallback onVision;

  const _HeroActions({
    required this.compact,
    required this.onStartDemo,
    required this.onExplore,
    required this.onVision,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    const cyan = Color(0xFF75D7FF);
    final minimum = Size(compact ? double.infinity : 0, 52);
    final buttons = <Widget>[
      FilledButton.icon(
        key: const Key('landing-start-demo'),
        onPressed: onStartDemo,
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(l.demoStartButton),
        style: FilledButton.styleFrom(
          backgroundColor: cyan,
          foregroundColor: const Color(0xFF061624),
          minimumSize: minimum,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      OutlinedButton.icon(
        key: const Key('landing-explore-platform'),
        onPressed: onExplore,
        icon: const Icon(Icons.explore_outlined),
        label: Text(l.landingLearnMoreButton),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF7A95AA)),
          minimumSize: minimum,
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
      ),
      TextButton.icon(
        key: const Key('landing-explore-vision'),
        onPressed: onVision,
        icon: const Icon(Icons.hub_outlined),
        label: Text(l.landingVisionButton),
        style: TextButton.styleFrom(
          foregroundColor: cyan,
          minimumSize: minimum,
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
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
    return Wrap(spacing: 10, runSpacing: 10, children: buttons);
  }
}

class _KnowledgeStory extends StatelessWidget {
  const _KnowledgeStory();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 570;
        final input = _StoryNode(
          icon: Icons.domain_outlined,
          title: l.landingHeroInputTitle,
          text: l.landingHeroInputItems,
        );
        final brain = _BrainNode(text: l.landingHeroCoreText);
        final output = _StoryNode(
          icon: Icons.route_outlined,
          title: l.landingHeroOutputTitle,
          text: l.landingHeroOutputItems,
        );

        return Semantics(
          container: true,
          label:
              '${l.landingHeroInputTitle}, BusinessBrain, '
              '${l.landingHeroOutputTitle}',
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D263B).withAlpha(225),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFF75D7FF).withAlpha(58)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2600B8FF),
                  blurRadius: 32,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              children: [
                if (horizontal)
                  Row(
                    children: [
                      Expanded(child: input),
                      const _StoryArrow(horizontal: true),
                      Expanded(child: brain),
                      const _StoryArrow(horizontal: true),
                      Expanded(child: output),
                    ],
                  )
                else
                  Column(
                    children: [
                      input,
                      const _StoryArrow(horizontal: false),
                      brain,
                      const _StoryArrow(horizontal: false),
                      output,
                    ],
                  ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF75D7FF).withAlpha(18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF75D7FF).withAlpha(45),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 19,
                        color: Color(0xFF75D7FF),
                      ),
                      const SizedBox(width: 9),
                      Flexible(
                        child: Text(
                          l.landingHeroHumanControl,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: const Color(0xFFDCECF6),
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StoryNode extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _StoryNode({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFA8C3D5), size: 30),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFFADC3D2),
              height: 1.38,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrainNode extends StatelessWidget {
  final String text;

  const _BrainNode({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF154C6C), Color(0xFF0D3450)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF75D7FF).withAlpha(125)),
        boxShadow: const [BoxShadow(color: Color(0x3300B8FF), blurRadius: 22)],
      ),
      child: Column(
        children: [
          const Icon(Icons.hub_rounded, color: Color(0xFF75D7FF), size: 38),
          const SizedBox(height: 9),
          Text(
            'BusinessBrain',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFFD8EAF5),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryArrow extends StatelessWidget {
  final bool horizontal;

  const _StoryArrow({required this.horizontal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal ? 8 : 0,
        vertical: horizontal ? 0 : 8,
      ),
      child: Icon(
        horizontal ? Icons.arrow_forward_rounded : Icons.arrow_downward_rounded,
        color: const Color(0xFF75D7FF),
        size: 25,
      ),
    );
  }
}

class _NetworkBackdropPainter extends CustomPainter {
  const _NetworkBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = const Color(0xFF58C9F5).withAlpha(20)
      ..strokeWidth = 1;
    final glow = Paint()..color = const Color(0xFF82DDFF).withAlpha(55);
    final points = <Offset>[
      Offset(size.width * .05, size.height * .2),
      Offset(size.width * .24, size.height * .08),
      Offset(size.width * .43, size.height * .26),
      Offset(size.width * .66, size.height * .1),
      Offset(size.width * .92, size.height * .24),
      Offset(size.width * .12, size.height * .82),
      Offset(size.width * .36, size.height * .68),
      Offset(size.width * .64, size.height * .86),
      Offset(size.width * .9, size.height * .72),
    ];
    const connections = <(int, int)>[
      (0, 1),
      (1, 2),
      (2, 3),
      (3, 4),
      (0, 5),
      (5, 6),
      (2, 6),
      (6, 7),
      (3, 7),
      (7, 8),
      (4, 8),
    ];
    for (final connection in connections) {
      canvas.drawLine(points[connection.$1], points[connection.$2], line);
    }
    for (final point in points) {
      canvas.drawCircle(point, 2.2, glow);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
