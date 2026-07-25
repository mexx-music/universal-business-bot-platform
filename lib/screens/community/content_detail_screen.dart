import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../community/community_controller.dart';
import '../../community/community_labels.dart';
import '../../community/models/community_member.dart';
import '../../community/models/profile_match.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';
import '../../models/knowledge_entry.dart' show RiskLevelX;

/// Read-only detail view of a discovered content item: original text, AI
/// analysis, risks, permitted/prohibited reactions and the matching community
/// members. No actions are performed here in CR-1.
class ContentDetailScreen extends StatelessWidget {
  final String contentId;

  const ContentDetailScreen({super.key, required this.contentId});

  @override
  Widget build(BuildContext context) {
    final controller = CommunityController.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final content = controller.content(contentId);

    if (content == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/community'),
          ),
        ),
        body: Center(child: Text(l.communityEmpty)),
      );
    }

    final matches = controller.matchesForContent(contentId);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextButton.icon(
                onPressed: () => context.go('/community'),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(l.communityBackToRadar),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      content.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: content.riskLevel.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          content.riskLevel.icon,
                          size: 14,
                          color: content.riskLevel.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          riskLevelLabel(context, content.riskLevel),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: content.riskLevel.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${communityPlatformLabel(context, content.platform)} · '
                '${controller.companyName(content.companyId)} · '
                '${content.language.toUpperCase()} · ${content.country}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              _Section(
                title: l.communityDetailOriginalText,
                child: Text(content.originalText),
              ),
              _Section(
                title: l.communityDetailSource,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        content.sourceUrl,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: Text(l.communityOpenOriginal),
                    ),
                  ],
                ),
              ),
              if (content.aiSummary.isNotEmpty)
                _Section(
                  title: l.communityDetailSummary,
                  child: Text(content.aiSummary),
                ),
              _Section(
                title: l.communityDetailIntent,
                child: Text(
                  '${communityIntentLabel(context, content.detectedIntent)}'
                  ' · ${communitySentimentLabel(context, content.sentiment)}',
                ),
              ),
              if (content.relevanceReason.isNotEmpty)
                _Section(
                  title: l.communityDetailRelevanceReason,
                  child: Text(content.relevanceReason),
                ),
              _Section(
                title: l.communityDetailRisks,
                child: content.riskNotes.isEmpty
                    ? Text(
                        l.communityDetailNoRisks,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : _BulletList(items: content.riskNotes),
              ),
              _Section(
                title: l.communityDetailAllowedActions,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final a in content.recommendedActionTypes)
                      Chip(
                        label: Text(communityActionLabel(context, a)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ),
              _Section(
                title: l.communityDetailProhibited,
                child: content.prohibitedClaims.isEmpty
                    ? Text(
                        l.communityDetailNoProhibited,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : _BulletList(
                        items: content.prohibitedClaims,
                        color: theme.colorScheme.error,
                        icon: Icons.block,
                      ),
              ),
              _Section(
                title: l.communityDetailKnowledge,
                child: content.relatedKnowledgeEntryIds.isEmpty
                    ? Text(
                        l.communityDetailNoKnowledge,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final id in content.relatedKnowledgeEntryIds)
                            Chip(
                              avatar: const Icon(Icons.link, size: 14),
                              label: Text(id),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                l.communityDetailMatches,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (matches.isEmpty)
                Text(
                  l.communityDetailNoMatches,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                )
              else
                for (final match in matches)
                  _MatchCard(
                    match: match,
                    member: controller.member(match.memberId),
                  ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final Color? color;
  final IconData? icon;

  const _BulletList({required this.items, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon ?? Icons.circle,
                  size: icon == null ? 6 : 14,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item, style: TextStyle(color: color)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  final ProfileMatch match;
  final CommunityMember? member;

  const _MatchCard({required this.match, required this.member});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final name = member?.displayName ?? match.memberId;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${l.communityMatchScore} ${match.overallMatchScore}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (member != null) ...[
              const SizedBox(height: 4),
              Text(
                '${member!.country} · ${member!.languages.map((e) => e.toUpperCase()).join(', ')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              l.communityMatchReasons,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            for (final reason in match.matchReasons)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('• $reason', style: theme.textTheme.bodySmall),
              ),
            if (match.warnings.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                l.communityMatchWarnings,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 2),
              for (final warning in match.warnings)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '• $warning',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
            if (member != null &&
                member!.disclosureRequirements.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${l.communityDisclosureRequired}: '
                      '${member!.disclosureRequirements.join(', ')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
