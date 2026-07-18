import '../../models/action_record.dart';
import '../../models/bot_configuration.dart';
import '../../models/bot_question_log.dart';
import '../../models/business_audit.dart';
import '../../models/business_rules.dart';
import '../../models/business_strategy.dart';
import '../../models/companion_check_in.dart';
import '../../models/company.dart';
import '../../models/company_workspace.dart';
import '../../models/intake_invitation.dart';
import '../../models/intake_session.dart';
import '../../models/knowledge_entry.dart';
import '../../models/marketing_strategy.dart';
import '../../models/product_or_service.dart';
import '../../models/source_material.dart';

/// Explicit JSON codec for the persisted [CompanyWorkspace] graph.
///
/// Rules:
/// - enums are stored as their stable `.name` string; unknown values fall
///   back to a safe default instead of failing the whole record,
/// - `DateTime` is stored as ISO-8601 string,
/// - unknown/extra fields in stored data are ignored,
/// - missing optional fields fall back to model defaults.
///
/// Only a workspace without a company id is rejected ([FormatException]) —
/// such a record carries no usable identity and is skipped by the repository.
class WorkspaceCodec {
  const WorkspaceCodec._();

  static Map<String, Object?> encodeWorkspace(CompanyWorkspace workspace) {
    return _clean({
      'company': _encodeCompany(workspace.company),
      'products': [
        for (final product in workspace.products) _encodeProduct(product),
      ],
      'knowledgeEntries': [
        for (final entry in workspace.knowledgeEntries)
          _encodeKnowledgeEntry(entry),
      ],
      'botLogs': [for (final log in workspace.botLogs) _encodeBotLog(log)],
      'auditItems': [
        for (final item in workspace.auditItems) _encodeAuditItem(item),
      ],
      'businessRules': _encodeBusinessRules(workspace.businessRules),
      'botConfiguration': _encodeBotConfiguration(workspace.botConfiguration),
      'sourceMaterials': [
        for (final source in workspace.sourceMaterials)
          _encodeSourceMaterial(source),
      ],
      'marketingActions': [
        for (final action in workspace.marketingActions)
          _encodeMarketingAction(action),
      ],
      'businessGoals': [
        for (final goal in workspace.businessGoals) _encodeBusinessGoal(goal),
      ],
      'intakeSession': workspace.intakeSession == null
          ? null
          : _encodeIntakeSession(workspace.intakeSession!),
      'intakeInvitation': workspace.intakeInvitation == null
          ? null
          : _encodeIntakeInvitation(workspace.intakeInvitation!),
      'actionRecords': [
        for (final record in workspace.actionRecords)
          _encodeActionRecord(record),
      ],
      'checkIns': [
        for (final checkIn in workspace.checkIns) _encodeCheckIn(checkIn),
      ],
    });
  }

  static CompanyWorkspace decodeWorkspace(Map<String, Object?> json) {
    final company = _decodeCompany(_map(json, 'company'));
    final intakeJson = json['intakeSession'];
    final invitationJson = json['intakeInvitation'];
    return CompanyWorkspace(
      company: company,
      products: [
        for (final item in _mapList(json, 'products')) _decodeProduct(item),
      ],
      knowledgeEntries: [
        for (final item in _mapList(json, 'knowledgeEntries'))
          _decodeKnowledgeEntry(item),
      ],
      botLogs: [
        for (final item in _mapList(json, 'botLogs')) _decodeBotLog(item),
      ],
      auditItems: [
        for (final item in _mapList(json, 'auditItems')) _decodeAuditItem(item),
      ],
      businessRules: _decodeBusinessRules(_map(json, 'businessRules')),
      botConfiguration: _decodeBotConfiguration(_map(json, 'botConfiguration')),
      sourceMaterials: [
        for (final item in _mapList(json, 'sourceMaterials'))
          _decodeSourceMaterial(item),
      ],
      marketingActions: [
        for (final item in _mapList(json, 'marketingActions'))
          _decodeMarketingAction(item),
      ],
      businessGoals: [
        for (final item in _mapList(json, 'businessGoals'))
          _decodeBusinessGoal(item),
      ],
      intakeSession: intakeJson is Map
          ? _decodeIntakeSession(intakeJson.cast<String, Object?>())
          : null,
      intakeInvitation: invitationJson is Map
          ? _decodeIntakeInvitation(invitationJson.cast<String, Object?>())
          : null,
      // Added in schema version 2; absent in v1 data → empty history.
      actionRecords: [
        for (final item in _mapList(json, 'actionRecords'))
          _decodeActionRecord(item),
      ],
      // Added in schema version 3; absent in older data → no check-ins yet.
      checkIns: [
        for (final item in _mapList(json, 'checkIns')) _decodeCheckIn(item),
      ],
    );
  }

  static Map<String, Object?> encodeIntakeInvitation(
    IntakeInvitation invitation,
  ) => _encodeIntakeInvitation(invitation);

  static IntakeInvitation decodeIntakeInvitation(Map<String, Object?> json) =>
      _decodeIntakeInvitation(json);

  static Map<String, Object?> encodeIntakeSession(IntakeSession session) =>
      _encodeIntakeSession(session);

  static IntakeSession decodeIntakeSession(Map<String, Object?> json) =>
      _decodeIntakeSession(json);

  // --- CompanionCheckIn (companion rhythm) ---

  static Map<String, Object?> _encodeCheckIn(CompanionCheckIn checkIn) {
    return _clean({
      'id': checkIn.id,
      'workspaceId': checkIn.workspaceId,
      'periodStart': checkIn.periodStart.toIso8601String(),
      'periodEnd': checkIn.periodEnd.toIso8601String(),
      'createdAt': checkIn.createdAt.toIso8601String(),
      'completedAt': checkIn.completedAt?.toIso8601String(),
      'status': checkIn.status.name,
      'summary': checkIn.summary,
      'completedActionIds': checkIn.completedActionIds,
      'openActionIds': checkIn.openActionIds,
      'ratedActionIds': checkIn.ratedActionIds,
      'awaitingRatingActionIds': checkIn.awaitingRatingActionIds,
      'positiveOutcomes': checkIn.positiveOutcomes,
      'negativeOutcomes': checkIn.negativeOutcomes,
      'lessonsLearned': checkIn.lessonsLearned,
      'userNotes': checkIn.userNotes,
      'nextActionIds': checkIn.nextActionIds,
      'dataConfidence': checkIn.dataConfidence.name,
      'needsHumanReview': checkIn.needsHumanReview,
    });
  }

  static CompanionCheckIn _decodeCheckIn(Map<String, Object?> json) {
    return CompanionCheckIn(
      id: _string(json, 'id'),
      workspaceId: _string(json, 'workspaceId'),
      periodStart: _dateTime(json, 'periodStart'),
      periodEnd: _dateTime(json, 'periodEnd'),
      createdAt: _dateTime(json, 'createdAt'),
      completedAt: _dateTimeOrNull(json, 'completedAt'),
      status: _enum(CheckInStatus.values, json['status'], CheckInStatus.draft),
      summary: _string(json, 'summary'),
      completedActionIds: _stringList(json, 'completedActionIds'),
      openActionIds: _stringList(json, 'openActionIds'),
      ratedActionIds: _stringList(json, 'ratedActionIds'),
      awaitingRatingActionIds: _stringList(json, 'awaitingRatingActionIds'),
      positiveOutcomes: _stringList(json, 'positiveOutcomes'),
      negativeOutcomes: _stringList(json, 'negativeOutcomes'),
      lessonsLearned: _stringList(json, 'lessonsLearned'),
      userNotes: _string(json, 'userNotes'),
      nextActionIds: _stringList(json, 'nextActionIds'),
      dataConfidence: _enum(
        CheckInDataConfidence.values,
        json['dataConfidence'],
        CheckInDataConfidence.low,
      ),
      needsHumanReview: _bool(json, 'needsHumanReview', false),
    );
  }

  // --- ActionRecord (company memory) ---

  static Map<String, Object?> _encodeActionRecord(ActionRecord record) {
    return _clean({
      'id': record.id,
      'actionType': record.actionType,
      'titleSnapshot': record.titleSnapshot,
      'descriptionSnapshot': record.descriptionSnapshot,
      'status': record.status.name,
      'createdAt': record.createdAt.toIso8601String(),
      'acceptedAt': record.acceptedAt?.toIso8601String(),
      'startedAt': record.startedAt?.toIso8601String(),
      'completedAt': record.completedAt?.toIso8601String(),
      'deferredUntil': record.deferredUntil?.toIso8601String(),
      'declinedAt': record.declinedAt?.toIso8601String(),
      'declineReason': record.declineReason,
      'resultRating': record.resultRating?.name,
      'resultNote': record.resultNote,
      'expectedImpact': record.expectedImpact,
      'actualOutcome': record.actualOutcome,
      'repeatRequested': record.repeatRequested,
      'relatedGoalIds': record.relatedGoalIds,
      'sourceReasonKeys': record.sourceReasonKeys,
    });
  }

  static ActionRecord _decodeActionRecord(Map<String, Object?> json) {
    return ActionRecord(
      id: _string(json, 'id'),
      actionType: _string(json, 'actionType'),
      titleSnapshot: _string(json, 'titleSnapshot'),
      descriptionSnapshot: _string(json, 'descriptionSnapshot'),
      status: _enum(
        ActionRecordStatus.values,
        json['status'],
        ActionRecordStatus.suggested,
      ),
      createdAt: _dateTime(json, 'createdAt'),
      acceptedAt: _dateTimeOrNull(json, 'acceptedAt'),
      startedAt: _dateTimeOrNull(json, 'startedAt'),
      completedAt: _dateTimeOrNull(json, 'completedAt'),
      deferredUntil: _dateTimeOrNull(json, 'deferredUntil'),
      declinedAt: _dateTimeOrNull(json, 'declinedAt'),
      declineReason: _stringOrNull(json, 'declineReason'),
      resultRating: _enumOrNull(
        ActionResultRating.values,
        json['resultRating'],
      ),
      resultNote: _stringOrNull(json, 'resultNote'),
      expectedImpact: _string(json, 'expectedImpact'),
      actualOutcome: _stringOrNull(json, 'actualOutcome'),
      repeatRequested: _boolOrNull(json, 'repeatRequested'),
      relatedGoalIds: _stringList(json, 'relatedGoalIds'),
      sourceReasonKeys: _stringList(json, 'sourceReasonKeys'),
    );
  }

  // --- Company ---

  static Map<String, Object?> _encodeCompany(Company company) {
    return _clean({
      'id': company.id,
      'name': company.name,
      'industry': company.industry,
      'description': company.description,
      'country': company.country,
      'primaryLanguage': company.primaryLanguage,
      'website': company.website,
      'email': company.email,
      'phone': company.phone,
      'address': company.address,
      'socialLinks': company.socialLinks,
      'internalNotes': company.internalNotes,
    });
  }

  static Company _decodeCompany(Map<String, Object?> json) {
    final id = _string(json, 'id');
    if (id.isEmpty) {
      throw const FormatException('Workspace record has no company id');
    }
    return Company(
      id: id,
      name: _string(json, 'name'),
      industry: _string(json, 'industry'),
      description: _string(json, 'description'),
      country: _string(json, 'country'),
      primaryLanguage: _string(json, 'primaryLanguage', 'de'),
      website: _string(json, 'website'),
      email: _string(json, 'email'),
      phone: _stringOrNull(json, 'phone'),
      address: _string(json, 'address'),
      socialLinks: _stringMap(json, 'socialLinks'),
      internalNotes: _string(json, 'internalNotes'),
    );
  }

  // --- ProductOrService ---

  static Map<String, Object?> _encodeProduct(ProductOrService product) {
    return _clean({
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'type': product.type.name,
      'price': product.price,
    });
  }

  static ProductOrService _decodeProduct(Map<String, Object?> json) {
    return ProductOrService(
      id: _string(json, 'id'),
      name: _string(json, 'name'),
      description: _string(json, 'description'),
      type: _enum(ProductType.values, json['type'], ProductType.produkt),
      price: _doubleOrNull(json, 'price'),
    );
  }

  // --- KnowledgeEntry ---

  static Map<String, Object?> _encodeKnowledgeEntry(KnowledgeEntry entry) {
    return _clean({
      'id': entry.id,
      'title': entry.title,
      'content': entry.content,
      'category': entry.category.name,
      'riskLevel': entry.riskLevel.name,
      'keywords': entry.keywords,
      'source': entry.source,
      'createdAt': entry.createdAt.toIso8601String(),
      'languageCode': entry.languageCode,
    });
  }

  static KnowledgeEntry _decodeKnowledgeEntry(Map<String, Object?> json) {
    return KnowledgeEntry(
      id: _string(json, 'id'),
      title: _string(json, 'title'),
      content: _string(json, 'content'),
      category: _enum(
        KnowledgeCategory.values,
        json['category'],
        KnowledgeCategory.allgemein,
      ),
      riskLevel: _enum(RiskLevel.values, json['riskLevel'], RiskLevel.yellow),
      keywords: _stringList(json, 'keywords'),
      source: _string(json, 'source'),
      createdAt: _dateTime(json, 'createdAt'),
      languageCode: _stringOrNull(json, 'languageCode'),
    );
  }

  // --- BotQuestionLog ---

  static Map<String, Object?> _encodeBotLog(BotQuestionLog log) {
    return _clean({
      'id': log.id,
      'question': log.question,
      'answer': log.answer,
      'matched': log.matched,
      'redirected': log.redirected,
      'timestamp': log.timestamp.toIso8601String(),
      'reviewStatus': log.reviewStatus.name,
      'reviewReason': log.reviewReason?.name,
      'humanNote': log.humanNote,
      'reviewedAt': log.reviewedAt?.toIso8601String(),
    });
  }

  static BotQuestionLog _decodeBotLog(Map<String, Object?> json) {
    return BotQuestionLog(
      id: _string(json, 'id'),
      question: _string(json, 'question'),
      answer: _stringOrNull(json, 'answer'),
      matched: _bool(json, 'matched', false),
      redirected: _bool(json, 'redirected', false),
      timestamp: _dateTime(json, 'timestamp'),
      reviewStatus: _enum(
        ReviewStatus.values,
        json['reviewStatus'],
        ReviewStatus.closed,
      ),
      reviewReason: _enumOrNull(ReviewReason.values, json['reviewReason']),
      humanNote: _stringOrNull(json, 'humanNote'),
      reviewedAt: _dateTimeOrNull(json, 'reviewedAt'),
    );
  }

  // --- BusinessAuditItem ---

  static Map<String, Object?> _encodeAuditItem(BusinessAuditItem item) {
    return _clean({
      'id': item.id,
      'area': item.area.name,
      'title': item.title,
      'description': item.description,
      'status': item.status.name,
      'priority': item.priority.name,
      'note': item.note,
      'recommendation': item.recommendation,
    });
  }

  static BusinessAuditItem _decodeAuditItem(Map<String, Object?> json) {
    return BusinessAuditItem(
      id: _string(json, 'id'),
      area: _enum(AuditArea.values, json['area'], AuditArea.companyProfile),
      title: _string(json, 'title'),
      description: _string(json, 'description'),
      status: _enum(
        AuditItemStatus.values,
        json['status'],
        AuditItemStatus.missing,
      ),
      priority: _enum(
        AuditPriority.values,
        json['priority'],
        AuditPriority.medium,
      ),
      note: _stringOrNull(json, 'note'),
      recommendation: _stringOrNull(json, 'recommendation'),
    );
  }

  // --- BusinessRules ---

  static Map<String, Object?> _encodeBusinessRules(BusinessRules rules) {
    return _clean({
      'brandVoice': rules.brandVoice,
      'doNotSay': rules.doNotSay,
      'allowedSupportTopics': rules.allowedSupportTopics,
      'escalationNotes': rules.escalationNotes,
      'disclaimerText': rules.disclaimerText,
    });
  }

  static BusinessRules _decodeBusinessRules(Map<String, Object?> json) {
    return BusinessRules(
      brandVoice: _string(json, 'brandVoice'),
      doNotSay: _stringList(json, 'doNotSay'),
      allowedSupportTopics: _stringList(json, 'allowedSupportTopics'),
      escalationNotes: _string(json, 'escalationNotes'),
      disclaimerText: _stringOrNull(json, 'disclaimerText'),
    );
  }

  // --- BotConfiguration ---

  static Map<String, Object?> _encodeBotConfiguration(BotConfiguration config) {
    return _clean({
      'status': config.status.name,
      'answerStyle': config.answerStyle.name,
      'defaultLanguage': config.defaultLanguage,
      'useDisclaimer': config.useDisclaimer,
      'disclaimerText': config.disclaimerText,
      'alwaysEscalateRedFlags': config.alwaysEscalateRedFlags,
      'escalateNoMatch': config.escalateNoMatch,
      'escalateYellowRisk': config.escalateYellowRisk,
      'allowedTopics': config.allowedTopics,
      'blockedTopics': config.blockedTopics,
      'handoverMessage': config.handoverMessage,
    });
  }

  static BotConfiguration _decodeBotConfiguration(Map<String, Object?> json) {
    return BotConfiguration(
      status: _enum(BotStatus.values, json['status'], BotStatus.draft),
      answerStyle: _enum(
        BotAnswerStyle.values,
        json['answerStyle'],
        BotAnswerStyle.balanced,
      ),
      defaultLanguage: _string(json, 'defaultLanguage', 'de'),
      useDisclaimer: _bool(json, 'useDisclaimer', false),
      disclaimerText: _string(json, 'disclaimerText'),
      alwaysEscalateRedFlags: _bool(json, 'alwaysEscalateRedFlags', true),
      escalateNoMatch: _bool(json, 'escalateNoMatch', true),
      escalateYellowRisk: _bool(json, 'escalateYellowRisk', false),
      allowedTopics: _stringList(json, 'allowedTopics'),
      blockedTopics: _stringList(json, 'blockedTopics'),
      handoverMessage: _string(json, 'handoverMessage'),
    );
  }

  // --- SourceMaterial ---

  static Map<String, Object?> _encodeSourceMaterial(SourceMaterial source) {
    return _clean({
      'id': source.id,
      'title': source.title,
      'type': source.type.name,
      'url': source.url,
      'contentSnippet': source.contentSnippet,
      'status': source.status.name,
      'relatedKnowledgeEntryIds': source.relatedKnowledgeEntryIds,
      'createdAt': source.createdAt.toIso8601String(),
      'updatedAt': source.updatedAt.toIso8601String(),
      'notes': source.notes,
    });
  }

  static SourceMaterial _decodeSourceMaterial(Map<String, Object?> json) {
    return SourceMaterial(
      id: _string(json, 'id'),
      title: _string(json, 'title'),
      type: _enum(
        SourceMaterialType.values,
        json['type'],
        SourceMaterialType.other,
      ),
      url: _stringOrNull(json, 'url'),
      contentSnippet: _stringOrNull(json, 'contentSnippet'),
      status: _enum(
        SourceMaterialStatus.values,
        json['status'],
        SourceMaterialStatus.newItem,
      ),
      relatedKnowledgeEntryIds: _stringList(json, 'relatedKnowledgeEntryIds'),
      createdAt: _dateTime(json, 'createdAt'),
      updatedAt: _dateTime(json, 'updatedAt'),
      notes: _stringOrNull(json, 'notes'),
    );
  }

  // --- MarketingAction ---

  static Map<String, Object?> _encodeMarketingAction(MarketingAction action) {
    return _clean({
      'id': action.id,
      'type': action.type.name,
      'priority': action.priority.name,
      'effort': action.effort.name,
      'impact': action.impact.name,
      'status': action.status.name,
      'notes': action.notes,
      'plannedBudget': action.plannedBudget,
      'usedBudget': action.usedBudget,
      'budgetComment': action.budgetComment,
    });
  }

  static MarketingAction _decodeMarketingAction(Map<String, Object?> json) {
    return MarketingAction(
      id: _string(json, 'id'),
      type: _enum(
        MarketingActionType.values,
        json['type'],
        MarketingActionType.optimizeWebsite,
      ),
      priority: _enum(
        MarketingActionPriority.values,
        json['priority'],
        MarketingActionPriority.medium,
      ),
      effort: _enum(
        MarketingActionEffort.values,
        json['effort'],
        MarketingActionEffort.medium,
      ),
      impact: _enum(
        MarketingActionImpact.values,
        json['impact'],
        MarketingActionImpact.medium,
      ),
      status: _enum(
        MarketingActionStatus.values,
        json['status'],
        MarketingActionStatus.notStarted,
      ),
      notes: _string(json, 'notes'),
      plannedBudget: _doubleOrNull(json, 'plannedBudget'),
      usedBudget: _doubleOrNull(json, 'usedBudget'),
      budgetComment: _string(json, 'budgetComment'),
    );
  }

  // --- BusinessGoal ---

  static Map<String, Object?> _encodeBusinessGoal(BusinessGoal goal) {
    return _clean({
      'id': goal.id,
      'title': goal.title,
      'description': goal.description,
      'priority': goal.priority.name,
      'startDate': goal.startDate.toIso8601String(),
      'targetDate': goal.targetDate.toIso8601String(),
      'status': goal.status.name,
      'owner': goal.owner,
      'comment': goal.comment,
      'linkedAreas': [for (final area in goal.linkedAreas) area.name],
    });
  }

  static BusinessGoal _decodeBusinessGoal(Map<String, Object?> json) {
    return BusinessGoal(
      id: _string(json, 'id'),
      title: _string(json, 'title'),
      description: _string(json, 'description'),
      priority: _enum(
        BusinessGoalPriority.values,
        json['priority'],
        BusinessGoalPriority.medium,
      ),
      startDate: _dateTime(json, 'startDate'),
      targetDate: _dateTime(json, 'targetDate'),
      status: _enum(
        BusinessGoalStatus.values,
        json['status'],
        BusinessGoalStatus.notStarted,
      ),
      owner: _string(json, 'owner'),
      comment: _string(json, 'comment'),
      linkedAreas: [
        for (final raw in _stringList(json, 'linkedAreas'))
          if (_enumOrNull(BusinessGoalArea.values, raw) != null)
            _enumOrNull(BusinessGoalArea.values, raw)!,
      ],
    );
  }

  // --- IntakeSession ---

  static Map<String, Object?> _encodeIntakeInvitation(
    IntakeInvitation invitation,
  ) {
    return _clean({
      'token': invitation.token,
      'id': invitation.id,
      'status': invitation.status.name,
      'greeting': invitation.greeting,
      'createdAt': invitation.createdAt.toIso8601String(),
      'updatedAt': invitation.updatedAt.toIso8601String(),
      'startedAt': invitation.startedAt?.toIso8601String(),
      'completedAt': invitation.completedAt?.toIso8601String(),
      'disabledAt': invitation.disabledAt?.toIso8601String(),
    });
  }

  static IntakeInvitation _decodeIntakeInvitation(Map<String, Object?> json) {
    return IntakeInvitation(
      id: _string(json, 'id'),
      token: _string(json, 'token'),
      status: _enum(
        IntakeInvitationStatus.values,
        json['status'],
        IntakeInvitationStatus.invited,
      ),
      greeting: _string(json, 'greeting'),
      createdAt: _dateTime(json, 'createdAt'),
      updatedAt: _dateTime(json, 'updatedAt'),
      startedAt: _dateTimeOrNull(json, 'startedAt'),
      completedAt: _dateTimeOrNull(json, 'completedAt'),
      disabledAt: _dateTimeOrNull(json, 'disabledAt'),
    );
  }

  static Map<String, Object?> _encodeIntakeSession(IntakeSession session) {
    return _clean({
      'id': session.id,
      'companyId': session.companyId,
      'status': session.status.name,
      'currentStepIndex': session.currentStepIndex,
      'createdAt': session.createdAt.toIso8601String(),
      'updatedAt': session.updatedAt.toIso8601String(),
      'importedAt': session.importedAt?.toIso8601String(),
      'chatStartedAt': session.chatStartedAt?.toIso8601String(),
      'chatUpdatedAt': session.chatUpdatedAt?.toIso8601String(),
      'chatCompletedAt': session.chatCompletedAt?.toIso8601String(),
      'chatCurrentQuestionIndex': session.chatCurrentQuestionIndex,
      'skippedQuestionKeys': session.skippedQuestionKeys,
      'deferredQuestionKeys': session.deferredQuestionKeys,
      'basics': _encodeIntakeBasics(session.basics),
      'products': _encodeIntakeProducts(session.products),
      'targetGroups': _encodeIntakeTargetGroups(session.targetGroups),
      'websiteAndSupport': _encodeIntakeWebsiteAndSupport(
        session.websiteAndSupport,
      ),
      'sourcesAndReviews': _encodeIntakeSourcesAndReviews(
        session.sourcesAndReviews,
      ),
      'marketingAndChannels': _encodeIntakeMarketingAndChannels(
        session.marketingAndChannels,
      ),
      'goalsAndRisks': _encodeIntakeGoalsAndRisks(session.goalsAndRisks),
    });
  }

  static IntakeSession _decodeIntakeSession(Map<String, Object?> json) {
    return IntakeSession(
      id: _string(json, 'id'),
      companyId: _string(json, 'companyId'),
      status: _enum(IntakeStatus.values, json['status'], IntakeStatus.draft),
      currentStepIndex: _int(json, 'currentStepIndex', 0),
      createdAt: _dateTime(json, 'createdAt'),
      updatedAt: _dateTime(json, 'updatedAt'),
      importedAt: _dateTimeOrNull(json, 'importedAt'),
      chatStartedAt: _dateTimeOrNull(json, 'chatStartedAt'),
      chatUpdatedAt: _dateTimeOrNull(json, 'chatUpdatedAt'),
      chatCompletedAt: _dateTimeOrNull(json, 'chatCompletedAt'),
      chatCurrentQuestionIndex: _int(json, 'chatCurrentQuestionIndex', 0),
      skippedQuestionKeys: _stringList(json, 'skippedQuestionKeys'),
      deferredQuestionKeys: _stringList(json, 'deferredQuestionKeys'),
      basics: _decodeIntakeBasics(_map(json, 'basics')),
      products: _decodeIntakeProducts(_map(json, 'products')),
      targetGroups: _decodeIntakeTargetGroups(_map(json, 'targetGroups')),
      websiteAndSupport: _decodeIntakeWebsiteAndSupport(
        _map(json, 'websiteAndSupport'),
      ),
      sourcesAndReviews: _decodeIntakeSourcesAndReviews(
        _map(json, 'sourcesAndReviews'),
      ),
      marketingAndChannels: _decodeIntakeMarketingAndChannels(
        _map(json, 'marketingAndChannels'),
      ),
      goalsAndRisks: _decodeIntakeGoalsAndRisks(_map(json, 'goalsAndRisks')),
    );
  }

  static Map<String, Object?> _encodeIntakeBasics(IntakeBasics basics) {
    return _clean({
      'companyName': basics.companyName,
      'shortDescription': basics.shortDescription,
      'industry': basics.industry,
      'country': basics.country,
      'primaryLanguage': basics.primaryLanguage,
      'website': basics.website,
      'supportEmail': basics.supportEmail,
      'supportPhone': basics.supportPhone,
      'hasWebsite': basics.hasWebsite,
      'additionalLanguages': basics.additionalLanguages,
      'targetRegions': basics.targetRegions,
    });
  }

  static IntakeBasics _decodeIntakeBasics(Map<String, Object?> json) {
    return IntakeBasics(
      companyName: _string(json, 'companyName'),
      shortDescription: _string(json, 'shortDescription'),
      industry: _string(json, 'industry'),
      country: _string(json, 'country'),
      primaryLanguage: _string(json, 'primaryLanguage'),
      website: _string(json, 'website'),
      supportEmail: _string(json, 'supportEmail'),
      supportPhone: _string(json, 'supportPhone'),
      hasWebsite: _boolOrNull(json, 'hasWebsite'),
      additionalLanguages: _string(json, 'additionalLanguages'),
      targetRegions: _string(json, 'targetRegions'),
    );
  }

  static Map<String, Object?> _encodeIntakeProducts(IntakeProducts products) {
    return _clean({
      'importantProducts': products.importantProducts,
      'mainProduct': products.mainProduct,
      'explanationNeeded': products.explanationNeeded,
      'priorityProducts': products.priorityProducts,
    });
  }

  static IntakeProducts _decodeIntakeProducts(Map<String, Object?> json) {
    return IntakeProducts(
      importantProducts: _string(json, 'importantProducts'),
      mainProduct: _string(json, 'mainProduct'),
      explanationNeeded: _string(json, 'explanationNeeded'),
      priorityProducts: _string(json, 'priorityProducts'),
    );
  }

  static Map<String, Object?> _encodeIntakeTargetGroups(
    IntakeTargetGroups targetGroups,
  ) {
    return _clean({
      'targetGroup': targetGroups.targetGroup,
      'marketType': targetGroups.marketType,
      'problemSolved': targetGroups.problemSolved,
      'customerBenefit': targetGroups.customerBenefit,
      'differentiation': targetGroups.differentiation,
    });
  }

  static IntakeTargetGroups _decodeIntakeTargetGroups(
    Map<String, Object?> json,
  ) {
    return IntakeTargetGroups(
      targetGroup: _string(json, 'targetGroup'),
      marketType: _string(json, 'marketType'),
      problemSolved: _string(json, 'problemSolved'),
      customerBenefit: _string(json, 'customerBenefit'),
      differentiation: _string(json, 'differentiation'),
    );
  }

  static Map<String, Object?> _encodeIntakeWebsiteAndSupport(
    IntakeWebsiteAndSupport value,
  ) {
    return _clean({
      'websiteUrl': value.websiteUrl,
      'hasShop': value.hasShop,
      'shopUrl': value.shopUrl,
      'hasFaqArea': value.hasFaqArea,
      'faqUrl': value.faqUrl,
      'websiteMaintainer': value.websiteMaintainer,
      'canEditWebsiteQuickly': value.canEditWebsiteQuickly,
      'websitePlanned': value.websitePlanned,
      'importantPages': value.importantPages,
      'frequentQuestions': value.frequentQuestions,
      'hasSupportQuestions': value.hasSupportQuestions,
      'supportChannels': value.supportChannels,
      'preSalesQuestions': value.preSalesQuestions,
      'afterSalesQuestions': value.afterSalesQuestions,
      'technicalProblems': value.technicalProblems,
      'complaintsOrMisunderstandings': value.complaintsOrMisunderstandings,
      'supportOwner': value.supportOwner,
      'standardizableQuestions': value.standardizableQuestions,
      'supportProblems': value.supportProblems,
      'sensitiveTopics': value.sensitiveTopics,
      'hasSensitiveTopics': value.hasSensitiveTopics,
    });
  }

  static IntakeWebsiteAndSupport _decodeIntakeWebsiteAndSupport(
    Map<String, Object?> json,
  ) {
    return IntakeWebsiteAndSupport(
      websiteUrl: _string(json, 'websiteUrl'),
      hasShop: _boolOrNull(json, 'hasShop'),
      shopUrl: _string(json, 'shopUrl'),
      hasFaqArea: _boolOrNull(json, 'hasFaqArea'),
      faqUrl: _string(json, 'faqUrl'),
      websiteMaintainer: _string(json, 'websiteMaintainer'),
      canEditWebsiteQuickly: _boolOrNull(json, 'canEditWebsiteQuickly'),
      websitePlanned: _string(json, 'websitePlanned'),
      importantPages: _string(json, 'importantPages'),
      frequentQuestions: _string(json, 'frequentQuestions'),
      hasSupportQuestions: _boolOrNull(json, 'hasSupportQuestions'),
      supportChannels: _string(json, 'supportChannels'),
      preSalesQuestions: _string(json, 'preSalesQuestions'),
      afterSalesQuestions: _string(json, 'afterSalesQuestions'),
      technicalProblems: _string(json, 'technicalProblems'),
      complaintsOrMisunderstandings: _string(
        json,
        'complaintsOrMisunderstandings',
      ),
      supportOwner: _string(json, 'supportOwner'),
      standardizableQuestions: _string(json, 'standardizableQuestions'),
      supportProblems: _string(json, 'supportProblems'),
      sensitiveTopics: _string(json, 'sensitiveTopics'),
      hasSensitiveTopics: _boolOrNull(json, 'hasSensitiveTopics'),
    );
  }

  static Map<String, Object?> _encodeIntakeSourcesAndReviews(
    IntakeSourcesAndReviews value,
  ) {
    return _clean({
      'existingSources': value.existingSources,
      'hasMaterials': value.hasMaterials,
      'materialDetails': value.materialDetails,
      'materialLocations': value.materialLocations,
      'materialFreshness': value.materialFreshness,
      'importantMaterials': value.importantMaterials,
      'materialsUsableForKnowledgeBase': value.materialsUsableForKnowledgeBase,
      'reviews': value.reviews,
      'reviewPlatforms': value.reviewPlatforms,
      'reviewCountEstimate': value.reviewCountEstimate,
      'reviewLinksOrFiles': value.reviewLinksOrFiles,
      'reviewTypes': value.reviewTypes,
      'reviewsPubliclyUsable': value.reviewsPubliclyUsable,
      'reviewsEmbeddedOnWebsite': value.reviewsEmbeddedOnWebsite,
      'collectReviewsPlanned': value.collectReviewsPlanned,
      'socialMentions': value.socialMentions,
      'trustMaterial': value.trustMaterial,
      'hasReviews': value.hasReviews,
      'hasSocialMentions': value.hasSocialMentions,
      'hasTrustMaterial': value.hasTrustMaterial,
    });
  }

  static IntakeSourcesAndReviews _decodeIntakeSourcesAndReviews(
    Map<String, Object?> json,
  ) {
    return IntakeSourcesAndReviews(
      existingSources: _string(json, 'existingSources'),
      hasMaterials: _boolOrNull(json, 'hasMaterials'),
      materialDetails: _string(json, 'materialDetails'),
      materialLocations: _string(json, 'materialLocations'),
      materialFreshness: _string(json, 'materialFreshness'),
      importantMaterials: _string(json, 'importantMaterials'),
      materialsUsableForKnowledgeBase: _boolOrNull(
        json,
        'materialsUsableForKnowledgeBase',
      ),
      reviews: _string(json, 'reviews'),
      reviewPlatforms: _string(json, 'reviewPlatforms'),
      reviewCountEstimate: _string(json, 'reviewCountEstimate'),
      reviewLinksOrFiles: _string(json, 'reviewLinksOrFiles'),
      reviewTypes: _string(json, 'reviewTypes'),
      reviewsPubliclyUsable: _boolOrNull(json, 'reviewsPubliclyUsable'),
      reviewsEmbeddedOnWebsite: _boolOrNull(json, 'reviewsEmbeddedOnWebsite'),
      collectReviewsPlanned: _string(json, 'collectReviewsPlanned'),
      socialMentions: _string(json, 'socialMentions'),
      trustMaterial: _string(json, 'trustMaterial'),
      hasReviews: _boolOrNull(json, 'hasReviews'),
      hasSocialMentions: _boolOrNull(json, 'hasSocialMentions'),
      hasTrustMaterial: _boolOrNull(json, 'hasTrustMaterial'),
    );
  }

  static Map<String, Object?> _encodeIntakeMarketingAndChannels(
    IntakeMarketingAndChannels value,
  ) {
    return _clean({
      'hasSocialChannels': value.hasSocialChannels,
      'socialPlatforms': value.socialPlatforms,
      'socialProfileLinks': value.socialProfileLinks,
      'activeChannels': value.activeChannels,
      'inactiveChannels': value.inactiveChannels,
      'postingFrequency': value.postingFrequency,
      'workingChannels': value.workingChannels,
      'futureSocialPlatforms': value.futureSocialPlatforms,
      'hasRunAds': value.hasRunAds,
      'advertisingChannels': value.advertisingChannels,
      'approximateBudget': value.approximateBudget,
      'successfulMeasures': value.successfulMeasures,
      'unsuccessfulMeasures': value.unsuccessfulMeasures,
      'availableMetrics': value.availableMetrics,
      'adAccountAccess': value.adAccountAccess,
      'futureAdChannels': value.futureAdChannels,
      'channels': value.channels,
      'campaigns': value.campaigns,
      'worked': value.worked,
      'notWorked': value.notWorked,
      'reachProblems': value.reachProblems,
    });
  }

  static IntakeMarketingAndChannels _decodeIntakeMarketingAndChannels(
    Map<String, Object?> json,
  ) {
    return IntakeMarketingAndChannels(
      hasSocialChannels: _boolOrNull(json, 'hasSocialChannels'),
      socialPlatforms: _string(json, 'socialPlatforms'),
      socialProfileLinks: _string(json, 'socialProfileLinks'),
      activeChannels: _string(json, 'activeChannels'),
      inactiveChannels: _string(json, 'inactiveChannels'),
      postingFrequency: _string(json, 'postingFrequency'),
      workingChannels: _string(json, 'workingChannels'),
      futureSocialPlatforms: _string(json, 'futureSocialPlatforms'),
      hasRunAds: _boolOrNull(json, 'hasRunAds'),
      advertisingChannels: _string(json, 'advertisingChannels'),
      approximateBudget: _string(json, 'approximateBudget'),
      successfulMeasures: _string(json, 'successfulMeasures'),
      unsuccessfulMeasures: _string(json, 'unsuccessfulMeasures'),
      availableMetrics: _string(json, 'availableMetrics'),
      adAccountAccess: _string(json, 'adAccountAccess'),
      futureAdChannels: _string(json, 'futureAdChannels'),
      channels: _string(json, 'channels'),
      campaigns: _string(json, 'campaigns'),
      worked: _string(json, 'worked'),
      notWorked: _string(json, 'notWorked'),
      reachProblems: _string(json, 'reachProblems'),
    );
  }

  static Map<String, Object?> _encodeIntakeGoalsAndRisks(
    IntakeGoalsAndRisks value,
  ) {
    return _clean({
      'hasSensitiveTopics': value.hasSensitiveTopics,
      'sensitiveTopics': value.sensitiveTopics,
      'companyGoals': value.companyGoals,
      'shortTermPriorities': value.shortTermPriorities,
      'prohibitedStatements': value.prohibitedStatements,
      'forbiddenClaims': value.forbiddenClaims,
      'botRestrictedTopics': value.botRestrictedTopics,
      'alwaysEscalateTopics': value.alwaysEscalateTopics,
      'legalRestrictions': value.legalRestrictions,
    });
  }

  static IntakeGoalsAndRisks _decodeIntakeGoalsAndRisks(
    Map<String, Object?> json,
  ) {
    return IntakeGoalsAndRisks(
      hasSensitiveTopics: _boolOrNull(json, 'hasSensitiveTopics'),
      sensitiveTopics: _string(json, 'sensitiveTopics'),
      companyGoals: _string(json, 'companyGoals'),
      shortTermPriorities: _string(json, 'shortTermPriorities'),
      prohibitedStatements: _string(json, 'prohibitedStatements'),
      forbiddenClaims: _string(json, 'forbiddenClaims'),
      botRestrictedTopics: _string(json, 'botRestrictedTopics'),
      alwaysEscalateTopics: _string(json, 'alwaysEscalateTopics'),
      legalRestrictions: _string(json, 'legalRestrictions'),
    );
  }

  // --- tolerant read helpers ---

  static Map<String, Object?> _clean(Map<String, Object?> map) {
    map.removeWhere((_, value) => value == null);
    return map;
  }

  static Map<String, Object?> _map(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is Map) return value.cast<String, Object?>();
    return const {};
  }

  static List<Map<String, Object?>> _mapList(
    Map<String, Object?> json,
    String key,
  ) {
    final value = json[key];
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is Map) item.cast<String, Object?>(),
    ];
  }

  static String _string(
    Map<String, Object?> json,
    String key, [
    String fallback = '',
  ]) {
    final value = json[key];
    return value is String ? value : fallback;
  }

  static String? _stringOrNull(Map<String, Object?> json, String key) {
    final value = json[key];
    return value is String ? value : null;
  }

  static List<String> _stringList(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is String) item,
    ];
  }

  static Map<String, String> _stringMap(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! Map) return const {};
    return {
      for (final entry in value.entries)
        if (entry.key is String && entry.value is String)
          entry.key as String: entry.value as String,
    };
  }

  static bool _bool(Map<String, Object?> json, String key, bool fallback) {
    final value = json[key];
    return value is bool ? value : fallback;
  }

  static bool? _boolOrNull(Map<String, Object?> json, String key) {
    final value = json[key];
    return value is bool ? value : null;
  }

  static int _int(Map<String, Object?> json, String key, int fallback) {
    final value = json[key];
    return value is int ? value : fallback;
  }

  static double? _doubleOrNull(Map<String, Object?> json, String key) {
    final value = json[key];
    return value is num ? value.toDouble() : null;
  }

  static DateTime _dateTime(Map<String, Object?> json, String key) {
    return _dateTimeOrNull(json, key) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _dateTimeOrNull(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! String) return null;
    return DateTime.tryParse(value);
  }

  static T _enum<T extends Enum>(List<T> values, Object? raw, T fallback) {
    return _enumOrNull(values, raw) ?? fallback;
  }

  static T? _enumOrNull<T extends Enum>(List<T> values, Object? raw) {
    if (raw is! String) return null;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}
