import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';
import '../../roles/models/portal_role.dart';
import '../../roles/portal_catalog.dart';

/// Read-only preview of the three portal tiers (BLOCK 3). Illustrates how the
/// company, employee and customer portals expose a *reduced navigation* over
/// one shared knowledge base. Enforces nothing — no login, no permission check,
/// no navigation side effects.
class RoleOverviewScreen extends StatefulWidget {
  const RoleOverviewScreen({super.key});

  @override
  State<RoleOverviewScreen> createState() => _RoleOverviewScreenState();
}

class _RoleOverviewScreenState extends State<RoleOverviewScreen> {
  PortalTier _tier = PortalTier.company;
  EmployeeRole _dept = EmployeeRole.support;

  RolePortal get _portal => PortalCatalog.forPersona(_tier, role: _dept);

  List<String> _daySteps(AppLocalizations l) => switch (_tier) {
    PortalTier.company => [
      l.roleDayCompany1,
      l.roleDayCompany2,
      l.roleDayCompany3,
    ],
    PortalTier.employee => [
      l.roleDayEmployee1,
      l.roleDayEmployee2,
      l.roleDayEmployee3,
    ],
    PortalTier.customer => [
      l.roleDayCustomer1,
      l.roleDayCustomer2,
      l.roleDayCustomer3,
    ],
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final portal = _portal;

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
                  Row(
                    children: [
                      Icon(
                        Icons.account_tree_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.roleOverviewTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.roleOverviewIntro,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Notice(
                    icon: Icons.hub_outlined,
                    text: l.roleSharedKnowledgeNote,
                    color: theme.colorScheme.secondaryContainer,
                    onColor: theme.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(height: 8),
                  _Notice(
                    icon: Icons.info_outline,
                    text: l.roleTrustNotice,
                    color: theme.colorScheme.tertiaryContainer,
                    onColor: theme.colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.roleSelectTier,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _TierSelector(
                    tier: _tier,
                    onChanged: (t) => setState(() => _tier = t),
                  ),
                  if (_tier == PortalTier.employee) ...[
                    const SizedBox(height: 12),
                    Text(
                      l.roleSelectDepartment,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _DeptSelector(
                      dept: _dept,
                      onChanged: (d) => setState(() => _dept = d),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _PortalCard(portal: portal, daySteps: _daySteps(l)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TierSelector extends StatelessWidget {
  const _TierSelector({required this.tier, required this.onChanged});

  final PortalTier tier;
  final ValueChanged<PortalTier> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<PortalTier>(
          showSelectedIcon: false,
          segments: [
            for (final t in PortalTier.values)
              ButtonSegment(value: t, label: Text(portalTierLabel(context, t))),
          ],
          selected: {tier},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      ),
    );
  }
}

class _DeptSelector extends StatelessWidget {
  const _DeptSelector({required this.dept, required this.onChanged});

  final EmployeeRole dept;
  final ValueChanged<EmployeeRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final d in EmployeeRole.values)
          ChoiceChip(
            label: Text(employeeRoleLabel(context, d)),
            selected: dept == d,
            onSelected: (_) => onChanged(d),
          ),
      ],
    );
  }
}

class _PortalCard extends StatelessWidget {
  const _PortalCard({required this.portal, required this.daySteps});

  final RolePortal portal;
  final List<String> daySteps;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.window_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  portalTierTitle(context, portal.tier),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (portal.employeeRole != null)
                _Pill(label: employeeRoleLabel(context, portal.employeeRole!)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l.roleSectionsTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in portal.sections) _SectionPill(section: s),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l.roleDayTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < daySteps.length; i++)
            _DayStep(number: i + 1, text: daySteps[i]),
        ],
      ),
    );
  }
}

class _SectionPill extends StatelessWidget {
  const _SectionPill({required this.section});

  final PortalSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            section.icon,
            size: 15,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              portalSectionLabel(context, section),
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayStep extends StatelessWidget {
  const _DayStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              '$number',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.text,
    required this.color,
    required this.onColor,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: onColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: onColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
