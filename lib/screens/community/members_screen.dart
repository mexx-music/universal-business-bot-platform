import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../community/community_controller.dart';
import '../../community/community_labels.dart';
import '../../community/models/community_enums.dart';
import '../../community/models/community_member.dart';
import '../../l10n/app_localizations.dart';

/// Read-only list of the global, company-independent member pool with filters
/// and search. Scores are shown as neutral signals — never as "credible" or
/// "not credible".
class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  String _query = '';
  String? _language;
  String? _country;
  String? _topic;
  CommunityPlatform? _platform;
  MemberStatus? _status;
  HumanIntelligenceDomain? _domain;

  @override
  Widget build(BuildContext context) {
    final controller = CommunityController.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final all = controller.members;

    final languages = {for (final m in all) ...m.languages}.toList()..sort();
    final countries = {for (final m in all) m.country}.toList()..sort();
    final topics = {
      for (final m in all) ...m.declaredInterests,
      for (final m in all) ...m.verifiedTopics,
    }.toList()..sort();

    final filtered = all.where((m) {
      if (_query.isNotEmpty &&
          !m.displayName.toLowerCase().contains(_query.toLowerCase())) {
        return false;
      }
      if (_language != null && !m.languages.contains(_language)) return false;
      if (_country != null && m.country != _country) return false;
      if (_topic != null &&
          !m.declaredInterests.contains(_topic) &&
          !m.verifiedTopics.contains(_topic)) {
        return false;
      }
      if (_platform != null && !m.platforms.contains(_platform)) return false;
      if (_status != null && m.status != _status) return false;
      if (_domain != null && !m.supportedDomains.contains(_domain)) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => a.displayName.compareTo(b.displayName));

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l.communityMembersTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.communityMembersSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: l.communityMembersSearchHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _Filter<String>(
                label: l.communityFilterLanguage,
                value: _language,
                items: [
                  for (final code in languages)
                    DropdownMenuItem(
                      value: code,
                      child: Text(code.toUpperCase()),
                    ),
                ],
                onChanged: (v) => setState(() => _language = v),
              ),
              _Filter<String>(
                label: l.communityFilterCountry,
                value: _country,
                items: [
                  for (final code in countries)
                    DropdownMenuItem(value: code, child: Text(code)),
                ],
                onChanged: (v) => setState(() => _country = v),
              ),
              _Filter<String>(
                label: l.communityFilterTopic,
                value: _topic,
                items: [
                  for (final t in topics)
                    DropdownMenuItem(value: t, child: Text(t)),
                ],
                onChanged: (v) => setState(() => _topic = v),
              ),
              _Filter<CommunityPlatform>(
                label: l.communityFilterPlatform,
                value: _platform,
                items: [
                  for (final p in CommunityPlatform.values)
                    DropdownMenuItem(
                      value: p,
                      child: Text(communityPlatformLabel(context, p)),
                    ),
                ],
                onChanged: (v) => setState(() => _platform = v),
              ),
              _Filter<MemberStatus>(
                label: l.communityFilterStatus,
                value: _status,
                items: [
                  for (final s in MemberStatus.values)
                    DropdownMenuItem(
                      value: s,
                      child: Text(communityMemberStatusLabel(context, s)),
                    ),
                ],
                onChanged: (v) => setState(() => _status = v),
              ),
              _Filter<HumanIntelligenceDomain>(
                label: l.communityFilterDomain,
                value: _domain,
                items: [
                  for (final d in HumanIntelligenceDomain.values)
                    DropdownMenuItem(
                      value: d,
                      child: Text(communityDomainLabel(context, d)),
                    ),
                ],
                onChanged: (v) => setState(() => _domain = v),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text(l.communityMembersEmpty)),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 900
                    ? 3
                    : constraints.maxWidth > 560
                    ? 2
                    : 1;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final member in filtered)
                      SizedBox(
                        width:
                            (constraints.maxWidth - (columns - 1) * 12) /
                            columns,
                        child: _MemberCard(
                          member: member,
                          onTap: () =>
                              context.go('/community-members/${member.id}'),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Filter<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _Filter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      width: 170,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T?>(
            isExpanded: true,
            value: value,
            hint: Text(l.communityFilterAll),
            items: [
              DropdownMenuItem<T?>(
                value: null,
                child: Text(l.communityFilterAll),
              ),
              ...items,
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final CommunityMember member;
  final VoidCallback onTap;

  const _MemberCard({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
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
                    child: Text(
                      member.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusChip(status: member.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${member.country} · '
                '${member.languages.map((e) => e.toUpperCase()).join(', ')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final p in member.platforms)
                    Chip(
                      label: Text(communityPlatformLabel(context, p)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${l.communityMemberQuality}: ${member.qualityScore} · '
                '${l.communityMemberAuthenticity}: '
                '${member.accountAuthenticityScore}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '${l.communityMemberCompletedTasks}: '
                '${member.completedTaskCount}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                member.isAvailable
                    ? l.communityMemberAvailable
                    : l.communityMemberUnavailable,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: member.isAvailable
                      ? Colors.green
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final MemberStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status) {
      MemberStatus.active => Colors.green,
      MemberStatus.pending => theme.colorScheme.tertiary,
      MemberStatus.paused => theme.colorScheme.onSurfaceVariant,
      MemberStatus.blocked => theme.colorScheme.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        communityMemberStatusLabel(context, status),
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
