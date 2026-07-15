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
      _TimelineStep(
        '1',
        Icons.add_business_rounded,
        l.landingTimelineStep1,
        l.landingTimelineStep1Text,
      ),
      _TimelineStep(
        '2',
        Icons.upload_file_rounded,
        l.landingTimelineStep2,
        l.landingTimelineStep2Text,
      ),
      _TimelineStep(
        '3',
        Icons.tune_rounded,
        l.landingTimelineStep3,
        l.landingTimelineStep3Text,
      ),
      _TimelineStep(
        '4',
        Icons.question_answer_rounded,
        l.landingTimelineStep4,
        l.landingTimelineStep4Text,
      ),
      _TimelineStep(
        '5',
        Icons.trending_up_rounded,
        l.landingTimelineStep5,
        l.landingTimelineStep5Text,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 54),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LandingSectionHeader(
            title: l.landingWorkflowTitle,
            subtitle: l.landingWorkflowSubtitle,
          ),
          const SizedBox(height: 26),
          LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = constraints.maxWidth >= 900;
              if (horizontal) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < steps.length; index++) ...[
                      Expanded(child: _TimelineCard(step: steps[index])),
                      if (index < steps.length - 1)
                        const Padding(
                          padding: EdgeInsets.only(top: 82),
                          child: _TimelineArrow(horizontal: true),
                        ),
                    ],
                  ],
                );
              }

              return Column(
                children: [
                  for (var index = 0; index < steps.length; index++) ...[
                    _TimelineCard(step: steps[index]),
                    if (index < steps.length - 1)
                      const _TimelineArrow(horizontal: false),
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

class _TimelineCard extends StatelessWidget {
  final _TimelineStep step;

  const _TimelineCard({required this.step});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LandingHoverCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  step.number,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(step.icon, color: theme.colorScheme.primary, size: 26),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            step.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.32,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineArrow extends StatelessWidget {
  final bool horizontal;

  const _TimelineArrow({required this.horizontal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal ? 8 : 0,
        vertical: horizontal ? 0 : 12,
      ),
      child: Icon(
        horizontal ? Icons.arrow_forward_rounded : Icons.arrow_downward_rounded,
      ),
    );
  }
}

class _TimelineStep {
  final String number;
  final IconData icon;
  final String title;
  final String description;

  const _TimelineStep(this.number, this.icon, this.title, this.description);
}
