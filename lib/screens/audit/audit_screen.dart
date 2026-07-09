import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final checks = _buildChecks(context, state, l);
    final score = checks.fold<int>(
      0,
      (sum, c) => sum + (c.passed ? c.points : 0),
    );
    final maxScore = checks.fold<int>(0, (sum, c) => sum + c.points);
    final percent = maxScore == 0 ? 0.0 : score / maxScore;

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
            l.auditSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          Card(
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
                        l.auditScoreLabel(score, maxScore),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 10,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percent >= 0.8
                            ? Colors.green
                            : percent >= 0.5
                            ? Colors.orange
                            : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _scoreLabel(l, percent),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: percent >= 0.8
                          ? Colors.green
                          : percent >= 0.5
                          ? Colors.orange
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l.auditChecklist,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...checks.map((c) => _CheckItem(check: c, l: l)),
        ],
      ),
    );
  }

  String _scoreLabel(AppLocalizations l, double percent) {
    if (percent >= 0.9) return l.auditExcellent;
    if (percent >= 0.7) return l.auditGood;
    if (percent >= 0.5) return l.auditMedium;
    return l.auditPoor;
  }

  List<_AuditCheck> _buildChecks(
    BuildContext context,
    AppState state,
    AppLocalizations l,
  ) {
    final c = state.company;
    return [
      _AuditCheck(
        title: l.auditCheckCompanyName,
        description: c.name.isNotEmpty ? c.name : '–',
        passed: c.name.isNotEmpty,
        points: 10,
      ),
      _AuditCheck(
        title: l.auditCheckIndustry,
        description: c.industry.isNotEmpty ? c.industry : '–',
        passed: c.industry.isNotEmpty,
        points: 10,
      ),
      _AuditCheck(
        title: l.auditCheckDescription,
        description: c.description.length >= 50
            ? l.auditDescChars(c.description.length)
            : l.auditDescTooShort,
        passed: c.description.length >= 50,
        points: 10,
      ),
      _AuditCheck(
        title: l.auditCheckWebsite,
        description: c.website.isNotEmpty ? c.website : '–',
        passed: c.website.isNotEmpty,
        points: 5,
      ),
      _AuditCheck(
        title: l.auditCheckProducts,
        description: l.auditDescEntries(state.products.length),
        passed: state.products.isNotEmpty,
        points: 15,
      ),
      _AuditCheck(
        title: l.auditCheckKnowledge,
        description: l.auditDescEntries(state.knowledgeEntries.length),
        passed: state.knowledgeEntries.isNotEmpty,
        points: 15,
      ),
      _AuditCheck(
        title: l.auditCheckKnowledge10,
        description: state.knowledgeEntries.length >= 10
            ? l.auditDescAchieved
            : l.auditDescOfTotal(state.knowledgeEntries.length, 10),
        passed: state.knowledgeEntries.length >= 10,
        points: 15,
      ),
      _AuditCheck(
        title: l.auditCheckBotTest,
        description: state.botLogs.isNotEmpty
            ? l.auditDescTestCount(state.botLogs.length)
            : l.auditDescNoTest,
        passed: state.botLogs.isNotEmpty,
        points: 20,
      ),
    ];
  }
}

class _AuditCheck {
  final String title;
  final String description;
  final bool passed;
  final int points;

  const _AuditCheck({
    required this.title,
    required this.description,
    required this.passed,
    required this.points,
  });
}

class _CheckItem extends StatelessWidget {
  final _AuditCheck check;
  final AppLocalizations l;

  const _CheckItem({required this.check, required this.l});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = check.passed
        ? Colors.green
        : theme.colorScheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          check.passed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: color,
        ),
        title: Text(
          check.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: check.passed ? null : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(check.description),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: check.passed
                ? Colors.green.withAlpha(20)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            l.auditPoints(check.points),
            style: theme.textTheme.labelSmall?.copyWith(
              color: check.passed
                  ? Colors.green
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
