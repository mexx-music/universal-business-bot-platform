import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_controller.dart';
import '../data/app_state.dart';
import '../demo/demo_mode_controller.dart';
import '../l10n/app_localizations.dart';
import '../tenant_selection/tenant_selection_controller.dart';
import 'language_switcher.dart';

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String path;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });
}

const _navItems = [
  _NavItem(
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    path: '/dashboard',
  ),
  _NavItem(
    icon: Icons.checklist_outlined,
    selectedIcon: Icons.checklist,
    path: '/next-actions',
  ),
  _NavItem(
    icon: Icons.event_available_outlined,
    selectedIcon: Icons.event_available,
    path: '/check-in',
  ),
  _NavItem(
    icon: Icons.route_outlined,
    selectedIcon: Icons.route,
    path: '/project-status',
  ),
  _NavItem(
    icon: Icons.insights_outlined,
    selectedIcon: Icons.insights,
    path: '/business-intelligence',
  ),
  _NavItem(
    icon: Icons.flag_outlined,
    selectedIcon: Icons.flag,
    path: '/business-strategy',
  ),
  _NavItem(
    icon: Icons.campaign_outlined,
    selectedIcon: Icons.campaign,
    path: '/marketing-strategy',
  ),
  _NavItem(
    icon: Icons.assignment_outlined,
    selectedIcon: Icons.assignment,
    path: '/intake',
  ),
  _NavItem(
    icon: Icons.business_outlined,
    selectedIcon: Icons.business,
    path: '/company',
  ),
  _NavItem(
    icon: Icons.fact_check_outlined,
    selectedIcon: Icons.fact_check,
    path: '/audit',
  ),
  _NavItem(
    icon: Icons.library_books_outlined,
    selectedIcon: Icons.library_books,
    path: '/knowledge',
  ),
  _NavItem(
    icon: Icons.smart_toy_outlined,
    selectedIcon: Icons.smart_toy,
    path: '/bot-test',
  ),
  _NavItem(
    icon: Icons.tune_outlined,
    selectedIcon: Icons.tune,
    path: '/bot-settings',
  ),
  _NavItem(
    icon: Icons.source_outlined,
    selectedIcon: Icons.source,
    path: '/sources',
  ),
  _NavItem(
    icon: Icons.rate_review_outlined,
    selectedIcon: Icons.rate_review,
    path: '/review',
  ),
];

int _indexFromLocation(String location) {
  if (location.startsWith('/dashboard')) return 0;
  if (location.startsWith('/next-actions')) return 1;
  if (location.startsWith('/check-in')) return 2;
  if (location.startsWith('/project-status')) return 3;
  if (location.startsWith('/business-intelligence')) return 4;
  if (location.startsWith('/business-strategy')) return 5;
  if (location.startsWith('/marketing-strategy')) return 6;
  if (location.startsWith('/intake')) return 7;
  if (location.startsWith('/company')) return 8;
  if (location.startsWith('/audit')) return 9;
  if (location.startsWith('/knowledge')) return 10;
  if (location.startsWith('/bot-test')) return 11;
  if (location.startsWith('/bot-settings')) return 12;
  if (location.startsWith('/sources')) return 13;
  if (location.startsWith('/review')) return 14;
  return 0;
}

List<String> _navLabels(AppLocalizations l) => [
  l.navDashboard,
  l.navNextActions,
  l.navCheckIn,
  l.navProjectStatus,
  l.navBusinessIntelligence,
  l.navBusinessStrategy,
  l.navMarketingStrategy,
  l.navIntake,
  l.navCompany,
  l.navAudit,
  l.navKnowledge,
  l.navBotTest,
  l.navBotSettings,
  l.navSources,
  l.navReview,
];

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentLocation;

  const AppShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = AppState.of(context);
    final auth = AuthController.of(context);
    final tenantSelection = TenantSelectionController.of(context);
    final labels = _navLabels(l);
    final selectedIndex = _indexFromLocation(currentLocation);
    if (!state.hasWorkspaces) {
      return _EmptyWorkspaceScaffold(
        title: _emptyWorkspaceTitle(state, l),
        message: _emptyWorkspaceMessage(state, l),
        onHome: () => context.go('/'),
        onLogout: auth.isSupabaseMode
            ? () async {
                await auth.signOut();
                if (context.mounted) context.go('/login');
              }
            : null,
      );
    }
    final company = state.selectedCompany;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return Scaffold(
            appBar: AppBar(
              title: Text(company.name),
              actions: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LanguageSwitcher(compact: true),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(child: Text(_authLabel(auth, l))),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(auth.isSupabaseMode ? 140 : 52),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: _ShellTextButton(
                                onPressed: () => context.go('/'),
                                icon: const Icon(Icons.home_outlined, size: 18),
                                label: Text(l.navHome),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: _ShellTextButton(
                                onPressed: () => context.go('/companies'),
                                icon: const Icon(Icons.swap_horiz, size: 18),
                                label: Text(l.companySwitch),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (auth.isSupabaseMode) ...[
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: _ShellTextButton(
                            onPressed: state.isSavingWorkspace
                                ? null
                                : () => context.go('/select-tenant?switch=1'),
                            icon: const Icon(
                              Icons.business_center_outlined,
                              size: 18,
                            ),
                            label: Text(l.tenantSwitch),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: _ShellTextButton(
                            onPressed: () async {
                              await auth.signOut();
                              if (context.mounted) context.go('/login');
                            },
                            icon: const Icon(Icons.logout, size: 18),
                            label: Text(l.authLogout),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            body: _DemoAwareContent(child: child),
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => context.go(_navItems[i].path),
              destinations: List.generate(
                _navItems.length,
                (i) => NavigationDestination(
                  icon: Icon(_navItems[i].icon),
                  selectedIcon: Icon(_navItems[i].selectedIcon),
                  label: labels[i],
                ),
              ),
            ),
          );
        }

        final extended = constraints.maxWidth >= 1200;

        return Scaffold(
          body: Row(
            children: [
              _DesktopSidebar(
                extended: extended,
                selectedIndex: selectedIndex,
                onDestinationSelected: (i) => context.go(_navItems[i].path),
                labels: labels,
                header: _AppLogo(
                  extended: extended,
                  l: l,
                  companyName: company.name,
                  tenantName:
                      tenantSelection.activeTenantName ??
                      auth.tenantContext?.tenantName,
                  tenantRole: auth.tenantContext?.role,
                  authLabel: _authLabel(auth, l),
                  showLogout: auth.isSupabaseMode,
                  showTenantSwitcher: auth.isSupabaseMode,
                  onGoHome: () => context.go('/'),
                  onSwitchCompany: () => context.go('/companies'),
                  onSwitchTenant: state.isSavingWorkspace
                      ? null
                      : () => context.go('/select-tenant?switch=1'),
                  onLogout: () async {
                    await auth.signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: _DemoAwareContent(child: child)),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final bool extended;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<String> labels;
  final Widget header;

  const _DesktopSidebar({
    required this.extended,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.labels,
    required this.header,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = extended ? 256.0 : 80.0;

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          width: width,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: header,
              ),
              for (var i = 0; i < _navItems.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: _SidebarNavItem(
                    extended: extended,
                    selected: i == selectedIndex,
                    icon: _navItems[i].icon,
                    selectedIcon: _navItems[i].selectedIcon,
                    label: labels[i],
                    onTap: () => onDestinationSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final bool extended;
  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.extended,
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onSurfaceVariant;
    final background = selected
        ? theme.colorScheme.secondaryContainer
        : Colors.transparent;

    return Tooltip(
      message: extended ? '' : label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: EdgeInsets.symmetric(
            horizontal: extended ? 14 : 0,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: extended
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(selected ? selectedIcon : icon, color: color),
              if (extended) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
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

String _emptyWorkspaceTitle(AppState state, AppLocalizations l) {
  return switch (state.workspaceLoadStatus) {
    WorkspaceLoadStatus.loading => l.workspaceLoadingTitle,
    WorkspaceLoadStatus.onboardingRequired => l.workspaceOnboardingTitle,
    WorkspaceLoadStatus.error => l.workspaceErrorTitle,
    _ => l.workspaceEmptyTitle,
  };
}

String _emptyWorkspaceMessage(AppState state, AppLocalizations l) {
  return switch (state.workspaceLoadStatus) {
    WorkspaceLoadStatus.loading => l.workspaceLoadingMessage,
    WorkspaceLoadStatus.onboardingRequired => l.workspaceOnboardingMessage,
    WorkspaceLoadStatus.error => l.workspaceErrorMessage,
    _ => l.workspaceEmptyMessage,
  };
}

class _EmptyWorkspaceScaffold extends StatelessWidget {
  const _EmptyWorkspaceScaffold({
    required this.title,
    required this.message,
    required this.onHome,
    this.onLogout,
  });

  final String title;
  final String message;
  final VoidCallback onHome;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.appName)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: onHome,
                      icon: const Icon(Icons.home_outlined),
                      label: Text(l.navHome),
                    ),
                    if (onLogout != null)
                      OutlinedButton.icon(
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout),
                        label: Text(l.authLogout),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _authLabel(AuthController auth, AppLocalizations l) {
  if (auth.isLocalMode) return l.authLocalMode;
  final user = auth.user;
  final name = user?.displayName;
  if (name != null && name.trim().isNotEmpty) return name;
  final email = user?.email;
  if (email != null && email.trim().isNotEmpty) return email;
  return l.authSignedIn;
}

class _AppLogo extends StatelessWidget {
  final bool extended;
  final AppLocalizations l;
  final String companyName;
  final String? tenantName;
  final String? tenantRole;
  final String authLabel;
  final bool showLogout;
  final bool showTenantSwitcher;
  final VoidCallback onGoHome;
  final VoidCallback onSwitchCompany;
  final VoidCallback? onSwitchTenant;
  final VoidCallback onLogout;

  const _AppLogo({
    required this.extended,
    required this.l,
    required this.companyName,
    this.tenantName,
    this.tenantRole,
    required this.authLabel,
    required this.showLogout,
    required this.showTenantSwitcher,
    required this.onGoHome,
    required this.onSwitchCompany,
    required this.onSwitchTenant,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (extended) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hub_rounded, size: 34, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            l.appName,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l.appStage,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const LanguageSwitcher(compact: true),
          const SizedBox(height: 14),
          Container(
            width: 180,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Text(
                  tenantName == null ? l.companyCurrent : l.tenantCurrent,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tenantName ?? companyName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (tenantRole != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _roleLabel(tenantRole!, l),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  authLabel,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: _ShellTextButton(
                    onPressed: onGoHome,
                    icon: const Icon(Icons.home_outlined, size: 16),
                    label: Text(l.navHome),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: _ShellTextButton(
                    onPressed: onSwitchCompany,
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: Text(l.companySwitch),
                  ),
                ),
                if (showTenantSwitcher) ...[
                  const SizedBox(height: 2),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: _ShellTextButton(
                      onPressed: onSwitchTenant,
                      icon: const Icon(
                        Icons.business_center_outlined,
                        size: 16,
                      ),
                      label: Text(l.tenantSwitch),
                    ),
                  ),
                ],
                if (showLogout) ...[
                  const SizedBox(height: 2),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: _ShellTextButton(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout, size: 16),
                      label: Text(l.authLogout),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.hub_rounded, size: 28, color: theme.colorScheme.primary),
        const SizedBox(height: 10),
        const LanguageSwitcher(compact: true),
        const SizedBox(height: 14),
        IconButton(
          tooltip: l.navHome,
          onPressed: onGoHome,
          icon: const Icon(Icons.home_outlined),
        ),
        IconButton(
          tooltip: l.companySwitch,
          onPressed: onSwitchCompany,
          icon: const Icon(Icons.swap_horiz),
        ),
        if (showTenantSwitcher)
          IconButton(
            tooltip: l.tenantSwitch,
            onPressed: onSwitchTenant,
            icon: const Icon(Icons.business_center_outlined),
          ),
        if (showLogout)
          IconButton(
            tooltip: l.authLogout,
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
          ),
      ],
    );
  }
}

String _roleLabel(String role, AppLocalizations l) {
  return switch (role) {
    'owner' => l.tenantRoleOwner,
    'admin' => l.tenantRoleAdmin,
    'editor' => l.tenantRoleEditor,
    'reviewer' => l.tenantRoleReviewer,
    _ => l.tenantRoleViewer,
  };
}

class _ShellTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Text label;

  const _ShellTextButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          icon,
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label.data ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: label.style,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wraps screen content with the demo banner and the light guided tour
/// while the competition demo runs; renders the plain content otherwise.
class _DemoAwareContent extends StatelessWidget {
  final Widget child;

  const _DemoAwareContent({required this.child});

  @override
  Widget build(BuildContext context) {
    final demo = DemoModeController.of(context);
    if (!demo.isActive) return child;
    return Column(
      children: [
        const _DemoBanner(),
        if (demo.isTourVisible) const _DemoTourBanner(),
        Expanded(child: child),
      ],
    );
  }
}

/// Clearly visible but unobtrusive: "Demo-Modus" plus the exit actions.
class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final demo = DemoModeController.of(context);
    final auth = AuthController.of(context);

    return Material(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 6,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 18,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  l.demoBadgeLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (auth.isSupabaseMode)
                  TextButton(
                    onPressed: () async {
                      await demo.exitDemo();
                      if (context.mounted) context.go('/login');
                    },
                    child: Text(l.demoCreateOwnButton),
                  ),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    await demo.exitDemo();
                    if (context.mounted) context.go('/');
                  },
                  icon: const Icon(Icons.logout, size: 16),
                  label: Text(l.demoLeaveButton),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Light guided tour: four suggested steps as tappable chips, dismissible
/// at any time. Deliberately no tour package — a simple banner suffices.
class _DemoTourBanner extends StatelessWidget {
  const _DemoTourBanner();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final demo = DemoModeController.of(context);

    final steps = <(String, String)>[
      (l.demoTourStep1, '/companies'),
      (l.demoTourStep2, '/review'),
      (l.demoTourStep3, '/review'),
      (l.demoTourStep4, '/audit'),
    ];

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l.demoTourTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  for (final (label, route) in steps)
                    ActionChip(
                      label: Text(label),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => context.go(route),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: l.demoTourDismiss,
              icon: const Icon(Icons.close, size: 18),
              onPressed: demo.dismissTour,
            ),
          ],
        ),
      ),
    );
  }
}
