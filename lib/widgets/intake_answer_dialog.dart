import 'package:flutter/material.dart';

import '../data/intake_chat_flow.dart';
import '../l10n/app_localizations.dart';

enum IntakeAnswerDialogAction { save, defer, cancel }

class IntakeAnswerDialogResult {
  final IntakeAnswerDialogAction action;
  final String answer;

  const IntakeAnswerDialogResult({required this.action, this.answer = ''});
}

class IntakeAnswerDialog extends StatefulWidget {
  final IntakeChatQuestion question;
  final String initialValue;
  final String defaultValue;

  const IntakeAnswerDialog({
    super.key,
    required this.question,
    required this.initialValue,
    required this.defaultValue,
  });

  @override
  State<IntakeAnswerDialog> createState() => _IntakeAnswerDialogState();
}

class _IntakeAnswerDialogState extends State<IntakeAnswerDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue.trim().isEmpty
          ? widget.defaultValue
          : widget.initialValue,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final question = widget.question;
    final isMultiLine =
        question.type == IntakeChatQuestionType.longText ||
        question.type == IntakeChatQuestionType.multiLineList;

    return AlertDialog(
      title: Text(question.text(l)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.helpText != null) ...[
              Text(
                question.helpText!(l),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
            ],
            if (question.isListQuestion) ...[
              Text(
                l.intakeChatListHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
            ],
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: _keyboardType(question.type),
              minLines: isMultiLine ? 4 : 1,
              maxLines: isMultiLine ? 8 : 1,
              textInputAction: isMultiLine
                  ? TextInputAction.newline
                  : TextInputAction.done,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: question.inputHint?.call(l) ?? l.intakeChatInputHint,
                errorText: _errorText,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
              ),
              onSubmitted: (_) {
                if (!isMultiLine) _save(l);
              },
            ),
            const SizedBox(height: 8),
            Text(
              IntakeChatFlow.exampleText(l, question),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            const IntakeAnswerDialogResult(
              action: IntakeAnswerDialogAction.cancel,
            ),
          ),
          child: Text(l.intakeChatDialogCancel),
        ),
        TextButton(
          onPressed: question.skippable
              ? () => Navigator.of(context).pop(
                  const IntakeAnswerDialogResult(
                    action: IntakeAnswerDialogAction.defer,
                  ),
                )
              : null,
          child: Text(l.intakeChatDialogDefer),
        ),
        FilledButton(
          onPressed: () => _save(l),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
          child: Text(l.intakeChatDialogSaveContinue),
        ),
      ],
    );
  }

  void _save(AppLocalizations l) {
    final validationMessage = IntakeChatFlow.validateAnswer(
      widget.question,
      _controller.text,
      l,
    );
    if (validationMessage != null) {
      setState(() => _errorText = validationMessage);
      return;
    }
    Navigator.of(context).pop(
      IntakeAnswerDialogResult(
        action: IntakeAnswerDialogAction.save,
        answer: IntakeChatFlow.normalizeAnswerForQuestion(
          widget.question,
          _controller.text,
        ),
      ),
    );
  }
}

TextInputType _keyboardType(IntakeChatQuestionType type) {
  return switch (type) {
    IntakeChatQuestionType.email => TextInputType.emailAddress,
    IntakeChatQuestionType.url => TextInputType.url,
    IntakeChatQuestionType.approximateNumber => TextInputType.text,
    IntakeChatQuestionType.longText ||
    IntakeChatQuestionType.multiLineList => TextInputType.multiline,
    _ => TextInputType.text,
  };
}
