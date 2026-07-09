import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/source_material.dart';

class SourcesScreen extends StatefulWidget {
  const SourcesScreen({super.key});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> {
  SourceMaterialType? _typeFilter;
  SourceMaterialStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sources = state.sourceMaterials.where((source) {
      final typeMatches = _typeFilter == null || source.type == _typeFilter;
      final statusMatches =
          _statusFilter == null || source.status == _statusFilter;
      return typeMatches && statusMatches;
    }).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.sourcesTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.sourcesSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _openEditor(context, state),
                icon: const Icon(Icons.add),
                label: Text(l.sourcesAdd),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SummaryChip(
                icon: Icons.source_outlined,
                label: l.sourcesCount(state.sourceMaterialCount),
                color: theme.colorScheme.primary,
              ),
              _SummaryChip(
                icon: Icons.fiber_new_outlined,
                label: l.sourcesNewCount(state.newSourceMaterialCount),
                color: state.newSourceMaterialCount > 0
                    ? Colors.orange
                    : Colors.green,
              ),
              _SummaryChip(
                icon: Icons.library_books_outlined,
                label: l.sourcesEntriesCount(state.knowledgeEntries.length),
                color: Colors.teal,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _FilterBar(
            typeFilter: _typeFilter,
            statusFilter: _statusFilter,
            onTypeChanged: (value) => setState(() => _typeFilter = value),
            onStatusChanged: (value) => setState(() => _statusFilter = value),
          ),
          const SizedBox(height: 18),
          if (sources.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text(l.sourcesEmpty)),
            )
          else
            ...sources.map(
              (source) => _SourceMaterialCard(
                source: source,
                onEdit: () => _openEditor(context, state, source: source),
                onDelete: () => _confirmDelete(context, state, source),
                onStatusChanged: (status) {
                  state.updateSourceMaterial(
                    source.copyWith(status: status, updatedAt: DateTime.now()),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _openEditor(
    BuildContext context,
    AppState state, {
    SourceMaterial? source,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => _SourceMaterialDialog(state: state, source: source),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AppState state,
    SourceMaterial source,
  ) {
    final l = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.sourcesDeleteTitle),
        content: Text(l.sourcesDeleteConfirm(source.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.btnCancel),
          ),
          FilledButton(
            onPressed: () {
              state.deleteSourceMaterial(source.id);
              Navigator.of(context).pop();
            },
            child: Text(l.btnDelete),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final SourceMaterialType? typeFilter;
  final SourceMaterialStatus? statusFilter;
  final ValueChanged<SourceMaterialType?> onTypeChanged;
  final ValueChanged<SourceMaterialStatus?> onStatusChanged;

  const _FilterBar({
    required this.typeFilter,
    required this.statusFilter,
    required this.onTypeChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: Text(l.sourcesFilterAllTypes),
          selected: typeFilter == null,
          onSelected: (_) => onTypeChanged(null),
        ),
        ...SourceMaterialType.values.map(
          (type) => FilterChip(
            label: Text(sourceTypeLabel(l, type)),
            selected: typeFilter == type,
            onSelected: (_) => onTypeChanged(type),
          ),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: Text(l.sourcesFilterAllStatuses),
          selected: statusFilter == null,
          onSelected: (_) => onStatusChanged(null),
        ),
        ...SourceMaterialStatus.values.map(
          (status) => FilterChip(
            label: Text(sourceStatusLabel(l, status)),
            selected: statusFilter == status,
            onSelected: (_) => onStatusChanged(status),
          ),
        ),
      ],
    );
  }
}

class _SourceMaterialCard extends StatelessWidget {
  final SourceMaterial source;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<SourceMaterialStatus> onStatusChanged;

  const _SourceMaterialCard({
    required this.source,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = _statusColor(source.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withAlpha(25),
                  child: Icon(_typeIcon(source.type), color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MiniBadge(label: sourceTypeLabel(l, source.type)),
                          _MiniBadge(
                            label: sourceStatusLabel(l, source.status),
                            color: color,
                          ),
                          _MiniBadge(
                            label: l.sourcesLinkedEntries(
                              source.relatedKnowledgeEntryIds.length,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text(l.btnEdit)),
                    PopupMenuItem(value: 'delete', child: Text(l.btnDelete)),
                  ],
                ),
              ],
            ),
            if (source.url != null && source.url!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _InfoLine(icon: Icons.link, text: source.url!),
            ],
            if (source.contentSnippet != null &&
                source.contentSnippet!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(source.contentSnippet!),
            ],
            if (source.notes != null && source.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _InfoLine(
                icon: Icons.sticky_note_2_outlined,
                text: source.notes!,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SourceMaterialStatus.values
                  .map(
                    (status) => ChoiceChip(
                      label: Text(sourceStatusLabel(l, status)),
                      selected: source.status == status,
                      onSelected: (_) => onStatusChanged(status),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceMaterialDialog extends StatefulWidget {
  final AppState state;
  final SourceMaterial? source;

  const _SourceMaterialDialog({required this.state, this.source});

  @override
  State<_SourceMaterialDialog> createState() => _SourceMaterialDialogState();
}

class _SourceMaterialDialogState extends State<_SourceMaterialDialog> {
  late final TextEditingController _title;
  late final TextEditingController _url;
  late final TextEditingController _snippet;
  late final TextEditingController _notes;
  late SourceMaterialType _type;
  late SourceMaterialStatus _status;

  @override
  void initState() {
    super.initState();
    final source = widget.source;
    _title = TextEditingController(text: source?.title ?? '');
    _url = TextEditingController(text: source?.url ?? '');
    _snippet = TextEditingController(text: source?.contentSnippet ?? '');
    _notes = TextEditingController(text: source?.notes ?? '');
    _type = source?.type ?? SourceMaterialType.website;
    _status = source?.status ?? SourceMaterialStatus.newItem;
  }

  @override
  void dispose() {
    _title.dispose();
    _url.dispose();
    _snippet.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.source == null ? l.sourcesAdd : l.sourcesEdit),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(l.fieldTitle, _title),
              _dropdown<SourceMaterialType>(
                label: l.sourcesType,
                value: _type,
                values: SourceMaterialType.values,
                itemLabel: (type) => sourceTypeLabel(l, type),
                onChanged: (value) => setState(() => _type = value),
              ),
              const SizedBox(height: 12),
              _dropdown<SourceMaterialStatus>(
                label: l.sourcesStatus,
                value: _status,
                values: SourceMaterialStatus.values,
                itemLabel: (status) => sourceStatusLabel(l, status),
                onChanged: (value) => setState(() => _status = value),
              ),
              const SizedBox(height: 12),
              _field(l.sourcesUrlOptional, _url),
              _field(l.sourcesSnippetOptional, _snippet, maxLines: 4),
              _field(l.sourcesNotesOptional, _notes, maxLines: 3),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.btnCancel),
        ),
        FilledButton(
          onPressed: _title.text.trim().isEmpty ? null : _save,
          child: Text(l.btnSave),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T value) itemLabel,
    required ValueChanged<T> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: values
            .map(
              (value) =>
                  DropdownMenuItem(value: value, child: Text(itemLabel(value))),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }

  void _save() {
    final now = DateTime.now();
    final source = widget.source;
    final url = _url.text.trim();
    final snippet = _snippet.text.trim();
    final notes = _notes.text.trim();
    if (source == null) {
      widget.state.addSourceMaterial(
        SourceMaterial(
          id: 'sm_${now.microsecondsSinceEpoch}',
          title: _title.text.trim(),
          type: _type,
          url: url.isEmpty ? null : url,
          contentSnippet: snippet.isEmpty ? null : snippet,
          status: _status,
          createdAt: now,
          updatedAt: now,
          notes: notes.isEmpty ? null : notes,
        ),
      );
    } else {
      widget.state.updateSourceMaterial(
        source.copyWith(
          title: _title.text.trim(),
          type: _type,
          url: url.isEmpty ? null : url,
          contentSnippet: snippet.isEmpty ? null : snippet,
          status: _status,
          updatedAt: now,
          notes: notes.isEmpty ? null : notes,
        ),
      );
    }
    Navigator.of(context).pop();
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const _MiniBadge({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: resolvedColor.withAlpha(22),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: resolvedColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
      ],
    );
  }
}

String sourceTypeLabel(AppLocalizations l, SourceMaterialType type) {
  return switch (type) {
    SourceMaterialType.website => l.sourceMaterialTypeWebsite,
    SourceMaterialType.pdf => l.sourceMaterialTypePdf,
    SourceMaterialType.faq => l.sourceMaterialTypeFaq,
    SourceMaterialType.review => l.sourceMaterialTypeReview,
    SourceMaterialType.social => l.sourceMaterialTypeSocial,
    SourceMaterialType.note => l.sourceMaterialTypeNote,
    SourceMaterialType.other => l.sourceMaterialTypeOther,
  };
}

String sourceStatusLabel(AppLocalizations l, SourceMaterialStatus status) {
  return switch (status) {
    SourceMaterialStatus.newItem => l.sourceMaterialStatusNew,
    SourceMaterialStatus.reviewed => l.sourceMaterialStatusReviewed,
    SourceMaterialStatus.converted => l.sourceMaterialStatusConverted,
    SourceMaterialStatus.ignored => l.sourceMaterialStatusIgnored,
  };
}

IconData _typeIcon(SourceMaterialType type) {
  return switch (type) {
    SourceMaterialType.website => Icons.language,
    SourceMaterialType.pdf => Icons.picture_as_pdf_outlined,
    SourceMaterialType.faq => Icons.help_outline,
    SourceMaterialType.review => Icons.reviews_outlined,
    SourceMaterialType.social => Icons.campaign_outlined,
    SourceMaterialType.note => Icons.edit_note,
    SourceMaterialType.other => Icons.source_outlined,
  };
}

Color _statusColor(SourceMaterialStatus status) {
  return switch (status) {
    SourceMaterialStatus.newItem => Colors.orange,
    SourceMaterialStatus.reviewed => Colors.blue,
    SourceMaterialStatus.converted => Colors.green,
    SourceMaterialStatus.ignored => Colors.grey,
  };
}
