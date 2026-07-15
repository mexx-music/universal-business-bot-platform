import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'landing_hover_card.dart';
import 'landing_section_header.dart';

class LandingAudienceSection extends StatelessWidget {
  const LandingAudienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final audiences = [
      (Icons.design_services_outlined, l.landingAudienceServices),
      (Icons.handyman_rounded, l.landingAudienceCraft),
      (Icons.local_hospital_outlined, l.landingAudienceDoctors),
      (Icons.handshake_outlined, l.landingAudienceConsulting),
      (Icons.shopping_bag_outlined, l.landingAudienceShops),
      (Icons.hotel_rounded, l.landingAudienceHotels),
      (Icons.groups_rounded, l.landingAudienceAssociations),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LandingSectionHeader(title: l.landingAudienceTitle),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 1100
                  ? 4
                  : constraints.maxWidth >= 820
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
                  mainAxisExtent: 118,
                ),
                itemCount: audiences.length,
                itemBuilder: (context, index) => _AudienceCard(
                  icon: audiences[index].$1,
                  label: audiences[index].$2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AudienceCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AudienceCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LandingHoverCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Icon(icon, color: theme.colorScheme.onSecondaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
