import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class LandingCtaSection extends StatelessWidget {
  final VoidCallback onRequest;

  const LandingCtaSection({super.key, required this.onRequest});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 52),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              Color.lerp(theme.colorScheme.primary, Colors.teal, 0.28)!,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withAlpha(35),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 700;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.landingCtaTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l.landingCtaText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withAlpha(220),
                    height: 1.38,
                  ),
                ),
              ],
            );
            final button = FilledButton.tonalIcon(
              onPressed: onRequest,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(l.landingCtaButton),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 52),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [copy, const SizedBox(height: 22), button],
              );
            }

            return Row(
              children: [
                Expanded(child: copy),
                const SizedBox(width: 24),
                button,
              ],
            );
          },
        ),
      ),
    );
  }
}
