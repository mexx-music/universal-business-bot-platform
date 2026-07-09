import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';
import '../../models/knowledge_entry.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  KnowledgeCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final filtered = _filter == null
        ? state.knowledgeEntries
        : state.knowledgeEntries.where((e) => e.category == _filter).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Text(
                l.knowledgeTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                l.knowledgeEntryCount(state.knowledgeEntries.length),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: l.knowledgeFilterAll,
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: 8),
                ...KnowledgeCategory.values.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: knowledgeCategoryLabel(context, cat),
                      color: cat.color,
                      selected: _filter == cat,
                      onTap: () => setState(() => _filter = cat),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text(l.knowledgeNoEntries)),
            )
          else
            ...filtered.map(
              (entry) => _KnowledgeCard(
                entry: entry,
                onDelete: () => state.removeKnowledgeEntry(entry.id),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, state),
        icon: const Icon(Icons.add),
        label: Text(l.knowledgeAddEntry),
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppState state) {
    showDialog<void>(
      context: context,
      builder: (_) => _AddEntryDialog(state: state),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: chipColor.withAlpha(40),
      checkmarkColor: chipColor,
      labelStyle: selected
          ? TextStyle(color: chipColor, fontWeight: FontWeight.w600)
          : null,
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _MiniChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _KnowledgeCard extends StatelessWidget {
  final KnowledgeEntry entry;
  final VoidCallback onDelete;

  const _KnowledgeCard({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MiniChip(
                  label: knowledgeCategoryLabel(context, entry.category),
                  icon: entry.category.icon,
                  color: entry.category.color,
                ),
                const SizedBox(width: 6),
                _MiniChip(
                  label: riskLevelLabel(context, entry.riskLevel),
                  icon: entry.riskLevel.icon,
                  color: entry.riskLevel.color,
                ),
                const Spacer(),
                Text(
                  '${entry.createdAt.day.toString().padLeft(2, '0')}.'
                  '${entry.createdAt.month.toString().padLeft(2, '0')}.'
                  '${entry.createdAt.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: theme.colorScheme.error,
                  tooltip: l.btnDelete,
                  onPressed: () => _confirmDelete(context, l),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              entry.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              entry.content,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: entry.keywords
                  .map(
                    (kw) => Chip(
                      label: Text(kw),
                      labelStyle: theme.textTheme.labelSmall,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.source_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  entry.source,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppLocalizations l) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.knowledgeDeleteTitle),
        content: Text(l.knowledgeDeleteConfirm(entry.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.btnCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete();
            },
            child: Text(l.btnDelete),
          ),
        ],
      ),
    );
  }
}

class _AddEntryDialog extends StatefulWidget {
  final AppState state;

  const _AddEntryDialog({required this.state});

  @override
  State<_AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<_AddEntryDialog> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _keywords = TextEditingController();
  final _source = TextEditingController(text: 'Manuell');
  KnowledgeCategory _category = KnowledgeCategory.faq;
  RiskLevel _riskLevel = RiskLevel.green;

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _keywords.dispose();
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.knowledgeNewEntry),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(l.fieldTitle, _title),
              _field(l.fieldContent, _content, maxLines: 4),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l.fieldCategory,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                child: DropdownButton<KnowledgeCategory>(
                  value: _category,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: KnowledgeCategory.values
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(knowledgeCategoryLabel(context, c)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l.knowledgeRisk,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                child: DropdownButton<RiskLevel>(
                  value: _riskLevel,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: RiskLevel.values
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Row(
                            children: [
                              Icon(r.icon, size: 14, color: r.color),
                              const SizedBox(width: 6),
                              Text(riskLevelLabel(context, r)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _riskLevel = v ?? _riskLevel),
                ),
              ),
              const SizedBox(height: 12),
              _field(l.fieldKeywords, _keywords),
              _field(l.fieldSource, _source),
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
          onPressed: _title.text.isEmpty ? null : _save,
          child: Text(l.btnAdd),
        ),
      ],
    );
  }

  void _save() {
    final kws = _keywords.text
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();

    widget.state.addKnowledgeEntry(
      KnowledgeEntry(
        id: 'k_${DateTime.now().millisecondsSinceEpoch}',
        title: _title.text.trim(),
        content: _content.text.trim(),
        category: _category,
        riskLevel: _riskLevel,
        keywords: kws,
        source: _source.text.trim(),
        createdAt: DateTime.now(),
        languageCode: Localizations.localeOf(context).languageCode,
      ),
    );
    Navigator.of(context).pop();
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
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
}
