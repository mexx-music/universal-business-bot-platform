import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'landing_hover_card.dart';
import 'landing_section_header.dart';

class LandingBenefitsSection extends StatelessWidget {
  const LandingBenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final benefits = [
      _Benefit(
        Icons.apartment_rounded,
        l.landingBenefitCompanyTitle,
        l.landingBenefitCompanyText,
      ),
      _Benefit(
        Icons.auto_awesome_rounded,
        l.landingBenefitAssistantTitle,
        l.landingBenefitAssistantText,
      ),
      _Benefit(
        Icons.local_library_rounded,
        l.landingBenefitDatabaseTitle,
        l.landingBenefitDatabaseText,
      ),
      _Benefit(
        Icons.trending_up_rounded,
        l.landingBenefitMarketingTitle,
        l.landingBenefitMarketingText,
      ),
      _Benefit(
        Icons.query_stats_rounded,
        l.landingBenefitControllingTitle,
        l.landingBenefitControllingText,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LandingSectionHeader(
            title: l.landingBenefitsTitle,
            subtitle: l.landingBenefitsSubtitle,
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final count = width >= 1160
                  ? 5
                  : width >= 900
                  ? 3
                  : width >= 620
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 196,
                ),
                itemCount: benefits.length,
                itemBuilder: (context, index) => _BenefitCard(benefits[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final _Benefit benefit;

  const _BenefitCard(this.benefit);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LandingHoverCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(18),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              benefit.icon,
              color: theme.colorScheme.primary,
              size: 27,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            benefit.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            benefit.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.36,
            ),
          ),
        ],
      ),
    );
  }
}

class _Benefit {
  final IconData icon;
  final String title;
  final String description;

  const _Benefit(this.icon, this.title, this.description);
}
