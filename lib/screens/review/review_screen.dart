import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';
import '../../models/bot_question_log.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  ReviewStatus? _filter = ReviewStatus.open;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final openCount = state.botLogs
        .where((e) => e.reviewStatus == ReviewStatus.open)
        .length;
    final reviewedCount = state.botLogs
        .where((e) => e.reviewStatus == ReviewStatus.reviewed)
        .length;
    final closedCount = state.botLogs
        .where((e) => e.reviewStatus == ReviewStatus.closed)
        .length;

    final base = _filter == null
        ? state.botLogs
        : state.botLogs.where((e) => e.reviewStatus == _filter).toList();

    final sorted = [...base]
      ..sort((a, b) {
        const order = {
          ReviewStatus.open: 0,
          ReviewStatus.reviewed: 1,
          ReviewStatus.closed: 2,
        };
        final s = order[a.reviewStatus]!.compareTo(order[b.reviewStatus]!);
        return s != 0 ? s : b.timestamp.compareTo(a.timestamp);
      });

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l.reviewTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.reviewSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // ── Filter-Chips ──────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(
                  label: l.reviewFilterAll,
                  count: state.botLogs.length,
                  selected: _filter == null,
                  color: theme.colorScheme.primary,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: 8),
                _Chip(
                  label: l.reviewStatusOpen,
                  count: openCount,
                  selected: _filter == ReviewStatus.open,
                  color: ReviewStatus.open.color,
                  icon: ReviewStatus.open.icon,
                  onTap: () => setState(() => _filter = ReviewStatus.open),
                ),
                const SizedBox(width: 8),
                _Chip(
                  label: l.reviewStatusReviewed,
                  count: reviewedCount,
                  selected: _filter == ReviewStatus.reviewed,
                  color: ReviewStatus.reviewed.color,
                  icon: ReviewStatus.reviewed.icon,
                  onTap: () => setState(() => _filter = ReviewStatus.reviewed),
                ),
                const SizedBox(width: 8),
                _Chip(
                  label: l.reviewStatusClosed,
                  count: closedCount,
                  selected: _filter == ReviewStatus.closed,
                  color: ReviewStatus.closed.color,
                  icon: ReviewStatus.closed.icon,
                  onTap: () => setState(() => _filter = ReviewStatus.closed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  l.reviewEmpty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...sorted.map(
              (log) => _ReviewCard(
                log: log,
                onTap: () => _openDetail(context, state, log),
              ),
            ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, AppState state, BotQuestionLog log) {
    showDialog<void>(
      context: context,
      builder: (_) => _ReviewDetailDialog(log: log, state: state),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.count,
    required this.selected,
    required this.color,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: icon != null ? Icon(icon, size: 16) : null,
      label: Text('$label ($count)'),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: color.withAlpha(40),
      checkmarkColor: color,
      labelStyle: selected
          ? TextStyle(color: color, fontWeight: FontWeight.w600)
          : null,
    );
  }
}

// ── Review card ───────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final BotQuestionLog log;
  final VoidCallback onTap;

  const _ReviewCard({required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final status = log.reviewStatus;
    final reason = log.reviewReason;

    final timeStr =
        '${log.timestamp.day.toString().padLeft(2, '0')}.'
        '${log.timestamp.month.toString().padLeft(2, '0')}.'
        '${log.timestamp.year} '
        '${log.timestamp.hour.toString().padLeft(2, '0')}:'
        '${log.timestamp.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status icon
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: status.color.withAlpha(30),
                  child: Icon(status.icon, size: 18, color: status.color),
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.question,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StatusBadge(
                          label: reviewStatusLabel(context, status),
                          color: status.color,
                        ),
                        if (reason != null) ...[
                          const SizedBox(width: 6),
                          _StatusBadge(
                            label: reviewReasonLabel(context, reason),
                            color: reason.color,
                            icon: reason.icon,
                          ),
                        ],
                      ],
                    ),
                    if (log.humanNote != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.sticky_note_2_outlined,
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              log.humanNote!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (log.redirected ||
                        (log.matched && log.answer != null)) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            log.redirected
                                ? Icons.block
                                : Icons.chat_bubble_outline,
                            size: 12,
                            color: log.redirected
                                ? Colors.red
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              log.redirected
                                  ? l.riskRed
                                  : (log.answer ?? l.logNoAnswer),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: log.redirected
                                    ? Colors.red
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Timestamp
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
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

// ── Small status badge ────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _StatusBadge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail dialog ─────────────────────────────────────────────────────────────

class _ReviewDetailDialog extends StatefulWidget {
  final BotQuestionLog log;
  final AppState state;

  const _ReviewDetailDialog({required this.log, required this.state});

  @override
  State<_ReviewDetailDialog> createState() => _ReviewDetailDialogState();
}

class _ReviewDetailDialogState extends State<_ReviewDetailDialog> {
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    _noteCtrl = TextEditingController(text: widget.log.humanNote ?? '');
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  BotQuestionLog _withNote({ReviewStatus? status}) {
    final note = _noteCtrl.text.trim();
    final changingStatus = status != null && status != widget.log.reviewStatus;
    return widget.log.copyWith(
      reviewStatus: status,
      humanNote: note.isEmpty ? null : note,
      // Set reviewedAt on first transition to reviewed/closed; keep existing otherwise
      reviewedAt: changingStatus ? DateTime.now() : widget.log.reviewedAt,
    );
  }

  void _saveNote() {
    widget.state.updateBotLog(_withNote());
    Navigator.of(context).pop();
  }

  void _markReviewed() {
    widget.state.updateBotLog(_withNote(status: ReviewStatus.reviewed));
    Navigator.of(context).pop();
  }

  void _markClosed() {
    widget.state.updateBotLog(_withNote(status: ReviewStatus.closed));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final log = widget.log;
    final theme = Theme.of(context);

    String fmtDt(DateTime dt) =>
        '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.rate_review_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(l.reviewTitle),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status + reason + timestamps row
              Row(
                children: [
                  _StatusBadge(
                    label: reviewStatusLabel(context, log.reviewStatus),
                    color: log.reviewStatus.color,
                    icon: log.reviewStatus.icon,
                  ),
                  if (log.reviewReason != null) ...[
                    const SizedBox(width: 6),
                    _StatusBadge(
                      label: reviewReasonLabel(context, log.reviewReason!),
                      color: log.reviewReason!.color,
                      icon: log.reviewReason!.icon,
                    ),
                  ],
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.question_answer_outlined,
                            size: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            fmtDt(log.timestamp),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      if (log.reviewedAt != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              fmtDt(log.reviewedAt!),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Question
              Text(
                log.question,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Bot answer / redirect
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: log.redirected
                      ? Colors.red.withAlpha(15)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: log.redirected
                      ? Border.all(color: Colors.red.withAlpha(60))
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      log.redirected
                          ? Icons.block
                          : log.matched
                          ? Icons.chat_bubble_outline
                          : Icons.search_off,
                      size: 16,
                      color: log.redirected
                          ? Colors.red
                          : log.matched
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.reviewBotAnswer,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            log.redirected
                                ? l.riskRed
                                : (log.answer ?? l.logNoAnswer),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: log.redirected ? Colors.red : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Human note field
              Text(
                l.reviewHumanNote,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: l.reviewNoteHint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),

              // Status action buttons
              if (log.reviewStatus == ReviewStatus.open ||
                  log.reviewStatus == ReviewStatus.reviewed)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    if (log.reviewStatus == ReviewStatus.open)
                      OutlinedButton.icon(
                        onPressed: _markReviewed,
                        icon: Icon(ReviewStatus.reviewed.icon, size: 18),
                        label: Text(l.reviewMarkReviewed),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ReviewStatus.reviewed.color,
                          side: BorderSide(
                            color: ReviewStatus.reviewed.color.withAlpha(120),
                          ),
                        ),
                      ),
                    if (log.reviewStatus != ReviewStatus.closed) ...[
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _markClosed,
                        icon: Icon(ReviewStatus.closed.icon, size: 18),
                        label: Text(l.reviewMarkClosed),
                        style: FilledButton.styleFrom(
                          backgroundColor: ReviewStatus.closed.color,
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.btnCancel),
        ),
        FilledButton.tonal(onPressed: _saveNote, child: Text(l.reviewSaveNote)),
      ],
    );
  }
}
