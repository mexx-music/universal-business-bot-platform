import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Internal release checklist (BLOCK 9). Team-only view of submission-readiness
/// items with a per-item status (not started / in progress / done). Presentation
/// only — the status is local UI state, not persisted or published.
class ReleaseChecklistScreen extends StatefulWidget {
  const ReleaseChecklistScreen({super.key});

  @override
  State<ReleaseChecklistScreen> createState() => _ReleaseChecklistScreenState();
}

enum _Status { notStarted, inProgress, done }

class _ReleaseChecklistScreenState extends State<ReleaseChecklistScreen> {
  // Default statuses reflect the current, honest state of the project.
  final List<_Status> _statuses = [
    _Status.inProgress, // branch published
    _Status.notStarted, // cloudflare deployment
    _Status.done, // live gemini active
    _Status.done, // AI_PROVIDER set
    _Status.done, // demo data
    _Status.done, // guided demo
    _Status.done, // business story
    _Status.done, // operations dashboard
    _Status.done, // knowledge workflow
    _Status.inProgress, // README
    _Status.notStarted, // screenshots
    _Status.notStarted, // pitch video
    _Status.inProgress, // submission document
  ];

  void _cycle(int i) {
    setState(() {
      final next = (_statuses[i].index + 1) % _Status.values.length;
      _statuses[i] = _Status.values[next];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = [
      l.rcItem1,
      l.rcItem2,
      l.rcItem3,
      l.rcItem4,
      l.rcItem5,
      l.rcItem6,
      l.rcItem7,
      l.rcItem8,
      l.rcItem9,
      l.rcItem10,
      l.rcItem11,
      l.rcItem12,
      l.rcItem13,
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.releaseTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.releaseIntro,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < items.length; i++)
                    _ChecklistTile(
                      label: items[i],
                      status: _statuses[i],
                      onTap: () => _cycle(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.label,
    required this.status,
    required this.onTap,
  });

  final String label;
  final _Status status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final (icon, color, text) = switch (status) {
      _Status.notStarted => (
        Icons.radio_button_unchecked,
        theme.colorScheme.onSurfaceVariant,
        l.rcNotStarted,
      ),
      _Status.inProgress => (
        Icons.hourglass_bottom,
        Colors.orange,
        l.rcInProgress,
      ),
      _Status.done => (Icons.check_circle, Colors.green, l.rcDone),
    };
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(28),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withAlpha(120)),
          ),
          child: Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
