/// Enums for the Community Radar module — the first domain of the future
/// "Human Intelligence Network".
///
/// The network is designed to host more than community engagement over time
/// (product tests, idea research, translations, …). To keep the architecture
/// open, tasks carry a [HumanIntelligenceDomain]; CR-1 only populates
/// [HumanIntelligenceDomain.communityEngagement], but the model and repository
/// interface already treat the domain as a first-class dimension.
library;

/// The service domains the Human Intelligence Network can host. CR-1 uses
/// only [communityEngagement]; the rest are declared so later blocks can add
/// them without changing the task model or repository contract.
enum HumanIntelligenceDomain {
  communityEngagement,
  productTest,
  ideaResearch,
  translation,
  other,
}

/// Public platform a discovered piece of content lives on. Deliberately a
/// broad enum — matching and allowed actions are configured per platform.
enum CommunityPlatform {
  reddit,
  facebookGroup,
  forum,
  instagram,
  x,
  youtube,
  other,
}

/// What the AI detected the author is trying to do. Purely descriptive.
enum ContentIntent {
  question,
  complaint,
  recommendationRequest,
  discussion,
  comparison,
  experienceShare,
  other,
}

enum ContentSentiment { positive, neutral, negative, mixed }

/// Lifecycle of a discovered content item inside the radar.
enum ContentStatus {
  newContent,
  reviewing,
  matched,
  taskCreated,
  actioned,
  dismissed,
}

/// Voluntary reaction a real community member can choose to perform on the
/// original platform. Never executed automatically — a human always decides.
///
/// Not every platform supports every action; see [platformAllowedActions].
enum CommunityActionType {
  viewOnly,
  like,
  share,
  repost,
  shortPersonalComment,
  personalExperience,
  factualAnswer,
  askFollowUpQuestion,
  openOriginal,
  skip,
}

/// Lifecycle of a voluntary task offered to a community member.
enum CommunityTaskStatus {
  open,
  offered,
  accepted,
  declined,
  completed,
  expired,
}

/// Status of a member in the shared, company-independent pool.
enum MemberStatus { active, pending, paused, blocked }

/// Which [CommunityActionType]s are technically/policy-wise available per
/// platform. Central config so screens never hard-code platform rules.
/// [CommunityActionType.openOriginal] and [CommunityActionType.skip] are
/// always available and therefore added to every platform's set at read time
/// via [allowedActionsFor].
const Map<CommunityPlatform, Set<CommunityActionType>> platformAllowedActions =
    {
      CommunityPlatform.reddit: {
        CommunityActionType.viewOnly,
        CommunityActionType.like,
        CommunityActionType.shortPersonalComment,
        CommunityActionType.personalExperience,
        CommunityActionType.factualAnswer,
        CommunityActionType.askFollowUpQuestion,
      },
      CommunityPlatform.facebookGroup: {
        CommunityActionType.viewOnly,
        CommunityActionType.like,
        CommunityActionType.share,
        CommunityActionType.shortPersonalComment,
        CommunityActionType.personalExperience,
        CommunityActionType.factualAnswer,
        CommunityActionType.askFollowUpQuestion,
      },
      CommunityPlatform.forum: {
        CommunityActionType.viewOnly,
        CommunityActionType.personalExperience,
        CommunityActionType.factualAnswer,
        CommunityActionType.askFollowUpQuestion,
      },
      CommunityPlatform.instagram: {
        CommunityActionType.viewOnly,
        CommunityActionType.like,
        CommunityActionType.shortPersonalComment,
      },
      CommunityPlatform.x: {
        CommunityActionType.viewOnly,
        CommunityActionType.like,
        CommunityActionType.repost,
        CommunityActionType.shortPersonalComment,
        CommunityActionType.askFollowUpQuestion,
      },
      CommunityPlatform.youtube: {
        CommunityActionType.viewOnly,
        CommunityActionType.like,
        CommunityActionType.shortPersonalComment,
      },
      CommunityPlatform.other: {CommunityActionType.viewOnly},
    };

/// Actions available on [platform]: the platform-specific set plus the
/// always-available [CommunityActionType.openOriginal] and
/// [CommunityActionType.skip].
Set<CommunityActionType> allowedActionsFor(CommunityPlatform platform) {
  return {
    ...?platformAllowedActions[platform],
    CommunityActionType.openOriginal,
    CommunityActionType.skip,
  };
}

/// Whether [action] is permitted on [platform].
bool isActionAllowedOn(CommunityPlatform platform, CommunityActionType action) {
  return allowedActionsFor(platform).contains(action);
}
