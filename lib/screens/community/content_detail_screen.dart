import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../community/community_controller.dart';
import '../../community/community_labels.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';
import '../../models/knowledge_entry.dart' show RiskLevelX;
import 'match_breakdown_card.dart';

/// Read-only detail view of a discovered content item: original text, AI
/// analysis, risks, permitted/prohibited reactions, related knowledge (titles
/// resolved read-only from the workspace) and the matching community members.
/// No actions are performed here.
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

    final matches = controller.eligibleMatchesForContent(contentId);

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
                              avatar: const Icon(
                                Icons.menu_book_outlined,
                                size: 14,
                              ),
                              label: Text(
                                _knowledgeTitle(context, content.companyId, id),
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.communityDetailMatches,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        context.go('/community/matching?content=$contentId'),
                    icon: const Icon(Icons.compare_arrows, size: 18),
                    label: Text(l.communityViewMatching),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (matches.isEmpty)
                Text(
                  l.communityDetailNoMatches,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                )
              else
                for (final match in matches)
                  MatchBreakdownCard(
                    match: match,
                    title:
                        controller.member(match.memberId)?.displayName ??
                        match.memberId,
                    subtitle: _memberSubtitle(controller, match.memberId),
                    dense: true,
                    onTap: () =>
                        context.go('/community-members/${match.memberId}'),
                  ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Resolves a knowledge entry id to its title by reading the workspace
  /// read-only from AppState. Community data is never moved into the workspace;
  /// this is a one-way, presentation-only lookup. Falls back to the id.
  String _knowledgeTitle(BuildContext context, String companyId, String id) {
    final state = AppState.of(context);
    for (final workspace in state.companies) {
      if (workspace.company.id != companyId) continue;
      for (final entry in workspace.knowledgeEntries) {
        if (entry.id == id) return entry.title;
      }
    }
    return id;
  }

  String? _memberSubtitle(CommunityController controller, String memberId) {
    final member = controller.member(memberId);
    if (member == null) return null;
    return '${member.country} · '
        '${member.languages.map((e) => e.toUpperCase()).join(', ')}';
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
