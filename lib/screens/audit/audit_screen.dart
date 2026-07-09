import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/business_audit.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final auditPct = (state.auditScore * 100).round();
    final groupedItems = <AuditArea, List<BusinessAuditItem>>{
      for (final area in AuditArea.values)
        area: state.auditItems.where((item) => item.area == area).toList(),
    };

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l.auditTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.auditBusinessSubtitle(state.company.name),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          _AuditSummaryCard(
            percent: auditPct,
            missing: state.auditMissingCount,
            partial: state.auditPartialCount,
            complete: state.auditCompleteCount,
            highPriorityOpen: state.auditHighPriorityOpenCount,
          ),
          const SizedBox(height: 24),
          Text(
            l.auditBusinessStatusTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...groupedItems.entries
              .where((entry) => entry.value.isNotEmpty)
              .map(
                (entry) => _AuditAreaCard(
                  area: entry.key,
                  items: entry.value,
                  state: state,
                ),
              ),
        ],
      ),
    );
  }
}

class _AuditSummaryCard extends StatelessWidget {
  final int percent;
  final int missing;
  final int partial;
  final int complete;
  final int highPriorityOpen;

  const _AuditSummaryCard({
    required this.percent,
    required this.missing,
    required this.partial,
    required this.complete,
    required this.highPriorityOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scoreColor = percent >= 80
        ? Colors.green
        : percent >= 50
        ? Colors.orange
        : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l.auditTotalScore,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$percent%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _scoreLabel(l, percent),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SummaryChip(
                  icon: Icons.cancel_outlined,
                  label: l.auditMissingCount(missing),
                  color: Colors.red,
                ),
                _SummaryChip(
                  icon: Icons.pending_outlined,
                  label: l.auditPartialCount(partial),
                  color: Colors.orange,
                ),
                _SummaryChip(
                  icon: Icons.check_circle_outline,
                  label: l.auditCompleteCount(complete),
                  color: Colors.green,
                ),
                _SummaryChip(
                  icon: Icons.priority_high,
                  label: l.auditHighPriorityOpenCount(highPriorityOpen),
                  color: highPriorityOpen > 0 ? Colors.red : Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _scoreLabel(AppLocalizations l, int percent) {
    if (percent >= 90) return l.auditExcellent;
    if (percent >= 70) return l.auditGood;
    if (percent >= 50) return l.auditMedium;
    return l.auditPoor;
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
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

class _AuditAreaCard extends StatelessWidget {
  final AuditArea area;
  final List<BusinessAuditItem> items;
  final AppState state;

  const _AuditAreaCard({
    required this.area,
    required this.items,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completeCount = items
        .where((item) => item.status == AuditItemStatus.complete)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: area == AuditArea.botReadiness,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(_areaIcon(area), color: theme.colorScheme.primary),
        ),
        title: Text(
          _areaLabel(context, area),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '$completeCount / ${items.length} ${AppLocalizations.of(context)!.auditItemsComplete}',
        ),
        children: [
          const Divider(height: 1),
          ...items.map(
            (item) => _AuditItemTile(
              item: item,
              onStatusChanged: (status) =>
                  state.updateAuditItemStatus(item.id, status),
              onPriorityChanged: (priority) =>
                  state.updateAuditItemPriority(item.id, priority),
              onEditNote: () => _openNoteDialog(context, state, item),
            ),
          ),
        ],
      ),
    );
  }

  void _openNoteDialog(
    BuildContext context,
    AppState state,
    BusinessAuditItem item,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _AuditNoteDialog(
        initialNote: item.note ?? '',
        onSave: (note) => state.updateAuditItemNote(item.id, note),
      ),
    );
  }
}

class _AuditItemTile extends StatelessWidget {
  final BusinessAuditItem item;
  final ValueChanged<AuditItemStatus> onStatusChanged;
  final ValueChanged<AuditPriority> onPriorityChanged;
  final VoidCallback onEditNote;

  const _AuditItemTile({
    required this.item,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onEditNote,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: l.auditEditNote,
                onPressed: onEditNote,
                icon: const Icon(Icons.edit_note_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AuditItemStatus.values
                .map(
                  (status) => _AuditChoiceChip(
                    label: _statusLabel(context, status),
                    selected: item.status == status,
                    color: _statusColor(status),
                    onTap: () => onStatusChanged(status),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AuditPriority.values
                .map(
                  (priority) => _AuditChoiceChip(
                    label: _priorityLabel(context, priority),
                    selected: item.priority == priority,
                    color: _priorityColor(priority),
                    onTap: () => onPriorityChanged(priority),
                  ),
                )
                .toList(),
          ),
          if (item.note != null && item.note!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoLine(
              icon: Icons.sticky_note_2_outlined,
              label: l.auditNote,
              text: item.note!,
            ),
          ],
          if (item.recommendation != null &&
              item.recommendation!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoLine(
              icon: Icons.lightbulb_outline,
              label: l.auditRecommendation,
              text: item.recommendation!,
            ),
          ],
        ],
      ),
    );
  }
}

class _AuditChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _AuditChoiceChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: color.withAlpha(35),
      checkmarkColor: color,
      labelStyle: selected
          ? TextStyle(color: color, fontWeight: FontWeight.w700)
          : null,
      side: BorderSide(color: selected ? color.withAlpha(90) : Colors.black12),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditNoteDialog extends StatefulWidget {
  final String initialNote;
  final ValueChanged<String> onSave;

  const _AuditNoteDialog({required this.initialNote, required this.onSave});

  @override
  State<_AuditNoteDialog> createState() => _AuditNoteDialogState();
}

class _AuditNoteDialogState extends State<_AuditNoteDialog> {
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _note = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.auditEditNote),
      content: SizedBox(
        width: 460,
        child: TextField(
          controller: _note,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: l.auditNoteHint,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.btnCancel),
        ),
        FilledButton(
          onPressed: () {
            widget.onSave(_note.text);
            Navigator.of(context).pop();
          },
          child: Text(l.btnSave),
        ),
      ],
    );
  }
}

String _areaLabel(BuildContext context, AuditArea area) {
  final l = AppLocalizations.of(context)!;
  return switch (area) {
    AuditArea.companyProfile => l.auditAreaCompanyProfile,
    AuditArea.website => l.auditAreaWebsite,
    AuditArea.products => l.auditAreaProducts,
    AuditArea.supportKnowledge => l.auditAreaSupportKnowledge,
    AuditArea.trustMaterial => l.auditAreaTrustMaterial,
    AuditArea.socialPresence => l.auditAreaSocialPresence,
    AuditArea.sources => l.auditAreaSources,
    AuditArea.riskRules => l.auditAreaRiskRules,
    AuditArea.botReadiness => l.auditAreaBotReadiness,
  };
}

IconData _areaIcon(AuditArea area) {
  return switch (area) {
    AuditArea.companyProfile => Icons.business_outlined,
    AuditArea.website => Icons.language,
    AuditArea.products => Icons.inventory_2_outlined,
    AuditArea.supportKnowledge => Icons.help_outline,
    AuditArea.trustMaterial => Icons.verified_outlined,
    AuditArea.socialPresence => Icons.campaign_outlined,
    AuditArea.sources => Icons.source_outlined,
    AuditArea.riskRules => Icons.block_outlined,
    AuditArea.botReadiness => Icons.smart_toy_outlined,
  };
}

String _statusLabel(BuildContext context, AuditItemStatus status) {
  final l = AppLocalizations.of(context)!;
  return switch (status) {
    AuditItemStatus.missing => l.auditStatusMissing,
    AuditItemStatus.partial => l.auditStatusPartial,
    AuditItemStatus.complete => l.auditStatusComplete,
  };
}

Color _statusColor(AuditItemStatus status) {
  return switch (status) {
    AuditItemStatus.missing => Colors.red,
    AuditItemStatus.partial => Colors.orange,
    AuditItemStatus.complete => Colors.green,
  };
}

String _priorityLabel(BuildContext context, AuditPriority priority) {
  final l = AppLocalizations.of(context)!;
  return switch (priority) {
    AuditPriority.low => l.auditPriorityLow,
    AuditPriority.medium => l.auditPriorityMedium,
    AuditPriority.high => l.auditPriorityHigh,
  };
}

Color _priorityColor(AuditPriority priority) {
  return switch (priority) {
    AuditPriority.low => Colors.blueGrey,
    AuditPriority.medium => Colors.blue,
    AuditPriority.high => Colors.red,
  };
}
