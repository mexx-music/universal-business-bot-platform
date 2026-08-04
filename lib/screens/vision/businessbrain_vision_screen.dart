import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/language_switcher.dart';

/// A presentation-only view of BusinessBrain's future direction.
///
/// Every future capability is explicitly marked as vision. The screen has no
/// state, services, AI calls, persistence, automation or domain mutations.
class BusinessBrainVisionScreen extends StatelessWidget {
  const BusinessBrainVisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withAlpha(245),
        title: Text(l.navBusinessBrainVision),
        leading: IconButton(
          tooltip: l.visionBack,
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
          IconButton(
            key: const Key('vision-open-roadmap'),
            tooltip: l.navBusinessBrainRoadmap,
            onPressed: () => context.go('/roadmap'),
            icon: const Icon(Icons.route_outlined),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LanguageSwitcher(compact: true),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withAlpha(76),
              theme.colorScheme.surface,
              theme.colorScheme.surface,
            ],
            stops: const [0, 0.22, 1],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _VisionHero(),
                  const SizedBox(height: 28),
                  const _TodayFoundation(),
                  const SizedBox(height: 42),
                  _SectionHeading(
                    icon: Icons.route_outlined,
                    title: l.visionJourneyTitle,
                    body: l.visionJourneyBody,
                  ),
                  const SizedBox(height: 18),
                  const _PhaseJourney(),
                  const SizedBox(height: 42),
                  _SectionHeading(
                    icon: Icons.account_tree_outlined,
                    title: l.visionFlowTitle,
                    body: l.visionFlowBody,
                  ),
                  const SizedBox(height: 18),
                  const _ProposalFlow(),
                  const SizedBox(height: 46),
                  _CapabilitySection(
                    icon: Icons.public_outlined,
                    title: l.visionPresenceTitle,
                    body: l.visionPresenceBody,
                    features: [
                      _VisionFeature(
                        Icons.language_outlined,
                        l.visionWebsiteTitle,
                        l.visionWebsiteBody,
                      ),
                      _VisionFeature(
                        Icons.search_outlined,
                        l.visionSeoTitle,
                        l.visionSeoBody,
                      ),
                      _VisionFeature(
                        Icons.travel_explore_outlined,
                        l.visionGoogleTitle,
                        l.visionGoogleBody,
                      ),
                      _VisionFeature(
                        Icons.share_outlined,
                        l.visionSocialTitle,
                        l.visionSocialBody,
                        platforms: const [
                          'Facebook',
                          'Instagram',
                          'Reddit',
                          'LinkedIn',
                          'YouTube',
                          'TikTok',
                        ],
                      ),
                      _VisionFeature(
                        Icons.reviews_outlined,
                        l.visionReputationTitle,
                        l.visionReputationBody,
                        platforms: const ['Google Business', 'Reviews'],
                      ),
                    ],
                  ),
                  const SizedBox(height: 46),
                  _CapabilitySection(
                    icon: Icons.forum_outlined,
                    title: l.visionCustomerTitle,
                    body: l.visionCustomerBody,
                    features: [
                      _VisionFeature(
                        Icons.mail_outline,
                        l.visionEmailTitle,
                        l.visionEmailBody,
                      ),
                      _VisionFeature(
                        Icons.question_answer_outlined,
                        l.visionQuestionsTitle,
                        l.visionQuestionsBody,
                      ),
                      _VisionFeature(
                        Icons.repeat_outlined,
                        l.visionProblemsTitle,
                        l.visionProblemsBody,
                      ),
                      _VisionFeature(
                        Icons.manage_search_outlined,
                        l.visionExternalGapsTitle,
                        l.visionExternalGapsBody,
                      ),
                    ],
                  ),
                  const SizedBox(height: 46),
                  _CapabilitySection(
                    icon: Icons.radar_outlined,
                    title: l.visionMarketTitle,
                    body: l.visionMarketBody,
                    features: [
                      _VisionFeature(
                        Icons.compare_arrows_outlined,
                        l.visionCompetitorsTitle,
                        l.visionCompetitorsBody,
                      ),
                      _VisionFeature(
                        Icons.trending_up_outlined,
                        l.visionTrendsTitle,
                        l.visionTrendsBody,
                      ),
                      _VisionFeature(
                        Icons.new_releases_outlined,
                        l.visionProductsTitle,
                        l.visionProductsBody,
                      ),
                    ],
                  ),
                  const SizedBox(height: 46),
                  _CapabilitySection(
                    icon: Icons.lightbulb_outline,
                    title: l.visionProposalsTitle,
                    body: l.visionProposalsBody,
                    features: [
                      _VisionFeature(
                        Icons.quiz_outlined,
                        l.visionFaqTitle,
                        l.visionFaqBody,
                      ),
                      _VisionFeature(
                        Icons.description_outlined,
                        l.visionDocsTitle,
                        l.visionDocsBody,
                      ),
                      _VisionFeature(
                        Icons.web_outlined,
                        l.visionLandingTitle,
                        l.visionLandingBody,
                      ),
                      _VisionFeature(
                        Icons.campaign_outlined,
                        l.visionCampaignTitle,
                        l.visionCampaignBody,
                      ),
                      _VisionFeature(
                        Icons.assignment_outlined,
                        l.visionTasksTitle,
                        l.visionTasksBody,
                      ),
                      _VisionFeature(
                        Icons.low_priority_outlined,
                        l.visionPriorityTitle,
                        l.visionPriorityBody,
                      ),
                    ],
                  ),
                  const SizedBox(height: 46),
                  const _BriefingVision(),
                  const SizedBox(height: 32),
                  const _HumanControlSection(),
                  const SizedBox(height: 32),
                  const _VisionClosing(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VisionHero extends StatelessWidget {
  const _VisionHero();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _VisionBadge(label: l.visionBadge),
                  _SoftBadge(
                    icon: Icons.schedule_outlined,
                    label: l.visionFutureLabel,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l.visionHeroTitle,
                style:
                    (compact
                            ? theme.textTheme.headlineMedium
                            : theme.textTheme.displaySmall)
                        ?.copyWith(fontWeight: FontWeight.w900, height: 1.08),
              ),
              const SizedBox(height: 14),
              Text(
                l.visionHeroBody,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          );
          const visual = _BrainOrbit();

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [copy, const SizedBox(height: 24), visual],
            );
          }
          return Row(
            children: [
              Expanded(flex: 3, child: copy),
              const SizedBox(width: 36),
              const Expanded(flex: 2, child: visual),
            ],
          );
        },
      ),
    );
  }
}

class _BrainOrbit extends StatelessWidget {
  const _BrainOrbit();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const nodes = [
      Icons.language,
      Icons.search,
      Icons.forum,
      Icons.trending_up,
    ];
    return AspectRatio(
      aspectRatio: 1.35,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(70),
                width: 2,
              ),
            ),
          ),
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(65),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Icon(
              Icons.hub_rounded,
              size: 54,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          for (var i = 0; i < nodes.length; i++)
            Align(
              alignment: switch (i) {
                0 => Alignment.topCenter,
                1 => Alignment.centerRight,
                2 => Alignment.bottomCenter,
                _ => Alignment.centerLeft,
              },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.surface,
                child: Icon(nodes[i], color: theme.colorScheme.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class _TodayFoundation extends StatelessWidget {
  const _TodayFoundation();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withAlpha(90)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_outlined, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TodayBadge(label: l.visionTodayLabel),
                const SizedBox(height: 8),
                Text(
                  l.visionTodayTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.visionTodayBody,
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 14),
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
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhaseJourney extends StatelessWidget {
  const _PhaseJourney();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final phases = [
      _PhaseData(
        l.visionPhase1Eyebrow,
        l.visionPhase1Title,
        l.visionPhase1Body,
        Icons.menu_book_outlined,
        false,
      ),
      _PhaseData(
        l.visionPhase2Eyebrow,
        l.visionPhase2Title,
        l.visionPhase2Body,
        Icons.assistant_outlined,
        true,
      ),
      _PhaseData(
        l.visionPhase3Eyebrow,
        l.visionPhase3Title,
        l.visionPhase3Body,
        Icons.hub_outlined,
        true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 760;
        if (!horizontal) {
          return Column(
            children: [
              for (var i = 0; i < phases.length; i++) ...[
                _PhaseCard(data: phases[i]),
                if (i < phases.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Icon(Icons.arrow_downward),
                  ),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < phases.length; i++) ...[
              Expanded(child: _PhaseCard(data: phases[i])),
              if (i < phases.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.arrow_forward),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _PhaseData {
  const _PhaseData(this.eyebrow, this.title, this.body, this.icon, this.future);

  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;
  final bool future;
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({required this.data});

  final _PhaseData data;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: data.future
            ? theme.colorScheme.surfaceContainerHigh
            : Colors.green.withAlpha(18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: data.future
              ? theme.colorScheme.outlineVariant
              : Colors.green.withAlpha(90),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, color: theme.colorScheme.primary),
              const Spacer(),
              if (data.future)
                _VisionBadge(label: l.visionBadge)
              else
                _TodayBadge(label: l.visionTodayLabel),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            data.eyebrow,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.body,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _ProposalFlow extends StatelessWidget {
  const _ProposalFlow();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final steps = [
      (Icons.visibility_outlined, l.visionFlow1, true),
      (Icons.account_tree_outlined, l.visionFlow2, true),
      (Icons.lightbulb_outline, l.visionFlow3, true),
      (Icons.how_to_reg_outlined, l.visionFlow4, false),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 760;
        if (!horizontal) {
          return Column(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                _FlowStep(
                  icon: steps[i].$1,
                  label: steps[i].$2,
                  future: steps[i].$3,
                ),
                if (i < steps.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Icon(Icons.arrow_downward, size: 20),
                  ),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              Expanded(
                child: _FlowStep(
                  icon: steps[i].$1,
                  label: steps[i].$2,
                  future: steps[i].$3,
                ),
              ),
              if (i < steps.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, size: 20),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.icon,
    required this.label,
    required this.future,
  });

  final IconData icon;
  final String label;
  final bool future;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: future
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (future) ...[
            const SizedBox(height: 8),
            _VisionBadge(label: l.visionBadge, compact: true),
          ],
        ],
      ),
    );
  }
}

class _VisionFeature {
  const _VisionFeature(this.icon, this.title, this.body, {this.platforms});

  final IconData icon;
  final String title;
  final String body;
  final List<String>? platforms;
}

class _CapabilitySection extends StatelessWidget {
  const _CapabilitySection({
    required this.icon,
    required this.title,
    required this.body,
    required this.features,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<_VisionFeature> features;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(icon: icon, title: title, body: body),
        const SizedBox(height: 18),
        _ResponsiveFeatureGrid(features: features),
      ],
    );
  }
}

class _ResponsiveFeatureGrid extends StatelessWidget {
  const _ResponsiveFeatureGrid({required this.features});

  final List<_VisionFeature> features;

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 920
            ? 3
            : constraints.maxWidth >= 600
            ? 2
            : 1;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final feature in features)
              SizedBox(
                width: width,
                child: _FeatureCard(feature: feature),
              ),
          ],
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final _VisionFeature feature;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  feature.icon,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const Spacer(),
              _VisionBadge(label: l.visionBadge, compact: true),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            feature.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            feature.body,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (feature.platforms case final platforms?) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final name in platforms) _PlatformChip(name)],
            ),
          ],
        ],
      ),
    );
  }
}

class _PlatformChip extends StatelessWidget {
  const _PlatformChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: theme.textTheme.labelSmall),
    );
  }
}

class _BriefingVision extends StatelessWidget {
  const _BriefingVision();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = [
      _VisionFeature(
        Icons.wb_sunny_outlined,
        l.visionMorningTitle,
        l.visionMorningBody,
      ),
      _VisionFeature(
        Icons.today_outlined,
        l.visionDailyTitle,
        l.visionDailyBody,
      ),
      _VisionFeature(
        Icons.verified_outlined,
        l.visionLearningTitle,
        l.visionLearningBody,
      ),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withAlpha(150),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            icon: Icons.light_mode_outlined,
            title: l.visionBriefingTitle,
            body: l.visionBriefingBody,
          ),
          const SizedBox(height: 18),
          _ResponsiveFeatureGrid(features: items),
        ],
      ),
    );
  }
}

class _HumanControlSection extends StatelessWidget {
  const _HumanControlSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final boundaries = [
      l.visionNeverDecides,
      l.visionNeverPublishes,
      l.visionNeverChanges,
      l.visionOnlySuggests,
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pan_tool_alt_outlined,
                color: theme.colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.visionControlTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.visionControlBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onTertiaryContainer,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < boundaries.length; i++)
                _BoundaryPill(
                  text: boundaries[i],
                  positive: i == boundaries.length - 1,
                ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withAlpha(210),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.how_to_reg, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.visionHumanAlways,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
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

class _BoundaryPill extends StatelessWidget {
  const _BoundaryPill({required this.text, required this.positive});

  final String text;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(190),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(
            positive ? Icons.lightbulb_outline : Icons.block_outlined,
            size: 17,
            color: positive ? Colors.green : theme.colorScheme.error,
          ),
          const SizedBox(width: 7),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _VisionClosing extends StatelessWidget {
  const _VisionClosing();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VisionBadge(label: l.visionBadge, inverted: true),
          const SizedBox(height: 16),
          Text(
            l.visionClosingTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.visionClosingBody,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisionBadge extends StatelessWidget {
  const _VisionBadge({
    required this.label,
    this.compact = false,
    this.inverted = false,
  });

  final String label;
  final bool compact;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = inverted
        ? theme.colorScheme.onPrimary.withAlpha(35)
        : theme.colorScheme.primary;
    final foreground = inverted
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onPrimary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 2 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _TodayBadge extends StatelessWidget {
  const _TodayBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(32),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.green.withAlpha(110)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.green.shade800,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(180),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
