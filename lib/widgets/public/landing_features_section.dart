import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'landing_section_header.dart';

class LandingFeaturesSection extends StatelessWidget {
  const LandingFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final today = [
      (Icons.auto_stories_outlined, l.landingFeatureKnowledgeBuilder),
      (Icons.fact_check_outlined, l.landingFeatureHumanReview),
      (Icons.chat_bubble_outline_rounded, l.landingFeatureGroundedAnswers),
      (Icons.link_rounded, l.landingFeatureWebsiteLinks),
      (Icons.insights_outlined, l.landingFeatureOperationsCenter),
      (Icons.auto_awesome_rounded, l.landingFeatureGeminiInsights),
    ];
    final vision = [
      (Icons.public_rounded, l.landingVisionExternalSignals),
      (Icons.account_tree_outlined, l.landingVisionCompanyKnowledge),
      (Icons.radar_rounded, l.landingVisionResearch),
      (Icons.lightbulb_outline_rounded, l.landingVisionRecommendations),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 54),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LandingSectionHeader(
            title: l.landingFeaturesTitle,
            subtitle: l.landingFeaturesSubtitle,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide = constraints.maxWidth >= 850;
              final available = _StatusPanel(
                key: const Key('landing-available-now'),
                status: l.landingAvailableNow,
                title: l.landingTodayTitle,
                text: l.landingTodayText,
                items: today,
                available: true,
              );
              final future = _StatusPanel(
                key: const Key('landing-vision-stage'),
                status: l.landingVisionStage,
                title: l.landingVisionTitle,
                text: l.landingVisionText,
                items: vision,
                available: false,
              );

              if (!sideBySide) {
                return Column(
                  children: [available, const SizedBox(height: 16), future],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: available),
                  const SizedBox(width: 16),
                  Expanded(child: future),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _GeminiNote(title: l.landingGeminiTitle, text: l.landingGeminiText),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final String status;
  final String title;
  final String text;
  final List<(IconData, String)> items;
  final bool available;

  const _StatusPanel({
    super.key,
    required this.status,
    required this.title,
    required this.text,
    required this.items,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = available
        ? theme.colorScheme.primary
        : theme.colorScheme.tertiary;
    final surface = available
        ? theme.colorScheme.primaryContainer.withAlpha(42)
        : theme.colorScheme.tertiaryContainer.withAlpha(45);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withAlpha(85)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: accent.withAlpha(available ? 28 : 24),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: accent.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  available
                      ? Icons.check_circle_rounded
                      : Icons.visibility_outlined,
                  color: accent,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    status,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              for (final item in items)
                _CapabilityChip(icon: item.$1, label: item.$2, accent: accent),
            ],
          ),
        ],
      ),
    );
  }
}

class _CapabilityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;

  const _CapabilityChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withAlpha(230),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeminiNote extends StatelessWidget {
  final String title;
  final String text;

  const _GeminiNote({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.42,
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
