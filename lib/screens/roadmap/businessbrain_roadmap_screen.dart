import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../roadmap/businessbrain_roadmap.dart';
import '../../widgets/language_switcher.dart';

/// Public, presentation-only roadmap. It visualises product direction without
/// activating, simulating or claiming any future capability.
class BusinessBrainRoadmapScreen extends StatefulWidget {
  const BusinessBrainRoadmapScreen({super.key});

  @override
  State<BusinessBrainRoadmapScreen> createState() =>
      _BusinessBrainRoadmapScreenState();
}

class _BusinessBrainRoadmapScreenState
    extends State<BusinessBrainRoadmapScreen> {
  RoadmapStageId _selected = RoadmapStageId.verifiedCompanyKnowledge;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final wideAppBar = MediaQuery.sizeOf(context).width >= 680;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withAlpha(245),
        title: Text(l.navBusinessBrainRoadmap),
        leading: IconButton(
          tooltip: l.roadmapBack,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          if (wideAppBar)
            TextButton.icon(
              key: const Key('roadmap-open-vision'),
              onPressed: () => context.go('/vision'),
              icon: const Icon(Icons.auto_awesome_outlined, size: 18),
              label: Text(l.navBusinessBrainVision),
            )
          else
            IconButton(
              key: const Key('roadmap-open-vision'),
              tooltip: l.navBusinessBrainVision,
              onPressed: () => context.go('/vision'),
              icon: const Icon(Icons.auto_awesome_outlined),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LanguageSwitcher(compact: true),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withAlpha(70),
              theme.colorScheme.surface,
              theme.colorScheme.surface,
            ],
            stops: const [0, 0.2, 1],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _RoadmapHero(),
                  const SizedBox(height: 32),
                  _SectionHeading(
                    icon: Icons.route_outlined,
                    title: l.roadmapJourneyTitle,
                    body: l.roadmapJourneyBody,
                  ),
                  const SizedBox(height: 18),
                  _RoadmapJourney(
                    selected: _selected,
                    onSelected: (stage) => setState(() => _selected = stage),
                  ),
                  const SizedBox(height: 38),
                  const _RoadmapClosing(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoadmapHero extends StatelessWidget {
  const _RoadmapHero();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: const Key('roadmap-hero'),
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _StatusBadge(status: RoadmapStageStatus.available),
                  _StatusBadge(status: RoadmapStageStatus.vision),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                l.roadmapHeroTitle,
                style:
                    (compact
                            ? theme.textTheme.headlineMedium
                            : theme.textTheme.displaySmall)
                        ?.copyWith(fontWeight: FontWeight.w900, height: 1.08),
              ),
              const SizedBox(height: 12),
              Text(
                l.roadmapHeroBody,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              _ControlStatement(text: l.roadmapHeroControl),
            ],
          );
          const visual = _RoadmapVisual();
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [copy, const SizedBox(height: 22), visual],
            );
          }
          return Row(
            children: [
              Expanded(flex: 3, child: copy),
              const SizedBox(width: 30),
              const Expanded(flex: 2, child: visual),
            ],
          );
        },
      ),
    );
  }
}

class _RoadmapVisual extends StatelessWidget {
  const _RoadmapVisual();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    return Container(
      constraints: const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              _VisualNode(
                icon: Icons.verified_outlined,
                label: l.roadmapVisualKnowledge,
                active: true,
              ),
              const _VisualConnector(),
              _VisualNode(
                icon: Icons.insights_outlined,
                label: l.roadmapVisualIntelligence,
              ),
              const _VisualConnector(),
              _VisualNode(
                icon: Icons.hub_outlined,
                label: l.roadmapVisualBrain,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l.roadmapVisualCaption,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualNode extends StatelessWidget {
  const _VisualNode({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: active
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Icon(
              icon,
              color: active
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualConnector extends StatelessWidget {
  const _VisualConnector();

  @override
  Widget build(BuildContext context) => Expanded(
    child: Divider(
      thickness: 2,
      color: Theme.of(context).colorScheme.primary.withAlpha(100),
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoadmapJourney extends StatelessWidget {
  const _RoadmapJourney({required this.selected, required this.onSelected});

  final RoadmapStageId selected;
  final ValueChanged<RoadmapStageId> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 1040;
        if (horizontal) {
          return Column(
            children: [
              SizedBox(
                height: 272,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (
                      var index = 0;
                      index < businessBrainRoadmap.length;
                      index++
                    ) ...[
                      Expanded(
                        child: _StageNode(
                          definition: businessBrainRoadmap[index],
                          index: index,
                          selected: businessBrainRoadmap[index].id == selected,
                          horizontal: true,
                          onTap: () =>
                              onSelected(businessBrainRoadmap[index].id),
                        ),
                      ),
                      if (index < businessBrainRoadmap.length - 1)
                        const _HorizontalStageConnector(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _AnimatedStageDetail(selected: selected),
            ],
          );
        }

        return Column(
          children: [
            for (
              var index = 0;
              index < businessBrainRoadmap.length;
              index++
            ) ...[
              _StageNode(
                definition: businessBrainRoadmap[index],
                index: index,
                selected: businessBrainRoadmap[index].id == selected,
                horizontal: false,
                onTap: () => onSelected(businessBrainRoadmap[index].id),
              ),
              if (businessBrainRoadmap[index].id == selected) ...[
                const SizedBox(height: 10),
                _AnimatedStageDetail(selected: selected),
              ],
              if (index < businessBrainRoadmap.length - 1)
                const _VerticalStageConnector(),
            ],
          ],
        );
      },
    );
  }
}

class _HorizontalStageConnector extends StatelessWidget {
  const _HorizontalStageConnector();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 16,
    child: Divider(
      thickness: 2,
      color: Theme.of(context).colorScheme.outlineVariant,
    ),
  );
}

class _VerticalStageConnector extends StatelessWidget {
  const _VerticalStageConnector();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(left: 25),
      width: 2,
      height: 18,
      color: Theme.of(context).colorScheme.outlineVariant,
    ),
  );
}

class _StageNode extends StatelessWidget {
  const _StageNode({
    required this.definition,
    required this.index,
    required this.selected,
    required this.horizontal,
    required this.onTap,
  });

  final RoadmapStageDefinition definition;
  final int index;
  final bool selected;
  final bool horizontal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = _stageContent(AppLocalizations.of(context)!, definition.id);
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;
    return Semantics(
      button: true,
      selected: selected,
      label: '${index + 1}. ${content.title}',
      child: AnimatedContainer(
        key: ValueKey('roadmap-stage-${definition.id.name}'),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: horizontal ? 260 : null,
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer.withAlpha(105)
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: horizontal
                  ? _HorizontalNodeContent(
                      definition: definition,
                      index: index,
                      title: content.title,
                      description: content.description,
                      selected: selected,
                    )
                  : _VerticalNodeContent(
                      definition: definition,
                      index: index,
                      title: content.title,
                      description: content.description,
                      selected: selected,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HorizontalNodeContent extends StatelessWidget {
  const _HorizontalNodeContent({
    required this.definition,
    required this.index,
    required this.title,
    required this.description,
    required this.selected,
  });

  final RoadmapStageDefinition definition;
  final int index;
  final String title;
  final String description;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StageIcon(icon: definition.icon, index: index, selected: selected),
            const Spacer(),
            Icon(
              selected ? Icons.expand_more : Icons.touch_app_outlined,
              size: 17,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        const SizedBox(height: 10),
        _StatusBadge(status: definition.status, compact: true),
        if (definition.nextExpansion) ...[
          const SizedBox(height: 5),
          const _NextBadge(),
        ],
        const SizedBox(height: 9),
        Text(
          title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Text(
            description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _VerticalNodeContent extends StatelessWidget {
  const _VerticalNodeContent({
    required this.definition,
    required this.index,
    required this.title,
    required this.description,
    required this.selected,
  });

  final RoadmapStageDefinition definition;
  final int index;
  final String title;
  final String description;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StageIcon(icon: definition.icon, index: index, selected: selected),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _StatusBadge(status: definition.status, compact: true),
                  if (definition.nextExpansion) const _NextBadge(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          selected ? Icons.expand_less : Icons.expand_more,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}

class _StageIcon extends StatelessWidget {
  const _StageIcon({
    required this.icon,
    required this.index,
    required this.selected,
  });

  final IconData icon;
  final int index;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerLowest,
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Icon(
            icon,
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
          ),
        ),
        Positioned(
          right: -3,
          bottom: -3,
          child: Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.surface),
            ),
            child: Text(
              '${index + 1}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedStageDetail extends StatelessWidget {
  const _AnimatedStageDetail({required this.selected});

  final RoadmapStageId selected;

  @override
  Widget build(BuildContext context) {
    final definition = businessBrainRoadmap.firstWhere(
      (stage) => stage.id == selected,
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _StageDetailCard(
        key: ValueKey('roadmap-detail-${selected.name}'),
        definition: definition,
      ),
    );
  }
}

class _StageDetailCard extends StatelessWidget {
  const _StageDetailCard({super.key, required this.definition});

  final RoadmapStageDefinition definition;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final content = _stageContent(l, definition.id);
    final available = definition.status == RoadmapStageStatus.available;
    return Card(
      elevation: 0,
      color: available
          ? theme.colorScheme.primaryContainer.withAlpha(110)
          : theme.colorScheme.tertiaryContainer.withAlpha(95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: available
              ? theme.colorScheme.primary.withAlpha(150)
              : theme.colorScheme.tertiary.withAlpha(140),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  definition.icon,
                  color: available
                      ? theme.colorScheme.primary
                      : theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: definition.status),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final benefits = _DetailSection(
                  icon: Icons.trending_up_outlined,
                  title: l.roadmapBenefitTitle,
                  body: content.benefit,
                );
                final control = _DetailSection(
                  icon: Icons.how_to_reg_outlined,
                  title: l.roadmapControlTitle,
                  body: content.control,
                );
                if (constraints.maxWidth < 720) {
                  return Column(
                    children: [benefits, const SizedBox(height: 12), control],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: benefits),
                    const SizedBox(width: 12),
                    Expanded(child: control),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              l.roadmapExamplesTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final feature in definition.featureKeys)
                  Chip(
                    avatar: Icon(
                      available
                          ? Icons.check_circle_outline
                          : Icons.visibility_outlined,
                      size: 17,
                    ),
                    label: Text(_featureLabel(l, feature)),
                  ),
              ],
            ),
            if (!available) ...[
              const SizedBox(height: 14),
              _ControlStatement(text: l.roadmapVisionDisclaimer),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
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
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(190),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, this.compact = false});

  final RoadmapStageStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final available = status == RoadmapStageStatus.available;
    final background = available
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.tertiaryContainer;
    final foreground = available
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onTertiaryContainer;
    return Container(
      key: ValueKey(
        available ? 'roadmap-status-available' : 'roadmap-status-vision',
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foreground.withAlpha(65)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            available ? Icons.check_circle_outline : Icons.visibility_outlined,
            size: compact ? 13 : 15,
            color: foreground,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              available ? l.roadmapAvailableBadge : l.roadmapVisionBadge,
              textAlign: TextAlign.center,
              style:
                  (compact
                          ? theme.textTheme.labelSmall
                          : theme.textTheme.labelMedium)
                      ?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.bold,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextBadge extends StatelessWidget {
  const _NextBadge();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: const Key('roadmap-next-stage'),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l.roadmapNextStage,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ControlStatement extends StatelessWidget {
  const _ControlStatement({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(175),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapClosing extends StatelessWidget {
  const _RoadmapClosing();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final steps = [
      l.roadmapClosingKnowledge,
      l.roadmapClosingCustomers,
      l.roadmapClosingMarketing,
      l.roadmapClosingAnalysis,
      l.roadmapClosingBrain,
    ];
    return Container(
      key: const Key('roadmap-closing'),
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StatusBadge(status: RoadmapStageStatus.vision),
          const SizedBox(height: 14),
          Text(
            l.roadmapClosingTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.roadmapClosingBody,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var index = 0; index < steps.length; index++) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withAlpha(180),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    steps[index],
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (index < steps.length - 1)
                  Icon(
                    Icons.arrow_forward,
                    size: 17,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withAlpha(205),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.roadmapHumanTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l.roadmapHumanBody,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

({String title, String description, String benefit, String control})
_stageContent(AppLocalizations l, RoadmapStageId id) => switch (id) {
  RoadmapStageId.verifiedCompanyKnowledge => (
    title: l.roadmapStage1Title,
    description: l.roadmapStage1Description,
    benefit: l.roadmapStage1Benefit,
    control: l.roadmapStage1Control,
  ),
  RoadmapStageId.customerIntelligence => (
    title: l.roadmapStage2Title,
    description: l.roadmapStage2Description,
    benefit: l.roadmapStage2Benefit,
    control: l.roadmapStage2Control,
  ),
  RoadmapStageId.websiteIntelligence => (
    title: l.roadmapStage3Title,
    description: l.roadmapStage3Description,
    benefit: l.roadmapStage3Benefit,
    control: l.roadmapStage3Control,
  ),
  RoadmapStageId.marketingIntelligence => (
    title: l.roadmapStage4Title,
    description: l.roadmapStage4Description,
    benefit: l.roadmapStage4Benefit,
    control: l.roadmapStage4Control,
  ),
  RoadmapStageId.competitiveIntelligence => (
    title: l.roadmapStage5Title,
    description: l.roadmapStage5Description,
    benefit: l.roadmapStage5Benefit,
    control: l.roadmapStage5Control,
  ),
  RoadmapStageId.businessIntelligence => (
    title: l.roadmapStage6Title,
    description: l.roadmapStage6Description,
    benefit: l.roadmapStage6Benefit,
    control: l.roadmapStage6Control,
  ),
  RoadmapStageId.digitalBusinessBrain => (
    title: l.roadmapStage7Title,
    description: l.roadmapStage7Description,
    benefit: l.roadmapStage7Benefit,
    control: l.roadmapStage7Control,
  ),
};

String _featureLabel(AppLocalizations l, String key) => switch (key) {
  'knowledgeBuilder' => l.roadmapFeatureKnowledgeBuilder,
  'humanReview' => l.roadmapFeatureHumanReview,
  'groundedAnswers' => l.roadmapFeatureGroundedAnswers,
  'websiteLinks' => l.roadmapFeatureWebsiteLinks,
  'operationsCenter' => l.roadmapFeatureOperationsCenter,
  'frequentQuestions' => l.roadmapFeatureFrequentQuestions,
  'recurringProblems' => l.roadmapFeatureRecurringProblems,
  'productInterest' => l.roadmapFeatureProductInterest,
  'supportTrends' => l.roadmapFeatureSupportTrends,
  'faqSuggestions' => l.roadmapFeatureFaqSuggestions,
  'analyseWebsite' => l.roadmapFeatureAnalyseWebsite,
  'detectProductPages' => l.roadmapFeatureDetectProductPages,
  'detectDownloads' => l.roadmapFeatureDetectDownloads,
  'detectFaq' => l.roadmapFeatureDetectFaq,
  'detectKnowledgeGaps' => l.roadmapFeatureDetectKnowledgeGaps,
  'keepWebsiteCurrent' => l.roadmapFeatureKeepWebsiteCurrent,
  'improveLandingPage' => l.roadmapFeatureImproveLandingPage,
  'googleBusiness' => 'Google Business',
  'googleAds' => 'Google Ads',
  'facebook' => 'Facebook',
  'instagram' => 'Instagram',
  'linkedIn' => 'LinkedIn',
  'reddit' => 'Reddit',
  'youTube' => 'YouTube',
  'newsletter' => l.roadmapFeatureNewsletter,
  'marketingIdeas' => l.roadmapFeatureMarketingIdeas,
  'contentSuggestions' => l.roadmapFeatureContentSuggestions,
  'observeCompetitors' => l.roadmapFeatureObserveCompetitors,
  'detectPriceChanges' => l.roadmapFeatureDetectPriceChanges,
  'marketTrends' => l.roadmapFeatureMarketTrends,
  'newProducts' => l.roadmapFeatureNewProducts,
  'strengthsWeaknesses' => l.roadmapFeatureStrengthsWeaknesses,
  'customerProblems' => l.roadmapFeatureCustomerProblems,
  'productIdeas' => l.roadmapFeatureProductIdeas,
  'improvementSuggestions' => l.roadmapFeatureImprovementSuggestions,
  'salesOpportunities' => l.roadmapFeatureSalesOpportunities,
  'frequentObjections' => l.roadmapFeatureFrequentObjections,
  'recogniseConnections' => l.roadmapFeatureRecogniseConnections,
  'recommendPriorities' => l.roadmapFeatureRecommendPriorities,
  'prepareTasks' => l.roadmapFeaturePrepareTasks,
  'createReports' => l.roadmapFeatureCreateReports,
  'decisionBriefs' => l.roadmapFeatureDecisionBriefs,
  _ => key,
};
