import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../demo_data/demo_data_controller.dart';
import '../../l10n/app_localizations.dart';

/// "Weitere Module" hub (BLOCK 9). Lists every remaining area of the platform
/// (nothing removed) plus the central demo switch and the internal release
/// checklist. Presentation only.
class MoreModulesScreen extends StatelessWidget {
  const MoreModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final demo = DemoDataController.maybeOf(context);

    final modules = <(IconData, String, String)>[
      (Icons.dashboard_outlined, l.navDashboard, '/dashboard'),
      (Icons.checklist_outlined, l.navNextActions, '/next-actions'),
      (Icons.event_available_outlined, l.navCheckIn, '/check-in'),
      (Icons.route_outlined, l.navProjectStatus, '/project-status'),
      (
        Icons.insights_outlined,
        l.navBusinessIntelligence,
        '/business-intelligence',
      ),
      (Icons.flag_outlined, l.navBusinessStrategy, '/business-strategy'),
      (Icons.campaign_outlined, l.navMarketingStrategy, '/marketing-strategy'),
      (Icons.assignment_outlined, l.navIntake, '/intake'),
      (Icons.business_outlined, l.navCompany, '/company'),
      (Icons.fact_check_outlined, l.navAudit, '/audit'),
      (Icons.library_books_outlined, l.navKnowledge, '/knowledge'),
      (
        Icons.auto_stories_outlined,
        l.navKnowledgeBuilder,
        '/knowledge-builder',
      ),
      (Icons.tune_outlined, l.navBotSettings, '/bot-settings'),
      (Icons.source_outlined, l.navSources, '/sources'),
      (Icons.rate_review_outlined, l.navReview, '/review'),
      (Icons.radar_outlined, l.navCommunityRadar, '/community'),
      (Icons.groups_outlined, l.navCommunityMembers, '/community-members'),
      (Icons.timeline_outlined, l.navCompanyEvolution, '/company-evolution'),
      (
        Icons.loop_outlined,
        l.navKnowledgeImprovement,
        '/knowledge-improvement',
      ),
      (Icons.account_tree_outlined, l.navRolePortals, '/portals'),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.moreTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.moreIntro,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (demo != null) _DemoSwitchCard(controller: demo),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.checklist_rtl_outlined),
                      title: Text(l.releaseTitle),
                      subtitle: Text(l.releaseIntro),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/release-check'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final m in modules)
                        _ModuleTile(icon: m.$1, label: m.$2, route: m.$3),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoSwitchCard extends StatelessWidget {
  const _DemoSwitchCard({required this.controller});

  final DemoDataController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: SwitchListTile(
        secondary: const Icon(Icons.science_outlined),
        title: Text(l.demoSwitchTitle),
        subtitle: Text(
          '${l.demoSwitchSubtitle} · ${controller.enabled ? l.demoSwitchOn : l.demoSwitchOff}',
        ),
        value: controller.enabled,
        onChanged: (v) => controller.setEnabled(v),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go(route),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
