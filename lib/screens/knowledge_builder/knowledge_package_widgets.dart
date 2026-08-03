import 'package:flutter/material.dart';

import '../../knowledge_builder/models/company_knowledge_package.dart';
import '../../l10n/app_localizations.dart';

class KnowledgePackageDemoCard extends StatelessWidget {
  const KnowledgePackageDemoCard({
    super.key,
    required this.package,
    required this.onLoad,
  });

  final CompanyKnowledgePackage package;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final language = Localizations.localeOf(context).languageCode;
    return Container(
      key: Key('kb-package-card-${package.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.tertiaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(90)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withAlpha(205),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l.kbPackageBadge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                package.title(language),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                package.description(language),
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ],
          );
          final button = FilledButton.icon(
            key: Key('kb-load-package-${package.id}'),
            onPressed: onLoad,
            icon: const Icon(Icons.inventory_2_outlined),
            label: Text(l.kbPackageLoad),
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [text, const SizedBox(height: 16), button],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.hub_outlined,
                size: 42,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(child: text),
              const SizedBox(width: 18),
              button,
            ],
          );
        },
      ),
    );
  }
}

class LoadedKnowledgePackageNotice extends StatelessWidget {
  const LoadedKnowledgePackageNotice({super.key, required this.package});

  final CompanyKnowledgePackage package;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final languageLabel = languageCode == 'de'
        ? l.kbLanguageGerman
        : l.kbLanguageEnglish;
    return Container(
      key: const Key('kb-loaded-package-notice'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(90)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.kbPackageLoaded,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(l.kbPackageNotAnalyzed),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PackageStat(
                label: l.kbPackageDocuments,
                value: '${package.documents.length}',
              ),
              _PackageStat(label: l.kbPackageLanguage, value: languageLabel),
              _PackageStat(
                label: l.kbPackageAreas,
                value: '${package.includedAreas(languageCode).length}',
              ),
              _PackageStat(
                label: l.kbPackageTimeSensitive,
                value: '${package.timeSensitiveDocumentCount}',
              ),
              _PackageStat(
                label: l.kbPackageReviewRequired,
                value: '${package.reviewRequiredDocumentCount}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l.kbPackageIncludedAreas,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final area in package.includedAreas(languageCode))
                Chip(label: Text(area), visualDensity: VisualDensity.compact),
            ],
          ),
          const SizedBox(height: 14),
          ExpansionTile(
            key: const Key('kb-package-source-documents'),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Text(
              l.kbPackageSourcesTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(l.kbPackageSourcesHint),
            children: [
              for (final document in package.documents)
                _PackageDocumentCard(
                  document: document,
                  languageCode: languageCode,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class KnowledgePackageDraftMetadata extends StatelessWidget {
  const KnowledgePackageDraftMetadata({super.key, required this.metadata});

  final KnowledgePackageDocumentMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: const Key('kb-draft-package-metadata'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              if (metadata.risk.requiresExplicitReview)
                _MetadataBadge(
                  icon: Icons.gavel_outlined,
                  label: _riskLabel(l, metadata.risk.type),
                  warning: true,
                ),
              if (metadata.freshness.timeSensitive)
                _MetadataBadge(
                  icon: Icons.schedule,
                  label: l.kbPackageTimeSensitiveBadge,
                  warning: true,
                ),
            ],
          ),
          if (metadata.risk.requiresExplicitReview ||
              metadata.freshness.timeSensitive)
            const SizedBox(height: 7),
          _MetadataLine(
            label: l.kbPackageSourceLabel,
            value: metadata.sourceName,
          ),
          _MetadataLine(
            label: l.kbPackageSourceTypeLabel,
            value: metadata.sourceType,
          ),
          _MetadataLine(
            label: l.kbPackageDataStatusLabel,
            value: metadata.dataStatus,
          ),
          if (metadata.freshness.lastChecked case final checked?)
            _MetadataLine(
              label: l.kbPackageLastCheckedLabel,
              value: _dateLabel(
                checked,
                Localizations.localeOf(context).languageCode,
              ),
            ),
          if (metadata.freshness.reviewRecommended)
            _MetadataLine(
              label: l.kbPackageReviewRecommendedLabel,
              value: l.kbPackageReviewRecommended,
            ),
        ],
      ),
    );
  }
}

class _PackageStat extends StatelessWidget {
  const _PackageStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(205),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$label: $value', style: theme.textTheme.labelMedium),
    );
  }
}

class _PackageDocumentCard extends StatelessWidget {
  const _PackageDocumentCard({
    required this.document,
    required this.languageCode,
  });

  final KnowledgePackageDocument document;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final metadata = document.metadata(languageCode);
    final normalizedContent = document
        .content(languageCode)
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final excerpt = normalizedContent.length <= 210
        ? normalizedContent
        : '${normalizedContent.substring(0, 209).trimRight()}…';
    return Card(
      key: Key('kb-package-document-${document.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surface,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 7,
              runSpacing: 7,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  metadata.area,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (metadata.freshness.timeSensitive)
                  _MetadataBadge(
                    icon: Icons.schedule,
                    label: l.kbPackageTimeSensitiveBadge,
                    warning: true,
                  ),
                if (metadata.risk.requiresExplicitReview)
                  _MetadataBadge(
                    icon: Icons.gavel_outlined,
                    label: _riskLabel(l, metadata.risk.type),
                    warning: true,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(metadata.documentType, style: theme.textTheme.bodySmall),
            const SizedBox(height: 9),
            Text(excerpt, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 10),
            _MetadataLine(
              label: l.kbPackageSourceLabel,
              value: metadata.sourceName,
            ),
            _MetadataLine(
              label: l.kbPackageSourceTypeLabel,
              value: metadata.sourceType,
            ),
            _MetadataLine(
              label: l.kbPackageDataStatusLabel,
              value: metadata.dataStatus,
            ),
            if (metadata.freshness.lastChecked case final checked?)
              _MetadataLine(
                label: l.kbPackageLastCheckedLabel,
                value: _dateLabel(checked, languageCode),
              ),
            if (metadata.freshness.reviewRecommended)
              _MetadataLine(
                label: l.kbPackageReviewRecommendedLabel,
                value: l.kbPackageReviewRecommended,
              ),
          ],
        ),
      ),
    );
  }
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}

class _MetadataBadge extends StatelessWidget {
  const _MetadataBadge({
    required this.icon,
    required this.label,
    required this.warning,
  });

  final IconData icon;
  final String label;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = warning
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.secondaryContainer;
    final foreground = warning
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

String _riskLabel(AppLocalizations l, KnowledgePackageRiskType risk) =>
    switch (risk) {
      KnowledgePackageRiskType.standard => '',
      KnowledgePackageRiskType.legalOrProfessionalReview =>
        l.kbPackageRiskReview,
      KnowledgePackageRiskType.impactRelatedClaim => l.kbPackageRiskImpact,
      KnowledgePackageRiskType.testimonial => l.kbPackageRiskTestimonial,
    };

String _dateLabel(DateTime date, String languageCode) => languageCode == 'de'
    ? '${date.day.toString().padLeft(2, '0')}.'
          '${date.month.toString().padLeft(2, '0')}.${date.year}'
    : '${date.year}-${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
