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
