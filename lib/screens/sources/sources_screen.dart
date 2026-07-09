import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';
import '../../models/knowledge_entry.dart';

enum _SourceType { url, dokument, manuell }

class _Source {
  final String name;
  final _SourceType type;
  final List<KnowledgeEntry> entries;

  const _Source({
    required this.name,
    required this.type,
    required this.entries,
  });
}

_SourceType _detectType(String source) {
  if (source.startsWith('http')) return _SourceType.url;
  if (source.toLowerCase().endsWith('.pdf') ||
      source.toLowerCase().contains('dokument')) {
    return _SourceType.dokument;
  }
  return _SourceType.manuell;
}

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final sourcesMap = <String, List<KnowledgeEntry>>{};
    for (final entry in state.knowledgeEntries) {
      sourcesMap.putIfAbsent(entry.source, () => []).add(entry);
    }

    final sources =
        sourcesMap.entries
            .map(
              (e) => _Source(
                name: e.key,
                type: _detectType(e.key),
                entries: e.value,
              ),
            )
            .toList()
          ..sort((a, b) => b.entries.length.compareTo(a.entries.length));

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 24),
          Row(
            children: [
              _SummaryChip(
                icon: Icons.source,
                label: l.sourcesCount(sources.length),
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              _SummaryChip(
                icon: Icons.library_books,
                label: l.sourcesEntriesCount(state.knowledgeEntries.length),
                color: Colors.teal,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (sources.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text(l.sourcesEmpty)),
            )
          else
            ...sources.map((s) => _SourceCard(source: s)),
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      l.sourcesStage2Hint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

class _SourceCard extends StatelessWidget {
  final _Source source;

  const _SourceCard({required this.source});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final (icon, color) = switch (source.type) {
      _SourceType.url => (Icons.language, Colors.blue),
      _SourceType.dokument => (Icons.picture_as_pdf, Colors.red),
      _SourceType.manuell => (Icons.edit_note, Colors.grey),
    };
    final typeLabel = switch (source.type) {
      _SourceType.url => l.sourceTypeUrl,
      _SourceType.dokument => l.sourceTypeDocument,
      _SourceType.manuell => l.sourceTypeManual,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(25),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          source.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(l.sourcesEntryInfo(source.entries.length, typeLabel)),
        children: source.entries
            .map(
              (e) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Icon(
                  e.category.icon,
                  size: 18,
                  color: e.category.color,
                ),
                title: Text(e.title, style: theme.textTheme.bodyMedium),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: e.category.color.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    knowledgeCategoryLabel(context, e.category),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: e.category.color,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
