import 'community_enums.dart';

/// A fictional platform handle for a member. No real accounts are stored.
class MemberPlatformProfile {
  const MemberPlatformProfile({required this.platform, required this.handle});

  final CommunityPlatform platform;

  /// A display handle only — deliberately fictional in the demo.
  final String handle;
}

/// A real person in the shared, company-independent pool. The same member can
/// be matched to content from any company, which is exactly why members are
/// NOT part of any [CompanyWorkspace].
///
/// Public activity is only ever analysed where technically, legally and
/// platform-policy-wise permitted, or where the member has explicitly
/// consented. The scores below are neutral signals, never a verdict on a
/// person's credibility.
class CommunityMember {
  const CommunityMember({
    required this.id,
    required this.displayName,
    required this.country,
    required this.languages,
    required this.platformProfiles,
    required this.declaredInterests,
    required this.verifiedTopics,
    required this.publicActivityTopics,
    required this.writingStyle,
    required this.experienceCategories,
    required this.isVerified,
    required this.accountAuthenticityScore,
    required this.qualityScore,
    required this.availability,
    required this.compensationEnabled,
    required this.disclosureRequirements,
    required this.status,
    this.completedTaskCount = 0,
    this.preferredActions = const [],
    this.supportedDomains = const [HumanIntelligenceDomain.communityEngagement],
    this.excludedTopics = const [],
    this.excludedCompanyIds = const [],
    this.profileAnalysisConsent = true,
    this.isAvailable = true,
  });

  final String id;
  final String displayName;

  /// ISO 3166-1 alpha-2 country code.
  final String country;

  /// ISO 639-1 language codes the member is comfortable writing in.
  final List<String> languages;

  final List<MemberPlatformProfile> platformProfiles;

  /// Interests the member voluntarily declared.
  final List<String> declaredInterests;

  /// Topics confirmed through a verification step.
  final List<String> verifiedTopics;

  /// Topics the member already posts about publicly (only where permitted).
  final List<String> publicActivityTopics;

  final String writingStyle;

  /// Categories of first-hand experience the member reports having.
  final List<String> experienceCategories;

  final bool isVerified;

  /// 0–100 neutral signal of account authenticity — NOT a credibility verdict.
  final int accountAuthenticityScore;

  /// 0–100 quality of previously completed tasks.
  final int qualityScore;

  final String availability;
  final bool compensationEnabled;

  /// Disclosure obligations that apply to this member (e.g. "paid partnership").
  final List<String> disclosureRequirements;

  final MemberStatus status;
  final int completedTaskCount;

  /// Reaction types the member prefers to perform.
  final List<CommunityActionType> preferredActions;

  /// Human Intelligence Network domains the member is willing to work in.
  final List<HumanIntelligenceDomain> supportedDomains;

  /// Topics the member never wants tasks about (hard exclusion in matching).
  final List<String> excludedTopics;

  /// Company ids the member never wants tasks for (hard exclusion).
  final List<String> excludedCompanyIds;

  /// Whether the member consented to analysis of their public activity. When
  /// false, matching must NOT use [publicActivityTopics].
  final bool profileAnalysisConsent;

  /// Whether the member is currently available for tasks (hard gate).
  final bool isAvailable;

  Set<CommunityPlatform> get platforms =>
      platformProfiles.map((p) => p.platform).toSet();
}
