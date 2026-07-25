import 'community_enums.dart';

/// A voluntary task offered to a community member. Its lifecycle mirrors the
/// existing [ActionRecord] pattern (accept / decline / complete + note), which
/// is why the app already has the muscle for "AI proposes, human decides".
///
/// [domain] keeps the model open for the wider Human Intelligence Network:
/// CR-1 only creates [HumanIntelligenceDomain.communityEngagement] tasks, but
/// product tests, idea research and translations will reuse this exact model.
///
/// Compensation is never tied to a positive statement — it is owed only for a
/// permissible, genuine, properly executed task. A later compliance block
/// enforces [prohibitedClaims] and [disclosureRequired].
class CommunityTask {
  const CommunityTask({
    required this.id,
    required this.contentId,
    required this.companyId,
    required this.allowedActions,
    required this.guidance,
    required this.status,
    this.domain = HumanIntelligenceDomain.communityEngagement,
    this.assignedMemberId,
    this.prohibitedClaims = const [],
    this.disclosureRequired = false,
    this.compensation,
    this.deadline,
    this.acceptedAt,
    this.completedAt,
    this.completionNote,
  });

  final String id;
  final String contentId;
  final String companyId;

  /// The Human Intelligence Network domain this task belongs to.
  final HumanIntelligenceDomain domain;

  final String? assignedMemberId;

  /// Actions the member may choose from — a subset of what the platform allows.
  final List<CommunityActionType> allowedActions;

  /// Guidance that must never yield identical mass comments — it asks for the
  /// member's own words and real experience.
  final String guidance;

  final List<String> prohibitedClaims;
  final bool disclosureRequired;

  /// Optional compensation label, e.g. "5 EUR". Null = unpaid.
  final String? compensation;

  final DateTime? deadline;
  final CommunityTaskStatus status;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final String? completionNote;

  bool get isPaid => compensation != null && compensation!.trim().isNotEmpty;

  bool get isOpen =>
      status == CommunityTaskStatus.open ||
      status == CommunityTaskStatus.offered;
}
