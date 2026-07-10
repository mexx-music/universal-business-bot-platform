import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/intake_session.dart';

enum IntakeChatQuestionType { shortText, longText, yesNo, multiLineList }

class IntakeChatQuestion {
  final String questionKey;
  final String blockKey;
  final IntakeChatQuestionType type;
  final String Function(AppLocalizations l) text;
  final bool Function(IntakeSession session) shouldAsk;
  final bool Function(IntakeSession session) isAnswered;
  final void Function(AppState state, String answer) saveAnswer;

  const IntakeChatQuestion({
    required this.questionKey,
    required this.blockKey,
    required this.type,
    required this.text,
    required this.shouldAsk,
    required this.isAnswered,
    required this.saveAnswer,
  });
}

class IntakeChatFlow {
  static final List<IntakeChatQuestion> questions = [
    _q(
      'companyName',
      'basics',
      IntakeChatQuestionType.shortText,
      (l) => l.intakeChatQCompanyName,
      (s) => s.basics.companyName,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(companyName: answer.trim()),
      ),
    ),
    _q(
      'shortDescription',
      'basics',
      IntakeChatQuestionType.longText,
      (l) => l.intakeChatQShortDescription,
      (s) => s.basics.shortDescription,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(shortDescription: answer.trim()),
      ),
    ),
    _q(
      'industry',
      'basics',
      IntakeChatQuestionType.shortText,
      (l) => l.intakeChatQIndustry,
      (s) => s.basics.industry,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(industry: answer.trim()),
      ),
    ),
    _q(
      'country',
      'basics',
      IntakeChatQuestionType.shortText,
      (l) => l.intakeChatQCountry,
      (s) => s.basics.country,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(country: answer.trim()),
      ),
    ),
    _q(
      'primaryLanguage',
      'basics',
      IntakeChatQuestionType.shortText,
      (l) => l.intakeChatQPrimaryLanguage,
      (s) => s.basics.primaryLanguage,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(primaryLanguage: answer.trim()),
      ),
    ),
    _yesNo(
      'hasWebsite',
      'basics',
      (l) => l.intakeChatQHasWebsite,
      (s) => s.basics.hasWebsite,
      (state, value) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(hasWebsite: value),
      ),
    ),
    _q(
      'website',
      'basics',
      IntakeChatQuestionType.shortText,
      (l) => l.intakeChatQWebsite,
      (s) => s.basics.website,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(website: answer.trim()),
      ),
      shouldAsk: (s) => s.basics.hasWebsite != false,
    ),
    _q(
      'supportEmail',
      'basics',
      IntakeChatQuestionType.shortText,
      (l) => l.intakeChatQSupportEmail,
      (s) => s.basics.supportEmail,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(supportEmail: answer.trim()),
      ),
    ),
    _q(
      'supportPhone',
      'basics',
      IntakeChatQuestionType.shortText,
      (l) => l.intakeChatQSupportPhone,
      (s) => s.basics.supportPhone,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(supportPhone: answer.trim()),
      ),
    ),
    _q(
      'importantProducts',
      'products',
      IntakeChatQuestionType.multiLineList,
      (l) => l.intakeChatQImportantProducts,
      (s) => s.products.importantProducts,
      (state, answer) => state.updateIntakeProducts(
        state.intakeSession!.products.copyWith(
          importantProducts: _mergeListText(
            state.intakeSession!.products.importantProducts,
            answer,
          ),
        ),
      ),
    ),
    _q(
      'mainProduct',
      'products',
      IntakeChatQuestionType.shortText,
      (l) => l.intakeChatQMainProduct,
      (s) => s.products.mainProduct,
      (state, answer) => state.updateIntakeProducts(
        state.intakeSession!.products.copyWith(mainProduct: answer.trim()),
      ),
    ),
    _q(
      'priorityProducts',
      'products',
      IntakeChatQuestionType.multiLineList,
      (l) => l.intakeChatQPriorityProducts,
      (s) => s.products.priorityProducts,
      (state, answer) => state.updateIntakeProducts(
        state.intakeSession!.products.copyWith(
          priorityProducts: _mergeListText(
            state.intakeSession!.products.priorityProducts,
            answer,
          ),
        ),
      ),
    ),
    _q(
      'explanationNeeded',
      'products',
      IntakeChatQuestionType.longText,
      (l) => l.intakeChatQExplanationNeeded,
      (s) => s.products.explanationNeeded,
      (state, answer) => state.updateIntakeProducts(
        state.intakeSession!.products.copyWith(
          explanationNeeded: answer.trim(),
        ),
      ),
    ),
    _q(
      'targetGroup',
      'targetGroups',
      IntakeChatQuestionType.longText,
      (l) => l.intakeChatQTargetGroup,
      (s) => s.targetGroups.targetGroup,
      (state, answer) => state.updateIntakeTargetGroups(
        state.intakeSession!.targetGroups.copyWith(targetGroup: answer.trim()),
      ),
    ),
    _q(
      'marketType',
      'targetGroups',
      IntakeChatQuestionType.shortText,
      (l) => l.intakeChatQMarketType,
      (s) => s.targetGroups.marketType,
      (state, answer) => state.updateIntakeTargetGroups(
        state.intakeSession!.targetGroups.copyWith(marketType: answer.trim()),
      ),
    ),
    _q(
      'problemSolved',
      'targetGroups',
      IntakeChatQuestionType.longText,
      (l) => l.intakeChatQProblemSolved,
      (s) => s.targetGroups.problemSolved,
      (state, answer) => state.updateIntakeTargetGroups(
        state.intakeSession!.targetGroups.copyWith(
          problemSolved: answer.trim(),
        ),
      ),
    ),
    _q(
      'customerBenefit',
      'targetGroups',
      IntakeChatQuestionType.longText,
      (l) => l.intakeChatQCustomerBenefit,
      (s) => s.targetGroups.customerBenefit,
      (state, answer) => state.updateIntakeTargetGroups(
        state.intakeSession!.targetGroups.copyWith(
          customerBenefit: answer.trim(),
        ),
      ),
    ),
    _q(
      'differentiation',
      'targetGroups',
      IntakeChatQuestionType.longText,
      (l) => l.intakeChatQDifferentiation,
      (s) => s.targetGroups.differentiation,
      (state, answer) => state.updateIntakeTargetGroups(
        state.intakeSession!.targetGroups.copyWith(
          differentiation: answer.trim(),
        ),
      ),
    ),
    _q(
      'importantPages',
      'websiteAndSupport',
      IntakeChatQuestionType.multiLineList,
      (l) => l.intakeChatQImportantPages,
      (s) => s.websiteAndSupport.importantPages,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          importantPages: _mergeListText(
            state.intakeSession!.websiteAndSupport.importantPages,
            answer,
          ),
        ),
      ),
    ),
    _q(
      'frequentQuestions',
      'websiteAndSupport',
      IntakeChatQuestionType.multiLineList,
      (l) => l.intakeChatQFrequentQuestions,
      (s) => s.websiteAndSupport.frequentQuestions,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          frequentQuestions: _mergeListText(
            state.intakeSession!.websiteAndSupport.frequentQuestions,
            answer,
          ),
        ),
      ),
    ),
    _q(
      'supportProblems',
      'websiteAndSupport',
      IntakeChatQuestionType.multiLineList,
      (l) => l.intakeChatQSupportProblems,
      (s) => s.websiteAndSupport.supportProblems,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          supportProblems: _mergeListText(
            state.intakeSession!.websiteAndSupport.supportProblems,
            answer,
          ),
        ),
      ),
    ),
    _yesNo(
      'hasSensitiveTopics',
      'websiteAndSupport',
      (l) => l.intakeChatQHasSensitiveTopics,
      (s) => s.websiteAndSupport.hasSensitiveTopics,
      (state, value) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          hasSensitiveTopics: value,
        ),
      ),
    ),
    _q(
      'sensitiveTopics',
      'websiteAndSupport',
      IntakeChatQuestionType.multiLineList,
      (l) => l.intakeChatQSensitiveTopics,
      (s) => s.websiteAndSupport.sensitiveTopics,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          sensitiveTopics: _mergeListText(
            state.intakeSession!.websiteAndSupport.sensitiveTopics,
            answer,
          ),
        ),
      ),
      shouldAsk: (s) => s.websiteAndSupport.hasSensitiveTopics != false,
    ),
    _q(
      'existingSources',
      'sourcesAndReviews',
      IntakeChatQuestionType.multiLineList,
      (l) => l.intakeChatQExistingSources,
      (s) => s.sourcesAndReviews.existingSources,
      (state, answer) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          existingSources: _mergeListText(
            state.intakeSession!.sourcesAndReviews.existingSources,
            answer,
          ),
        ),
      ),
    ),
    _yesNo(
      'hasReviews',
      'sourcesAndReviews',
      (l) => l.intakeChatQHasReviews,
      (s) => s.sourcesAndReviews.hasReviews,
      (state, value) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(hasReviews: value),
      ),
    ),
    _q(
      'reviews',
      'sourcesAndReviews',
      IntakeChatQuestionType.multiLineList,
      (l) => l.intakeChatQReviews,
      (s) => s.sourcesAndReviews.reviews,
      (state, answer) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          reviews: _mergeListText(
            state.intakeSession!.sourcesAndReviews.reviews,
            answer,
          ),
        ),
      ),
      shouldAsk: (s) => s.sourcesAndReviews.hasReviews != false,
    ),
    _yesNo(
      'hasSocialMentions',
      'sourcesAndReviews',
      (l) => l.intakeChatQHasSocialMentions,
      (s) => s.sourcesAndReviews.hasSocialMentions,
      (state, value) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          hasSocialMentions: value,
        ),
      ),
    ),
    _q(
      'socialMentions',
      'sourcesAndReviews',
      IntakeChatQuestionType.multiLineList,
      (l) => l.intakeChatQSocialMentions,
      (s) => s.sourcesAndReviews.socialMentions,
      (state, answer) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          socialMentions: _mergeListText(
            state.intakeSession!.sourcesAndReviews.socialMentions,
            answer,
          ),
        ),
      ),
      shouldAsk: (s) => s.sourcesAndReviews.hasSocialMentions != false,
    ),
    _yesNo(
      'hasTrustMaterial',
      'sourcesAndReviews',
      (l) => l.intakeChatQHasTrustMaterial,
      (s) => s.sourcesAndReviews.hasTrustMaterial,
      (state, value) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          hasTrustMaterial: value,
        ),
      ),
    ),
    _q(
      'trustMaterial',
      'sourcesAndReviews',
      IntakeChatQuestionType.multiLineList,
      (l) => l.intakeChatQTrustMaterial,
      (s) => s.sourcesAndReviews.trustMaterial,
      (state, answer) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          trustMaterial: _mergeListText(
            state.intakeSession!.sourcesAndReviews.trustMaterial,
            answer,
          ),
        ),
      ),
      shouldAsk: (s) => s.sourcesAndReviews.hasTrustMaterial != false,
    ),
    _q(
      'channels',
      'marketingAndChannels',
      IntakeChatQuestionType.multiLineList,
      (l) => l.intakeChatQChannels,
      (s) => s.marketingAndChannels.channels,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          channels: _mergeListText(
            state.intakeSession!.marketingAndChannels.channels,
            answer,
          ),
        ),
      ),
    ),
    _q(
      'campaigns',
      'marketingAndChannels',
      IntakeChatQuestionType.longText,
      (l) => l.intakeChatQCampaigns,
      (s) => s.marketingAndChannels.campaigns,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(campaigns: answer),
      ),
    ),
    _q(
      'workedNotWorked',
      'marketingAndChannels',
      IntakeChatQuestionType.longText,
      (l) => l.intakeChatQWorkedNotWorked,
      (s) =>
          '${s.marketingAndChannels.worked}\n${s.marketingAndChannels.notWorked}',
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(worked: answer),
      ),
    ),
    _q(
      'reachProblems',
      'marketingAndChannels',
      IntakeChatQuestionType.longText,
      (l) => l.intakeChatQReachProblems,
      (s) => s.marketingAndChannels.reachProblems,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          reachProblems: answer.trim(),
        ),
      ),
    ),
    _q(
      'companyGoals',
      'goalsAndRisks',
      IntakeChatQuestionType.longText,
      (l) => l.intakeChatQCompanyGoals,
      (s) => s.goalsAndRisks.companyGoals,
      (state, answer) => state.updateIntakeGoalsAndRisks(
        state.intakeSession!.goalsAndRisks.copyWith(
          companyGoals: answer.trim(),
        ),
      ),
    ),
    _q(
      'shortTermPriorities',
      'goalsAndRisks',
      IntakeChatQuestionType.longText,
      (l) => l.intakeChatQShortTermPriorities,
      (s) => s.goalsAndRisks.shortTermPriorities,
      (state, answer) => state.updateIntakeGoalsAndRisks(
        state.intakeSession!.goalsAndRisks.copyWith(
          shortTermPriorities: answer.trim(),
        ),
      ),
    ),
    _q(
      'forbiddenClaims',
      'goalsAndRisks',
      IntakeChatQuestionType.multiLineList,
      (l) => l.intakeChatQForbiddenClaims,
      (s) => s.goalsAndRisks.forbiddenClaims,
      (state, answer) => state.updateIntakeGoalsAndRisks(
        state.intakeSession!.goalsAndRisks.copyWith(
          forbiddenClaims: _mergeListText(
            state.intakeSession!.goalsAndRisks.forbiddenClaims,
            answer,
          ),
        ),
      ),
    ),
    _q(
      'botRestrictedTopics',
      'goalsAndRisks',
      IntakeChatQuestionType.multiLineList,
      (l) => l.intakeChatQBotRestrictedTopics,
      (s) => s.goalsAndRisks.botRestrictedTopics,
      (state, answer) => state.updateIntakeGoalsAndRisks(
        state.intakeSession!.goalsAndRisks.copyWith(
          botRestrictedTopics: _mergeListText(
            state.intakeSession!.goalsAndRisks.botRestrictedTopics,
            answer,
          ),
        ),
      ),
    ),
  ];

  static IntakeChatQuestion? nextQuestion(IntakeSession session) {
    for (var i = session.chatCurrentQuestionIndex; i < questions.length; i++) {
      final question = questions[i];
      if (_isOpen(question, session)) return question;
    }
    for (var i = 0; i < session.chatCurrentQuestionIndex; i++) {
      final question = questions[i];
      if (_isOpen(question, session)) return question;
    }
    return null;
  }

  static int nextQuestionIndexAfter(IntakeSession session, String questionKey) {
    final currentIndex = questions.indexWhere(
      (q) => q.questionKey == questionKey,
    );
    final start = currentIndex < 0
        ? session.chatCurrentQuestionIndex
        : currentIndex + 1;
    for (var i = start; i < questions.length; i++) {
      if (_isOpen(questions[i], session)) return i;
    }
    for (var i = 0; i < start && i < questions.length; i++) {
      if (_isOpen(questions[i], session)) return i;
    }
    return questions.length;
  }

  static void saveAnswer(
    AppState state,
    IntakeChatQuestion question,
    String answer,
  ) {
    question.saveAnswer(state, answer);
    final session = state.intakeSession!;
    final nextIndex = nextQuestionIndexAfter(session, question.questionKey);
    state.setIntakeChatQuestionIndex(nextIndex);
    if (nextQuestion(state.intakeSession!) == null) {
      state.markIntakeChatCompleted();
    }
  }

  static String blockLabel(AppLocalizations l, String blockKey) {
    return switch (blockKey) {
      'basics' => l.intakeStepBasicsTitle,
      'products' => l.intakeStepProductsTitle,
      'targetGroups' => l.intakeStepTargetGroupsTitle,
      'websiteAndSupport' => l.intakeStepWebsiteSupportTitle,
      'sourcesAndReviews' => l.intakeStepSourcesReviewsTitle,
      'marketingAndChannels' => l.intakeStepMarketingTitle,
      'goalsAndRisks' => l.intakeStepGoalsRisksTitle,
      _ => l.intakeTitle,
    };
  }

  static bool _isOpen(IntakeChatQuestion question, IntakeSession session) {
    return question.shouldAsk(session) &&
        !session.skippedQuestionKeys.contains(question.questionKey) &&
        !question.isAnswered(session);
  }
}

IntakeChatQuestion _q(
  String questionKey,
  String blockKey,
  IntakeChatQuestionType type,
  String Function(AppLocalizations l) text,
  String Function(IntakeSession session) value,
  void Function(AppState state, String answer) saveAnswer, {
  bool Function(IntakeSession session)? shouldAsk,
}) {
  return IntakeChatQuestion(
    questionKey: questionKey,
    blockKey: blockKey,
    type: type,
    text: text,
    shouldAsk: shouldAsk ?? (_) => true,
    isAnswered: (session) => value(session).trim().isNotEmpty,
    saveAnswer: saveAnswer,
  );
}

IntakeChatQuestion _yesNo(
  String questionKey,
  String blockKey,
  String Function(AppLocalizations l) text,
  bool? Function(IntakeSession session) value,
  void Function(AppState state, bool answer) saveAnswer,
) {
  return IntakeChatQuestion(
    questionKey: questionKey,
    blockKey: blockKey,
    type: IntakeChatQuestionType.yesNo,
    text: text,
    shouldAsk: (_) => true,
    isAnswered: (session) => value(session) != null,
    saveAnswer: (state, answer) => saveAnswer(state, _parseYes(answer)),
  );
}

bool _parseYes(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized == 'yes' ||
      normalized == 'ja' ||
      normalized == 'j' ||
      normalized == 'y' ||
      normalized == 'true';
}

String _mergeListText(String current, String addition) {
  final existing = _splitLines(current);
  final next = _splitLines(addition);
  final merged = [...existing];
  for (final item in next) {
    if (!merged.any((existingItem) => _same(existingItem, item))) {
      merged.add(item);
    }
  }
  return merged.join('\n');
}

List<String> _splitLines(String value) {
  return value
      .split(RegExp(r'[\n;,]+'))
      .map((item) => item.replaceFirst(RegExp(r'^[-•]\s*'), '').trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

bool _same(String a, String b) {
  String normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  return normalize(a) == normalize(b);
}
