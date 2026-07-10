// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'UniversalBiz';

  @override
  String get appStage => 'Stage 1';

  @override
  String get landingHeadline => 'Universal Business Bot Platform';

  @override
  String get landingSubtitle =>
      'Manage business knowledge, safe bot answers, audit checks, and human review for multiple companies in one local demo workspace.';

  @override
  String get landingFeatureKnowledge => 'Business Knowledge';

  @override
  String get landingFeatureBot => 'Bot';

  @override
  String get landingFeatureAudit => 'Audit';

  @override
  String get landingFeatureReview => 'Human Review';

  @override
  String get landingStepsTitle => 'Demo Flow';

  @override
  String get landingStepCompanyTitle => 'Capture company';

  @override
  String get landingStepCompanyDescription =>
      'Maintain business core, contact channels, and rules per workspace.';

  @override
  String get landingStepKnowledgeTitle => 'Structure knowledge';

  @override
  String get landingStepKnowledgeDescription =>
      'Turn FAQs, sources, and support knowledge into safe entries.';

  @override
  String get landingStepBotTitle => 'Test bot safely';

  @override
  String get landingStepBotDescription =>
      'Review, block, and validate bot questions with human review.';

  @override
  String get landingDemoTitle => 'Demo Companies';

  @override
  String get landingOpenDemo => 'Open Demo';

  @override
  String get landingBackHome => 'Back Home';

  @override
  String get companySelectTitle => 'Select Company';

  @override
  String get companySelectHeadline => 'Choose Workspace';

  @override
  String get companySelectSubtitle =>
      'Select a demo company. Dashboard, company, audit, knowledge base, bot test, review, and sources then use separate local data.';

  @override
  String get companySelectButton => 'Select';

  @override
  String get companySwitch => 'Switch Company';

  @override
  String get companyCurrent => 'Current Company';

  @override
  String get companyCreatePlaceholder => 'Create new company (later)';

  @override
  String companyProductCount(int count) {
    return '$count products';
  }

  @override
  String companyKnowledgeCount(int count) {
    return '$count knowledge entries';
  }

  @override
  String companyLogCount(int count) {
    return '$count logs';
  }

  @override
  String companyAuditScore(int score) {
    return 'Audit $score%';
  }

  @override
  String companyOpenReviewCount(int count) {
    return '$count open reviews';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navIntake => 'Intake';

  @override
  String get navCompany => 'Company';

  @override
  String get navAudit => 'Audit';

  @override
  String get navKnowledge => 'Knowledge Base';

  @override
  String get navBotTest => 'Bot Test';

  @override
  String get navBotSettings => 'Bot Settings';

  @override
  String get navSources => 'Sources';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnSave => 'Save';

  @override
  String get btnEdit => 'Edit';

  @override
  String get btnDelete => 'Delete';

  @override
  String get btnAdd => 'Add';

  @override
  String get btnReset => 'Reset';

  @override
  String get btnBack => 'Back';

  @override
  String get btnNext => 'Next';

  @override
  String get fieldCompanyName => 'Company Name';

  @override
  String get fieldIndustry => 'Industry';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldWebsite => 'Website';

  @override
  String get fieldEmail => 'E-Mail';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldAddress => 'Address';

  @override
  String get fieldCountry => 'Country';

  @override
  String get fieldPrimaryLanguage => 'Primary Language';

  @override
  String get fieldSupportEmail => 'Support E-Mail';

  @override
  String get fieldSupportPhone => 'Support Phone';

  @override
  String get fieldFacebook => 'Facebook';

  @override
  String get fieldInstagram => 'Instagram';

  @override
  String get fieldYoutube => 'YouTube';

  @override
  String get fieldTelegram => 'Telegram';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldContent => 'Content';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldKeywords => 'Keywords (comma-separated)';

  @override
  String get fieldSource => 'Source';

  @override
  String dashboardSubtitle(String companyName) {
    return 'Overview · $companyName';
  }

  @override
  String get statKnowledgeEntries => 'Knowledge Entries';

  @override
  String get statBotRequests => 'Bot Requests';

  @override
  String get statMatchRate => 'Match Rate';

  @override
  String get statProducts => 'Products & Services';

  @override
  String get statSourcesTotal => 'Total Sources';

  @override
  String get statSourcesNew => 'New Sources';

  @override
  String get statIntakeStatus => 'Company Intake';

  @override
  String get dashboardRecentRequests => 'Recent Bot Requests';

  @override
  String dashboardTotal(int count) {
    return '$count total';
  }

  @override
  String get dashboardNoLogs => 'No bot requests yet. Start the bot test.';

  @override
  String get logNoAnswer => 'No answer found';

  @override
  String get dashboardNextStepsTitle => 'Next recommended steps';

  @override
  String get dashboardRecommendationAuditTitle => 'Close audit gaps';

  @override
  String dashboardRecommendationAuditDescription(int count) {
    return '$count high-priority audit items are still missing.';
  }

  @override
  String get dashboardRecommendationKnowledgeTitle => 'Expand knowledge base';

  @override
  String dashboardRecommendationKnowledgeDescription(int count) {
    return 'There are currently $count knowledge entries. Add more safe FAQs and support cases for a stronger demo.';
  }

  @override
  String get dashboardRecommendationSourcesTitle => 'Review sources';

  @override
  String dashboardRecommendationSourcesDescription(int count) {
    return '$count new sources are waiting to be reviewed and converted into knowledge where useful.';
  }

  @override
  String get dashboardRecommendationReviewTitle => 'Check human review';

  @override
  String dashboardRecommendationReviewDescription(int count) {
    return '$count bot questions are waiting for review.';
  }

  @override
  String get dashboardRecommendationProfileTitle => 'Complete company profile';

  @override
  String get dashboardRecommendationProfileDescription =>
      'Business core, contact channels, or business rules are not fully maintained yet.';

  @override
  String get dashboardRecommendationAllDoneTitle =>
      'Workspace looks demo-ready';

  @override
  String get dashboardRecommendationAllDoneDescription =>
      'No urgent next steps can be derived from the current workspace data.';

  @override
  String get dashboardRecommendationBotSettingsTitle => 'Review bot settings';

  @override
  String get dashboardRecommendationBotSettingsDescription =>
      'The bot is still in draft. Check status, escalation, and handover rules before testing.';

  @override
  String get dashboardRecommendationIntakeTitle => 'Start company intake';

  @override
  String get dashboardRecommendationIntakeDescription =>
      'This workspace does not have a structured company intake yet.';

  @override
  String get dashboardRecommendationIntakeImportTitle =>
      'Import company intake';

  @override
  String get dashboardRecommendationIntakeImportDescription =>
      'The company intake is completed, but has not been reviewed and imported into the workspace yet.';

  @override
  String get intakeTitle => 'Company Intake';

  @override
  String intakeSubtitle(String companyName) {
    return 'Structured intake for $companyName';
  }

  @override
  String intakeStepOfTotal(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get intakeStatusDraft => 'Draft';

  @override
  String get intakeStatusInProgress => 'In Progress';

  @override
  String get intakeStatusCompleted => 'Completed';

  @override
  String get intakeStatusNotStarted => 'Not Started';

  @override
  String get intakeImportStatusReady => 'Ready to Import';

  @override
  String get intakeImportStatusImported => 'Imported';

  @override
  String get intakeSaveDraft => 'Save Draft';

  @override
  String get intakeDraftSaved => 'Draft saved.';

  @override
  String get intakeCompleted => 'Company intake completed.';

  @override
  String get intakeSummaryTitle => 'Summary';

  @override
  String get intakeSummaryNotice =>
      'This company intake is saved. Transfer into the workspace follows in the next step.';

  @override
  String get intakeMarkCompleted => 'Mark as completed';

  @override
  String get intakePrepareImport => 'Prepare workspace import';

  @override
  String get intakeMappingPreviewTitle => 'Workspace Import Preview';

  @override
  String get intakeMappingPreviewDescription =>
      'Review which intake data will be written to which workspace areas. Conflicts are not selected by default.';

  @override
  String get intakeMappingConflictWarning =>
      'Some suggestions differ from existing workspace data and must be selected intentionally.';

  @override
  String get intakeConflict => 'Conflict';

  @override
  String get intakeCurrentValue => 'Current value';

  @override
  String get intakeProposedValue => 'Proposed value';

  @override
  String get intakeKnowledgeDraftEmpty =>
      'Empty FAQ draft – add an approved answer before use.';

  @override
  String get intakeImportSelected => 'Import selected data';

  @override
  String get intakeImportConfirmTitle => 'Import selected data?';

  @override
  String get intakeImportConfirmDescription =>
      'Only selected suggestions will be written into this workspace. Existing data is replaced only for selected conflicts.';

  @override
  String get intakeImportSuccess => 'Selected intake data was imported.';

  @override
  String get intakeNoAnswer => 'Not answered yet';

  @override
  String get intakeStepBasicsTitle => 'Basics';

  @override
  String get intakeStepBasicsDescription =>
      'Core company data, contact channels, and a short positioning.';

  @override
  String get intakeStepProductsTitle => 'Products / Services';

  @override
  String get intakeStepProductsDescription =>
      'What is offered, what has priority, and what needs explanation.';

  @override
  String get intakeStepTargetGroupsTitle => 'Target Group / Positioning';

  @override
  String get intakeStepTargetGroupsDescription =>
      'Who the company serves and which value should be communicated clearly.';

  @override
  String get intakeStepWebsiteSupportTitle => 'Website / Support / FAQ';

  @override
  String get intakeStepWebsiteSupportDescription =>
      'Important pages, frequent questions, and sensitive support topics.';

  @override
  String get intakeStepSourcesReviewsTitle => 'Sources / Reviews';

  @override
  String get intakeStepSourcesReviewsDescription =>
      'Existing materials, reviews, social signals, and trust assets.';

  @override
  String get intakeStepMarketingTitle => 'Marketing / Channels';

  @override
  String get intakeStepMarketingDescription =>
      'Previous channels, campaigns, and reach problems.';

  @override
  String get intakeStepGoalsRisksTitle => 'Goals / Risks / No-Go';

  @override
  String get intakeStepGoalsRisksDescription =>
      'Priorities, forbidden claims, and topics that require human review.';

  @override
  String get intakeImportantProducts => 'Most important products / services';

  @override
  String get intakeMainProduct => 'Main product';

  @override
  String get intakeExplanationNeeded => 'Products that need explanation';

  @override
  String get intakePriorityProducts => 'Current product priorities';

  @override
  String get intakeTargetGroup => 'Target group';

  @override
  String get intakeMarketType => 'B2B / B2C';

  @override
  String get intakeProblemSolved => 'Which problem is solved?';

  @override
  String get intakeCustomerBenefit => 'Most important customer benefit';

  @override
  String get intakeDifferentiation => 'Differentiation from competitors';

  @override
  String get intakeImportantPages => 'Important website / landing pages';

  @override
  String get intakeFrequentQuestions => 'Frequent customer questions';

  @override
  String get intakeSupportProblems => 'Frequent support issues';

  @override
  String get intakeSensitiveTopics => 'Sensitive questions / topics';

  @override
  String get intakeExistingSources => 'Existing sources / PDFs / guides';

  @override
  String get intakeReviews => 'Reviews / testimonials';

  @override
  String get intakeSocialMentions =>
      'Social media mentions / external discussions';

  @override
  String get intakeTrustMaterial => 'Trust material';

  @override
  String get intakeChannels => 'Channels used so far';

  @override
  String get intakeCampaigns => 'Previous marketing activities';

  @override
  String get intakeWorked => 'What worked?';

  @override
  String get intakeNotWorked => 'What did not work?';

  @override
  String get intakeReachProblems => 'Current reach problems';

  @override
  String get intakeCompanyGoals => 'Most important company goals';

  @override
  String get intakeShortTermPriorities => 'Short-term priorities';

  @override
  String get intakeForbiddenClaims => 'Sensitive / forbidden claims';

  @override
  String get intakeBotRestrictedTopics =>
      'Topics the bot must not answer freely';

  @override
  String get intakeChatTitle => 'Chat Intake';

  @override
  String get intakeChatSubtitle =>
      'Step-by-step questionnaire for company profile, website, support, materials, and goals.';

  @override
  String get intakeChatStart => 'Start chat intake';

  @override
  String get intakeChatResume => 'Resume chat intake';

  @override
  String get intakeChatSharedDataHint => 'All answers are saved automatically.';

  @override
  String get intakeChatOpenWizard => 'Open overview';

  @override
  String intakeChatQuestionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get intakeChatCompletedProgress => 'Completed';

  @override
  String get intakeChatInputHint => 'Enter answer …';

  @override
  String get intakeChatDoneInputHint => 'All questions are answered.';

  @override
  String get intakeChatYes => 'Yes';

  @override
  String get intakeChatNo => 'No';

  @override
  String get intakeChatSkip => 'Skip';

  @override
  String get intakeChatEnterAnswer => 'Enter answer';

  @override
  String get intakeChatDialogCancel => 'Cancel';

  @override
  String get intakeChatDialogDefer => 'Answer later';

  @override
  String get intakeChatDialogSave => 'Save';

  @override
  String get intakeChatDialogSaveContinue => 'Save and continue';

  @override
  String get intakeChatPause => 'Continue later';

  @override
  String get intakeChatGoToSummary => 'Go to intake summary';

  @override
  String get intakeChatGreeting =>
      'Hello! I will guide you through the company intake step by step.';

  @override
  String get intakeChatExplanation =>
      'Answer the current question. After that, the next relevant step appears automatically.';

  @override
  String get intakeChatAllDone =>
      'The chat intake is complete. You can now open the summary and prepare the workspace import.';

  @override
  String get intakeChatEmptyAnswer =>
      'Please enter an answer or skip the question.';

  @override
  String get intakeChatSkipped => 'Question skipped.';

  @override
  String get intakeChatRequiredAnswer =>
      'This question is required. Please enter an answer.';

  @override
  String get intakeChatYesNoWarning => 'Please answer with yes or no.';

  @override
  String get intakeChatUrlWarning =>
      'This does not look like a website URL. Please check it briefly.';

  @override
  String get intakeChatEmailWarning =>
      'This email address does not look valid. Please check the format.';

  @override
  String get intakeChatDeferred => 'Answer later.';

  @override
  String get intakeChatAnswerSaved => 'Answer saved.';

  @override
  String get intakeChatExampleShortDescription =>
      'Example: We develop and sell accessories for cat owners in German-speaking markets.';

  @override
  String get intakeChatExampleIndustry =>
      'Example: online retail, consulting, software, or health products';

  @override
  String get intakeChatExampleWebsiteUrl =>
      'Example: https://www.mycompany.com';

  @override
  String get intakeChatExampleShopUrl => 'Example: https://shop.mycompany.com';

  @override
  String get intakeChatExampleFaqUrl =>
      'Example: https://www.mycompany.com/faq';

  @override
  String get intakeChatExampleSupportEmail => 'Example: support@mycompany.com';

  @override
  String get intakeChatExampleSupportPhone => 'Example: +43 660 1234567';

  @override
  String get intakeChatExampleImportantProducts =>
      'Example: mobile app, relax pillow, accessories';

  @override
  String get intakeChatExampleMainProduct =>
      'Example: Our best-selling product is ...';

  @override
  String get intakeChatExampleTargetGroup =>
      'Example: private customers in the DACH region and small specialist retailers';

  @override
  String get intakeChatExampleCustomerBenefit =>
      'Example: Customers save time, get clear information, or solve a concrete everyday problem.';

  @override
  String get intakeChatExampleWebsitePages =>
      'Example: product page, FAQ, contact, shop, retailer area';

  @override
  String get intakeChatExampleSupportQuestions =>
      'Example: How long does delivery take? How does setup work?';

  @override
  String get intakeChatExampleSupportProblems =>
      'Example: connection issues, wrong order, missing instructions';

  @override
  String get intakeChatExampleReviewCount =>
      'Example: about 20 reviews or roughly 150 star ratings';

  @override
  String get intakeChatExampleReviewLinks =>
      'Example: Google profile, Facebook page, or screenshot file';

  @override
  String get intakeChatExampleMaterials =>
      'Example: user manual, PDF brochure, presentation, or price list';

  @override
  String get intakeChatExampleMaterialLocations =>
      'Example: website, Google Drive, internal folder, or printed documents';

  @override
  String get intakeChatExampleSocialProfileLinks =>
      'Example: https://facebook.com/mycompany';

  @override
  String get intakeChatExamplePostingFrequency =>
      'Example: twice per week or irregularly';

  @override
  String get intakeChatExampleCampaigns =>
      'Example: Facebook campaign for product X in spring';

  @override
  String get intakeChatExampleAdBudget => 'Example: about €500 per month';

  @override
  String get intakeChatExampleAdResults =>
      'Example: 300 clicks, 12 inquiries, and 3 sales';

  @override
  String get intakeChatExampleGoals =>
      'Example: more inquiries, better visibility, and less support effort';

  @override
  String get intakeChatExampleSensitiveTopics =>
      'Example: medical statements, refunds, or individual legal advice';

  @override
  String get intakeChatExampleNoGoStatements =>
      'Example: no healing promises and no binding legal advice';

  @override
  String get intakeChatExampleEscalationTopics =>
      'Example: complaints, legal threats, or individual health questions';

  @override
  String get intakeChatAnswerModeYesNo => 'Choose yes or no.';

  @override
  String get intakeChatAnswerModeChoice => 'Choose one answer.';

  @override
  String get intakeChatAnswerModeMultiChoice => 'Choose all matching answers.';

  @override
  String get intakeChatAnswerModeShortText => 'Enter a short answer.';

  @override
  String get intakeChatAnswerModeLongText => 'Enter a short description.';

  @override
  String get intakeChatAnswerModeList => 'Enter one or more items.';

  @override
  String get intakeChatAnswerModeUrl => 'Enter a web address.';

  @override
  String get intakeChatAnswerModeEmail => 'Enter an email address.';

  @override
  String get intakeChatAnswerModeApproximateNumber =>
      'Enter a number or rough estimate.';

  @override
  String get intakeChatListHint =>
      'Separate multiple entries with commas or line breaks.';

  @override
  String get intakeChatDetailWebsite =>
      'Thanks. Let us capture the website details briefly.';

  @override
  String get intakeChatDetailSupport =>
      'Thanks. Let us collect the key support questions.';

  @override
  String get intakeChatDetailSensitive =>
      'Thanks. Let us capture the sensitive rules more precisely.';

  @override
  String get intakeChatDetailMaterials =>
      'Thanks. Let us capture the existing materials briefly.';

  @override
  String get intakeChatDetailReviews =>
      'Thanks. Let us go through the review and trust details.';

  @override
  String get intakeChatDetailSocial =>
      'Thanks. Let us capture the social media details.';

  @override
  String get intakeChatDetailAds =>
      'Thanks. Let us collect the previous advertising experience.';

  @override
  String get intakeChatQCompanyName => 'What is the company name?';

  @override
  String get intakeChatQShortDescription =>
      'Briefly describe the company in 1–3 sentences.';

  @override
  String get intakeChatQIndustry =>
      'Which industry or category is the company in?';

  @override
  String get intakeChatQCountry =>
      'In which country is the company mainly active?';

  @override
  String get intakeChatQPrimaryLanguage =>
      'Which primary language should this workspace use?';

  @override
  String get intakeChatQAdditionalLanguages =>
      'Which other languages are important?';

  @override
  String get intakeChatQHasWebsite => 'Is there already a website?';

  @override
  String get intakeChatQWebsite => 'What is the website URL?';

  @override
  String get intakeChatQHasShop => 'Is there an online shop?';

  @override
  String get intakeChatQShopUrl => 'What is the shop URL?';

  @override
  String get intakeChatQHasFaqArea =>
      'Is there an FAQ or support area on the website?';

  @override
  String get intakeChatQFaqUrl => 'What is the URL of the FAQ or support area?';

  @override
  String get intakeChatQWebsiteMaintainer =>
      'Who currently maintains the website?';

  @override
  String get intakeChatQCanEditWebsiteQuickly =>
      'Can the company change website content itself on short notice?';

  @override
  String get intakeChatQWebsitePlanned => 'Is a website planned?';

  @override
  String get intakeChatQSupportEmail => 'Which support email should be used?';

  @override
  String get intakeChatQSupportPhone => 'Is there a support phone number?';

  @override
  String get intakeChatQImportantProducts =>
      'What are the most important products or services? You can use multiple lines.';

  @override
  String get intakeChatQMainProduct =>
      'What is the current main product or offer?';

  @override
  String get intakeChatQPriorityProducts =>
      'Which products or services currently have priority?';

  @override
  String get intakeChatQExplanationNeeded =>
      'Which products or services need explanation?';

  @override
  String get intakeChatQTargetGroup =>
      'Who is the most important target group?';

  @override
  String get intakeChatQMarketType => 'Is the offer mainly B2B, B2C, or both?';

  @override
  String get intakeChatQProblemSolved =>
      'Which problem does the offer solve for customers?';

  @override
  String get intakeChatQCustomerBenefit =>
      'What is the most important customer benefit?';

  @override
  String get intakeChatQDifferentiation =>
      'How does the company differ from alternatives?';

  @override
  String get intakeChatQImportantPages =>
      'Which website or landing pages are important?';

  @override
  String get intakeChatQHasSupportQuestions =>
      'Are there recurring support questions or customer issues?';

  @override
  String get intakeChatQSupportChannels =>
      'Which channels do support questions come through?';

  @override
  String get intakeChatQPreSalesQuestions =>
      'Which questions come up frequently before purchase?';

  @override
  String get intakeChatQAfterSalesQuestions =>
      'Which questions come up frequently after purchase?';

  @override
  String get intakeChatQTechnicalProblems =>
      'Which technical problems occur frequently?';

  @override
  String get intakeChatQComplaintsOrMisunderstandings =>
      'Which complaints or misunderstandings occur?';

  @override
  String get intakeChatQSupportOwner =>
      'Who currently answers these questions?';

  @override
  String get intakeChatQStandardizableQuestions =>
      'Which questions could be answered in a standardized way?';

  @override
  String get intakeChatQFrequentQuestions =>
      'Which questions do customers ask most often?';

  @override
  String get intakeChatQSupportProblems =>
      'Which support issues occur frequently?';

  @override
  String get intakeChatQHasSensitiveTopics =>
      'Are there sensitive questions or topics?';

  @override
  String get intakeChatQSensitiveTopics =>
      'Which sensitive questions or topics should be handled carefully?';

  @override
  String get intakeChatQProhibitedStatements =>
      'Which statements or wordings should be avoided?';

  @override
  String get intakeChatQAlwaysEscalateTopics =>
      'Which topics should always be handed over to a human?';

  @override
  String get intakeChatQLegalRestrictions =>
      'Are there legal or industry-specific restrictions?';

  @override
  String get intakeChatQHasMaterials =>
      'Are there existing materials such as PDFs, guides, or presentations?';

  @override
  String get intakeChatQMaterialDetails =>
      'Which materials exist specifically?';

  @override
  String get intakeChatQMaterialLocations =>
      'Where are these materials stored?';

  @override
  String get intakeChatQMaterialFreshness =>
      'Are the materials current or partly outdated?';

  @override
  String get intakeChatQImportantMaterials =>
      'Which materials are especially important?';

  @override
  String get intakeChatQMaterialsUsableForKnowledgeBase =>
      'May these materials be used for the knowledge base?';

  @override
  String get intakeChatQExistingSources =>
      'Which PDFs, guides, notes, or materials already exist?';

  @override
  String get intakeChatQHasReviews => 'Are there reviews or testimonials?';

  @override
  String get intakeChatQReviewPlatforms => 'Where are these reviews located?';

  @override
  String get intakeChatQReviewCountEstimate =>
      'Roughly how many reviews are there?';

  @override
  String get intakeChatQReviewLinksOrFiles =>
      'Are there links, files, or screenshots for the reviews?';

  @override
  String get intakeChatQReviewTypes => 'What type of reviews are they?';

  @override
  String get intakeChatQReviewsPubliclyUsable =>
      'Can the reviews be used publicly?';

  @override
  String get intakeChatQReviewsEmbeddedOnWebsite =>
      'Are they already embedded on the website?';

  @override
  String get intakeChatQCollectReviewsPlanned =>
      'Should trust or review material be collected intentionally in the future?';

  @override
  String get intakeChatQReviews =>
      'Which reviews or testimonials are relevant?';

  @override
  String get intakeChatQHasSocialMentions =>
      'Are there social media mentions or external discussions?';

  @override
  String get intakeChatQSocialMentions =>
      'Which social media mentions or external discussions are important?';

  @override
  String get intakeChatQHasTrustMaterial =>
      'Is there trust material such as seals, references, or proof points?';

  @override
  String get intakeChatQTrustMaterial => 'Which trust material is available?';

  @override
  String get intakeChatQHasSocialChannels =>
      'Are there active social media channels?';

  @override
  String get intakeChatQSocialPlatforms => 'Which platforms are used?';

  @override
  String get intakeChatQSocialProfileLinks =>
      'What are the links or profile names?';

  @override
  String get intakeChatQActiveChannels =>
      'Which channels are currently active?';

  @override
  String get intakeChatQPostingFrequency =>
      'How often is content posted roughly?';

  @override
  String get intakeChatQWorkingChannels => 'Which channels work well?';

  @override
  String get intakeChatQInactiveChannels => 'Which channels are inactive?';

  @override
  String get intakeChatQFutureSocialPlatforms =>
      'Which platform would generally be interesting?';

  @override
  String get intakeChatQChannels =>
      'Which marketing or communication channels have been used so far?';

  @override
  String get intakeChatQHasRunAds => 'Has advertising been run before?';

  @override
  String get intakeChatQAdvertisingChannels =>
      'On which channels was advertising run?';

  @override
  String get intakeChatQCampaigns =>
      'Which marketing activities have been tried so far?';

  @override
  String get intakeChatQApproximateBudget => 'What was the approximate budget?';

  @override
  String get intakeChatQSuccessfulMeasures => 'What worked?';

  @override
  String get intakeChatQUnsuccessfulMeasures => 'What did not work?';

  @override
  String get intakeChatQAvailableMetrics =>
      'Are there figures for clicks, leads, sales, or inquiries?';

  @override
  String get intakeChatQAdAccountAccess =>
      'Is there access to ad accounts or reports?';

  @override
  String get intakeChatQFutureAdChannels =>
      'Which advertising channels should be checked in the future?';

  @override
  String get intakeChatQWorkedNotWorked =>
      'What has worked so far, and what has not?';

  @override
  String get intakeChatQReachProblems =>
      'Where are there current reach problems?';

  @override
  String get intakeChatQCompanyGoals =>
      'What are the most important company goals?';

  @override
  String get intakeChatQShortTermPriorities =>
      'What are the short-term priorities?';

  @override
  String get intakeChatQForbiddenClaims =>
      'Which claims are sensitive or forbidden?';

  @override
  String get intakeChatQBotRestrictedTopics =>
      'Which topics must a bot not answer freely?';

  @override
  String get intakeChoiceOther => 'Other';

  @override
  String get intakeChoiceOtherHint => 'Enter another answer';

  @override
  String get intakeChoiceDialogSingleHint => 'Tap one option.';

  @override
  String get intakeChoiceDialogMultiHint => 'Tap all matching options.';

  @override
  String get intakeChoiceDialogSelectionRequired =>
      'Please select at least one option.';

  @override
  String get intakeChoiceDialogSaveContinue => 'Save selection and continue';

  @override
  String get intakeChoiceLanguageOptions =>
      'German|English|French|Italian|Spanish|Dutch|Polish';

  @override
  String get intakeChoiceRegionOptions =>
      'domestic market|DACH|EU|Europe|worldwide|individual countries';

  @override
  String get intakeChoiceTargetGroupOptions =>
      'private customers|businesses|retailers|therapists|public authorities|associations|educational institutions|pet owners|international customers';

  @override
  String get intakeChoiceMarketTypeOptions => 'B2C|B2B|both';

  @override
  String get intakeChoiceSupportChannelOptions =>
      'phone|email|WhatsApp|Telegram|website form|live chat|Facebook Messenger|Instagram|in person|retailers|no fixed structure';

  @override
  String get intakeChoiceSensitiveCategoryOptions =>
      'medical statements|legal questions|data protection|prices/discounts|complaints|refunds|product safety|technical issues|individual advice|confidential company data';

  @override
  String get intakeChoiceMaterialOptions =>
      'user manual|PDF|brochure|presentation|price lists|product texts|FAQ list|answer templates|videos|images|screenshots|internal notes|emails';

  @override
  String get intakeChoiceReviewPlatformOptions =>
      'own website|Google|Facebook|Trustpilot|Amazon|App Store|Google Play|YouTube|email|screenshots|forums';

  @override
  String get intakeChoiceSocialPlatformOptions =>
      'Facebook|Instagram|TikTok|YouTube|LinkedIn|WhatsApp|Telegram|Reddit|X|Pinterest|Snapchat|own blog|newsletter|none';

  @override
  String get intakeChoiceAdvertisingChannelOptions =>
      'Google Ads|Facebook Ads|Instagram Ads|TikTok Ads|YouTube Ads|LinkedIn Ads|influencers|SEO|newsletter|print|flyers|trade fairs|Telegram/community marketing|none';

  @override
  String get intakeChoiceGoalOptions =>
      'more sales|more inquiries|greater reach|better visibility|less support effort|better customer information|more reviews|better website|expand social media|optimize advertising|new markets|improve internal workflows';

  @override
  String get intakeChoiceReachProblemOptions =>
      'too few website visitors|too few inquiries|too few sales|low social reach|too few reviews|unclear positioning|weak landing page|too little trust|too little content|wrong advertising channels|no measurement data';

  @override
  String get companyTitle => 'Company';

  @override
  String get companyEditDialogTitle => 'Edit Company Data';

  @override
  String get companyProducts => 'Products & Services';

  @override
  String get companyCoreSubtitle =>
      'Business core for audit, knowledge base, bot, and external channels';

  @override
  String get companyProfileSection => 'Company Profile';

  @override
  String get companyContactWebSection => 'Contact & Web';

  @override
  String get companySocialSection => 'Social / Channels';

  @override
  String get companyBusinessRulesSection => 'Business Rules';

  @override
  String get companyInternalNotesSection => 'Internal Notes';

  @override
  String get companyNoSocialLinks =>
      'No social or channel links maintained yet.';

  @override
  String get companyNoInternalNotes => 'No internal notes maintained yet.';

  @override
  String get companyBrandVoice => 'Brand Voice / Tone';

  @override
  String get companyDoNotSay => 'Do-not-say / No-Go Rules';

  @override
  String get companyAllowedSupportTopics => 'Allowed Support Topics';

  @override
  String get companyEscalationNotes => 'Escalation Notes';

  @override
  String get companyDisclaimerText => 'Disclaimer Text';

  @override
  String get companyProfileComplete => 'Complete';

  @override
  String get companyProfilePartial => 'Partial';

  @override
  String get companyProfileIncomplete => 'Incomplete';

  @override
  String get auditTitle => 'Audit';

  @override
  String get auditSubtitle => 'Completeness check for bot deployment';

  @override
  String get auditTotalScore => 'Total Score';

  @override
  String auditScoreLabel(int score, int max) {
    return '$score / $max points';
  }

  @override
  String get auditExcellent => 'Excellent – Bot is ready!';

  @override
  String get auditGood => 'Good – fill remaining gaps.';

  @override
  String get auditMedium => 'Fair – expanding knowledge recommended.';

  @override
  String get auditPoor => 'Incomplete – bot not ready yet.';

  @override
  String get auditChecklist => 'Checklist';

  @override
  String auditPoints(int points) {
    return '+$points pts.';
  }

  @override
  String get auditCheckCompanyName => 'Company name entered';

  @override
  String get auditCheckIndustry => 'Industry defined';

  @override
  String get auditCheckDescription => 'Company description present';

  @override
  String get auditCheckWebsite => 'Website entered';

  @override
  String get auditCheckProducts => 'Products / Services recorded';

  @override
  String get auditCheckKnowledge => 'Knowledge entries present';

  @override
  String get auditCheckKnowledge10 => 'At least 10 knowledge entries';

  @override
  String get auditCheckBotTest => 'Bot test performed';

  @override
  String auditDescChars(int count) {
    return '$count characters';
  }

  @override
  String get auditDescTooShort => 'Too short (min. 50 chars)';

  @override
  String auditDescEntries(int count) {
    return '$count entries';
  }

  @override
  String get auditDescAchieved => 'Achieved';

  @override
  String auditDescOfTotal(int current, int total) {
    return '$current of $total';
  }

  @override
  String get auditDescNoTest => 'No test yet';

  @override
  String auditDescTestCount(int count) {
    return '$count test requests';
  }

  @override
  String auditBusinessSubtitle(String companyName) {
    return 'Business status and bot readiness · $companyName';
  }

  @override
  String get auditBusinessStatusTitle => 'Status Assessment';

  @override
  String get auditItemsComplete => 'complete';

  @override
  String auditMissingCount(int count) {
    return '$count missing';
  }

  @override
  String auditPartialCount(int count) {
    return '$count partial';
  }

  @override
  String auditCompleteCount(int count) {
    return '$count complete';
  }

  @override
  String auditHighPriorityOpenCount(int count) {
    return '$count high-priority open';
  }

  @override
  String get auditAreaCompanyProfile => 'Company Profile';

  @override
  String get auditAreaWebsite => 'Website / Web Presence';

  @override
  String get auditAreaProducts => 'Products / Services';

  @override
  String get auditAreaSupportKnowledge => 'FAQ / Support Knowledge';

  @override
  String get auditAreaTrustMaterial => 'Reviews / Trust Material';

  @override
  String get auditAreaSocialPresence => 'Social Media / External Presence';

  @override
  String get auditAreaSources => 'Sources / Documents';

  @override
  String get auditAreaRiskRules => 'Risk / No-Go Rules';

  @override
  String get auditAreaBotReadiness => 'Bot Readiness';

  @override
  String get auditStatusMissing => 'Missing';

  @override
  String get auditStatusPartial => 'Partial';

  @override
  String get auditStatusComplete => 'Complete';

  @override
  String get auditPriorityLow => 'Low';

  @override
  String get auditPriorityMedium => 'Medium';

  @override
  String get auditPriorityHigh => 'High';

  @override
  String get auditNote => 'Note';

  @override
  String get auditRecommendation => 'Recommendation';

  @override
  String get auditEditNote => 'Edit Note';

  @override
  String get auditNoteHint => 'Internal note for this audit item …';

  @override
  String get knowledgeTitle => 'Knowledge Base';

  @override
  String knowledgeEntryCount(int count) {
    return '$count entries';
  }

  @override
  String get knowledgeFilterAll => 'All';

  @override
  String get knowledgeNoEntries => 'No entries in this category.';

  @override
  String get knowledgeAddEntry => 'Add Entry';

  @override
  String get knowledgeDeleteTitle => 'Delete entry?';

  @override
  String knowledgeDeleteConfirm(String title) {
    return '\"$title\" will be permanently removed.';
  }

  @override
  String get knowledgeNewEntry => 'New Knowledge Entry';

  @override
  String get knowledgeSourceMaterialOptional =>
      'Link source material (optional)';

  @override
  String get knowledgeNoSourceMaterial => 'Do not link a source';

  @override
  String get knowledgeMarkSourceConverted => 'Mark source as converted';

  @override
  String get botTestTitle => 'Bot Test';

  @override
  String get botTestSubtitle =>
      'Simulated bot without real AI – answers based on the knowledge base.';

  @override
  String get botTestGreeting =>
      'Hello! I am your bot assistant. Ask me a question about the company.';

  @override
  String get botTestInputHint => 'Enter question …';

  @override
  String get botTestNoMatch =>
      'No matching answer found. Please contact us directly.';

  @override
  String get botTestResetMessage => 'Chat reset. Ask me a new question!';

  @override
  String get sourcesTitle => 'Sources';

  @override
  String get sourcesSubtitle => 'Sources and materials for this workspace';

  @override
  String get sourcesAdd => 'Add Source';

  @override
  String sourcesCount(int count) {
    return '$count sources';
  }

  @override
  String sourcesNewCount(int count) {
    return '$count new';
  }

  @override
  String sourcesEntriesCount(int count) {
    return '$count entries';
  }

  @override
  String get sourcesEmpty => 'No sources available yet.';

  @override
  String sourcesEntryInfo(int count, String type) {
    return '$count entries · $type';
  }

  @override
  String get sourcesFilterAllTypes => 'All Types';

  @override
  String get sourcesFilterAllStatuses => 'All Statuses';

  @override
  String sourcesLinkedEntries(int count) {
    return '$count linked entries';
  }

  @override
  String get sourcesDeleteTitle => 'Delete source?';

  @override
  String sourcesDeleteConfirm(String title) {
    return '\"$title\" will be removed from the source list. Knowledge entries remain unchanged.';
  }

  @override
  String get sourcesEdit => 'Edit Source';

  @override
  String get sourcesType => 'Source Type';

  @override
  String get sourcesStatus => 'Status';

  @override
  String get sourcesUrlOptional => 'URL (optional)';

  @override
  String get sourcesSnippetOptional => 'Content snippet (optional)';

  @override
  String get sourcesNotesOptional => 'Notes (optional)';

  @override
  String get sourceTypeUrl => 'Website';

  @override
  String get sourceTypeDocument => 'Document';

  @override
  String get sourceTypeManual => 'Manual';

  @override
  String get sourceMaterialTypeWebsite => 'Website';

  @override
  String get sourceMaterialTypePdf => 'PDF';

  @override
  String get sourceMaterialTypeFaq => 'FAQ';

  @override
  String get sourceMaterialTypeReview => 'Review';

  @override
  String get sourceMaterialTypeSocial => 'Social';

  @override
  String get sourceMaterialTypeNote => 'Note';

  @override
  String get sourceMaterialTypeOther => 'Other';

  @override
  String get sourceMaterialStatusNew => 'New';

  @override
  String get sourceMaterialStatusReviewed => 'Reviewed';

  @override
  String get sourceMaterialStatusConverted => 'Converted';

  @override
  String get sourceMaterialStatusIgnored => 'Ignored';

  @override
  String get sourcesStage2Hint =>
      'In Stage 2, sources can be imported directly (websites, PDFs, documents).';

  @override
  String get categoryFaq => 'FAQ';

  @override
  String get categoryProdukt => 'Product';

  @override
  String get categoryProzess => 'Process';

  @override
  String get categoryAllgemein => 'General';

  @override
  String get typeProdukt => 'Product';

  @override
  String get typeDienstleistung => 'Service';

  @override
  String get riskGreen => 'Safe';

  @override
  String get riskYellow => 'Wellness';

  @override
  String get riskRed => 'Blocked';

  @override
  String botTestRedirectMessage(String supportEmail) {
    return 'This question touches on medical or legal areas that I am not permitted to answer. Please consult a qualified professional or contact our support directly: $supportEmail';
  }

  @override
  String get botTestYellowDisclaimer =>
      'Note: This answer is for general information only and does not replace medical advice.';

  @override
  String get statOpenRequests => 'Open Requests';

  @override
  String get statRedirects => 'Redirections';

  @override
  String get statReviewedBotQuestions => 'Reviewed Bot Questions';

  @override
  String get statAuditScore => 'Audit Score';

  @override
  String get statAuditMissing => 'Audit Missing';

  @override
  String get statAuditPartial => 'Audit Partial';

  @override
  String get statAuditComplete => 'Audit Complete';

  @override
  String get statAuditHighPriorityOpen => 'High-Priority Gaps';

  @override
  String get statCompanyProfile => 'Company Profile';

  @override
  String get statBotStatus => 'Bot Status';

  @override
  String get statReviewOpen => 'Open for Review';

  @override
  String get dashboardRiskTitle => 'Knowledge Base by Risk Level';

  @override
  String get knowledgeRisk => 'Risk Level';

  @override
  String get navReview => 'Review';

  @override
  String get reviewTitle => 'Human Review';

  @override
  String get reviewSubtitle => 'Bot requests for manual review';

  @override
  String get reviewEmpty => 'No entries for review.';

  @override
  String get reviewFilterAll => 'All';

  @override
  String reviewOpenCount(int count) {
    return '$count open';
  }

  @override
  String get reviewStatusOpen => 'Open';

  @override
  String get reviewStatusReviewed => 'Reviewed';

  @override
  String get reviewStatusClosed => 'Closed';

  @override
  String get reviewReasonNoMatch => 'No Match';

  @override
  String get reviewReasonRedFlag => 'Red Question';

  @override
  String get reviewReasonYellowRisk => 'Yellow Answer';

  @override
  String get reviewReasonLowConfidence => 'Low Confidence';

  @override
  String get reviewBotAnswer => 'Bot Answer';

  @override
  String get reviewHumanNote => 'Note';

  @override
  String get reviewNoteHint => 'Note for the team …';

  @override
  String get reviewSaveNote => 'Save Note';

  @override
  String get reviewAddNote => 'Edit Note';

  @override
  String get reviewMarkReviewed => 'Mark as reviewed';

  @override
  String get reviewMarkClosed => 'Mark as closed';

  @override
  String get reviewCreateKnowledgeEntry => 'Create knowledge entry';

  @override
  String get reviewKnowledgeSourceOptional => 'Source (optional)';

  @override
  String get reviewKnowledgeDefaultSource => 'Human Review';

  @override
  String get reviewKnowledgeCreatedNote => 'Converted to knowledge entry';

  @override
  String get botSettingsTitle => 'Bot Settings';

  @override
  String botSettingsSubtitle(String companyName) {
    return 'Configuration for $companyName';
  }

  @override
  String get botSettingsStatus => 'Status';

  @override
  String get botSettingsAnswerStyle => 'Answer Style';

  @override
  String get botSettingsLanguage => 'Language';

  @override
  String get botSettingsDisclaimer => 'Disclaimer';

  @override
  String get botSettingsUseDisclaimer => 'Show disclaimer for yellow answers';

  @override
  String get botSettingsDisclaimerText => 'Disclaimer Text';

  @override
  String get botSettingsNoDisclaimer => 'No disclaimer maintained.';

  @override
  String get botSettingsEscalation => 'Escalation / Human Handover';

  @override
  String get botSettingsEscalateRedFlags => 'Always escalate red questions';

  @override
  String get botSettingsEscalateNoMatch => 'Send no-match questions to review';

  @override
  String get botSettingsEscalateYellowRisk => 'Send yellow answers to review';

  @override
  String get botSettingsHandoverMessage => 'Handover Message';

  @override
  String get botSettingsNoHandover => 'No handover message maintained.';

  @override
  String get botSettingsAllowedTopics => 'Allowed Topics';

  @override
  String get botSettingsBlockedTopics => 'Blocked Topics';

  @override
  String get botSettingsNoAllowedTopics => 'No allowed topics maintained yet.';

  @override
  String get botSettingsNoBlockedTopics => 'No blocked topics maintained yet.';

  @override
  String get botStatusDraft => 'Draft';

  @override
  String get botStatusTestReady => 'Test Ready';

  @override
  String get botStatusActive => 'Active';

  @override
  String get botAnswerStyleShort => 'Short';

  @override
  String get botAnswerStyleBalanced => 'Balanced';

  @override
  String get botAnswerStyleDetailed => 'Detailed';

  @override
  String get languageGerman => 'German';

  @override
  String get languageEnglish => 'English';
}
