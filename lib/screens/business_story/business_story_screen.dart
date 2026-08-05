import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Business Story (BLOCK 6): a credibility-focused page for entrepreneurs,
/// investors and jury members. Presentation only — no new features, no backend
/// or AI changes. It explains the problem, the solution, the loop, the concrete
/// benefits, the deliberate boundaries, the clearly-labelled future vision, and
/// a transparent status overview (available / in development / vision) so a jury
/// can immediately tell what is real today.
class BusinessStoryScreen extends StatelessWidget {
  const BusinessStoryScreen({super.key});

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
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.bsTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.bsSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ProblemSolution(),
                  const SizedBox(height: 24),
                  _CycleSection(),
                  const SizedBox(height: 24),
                  _BenefitsSection(),
                  const SizedBox(height: 24),
                  _ContrastSection(),
                  const SizedBox(height: 24),
                  _VisionSection(),
                  const SizedBox(height: 24),
                  _StatusSection(),
                  const SizedBox(height: 24),
                  _ClosingSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.color,
    this.onColor,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Color? color;
  final Color? onColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = color ?? theme.colorScheme.surfaceContainerHigh;
    final fg = onColor ?? theme.colorScheme.onSurface;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ProblemSolution extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    Widget body(String text) =>
        Text(text, style: theme.textTheme.bodyLarge?.copyWith(height: 1.45));
    return Column(
      children: [
        _SectionCard(
          icon: Icons.report_problem_outlined,
          title: l.bsProblemTitle,
          child: body(l.bsProblemBody),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.hub_outlined,
          title: l.bsSolutionTitle,
          child: body(l.bsSolutionBody),
        ),
      ],
    );
  }
}

class _CycleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Reuses the loop wording from the guided demo / improvement loop.
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
    return _SectionCard(
      icon: Icons.loop,
      title: l.bsCycleTitle,
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 0; i < nodes.length; i++) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                nodes[i],
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (i < nodes.length - 1)
              Icon(Icons.arrow_right_alt, color: theme.colorScheme.primary),
          ],
          Icon(Icons.refresh, color: theme.colorScheme.primary),
        ],
      ),
    );
  }
}

class _BenefitsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final benefits = <(IconData, String, String)>[
      (Icons.bolt_outlined, l.bsBenefit1Title, l.bsBenefit1Body),
      (Icons.verified_outlined, l.bsBenefit2Title, l.bsBenefit2Body),
      (Icons.hub_outlined, l.bsBenefit3Title, l.bsBenefit3Body),
      (Icons.groups_outlined, l.bsBenefit4Title, l.bsBenefit4Body),
      (Icons.trending_up, l.bsBenefit5Title, l.bsBenefit5Body),
      (Icons.description_outlined, l.bsBenefit6Title, l.bsBenefit6Body),
      (Icons.shield_outlined, l.bsBenefit7Title, l.bsBenefit7Body),
      (Icons.pan_tool_outlined, l.bsBenefit8Title, l.bsBenefit8Body),
    ];
    return _SectionCard(
      icon: Icons.star_outline,
      title: l.bsBenefitsTitle,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final b in benefits)
            _BenefitCard(icon: b.$1, title: b.$2, body: b.$3),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(body, style: theme.textTheme.bodySmall?.copyWith(height: 1.35)),
        ],
      ),
    );
  }
}

class _ContrastSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final not = _ContrastColumn(
      title: l.bsNotTitle,
      items: [l.bsNot1, l.bsNot2, l.bsNot3, l.bsNot4],
      positive: false,
    );
    final does = _ContrastColumn(
      title: l.bsDoesTitle,
      items: [l.bsDoes1, l.bsDoes2, l.bsDoes3, l.bsDoes4],
      positive: true,
    );
    return _SectionCard(
      icon: Icons.balance_outlined,
      title: l.bsContrastTitle,
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth >= 560) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: not),
                const SizedBox(width: 16),
                Expanded(child: does),
              ],
            );
          }
          return Column(children: [not, const SizedBox(height: 16), does]);
        },
      ),
    );
  }
}

class _ContrastColumn extends StatelessWidget {
  const _ContrastColumn({
    required this.title,
    required this.items,
    required this.positive,
  });

  final String title;
  final List<String> items;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = positive ? Colors.green : theme.colorScheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  positive ? Icons.check_circle_outline : Icons.block,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _VisionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = [
      l.bsVision1,
      l.bsVision2,
      l.bsVision3,
      l.bsVision4,
      l.bsVision5,
      l.bsVision6,
      l.bsVision7,
      l.bsVision8,
    ];
    return _SectionCard(
      icon: Icons.rocket_launch_outlined,
      title: l.bsVisionTitle,
      color: theme.colorScheme.tertiaryContainer,
      onColor: theme.colorScheme.onTertiaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '🔵 ${l.bsVisionBadge}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onTertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in items)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withAlpha(160),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.tertiary),
                  ),
                  child: Text(item, style: theme.textTheme.labelLarge),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _StatusCategory { available, inDev, vision }

class _StatusSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final available = [
      l.bsFeatKnowledgeBase,
      l.bsFeatGrounded,
      l.bsFeatGapDetection,
      l.bsFeatBuilder,
      l.bsFeatSuggestions,
      l.bsFeatLoop,
      l.bsFeatEvolution,
      l.bsFeatPortals,
      l.bsFeatI18n,
    ];
    final inDev = [
      l.bsFeatLiveGemini,
      l.bsFeatRoleEnforcement,
      l.bsFeatResearchLive,
      l.bsFeatCommunity,
    ];
    final vision = [
      l.bsVision1,
      l.bsVision2,
      l.bsVision3,
      l.bsVision4,
      l.bsVision5,
      l.bsVision6,
      l.bsVision7,
      l.bsVision8,
    ];
    return _SectionCard(
      icon: Icons.fact_check_outlined,
      title: l.bsStatusTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.bsStatusIntro,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _StatusGroup(
            label: '✅ ${l.bsStatusAvailable}',
            category: _StatusCategory.available,
            items: available,
          ),
          const SizedBox(height: 16),
          _StatusGroup(
            label: '🟡 ${l.bsStatusInDev}',
            category: _StatusCategory.inDev,
            items: inDev,
          ),
          const SizedBox(height: 16),
          _StatusGroup(
            label: '🔵 ${l.bsStatusVision}',
            category: _StatusCategory.vision,
            items: vision,
          ),
        ],
      ),
    );
  }
}

class _StatusGroup extends StatelessWidget {
  const _StatusGroup({
    required this.label,
    required this.category,
    required this.items,
  });

  final String label;
  final _StatusCategory category;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (category) {
      _StatusCategory.available => Colors.green,
      _StatusCategory.inDev => Colors.orange,
      _StatusCategory.vision => theme.colorScheme.tertiary,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(28),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withAlpha(120)),
                ),
                child: Text(
                  item,
                  style: theme.textTheme.labelMedium?.copyWith(height: 1.2),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ClosingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
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
            Icons.psychology_outlined,
            size: 40,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(height: 16),
          Text(
            l.bsClosingTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.bsClosingBody,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.45,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
