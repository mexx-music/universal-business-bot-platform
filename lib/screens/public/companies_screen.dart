import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/company_workspace.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.companySelectTitle),
        leading: IconButton(
          tooltip: l.landingBackHome,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l.companySelectHeadline,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.companySelectSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          if (state.companies.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.workspaceLoadStatus == WorkspaceLoadStatus.error
                          ? l.workspaceErrorTitle
                          : l.workspaceEmptyTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.workspaceLoadStatus == WorkspaceLoadStatus.error
                          ? l.workspaceErrorMessage
                          : l.workspaceEmptyMessage,
                    ),
                  ],
                ),
              ),
            ),
          ...state.companies.map(
            (workspace) => _CompanySelectionCard(
              workspace: workspace,
              selected: workspace.company.id == state.selectedCompanyId,
              auditScore: (state.auditScoreFor(workspace) * 100).round(),
              openReviews: state.openReviewCountFor(workspace),
              onSelect: () {
                state.selectCompany(workspace.company.id);
                context.go('/dashboard');
              },
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.add_business_outlined),
            label: Text(l.companyCreatePlaceholder),
          ),
        ],
      ),
    );
  }
}

class _CompanySelectionCard extends StatelessWidget {
  final CompanyWorkspace workspace;
  final bool selected;
  final int auditScore;
  final int openReviews;
  final VoidCallback onSelect;

  const _CompanySelectionCard({
    required this.workspace,
    required this.selected,
    required this.auditScore,
    required this.openReviews,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final company = workspace.company;
    final isSchnurrPurr = company.id == 'schnurr-purr';
    final accent = isSchnurrPurr ? Colors.teal : Colors.indigo;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onSelect,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 560;
            final content = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: accent.withAlpha(25),
                  child: Icon(
                    isSchnurrPurr
                        ? Icons.spa_outlined
                        : Icons.health_and_safety_outlined,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              company.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        company.industry,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        company.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _CountChip(
                            icon: Icons.fact_check_outlined,
                            label: l.companyAuditScore(auditScore),
                          ),
                          _CountChip(
                            icon: Icons.library_books_outlined,
                            label: l.companyKnowledgeCount(
                              workspace.knowledgeEntries.length,
                            ),
                          ),
                          _CountChip(
                            icon: Icons.rate_review_outlined,
                            label: l.companyOpenReviewCount(openReviews),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );

            return Padding(
              padding: const EdgeInsets.all(18),
              child: compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        content,
                        const SizedBox(height: 14),
                        FilledButton.tonal(
                          onPressed: onSelect,
                          child: Text(l.companySelectButton),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: content),
                        const SizedBox(width: 12),
                        FilledButton.tonal(
                          onPressed: onSelect,
                          child: Text(l.companySelectButton),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CountChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
