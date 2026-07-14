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
      l.landingBenefitOnePlace,
      l.landingBenefitLessSupport,
      l.landingBenefitStructuredData,
      l.landingBenefitHumanAi,
      l.landingBenefitTransparency,
      l.landingBenefitScalable,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LandingSectionHeader(title: l.landingBenefitsTitle),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 620
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 116,
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
  final String text;

  const _BenefitCard(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LandingHoverCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
