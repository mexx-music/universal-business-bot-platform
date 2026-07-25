import 'community_enums.dart';

/// The record of what a real person actually did on the original platform,
/// in their own words and by their own decision. This is the audit trail of
/// human intelligence: every voluntary action is documented, never inferred.
class HumanActionReport {
  const HumanActionReport({
    required this.id,
    required this.taskId,
    required this.actionType,
    required this.performedBy,
    required this.performedAt,
    this.originalPlatformUrl,
    this.selfWrittenText,
    this.wasEditedFromGuidance = false,
    this.disclosureUsed = false,
    this.resultStatus = 'submitted',
    this.moderationNotes,
  });

  final String id;
  final String taskId;
  final CommunityActionType actionType;

  /// Member id of the person who performed the action.
  final String performedBy;

  final DateTime performedAt;
  final String? originalPlatformUrl;

  /// The text the member wrote themselves, if any.
  final String? selfWrittenText;

  /// True when the member changed the text away from the guidance — expected
  /// and encouraged, since identical mass comments are not allowed.
  final bool wasEditedFromGuidance;

  /// Whether the required disclosure was actually included.
  final bool disclosureUsed;

  final String resultStatus;
  final String? moderationNotes;
}
