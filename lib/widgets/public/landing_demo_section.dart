import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'landing_section_header.dart';

class LandingDemoSection extends StatelessWidget {
  final VoidCallback onDemo;

  const LandingDemoSection({super.key, required this.onDemo});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LandingSectionHeader(
            title: l.landingDemoSectionTitle,
            subtitle: l.landingDemoSectionSubtitle,
          ),
          const SizedBox(height: 22),
          Container(
            constraints: const BoxConstraints(minHeight: 320),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(90),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 28,
                  top: 28,
                  right: 28,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _PreviewChip(label: l.landingFeatureIntake),
                      _PreviewChip(label: l.landingFeatureKnowledgeFull),
                      _PreviewChip(label: l.landingFeatureHumanReview),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withAlpha(45),
                              blurRadius: 30,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: theme.colorScheme.onPrimary,
                          size: 54,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l.landingDemoVideoComing,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: onDemo,
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: Text(l.landingDemoButton),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  final String label;

  const _PreviewChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(235),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
