import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../community/community_controller.dart';
import '../../community/models/profile_match.dart';
import '../../l10n/app_localizations.dart';
import 'match_breakdown_card.dart';

/// Deterministic matching view. Starting point is either a content item
/// (?content=id) or a member (?member=id). Shows the full ranked breakdown
/// including ineligible (hard-blocked) profiles. Nothing is ever assigned
/// automatically — a human decides.
class MatchingScreen extends StatelessWidget {
  final String? contentId;
  final String? memberId;

  const MatchingScreen({super.key, this.contentId, this.memberId});

  @override
  Widget build(BuildContext context) {
    final controller = CommunityController.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final fromContent = contentId != null && contentId!.isNotEmpty;
    final content = fromContent ? controller.content(contentId!) : null;
    final member = !fromContent && memberId != null
        ? controller.member(memberId!)
        : null;

    final List<ProfileMatch> matches;
    final String heading;
    final String starting;
    final String backLabel;
    final VoidCallback onBack;

    if (fromContent && content != null) {
      matches = controller.matchesForContent(content.id);
      heading = content.title;
      starting = l.communityMatchingFromContent;
      backLabel = l.communityViewContent;
      onBack = () => context.go('/community/${content.id}');
    } else if (member != null) {
      matches = controller.matchesForMember(member.id);
      heading = member.displayName;
      starting = l.communityMatchingFromMember;
      backLabel = l.communityViewProfile;
      onBack = () => context.go('/community-members/${member.id}');
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/community'),
          ),
        ),
        body: Center(child: Text(l.communityMatchingEmpty)),
      );
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(backLabel),
              ),
              const SizedBox(height: 8),
              Text(
                l.communityMatchingTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$starting · $heading',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.communityMatchNoAssignNote,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (matches.isEmpty)
                Text(l.communityMatchingEmpty)
              else
                for (final match in matches)
                  MatchBreakdownCard(
                    match: match,
                    title: fromContent
                        ? (controller.member(match.memberId)?.displayName ??
                              match.memberId)
                        : (controller.content(match.contentId)?.title ??
                              match.contentId),
                    subtitle: fromContent
                        ? _memberSubtitle(controller, match.memberId)
                        : controller.companyName(
                            controller.content(match.contentId)?.companyId ??
                                '',
                          ),
                    onTap: fromContent
                        ? () =>
                              context.go('/community-members/${match.memberId}')
                        : () => context.go('/community/${match.contentId}'),
                  ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String? _memberSubtitle(CommunityController controller, String memberId) {
    final member = controller.member(memberId);
    if (member == null) return null;
    return '${member.country} · '
        '${member.languages.map((e) => e.toUpperCase()).join(', ')}';
  }
}
