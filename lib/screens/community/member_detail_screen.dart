import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../community/community_controller.dart';
import '../../community/community_labels.dart';
import '../../l10n/app_localizations.dart';
import 'match_breakdown_card.dart';

/// Read-only profile of a single community member plus their matching content.
class MemberDetailScreen extends StatelessWidget {
  final String memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    final controller = CommunityController.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final member = controller.member(memberId);

    if (member == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/community-members'),
          ),
        ),
        body: Center(child: Text(l.communityMembersEmpty)),
      );
    }

    final matches = controller
        .matchesForMember(memberId)
        .where((m) => m.eligible)
        .toList();

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextButton.icon(
                onPressed: () => context.go('/community-members'),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(l.navCommunityMembers),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      member.displayName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    member.isVerified
                        ? l.communityMemberVerified
                        : l.communityMemberNotVerified,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: member.isVerified
                          ? Colors.green
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${l.communityMemberQuality}: ${member.qualityScore} · '
                '${l.communityMemberAuthenticity}: '
                '${member.accountAuthenticityScore} · '
                '${l.communityMemberCompletedTasks}: '
                '${member.completedTaskCount}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              _Field(
                label: l.communityMemberLanguages,
                value: member.languages.map((e) => e.toUpperCase()).join(', '),
              ),
              _Field(label: l.communityMemberCountry, value: member.country),
              _ChipsField(
                label: l.communityMemberInterests,
                values: member.declaredInterests,
              ),
              _ChipsField(
                label: l.communityMemberExperience,
                values: member.experienceCategories,
              ),
              _Field(
                label: l.communityMemberPlatforms,
                value: member.platformProfiles
                    .map(
                      (p) =>
                          '${communityPlatformLabel(context, p.platform)} '
                          '(@${p.handle})',
                    )
                    .join(', '),
              ),
              _ChipsField(
                label: l.communityMemberPublicTopics,
                values: member.publicActivityTopics,
              ),
              _Field(
                label: l.communityMemberPreferredActions,
                value: member.preferredActions
                    .map((a) => communityActionLabel(context, a))
                    .join(', '),
              ),
              _Field(
                label: l.communityMemberDomains,
                value: member.supportedDomains
                    .map((d) => communityDomainLabel(context, d))
                    .join(', '),
              ),
              _ChipsField(
                label: l.communityMemberExcludedTopics,
                values: member.excludedTopics,
              ),
              _Field(
                label: l.communityMemberExcludedCompanies,
                value: member.excludedCompanyIds.isEmpty
                    ? l.communityMemberNone
                    : member.excludedCompanyIds
                          .map(controller.companyName)
                          .join(', '),
              ),
              _Field(
                label: l.communityMemberConsentStatus,
                value: member.profileAnalysisConsent
                    ? l.communityMemberConsentGranted
                    : l.communityMemberConsentMissing,
              ),
              _Field(
                label: l.communityMemberAvailability,
                value:
                    '${member.isAvailable ? l.communityMemberAvailable : l.communityMemberUnavailable}'
                    ' · ${member.availability}',
              ),

              const SizedBox(height: 12),
              Text(
                l.communityMemberMatchesTitle,
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
                  MatchBreakdownCard(
                    match: match,
                    title:
                        controller.content(match.contentId)?.title ??
                        match.contentId,
                    subtitle: _contentSubtitle(controller, match.contentId),
                    dense: true,
                    onTap: () => context.go('/community/${match.contentId}'),
                  ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String? _contentSubtitle(CommunityController controller, String contentId) {
    final content = controller.content(contentId);
    if (content == null) return null;
    return controller.companyName(content.companyId);
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;

  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(value.isEmpty ? '—' : value),
        ],
      ),
    );
  }
}

class _ChipsField extends StatelessWidget {
  final String label;
  final List<String> values;

  const _ChipsField({required this.label, required this.values});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (values.isEmpty)
            const Text('—')
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final v in values)
                  Chip(
                    label: Text(v),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
