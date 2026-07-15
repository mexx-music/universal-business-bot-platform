import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'landing_section_header.dart';

class LandingFaqSection extends StatelessWidget {
  const LandingFaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final items = [
      (l.landingFaqQuestion1, l.landingFaqAnswer1),
      (l.landingFaqQuestion2, l.landingFaqAnswer2),
      (l.landingFaqQuestion3, l.landingFaqAnswer3),
      (l.landingFaqQuestion4, l.landingFaqAnswer4),
      (l.landingFaqQuestion5, l.landingFaqAnswer5),
      (l.landingFaqQuestion6, l.landingFaqAnswer6),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 54),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LandingSectionHeader(
            title: l.landingFaqTitle,
            subtitle: l.landingFaqSubtitle,
          ),
          const SizedBox(height: 22),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                for (var index = 0; index < items.length; index++)
                  _FaqTile(
                    question: items[index].$1,
                    answer: items[index].$2,
                    last: index == items.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool last;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        title: Text(
          question,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
