import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import 'models/community_enums.dart';

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
