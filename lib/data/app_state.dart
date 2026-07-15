import 'package:flutter/widgets.dart';
import '../models/business_audit.dart';
import '../models/business_rules.dart';
import '../models/bot_configuration.dart';
import '../models/company.dart';
import '../models/company_workspace.dart';
import '../models/product_or_service.dart';
import '../models/knowledge_entry.dart';
import '../models/bot_question_log.dart';
import '../models/project_status.dart';
import '../models/source_material.dart';
import '../models/intake_session.dart';
import '../models/intake_mapping_preview.dart';
import 'mock_data.dart';

enum CompanyProfileStatus { incomplete, partial, complete }

class AppState extends ChangeNotifier {
  List<CompanyWorkspace> companies = MockData.companyWorkspaces
      .map(
        (workspace) => workspace.copyWith(
          products: List.from(workspace.products),
          knowledgeEntries: List.from(workspace.knowledgeEntries),
          botLogs: List.from(workspace.botLogs),
          auditItems: List.from(workspace.auditItems),
          sourceMaterials: List.from(workspace.sourceMaterials),
          intakeSession: workspace.intakeSession,
        ),
      )
      .toList();

  String selectedCompanyId = MockData.companyWorkspaces.first.company.id;

  CompanyWorkspace get selectedWorkspace {
    return companies.firstWhere(
      (workspace) => workspace.company.id == selectedCompanyId,
      orElse: () => companies.first,
    );
  }

  Company get selectedCompany => selectedWorkspace.company;
  List<ProductOrService> get selectedProducts => selectedWorkspace.products;
  List<KnowledgeEntry> get selectedKnowledgeEntries =>
      selectedWorkspace.knowledgeEntries;
  List<BotQuestionLog> get selectedBotLogs => selectedWorkspace.botLogs;
  List<BusinessAuditItem> get selectedAuditItems =>
      selectedWorkspace.auditItems;
  BusinessRules get selectedBusinessRules => selectedWorkspace.businessRules;
  BotConfiguration get selectedBotConfiguration =>
      selectedWorkspace.botConfiguration;
  List<SourceMaterial> get selectedSourceMaterials =>
      selectedWorkspace.sourceMaterials;
  IntakeSession? get selectedIntakeSession => selectedWorkspace.intakeSession;

  Company get company => selectedCompany;
  List<ProductOrService> get products => selectedProducts;
  List<KnowledgeEntry> get knowledgeEntries => selectedKnowledgeEntries;
  List<BotQuestionLog> get botLogs => selectedBotLogs;
  List<BusinessAuditItem> get auditItems => selectedAuditItems;
  BusinessRules get businessRules => selectedBusinessRules;
  BotConfiguration get botConfiguration => selectedBotConfiguration;
  List<SourceMaterial> get sourceMaterials => selectedSourceMaterials;
  IntakeSession? get intakeSession => selectedIntakeSession;

  void selectCompany(String companyId) {
    if (selectedCompanyId == companyId) return;
    if (!companies.any((workspace) => workspace.company.id == companyId)) {
      return;
    }
    selectedCompanyId = companyId;
    notifyListeners();
  }

  void updateCompany(Company updated) {
    _updateSelectedWorkspace(selectedWorkspace.copyWith(company: updated));
    notifyListeners();
  }

  void updateBusinessRules(BusinessRules updated) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(businessRules: updated),
    );
    notifyListeners();
  }

  void updateBotConfiguration(BotConfiguration updated) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(botConfiguration: updated),
    );
    notifyListeners();
  }

  IntakeSession startOrResumeIntake() {
    final existing = selectedIntakeSession;
    if (existing != null) return existing;

    final c = selectedCompany;
    final session = IntakeSession.empty(
      companyId: c.id,
      basics: IntakeBasics(
        companyName: c.name,
        shortDescription: c.shortDescription,
        industry: c.industry,
        country: c.country,
        primaryLanguage: c.primaryLanguage,
        website: c.website,
        supportEmail: c.supportEmail,
        supportPhone: c.supportPhone,
        hasWebsite: c.website.trim().isNotEmpty,
      ),
    );
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(intakeSession: session),
    );
    notifyListeners();
    return session;
  }

  void updateIntakeBasics(IntakeBasics basics) {
    _updateIntake((session) => session.copyWith(basics: basics));
  }

  void updateIntakeProducts(IntakeProducts products) {
    _updateIntake((session) => session.copyWith(products: products));
  }

  void updateIntakeTargetGroups(IntakeTargetGroups targetGroups) {
    _updateIntake((session) => session.copyWith(targetGroups: targetGroups));
  }

  void updateIntakeWebsiteAndSupport(
    IntakeWebsiteAndSupport websiteAndSupport,
  ) {
    _updateIntake(
      (session) => session.copyWith(websiteAndSupport: websiteAndSupport),
    );
  }

  void updateIntakeSourcesAndReviews(
    IntakeSourcesAndReviews sourcesAndReviews,
  ) {
    _updateIntake(
      (session) => session.copyWith(sourcesAndReviews: sourcesAndReviews),
    );
  }

  void updateIntakeMarketingAndChannels(
    IntakeMarketingAndChannels marketingAndChannels,
  ) {
    _updateIntake(
      (session) => session.copyWith(marketingAndChannels: marketingAndChannels),
    );
  }

  void updateIntakeGoalsAndRisks(IntakeGoalsAndRisks goalsAndRisks) {
    _updateIntake((session) => session.copyWith(goalsAndRisks: goalsAndRisks));
  }

  void setIntakeStep(int stepIndex) {
    _updateIntake((session) => session.copyWith(currentStepIndex: stepIndex));
  }

  void completeIntake() {
    _updateIntake(
      (session) =>
          session.copyWith(status: IntakeStatus.completed, currentStepIndex: 7),
    );
  }

  void markIntakeChatStarted() {
    final now = DateTime.now();
    _updateIntake(
      (session) => session.copyWith(
        chatStartedAt: session.chatStartedAt ?? now,
        chatUpdatedAt: now,
      ),
    );
  }

  void setIntakeChatQuestionIndex(int index) {
    _updateIntake(
      (session) => session.copyWith(
        chatCurrentQuestionIndex: index,
        chatUpdatedAt: DateTime.now(),
      ),
    );
  }

  void skipIntakeChatQuestion(String questionKey, int nextQuestionIndex) {
    _updateIntake(
      (session) => session.copyWith(
        skippedQuestionKeys: _appendUnique(
          session.skippedQuestionKeys,
          questionKey,
        ),
        chatCurrentQuestionIndex: nextQuestionIndex,
        chatUpdatedAt: DateTime.now(),
      ),
    );
  }

  void deferIntakeChatQuestion(String questionKey, int nextQuestionIndex) {
    _updateIntake(
      (session) => session.copyWith(
        deferredQuestionKeys: _appendUnique(
          session.deferredQuestionKeys,
          questionKey,
        ),
        chatCurrentQuestionIndex: nextQuestionIndex,
        chatUpdatedAt: DateTime.now(),
      ),
    );
  }

  void markIntakeChatCompleted() {
    final now = DateTime.now();
    _updateIntake(
      (session) => session.copyWith(
        status: IntakeStatus.completed,
        currentStepIndex: 7,
        chatCompletedAt: now,
        chatUpdatedAt: now,
      ),
    );
  }

  IntakeMappingPreview generateIntakeMappingPreview() {
    final session = selectedIntakeSession;
    if (session == null) {
      return IntakeMappingPreview(
        suggestions: const [],
        warnings: const ['No intake session available.'],
        generatedAt: DateTime.now(),
      );
    }

    final suggestions = <IntakeMappingSuggestion>[];
    var index = 0;
    String nextId(String prefix) => '${prefix}_${index++}';

    void addCompanyField({
      required String fieldKey,
      required String label,
      required String proposed,
      required String current,
    }) {
      final clean = proposed.trim();
      if (clean.isEmpty || _sameText(clean, current)) return;
      final conflict = current.trim().isNotEmpty;
      suggestions.add(
        IntakeMappingSuggestion(
          id: nextId('company'),
          targetArea: IntakeMappingTargetArea.companyProfile,
          action: IntakeMappingAction.updateCompanyField,
          fieldKey: fieldKey,
          label: label,
          proposedValue: clean,
          currentValue: current.trim().isEmpty ? null : current.trim(),
          conflict: conflict,
          selected: !conflict,
        ),
      );
    }

    final basics = session.basics;
    addCompanyField(
      fieldKey: 'name',
      label: 'Company name',
      proposed: basics.companyName,
      current: company.name,
    );
    addCompanyField(
      fieldKey: 'description',
      label: 'Short description',
      proposed: basics.shortDescription,
      current: company.description,
    );
    addCompanyField(
      fieldKey: 'industry',
      label: 'Industry',
      proposed: basics.industry,
      current: company.industry,
    );
    addCompanyField(
      fieldKey: 'country',
      label: 'Country',
      proposed: basics.country,
      current: company.country,
    );
    addCompanyField(
      fieldKey: 'primaryLanguage',
      label: 'Primary language',
      proposed: basics.primaryLanguage,
      current: company.primaryLanguage,
    );
    addCompanyField(
      fieldKey: 'website',
      label: 'Website',
      proposed: session.websiteAndSupport.websiteUrl.trim().isEmpty
          ? basics.website
          : session.websiteAndSupport.websiteUrl,
      current: company.website,
    );
    addCompanyField(
      fieldKey: 'email',
      label: 'Support email',
      proposed: basics.supportEmail,
      current: company.email,
    );
    addCompanyField(
      fieldKey: 'phone',
      label: 'Support phone',
      proposed: basics.supportPhone,
      current: company.supportPhone,
    );

    final existingProductNames = products.map((product) => product.name);
    final productSeeds = [
      ..._splitList(session.products.importantProducts),
      ..._splitList(session.products.mainProduct),
      ..._splitList(session.products.priorityProducts),
    ];
    for (final productName in _uniqueStrings(productSeeds)) {
      if (_containsSimilar(existingProductNames, productName)) continue;
      suggestions.add(
        IntakeMappingSuggestion(
          id: nextId('product'),
          targetArea: IntakeMappingTargetArea.products,
          action: IntakeMappingAction.addProduct,
          label: productName,
          proposedValue: session.products.explanationNeeded.trim().isEmpty
              ? productName
              : session.products.explanationNeeded.trim(),
          conflict: false,
          selected: true,
          productType: ProductType.produkt,
        ),
      );
    }

    final positioningNote = _joinNonEmpty([
      session.basics.additionalLanguages,
      session.basics.targetRegions,
      session.targetGroups.targetGroup,
      session.targetGroups.marketType,
      session.targetGroups.problemSolved,
      session.targetGroups.customerBenefit,
      session.targetGroups.differentiation,
      session.marketingAndChannels.channels,
      session.marketingAndChannels.socialPlatforms,
      session.marketingAndChannels.socialProfileLinks,
      session.marketingAndChannels.activeChannels,
      session.marketingAndChannels.inactiveChannels,
      session.marketingAndChannels.postingFrequency,
      session.marketingAndChannels.workingChannels,
      session.marketingAndChannels.campaigns,
      session.marketingAndChannels.advertisingChannels,
      session.marketingAndChannels.approximateBudget,
      session.marketingAndChannels.successfulMeasures,
      session.marketingAndChannels.unsuccessfulMeasures,
      session.marketingAndChannels.availableMetrics,
      session.marketingAndChannels.adAccountAccess,
      session.marketingAndChannels.futureSocialPlatforms,
      session.marketingAndChannels.futureAdChannels,
      session.marketingAndChannels.worked,
      session.marketingAndChannels.notWorked,
      session.marketingAndChannels.reachProblems,
    ]);
    if (positioningNote.isNotEmpty &&
        !_containsSimilar([company.internalNotes], positioningNote)) {
      suggestions.add(
        IntakeMappingSuggestion(
          id: nextId('note'),
          targetArea: IntakeMappingTargetArea.internalNotes,
          action: IntakeMappingAction.appendInternalNote,
          label: 'Positioning / marketing notes',
          proposedValue: positioningNote,
          currentValue: company.internalNotes.trim().isEmpty
              ? null
              : company.internalNotes.trim(),
          conflict: false,
          selected: true,
        ),
      );
    }

    final allowedTopics = _uniqueStrings([
      ..._splitList(session.products.mainProduct),
      ..._splitList(session.products.priorityProducts),
      ..._splitList(session.products.importantProducts),
    ]);
    for (final topic in allowedTopics) {
      if (_containsSimilar(businessRules.allowedSupportTopics, topic)) {
        continue;
      }
      suggestions.add(
        IntakeMappingSuggestion(
          id: nextId('rule_allowed'),
          targetArea: IntakeMappingTargetArea.businessRules,
          action: IntakeMappingAction.addBusinessRuleAllowedTopic,
          label: topic,
          proposedValue: topic,
          conflict: false,
          selected: true,
        ),
      );
    }

    final riskTopics = _uniqueStrings([
      ..._splitList(session.websiteAndSupport.sensitiveTopics),
      ..._splitList(session.goalsAndRisks.sensitiveTopics),
      ..._splitList(session.goalsAndRisks.prohibitedStatements),
      ..._splitList(session.goalsAndRisks.forbiddenClaims),
      ..._splitList(session.goalsAndRisks.botRestrictedTopics),
      ..._splitList(session.goalsAndRisks.alwaysEscalateTopics),
      ..._splitList(session.goalsAndRisks.legalRestrictions),
    ]);
    for (final topic in riskTopics) {
      if (!_containsSimilar(businessRules.doNotSay, topic)) {
        suggestions.add(
          IntakeMappingSuggestion(
            id: nextId('rule_blocked'),
            targetArea: IntakeMappingTargetArea.businessRules,
            action: IntakeMappingAction.addBusinessRuleDoNotSay,
            label: topic,
            proposedValue: topic,
            conflict: false,
            selected: true,
          ),
        );
      }
      if (!_containsSimilar(botConfiguration.blockedTopics, topic)) {
        suggestions.add(
          IntakeMappingSuggestion(
            id: nextId('bot_blocked'),
            targetArea: IntakeMappingTargetArea.botSettings,
            action: IntakeMappingAction.addBotBlockedTopic,
            label: topic,
            proposedValue: topic,
            conflict: false,
            selected: true,
          ),
        );
      }
    }

    final escalationNotes = _joinNonEmpty([
      session.websiteAndSupport.sensitiveTopics,
      session.websiteAndSupport.supportChannels,
      session.goalsAndRisks.sensitiveTopics,
      session.goalsAndRisks.botRestrictedTopics,
      session.goalsAndRisks.alwaysEscalateTopics,
      session.goalsAndRisks.legalRestrictions,
      session.goalsAndRisks.shortTermPriorities,
    ]);
    if (escalationNotes.isNotEmpty &&
        !_containsSimilar([businessRules.escalationNotes], escalationNotes)) {
      suggestions.add(
        IntakeMappingSuggestion(
          id: nextId('escalation'),
          targetArea: IntakeMappingTargetArea.businessRules,
          action: IntakeMappingAction.appendEscalationNotes,
          label: 'Escalation notes',
          proposedValue: escalationNotes,
          currentValue: businessRules.escalationNotes.trim().isEmpty
              ? null
              : businessRules.escalationNotes.trim(),
          conflict: false,
          selected: true,
        ),
      );
    }

    if (riskTopics.isNotEmpty && !botConfiguration.alwaysEscalateRedFlags) {
      suggestions.add(
        IntakeMappingSuggestion(
          id: nextId('bot_red'),
          targetArea: IntakeMappingTargetArea.botSettings,
          action: IntakeMappingAction.setBotEscalateRedFlags,
          label: 'Always escalate red flags',
          proposedValue: 'true',
          currentValue: 'false',
          conflict: false,
          selected: true,
        ),
      );
    }

    final handover = _joinNonEmpty([
      session.goalsAndRisks.botRestrictedTopics,
      session.goalsAndRisks.alwaysEscalateTopics,
    ]);
    if (handover.isNotEmpty &&
        !_sameText(handover, botConfiguration.handoverMessage)) {
      final conflict = botConfiguration.handoverMessage.trim().isNotEmpty;
      suggestions.add(
        IntakeMappingSuggestion(
          id: nextId('handover'),
          targetArea: IntakeMappingTargetArea.botSettings,
          action: IntakeMappingAction.setBotHandoverMessage,
          label: 'Handover message',
          proposedValue: handover,
          currentValue: botConfiguration.handoverMessage.trim().isEmpty
              ? null
              : botConfiguration.handoverMessage.trim(),
          conflict: conflict,
          selected: !conflict,
        ),
      );
    }

    final knowledgeQuestions = _uniqueStrings([
      ..._splitQuestions(session.websiteAndSupport.frequentQuestions),
      ..._splitQuestions(session.websiteAndSupport.supportProblems),
      ..._splitQuestions(session.websiteAndSupport.preSalesQuestions),
      ..._splitQuestions(session.websiteAndSupport.afterSalesQuestions),
      ..._splitQuestions(session.websiteAndSupport.technicalProblems),
      ..._splitQuestions(session.websiteAndSupport.standardizableQuestions),
    ]);
    final sensitiveQuestions = _splitQuestions(
      session.websiteAndSupport.sensitiveTopics,
    );
    for (final question in knowledgeQuestions) {
      if (_containsSimilar(
        knowledgeEntries.map((entry) => entry.title),
        question,
      )) {
        continue;
      }
      suggestions.add(
        IntakeMappingSuggestion(
          id: nextId('knowledge'),
          targetArea: IntakeMappingTargetArea.knowledgeBase,
          action: IntakeMappingAction.addKnowledgeEntry,
          label: question,
          proposedValue: '',
          conflict: false,
          selected: true,
          riskLevel: RiskLevel.green,
        ),
      );
    }
    for (final question in sensitiveQuestions) {
      if (_containsSimilar(
        knowledgeEntries.map((entry) => entry.title),
        question,
      )) {
        continue;
      }
      suggestions.add(
        IntakeMappingSuggestion(
          id: nextId('knowledge_sensitive'),
          targetArea: IntakeMappingTargetArea.knowledgeBase,
          action: IntakeMappingAction.addKnowledgeEntry,
          label: question,
          proposedValue: '',
          conflict: false,
          selected: false,
          riskLevel: RiskLevel.yellow,
        ),
      );
    }

    final sourceSeeds = <({String title, SourceMaterialType type})>[
      if (session.websiteAndSupport.websiteUrl.trim().isNotEmpty)
        (
          title: session.websiteAndSupport.websiteUrl.trim(),
          type: SourceMaterialType.website,
        ),
      if (session.websiteAndSupport.shopUrl.trim().isNotEmpty)
        (
          title: session.websiteAndSupport.shopUrl.trim(),
          type: SourceMaterialType.website,
        ),
      if (session.websiteAndSupport.faqUrl.trim().isNotEmpty)
        (
          title: session.websiteAndSupport.faqUrl.trim(),
          type: SourceMaterialType.faq,
        ),
      for (final item in _splitList(session.websiteAndSupport.importantPages))
        (title: item, type: SourceMaterialType.website),
      for (final item in _splitList(session.sourcesAndReviews.existingSources))
        (title: item, type: _inferSourceType(item)),
      for (final item in _splitList(session.sourcesAndReviews.materialDetails))
        (title: item, type: _inferSourceType(item)),
      for (final item in _splitList(
        session.sourcesAndReviews.materialLocations,
      ))
        (title: item, type: _inferSourceType(item)),
      for (final item in _splitList(
        session.sourcesAndReviews.importantMaterials,
      ))
        (title: item, type: _inferSourceType(item)),
      for (final item in _splitList(session.sourcesAndReviews.reviewPlatforms))
        (title: item, type: SourceMaterialType.review),
      for (final item in _splitList(
        session.sourcesAndReviews.reviewLinksOrFiles,
      ))
        (title: item, type: SourceMaterialType.review),
      for (final item in _splitList(session.sourcesAndReviews.reviews))
        (title: item, type: SourceMaterialType.review),
      for (final item in _splitList(session.sourcesAndReviews.socialMentions))
        (title: item, type: SourceMaterialType.social),
      for (final item in _splitList(
        session.marketingAndChannels.socialProfileLinks,
      ))
        (title: item, type: SourceMaterialType.social),
      for (final item in _splitList(session.sourcesAndReviews.trustMaterial))
        (title: item, type: SourceMaterialType.note),
    ];
    final existingSourceTitles = sourceMaterials.map((source) => source.title);
    for (final source in sourceSeeds) {
      if (_containsSimilar(existingSourceTitles, source.title)) continue;
      suggestions.add(
        IntakeMappingSuggestion(
          id: nextId('source'),
          targetArea: IntakeMappingTargetArea.sources,
          action: IntakeMappingAction.addSourceMaterial,
          label: source.title,
          proposedValue: source.title,
          conflict: false,
          selected: true,
          sourceType: source.type,
        ),
      );
    }

    void addAuditSuggestion(
      AuditArea area,
      AuditItemStatus status,
      String label,
    ) {
      final areaItems = auditItems.where((item) => item.area == area).toList();
      if (areaItems.isEmpty) return;
      if (areaItems.every((item) => item.status == status)) return;
      suggestions.add(
        IntakeMappingSuggestion(
          id: nextId('audit'),
          targetArea: IntakeMappingTargetArea.audit,
          action: IntakeMappingAction.updateAuditArea,
          label: label,
          proposedValue: status.name,
          currentValue: areaItems
              .map((item) => item.status.name)
              .toSet()
              .join('/'),
          conflict: true,
          selected: false,
          auditArea: area,
          auditStatus: status,
        ),
      );
    }

    addAuditSuggestion(
      AuditArea.website,
      basics.website.trim().isEmpty &&
              session.websiteAndSupport.websiteUrl.trim().isEmpty
          ? AuditItemStatus.missing
          : AuditItemStatus.complete,
      'Website audit',
    );
    addAuditSuggestion(
      AuditArea.supportKnowledge,
      _joinNonEmpty([
            session.websiteAndSupport.frequentQuestions,
            session.websiteAndSupport.preSalesQuestions,
            session.websiteAndSupport.afterSalesQuestions,
            session.websiteAndSupport.technicalProblems,
            session.websiteAndSupport.standardizableQuestions,
          ]).isEmpty
          ? AuditItemStatus.missing
          : AuditItemStatus.partial,
      'FAQ / support knowledge audit',
    );
    addAuditSuggestion(
      AuditArea.trustMaterial,
      session.sourcesAndReviews.trustMaterial.trim().isEmpty &&
              session.sourcesAndReviews.reviews.trim().isEmpty &&
              session.sourcesAndReviews.reviewPlatforms.trim().isEmpty &&
              session.sourcesAndReviews.reviewLinksOrFiles.trim().isEmpty
          ? AuditItemStatus.missing
          : AuditItemStatus.partial,
      'Reviews / trust audit',
    );
    addAuditSuggestion(
      AuditArea.sources,
      sourceSeeds.isEmpty ? AuditItemStatus.missing : AuditItemStatus.partial,
      'Sources audit',
    );
    addAuditSuggestion(
      AuditArea.riskRules,
      riskTopics.isEmpty ? AuditItemStatus.missing : AuditItemStatus.partial,
      'Risk rules audit',
    );
    addAuditSuggestion(
      AuditArea.botReadiness,
      botConfiguration.status == BotStatus.draft
          ? AuditItemStatus.partial
          : AuditItemStatus.complete,
      'Bot readiness audit',
    );

    return IntakeMappingPreview(
      suggestions: suggestions,
      warnings: suggestions.any((suggestion) => suggestion.conflict)
          ? const ['Some suggestions conflict with existing workspace data.']
          : const [],
      generatedAt: DateTime.now(),
    );
  }

  void importSelectedIntakeMapping(IntakeMappingPreview preview) {
    final selected = preview.suggestions.where((s) => s.selected).toList();
    if (selected.isEmpty) return;

    final now = DateTime.now();
    var updatedCompany = company;
    var updatedProducts = [...products];
    var updatedRules = businessRules;
    var updatedSources = [...sourceMaterials];
    var updatedKnowledge = [...knowledgeEntries];
    var updatedAuditItems = [...auditItems];
    var updatedBotConfig = botConfiguration;

    for (final suggestion in selected) {
      switch (suggestion.action) {
        case IntakeMappingAction.updateCompanyField:
          updatedCompany = _applyCompanyField(updatedCompany, suggestion);
        case IntakeMappingAction.addProduct:
          if (!_containsSimilar(
            updatedProducts.map((product) => product.name),
            suggestion.label,
          )) {
            updatedProducts.add(
              ProductOrService(
                id: 'p_import_${now.microsecondsSinceEpoch}_${updatedProducts.length}',
                name: suggestion.label,
                description: suggestion.proposedValue,
                type: suggestion.productType ?? ProductType.produkt,
              ),
            );
          }
        case IntakeMappingAction.appendInternalNote:
          updatedCompany = updatedCompany.copyWith(
            internalNotes: _appendParagraph(
              updatedCompany.internalNotes,
              suggestion.proposedValue,
            ),
          );
        case IntakeMappingAction.addBusinessRuleDoNotSay:
          updatedRules = updatedRules.copyWith(
            doNotSay: _appendUnique(
              updatedRules.doNotSay,
              suggestion.proposedValue,
            ),
          );
        case IntakeMappingAction.addBusinessRuleAllowedTopic:
          updatedRules = updatedRules.copyWith(
            allowedSupportTopics: _appendUnique(
              updatedRules.allowedSupportTopics,
              suggestion.proposedValue,
            ),
          );
        case IntakeMappingAction.appendEscalationNotes:
          updatedRules = updatedRules.copyWith(
            escalationNotes: _appendParagraph(
              updatedRules.escalationNotes,
              suggestion.proposedValue,
            ),
          );
        case IntakeMappingAction.addSourceMaterial:
          if (!_containsSimilar(
            updatedSources.map((source) => source.title),
            suggestion.label,
          )) {
            updatedSources.add(
              SourceMaterial(
                id: 'sm_import_${now.microsecondsSinceEpoch}_${updatedSources.length}',
                title: suggestion.label,
                type: suggestion.sourceType ?? SourceMaterialType.other,
                url: _extractUrl(suggestion.proposedValue),
                contentSnippet: suggestion.proposedValue,
                status: SourceMaterialStatus.newItem,
                createdAt: now,
                updatedAt: now,
              ),
            );
          }
        case IntakeMappingAction.addKnowledgeEntry:
          if (!_containsSimilar(
            updatedKnowledge.map((entry) => entry.title),
            suggestion.label,
          )) {
            updatedKnowledge.add(
              KnowledgeEntry(
                id: 'k_import_${now.microsecondsSinceEpoch}_${updatedKnowledge.length}',
                title: suggestion.label,
                content: suggestion.proposedValue,
                category: KnowledgeCategory.faq,
                riskLevel: suggestion.riskLevel ?? RiskLevel.green,
                keywords: _keywordsFromTitle(suggestion.label),
                source: 'Intake',
                createdAt: now,
                languageCode: updatedCompany.primaryLanguage.isEmpty
                    ? 'de'
                    : updatedCompany.primaryLanguage,
              ),
            );
          }
        case IntakeMappingAction.updateAuditArea:
          final area = suggestion.auditArea;
          final status = suggestion.auditStatus;
          if (area != null && status != null) {
            updatedAuditItems = [
              for (final item in updatedAuditItems)
                if (item.area == area) item.copyWith(status: status) else item,
            ];
          }
        case IntakeMappingAction.addBotBlockedTopic:
          updatedBotConfig = updatedBotConfig.copyWith(
            blockedTopics: _appendUnique(
              updatedBotConfig.blockedTopics,
              suggestion.proposedValue,
            ),
          );
        case IntakeMappingAction.setBotEscalateRedFlags:
          updatedBotConfig = updatedBotConfig.copyWith(
            alwaysEscalateRedFlags: true,
          );
        case IntakeMappingAction.setBotHandoverMessage:
          updatedBotConfig = updatedBotConfig.copyWith(
            handoverMessage: suggestion.proposedValue,
          );
      }
    }

    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        company: updatedCompany,
        products: updatedProducts,
        businessRules: updatedRules,
        sourceMaterials: updatedSources,
        knowledgeEntries: updatedKnowledge,
        auditItems: updatedAuditItems,
        botConfiguration: updatedBotConfig,
        intakeSession: selectedIntakeSession?.copyWith(
          importedAt: now,
          updatedAt: now,
        ),
      ),
    );
    notifyListeners();
  }

  void addKnowledgeEntry(KnowledgeEntry entry) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        knowledgeEntries: [...selectedKnowledgeEntries, entry],
      ),
    );
    notifyListeners();
  }

  void addKnowledgeEntryLinkedToSource({
    required KnowledgeEntry entry,
    String? sourceMaterialId,
    bool markSourceConverted = true,
  }) {
    final updatedSources = [
      for (final source in selectedSourceMaterials)
        if (source.id == sourceMaterialId)
          source.copyWith(
            status: markSourceConverted
                ? SourceMaterialStatus.converted
                : source.status,
            relatedKnowledgeEntryIds: [
              ...source.relatedKnowledgeEntryIds,
              entry.id,
            ],
            updatedAt: DateTime.now(),
          )
        else
          source,
    ];
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        knowledgeEntries: [...selectedKnowledgeEntries, entry],
        sourceMaterials: updatedSources,
      ),
    );
    notifyListeners();
  }

  void removeKnowledgeEntry(String id) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        knowledgeEntries: selectedKnowledgeEntries
            .where((e) => e.id != id)
            .toList(),
      ),
    );
    notifyListeners();
  }

  void addBotLog(BotQuestionLog log) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(botLogs: [...selectedBotLogs, log]),
    );
    notifyListeners();
  }

  void addSourceMaterial(SourceMaterial source) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        sourceMaterials: [...selectedSourceMaterials, source],
      ),
    );
    notifyListeners();
  }

  void updateSourceMaterial(SourceMaterial updated) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        sourceMaterials: [
          for (final source in selectedSourceMaterials)
            if (source.id == updated.id) updated else source,
        ],
      ),
    );
    notifyListeners();
  }

  void deleteSourceMaterial(String id) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        sourceMaterials: selectedSourceMaterials
            .where((source) => source.id != id)
            .toList(),
      ),
    );
    notifyListeners();
  }

  void markSourceAsReviewed(String id) {
    _updateSourceStatus(id, SourceMaterialStatus.reviewed);
  }

  void markSourceAsConverted(String id) {
    _updateSourceStatus(id, SourceMaterialStatus.converted);
  }

  int get sourceMaterialCount => selectedSourceMaterials.length;

  int get newSourceMaterialCount => selectedSourceMaterials
      .where((source) => source.status == SourceMaterialStatus.newItem)
      .length;

  String intakeStatusFor(CompanyWorkspace workspace) {
    final session = workspace.intakeSession;
    if (session == null) return 'notStarted';
    return session.status.name;
  }

  void updateBotLog(BotQuestionLog updated) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        botLogs: [
          for (final log in selectedBotLogs)
            if (log.id == updated.id) updated else log,
        ],
      ),
    );
    notifyListeners();
  }

  void addKnowledgeEntryFromReview({
    required KnowledgeEntry entry,
    required BotQuestionLog updatedLog,
    String? sourceMaterialId,
    bool markSourceConverted = true,
  }) {
    final updatedSources = [
      for (final source in selectedSourceMaterials)
        if (source.id == sourceMaterialId)
          source.copyWith(
            status: markSourceConverted
                ? SourceMaterialStatus.converted
                : source.status,
            relatedKnowledgeEntryIds: [
              ...source.relatedKnowledgeEntryIds,
              entry.id,
            ],
            updatedAt: DateTime.now(),
          )
        else
          source,
    ];
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        knowledgeEntries: [...selectedKnowledgeEntries, entry],
        sourceMaterials: updatedSources,
        botLogs: [
          for (final log in selectedBotLogs)
            if (log.id == updatedLog.id) updatedLog else log,
        ],
      ),
    );
    notifyListeners();
  }

  void updateAuditItemStatus(String id, AuditItemStatus status) {
    _updateAuditItem(id, (item) => item.copyWith(status: status));
  }

  void updateAuditItemPriority(String id, AuditPriority priority) {
    _updateAuditItem(id, (item) => item.copyWith(priority: priority));
  }

  void updateAuditItemNote(String id, String? note) {
    _updateAuditItem(id, (item) {
      final cleanNote = note?.trim();
      return item.copyWith(
        note: cleanNote == null || cleanNote.isEmpty ? null : cleanNote,
      );
    });
  }

  int get auditMissingCount =>
      auditItems.where((item) => item.status == AuditItemStatus.missing).length;

  int get auditPartialCount =>
      auditItems.where((item) => item.status == AuditItemStatus.partial).length;

  int get auditCompleteCount => auditItems
      .where((item) => item.status == AuditItemStatus.complete)
      .length;

  int get auditHighPriorityOpenCount => auditItems
      .where(
        (item) =>
            item.priority == AuditPriority.high &&
            item.status != AuditItemStatus.complete,
      )
      .length;

  int get auditHighPriorityMissingCount => auditItems
      .where(
        (item) =>
            item.priority == AuditPriority.high &&
            item.status == AuditItemStatus.missing,
      )
      .length;

  int get openReviewCount =>
      botLogs.where((log) => log.reviewStatus == ReviewStatus.open).length;

  int get blockedBotLogCount => botLogs.where((log) => log.redirected).length;

  ProjectStatusSnapshot get projectStatus {
    return projectStatusFor(selectedWorkspace);
  }

  ProjectStatusSnapshot projectStatusFor(CompanyWorkspace workspace) {
    final profileStatus = companyProfileStatusFor(workspace);
    final auditScore = auditScoreFor(workspace);
    final intake = workspace.intakeSession;
    final sources = workspace.sourceMaterials;
    final knowledgeCount = workspace.knowledgeEntries.length;
    final openReviews = openReviewCountFor(workspace);
    final botStatus = workspace.botConfiguration.status;
    final businessRules = workspace.businessRules;

    final items = [
      ProjectStatusItem(
        type: ProjectTaskType.companyProfile,
        phase: ProjectPhase.company,
        completion: switch (profileStatus) {
          CompanyProfileStatus.complete => ProjectCompletionState.complete,
          CompanyProfileStatus.partial => ProjectCompletionState.partial,
          CompanyProfileStatus.incomplete => ProjectCompletionState.missing,
        },
        priority: ProjectTaskPriority.high,
        route: '/company',
        weight: 1.2,
      ),
      ProjectStatusItem(
        type: ProjectTaskType.intake,
        phase: ProjectPhase.company,
        completion: _intakeCompletion(intake),
        priority: ProjectTaskPriority.high,
        route: '/intake',
        weight: 1.2,
      ),
      ProjectStatusItem(
        type: ProjectTaskType.knowledgeBase,
        phase: ProjectPhase.knowledge,
        completion: _countCompletion(
          knowledgeCount,
          partialAt: 4,
          completeAt: 12,
        ),
        priority: ProjectTaskPriority.high,
        route: '/knowledge',
        weight: 1.2,
      ),
      ProjectStatusItem(
        type: ProjectTaskType.sources,
        phase: ProjectPhase.knowledge,
        completion: _sourcesCompletion(sources),
        priority: ProjectTaskPriority.medium,
        route: '/sources',
      ),
      ProjectStatusItem(
        type: ProjectTaskType.audit,
        phase: ProjectPhase.knowledge,
        completion: auditScore >= 0.8
            ? ProjectCompletionState.complete
            : auditScore >= 0.6
            ? ProjectCompletionState.partial
            : ProjectCompletionState.missing,
        priority: ProjectTaskPriority.high,
        route: '/audit',
        weight: 1.2,
      ),
      ProjectStatusItem(
        type: ProjectTaskType.websiteAnalysis,
        phase: ProjectPhase.knowledge,
        completion: _websiteAnalysisCompletion(workspace),
        priority: ProjectTaskPriority.medium,
        route: '/sources',
      ),
      ProjectStatusItem(
        type: ProjectTaskType.botActivation,
        phase: ProjectPhase.ai,
        completion: switch (botStatus) {
          BotStatus.active => ProjectCompletionState.complete,
          BotStatus.testReady => ProjectCompletionState.partial,
          BotStatus.draft => ProjectCompletionState.missing,
        },
        priority: ProjectTaskPriority.high,
        route: '/bot-settings',
        weight: 1.2,
      ),
      ProjectStatusItem(
        type: ProjectTaskType.humanReview,
        phase: ProjectPhase.ai,
        completion: openReviews == 0
            ? ProjectCompletionState.complete
            : openReviews < 3
            ? ProjectCompletionState.partial
            : ProjectCompletionState.missing,
        priority: openReviews >= 3
            ? ProjectTaskPriority.high
            : ProjectTaskPriority.medium,
        route: '/review',
      ),
      ProjectStatusItem(
        type: ProjectTaskType.marketing,
        phase: ProjectPhase.marketing,
        completion: _marketingCompletion(workspace),
        priority: ProjectTaskPriority.medium,
        route: '/intake',
      ),
      ProjectStatusItem(
        type: ProjectTaskType.controlling,
        phase: ProjectPhase.controlling,
        completion: _controllingCompletion(workspace),
        priority: ProjectTaskPriority.low,
        route: '/dashboard',
      ),
    ];

    final recommendations = _buildProjectRecommendations(
      workspace: workspace,
      items: items,
      auditScore: auditScore,
      knowledgeCount: knowledgeCount,
      openReviews: openReviews,
      businessRulesComplete:
          businessRules.brandVoice.trim().isNotEmpty &&
          businessRules.allowedSupportTopics.isNotEmpty,
    );

    return ProjectStatusSnapshot(
      progress: _weightedProjectProgress(items),
      currentPhase: _currentProjectPhase(items),
      items: items,
      recommendations: recommendations,
    );
  }

  ProjectCompletionState _intakeCompletion(IntakeSession? session) {
    if (session == null) return ProjectCompletionState.missing;
    if (session.importedAt != null ||
        session.status == IntakeStatus.completed) {
      return ProjectCompletionState.complete;
    }
    if (session.status == IntakeStatus.inProgress ||
        session.chatStartedAt != null) {
      return ProjectCompletionState.partial;
    }
    return ProjectCompletionState.missing;
  }

  ProjectCompletionState _countCompletion(
    int count, {
    required int partialAt,
    required int completeAt,
  }) {
    if (count >= completeAt) return ProjectCompletionState.complete;
    if (count >= partialAt) return ProjectCompletionState.partial;
    return ProjectCompletionState.missing;
  }

  ProjectCompletionState _sourcesCompletion(List<SourceMaterial> sources) {
    if (sources.any(
      (source) => source.status == SourceMaterialStatus.converted,
    )) {
      return ProjectCompletionState.complete;
    }
    if (sources.isNotEmpty) return ProjectCompletionState.partial;
    return ProjectCompletionState.missing;
  }

  ProjectCompletionState _websiteAnalysisCompletion(
    CompanyWorkspace workspace,
  ) {
    final website = workspace.company.website.trim();
    final intakeWebsite =
        workspace.intakeSession?.websiteAndSupport.websiteUrl.trim() ?? '';
    final hasWebsite = website.isNotEmpty || intakeWebsite.isNotEmpty;
    if (!hasWebsite) return ProjectCompletionState.missing;

    final websiteSources = workspace.sourceMaterials.where(
      (source) => source.type == SourceMaterialType.website,
    );
    if (websiteSources.any(
      (source) =>
          source.status == SourceMaterialStatus.reviewed ||
          source.status == SourceMaterialStatus.converted,
    )) {
      return ProjectCompletionState.complete;
    }
    if (websiteSources.isNotEmpty) return ProjectCompletionState.partial;
    return ProjectCompletionState.partial;
  }

  ProjectCompletionState _marketingCompletion(CompanyWorkspace workspace) {
    final marketing = workspace.intakeSession?.marketingAndChannels;
    final hasSocialLinks = workspace.company.socialLinks.values.any(
      (value) => value.trim().isNotEmpty,
    );
    if (marketing == null) {
      return hasSocialLinks
          ? ProjectCompletionState.partial
          : ProjectCompletionState.missing;
    }
    final details = _joinNonEmpty([
      marketing.channels,
      marketing.campaigns,
      marketing.socialPlatforms,
      marketing.socialProfileLinks,
      marketing.workingChannels,
      marketing.advertisingChannels,
      marketing.availableMetrics,
      marketing.futureSocialPlatforms,
      marketing.futureAdChannels,
    ]);
    if (details.isNotEmpty && hasSocialLinks) {
      return ProjectCompletionState.complete;
    }
    if (details.isNotEmpty || hasSocialLinks) {
      return ProjectCompletionState.partial;
    }
    return ProjectCompletionState.missing;
  }

  ProjectCompletionState _controllingCompletion(CompanyWorkspace workspace) {
    final hasActivity = workspace.botLogs.length >= 5;
    final hasEnoughKnowledge = workspace.knowledgeEntries.length >= 12;
    final hasAuditBaseline = auditScoreFor(workspace) >= 0.6;
    if (hasActivity && hasEnoughKnowledge && hasAuditBaseline) {
      return ProjectCompletionState.complete;
    }
    if (workspace.botLogs.isNotEmpty || hasAuditBaseline) {
      return ProjectCompletionState.partial;
    }
    return ProjectCompletionState.missing;
  }

  double _weightedProjectProgress(List<ProjectStatusItem> items) {
    if (items.isEmpty) return 0;
    final maxScore = items.fold<double>(0, (sum, item) => sum + item.weight);
    final score = items.fold<double>(
      0,
      (sum, item) => sum + item.weight * item.completionValue,
    );
    return maxScore == 0 ? 0 : score / maxScore;
  }

  ProjectPhase _currentProjectPhase(List<ProjectStatusItem> items) {
    const phases = [
      ProjectPhase.company,
      ProjectPhase.knowledge,
      ProjectPhase.ai,
      ProjectPhase.marketing,
      ProjectPhase.controlling,
    ];
    for (final phase in phases) {
      final phaseItems = items.where((item) => item.phase == phase);
      if (phaseItems.any((item) => item.isOpen)) return phase;
    }
    return ProjectPhase.controlling;
  }

  List<ProjectRecommendation> _buildProjectRecommendations({
    required CompanyWorkspace workspace,
    required List<ProjectStatusItem> items,
    required double auditScore,
    required int knowledgeCount,
    required int openReviews,
    required bool businessRulesComplete,
  }) {
    final recommendations = <ProjectRecommendation>[];
    void add(ProjectTaskType type, ProjectTaskPriority priority, String route) {
      final item = items.firstWhere((candidate) => candidate.type == type);
      if (item.isComplete) return;
      if (recommendations.any((entry) => entry.type == type)) return;
      recommendations.add(
        ProjectRecommendation(
          type: type,
          phase: item.phase,
          priority: priority,
          route: route,
        ),
      );
    }

    final highPriorityMissing = workspace.auditItems.where(
      (item) =>
          item.priority == AuditPriority.high &&
          item.status == AuditItemStatus.missing,
    );
    if (highPriorityMissing.isNotEmpty || auditScore < 0.6) {
      add(ProjectTaskType.audit, ProjectTaskPriority.high, '/audit');
    }
    if (companyProfileStatusFor(workspace) != CompanyProfileStatus.complete ||
        !businessRulesComplete) {
      add(ProjectTaskType.companyProfile, ProjectTaskPriority.high, '/company');
    }
    if (workspace.intakeSession == null ||
        _intakeCompletion(workspace.intakeSession) !=
            ProjectCompletionState.complete) {
      add(ProjectTaskType.intake, ProjectTaskPriority.high, '/intake');
    }
    if (knowledgeCount < 4) {
      add(
        ProjectTaskType.knowledgeBase,
        ProjectTaskPriority.high,
        '/knowledge',
      );
    } else if (knowledgeCount < 12) {
      add(
        ProjectTaskType.knowledgeBase,
        ProjectTaskPriority.medium,
        '/knowledge',
      );
    }
    final newSources = workspace.sourceMaterials.where(
      (source) => source.status == SourceMaterialStatus.newItem,
    );
    if (workspace.sourceMaterials.isEmpty || newSources.isNotEmpty) {
      add(ProjectTaskType.sources, ProjectTaskPriority.medium, '/sources');
    }
    if (_websiteAnalysisCompletion(workspace) !=
        ProjectCompletionState.complete) {
      add(
        ProjectTaskType.websiteAnalysis,
        ProjectTaskPriority.medium,
        '/sources',
      );
    }
    if (workspace.botConfiguration.status == BotStatus.draft) {
      add(
        ProjectTaskType.botActivation,
        ProjectTaskPriority.high,
        '/bot-settings',
      );
    } else if (workspace.botConfiguration.status == BotStatus.testReady) {
      add(
        ProjectTaskType.botActivation,
        ProjectTaskPriority.medium,
        '/bot-test',
      );
    }
    if (openReviews > 0) {
      add(
        ProjectTaskType.humanReview,
        openReviews >= 3
            ? ProjectTaskPriority.high
            : ProjectTaskPriority.medium,
        '/review',
      );
    }
    if (_marketingCompletion(workspace) != ProjectCompletionState.complete) {
      add(ProjectTaskType.marketing, ProjectTaskPriority.medium, '/intake');
    }
    if (_controllingCompletion(workspace) != ProjectCompletionState.complete) {
      add(ProjectTaskType.controlling, ProjectTaskPriority.low, '/dashboard');
    }

    recommendations.sort((a, b) {
      final priority = _projectPriorityRank(
        b.priority,
      ).compareTo(_projectPriorityRank(a.priority));
      if (priority != 0) return priority;
      return _phaseRank(a.phase).compareTo(_phaseRank(b.phase));
    });
    return recommendations;
  }

  int _projectPriorityRank(ProjectTaskPriority priority) {
    return switch (priority) {
      ProjectTaskPriority.high => 3,
      ProjectTaskPriority.medium => 2,
      ProjectTaskPriority.low => 1,
    };
  }

  int _phaseRank(ProjectPhase phase) {
    return switch (phase) {
      ProjectPhase.company => 0,
      ProjectPhase.knowledge => 1,
      ProjectPhase.ai => 2,
      ProjectPhase.marketing => 3,
      ProjectPhase.controlling => 4,
    };
  }

  int sourceMaterialCountFor(CompanyWorkspace workspace) {
    return workspace.sourceMaterials.length;
  }

  int newSourceMaterialCountFor(CompanyWorkspace workspace) {
    return workspace.sourceMaterials
        .where((source) => source.status == SourceMaterialStatus.newItem)
        .length;
  }

  CompanyProfileStatus get companyProfileStatus {
    return companyProfileStatusFor(selectedWorkspace);
  }

  CompanyProfileStatus companyProfileStatusFor(CompanyWorkspace workspace) {
    final c = workspace.company;
    final rules = workspace.businessRules;
    final checks = [
      c.name.isNotEmpty,
      c.description.isNotEmpty,
      c.industry.isNotEmpty,
      c.country.isNotEmpty,
      c.primaryLanguage.isNotEmpty,
      c.website.isNotEmpty,
      c.email.isNotEmpty,
      c.socialLinks.values.any((value) => value.trim().isNotEmpty),
      rules.brandVoice.isNotEmpty,
      rules.allowedSupportTopics.isNotEmpty,
    ];
    final complete = checks.where((check) => check).length;
    if (complete >= 8) return CompanyProfileStatus.complete;
    if (complete >= 4) return CompanyProfileStatus.partial;
    return CompanyProfileStatus.incomplete;
  }

  double auditScoreFor(CompanyWorkspace workspace) {
    return _auditScoreForItems(workspace.auditItems);
  }

  int openReviewCountFor(CompanyWorkspace workspace) {
    return workspace.botLogs
        .where((log) => log.reviewStatus == ReviewStatus.open)
        .length;
  }

  int blockedBotLogCountFor(CompanyWorkspace workspace) {
    return workspace.botLogs.where((log) => log.redirected).length;
  }

  // 0.0 - 1.0; weighted by priority, with partial items counting halfway.
  double get auditScore {
    return _auditScoreForItems(auditItems);
  }

  double _auditScoreForItems(List<BusinessAuditItem> items) {
    if (items.isEmpty) return 0.0;
    double score = 0;
    double maxScore = 0;
    for (final item in items) {
      final weight = _priorityWeight(item.priority);
      maxScore += weight;
      score += switch (item.status) {
        AuditItemStatus.complete => weight,
        AuditItemStatus.partial => weight * 0.5,
        AuditItemStatus.missing => 0,
      };
    }
    return maxScore == 0 ? 0.0 : score / maxScore;
  }

  void _updateAuditItem(
    String id,
    BusinessAuditItem Function(BusinessAuditItem item) update,
  ) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        auditItems: [
          for (final item in selectedAuditItems)
            if (item.id == id) update(item) else item,
        ],
      ),
    );
    notifyListeners();
  }

  void _updateSourceStatus(String id, SourceMaterialStatus status) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        sourceMaterials: [
          for (final source in selectedSourceMaterials)
            if (source.id == id)
              source.copyWith(status: status, updatedAt: DateTime.now())
            else
              source,
        ],
      ),
    );
    notifyListeners();
  }

  void _updateIntake(IntakeSession Function(IntakeSession session) update) {
    final existing = selectedIntakeSession ?? startOrResumeIntake();
    final status = existing.status == IntakeStatus.completed
        ? IntakeStatus.completed
        : IntakeStatus.inProgress;
    final updated = update(
      existing.copyWith(status: status, updatedAt: DateTime.now()),
    );
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(intakeSession: updated),
    );
    notifyListeners();
  }

  int _priorityWeight(AuditPriority priority) {
    return switch (priority) {
      AuditPriority.low => 1,
      AuditPriority.medium => 2,
      AuditPriority.high => 3,
    };
  }

  Company _applyCompanyField(
    Company current,
    IntakeMappingSuggestion suggestion,
  ) {
    final value = suggestion.proposedValue;
    return switch (suggestion.fieldKey) {
      'name' => current.copyWith(name: value),
      'description' => current.copyWith(description: value),
      'industry' => current.copyWith(industry: value),
      'country' => current.copyWith(country: value),
      'primaryLanguage' => current.copyWith(primaryLanguage: value),
      'website' => current.copyWith(website: value),
      'email' => current.copyWith(email: value),
      'phone' => current.copyWith(phone: value),
      _ => current,
    };
  }

  List<String> _splitList(String value) {
    return value
        .split(RegExp(r'[\n;,]+'))
        .map((item) => item.replaceFirst(RegExp(r'^[-•]\s*'), '').trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> _splitQuestions(String value) {
    final clean = value.trim();
    if (clean.isEmpty) return const [];
    if (clean.contains('\n')) return _splitList(clean);
    return clean
        .split(RegExp(r'(?<=[?])\s+|;'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> _uniqueStrings(Iterable<String> values) {
    final result = <String>[];
    for (final value in values) {
      final clean = value.trim();
      if (clean.isEmpty || _containsSimilar(result, clean)) continue;
      result.add(clean);
    }
    return result;
  }

  bool _containsSimilar(Iterable<String> existingValues, String candidate) {
    final normalizedCandidate = _normalize(candidate);
    if (normalizedCandidate.isEmpty) return true;
    return existingValues.any((existing) {
      final normalizedExisting = _normalize(existing);
      if (normalizedExisting.isEmpty) return false;
      return normalizedExisting == normalizedCandidate ||
          normalizedExisting.contains(normalizedCandidate) ||
          normalizedCandidate.contains(normalizedExisting);
    });
  }

  bool _sameText(String a, String b) => _normalize(a) == _normalize(b);

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\wäöüß ]', unicode: true), '');
  }

  String _joinNonEmpty(Iterable<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join('\n\n');
  }

  List<String> _appendUnique(List<String> current, String value) {
    final clean = value.trim();
    if (clean.isEmpty || _containsSimilar(current, clean)) return current;
    return [...current, clean];
  }

  String _appendParagraph(String current, String addition) {
    final clean = addition.trim();
    if (clean.isEmpty || _containsSimilar([current], clean)) return current;
    if (current.trim().isEmpty) return clean;
    return '${current.trim()}\n\n$clean';
  }

  SourceMaterialType _inferSourceType(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('.pdf') || lower.contains('pdf')) {
      return SourceMaterialType.pdf;
    }
    if (lower.contains('review') ||
        lower.contains('rezension') ||
        lower.contains('testimonial')) {
      return SourceMaterialType.review;
    }
    if (lower.contains('instagram') ||
        lower.contains('facebook') ||
        lower.contains('youtube') ||
        lower.contains('social')) {
      return SourceMaterialType.social;
    }
    if (_extractUrl(value) != null || lower.contains('website')) {
      return SourceMaterialType.website;
    }
    return SourceMaterialType.note;
  }

  String? _extractUrl(String value) {
    final match = RegExp(r'https?://[^\s,;)]+').firstMatch(value);
    return match?.group(0);
  }

  List<String> _keywordsFromTitle(String title) {
    return title
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .map((word) => word.replaceAll(RegExp(r'[^\wäöüß]', unicode: true), ''))
        .where((word) => word.length > 3)
        .take(8)
        .toList();
  }

  void _updateSelectedWorkspace(CompanyWorkspace updated) {
    companies = [
      for (final workspace in companies)
        if (workspace.company.id == updated.company.id) updated else workspace,
    ];
    selectedCompanyId = updated.company.id;
  }

  static AppState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateScope>()!
        .notifier!;
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required super.notifier,
    required super.child,
  });
}
