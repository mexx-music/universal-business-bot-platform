import 'community_enums.dart';

/// A named contribution to an overall match score. Kept explicit so the
/// matching view can show *why* a score is what it is — no black box.
enum MatchFactor {
  language,
  country,
  topic,
  experience,
  platform,
  publicActivity,
  preferredAction,
}

/// Soft warnings a human should weigh (not hard blocks).
enum MatchWarning {
  noExperience,
  notOnPlatform,
  lowAuthenticity,
  profileAnalysisNoConsent,
}

/// Hard exclusions that make a member ineligible for a task.
enum MatchBlock {
  companyExcluded,
  topicExcluded,
  unavailable,
  accountBlocked,
  domainUnsupported,
}

class MatchComponent {
  const MatchComponent({
    required this.factor,
    required this.matched,
    required this.points,
    required this.maxPoints,
    this.detail,
  });

  final MatchFactor factor;
  final bool matched;
  final int points;
  final int maxPoints;

  /// Optional matched token, e.g. the overlapping topic — for display only.
  final String? detail;
}

/// A hard exclusion with an optional detail token (e.g. the excluded topic).
class MatchBlockReason {
  const MatchBlockReason({required this.reason, this.detail});

  final MatchBlock reason;
  final String? detail;
}

/// Explains, factually, how well a member's profile fits a piece of content.
///
/// It never claims a person is "credible" or "not credible", and never
/// invents medical qualification or product experience. Warnings and block
/// reasons are structured (not free text) so the UI can localise them.
/// Produced by the deterministic [CommunityMatchingService].
class ProfileMatch {
  const ProfileMatch({
    required this.id,
    required this.memberId,
    required this.contentId,
    required this.overallMatchScore,
    required this.eligible,
    required this.components,
    this.warnings = const [],
    this.blockReasons = const [],
    this.disclosureRequired = false,
    this.possibleActions = const [],
  });

  final String id;
  final String memberId;
  final String contentId;

  /// 0–100 overall thematic fit (sum of earned component points).
  final int overallMatchScore;

  /// False when a hard exclusion applies (see [blockReasons]). Ineligible
  /// members are never proposed for assignment.
  final bool eligible;

  /// Per-factor score breakdown, always present for transparency.
  final List<MatchComponent> components;

  final List<MatchWarning> warnings;
  final List<MatchBlockReason> blockReasons;

  /// Whether a disclosure would be required if this member acted.
  final bool disclosureRequired;

  /// Reaction types available for this content on its platform.
  final List<CommunityActionType> possibleActions;

  /// The matched components, i.e. the factual reasons the profile fits.
  List<MatchComponent> get matchedComponents =>
      components.where((c) => c.matched).toList();
}
