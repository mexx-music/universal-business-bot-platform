import '../models/bot_configuration.dart';
import '../models/bot_question_log.dart';
import '../models/business_audit.dart';
import '../models/business_rules.dart';
import '../models/company.dart';
import '../models/company_workspace.dart';
import '../models/intake_invitation.dart';
import '../models/intake_session.dart';
import '../models/knowledge_entry.dart';
import '../models/product_or_service.dart';
import '../models/source_material.dart';
import 'intake_invitation_repository.dart';
import 'persistence/workspace_codec.dart';
import 'remote_workspace_data_source.dart';
import 'remote_workspace_exception.dart';
import 'remote_workspace_mapper.dart';
import 'tenant_context.dart';
import 'workspace_repository.dart';

class RemoteWorkspaceRepository
    implements
        WorkspaceRepository,
        IntakeInvitationRepository,
        ReloadableWorkspaceRepository {
  RemoteWorkspaceRepository._({
    required this.tenantContext,
    required RemoteWorkspaceDataSource dataSource,
    required RemoteWorkspaceMapper mapper,
    required List<CompanyWorkspace> companies,
    required String selectedCompanyId,
    required Map<String, String> workspaceIdsByCompanyId,
  }) : _companies = companies,
       _selectedCompanyId = selectedCompanyId,
       _dataSource = dataSource,
       _mapper = mapper,
       _workspaceIdsByCompanyId = workspaceIdsByCompanyId;

  static Future<RemoteWorkspaceRepository> open({
    required TenantContext tenantContext,
    required RemoteWorkspaceDataSource dataSource,
    RemoteWorkspaceMapper mapper = const RemoteWorkspaceMapper(),
  }) async {
    if (tenantContext.isLocal || tenantContext.tenantId.trim().isEmpty) {
      throw const MissingTenantException();
    }

    final rows = await dataSource.loadWorkspaceRows(tenantContext.tenantId);
    final companies = mapper.map(rows);
    final workspaceIdsByCompanyId = {
      for (final row in rows.companies)
        if (_rowString(row, 'id').isNotEmpty &&
            _rowString(row, 'workspace_id').isNotEmpty)
          _rowString(row, 'id'): _rowString(row, 'workspace_id'),
    };
    final selectedCompanyId = _selectedCompanyIdForContext(
      tenantContext,
      companies,
      workspaceIdsByCompanyId,
    );
    return RemoteWorkspaceRepository._(
      tenantContext: tenantContext,
      dataSource: dataSource,
      mapper: mapper,
      companies: companies,
      selectedCompanyId: selectedCompanyId,
      workspaceIdsByCompanyId: workspaceIdsByCompanyId,
    );
  }

  List<CompanyWorkspace> _companies;
  String _selectedCompanyId;
  final RemoteWorkspaceDataSource _dataSource;
  final RemoteWorkspaceMapper _mapper;
  final Map<String, String> _workspaceIdsByCompanyId;

  @override
  final TenantContext tenantContext;

  @override
  List<CompanyWorkspace> get companies => List.unmodifiable(_companies);

  @override
  String get selectedCompanyId => _selectedCompanyId;

  @override
  CompanyWorkspace get selectedWorkspace {
    if (_companies.isEmpty) throw StateError('No remote workspace is loaded.');
    return _companies.firstWhere(
      (workspace) => workspace.company.id == _selectedCompanyId,
      orElse: () => _companies.first,
    );
  }

  @override
  bool selectCompany(String companyId) {
    if (companyId == _selectedCompanyId) return false;
    if (!_companies.any((workspace) => workspace.company.id == companyId)) {
      return false;
    }
    _selectedCompanyId = companyId;
    return true;
  }

  @override
  CompanyWorkspace? findWorkspace(String companyId) {
    for (final workspace in _companies) {
      if (workspace.company.id == companyId) return workspace;
    }
    return null;
  }

  /// Block 22C is read-focused. Mutations update the in-memory snapshot so
  /// existing screens remain usable; durable cloud writes follow in 22D.
  @override
  Future<bool> saveWorkspace(String companyId, CompanyWorkspace updated) async {
    final index = _companies.indexWhere(
      (workspace) => workspace.company.id == companyId,
    );
    if (index == -1) return false;
    _companies = [
      ..._companies.take(index),
      updated,
      ..._companies.skip(index + 1),
    ];
    return true;
  }

  @override
  Future<void> saveSelectedWorkspace(CompanyWorkspace updated) async {
    await saveWorkspace(_selectedCompanyId, updated);
  }

  @override
  Future<void> reload() async {
    final rows = await _dataSource.loadWorkspaceRows(tenantContext.tenantId);
    _companies = _mapper.map(rows);
    _workspaceIdsByCompanyId
      ..clear()
      ..addAll({
        for (final row in rows.companies)
          if (_rowString(row, 'id').isNotEmpty &&
              _rowString(row, 'workspace_id').isNotEmpty)
            _rowString(row, 'id'): _rowString(row, 'workspace_id'),
      });
    if (!_companies.any(
      (workspace) => workspace.company.id == _selectedCompanyId,
    )) {
      _selectedCompanyId = _companies.isEmpty
          ? ''
          : _companies.first.company.id;
    }
  }

  @override
  Future<Company> updateCompany(
    Company company, {
    BusinessRules? businessRules,
    BotConfiguration? botConfiguration,
  }) async {
    _ensureWriteAllowed();
    final row = await _write(
      () => _dataSource.updateCompanyRow(
        tenantId: tenantContext.tenantId,
        workspaceId: _selectedWorkspaceId,
        payload: _companyPayload(
          company,
          businessRules: businessRules,
          botConfiguration: botConfiguration,
        ),
      ),
    );
    final saved = _mapper.companyFromRow(row);
    _replaceSelected(
      selectedWorkspace.copyWith(
        company: saved,
        businessRules: businessRules,
        botConfiguration: botConfiguration,
      ),
    );
    return saved;
  }

  @override
  Future<ProductOrService> createProduct(ProductOrService product) async {
    _ensureWriteAllowed();
    final row = await _write(
      () => _dataSource.insertRow('products', _productInsertPayload(product)),
    );
    final saved = _mapper.productFromRow(row);
    _replaceSelected(
      selectedWorkspace.copyWith(
        products: [...selectedWorkspace.products, saved],
      ),
    );
    return saved;
  }

  @override
  Future<ProductOrService> updateProduct(ProductOrService product) async {
    _ensureWriteAllowed();
    final row = await _write(
      () => _dataSource.updateTenantRow(
        table: 'products',
        tenantId: tenantContext.tenantId,
        workspaceId: _selectedWorkspaceId,
        id: product.id,
        payload: _productUpdatePayload(product),
      ),
    );
    final saved = _mapper.productFromRow(row);
    _replaceSelected(
      selectedWorkspace.copyWith(
        products: [
          for (final existing in selectedWorkspace.products)
            if (existing.id == saved.id) saved else existing,
        ],
      ),
    );
    return saved;
  }

  @override
  Future<void> deleteProduct(String id) async {
    _ensureDeleteAllowed();
    if (selectedWorkspace.knowledgeEntries.any((entry) => entry.source == id)) {
      throw const RepositoryValidationException(
        'Product is still referenced by knowledge entries.',
      );
    }
    await _write(
      () => _dataSource.deleteTenantRow(
        table: 'products',
        tenantId: tenantContext.tenantId,
        workspaceId: _selectedWorkspaceId,
        id: id,
      ),
    );
    _replaceSelected(
      selectedWorkspace.copyWith(
        products: selectedWorkspace.products
            .where((product) => product.id != id)
            .toList(),
      ),
    );
  }

  @override
  Future<KnowledgeEntry> createKnowledgeEntry(KnowledgeEntry entry) async {
    _ensureWriteAllowed();
    final row = await _write(
      () => _dataSource.insertRow(
        'knowledge_entries',
        _knowledgeInsertPayload(entry),
      ),
    );
    final saved = _mapper.knowledgeEntryFromRow(row);
    _replaceSelected(
      selectedWorkspace.copyWith(
        knowledgeEntries: [...selectedWorkspace.knowledgeEntries, saved],
      ),
    );
    return saved;
  }

  @override
  Future<KnowledgeEntry> updateKnowledgeEntry(KnowledgeEntry entry) async {
    _ensureWriteAllowed();
    final row = await _write(
      () => _dataSource.updateTenantRow(
        table: 'knowledge_entries',
        tenantId: tenantContext.tenantId,
        workspaceId: _selectedWorkspaceId,
        id: entry.id,
        payload: _knowledgeUpdatePayload(entry),
      ),
    );
    final saved = _mapper.knowledgeEntryFromRow(row);
    _replaceSelected(
      selectedWorkspace.copyWith(
        knowledgeEntries: [
          for (final existing in selectedWorkspace.knowledgeEntries)
            if (existing.id == saved.id) saved else existing,
        ],
      ),
    );
    return saved;
  }

  @override
  Future<void> deleteKnowledgeEntry(String id) async {
    _ensureDeleteAllowed();
    await _write(
      () => _dataSource.deleteTenantRow(
        table: 'knowledge_entries',
        tenantId: tenantContext.tenantId,
        workspaceId: _selectedWorkspaceId,
        id: id,
      ),
    );
    _replaceSelected(
      selectedWorkspace.copyWith(
        knowledgeEntries: selectedWorkspace.knowledgeEntries
            .where((entry) => entry.id != id)
            .toList(),
      ),
    );
  }

  @override
  Future<SourceMaterial> createSourceMaterial(SourceMaterial source) async {
    _ensureWriteAllowed();
    final row = await _write(
      () => _dataSource.insertRow(
        'source_materials',
        _sourceInsertPayload(source),
      ),
    );
    final saved = _mapper.sourceMaterialFromRow(row);
    _replaceSelected(
      selectedWorkspace.copyWith(
        sourceMaterials: [...selectedWorkspace.sourceMaterials, saved],
      ),
    );
    return saved;
  }

  @override
  Future<SourceMaterial> updateSourceMaterial(SourceMaterial source) async {
    _ensureWriteAllowed();
    final row = await _write(
      () => _dataSource.updateTenantRow(
        table: 'source_materials',
        tenantId: tenantContext.tenantId,
        workspaceId: _selectedWorkspaceId,
        id: source.id,
        payload: _sourceUpdatePayload(source),
      ),
    );
    final saved = _mapper.sourceMaterialFromRow(row);
    _replaceSelected(
      selectedWorkspace.copyWith(
        sourceMaterials: [
          for (final existing in selectedWorkspace.sourceMaterials)
            if (existing.id == saved.id) saved else existing,
        ],
      ),
    );
    return saved;
  }

  @override
  Future<void> deleteSourceMaterial(String id) async {
    _ensureDeleteAllowed();
    await _write(
      () => _dataSource.deleteTenantRow(
        table: 'source_materials',
        tenantId: tenantContext.tenantId,
        workspaceId: _selectedWorkspaceId,
        id: id,
      ),
    );
    _replaceSelected(
      selectedWorkspace.copyWith(
        sourceMaterials: selectedWorkspace.sourceMaterials
            .where((source) => source.id != id)
            .toList(),
      ),
    );
  }

  @override
  Future<BotQuestionLog> createBotQuestionLog(BotQuestionLog log) async {
    _ensureReviewWriteAllowed();
    final row = await _write(
      () =>
          _dataSource.insertRow('bot_question_logs', _botLogInsertPayload(log)),
    );
    final saved = _mapper.botLogFromRow(row);
    _replaceSelected(
      selectedWorkspace.copyWith(
        botLogs: [...selectedWorkspace.botLogs, saved],
      ),
    );
    return saved;
  }

  @override
  Future<BotQuestionLog> updateBotQuestionLog(BotQuestionLog log) async {
    _ensureReviewWriteAllowed();
    final row = await _write(
      () => _dataSource.updateTenantRow(
        table: 'bot_question_logs',
        tenantId: tenantContext.tenantId,
        workspaceId: _selectedWorkspaceId,
        id: log.id,
        payload: _botLogUpdatePayload(log),
      ),
    );
    final saved = _mapper.botLogFromRow(row);
    _replaceSelected(
      selectedWorkspace.copyWith(
        botLogs: [
          for (final existing in selectedWorkspace.botLogs)
            if (existing.id == saved.id) saved else existing,
        ],
      ),
    );
    return saved;
  }

  @override
  Future<BusinessAuditItem> updateAuditItem(BusinessAuditItem item) async {
    _ensureWriteAllowed();
    final row = await _write(
      () => _dataSource.updateTenantRow(
        table: 'audit_items',
        tenantId: tenantContext.tenantId,
        workspaceId: _selectedWorkspaceId,
        id: item.id,
        payload: _auditItemUpdatePayload(item),
      ),
    );
    final saved = _mapper.auditItemFromRow(row);
    _replaceSelected(
      selectedWorkspace.copyWith(
        auditItems: [
          for (final existing in selectedWorkspace.auditItems)
            if (existing.id == saved.id) saved else existing,
        ],
      ),
    );
    return saved;
  }

  @override
  Future<IntakeInvitation> createIntakeInvitation({
    required String greeting,
  }) async {
    _ensureWriteAllowed();
    final dataSource = _intakeInvitationDataSource;
    final row = await _write(
      () => dataSource.createIntakeInvitation(
        workspaceId: _selectedWorkspaceId,
        companyId: selectedWorkspace.company.id,
        greeting: greeting,
      ),
    );
    final invitation = _mapper.intakeInvitationFromRow(row);
    _replaceSelected(selectedWorkspace.copyWith(intakeInvitation: invitation));
    return invitation;
  }

  @override
  Future<IntakeInvitation> regenerateIntakeInvitation({
    String? greeting,
  }) async {
    _ensureWriteAllowed();
    final dataSource = _intakeInvitationDataSource;
    final row = await _write(
      () => dataSource.regenerateIntakeInvitation(
        workspaceId: _selectedWorkspaceId,
        companyId: selectedWorkspace.company.id,
        greeting: greeting,
      ),
    );
    final invitation = _mapper.intakeInvitationFromRow(row);
    _replaceSelected(selectedWorkspace.copyWith(intakeInvitation: invitation));
    return invitation;
  }

  @override
  Future<IntakeInvitation?> deactivateIntakeInvitation() async {
    _ensureWriteAllowed();
    final dataSource = _intakeInvitationDataSource;
    final row = await _write(
      () => dataSource.deactivateIntakeInvitation(
        workspaceId: _selectedWorkspaceId,
        companyId: selectedWorkspace.company.id,
      ),
    );
    if (row == null) return null;
    final invitation = _mapper.intakeInvitationFromRow(row);
    _replaceSelected(selectedWorkspace.copyWith(intakeInvitation: invitation));
    return invitation;
  }

  @override
  Future<IntakeSession> updateIntakeSession(
    IntakeSession session, {
    IntakeInvitation? invitation,
  }) async {
    _ensureWriteAllowed();
    final dataSource = _intakeInvitationDataSource;
    final row = await _write(
      () => dataSource.updateIntakeSession(
        workspaceId: _selectedWorkspaceId,
        companyId: selectedWorkspace.company.id,
        payload: _intakeSessionPayload(session),
      ),
    );
    final saved = _mapper.intakeSessionFromRow(row);
    _replaceSelected(
      selectedWorkspace.copyWith(
        intakeSession: saved,
        intakeInvitation: invitation ?? selectedWorkspace.intakeInvitation,
      ),
    );
    return saved;
  }

  @override
  Future<IntakeSession> resetIntakeSession(
    IntakeSession session, {
    IntakeInvitation? invitation,
  }) async {
    _ensureWriteAllowed();
    final dataSource = _intakeInvitationDataSource;
    final row = await _write(
      () => dataSource.resetIntakeSession(
        workspaceId: _selectedWorkspaceId,
        companyId: selectedWorkspace.company.id,
      ),
    );
    final saved = _mapper.intakeSessionFromRow(_map(row['intakeSession']));
    final savedInvitation = row['invitation'] is Map
        ? _mapper.intakeInvitationFromRow(_map(row['invitation']))
        : invitation ?? selectedWorkspace.intakeInvitation;
    _replaceSelected(
      selectedWorkspace.copyWith(
        intakeSession: saved,
        intakeInvitation: savedInvitation,
      ),
    );
    return saved;
  }

  @override
  Future<void> clear() async {
    _companies = const [];
    _selectedCompanyId = '';
  }

  String get _selectedWorkspaceId {
    final workspaceId = _workspaceIdsByCompanyId[_selectedCompanyId];
    if (workspaceId == null || workspaceId.isEmpty) {
      throw const NoActiveWorkspaceException();
    }
    return workspaceId;
  }

  RemoteIntakeInvitationDataSource get _intakeInvitationDataSource {
    final dataSource = _dataSource;
    if (dataSource is RemoteIntakeInvitationDataSource) {
      return dataSource as RemoteIntakeInvitationDataSource;
    }
    throw const RepositoryTechnicalException(
      'Remote intake invitations are not supported by this data source.',
    );
  }

  void _ensureWriteAllowed() {
    if (tenantContext.tenantId.trim().isEmpty) {
      throw const MissingTenantException();
    }
    if (!tenantContext.canWriteContent) {
      throw const NoWritePermissionException();
    }
  }

  void _ensureReviewWriteAllowed() {
    if (tenantContext.tenantId.trim().isEmpty) {
      throw const MissingTenantException();
    }
    if (!tenantContext.canReviewContent) {
      throw const NoWritePermissionException();
    }
  }

  void _ensureDeleteAllowed() {
    if (tenantContext.tenantId.trim().isEmpty) {
      throw const MissingTenantException();
    }
    if (!tenantContext.canDeleteContent) {
      throw const NoWritePermissionException();
    }
  }

  Future<T> _write<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on RemoteWorkspaceException catch (error) {
      final message = error.cause?.toString().toLowerCase() ?? error.message;
      if (message.contains('permission') ||
          message.contains('row-level security')) {
        throw RepositoryTechnicalException(
          'Remote workspace write was rejected by the database.',
          error,
        );
      }
      if (message.contains('0 rows') ||
          message.contains('json object requested') ||
          message.contains('not found')) {
        throw const RepositoryRecordNotFoundException();
      }
      if (message.contains('check constraint') ||
          message.contains('violates')) {
        throw RepositoryValidationException(
          'Remote workspace data failed validation.',
          error,
        );
      }
      rethrow;
    } catch (error) {
      throw RepositoryTechnicalException(
        'Remote workspace write failed.',
        error,
      );
    }
  }

  void _replaceSelected(CompanyWorkspace updated) {
    final index = _companies.indexWhere(
      (workspace) => workspace.company.id == updated.company.id,
    );
    if (index == -1) return;
    _companies = [
      ..._companies.take(index),
      updated,
      ..._companies.skip(index + 1),
    ];
    _selectedCompanyId = updated.company.id;
  }

  Map<String, Object?> _baseInsertPayload(String id) => {
    'tenant_id': tenantContext.tenantId,
    'workspace_id': _selectedWorkspaceId,
    'company_id': selectedWorkspace.company.id,
    'id': id,
  };

  Map<String, Object?> _companyPayload(
    Company company, {
    BusinessRules? businessRules,
    BotConfiguration? botConfiguration,
  }) {
    return {
      'company_name': company.name.trim(),
      'short_description': company.description.trim(),
      'industry': company.industry.trim(),
      'country': company.country.trim(),
      'primary_language': company.primaryLanguage.trim().isEmpty
          ? 'de'
          : company.primaryLanguage.trim(),
      'website': company.website.trim(),
      'support_email': company.email.trim(),
      'support_phone': _nullableText(company.phone),
      'social_links': company.socialLinks,
      if (businessRules != null)
        'business_rules': _businessRulesJson(businessRules),
      if (botConfiguration != null)
        'bot_configuration': _botConfigurationJson(botConfiguration),
      'internal_notes': company.internalNotes.trim(),
    };
  }

  Map<String, Object?> _productInsertPayload(ProductOrService product) => {
    ..._baseInsertPayload(product.id),
    ..._productUpdatePayload(product),
    'priority': selectedWorkspace.products.length,
  };

  Map<String, Object?> _productUpdatePayload(ProductOrService product) => {
    'name': product.name.trim(),
    'description': product.description.trim(),
    'type': product.type == ProductType.dienstleistung ? 'service' : 'product',
    'price_note': product.price?.toString(),
  };

  Map<String, Object?> _knowledgeInsertPayload(KnowledgeEntry entry) => {
    ..._baseInsertPayload(entry.id),
    ..._knowledgeUpdatePayload(entry),
  };

  Map<String, Object?> _knowledgeUpdatePayload(KnowledgeEntry entry) => {
    'title': entry.title.trim(),
    'content': entry.content.trim(),
    'category': entry.category.name,
    'risk_level': entry.riskLevel.name,
    'keywords': entry.keywords,
    'source': entry.source.trim(),
    'language_code': entry.languageCode?.trim().isNotEmpty == true
        ? entry.languageCode!.trim()
        : selectedWorkspace.company.primaryLanguage,
  };

  Map<String, Object?> _sourceInsertPayload(SourceMaterial source) => {
    ..._baseInsertPayload(source.id),
    ..._sourceUpdatePayload(source),
  };

  Map<String, Object?> _sourceUpdatePayload(SourceMaterial source) => {
    'title': source.title.trim(),
    'type': source.type.name,
    'url': _nullableText(source.url),
    'content_snippet': _nullableText(source.contentSnippet),
    'status': source.status == SourceMaterialStatus.newItem
        ? 'new'
        : source.status.name,
    'related_knowledge_entry_ids': source.relatedKnowledgeEntryIds,
    'notes': _nullableText(source.notes),
  };

  Map<String, Object?> _botLogInsertPayload(BotQuestionLog log) => {
    ..._baseInsertPayload(log.id),
    ..._botLogUpdatePayload(log),
    'language_code': selectedWorkspace.company.primaryLanguage.trim().isEmpty
        ? 'de'
        : selectedWorkspace.company.primaryLanguage.trim(),
  };

  Map<String, Object?> _botLogUpdatePayload(BotQuestionLog log) => {
    'question': log.question.trim(),
    'answer': _nullableText(log.answer),
    'matched': log.matched,
    'redirected': log.redirected,
    'reason': log.reviewReason?.name,
    'risk_level': _riskLevelForLog(log).name,
    'review_status': log.reviewStatus.name,
    'reviewed_at': log.reviewedAt?.toIso8601String(),
    'human_note': _nullableText(log.humanNote),
  };

  Map<String, Object?> _auditItemUpdatePayload(BusinessAuditItem item) => {
    'area': item.area.name,
    'title': item.title.trim(),
    'description': item.description.trim(),
    'status': item.status.name,
    'priority': item.priority.name,
    'note': _nullableText(item.note),
    'recommendation': _nullableText(item.recommendation),
  };

  Map<String, Object?> _intakeSessionPayload(IntakeSession session) {
    final json = WorkspaceCodec.encodeIntakeSession(session);
    return {
      'tenant_id': tenantContext.tenantId,
      'workspace_id': _selectedWorkspaceId,
      'company_id': selectedWorkspace.company.id,
      'id': session.id,
      'status': session.status.name,
      'current_step': session.currentStepIndex,
      'chat_started_at': session.chatStartedAt?.toIso8601String(),
      'chat_updated_at': session.chatUpdatedAt?.toIso8601String(),
      'chat_completed_at': session.chatCompletedAt?.toIso8601String(),
      'chat_current_question_index': session.chatCurrentQuestionIndex,
      'skipped_question_keys': session.skippedQuestionKeys,
      'deferred_question_keys': session.deferredQuestionKeys,
      'basics': json['basics'] ?? const <String, Object?>{},
      'products': json['products'] ?? const <String, Object?>{},
      'target_groups': json['targetGroups'] ?? const <String, Object?>{},
      'website_support': json['websiteAndSupport'] ?? const <String, Object?>{},
      'sources_reviews': json['sourcesAndReviews'] ?? const <String, Object?>{},
      'marketing': json['marketingAndChannels'] ?? const <String, Object?>{},
      'goals_risks': json['goalsAndRisks'] ?? const <String, Object?>{},
    };
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map) return value.cast<String, Object?>();
    return const <String, Object?>{};
  }

  Map<String, Object?> _businessRulesJson(BusinessRules rules) => {
    'brandVoice': rules.brandVoice,
    'doNotSay': rules.doNotSay,
    'noGoRules': rules.doNotSay,
    'allowedSupportTopics': rules.allowedSupportTopics,
    'escalationNotes': rules.escalationNotes,
    'disclaimerText': rules.disclaimerText,
  };

  Map<String, Object?> _botConfigurationJson(BotConfiguration config) => {
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
  };

  RiskLevel _riskLevelForLog(BotQuestionLog log) {
    return switch (log.reviewReason) {
      ReviewReason.redFlag => RiskLevel.red,
      ReviewReason.yellowRisk || ReviewReason.lowConfidence => RiskLevel.yellow,
      ReviewReason.noMatch || null => RiskLevel.green,
    };
  }

  String? _nullableText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static String _rowString(Map<String, Object?> row, String key) {
    return row[key]?.toString().trim() ?? '';
  }

  static String _selectedCompanyIdForContext(
    TenantContext tenantContext,
    List<CompanyWorkspace> companies,
    Map<String, String> workspaceIdsByCompanyId,
  ) {
    if (companies.isEmpty) return '';
    final workspaceId = tenantContext.workspaceId;
    if (workspaceId == null || workspaceId.trim().isEmpty) {
      return companies.first.company.id;
    }
    for (final entry in workspaceIdsByCompanyId.entries) {
      if (entry.value == workspaceId) return entry.key;
    }
    return companies.first.company.id;
  }
}
