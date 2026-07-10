import 'package:flutter/material.dart';

import '../data/intake_chat_flow.dart';
import '../l10n/app_localizations.dart';
import '../models/intake_session.dart';

enum IntakeChoiceDialogAction { save, defer, cancel }

class IntakeChoiceDialogResult {
  final IntakeChoiceDialogAction action;
  final String answer;

  const IntakeChoiceDialogResult({required this.action, this.answer = ''});
}

class IntakeChoiceDialog extends StatefulWidget {
  final IntakeChatQuestion question;
  final IntakeSession session;

  const IntakeChoiceDialog({
    super.key,
    required this.question,
    required this.session,
  });

  @override
  State<IntakeChoiceDialog> createState() => _IntakeChoiceDialogState();
}

class _IntakeChoiceDialogState extends State<IntakeChoiceDialog> {
  late final TextEditingController _otherController;
  late final List<String> _options;
  late final Set<String> _selected;
  String? _errorText;
  bool _otherSelected = false;

  @override
  void initState() {
    super.initState();
    final l = AppLocalizations.of(context)!;
    _options =
        widget.question.choiceOptions?.call(widget.session, l) ?? const [];
    final existing = _splitSaved(widget.question.value(widget.session));
    _selected = {
      for (final value in existing)
        if (_options.any((option) => _same(option, value)))
          _matchingOption(_options, value),
    };
    final otherValues = [
      for (final value in existing)
        if (!_options.any((option) => _same(option, value))) value,
    ];
    _otherSelected = otherValues.isNotEmpty;
    _otherController = TextEditingController(text: otherValues.join(', '));
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final question = widget.question;
    final isWide = MediaQuery.sizeOf(context).width > 560;

    return AlertDialog(
      title: Text(question.text(l)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.allowMultiple
                    ? l.intakeChoiceDialogMultiHint
                    : l.intakeChoiceDialogSingleHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              if (_errorText != null) ...[
                Text(
                  _errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 10),
              ],
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final option in _options)
                    SizedBox(
                      width: isWide ? 190 : double.infinity,
                      child: _ChoiceCard(
                        label: option,
                        selected: _selected.contains(option),
                        onTap: () => _toggleOption(option),
                      ),
                    ),
                  if (question.allowOther)
                    SizedBox(
                      width: isWide ? 190 : double.infinity,
                      child: _ChoiceCard(
                        label:
                            question.otherLabel?.call(l) ?? l.intakeChoiceOther,
                        selected: _otherSelected,
                        onTap: _toggleOther,
                      ),
                    ),
                ],
              ),
              if (_otherSelected) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: _otherController,
                  autofocus: _selected.isEmpty,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText:
                        question.otherLabel?.call(l) ?? l.intakeChoiceOther,
                    hintText: l.intakeChoiceOtherHint,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            const IntakeChoiceDialogResult(
              action: IntakeChoiceDialogAction.cancel,
            ),
          ),
          child: Text(l.intakeChatDialogCancel),
        ),
        TextButton(
          onPressed: question.skippable
              ? () => Navigator.of(context).pop(
                  const IntakeChoiceDialogResult(
                    action: IntakeChoiceDialogAction.defer,
                  ),
                )
              : null,
          child: Text(l.intakeChatDialogDefer),
        ),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
          child: Text(l.intakeChoiceDialogSaveContinue),
        ),
      ],
    );
  }

  void _toggleOption(String option) {
    setState(() {
      _errorText = null;
      if (_isNone(option)) {
        _selected
          ..clear()
          ..add(option);
        _otherSelected = false;
        _otherController.clear();
        return;
      }
      _selected.removeWhere(_isNone);
      if (widget.question.allowMultiple) {
        if (_selected.contains(option)) {
          _selected.remove(option);
        } else {
          final max = widget.question.maxSelections;
          if (max == null || _selected.length < max) {
            _selected.add(option);
          }
        }
      } else {
        _selected
          ..clear()
          ..add(option);
        _otherSelected = false;
      }
    });
  }

  void _toggleOther() {
    setState(() {
      _errorText = null;
      _selected.removeWhere(_isNone);
      if (widget.question.allowMultiple) {
        _otherSelected = !_otherSelected;
      } else {
        _selected.clear();
        _otherSelected = true;
      }
    });
  }

  void _save() {
    final l = AppLocalizations.of(context)!;
    final values = [..._selected];
    if (_otherSelected) {
      values.addAll(_splitSaved(_otherController.text));
    }
    final unique = <String>[];
    for (final value in values) {
      final clean = value.trim();
      if (clean.isEmpty) continue;
      if (!unique.any((existing) => _same(existing, clean))) {
        unique.add(clean);
      }
    }
    final min =
        widget.question.minSelections ?? (widget.question.required ? 1 : 0);
    if (unique.length < min) {
      setState(() => _errorText = l.intakeChoiceDialogSelectionRequired);
      return;
    }
    Navigator.of(context).pop(
      IntakeChoiceDialogResult(
        action: IntakeChoiceDialogAction.save,
        answer: unique.join('\n'),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                size: 20,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  softWrap: true,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<String> _splitSaved(String value) {
  return value
      .split(RegExp(r'[\n;,]+'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

String _matchingOption(List<String> options, String value) {
  return options.firstWhere((option) => _same(option, value));
}

bool _same(String a, String b) {
  return a.trim().toLowerCase() == b.trim().toLowerCase();
}

bool _isNone(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized == 'keine' ||
      normalized == 'none' ||
      normalized == 'no fixed structure';
}
