import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../community/community_controller.dart';
import '../../community/community_labels.dart';
import '../../community/models/community_enums.dart';
import '../../community/models/discovered_content.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';
import '../../models/knowledge_entry.dart' show RiskLevel, RiskLevelX;

/// Read-only overview of discovered public discussions with filters. CR-1
/// surfaces the radar; task actions come later. Tapping a card opens the
/// detail view.
class CommunityRadarScreen extends StatefulWidget {
  const CommunityRadarScreen({super.key});

  @override
  State<CommunityRadarScreen> createState() => _CommunityRadarScreenState();
}

class _CommunityRadarScreenState extends State<CommunityRadarScreen> {
  String? _company;
  CommunityPlatform? _platform;
  String? _language;
  String? _country;
  RiskLevel? _risk;
  ContentStatus? _status;

  @override
  Widget build(BuildContext context) {
    final controller = CommunityController.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final all = controller.discoveredContent;

    final filtered = all.where((c) {
      if (_company != null && c.companyId != _company) return false;
      if (_platform != null && c.platform != _platform) return false;
      if (_language != null && c.language != _language) return false;
      if (_country != null && c.country != _country) return false;
      if (_risk != null && c.riskLevel != _risk) return false;
      if (_status != null && c.status != _status) return false;
      return true;
    }).toList()..sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    final languages = {for (final c in all) c.language}.toList()..sort();
    final countries = {for (final c in all) c.country}.toList()..sort();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l.communityRadarTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.communityRadarSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          _NoticeBar(text: l.communityDemoNote, icon: Icons.science_outlined),
          const SizedBox(height: 6),
          _NoticeBar(
            text: l.communityReadOnlyNote,
            icon: Icons.visibility_outlined,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _Filter<String>(
                label: l.communityFilterCompany,
                value: _company,
                items: [
                  for (final id in controller.companyIds)
                    DropdownMenuItem(
                      value: id,
                      child: Text(controller.companyName(id)),
                    ),
                ],
                onChanged: (v) => setState(() => _company = v),
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
              _Filter<RiskLevel>(
                label: l.communityFilterRisk,
                value: _risk,
                items: [
                  for (final r in RiskLevel.values)
                    DropdownMenuItem(
                      value: r,
                      child: Text(riskLevelLabel(context, r)),
                    ),
                ],
                onChanged: (v) => setState(() => _risk = v),
              ),
              _Filter<ContentStatus>(
                label: l.communityFilterStatus,
                value: _status,
                items: [
                  for (final s in ContentStatus.values)
                    DropdownMenuItem(
                      value: s,
                      child: Text(communityStatusLabel(context, s)),
                    ),
                ],
                onChanged: (v) => setState(() => _status = v),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  l.communityEmpty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            for (final content in filtered)
              _ContentCard(
                content: content,
                companyName: controller.companyName(content.companyId),
                onTap: () => context.go('/community/${content.id}'),
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
      width: 180,
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

class _ContentCard extends StatelessWidget {
  final DiscoveredContent content;
  final String companyName;
  final VoidCallback onTap;

  const _ContentCard({
    required this.content,
    required this.companyName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      content.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _RiskChip(risk: content.riskLevel),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _MetaChip(
                    icon: Icons.public,
                    label: communityPlatformLabel(context, content.platform),
                  ),
                  _MetaChip(icon: Icons.business_outlined, label: companyName),
                  _MetaChip(
                    icon: Icons.translate,
                    label:
                        '${content.language.toUpperCase()} · ${content.country}',
                  ),
                  _MetaChip(
                    icon: Icons.trending_up,
                    label: '${l.communityRelevance} ${content.relevanceScore}',
                  ),
                  _MetaChip(
                    icon: Icons.flag_outlined,
                    label: communityStatusLabel(context, content.status),
                  ),
                ],
              ),
              if (content.topicTags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final tag in content.topicTags)
                      Chip(
                        label: Text(tag),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ],
              if (content.recommendedActionTypes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${l.communityRecommendedAction}: '
                  '${content.recommendedActionTypes.map((a) => communityActionLabel(context, a)).join(', ')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RiskChip extends StatelessWidget {
  final RiskLevel risk;

  const _RiskChip({required this.risk});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: risk.color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(risk.icon, size: 14, color: risk.color),
          const SizedBox(width: 4),
          Text(
            riskLevelLabel(context, risk),
            style: theme.textTheme.labelSmall?.copyWith(color: risk.color),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _NoticeBar extends StatelessWidget {
  final String text;
  final IconData icon;

  const _NoticeBar({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
