import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import 'models/community_enums.dart';
import 'models/profile_match.dart';

/// Locale-aware labels for the Community Radar enums. Kept in the module (not
/// in the app-wide label_helpers) to keep this bounded context self-contained.

String communityPlatformLabel(BuildContext context, CommunityPlatform p) {
  final l = AppLocalizations.of(context)!;
  return switch (p) {
    CommunityPlatform.reddit => l.communityPlatformReddit,
    CommunityPlatform.facebookGroup => l.communityPlatformFacebookGroup,
    CommunityPlatform.forum => l.communityPlatformForum,
    CommunityPlatform.instagram => l.communityPlatformInstagram,
    CommunityPlatform.x => l.communityPlatformX,
    CommunityPlatform.youtube => l.communityPlatformYoutube,
    CommunityPlatform.other => l.communityPlatformOther,
  };
}

String communityIntentLabel(BuildContext context, ContentIntent i) {
  final l = AppLocalizations.of(context)!;
  return switch (i) {
    ContentIntent.question => l.communityIntentQuestion,
    ContentIntent.complaint => l.communityIntentComplaint,
    ContentIntent.recommendationRequest =>
      l.communityIntentRecommendationRequest,
    ContentIntent.discussion => l.communityIntentDiscussion,
    ContentIntent.comparison => l.communityIntentComparison,
    ContentIntent.experienceShare => l.communityIntentExperienceShare,
    ContentIntent.other => l.communityIntentOther,
  };
}

String communitySentimentLabel(BuildContext context, ContentSentiment s) {
  final l = AppLocalizations.of(context)!;
  return switch (s) {
    ContentSentiment.positive => l.communitySentimentPositive,
    ContentSentiment.neutral => l.communitySentimentNeutral,
    ContentSentiment.negative => l.communitySentimentNegative,
    ContentSentiment.mixed => l.communitySentimentMixed,
  };
}

String communityStatusLabel(BuildContext context, ContentStatus s) {
  final l = AppLocalizations.of(context)!;
  return switch (s) {
    ContentStatus.newContent => l.communityStatusNew,
    ContentStatus.reviewing => l.communityStatusReviewing,
    ContentStatus.matched => l.communityStatusMatched,
    ContentStatus.taskCreated => l.communityStatusTaskCreated,
    ContentStatus.actioned => l.communityStatusActioned,
    ContentStatus.dismissed => l.communityStatusDismissed,
  };
}

String communityActionLabel(BuildContext context, CommunityActionType a) {
  final l = AppLocalizations.of(context)!;
  return switch (a) {
    CommunityActionType.viewOnly => l.communityActionViewOnly,
    CommunityActionType.like => l.communityActionLike,
    CommunityActionType.share => l.communityActionShare,
    CommunityActionType.repost => l.communityActionRepost,
    CommunityActionType.shortPersonalComment =>
      l.communityActionShortPersonalComment,
    CommunityActionType.personalExperience =>
      l.communityActionPersonalExperience,
    CommunityActionType.factualAnswer => l.communityActionFactualAnswer,
    CommunityActionType.askFollowUpQuestion =>
      l.communityActionAskFollowUpQuestion,
    CommunityActionType.openOriginal => l.communityActionOpenOriginal,
    CommunityActionType.skip => l.communityActionSkip,
  };
}

String communityDomainLabel(BuildContext context, HumanIntelligenceDomain d) {
  final l = AppLocalizations.of(context)!;
  return switch (d) {
    HumanIntelligenceDomain.communityEngagement =>
      l.communityDomainCommunityEngagement,
    HumanIntelligenceDomain.productTest => l.communityDomainProductTest,
    HumanIntelligenceDomain.ideaResearch => l.communityDomainIdeaResearch,
    HumanIntelligenceDomain.translation => l.communityDomainTranslation,
    HumanIntelligenceDomain.other => l.communityDomainOther,
  };
}

String communityMemberStatusLabel(BuildContext context, MemberStatus s) {
  final l = AppLocalizations.of(context)!;
  return switch (s) {
    MemberStatus.active => l.communityMemberStatusActive,
    MemberStatus.pending => l.communityMemberStatusPending,
    MemberStatus.paused => l.communityMemberStatusPaused,
    MemberStatus.blocked => l.communityMemberStatusBlocked,
  };
}

String communityFactorLabel(BuildContext context, MatchFactor f) {
  final l = AppLocalizations.of(context)!;
  return switch (f) {
    MatchFactor.language => l.communityFactorLanguage,
    MatchFactor.country => l.communityFactorCountry,
    MatchFactor.topic => l.communityFactorTopic,
    MatchFactor.experience => l.communityFactorExperience,
    MatchFactor.platform => l.communityFactorPlatform,
    MatchFactor.publicActivity => l.communityFactorPublicActivity,
    MatchFactor.preferredAction => l.communityFactorPreferredAction,
  };
}

String communityWarningLabel(BuildContext context, MatchWarning w) {
  final l = AppLocalizations.of(context)!;
  return switch (w) {
    MatchWarning.noExperience => l.communityWarningNoExperience,
    MatchWarning.notOnPlatform => l.communityWarningNotOnPlatform,
    MatchWarning.lowAuthenticity => l.communityWarningLowAuthenticity,
    MatchWarning.profileAnalysisNoConsent =>
      l.communityWarningProfileAnalysisNoConsent,
  };
}

String communityBlockLabel(BuildContext context, MatchBlockReason b) {
  final l = AppLocalizations.of(context)!;
  final base = switch (b.reason) {
    MatchBlock.companyExcluded => l.communityBlockCompanyExcluded,
    MatchBlock.topicExcluded => l.communityBlockTopicExcluded,
    MatchBlock.unavailable => l.communityBlockUnavailable,
    MatchBlock.accountBlocked => l.communityBlockAccountBlocked,
    MatchBlock.domainUnsupported => l.communityBlockDomainUnsupported,
  };
  return b.detail == null ? base : '$base: ${b.detail}';
}
