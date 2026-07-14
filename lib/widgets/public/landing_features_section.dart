import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'landing_hover_card.dart';
import 'landing_section_header.dart';

class LandingFeaturesSection extends StatelessWidget {
  const LandingFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final features = [
      _Feature(Icons.assignment_outlined, l.landingFeatureIntake, false),
      _Feature(Icons.fact_check_outlined, l.landingFeatureAuditFull, false),
      _Feature(
        Icons.library_books_outlined,
        l.landingFeatureKnowledgeFull,
        false,
      ),
      _Feature(Icons.folder_copy_outlined, l.landingFeatureSources, false),
      _Feature(Icons.smart_toy_outlined, l.landingFeatureBotTest, false),
      _Feature(Icons.rate_review_outlined, l.landingFeatureHumanReview, false),
      _Feature(Icons.campaign_outlined, l.landingFeatureMarketing, true),
      _Feature(Icons.query_stats_outlined, l.landingFeatureControlling, true),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LandingSectionHeader(
            title: l.landingFeaturesTitle,
            subtitle: l.landingFeaturesSubtitle,
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final count = width >= 980
                  ? 4
                  : width >= 680
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 148,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) => _FeatureCard(features[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;

  const _FeatureCard(this.feature);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return LandingHoverCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(feature.icon, color: theme.colorScheme.primary, size: 28),
              const Spacer(),
              if (feature.comingSoon)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l.landingComingSoon,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            feature.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final bool comingSoon;

  const _Feature(this.icon, this.title, this.comingSoon);
}
