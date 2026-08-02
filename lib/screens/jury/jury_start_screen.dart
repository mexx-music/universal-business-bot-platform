import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../jury/jury_mode_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/language_switcher.dart';

/// Jury Mode start page (BLOCK 9). A modern entry screen with a short intro and
/// two clear actions. Presentation only — activating jury mode just simplifies
/// the navigation; no feature is removed and no logic changes.
class JuryStartScreen extends StatelessWidget {
  const JuryStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    void guided() {
      JuryModeController.maybeOf(context)?.enable();
      context.go('/jury-demo');
    }

    void explore() {
      JuryModeController.maybeOf(context)?.enable();
      context.go('/dashboard');
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: LanguageSwitcher(compact: true),
                  ),
                  Icon(
                    Icons.hub_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.juryStartTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l.juryStartIntro,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: guided,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(l.juryStartGuided),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: explore,
                      icon: const Icon(Icons.explore_outlined),
                      label: Text(l.juryStartExplore),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.juryStartNote,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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
