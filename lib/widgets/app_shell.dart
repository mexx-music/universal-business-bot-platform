import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/app_state.dart';
import '../l10n/app_localizations.dart';

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
  if (location.startsWith('/company')) return 1;
  if (location.startsWith('/audit')) return 2;
  if (location.startsWith('/knowledge')) return 3;
  if (location.startsWith('/bot-test')) return 4;
  if (location.startsWith('/sources')) return 5;
  if (location.startsWith('/review')) return 6;
  return 0;
}

List<String> _navLabels(AppLocalizations l) => [
  l.navDashboard,
  l.navCompany,
  l.navAudit,
  l.navKnowledge,
  l.navBotTest,
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
    final labels = _navLabels(l);
    final selectedIndex = _indexFromLocation(currentLocation);
    final company = state.selectedCompany;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return Scaffold(
            appBar: AppBar(
              title: Text(company.name),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
                  child: Row(
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
                ),
              ),
            ),
            body: child,
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
              NavigationRail(
                extended: extended,
                selectedIndex: selectedIndex,
                onDestinationSelected: (i) => context.go(_navItems[i].path),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: _AppLogo(
                    extended: extended,
                    l: l,
                    companyName: company.name,
                    onGoHome: () => context.go('/'),
                    onSwitchCompany: () => context.go('/companies'),
                  ),
                ),
                destinations: List.generate(
                  _navItems.length,
                  (i) => NavigationRailDestination(
                    icon: Icon(_navItems[i].icon),
                    selectedIcon: Icon(_navItems[i].selectedIcon),
                    label: Text(labels[i]),
                  ),
                ),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

class _AppLogo extends StatelessWidget {
  final bool extended;
  final AppLocalizations l;
  final String companyName;
  final VoidCallback onGoHome;
  final VoidCallback onSwitchCompany;

  const _AppLogo({
    required this.extended,
    required this.l,
    required this.companyName,
    required this.onGoHome,
    required this.onSwitchCompany,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = Localizations.localeOf(context).languageCode.toUpperCase();
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
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  langCode,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
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
                  l.companyCurrent,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  companyName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
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
      ],
    );
  }
}

class _ShellTextButton extends StatelessWidget {
  final VoidCallback onPressed;
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
