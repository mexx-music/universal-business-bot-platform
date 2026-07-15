import '../models/business_audit.dart';
import '../models/bot_configuration.dart';
import '../models/company.dart';
import '../models/company_workspace.dart';
import '../models/intake_mapping_preview.dart';
import '../models/knowledge_entry.dart';
import '../models/product_or_service.dart';
import '../models/source_material.dart';

class IntakeMappingService {
  const IntakeMappingService();

  IntakeMappingPreview createPreview(CompanyWorkspace workspace) {
    final session = workspace.intakeSession;
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
      current: workspace.company.name,
    );
    addCompanyField(
      fieldKey: 'description',
      label: 'Short description',
      proposed: basics.shortDescription,
      current: workspace.company.description,
    );
    addCompanyField(
      fieldKey: 'industry',
      label: 'Industry',
      proposed: basics.industry,
      current: workspace.company.industry,
    );
    addCompanyField(
      fieldKey: 'country',
      label: 'Country',
      proposed: basics.country,
      current: workspace.company.country,
    );
    addCompanyField(
      fieldKey: 'primaryLanguage',
      label: 'Primary language',
      proposed: basics.primaryLanguage,
      current: workspace.company.primaryLanguage,
    );
    addCompanyField(
      fieldKey: 'website',
      label: 'Website',
      proposed: session.websiteAndSupport.websiteUrl.trim().isEmpty
          ? basics.website
          : session.websiteAndSupport.websiteUrl,
      current: workspace.company.website,
    );
    addCompanyField(
      fieldKey: 'email',
      label: 'Support email',
      proposed: basics.supportEmail,
      current: workspace.company.email,
    );
    addCompanyField(
      fieldKey: 'phone',
      label: 'Support phone',
      proposed: basics.supportPhone,
      current: workspace.company.supportPhone,
    );

    final existingProductNames = workspace.products.map(
      (product) => product.name,
    );
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
        !_containsSimilar([workspace.company.internalNotes], positioningNote)) {
      suggestions.add(
        IntakeMappingSuggestion(
          id: nextId('note'),
          targetArea: IntakeMappingTargetArea.internalNotes,
          action: IntakeMappingAction.appendInternalNote,
          label: 'Positioning / marketing notes',
          proposedValue: positioningNote,
          currentValue: workspace.company.internalNotes.trim().isEmpty
              ? null
              : workspace.company.internalNotes.trim(),
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
      if (_containsSimilar(
        workspace.businessRules.allowedSupportTopics,
        topic,
      )) {
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
      if (!_containsSimilar(workspace.businessRules.doNotSay, topic)) {
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
      if (!_containsSimilar(workspace.botConfiguration.blockedTopics, topic)) {
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
        !_containsSimilar([
          workspace.businessRules.escalationNotes,
        ], escalationNotes)) {
      suggestions.add(
        IntakeMappingSuggestion(
          id: nextId('escalation'),
          targetArea: IntakeMappingTargetArea.businessRules,
          action: IntakeMappingAction.appendEscalationNotes,
          label: 'Escalation notes',
          proposedValue: escalationNotes,
          currentValue: workspace.businessRules.escalationNotes.trim().isEmpty
              ? null
              : workspace.businessRules.escalationNotes.trim(),
          conflict: false,
          selected: true,
        ),
      );
    }

    if (riskTopics.isNotEmpty &&
        !workspace.botConfiguration.alwaysEscalateRedFlags) {
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
        !_sameText(handover, workspace.botConfiguration.handoverMessage)) {
      final conflict = workspace.botConfiguration.handoverMessage
          .trim()
          .isNotEmpty;
      suggestions.add(
        IntakeMappingSuggestion(
          id: nextId('handover'),
          targetArea: IntakeMappingTargetArea.botSettings,
          action: IntakeMappingAction.setBotHandoverMessage,
          label: 'Handover message',
          proposedValue: handover,
          currentValue:
              workspace.botConfiguration.handoverMessage.trim().isEmpty
              ? null
              : workspace.botConfiguration.handoverMessage.trim(),
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
        workspace.knowledgeEntries.map((entry) => entry.title),
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
        workspace.knowledgeEntries.map((entry) => entry.title),
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
    final existingSourceTitles = workspace.sourceMaterials.map(
      (source) => source.title,
    );
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
      final areaItems = workspace.auditItems
          .where((item) => item.area == area)
          .toList();
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
      workspace.botConfiguration.status == BotStatus.draft
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

  CompanyWorkspace importSelectedMapping(
    CompanyWorkspace workspace,
    IntakeMappingPreview preview,
  ) {
    final selected = preview.suggestions.where((s) => s.selected).toList();
    if (selected.isEmpty) return workspace;

    final now = DateTime.now();
    var updatedCompany = workspace.company;
    var updatedProducts = [...workspace.products];
    var updatedRules = workspace.businessRules;
    var updatedSources = [...workspace.sourceMaterials];
    var updatedKnowledge = [...workspace.knowledgeEntries];
    var updatedAuditItems = [...workspace.auditItems];
    var updatedBotConfig = workspace.botConfiguration;

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

    return workspace.copyWith(
      company: updatedCompany,
      products: updatedProducts,
      businessRules: updatedRules,
      sourceMaterials: updatedSources,
      knowledgeEntries: updatedKnowledge,
      auditItems: updatedAuditItems,
      botConfiguration: updatedBotConfig,
      intakeSession: workspace.intakeSession?.copyWith(
        importedAt: now,
        updatedAt: now,
      ),
    );
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
}
