import 'package:flutter/material.dart';

import '../../community/community_labels.dart';
import '../../community/models/profile_match.dart';
import '../../l10n/app_localizations.dart';

/// Reusable, fully localized breakdown of a [ProfileMatch]: score, per-factor
/// components, warnings, hard block reasons, disclosure and possible actions.
/// Shared by the matching view, content detail and member detail so the
/// explanation of a score looks identical everywhere.
class MatchBreakdownCard extends StatelessWidget {
  const MatchBreakdownCard({
    super.key,
    required this.match,
    required this.title,
    this.subtitle,
    this.onTap,
    this.dense = false,
  });

  final ProfileMatch match;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  /// When true, hides the component breakdown (compact list contexts).
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _ScoreBadge(score: match.overallMatchScore),
                ],
              ),
              const SizedBox(height: 6),
              _EligibilityChip(eligible: match.eligible),
              if (!dense) ...[
                const SizedBox(height: 10),
                Text(
                  l.communityMatchComponents,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final c in match.components)
                      _ComponentChip(
                        label: communityFactorLabel(context, c.factor),
                        matched: c.matched,
                        points: c.points,
                        maxPoints: c.maxPoints,
                        detail: c.detail,
                      ),
                  ],
                ),
              ],
              if (match.blockReasons.isNotEmpty) ...[
                const SizedBox(height: 8),
                _LabeledList(
                  title: l.communityMatchBlockedTitle,
                  color: theme.colorScheme.error,
                  icon: Icons.block,
                  items: [
                    for (final b in match.blockReasons)
                      communityBlockLabel(context, b),
                  ],
                ),
              ],
              if (match.warnings.isNotEmpty) ...[
                const SizedBox(height: 8),
                _LabeledList(
                  title: l.communityMatchWarningsTitle,
                  color: theme.colorScheme.tertiary,
                  icon: Icons.info_outline,
                  items: [
                    for (final w in match.warnings)
                      communityWarningLabel(context, w),
                  ],
                ),
              ],
              if (match.possibleActions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${l.communityMatchPossibleActions}: '
                  '${match.possibleActions.map((a) => communityActionLabel(context, a)).join(', ')}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (match.disclosureRequired) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l.communityDisclosureRequired,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$score%',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EligibilityChip extends StatelessWidget {
  final bool eligible;

  const _EligibilityChip({required this.eligible});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = eligible ? Colors.green : theme.colorScheme.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          eligible
              ? Icons.check_circle_outline
              : Icons.do_not_disturb_on_outlined,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          eligible ? l.communityMatchEligible : l.communityMatchIneligible,
          style: theme.textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _ComponentChip extends StatelessWidget {
  final String label;
  final bool matched;
  final int points;
  final int maxPoints;
  final String? detail;

  const _ComponentChip({
    required this.label,
    required this.matched,
    required this.points,
    required this.maxPoints,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = matched
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final text = detail == null ? label : '$label · $detail';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            matched ? Icons.check : Icons.remove,
            size: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text('$text  $points/$maxPoints', style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _LabeledList extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<String> items;

  const _LabeledList({
    required this.title,
    required this.color,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        for (final item in items)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item,
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
