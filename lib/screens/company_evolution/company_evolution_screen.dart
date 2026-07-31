import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';
import '../../research/company_evolution_controller.dart';
import '../../research/models/company_timeline_event.dart';
import '../../research/models/research_document.dart';
import '../../research/models/research_evidence.dart';

/// Company Evolution: the first visible surface of the Research Engine (G-5/6).
///
/// Reads exclusively through [CompanyEvolutionController] (→ ResearchRuntime).
/// No web research, no crawling, no AI in this block — only the local demo
/// bundles. Documents and evidence are shown separately, with evidence always
/// resolved via its document id.
class CompanyEvolutionScreen extends StatelessWidget {
  const CompanyEvolutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Depending on the scope here rebuilds the screen when the selection
    // changes (InheritedNotifier).
    final controller = CompanyEvolutionController.of(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(controller: controller),
                      const SizedBox(height: 12),
                      const _TrustNotice(),
                      const SizedBox(height: 16),
                      if (!controller.hasCompanies)
                        _EmptyState(message: l.companyEvolutionEmptyCompanies)
                      else if (wide)
                        _WideBody(controller: controller)
                      else
                        _NarrowBody(controller: controller),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final CompanyEvolutionController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l.companyEvolutionTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l.companyEvolutionSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (controller.hasCompanies) ...[
          const SizedBox(height: 16),
          _CompanySelector(controller: controller),
        ],
      ],
    );
  }
}

class _CompanySelector extends StatelessWidget {
  const _CompanySelector({required this.controller});

  final CompanyEvolutionController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: DropdownButtonFormField<String>(
        key: const Key('company-evolution-selector'),
        initialValue: controller.selectedCompanyId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: l.companyEvolutionSelectCompany,
          border: const OutlineInputBorder(),
        ),
        items: [
          for (final company in controller.companies)
            DropdownMenuItem(
              value: company.companyId,
              child: Text(company.companyName, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (value) {
          if (value != null) controller.selectCompany(value);
        },
      ),
    );
  }
}

class _WideBody extends StatelessWidget {
  const _WideBody({required this.controller});

  final CompanyEvolutionController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SnapshotSection(controller: controller),
              const SizedBox(height: 16),
              _TimelineSection(controller: controller),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: _SourcesSection(controller: controller)),
      ],
    );
  }
}

class _NarrowBody extends StatelessWidget {
  const _NarrowBody({required this.controller});

  final CompanyEvolutionController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SnapshotSection(controller: controller),
        const SizedBox(height: 16),
        _TimelineSection(controller: controller),
        const SizedBox(height: 16),
        _SourcesSection(controller: controller),
      ],
    );
  }
}

// --- Snapshot -------------------------------------------------------------

class _SnapshotSection extends StatelessWidget {
  const _SnapshotSection({required this.controller});

  final CompanyEvolutionController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final snapshot = controller.snapshot;
    if (snapshot == null) return const SizedBox.shrink();

    final rows = <Widget>[
      if (snapshot.industry.isNotEmpty)
        _FieldRow(
          label: l.companyEvolutionFieldIndustry,
          value: snapshot.industry,
        ),
      if (snapshot.foundedYear != null)
        _FieldRow(
          label: l.companyEvolutionFieldFounded,
          value: '${snapshot.foundedYear}',
        ),
      if (snapshot.marketSegment.isNotEmpty)
        _FieldRow(
          label: l.companyEvolutionFieldSegment,
          value: snapshot.marketSegment,
        ),
      if (snapshot.countries.isNotEmpty)
        _FieldRow(
          label: l.companyEvolutionFieldCountries,
          value: snapshot.countries.join(', '),
        ),
      if (snapshot.knownProducts.isNotEmpty)
        _FieldRow(
          label: l.companyEvolutionFieldProducts,
          value: snapshot.knownProducts.join(', '),
        ),
      if (snapshot.website.isNotEmpty)
        _FieldRow(
          label: l.companyEvolutionFieldWebsite,
          value: snapshot.website,
        ),
      if (snapshot.socialMedia.isNotEmpty)
        _FieldRow(
          label: l.companyEvolutionFieldSocial,
          value: snapshot.socialMedia.keys.join(', '),
        ),
      if (snapshot.rating != null)
        _FieldRow(
          label: l.companyEvolutionFieldRating,
          value: snapshot.rating!.toStringAsFixed(1),
        ),
      _FieldRow(
        label: l.companyEvolutionFieldUpdated,
        value: _formatDate(snapshot.capturedAt),
      ),
    ];

    return _SectionCard(
      title: l.companyEvolutionSnapshotTitle,
      icon: Icons.badge_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            snapshot.companyName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

// --- Timeline -------------------------------------------------------------

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.controller});

  final CompanyEvolutionController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final events = controller.timeline;
    return _SectionCard(
      title: l.companyEvolutionTimelineTitle,
      icon: Icons.history,
      child: events.isEmpty
          ? _EmptyState(message: l.companyEvolutionEmptyTimeline)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final event in events) _TimelineTile(event: event),
              ],
            ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.event});

  final CompanyTimelineEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.circle,
              size: 10,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _formatDate(event.date),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    _CategoryChip(
                      label: timelineCategoryLabel(context, event.category),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  event.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (event.description.isNotEmpty)
                  Text(event.description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Sources & evidence ---------------------------------------------------

class _SourcesSection extends StatelessWidget {
  const _SourcesSection({required this.controller});

  final CompanyEvolutionController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final documents = controller.documents;
    return _SectionCard(
      title: l.companyEvolutionSourcesTitle,
      icon: Icons.source_outlined,
      child: documents.isEmpty
          ? _EmptyState(message: l.companyEvolutionEmptyDocuments)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final doc in documents)
                  _DocumentCard(
                    document: doc,
                    evidence: controller.evidenceForDocument(doc.id),
                  ),
              ],
            ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document, required this.evidence});

  final ResearchDocument document;
  final List<ResearchEvidence> evidence;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      key: ValueKey('doc-${document.id}'),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _CategoryChip(
                  label: researchDocumentTypeLabel(
                    context,
                    document.documentType,
                  ),
                ),
                _MetaText(
                  '${l.companyEvolutionDocSource}: ${document.sourceName}',
                ),
                _MetaText(
                  '${l.companyEvolutionDocPublished}: '
                  '${_formatDate(document.publishedAt)}',
                ),
                _MetaText(
                  '${l.companyEvolutionDocLanguage}: '
                  '${document.language.toUpperCase()}',
                ),
                _MetaText(
                  '${l.companyEvolutionDocCountry}: ${document.country}',
                ),
              ],
            ),
            const SizedBox(height: 4),
            // URL shown as plain text only — no navigation into the web.
            Text(
              '${l.companyEvolutionDocUrl}: ${document.sourceUrl}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 20),
            Text(
              l.companyEvolutionEvidenceForDocument,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            if (evidence.isEmpty)
              _EmptyState(message: l.companyEvolutionEmptyEvidence)
            else
              for (final ev in evidence) _EvidenceTile(evidence: ev),
          ],
        ),
      ),
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({required this.evidence});

  final ResearchEvidence evidence;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      key: ValueKey('ev-${evidence.id}'),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  evidence.summary,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _CategoryChip(
                label: researchEvidenceCategoryLabel(
                  context,
                  evidence.category,
                ),
              ),
              _MetaText(
                '${l.companyEvolutionEvidenceConfidence}: '
                '${evidence.confidence}%',
              ),
              _MetaText(
                '${l.companyEvolutionEvidenceExtracted}: '
                '${_formatDate(evidence.extractedAt)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Shared bits ----------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

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
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
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

class _MetaText extends StatelessWidget {
  const _MetaText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _TrustNotice extends StatelessWidget {
  const _TrustNotice();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.companyEvolutionTrustTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.companyEvolutionTrustBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d.$m.${date.year}';
}
