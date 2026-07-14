import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../platform/pwa_install.dart';

class PwaInstallNotice extends StatelessWidget {
  final PwaInstallController controller;
  final bool dismissed;
  final VoidCallback onDismiss;

  const PwaInstallNotice({
    super.key,
    required this.controller,
    required this.dismissed,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final status = controller.status;
        if (dismissed || !status.isWeb || status.isStandalone) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withAlpha(235),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 620;
                  final instruction = status.canInstall
                      ? null
                      : status.isLikelyIosSafari
                      ? l.landingPwaIosHint
                      : l.landingPwaBrowserMenuHint;
                  final textBlock = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.landingPwaHint, style: theme.textTheme.bodyMedium),
                      if (instruction != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          instruction,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  );
                  final actions = Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: compact
                        ? WrapAlignment.start
                        : WrapAlignment.end,
                    children: [
                      if (status.canInstall)
                        FilledButton(
                          onPressed: controller.promptInstall,
                          child: Text(l.landingPwaAddToHome),
                        ),
                      TextButton(
                        onPressed: onDismiss,
                        child: Text(l.landingPwaDismiss),
                      ),
                    ],
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textBlock,
                        const SizedBox(height: 12),
                        actions,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: textBlock),
                      const SizedBox(width: 16),
                      actions,
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
