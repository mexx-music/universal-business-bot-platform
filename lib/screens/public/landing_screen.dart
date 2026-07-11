import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/company_workspace.dart';
import '../../platform/pwa_install.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  static bool _pwaHintDismissedInSession = false;

  late final PwaInstallController _pwaInstallController;
  late bool _pwaHintDismissed;

  @override
  void initState() {
    super.initState();
    _pwaInstallController = PwaInstallController();
    _pwaHintDismissed = _pwaHintDismissedInSession;
  }

  @override
  void dispose() {
    _pwaInstallController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 520;
                      final brand = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hub_rounded,
                            color: theme.colorScheme.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              l.appName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                      final companyButton = TextButton.icon(
                        onPressed: () => context.go('/companies'),
                        icon: const Icon(Icons.business_outlined, size: 18),
                        label: Text(l.companySelectTitle),
                      );

                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            brand,
                            const SizedBox(height: 8),
                            companyButton,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: brand),
                          const SizedBox(width: 16),
                          companyButton,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 52),
                  Text(
                    l.landingHeadline,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Text(
                      l.landingSubtitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _PwaInstallNotice(
                    controller: _pwaInstallController,
                    dismissed: _pwaHintDismissed,
                    onDismiss: () {
                      setState(() {
                        _pwaHintDismissed = true;
                        _pwaHintDismissedInSession = true;
                      });
                    },
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _FeaturePill(
                        icon: Icons.library_books_outlined,
                        label: l.landingFeatureKnowledge,
                      ),
                      _FeaturePill(
                        icon: Icons.smart_toy_outlined,
                        label: l.landingFeatureBot,
                      ),
                      _FeaturePill(
                        icon: Icons.fact_check_outlined,
                        label: l.landingFeatureAudit,
                      ),
                      _FeaturePill(
                        icon: Icons.rate_review_outlined,
                        label: l.landingFeatureReview,
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Text(
                    l.landingStepsTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 820;
                      final steps = [
                        _StepCard(
                          number: '1',
                          title: l.landingStepCompanyTitle,
                          description: l.landingStepCompanyDescription,
                          icon: Icons.business_outlined,
                        ),
                        _StepCard(
                          number: '2',
                          title: l.landingStepKnowledgeTitle,
                          description: l.landingStepKnowledgeDescription,
                          icon: Icons.account_tree_outlined,
                        ),
                        _StepCard(
                          number: '3',
                          title: l.landingStepBotTitle,
                          description: l.landingStepBotDescription,
                          icon: Icons.verified_user_outlined,
                        ),
                      ];
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isWide ? 3 : 1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 154,
                        ),
                        itemCount: steps.length,
                        itemBuilder: (context, index) => steps[index],
                      );
                    },
                  ),
                  const SizedBox(height: 44),
                  Text(
                    l.landingDemoTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 900;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isWide ? 2 : 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: isWide ? 286 : 260,
                        ),
                        itemCount: state.companies.length,
                        itemBuilder: (context, index) => _DemoCompanyCard(
                          workspace: state.companies[index],
                          onOpen: () {
                            state.selectCompany(
                              state.companies[index].company.id,
                            );
                            context.go('/dashboard');
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PwaInstallNotice extends StatelessWidget {
  final PwaInstallController controller;
  final bool dismissed;
  final VoidCallback onDismiss;

  const _PwaInstallNotice({
    required this.controller,
    required this.dismissed,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final status = controller.status;
        if (dismissed || !status.isWeb || status.isStandalone) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 620;
                  final instruction = status.canInstall
                      ? null
                      : status.isLikelyIosSafari
                      ? l.landingPwaIosHint
                      : l.landingPwaBrowserMenuHint;
                  final textBlock = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.landingPwaHint, style: theme.textTheme.bodyMedium),
                      if (instruction != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          instruction,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  );
                  final actions = Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: compact
                        ? WrapAlignment.start
                        : WrapAlignment.end,
                    children: [
                      if (status.canInstall)
                        FilledButton(
                          onPressed: controller.promptInstall,
                          child: Text(l.landingPwaAddToHome),
                        ),
                      TextButton(
                        onPressed: onDismiss,
                        child: Text(l.landingPwaDismiss),
                      ),
                    ],
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textBlock,
                        const SizedBox(height: 12),
                        actions,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: textBlock),
                      const SizedBox(width: 16),
                      actions,
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    number,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, color: theme.colorScheme.primary, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 7),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoCompanyCard extends StatelessWidget {
  final CompanyWorkspace workspace;
  final VoidCallback onOpen;

  const _DemoCompanyCard({required this.workspace, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final company = workspace.company;
    final isSchnurrPurr = company.id == 'schnurr-purr';
    final accent = isSchnurrPurr ? Colors.teal : Colors.indigo;
    final icon = isSchnurrPurr
        ? Icons.spa_outlined
        : Icons.health_and_safety_outlined;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: accent.withAlpha(25),
                    child: Icon(icon, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          company.industry,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                company.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              Wrap(
                spacing: 18,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: _MiniMetric(
                      value: workspace.products.length,
                      label: l.companyProducts,
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: _MiniMetric(
                      value: workspace.knowledgeEntries.length,
                      label: l.statKnowledgeEntries,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 210),
                    child: FilledButton.icon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: Text(
                        l.landingOpenDemo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final int value;
  final String label;

  const _MiniMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
