import 'dart:async';

import 'package:flutter/material.dart';

import '../app/app_locale_controller.dart';
import '../l10n/app_localizations.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool compact;

  const LanguageSwitcher({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final controller = AppLocaleScope.maybeOf(context);
    if (controller == null) return const SizedBox.shrink();
    final currentCode = controller.locale.languageCode;
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (compact) {
      return Semantics(
        label: '${l.languageGerman} / ${l.languageEnglish}',
        button: true,
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _LanguageCodeButton(
              code: 'de',
              selected: currentCode == 'de',
              onTap: () => unawaited(controller.setLocaleCode('de')),
            ),
            _LanguageCodeButton(
              code: 'en',
              selected: currentCode == 'en',
              onTap: () => unawaited(controller.setLocaleCode('en')),
            ),
          ],
        ),
      );
    }

    return Semantics(
      label: '${l.languageGerman} / ${l.languageEnglish}',
      button: true,
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: compact
              ? VisualDensity.compact
              : VisualDensity.standard,
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: compact ? 6 : 8,
            ),
          ),
          textStyle: WidgetStateProperty.all(
            theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        segments: const [
          ButtonSegment(value: 'de', label: Text('DE')),
          ButtonSegment(value: 'en', label: Text('EN')),
        ],
        selected: {currentCode},
        onSelectionChanged: (selection) {
          if (selection.isEmpty) return;
          unawaited(controller.setLocaleCode(selection.first));
        },
      ),
    );
  }
}

class _LanguageCodeButton extends StatelessWidget {
  final String code;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageCodeButton({
    required this.code,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.primary;
    final background = selected
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.surface;

    return SizedBox(
      width: 34,
      height: 30,
      child: TextButton(
        onPressed: selected ? null : onTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: foreground,
          disabledForegroundColor: foreground,
          backgroundColor: background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          code.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
