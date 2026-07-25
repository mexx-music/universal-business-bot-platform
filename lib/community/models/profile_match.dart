/// Explains, factually, why a member's profile fits a piece of content.
///
/// It never claims a person is "credible" or "not credible", and never
/// invents medical qualification or product experience. [matchReasons] state
/// only observable facts ("already posts about cats publicly", "same
/// language", "active on the same platform", "voluntarily declared interest
/// in pet products"); [warnings] flag things a human should weigh.
class ProfileMatch {
  const ProfileMatch({
    required this.id,
    required this.memberId,
    required this.contentId,
    required this.languageMatch,
    required this.countryMatch,
    required this.topicMatch,
    required this.experienceMatch,
    required this.platformMatch,
    required this.authenticityMatch,
    required this.overallMatchScore,
    required this.matchReasons,
    this.warnings = const [],
  });

  final String id;
  final String memberId;
  final String contentId;

  final bool languageMatch;
  final bool countryMatch;
  final bool topicMatch;
  final bool experienceMatch;
  final bool platformMatch;
  final bool authenticityMatch;

  /// 0–100 overall thematic fit.
  final int overallMatchScore;

  /// Factual, non-judgemental reasons for the fit.
  final List<String> matchReasons;

  /// Things a human should consider (e.g. "no first-hand experience declared").
  final List<String> warnings;
}
