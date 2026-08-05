import 'package:flutter/material.dart';

import '../../ai/grounded_answer_service.dart';
import '../../l10n/app_localizations.dart';
import 'grounded_answer_panel.dart';

/// Public test surface for BusinessBrain's single grounded-answer workflow.
///
/// The previous local keyword chat intentionally no longer lives on this
/// screen. Keeping one input prevents two competing answer systems from
/// presenting different knowledge, languages or sources to the user.
class BotTestScreen extends StatelessWidget {
  const BotTestScreen({super.key, this.serviceOverride});

  /// Test seam forwarded to the one visible [GroundedAnswerPanel]. Production
  /// always uses the ambient service configuration.
  final GroundedAnswerService? serviceOverride;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          key: const Key('bot-test-grounded-scroll'),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Text(
                  l.botTestTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Text(
                  l.botTestSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              GroundedAnswerPanel(serviceOverride: serviceOverride),
            ],
          ),
        ),
      ),
    );
  }
}
