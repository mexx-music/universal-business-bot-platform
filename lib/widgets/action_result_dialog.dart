import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/action_record.dart';

/// The user's answers from the "Maßnahme abschließen"/"bewerten" dialog.
class ActionCompletionResult {
  const ActionCompletionResult({
    this.rating,
    this.note,
    this.outcome,
    this.repeat,
  });

  final ActionResultRating? rating;
  final String? note;
  final String? outcome;
  final bool? repeat;
}

/// Localized label for a result rating.
String actionRatingLabel(AppLocalizations l, ActionResultRating rating) {
  return switch (rating) {
    ActionResultRating.helpedALot => l.ratingHelpedALot,
    ActionResultRating.helpedSomewhat => l.ratingHelpedSomewhat,
    ActionResultRating.noEffect => l.ratingNoEffect,
    ActionResultRating.negative => l.ratingNegative,
    ActionResultRating.notYetRatable => l.ratingNotYet,
  };
}

/// Shows the simple result dialog ("Hat die Maßnahme geholfen?") and calls
/// [onSave] when the user confirms. Shared between /next-actions and the
/// check-in flow.
Future<void> showActionResultDialog(
  BuildContext context, {
  required void Function(ActionCompletionResult result) onSave,
}) async {
  final l = AppLocalizations.of(context)!;
  final noteController = TextEditingController();
  final outcomeController = TextEditingController();
  var rating = ActionResultRating.notYetRatable;
  var repeat = false;

  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: Text(l.completeDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.completeDialogQuestion),
              const SizedBox(height: 4),
              RadioGroup<ActionResultRating>(
                groupValue: rating,
                onChanged: (value) => setState(
                  () => rating = value ?? ActionResultRating.notYetRatable,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final option in ActionResultRating.values)
                      RadioListTile<ActionResultRating>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(actionRatingLabel(l, option)),
                        value: option,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                decoration: InputDecoration(labelText: l.completeWhatHappened),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: outcomeController,
                decoration: InputDecoration(
                  labelText: l.completeMetricChanged,
                ),
              ),
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(l.completeRepeatQuestion),
                value: repeat,
                onChanged: (value) => setState(() => repeat = value ?? false),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l.btnCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l.actionSave),
          ),
        ],
      ),
    ),
  );

  if (saved == true) {
    onSave(
      ActionCompletionResult(
        rating: rating,
        note: noteController.text,
        outcome: outcomeController.text,
        repeat: repeat,
      ),
    );
  }
  noteController.dispose();
  outcomeController.dispose();
}
