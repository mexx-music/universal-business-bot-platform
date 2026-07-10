import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/intake_session.dart';

enum IntakeChatQuestionType {
  singleChoice,
  multiChoice,
  shortText,
  longText,
  yesNo,
  multiLineList,
  url,
  email,
  approximateNumber,
  choiceWithOther,
  multiChoiceWithOther,
  ratingChoice,
}

class IntakeChatQuestion {
  final String questionKey;
  final String blockKey;
  final IntakeChatQuestionType type;
  final String targetField;
  final String? dependsOnQuestionKey;
  final bool? dependsOnAnswer;
  final bool required;
  final bool skippable;
  final bool appendMode;
  final String? followUpGroup;
  final String? parentQuestionKey;
  final String Function(AppLocalizations l) text;
  final String Function(AppLocalizations l)? helpText;
  final String Function(AppLocalizations l)? inputHint;
  final String Function(IntakeSession session)? defaultValue;
  final List<String> Function(IntakeSession session, AppLocalizations l)?
  choiceOptions;
  final bool allowMultiple;
  final bool allowOther;
  final String Function(AppLocalizations l)? otherLabel;
  final int? minSelections;
  final int? maxSelections;
  final String Function(IntakeSession session) value;
  final bool? Function(IntakeSession session)? boolValue;
  final bool Function(String answer)? validation;
  final String Function(AppLocalizations l)? warningText;
  final void Function(AppState state, String answer) saveAnswer;

  const IntakeChatQuestion({
    required this.questionKey,
    required this.blockKey,
    required this.type,
    required this.targetField,
    required this.text,
    required this.value,
    required this.saveAnswer,
    this.dependsOnQuestionKey,
    this.dependsOnAnswer,
    this.required = false,
    this.skippable = true,
    this.appendMode = false,
    this.followUpGroup,
    this.parentQuestionKey,
    this.helpText,
    this.inputHint,
    this.defaultValue,
    this.choiceOptions,
    this.allowMultiple = false,
    this.allowOther = false,
    this.otherLabel,
    this.minSelections,
    this.maxSelections,
    this.boolValue,
    this.validation,
    this.warningText,
  });

  bool get isListQuestion => type == IntakeChatQuestionType.multiLineList;

  bool get isChoiceQuestion =>
      type == IntakeChatQuestionType.singleChoice ||
      type == IntakeChatQuestionType.multiChoice ||
      type == IntakeChatQuestionType.choiceWithOther ||
      type == IntakeChatQuestionType.multiChoiceWithOther ||
      type == IntakeChatQuestionType.ratingChoice;

  bool get opensAnswerDialog =>
      type != IntakeChatQuestionType.yesNo && !isChoiceQuestion;

  bool isAnswered(IntakeSession session) {
    if (type == IntakeChatQuestionType.yesNo) {
      return boolValue?.call(session) != null;
    }
    final currentValue = value(session).trim();
    if (currentValue.isEmpty) return false;
    if (type == IntakeChatQuestionType.url) {
      return _looksLikeUrl(currentValue);
    }
    return true;
  }
}

class IntakeChatFlow {
  static final List<IntakeChatQuestion> questions = [
    _q(
      'companyName',
      'basics',
      IntakeChatQuestionType.shortText,
      'basics.companyName',
      (l) => l.intakeChatQCompanyName,
      (s) => s.basics.companyName,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(companyName: answer.trim()),
      ),
      required: true,
      skippable: false,
    ),
    _q(
      'shortDescription',
      'basics',
      IntakeChatQuestionType.longText,
      'basics.shortDescription',
      (l) => l.intakeChatQShortDescription,
      (s) => s.basics.shortDescription,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(shortDescription: answer.trim()),
      ),
      required: true,
      skippable: false,
    ),
    _q(
      'industry',
      'basics',
      IntakeChatQuestionType.shortText,
      'basics.industry',
      (l) => l.intakeChatQIndustry,
      (s) => s.basics.industry,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(industry: answer.trim()),
      ),
    ),
    _choice(
      'country',
      'basics',
      IntakeChatQuestionType.choiceWithOther,
      'basics.country',
      (l) => l.intakeChatQCountry,
      (s) => s.basics.country,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(country: answer.trim()),
      ),
      choiceOptions: (_, l) => _splitOptions(l.intakeChoiceRegionOptions),
      allowOther: true,
    ),
    _choice(
      'primaryLanguage',
      'basics',
      IntakeChatQuestionType.choiceWithOther,
      'basics.primaryLanguage',
      (l) => l.intakeChatQPrimaryLanguage,
      (s) => s.basics.primaryLanguage,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(primaryLanguage: answer.trim()),
      ),
      choiceOptions: (_, l) => _splitOptions(l.intakeChoiceLanguageOptions),
      allowOther: true,
    ),
    _choice(
      'additionalLanguages',
      'basics',
      IntakeChatQuestionType.multiChoiceWithOther,
      'basics.additionalLanguages',
      (l) => l.intakeChatQAdditionalLanguages,
      (s) => s.basics.additionalLanguages,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(additionalLanguages: answer),
      ),
      choiceOptions: (_, l) => _splitOptions(l.intakeChoiceLanguageOptions),
      allowOther: true,
    ),
    _yesNo(
      'hasWebsite',
      'basics',
      'basics.hasWebsite',
      (l) => l.intakeChatQHasWebsite,
      (s) => s.basics.hasWebsite,
      (state, value) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(hasWebsite: value),
      ),
      required: true,
      skippable: false,
      followUpGroup: 'website',
    ),
    _q(
      'website',
      'websiteAndSupport',
      IntakeChatQuestionType.shortText,
      'websiteAndSupport.websiteUrl',
      (l) => l.intakeChatQWebsite,
      (s) => s.websiteAndSupport.websiteUrl,
      (state, answer) {
        final value = normalizeAnswerForQuestion(
          questionByKey('website'),
          answer,
        );
        state.updateIntakeBasics(
          state.intakeSession!.basics.copyWith(website: value),
        );
        state.updateIntakeWebsiteAndSupport(
          state.intakeSession!.websiteAndSupport.copyWith(websiteUrl: value),
        );
      },
      dependsOnQuestionKey: 'hasWebsite',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasWebsite',
      followUpGroup: 'website',
      typeOverride: IntakeChatQuestionType.url,
      defaultValue: (s) =>
          s.basics.website.trim().isEmpty ? 'https://' : s.basics.website,
      validation: _looksLikeUrl,
      warningText: (l) => l.intakeChatUrlWarning,
    ),
    _yesNo(
      'hasShop',
      'websiteAndSupport',
      'websiteAndSupport.hasShop',
      (l) => l.intakeChatQHasShop,
      (s) => s.websiteAndSupport.hasShop,
      (state, value) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(hasShop: value),
      ),
      dependsOnQuestionKey: 'hasWebsite',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasWebsite',
      followUpGroup: 'website',
    ),
    _q(
      'shopUrl',
      'websiteAndSupport',
      IntakeChatQuestionType.url,
      'websiteAndSupport.shopUrl',
      (l) => l.intakeChatQShopUrl,
      (s) => s.websiteAndSupport.shopUrl,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          shopUrl: normalizeAnswerForQuestion(questionByKey('shopUrl'), answer),
        ),
      ),
      dependsOnQuestionKey: 'hasShop',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasShop',
      followUpGroup: 'website',
      defaultValue: (_) => 'https://',
      validation: _looksLikeUrl,
      warningText: (l) => l.intakeChatUrlWarning,
    ),
    _q(
      'importantPages',
      'websiteAndSupport',
      IntakeChatQuestionType.multiLineList,
      'websiteAndSupport.importantPages',
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
      dependsOnQuestionKey: 'hasWebsite',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasWebsite',
      followUpGroup: 'website',
      appendMode: true,
    ),
    _yesNo(
      'hasFaqArea',
      'websiteAndSupport',
      'websiteAndSupport.hasFaqArea',
      (l) => l.intakeChatQHasFaqArea,
      (s) => s.websiteAndSupport.hasFaqArea,
      (state, value) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(hasFaqArea: value),
      ),
      dependsOnQuestionKey: 'hasWebsite',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasWebsite',
      followUpGroup: 'website',
    ),
    _q(
      'faqUrl',
      'websiteAndSupport',
      IntakeChatQuestionType.url,
      'websiteAndSupport.faqUrl',
      (l) => l.intakeChatQFaqUrl,
      (s) => s.websiteAndSupport.faqUrl,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          faqUrl: normalizeAnswerForQuestion(questionByKey('faqUrl'), answer),
        ),
      ),
      dependsOnQuestionKey: 'hasFaqArea',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasFaqArea',
      followUpGroup: 'website',
      defaultValue: (_) => 'https://',
      validation: _looksLikeUrl,
      warningText: (l) => l.intakeChatUrlWarning,
    ),
    _q(
      'websiteMaintainer',
      'websiteAndSupport',
      IntakeChatQuestionType.shortText,
      'websiteAndSupport.websiteMaintainer',
      (l) => l.intakeChatQWebsiteMaintainer,
      (s) => s.websiteAndSupport.websiteMaintainer,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          websiteMaintainer: answer.trim(),
        ),
      ),
      dependsOnQuestionKey: 'hasWebsite',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasWebsite',
      followUpGroup: 'website',
    ),
    _yesNo(
      'canEditWebsiteQuickly',
      'websiteAndSupport',
      'websiteAndSupport.canEditWebsiteQuickly',
      (l) => l.intakeChatQCanEditWebsiteQuickly,
      (s) => s.websiteAndSupport.canEditWebsiteQuickly,
      (state, value) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          canEditWebsiteQuickly: value,
        ),
      ),
      dependsOnQuestionKey: 'hasWebsite',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasWebsite',
      followUpGroup: 'website',
    ),
    _q(
      'websitePlanned',
      'websiteAndSupport',
      IntakeChatQuestionType.shortText,
      'websiteAndSupport.websitePlanned',
      (l) => l.intakeChatQWebsitePlanned,
      (s) => s.websiteAndSupport.websitePlanned,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          websitePlanned: answer.trim(),
        ),
      ),
      dependsOnQuestionKey: 'hasWebsite',
      dependsOnAnswer: false,
      parentQuestionKey: 'hasWebsite',
      followUpGroup: 'website',
    ),
    _q(
      'supportEmail',
      'basics',
      IntakeChatQuestionType.email,
      'basics.supportEmail',
      (l) => l.intakeChatQSupportEmail,
      (s) => s.basics.supportEmail,
      (state, answer) => state.updateIntakeBasics(
        state.intakeSession!.basics.copyWith(supportEmail: answer.trim()),
      ),
      validation: _looksLikeEmail,
      warningText: (l) => l.intakeChatEmailWarning,
    ),
    _q(
      'supportPhone',
      'basics',
      IntakeChatQuestionType.shortText,
      'basics.supportPhone',
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
      'products.importantProducts',
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
      appendMode: true,
    ),
    _q(
      'mainProduct',
      'products',
      IntakeChatQuestionType.shortText,
      'products.mainProduct',
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
      'products.priorityProducts',
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
      appendMode: true,
    ),
    _q(
      'explanationNeeded',
      'products',
      IntakeChatQuestionType.longText,
      'products.explanationNeeded',
      (l) => l.intakeChatQExplanationNeeded,
      (s) => s.products.explanationNeeded,
      (state, answer) => state.updateIntakeProducts(
        state.intakeSession!.products.copyWith(
          explanationNeeded: answer.trim(),
        ),
      ),
    ),
    _choice(
      'targetGroup',
      'targetGroups',
      IntakeChatQuestionType.multiChoiceWithOther,
      'targetGroups.targetGroup',
      (l) => l.intakeChatQTargetGroup,
      (s) => s.targetGroups.targetGroup,
      (state, answer) => state.updateIntakeTargetGroups(
        state.intakeSession!.targetGroups.copyWith(targetGroup: answer),
      ),
      choiceOptions: (_, l) => _splitOptions(l.intakeChoiceTargetGroupOptions),
      allowOther: true,
    ),
    _choice(
      'marketType',
      'targetGroups',
      IntakeChatQuestionType.singleChoice,
      'targetGroups.marketType',
      (l) => l.intakeChatQMarketType,
      (s) => s.targetGroups.marketType,
      (state, answer) => state.updateIntakeTargetGroups(
        state.intakeSession!.targetGroups.copyWith(marketType: answer.trim()),
      ),
      choiceOptions: (_, l) => _splitOptions(l.intakeChoiceMarketTypeOptions),
    ),
    _q(
      'problemSolved',
      'targetGroups',
      IntakeChatQuestionType.longText,
      'targetGroups.problemSolved',
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
      'targetGroups.customerBenefit',
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
      'targetGroups.differentiation',
      (l) => l.intakeChatQDifferentiation,
      (s) => s.targetGroups.differentiation,
      (state, answer) => state.updateIntakeTargetGroups(
        state.intakeSession!.targetGroups.copyWith(
          differentiation: answer.trim(),
        ),
      ),
    ),
    _yesNo(
      'hasSupportQuestions',
      'websiteAndSupport',
      'websiteAndSupport.hasSupportQuestions',
      (l) => l.intakeChatQHasSupportQuestions,
      (s) => s.websiteAndSupport.hasSupportQuestions,
      (state, value) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          hasSupportQuestions: value,
        ),
      ),
      followUpGroup: 'support',
    ),
    _choice(
      'supportChannels',
      'websiteAndSupport',
      IntakeChatQuestionType.multiChoiceWithOther,
      'websiteAndSupport.supportChannels',
      (l) => l.intakeChatQSupportChannels,
      (s) => s.websiteAndSupport.supportChannels,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          supportChannels: answer,
        ),
      ),
      choiceOptions: (_, l) =>
          _splitOptions(l.intakeChoiceSupportChannelOptions),
      dependsOnQuestionKey: 'hasSupportQuestions',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSupportQuestions',
      followUpGroup: 'support',
      allowOther: true,
    ),
    _q(
      'preSalesQuestions',
      'websiteAndSupport',
      IntakeChatQuestionType.multiLineList,
      'websiteAndSupport.preSalesQuestions',
      (l) => l.intakeChatQPreSalesQuestions,
      (s) => s.websiteAndSupport.preSalesQuestions,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          preSalesQuestions: _mergeListText(
            state.intakeSession!.websiteAndSupport.preSalesQuestions,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasSupportQuestions',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSupportQuestions',
      followUpGroup: 'support',
      appendMode: true,
    ),
    _q(
      'afterSalesQuestions',
      'websiteAndSupport',
      IntakeChatQuestionType.multiLineList,
      'websiteAndSupport.afterSalesQuestions',
      (l) => l.intakeChatQAfterSalesQuestions,
      (s) => s.websiteAndSupport.afterSalesQuestions,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          afterSalesQuestions: _mergeListText(
            state.intakeSession!.websiteAndSupport.afterSalesQuestions,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasSupportQuestions',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSupportQuestions',
      followUpGroup: 'support',
      appendMode: true,
    ),
    _q(
      'technicalProblems',
      'websiteAndSupport',
      IntakeChatQuestionType.multiLineList,
      'websiteAndSupport.technicalProblems',
      (l) => l.intakeChatQTechnicalProblems,
      (s) => s.websiteAndSupport.technicalProblems,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          technicalProblems: _mergeListText(
            state.intakeSession!.websiteAndSupport.technicalProblems,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasSupportQuestions',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSupportQuestions',
      followUpGroup: 'support',
      appendMode: true,
    ),
    _q(
      'supportProblems',
      'websiteAndSupport',
      IntakeChatQuestionType.multiLineList,
      'websiteAndSupport.supportProblems',
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
      dependsOnQuestionKey: 'hasSupportQuestions',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSupportQuestions',
      followUpGroup: 'support',
      appendMode: true,
    ),
    _q(
      'complaintsOrMisunderstandings',
      'websiteAndSupport',
      IntakeChatQuestionType.multiLineList,
      'websiteAndSupport.complaintsOrMisunderstandings',
      (l) => l.intakeChatQComplaintsOrMisunderstandings,
      (s) => s.websiteAndSupport.complaintsOrMisunderstandings,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          complaintsOrMisunderstandings: _mergeListText(
            state
                .intakeSession!
                .websiteAndSupport
                .complaintsOrMisunderstandings,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasSupportQuestions',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSupportQuestions',
      followUpGroup: 'support',
      appendMode: true,
    ),
    _q(
      'supportOwner',
      'websiteAndSupport',
      IntakeChatQuestionType.shortText,
      'websiteAndSupport.supportOwner',
      (l) => l.intakeChatQSupportOwner,
      (s) => s.websiteAndSupport.supportOwner,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          supportOwner: answer.trim(),
        ),
      ),
      dependsOnQuestionKey: 'hasSupportQuestions',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSupportQuestions',
      followUpGroup: 'support',
    ),
    _q(
      'standardizableQuestions',
      'websiteAndSupport',
      IntakeChatQuestionType.multiLineList,
      'websiteAndSupport.standardizableQuestions',
      (l) => l.intakeChatQStandardizableQuestions,
      (s) => s.websiteAndSupport.standardizableQuestions,
      (state, answer) => state.updateIntakeWebsiteAndSupport(
        state.intakeSession!.websiteAndSupport.copyWith(
          standardizableQuestions: _mergeListText(
            state.intakeSession!.websiteAndSupport.standardizableQuestions,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasSupportQuestions',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSupportQuestions',
      followUpGroup: 'support',
      appendMode: true,
    ),
    _q(
      'frequentQuestions',
      'websiteAndSupport',
      IntakeChatQuestionType.multiLineList,
      'websiteAndSupport.frequentQuestions',
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
      appendMode: true,
    ),
    _yesNo(
      'hasSensitiveTopics',
      'goalsAndRisks',
      'goalsAndRisks.hasSensitiveTopics',
      (l) => l.intakeChatQHasSensitiveTopics,
      (s) =>
          s.goalsAndRisks.hasSensitiveTopics ??
          s.websiteAndSupport.hasSensitiveTopics,
      (state, value) {
        state.updateIntakeGoalsAndRisks(
          state.intakeSession!.goalsAndRisks.copyWith(
            hasSensitiveTopics: value,
          ),
        );
        state.updateIntakeWebsiteAndSupport(
          state.intakeSession!.websiteAndSupport.copyWith(
            hasSensitiveTopics: value,
          ),
        );
      },
      followUpGroup: 'sensitive',
    ),
    _choice(
      'sensitiveTopics',
      'goalsAndRisks',
      IntakeChatQuestionType.multiChoiceWithOther,
      'goalsAndRisks.sensitiveTopics',
      (l) => l.intakeChatQSensitiveTopics,
      (s) => s.goalsAndRisks.sensitiveTopics,
      (state, answer) {
        final merged = _mergeListText(
          state.intakeSession!.goalsAndRisks.sensitiveTopics,
          answer,
        );
        state.updateIntakeGoalsAndRisks(
          state.intakeSession!.goalsAndRisks.copyWith(sensitiveTopics: merged),
        );
        state.updateIntakeWebsiteAndSupport(
          state.intakeSession!.websiteAndSupport.copyWith(
            sensitiveTopics: _mergeListText(
              state.intakeSession!.websiteAndSupport.sensitiveTopics,
              answer,
            ),
          ),
        );
      },
      choiceOptions: (_, l) =>
          _splitOptions(l.intakeChoiceSensitiveCategoryOptions),
      dependsOnQuestionKey: 'hasSensitiveTopics',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSensitiveTopics',
      followUpGroup: 'sensitive',
      allowOther: true,
    ),
    _q(
      'prohibitedStatements',
      'goalsAndRisks',
      IntakeChatQuestionType.multiLineList,
      'goalsAndRisks.prohibitedStatements',
      (l) => l.intakeChatQProhibitedStatements,
      (s) => s.goalsAndRisks.prohibitedStatements,
      (state, answer) => state.updateIntakeGoalsAndRisks(
        state.intakeSession!.goalsAndRisks.copyWith(
          prohibitedStatements: _mergeListText(
            state.intakeSession!.goalsAndRisks.prohibitedStatements,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasSensitiveTopics',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSensitiveTopics',
      followUpGroup: 'sensitive',
      appendMode: true,
    ),
    _q(
      'botRestrictedTopics',
      'goalsAndRisks',
      IntakeChatQuestionType.multiLineList,
      'goalsAndRisks.botRestrictedTopics',
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
      dependsOnQuestionKey: 'hasSensitiveTopics',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSensitiveTopics',
      followUpGroup: 'sensitive',
      appendMode: true,
    ),
    _q(
      'alwaysEscalateTopics',
      'goalsAndRisks',
      IntakeChatQuestionType.multiLineList,
      'goalsAndRisks.alwaysEscalateTopics',
      (l) => l.intakeChatQAlwaysEscalateTopics,
      (s) => s.goalsAndRisks.alwaysEscalateTopics,
      (state, answer) => state.updateIntakeGoalsAndRisks(
        state.intakeSession!.goalsAndRisks.copyWith(
          alwaysEscalateTopics: _mergeListText(
            state.intakeSession!.goalsAndRisks.alwaysEscalateTopics,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasSensitiveTopics',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSensitiveTopics',
      followUpGroup: 'sensitive',
      appendMode: true,
    ),
    _q(
      'legalRestrictions',
      'goalsAndRisks',
      IntakeChatQuestionType.multiLineList,
      'goalsAndRisks.legalRestrictions',
      (l) => l.intakeChatQLegalRestrictions,
      (s) => s.goalsAndRisks.legalRestrictions,
      (state, answer) => state.updateIntakeGoalsAndRisks(
        state.intakeSession!.goalsAndRisks.copyWith(
          legalRestrictions: _mergeListText(
            state.intakeSession!.goalsAndRisks.legalRestrictions,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasSensitiveTopics',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSensitiveTopics',
      followUpGroup: 'sensitive',
      appendMode: true,
    ),
    _yesNo(
      'hasMaterials',
      'sourcesAndReviews',
      'sourcesAndReviews.hasMaterials',
      (l) => l.intakeChatQHasMaterials,
      (s) => s.sourcesAndReviews.hasMaterials,
      (state, value) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(hasMaterials: value),
      ),
      followUpGroup: 'materials',
    ),
    _choice(
      'materialDetails',
      'sourcesAndReviews',
      IntakeChatQuestionType.multiChoiceWithOther,
      'sourcesAndReviews.materialDetails',
      (l) => l.intakeChatQMaterialDetails,
      (s) => s.sourcesAndReviews.materialDetails,
      (state, answer) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          materialDetails: _mergeListText(
            state.intakeSession!.sourcesAndReviews.materialDetails,
            answer,
          ),
          existingSources: _mergeListText(
            state.intakeSession!.sourcesAndReviews.existingSources,
            answer,
          ),
        ),
      ),
      choiceOptions: (_, l) => _splitOptions(l.intakeChoiceMaterialOptions),
      dependsOnQuestionKey: 'hasMaterials',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasMaterials',
      followUpGroup: 'materials',
      allowOther: true,
    ),
    _q(
      'materialLocations',
      'sourcesAndReviews',
      IntakeChatQuestionType.multiLineList,
      'sourcesAndReviews.materialLocations',
      (l) => l.intakeChatQMaterialLocations,
      (s) => s.sourcesAndReviews.materialLocations,
      (state, answer) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          materialLocations: _mergeListText(
            state.intakeSession!.sourcesAndReviews.materialLocations,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasMaterials',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasMaterials',
      followUpGroup: 'materials',
      appendMode: true,
    ),
    _q(
      'materialFreshness',
      'sourcesAndReviews',
      IntakeChatQuestionType.shortText,
      'sourcesAndReviews.materialFreshness',
      (l) => l.intakeChatQMaterialFreshness,
      (s) => s.sourcesAndReviews.materialFreshness,
      (state, answer) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          materialFreshness: answer.trim(),
        ),
      ),
      dependsOnQuestionKey: 'hasMaterials',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasMaterials',
      followUpGroup: 'materials',
    ),
    _q(
      'importantMaterials',
      'sourcesAndReviews',
      IntakeChatQuestionType.multiLineList,
      'sourcesAndReviews.importantMaterials',
      (l) => l.intakeChatQImportantMaterials,
      (s) => s.sourcesAndReviews.importantMaterials,
      (state, answer) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          importantMaterials: _mergeListText(
            state.intakeSession!.sourcesAndReviews.importantMaterials,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasMaterials',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasMaterials',
      followUpGroup: 'materials',
      appendMode: true,
    ),
    _yesNo(
      'materialsUsableForKnowledgeBase',
      'sourcesAndReviews',
      'sourcesAndReviews.materialsUsableForKnowledgeBase',
      (l) => l.intakeChatQMaterialsUsableForKnowledgeBase,
      (s) => s.sourcesAndReviews.materialsUsableForKnowledgeBase,
      (state, value) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          materialsUsableForKnowledgeBase: value,
        ),
      ),
      dependsOnQuestionKey: 'hasMaterials',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasMaterials',
      followUpGroup: 'materials',
    ),
    _yesNo(
      'hasReviews',
      'sourcesAndReviews',
      'sourcesAndReviews.hasReviews',
      (l) => l.intakeChatQHasReviews,
      (s) => s.sourcesAndReviews.hasReviews,
      (state, value) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(hasReviews: value),
      ),
      followUpGroup: 'reviews',
    ),
    _choice(
      'reviewPlatforms',
      'sourcesAndReviews',
      IntakeChatQuestionType.multiChoiceWithOther,
      'sourcesAndReviews.reviewPlatforms',
      (l) => l.intakeChatQReviewPlatforms,
      (s) => s.sourcesAndReviews.reviewPlatforms,
      (state, answer) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          reviewPlatforms: _mergeListText(
            state.intakeSession!.sourcesAndReviews.reviewPlatforms,
            answer,
          ),
        ),
      ),
      choiceOptions: (_, l) =>
          _splitOptions(l.intakeChoiceReviewPlatformOptions),
      dependsOnQuestionKey: 'hasReviews',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasReviews',
      followUpGroup: 'reviews',
      allowOther: true,
    ),
    _q(
      'reviewCountEstimate',
      'sourcesAndReviews',
      IntakeChatQuestionType.approximateNumber,
      'sourcesAndReviews.reviewCountEstimate',
      (l) => l.intakeChatQReviewCountEstimate,
      (s) => s.sourcesAndReviews.reviewCountEstimate,
      (state, answer) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          reviewCountEstimate: answer.trim(),
        ),
      ),
      dependsOnQuestionKey: 'hasReviews',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasReviews',
      followUpGroup: 'reviews',
    ),
    _q(
      'reviewLinksOrFiles',
      'sourcesAndReviews',
      IntakeChatQuestionType.multiLineList,
      'sourcesAndReviews.reviewLinksOrFiles',
      (l) => l.intakeChatQReviewLinksOrFiles,
      (s) => s.sourcesAndReviews.reviewLinksOrFiles,
      (state, answer) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          reviewLinksOrFiles: _mergeListText(
            state.intakeSession!.sourcesAndReviews.reviewLinksOrFiles,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasReviews',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasReviews',
      followUpGroup: 'reviews',
      appendMode: true,
    ),
    _q(
      'reviewTypes',
      'sourcesAndReviews',
      IntakeChatQuestionType.multiLineList,
      'sourcesAndReviews.reviewTypes',
      (l) => l.intakeChatQReviewTypes,
      (s) => s.sourcesAndReviews.reviewTypes,
      (state, answer) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          reviewTypes: _mergeListText(
            state.intakeSession!.sourcesAndReviews.reviewTypes,
            answer,
          ),
          reviews: _mergeListText(
            state.intakeSession!.sourcesAndReviews.reviews,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasReviews',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasReviews',
      followUpGroup: 'reviews',
      appendMode: true,
    ),
    _yesNo(
      'reviewsPubliclyUsable',
      'sourcesAndReviews',
      'sourcesAndReviews.reviewsPubliclyUsable',
      (l) => l.intakeChatQReviewsPubliclyUsable,
      (s) => s.sourcesAndReviews.reviewsPubliclyUsable,
      (state, value) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          reviewsPubliclyUsable: value,
        ),
      ),
      dependsOnQuestionKey: 'hasReviews',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasReviews',
      followUpGroup: 'reviews',
    ),
    _yesNo(
      'reviewsEmbeddedOnWebsite',
      'sourcesAndReviews',
      'sourcesAndReviews.reviewsEmbeddedOnWebsite',
      (l) => l.intakeChatQReviewsEmbeddedOnWebsite,
      (s) => s.sourcesAndReviews.reviewsEmbeddedOnWebsite,
      (state, value) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          reviewsEmbeddedOnWebsite: value,
        ),
      ),
      dependsOnQuestionKey: 'hasReviews',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasReviews',
      followUpGroup: 'reviews',
    ),
    _q(
      'collectReviewsPlanned',
      'sourcesAndReviews',
      IntakeChatQuestionType.shortText,
      'sourcesAndReviews.collectReviewsPlanned',
      (l) => l.intakeChatQCollectReviewsPlanned,
      (s) => s.sourcesAndReviews.collectReviewsPlanned,
      (state, answer) => state.updateIntakeSourcesAndReviews(
        state.intakeSession!.sourcesAndReviews.copyWith(
          collectReviewsPlanned: answer.trim(),
        ),
      ),
      dependsOnQuestionKey: 'hasReviews',
      dependsOnAnswer: false,
      parentQuestionKey: 'hasReviews',
      followUpGroup: 'reviews',
    ),
    _yesNo(
      'hasSocialChannels',
      'marketingAndChannels',
      'marketingAndChannels.hasSocialChannels',
      (l) => l.intakeChatQHasSocialChannels,
      (s) => s.marketingAndChannels.hasSocialChannels,
      (state, value) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          hasSocialChannels: value,
        ),
      ),
      followUpGroup: 'social',
    ),
    _choice(
      'socialPlatforms',
      'marketingAndChannels',
      IntakeChatQuestionType.multiChoiceWithOther,
      'marketingAndChannels.socialPlatforms',
      (l) => l.intakeChatQSocialPlatforms,
      (s) => s.marketingAndChannels.socialPlatforms,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          socialPlatforms: _mergeListText(
            state.intakeSession!.marketingAndChannels.socialPlatforms,
            answer,
          ),
          channels: _mergeListText(
            state.intakeSession!.marketingAndChannels.channels,
            answer,
          ),
        ),
      ),
      choiceOptions: (_, l) =>
          _splitOptions(l.intakeChoiceSocialPlatformOptions),
      dependsOnQuestionKey: 'hasSocialChannels',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSocialChannels',
      followUpGroup: 'social',
      allowOther: true,
    ),
    _q(
      'socialProfileLinks',
      'marketingAndChannels',
      IntakeChatQuestionType.multiLineList,
      'marketingAndChannels.socialProfileLinks',
      (l) => l.intakeChatQSocialProfileLinks,
      (s) => s.marketingAndChannels.socialProfileLinks,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          socialProfileLinks: _mergeListText(
            state.intakeSession!.marketingAndChannels.socialProfileLinks,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasSocialChannels',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSocialChannels',
      followUpGroup: 'social',
      appendMode: true,
    ),
    _choice(
      'activeChannels',
      'marketingAndChannels',
      IntakeChatQuestionType.multiChoice,
      'marketingAndChannels.activeChannels',
      (l) => l.intakeChatQActiveChannels,
      (s) => s.marketingAndChannels.activeChannels,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          activeChannels: _mergeListText(
            state.intakeSession!.marketingAndChannels.activeChannels,
            answer,
          ),
        ),
      ),
      choiceOptions: (s, _) => _splitLines(
        s.marketingAndChannels.socialPlatforms,
      ).where((item) => !_isNone(item)).toList(),
      dependsOnQuestionKey: 'hasSocialChannels',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSocialChannels',
      followUpGroup: 'social',
    ),
    _q(
      'postingFrequency',
      'marketingAndChannels',
      IntakeChatQuestionType.shortText,
      'marketingAndChannels.postingFrequency',
      (l) => l.intakeChatQPostingFrequency,
      (s) => s.marketingAndChannels.postingFrequency,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          postingFrequency: answer.trim(),
        ),
      ),
      dependsOnQuestionKey: 'hasSocialChannels',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSocialChannels',
      followUpGroup: 'social',
    ),
    _choice(
      'workingChannels',
      'marketingAndChannels',
      IntakeChatQuestionType.multiChoice,
      'marketingAndChannels.workingChannels',
      (l) => l.intakeChatQWorkingChannels,
      (s) => s.marketingAndChannels.workingChannels,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          workingChannels: _mergeListText(
            state.intakeSession!.marketingAndChannels.workingChannels,
            answer,
          ),
        ),
      ),
      choiceOptions: (s, _) => _splitLines(
        s.marketingAndChannels.socialPlatforms,
      ).where((item) => !_isNone(item)).toList(),
      dependsOnQuestionKey: 'hasSocialChannels',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSocialChannels',
      followUpGroup: 'social',
    ),
    _choice(
      'inactiveChannels',
      'marketingAndChannels',
      IntakeChatQuestionType.multiChoice,
      'marketingAndChannels.inactiveChannels',
      (l) => l.intakeChatQInactiveChannels,
      (s) => s.marketingAndChannels.inactiveChannels,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          inactiveChannels: _mergeListText(
            state.intakeSession!.marketingAndChannels.inactiveChannels,
            answer,
          ),
        ),
      ),
      choiceOptions: (s, _) => _splitLines(
        s.marketingAndChannels.socialPlatforms,
      ).where((item) => !_isNone(item)).toList(),
      dependsOnQuestionKey: 'hasSocialChannels',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSocialChannels',
      followUpGroup: 'social',
    ),
    _q(
      'socialMentions',
      'sourcesAndReviews',
      IntakeChatQuestionType.multiLineList,
      'sourcesAndReviews.socialMentions',
      (l) => l.intakeChatQSocialMentions,
      (s) => s.sourcesAndReviews.socialMentions,
      (state, answer) {
        state.updateIntakeSourcesAndReviews(
          state.intakeSession!.sourcesAndReviews.copyWith(
            hasSocialMentions: true,
            socialMentions: _mergeListText(
              state.intakeSession!.sourcesAndReviews.socialMentions,
              answer,
            ),
          ),
        );
      },
      dependsOnQuestionKey: 'hasSocialChannels',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasSocialChannels',
      followUpGroup: 'social',
      appendMode: true,
    ),
    _q(
      'futureSocialPlatforms',
      'marketingAndChannels',
      IntakeChatQuestionType.shortText,
      'marketingAndChannels.futureSocialPlatforms',
      (l) => l.intakeChatQFutureSocialPlatforms,
      (s) => s.marketingAndChannels.futureSocialPlatforms,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          futureSocialPlatforms: answer.trim(),
        ),
      ),
      dependsOnQuestionKey: 'hasSocialChannels',
      dependsOnAnswer: false,
      parentQuestionKey: 'hasSocialChannels',
      followUpGroup: 'social',
    ),
    _yesNo(
      'hasRunAds',
      'marketingAndChannels',
      'marketingAndChannels.hasRunAds',
      (l) => l.intakeChatQHasRunAds,
      (s) => s.marketingAndChannels.hasRunAds,
      (state, value) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(hasRunAds: value),
      ),
      followUpGroup: 'ads',
    ),
    _choice(
      'advertisingChannels',
      'marketingAndChannels',
      IntakeChatQuestionType.multiChoiceWithOther,
      'marketingAndChannels.advertisingChannels',
      (l) => l.intakeChatQAdvertisingChannels,
      (s) => s.marketingAndChannels.advertisingChannels,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          advertisingChannels: _mergeListText(
            state.intakeSession!.marketingAndChannels.advertisingChannels,
            answer,
          ),
          channels: _mergeListText(
            state.intakeSession!.marketingAndChannels.channels,
            answer,
          ),
        ),
      ),
      choiceOptions: (_, l) =>
          _splitOptions(l.intakeChoiceAdvertisingChannelOptions),
      dependsOnQuestionKey: 'hasRunAds',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasRunAds',
      followUpGroup: 'ads',
      allowOther: true,
    ),
    _q(
      'campaigns',
      'marketingAndChannels',
      IntakeChatQuestionType.longText,
      'marketingAndChannels.campaigns',
      (l) => l.intakeChatQCampaigns,
      (s) => s.marketingAndChannels.campaigns,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(campaigns: answer),
      ),
      dependsOnQuestionKey: 'hasRunAds',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasRunAds',
      followUpGroup: 'ads',
    ),
    _q(
      'approximateBudget',
      'marketingAndChannels',
      IntakeChatQuestionType.approximateNumber,
      'marketingAndChannels.approximateBudget',
      (l) => l.intakeChatQApproximateBudget,
      (s) => s.marketingAndChannels.approximateBudget,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          approximateBudget: answer.trim(),
        ),
      ),
      dependsOnQuestionKey: 'hasRunAds',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasRunAds',
      followUpGroup: 'ads',
    ),
    _q(
      'successfulMeasures',
      'marketingAndChannels',
      IntakeChatQuestionType.multiLineList,
      'marketingAndChannels.successfulMeasures',
      (l) => l.intakeChatQSuccessfulMeasures,
      (s) => s.marketingAndChannels.successfulMeasures,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          successfulMeasures: _mergeListText(
            state.intakeSession!.marketingAndChannels.successfulMeasures,
            answer,
          ),
          worked: _mergeListText(
            state.intakeSession!.marketingAndChannels.worked,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasRunAds',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasRunAds',
      followUpGroup: 'ads',
      appendMode: true,
    ),
    _q(
      'unsuccessfulMeasures',
      'marketingAndChannels',
      IntakeChatQuestionType.multiLineList,
      'marketingAndChannels.unsuccessfulMeasures',
      (l) => l.intakeChatQUnsuccessfulMeasures,
      (s) => s.marketingAndChannels.unsuccessfulMeasures,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          unsuccessfulMeasures: _mergeListText(
            state.intakeSession!.marketingAndChannels.unsuccessfulMeasures,
            answer,
          ),
          notWorked: _mergeListText(
            state.intakeSession!.marketingAndChannels.notWorked,
            answer,
          ),
        ),
      ),
      dependsOnQuestionKey: 'hasRunAds',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasRunAds',
      followUpGroup: 'ads',
      appendMode: true,
    ),
    _q(
      'availableMetrics',
      'marketingAndChannels',
      IntakeChatQuestionType.longText,
      'marketingAndChannels.availableMetrics',
      (l) => l.intakeChatQAvailableMetrics,
      (s) => s.marketingAndChannels.availableMetrics,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          availableMetrics: answer.trim(),
        ),
      ),
      dependsOnQuestionKey: 'hasRunAds',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasRunAds',
      followUpGroup: 'ads',
    ),
    _q(
      'adAccountAccess',
      'marketingAndChannels',
      IntakeChatQuestionType.shortText,
      'marketingAndChannels.adAccountAccess',
      (l) => l.intakeChatQAdAccountAccess,
      (s) => s.marketingAndChannels.adAccountAccess,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          adAccountAccess: answer.trim(),
        ),
      ),
      dependsOnQuestionKey: 'hasRunAds',
      dependsOnAnswer: true,
      parentQuestionKey: 'hasRunAds',
      followUpGroup: 'ads',
    ),
    _q(
      'futureAdChannels',
      'marketingAndChannels',
      IntakeChatQuestionType.shortText,
      'marketingAndChannels.futureAdChannels',
      (l) => l.intakeChatQFutureAdChannels,
      (s) => s.marketingAndChannels.futureAdChannels,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          futureAdChannels: answer.trim(),
        ),
      ),
      dependsOnQuestionKey: 'hasRunAds',
      dependsOnAnswer: false,
      parentQuestionKey: 'hasRunAds',
      followUpGroup: 'ads',
    ),
    _choice(
      'reachProblems',
      'marketingAndChannels',
      IntakeChatQuestionType.multiChoiceWithOther,
      'marketingAndChannels.reachProblems',
      (l) => l.intakeChatQReachProblems,
      (s) => s.marketingAndChannels.reachProblems,
      (state, answer) => state.updateIntakeMarketingAndChannels(
        state.intakeSession!.marketingAndChannels.copyWith(
          reachProblems: answer,
        ),
      ),
      choiceOptions: (_, l) => _splitOptions(l.intakeChoiceReachProblemOptions),
      allowOther: true,
    ),
    _choice(
      'companyGoals',
      'goalsAndRisks',
      IntakeChatQuestionType.multiChoiceWithOther,
      'goalsAndRisks.companyGoals',
      (l) => l.intakeChatQCompanyGoals,
      (s) => s.goalsAndRisks.companyGoals,
      (state, answer) => state.updateIntakeGoalsAndRisks(
        state.intakeSession!.goalsAndRisks.copyWith(companyGoals: answer),
      ),
      choiceOptions: (_, l) => _splitOptions(l.intakeChoiceGoalOptions),
      allowOther: true,
    ),
    _q(
      'shortTermPriorities',
      'goalsAndRisks',
      IntakeChatQuestionType.longText,
      'goalsAndRisks.shortTermPriorities',
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
      'goalsAndRisks.forbiddenClaims',
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
      appendMode: true,
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

  static IntakeChatQuestion questionByKey(String questionKey) {
    return questions.firstWhere(
      (question) => question.questionKey == questionKey,
    );
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

  static List<IntakeChatQuestion> relevantQuestions(IntakeSession session) {
    return [
      for (final question in questions)
        if (_dependencyMatches(question, session) &&
            !_isDeferredOrSkipped(question, session))
          question,
    ];
  }

  static int answeredRelevantCount(IntakeSession session) {
    return relevantQuestions(
      session,
    ).where((question) => question.isAnswered(session)).length;
  }

  static String? validateAnswer(
    IntakeChatQuestion question,
    String answer,
    AppLocalizations l,
  ) {
    final clean = answer.trim();
    if (clean.isEmpty) {
      return question.required
          ? l.intakeChatRequiredAnswer
          : l.intakeChatEmptyAnswer;
    }
    if (question.type == IntakeChatQuestionType.yesNo &&
        !_isYesNoAnswer(clean)) {
      return l.intakeChatYesNoWarning;
    }
    final normalized = normalizeAnswerForQuestion(question, clean);
    if (question.validation != null && !question.validation!(normalized)) {
      return question.warningText?.call(l);
    }
    return null;
  }

  static String normalizeAnswerForQuestion(
    IntakeChatQuestion question,
    String answer,
  ) {
    final clean = answer.trim();
    if (question.type == IntakeChatQuestionType.url) {
      if (clean == 'https://' || clean == 'http://') return clean;
      if (clean.isNotEmpty &&
          !clean.startsWith('http://') &&
          !clean.startsWith('https://') &&
          clean.contains('.') &&
          !clean.contains(' ')) {
        return 'https://$clean';
      }
    }
    if (question.type == IntakeChatQuestionType.email) {
      return clean.toLowerCase();
    }
    if (question.type == IntakeChatQuestionType.multiLineList ||
        question.isChoiceQuestion) {
      final normalizedItems = <String>[];
      for (final item in _splitLines(clean)) {
        if (_isNone(item)) return item;
        if (!normalizedItems.any((existing) => _same(existing, item))) {
          normalizedItems.add(item);
        }
      }
      return normalizedItems.join('\n');
    }
    return clean;
  }

  static void saveAnswer(
    AppState state,
    IntakeChatQuestion question,
    String answer,
  ) {
    final normalized = normalizeAnswerForQuestion(question, answer);
    question.saveAnswer(state, normalized);
    final session = state.intakeSession!;
    final nextIndex = nextQuestionIndexAfter(session, question.questionKey);
    state.setIntakeChatQuestionIndex(nextIndex);
    if (nextQuestion(state.intakeSession!) == null) {
      state.markIntakeChatCompleted();
    }
  }

  static String? detailIntro(AppLocalizations l, IntakeChatQuestion question) {
    return switch (question.followUpGroup) {
      'website' => l.intakeChatDetailWebsite,
      'support' => l.intakeChatDetailSupport,
      'sensitive' => l.intakeChatDetailSensitive,
      'materials' => l.intakeChatDetailMaterials,
      'reviews' => l.intakeChatDetailReviews,
      'social' => l.intakeChatDetailSocial,
      'ads' => l.intakeChatDetailAds,
      _ => null,
    };
  }

  static String exampleText(AppLocalizations l, IntakeChatQuestion question) {
    return switch (question.type) {
      IntakeChatQuestionType.singleChoice ||
      IntakeChatQuestionType.choiceWithOther ||
      IntakeChatQuestionType.ratingChoice => l.intakeChatExampleChoice,
      IntakeChatQuestionType.multiChoice ||
      IntakeChatQuestionType.multiChoiceWithOther =>
        l.intakeChatExampleMultiChoice,
      IntakeChatQuestionType.url => l.intakeChatExampleUrl,
      IntakeChatQuestionType.email => l.intakeChatExampleEmail,
      IntakeChatQuestionType.multiLineList => l.intakeChatExampleList,
      IntakeChatQuestionType.approximateNumber =>
        l.intakeChatExampleApproximateNumber,
      IntakeChatQuestionType.longText => l.intakeChatExampleLongText,
      _ => l.intakeChatExampleShortText,
    };
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
    return _dependencyMatches(question, session) &&
        !_isDeferredOrSkipped(question, session) &&
        !question.isAnswered(session);
  }

  static bool _isDeferredOrSkipped(
    IntakeChatQuestion question,
    IntakeSession session,
  ) {
    return session.skippedQuestionKeys.contains(question.questionKey) ||
        session.deferredQuestionKeys.contains(question.questionKey);
  }

  static bool _dependencyMatches(
    IntakeChatQuestion question,
    IntakeSession session,
  ) {
    final dependency = question.dependsOnQuestionKey;
    if (dependency == null) return true;
    final parent = questions.where((q) => q.questionKey == dependency).first;
    final parentValue = parent.boolValue?.call(session);
    return parentValue == question.dependsOnAnswer;
  }
}

IntakeChatQuestion _q(
  String questionKey,
  String blockKey,
  IntakeChatQuestionType type,
  String targetField,
  String Function(AppLocalizations l) text,
  String Function(IntakeSession session) value,
  void Function(AppState state, String answer) saveAnswer, {
  String? dependsOnQuestionKey,
  bool? dependsOnAnswer,
  bool required = false,
  bool skippable = true,
  bool appendMode = false,
  String? followUpGroup,
  String? parentQuestionKey,
  String Function(AppLocalizations l)? helpText,
  String Function(AppLocalizations l)? inputHint,
  String Function(IntakeSession session)? defaultValue,
  List<String> Function(AppLocalizations l)? choiceOptions,
  bool allowMultiple = false,
  bool allowOther = false,
  String Function(AppLocalizations l)? otherLabel,
  int? minSelections,
  int? maxSelections,
  IntakeChatQuestionType? typeOverride,
  bool Function(String answer)? validation,
  String Function(AppLocalizations l)? warningText,
}) {
  return IntakeChatQuestion(
    questionKey: questionKey,
    blockKey: blockKey,
    type: typeOverride ?? type,
    targetField: targetField,
    text: text,
    value: value,
    saveAnswer: saveAnswer,
    dependsOnQuestionKey: dependsOnQuestionKey,
    dependsOnAnswer: dependsOnAnswer,
    required: required,
    skippable: skippable,
    appendMode: appendMode,
    followUpGroup: followUpGroup,
    parentQuestionKey: parentQuestionKey,
    helpText: helpText,
    inputHint: inputHint,
    defaultValue: defaultValue,
    choiceOptions: choiceOptions == null ? null : (_, l) => choiceOptions(l),
    allowMultiple: allowMultiple,
    allowOther: allowOther,
    otherLabel: otherLabel,
    minSelections: minSelections,
    maxSelections: maxSelections,
    validation: validation,
    warningText: warningText,
  );
}

IntakeChatQuestion _choice(
  String questionKey,
  String blockKey,
  IntakeChatQuestionType type,
  String targetField,
  String Function(AppLocalizations l) text,
  String Function(IntakeSession session) value,
  void Function(AppState state, String answer) saveAnswer, {
  required List<String> Function(IntakeSession session, AppLocalizations l)
  choiceOptions,
  String? dependsOnQuestionKey,
  bool? dependsOnAnswer,
  bool required = false,
  bool skippable = true,
  bool appendMode = false,
  String? followUpGroup,
  String? parentQuestionKey,
  String Function(AppLocalizations l)? helpText,
  bool allowOther = false,
  String Function(AppLocalizations l)? otherLabel,
  int? minSelections,
  int? maxSelections,
}) {
  final allowMultiple =
      type == IntakeChatQuestionType.multiChoice ||
      type == IntakeChatQuestionType.multiChoiceWithOther;
  return IntakeChatQuestion(
    questionKey: questionKey,
    blockKey: blockKey,
    type: type,
    targetField: targetField,
    text: text,
    value: value,
    saveAnswer: saveAnswer,
    choiceOptions: choiceOptions,
    allowMultiple: allowMultiple,
    allowOther:
        allowOther ||
        type == IntakeChatQuestionType.choiceWithOther ||
        type == IntakeChatQuestionType.multiChoiceWithOther,
    otherLabel: otherLabel,
    minSelections: minSelections,
    maxSelections: maxSelections,
    dependsOnQuestionKey: dependsOnQuestionKey,
    dependsOnAnswer: dependsOnAnswer,
    required: required,
    skippable: skippable,
    appendMode: appendMode,
    followUpGroup: followUpGroup,
    parentQuestionKey: parentQuestionKey,
    helpText: helpText,
  );
}

IntakeChatQuestion _yesNo(
  String questionKey,
  String blockKey,
  String targetField,
  String Function(AppLocalizations l) text,
  bool? Function(IntakeSession session) value,
  void Function(AppState state, bool answer) saveAnswer, {
  String? dependsOnQuestionKey,
  bool? dependsOnAnswer,
  bool required = false,
  bool skippable = true,
  String? followUpGroup,
  String? parentQuestionKey,
  String Function(AppLocalizations l)? helpText,
}) {
  return IntakeChatQuestion(
    questionKey: questionKey,
    blockKey: blockKey,
    type: IntakeChatQuestionType.yesNo,
    targetField: targetField,
    text: text,
    value: (session) {
      final answer = value(session);
      if (answer == null) return '';
      return answer ? 'yes' : 'no';
    },
    boolValue: value,
    saveAnswer: (state, answer) => saveAnswer(state, _parseYes(answer)),
    dependsOnQuestionKey: dependsOnQuestionKey,
    dependsOnAnswer: dependsOnAnswer,
    required: required,
    skippable: skippable,
    followUpGroup: followUpGroup,
    parentQuestionKey: parentQuestionKey,
    helpText: helpText,
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

bool _isYesNoAnswer(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized == 'yes' ||
      normalized == 'ja' ||
      normalized == 'j' ||
      normalized == 'y' ||
      normalized == 'true' ||
      normalized == 'no' ||
      normalized == 'nein' ||
      normalized == 'n' ||
      normalized == 'false';
}

bool _looksLikeUrl(String value) {
  final clean = value.trim().toLowerCase();
  if (clean == 'http://' || clean == 'https://') return false;
  if (clean.contains(' ')) return false;
  final withoutScheme = clean
      .replaceFirst(RegExp(r'^https?://'), '')
      .replaceFirst(RegExp(r'/$'), '');
  return withoutScheme.contains('.') && withoutScheme.length > 3;
}

bool _looksLikeEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
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

List<String> _splitOptions(String value) {
  return value
      .split('|')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

bool _same(String a, String b) {
  String normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  return normalize(a) == normalize(b);
}

bool _isNone(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized == 'keine' ||
      normalized == 'none' ||
      normalized == 'no fixed structure';
}
