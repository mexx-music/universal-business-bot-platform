import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../tenant_selection/tenant_selection_controller.dart';

class TenantSelectionScreen extends StatelessWidget {
  const TenantSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = AuthController.of(context);
    final controller = TenantSelectionController.of(context);
    final memberships = controller.memberships;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tenantSelectTitle),
        actions: [
          TextButton.icon(
            onPressed: controller.isSwitching
                ? null
                : () => controller.refresh(),
            icon: const Icon(Icons.refresh),
            label: Text(l.tenantRetry),
          ),
          TextButton.icon(
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: Text(l.authLogout),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.tenantSelectHeading,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.tenantSelectSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(message: l.tenantSwitchFailed),
                ],
                const SizedBox(height: 24),
                Expanded(
                  child: memberships.isEmpty
                      ? _EmptyTenantState(onRetry: controller.refresh)
                      : ListView.separated(
                          itemCount: memberships.length + 1,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == memberships.length) {
                              return _AddTenantPlaceholder();
                            }
                            final membership = memberships[index];
                            final isActive =
                                membership.tenantId ==
                                controller.activeTenantId;
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final narrow = constraints.maxWidth < 560;
                                    final details = _TenantDetails(
                                      role: _roleLabel(membership.role, l),
                                      workspaceCount: membership.workspaceCount,
                                      isActive: isActive,
                                    );
                                    final button = FilledButton.icon(
                                      onPressed:
                                          controller.isSwitching || isActive
                                          ? null
                                          : () async {
                                              final ok = await controller
                                                  .selectTenant(
                                                    membership.tenantId,
                                                  );
                                              if (ok && context.mounted) {
                                                context.go('/dashboard');
                                              }
                                            },
                                      icon: controller.isSwitching
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.open_in_new),
                                      label: Text(
                                        isActive
                                            ? l.tenantCurrent
                                            : l.tenantOpen,
                                      ),
                                    );

                                    if (narrow) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _TenantTitle(
                                            name: membership.tenantName,
                                            isActive: isActive,
                                          ),
                                          const SizedBox(height: 12),
                                          details,
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: button,
                                          ),
                                        ],
                                      );
                                    }

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _TenantTitle(
                                                name: membership.tenantName,
                                                isActive: isActive,
                                              ),
                                              const SizedBox(height: 10),
                                              details,
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        button,
                                      ],
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}

class _TenantTitle extends StatelessWidget {
  const _TenantTitle({required this.name, required this.isActive});

  final String name;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Row(
      children: [
        Icon(
          isActive ? Icons.check_circle : Icons.business_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (isActive)
          Chip(
            avatar: const Icon(Icons.check, size: 16),
            label: Text(l.tenantCurrent),
          ),
      ],
    );
  }
}

class _TenantDetails extends StatelessWidget {
  const _TenantDetails({
    required this.role,
    required this.workspaceCount,
    required this.isActive,
  });

  final String role;
  final int? workspaceCount;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(
          avatar: const Icon(Icons.verified_user_outlined, size: 16),
          label: Text('${l.tenantCurrentRole}: $role'),
        ),
        if (workspaceCount != null)
          Chip(
            avatar: const Icon(Icons.workspaces_outline, size: 16),
            label: Text(l.tenantWorkspaceCount(workspaceCount!)),
          ),
        if (isActive)
          Chip(
            avatar: const Icon(Icons.lock_open_outlined, size: 16),
            label: Text(l.tenantAccessActive),
          ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
    );
  }
}

class _EmptyTenantState extends StatelessWidget {
  const _EmptyTenantState({required this.onRetry});

  final Future<bool> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.business_center_outlined, size: 48),
          const SizedBox(height: 12),
          Text(l.tenantNoneTitle),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l.tenantRetry),
          ),
        ],
      ),
    );
  }
}

class _AddTenantPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.add_business_outlined),
        title: Text(l.tenantAddPlaceholder),
        subtitle: Text(l.tenantAddPlaceholderSubtitle),
        enabled: false,
      ),
    );
  }
}
