import 'models/community_enums.dart';
import 'models/community_member.dart';
import 'models/discovered_content.dart';
import 'models/profile_match.dart';

/// Deterministic, explainable matching between discovered content and the
/// shared member pool. No AI, no randomness: the same inputs always produce
/// the same scores, components, warnings and order.
///
/// Scoring (soft factors, summing to 100 when all match):
///   language 25 · topic 20 · platform 15 · experience 15 · country 10 ·
///   public activity 10 (consent-gated) · preferred action 5
///
/// Hard exclusions make a member ineligible (never proposed for assignment)
/// regardless of score: excluded company, excluded topic, unavailable,
/// blocked account, unsupported domain. A missing profile-analysis consent is
/// NOT a block — it only removes the public-activity factor and adds a
/// warning; no public profile data is used in that case.
class CommunityMatchingService {
  const CommunityMatchingService({this.lowAuthenticityThreshold = 70});

  /// Below this [CommunityMember.accountAuthenticityScore] a neutral warning
  /// is added (never a "not credible" verdict).
  final int lowAuthenticityThreshold;

  static const Map<MatchFactor, int> _maxPoints = {
    MatchFactor.language: 25,
    MatchFactor.topic: 20,
    MatchFactor.platform: 15,
    MatchFactor.experience: 15,
    MatchFactor.country: 10,
    MatchFactor.publicActivity: 10,
    MatchFactor.preferredAction: 5,
  };

  /// Content is community engagement work.
  static const HumanIntelligenceDomain _contentDomain =
      HumanIntelligenceDomain.communityEngagement;

  /// Ranks all [members] against [content]: eligible first (highest score
  /// first), then ineligible; ties broken by member id for stable order.
  List<ProfileMatch> matchContent(
    DiscoveredContent content,
    List<CommunityMember> members,
  ) {
    final matches = [for (final member in members) evaluate(content, member)];
    return _sorted(matches);
  }

  /// Ranks all [contents] against [member], same ordering rules.
  List<ProfileMatch> matchMember(
    CommunityMember member,
    List<DiscoveredContent> contents,
  ) {
    final matches = [for (final content in contents) evaluate(content, member)];
    return _sorted(matches);
  }

  List<ProfileMatch> _sorted(List<ProfileMatch> matches) {
    matches.sort((a, b) {
      if (a.eligible != b.eligible) return a.eligible ? -1 : 1;
      final byScore = b.overallMatchScore.compareTo(a.overallMatchScore);
      return byScore != 0 ? byScore : a.memberId.compareTo(b.memberId);
    });
    return matches;
  }

  /// Evaluates a single content/member pair into an explainable [ProfileMatch].
  ProfileMatch evaluate(DiscoveredContent content, CommunityMember member) {
    final blockReasons = _blockReasons(content, member);
    final topics = content.topicTags.map((t) => t.toLowerCase()).toSet();

    final interests = {
      ...member.declaredInterests.map((t) => t.toLowerCase()),
      ...member.verifiedTopics.map((t) => t.toLowerCase()),
    };
    final experience = member.experienceCategories
        .map((t) => t.toLowerCase())
        .toSet();
    final publicTopics = member.publicActivityTopics
        .map((t) => t.toLowerCase())
        .toSet();

    final components = <MatchComponent>[
      _component(
        MatchFactor.language,
        member.languages.contains(content.language),
        detail: content.language.toUpperCase(),
      ),
      _component(
        MatchFactor.topic,
        topics.intersection(interests).isNotEmpty,
        detail: _firstOverlap(topics, interests),
      ),
      _component(
        MatchFactor.platform,
        member.platforms.contains(content.platform),
      ),
      _component(
        MatchFactor.experience,
        topics.intersection(experience).isNotEmpty,
        detail: _firstOverlap(topics, experience),
      ),
      _component(
        MatchFactor.country,
        member.country == content.country,
        detail: content.country,
      ),
      // Public-activity factor is only used with consent; otherwise it scores
      // zero and never reads the member's public profile data.
      _component(
        MatchFactor.publicActivity,
        member.profileAnalysisConsent &&
            topics.intersection(publicTopics).isNotEmpty,
        detail: member.profileAnalysisConsent
            ? _firstOverlap(topics, publicTopics)
            : null,
      ),
      _component(
        MatchFactor.preferredAction,
        member.preferredActions
            .toSet()
            .intersection(content.recommendedActionTypes.toSet())
            .isNotEmpty,
      ),
    ];

    final score = components.fold<int>(0, (sum, c) => sum + c.points);

    final warnings = <MatchWarning>[
      if (!member.platforms.contains(content.platform))
        MatchWarning.notOnPlatform,
      if (topics.intersection(experience).isEmpty) MatchWarning.noExperience,
      if (!member.profileAnalysisConsent) MatchWarning.profileAnalysisNoConsent,
      if (member.accountAuthenticityScore < lowAuthenticityThreshold)
        MatchWarning.lowAuthenticity,
    ];

    final possibleActions = [
      for (final a in content.recommendedActionTypes)
        if (isActionAllowedOn(content.platform, a)) a,
    ];

    return ProfileMatch(
      id: 'pm-${content.id}-${member.id}',
      memberId: member.id,
      contentId: content.id,
      overallMatchScore: score,
      eligible: blockReasons.isEmpty,
      components: components,
      warnings: warnings,
      blockReasons: blockReasons,
      disclosureRequired: member.disclosureRequirements.isNotEmpty,
      possibleActions: possibleActions,
    );
  }

  List<MatchBlockReason> _blockReasons(
    DiscoveredContent content,
    CommunityMember member,
  ) {
    final reasons = <MatchBlockReason>[];
    if (member.status == MemberStatus.blocked) {
      reasons.add(const MatchBlockReason(reason: MatchBlock.accountBlocked));
    }
    if (!member.isAvailable || member.status == MemberStatus.paused) {
      reasons.add(const MatchBlockReason(reason: MatchBlock.unavailable));
    }
    if (member.excludedCompanyIds.contains(content.companyId)) {
      reasons.add(
        MatchBlockReason(
          reason: MatchBlock.companyExcluded,
          detail: content.companyId,
        ),
      );
    }
    final excluded = member.excludedTopics.map((t) => t.toLowerCase()).toSet();
    final excludedHit = _firstOverlap(
      content.topicTags.map((t) => t.toLowerCase()).toSet(),
      excluded,
    );
    if (excludedHit != null) {
      reasons.add(
        MatchBlockReason(reason: MatchBlock.topicExcluded, detail: excludedHit),
      );
    }
    if (!member.supportedDomains.contains(_contentDomain)) {
      reasons.add(const MatchBlockReason(reason: MatchBlock.domainUnsupported));
    }
    return reasons;
  }

  MatchComponent _component(
    MatchFactor factor,
    bool matched, {
    String? detail,
  }) {
    final max = _maxPoints[factor]!;
    return MatchComponent(
      factor: factor,
      matched: matched,
      points: matched ? max : 0,
      maxPoints: max,
      detail: matched ? detail : null,
    );
  }

  /// The first overlapping element in iteration order — deterministic.
  String? _firstOverlap(Set<String> a, Set<String> b) {
    for (final value in a) {
      if (b.contains(value)) return value;
    }
    return null;
  }
}
