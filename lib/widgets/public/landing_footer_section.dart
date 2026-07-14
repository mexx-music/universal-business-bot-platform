import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class LandingFooterSection extends StatelessWidget {
  final VoidCallback onPlaceholder;

  const LandingFooterSection({super.key, required this.onPlaceholder});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 42),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final brand = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.landingBrandName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.landingFooterVersion,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
            final links = Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: compact ? WrapAlignment.start : WrapAlignment.end,
              children: [
                TextButton(
                  onPressed: onPlaceholder,
                  child: Text(l.landingFooterGithub),
                ),
                TextButton(
                  onPressed: onPlaceholder,
                  child: Text(l.landingFooterImprint),
                ),
                TextButton(
                  onPressed: onPlaceholder,
                  child: Text(l.landingFooterPrivacy),
                ),
                TextButton(
                  onPressed: onPlaceholder,
                  child: Text(l.landingFooterContact),
                ),
                _LanguagePill(label: l.landingFooterLanguages),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [brand, const SizedBox(height: 16), links],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: brand),
                links,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  final String label;

  const _LanguagePill({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
