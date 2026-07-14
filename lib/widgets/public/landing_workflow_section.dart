import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'landing_hover_card.dart';
import 'landing_section_header.dart';

class LandingWorkflowSection extends StatelessWidget {
  const LandingWorkflowSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final steps = [
      _WorkflowStep(
        number: '1',
        icon: Icons.business_outlined,
        title: l.landingWorkflowStep1Title,
        description: l.landingWorkflowStep1Text,
      ),
      _WorkflowStep(
        number: '2',
        icon: Icons.library_books_outlined,
        title: l.landingWorkflowStep2Title,
        description: l.landingWorkflowStep2Text,
      ),
      _WorkflowStep(
        number: '3',
        icon: Icons.trending_up_rounded,
        title: l.landingWorkflowStep3Title,
        description: l.landingWorkflowStep3Text,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LandingSectionHeader(title: l.landingWorkflowTitle),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 880;
              if (!wide) {
                return Column(
                  children: [
                    for (var index = 0; index < steps.length; index++) ...[
                      steps[index],
                      if (index < steps.length - 1) const _DownArrow(),
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < steps.length; index++) ...[
                    Expanded(child: steps[index]),
                    if (index < steps.length - 1)
                      const Padding(
                        padding: EdgeInsets.only(top: 76),
                        child: Icon(Icons.arrow_forward_rounded),
                      ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;

  const _WorkflowStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LandingHoverCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  number,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: theme.colorScheme.primary, size: 30),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.38,
            ),
          ),
        ],
      ),
    );
  }
}

class _DownArrow extends StatelessWidget {
  const _DownArrow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Icon(Icons.arrow_downward_rounded),
    );
  }
}
