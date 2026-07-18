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
import 'persistence/workspace_codec.dart';
import 'remote_workspace_data_source.dart';

class RemoteWorkspaceMapper {
  const RemoteWorkspaceMapper();

  List<CompanyWorkspace> map(RemoteWorkspaceSnapshotRows rows) {
    final companiesByWorkspace = {
      for (final row in rows.companies) _string(row, 'workspace_id'): row,
    };

    final productsByWorkspace = _groupByWorkspace(rows.products);
    final knowledgeByWorkspace = _groupByWorkspace(rows.knowledgeEntries);
    final sourcesByWorkspace = _groupByWorkspace(rows.sourceMaterials);
    final logsByWorkspace = _groupByWorkspace(rows.botQuestionLogs);
    final auditByWorkspace = _groupByWorkspace(rows.auditItems);
    final intakeByWorkspace = _groupByWorkspace(rows.intakeSessions);
    final invitationsByWorkspace = _groupByWorkspace(rows.intakeInvitations);

    final workspaces = <CompanyWorkspace>[];
    for (final workspaceRow in rows.workspaces) {
      final workspaceId = _string(workspaceRow, 'id');
      final companyRow = companiesByWorkspace[workspaceId];
      if (workspaceId.isEmpty || companyRow == null) continue;

      workspaces.add(
        CompanyWorkspace(
          company: _company(companyRow),
          products: [
            for (final row in productsByWorkspace[workspaceId] ?? const [])
              _product(row),
          ],
          knowledgeEntries: [
            for (final row in knowledgeByWorkspace[workspaceId] ?? const [])
              _knowledgeEntry(row),
          ],
          botLogs: [
            for (final row in logsByWorkspace[workspaceId] ?? const [])
              _botLog(row),
          ],
          auditItems: [
            for (final row in auditByWorkspace[workspaceId] ?? const [])
              _auditItem(row),
          ],
          businessRules: _businessRules(_map(companyRow, 'business_rules')),
          botConfiguration: _botConfiguration(
            _map(companyRow, 'bot_configuration'),
          ),
          sourceMaterials: [
            for (final row in sourcesByWorkspace[workspaceId] ?? const [])
              _sourceMaterial(row),
          ],
          intakeSession: (intakeByWorkspace[workspaceId]?.isNotEmpty ?? false)
              ? _intakeSession(intakeByWorkspace[workspaceId]!.last)
              : null,
          intakeInvitation:
              (invitationsByWorkspace[workspaceId]?.isNotEmpty ?? false)
              ? _intakeInvitation(invitationsByWorkspace[workspaceId]!.last)
              : null,
        ),
      );
    }
    return workspaces;
  }

  Company companyFromRow(Map<String, Object?> row) => _company(row);

  ProductOrService productFromRow(Map<String, Object?> row) => _product(row);

  KnowledgeEntry knowledgeEntryFromRow(Map<String, Object?> row) =>
      _knowledgeEntry(row);

  SourceMaterial sourceMaterialFromRow(Map<String, Object?> row) =>
      _sourceMaterial(row);

  BotQuestionLog botLogFromRow(Map<String, Object?> row) => _botLog(row);

  BusinessAuditItem auditItemFromRow(Map<String, Object?> row) =>
      _auditItem(row);

  IntakeSession intakeSessionFromRow(Map<String, Object?> row) =>
      _intakeSession(row);

  IntakeInvitation intakeInvitationFromRow(Map<String, Object?> row) =>
      _intakeInvitation(row);

  Map<String, List<Map<String, Object?>>> _groupByWorkspace(
    List<Map<String, Object?>> rows,
  ) {
    final grouped = <String, List<Map<String, Object?>>>{};
    for (final row in rows) {
      final workspaceId = _string(row, 'workspace_id');
      if (workspaceId.isEmpty) continue;
      grouped.putIfAbsent(workspaceId, () => []).add(row);
    }
    return grouped;
  }

  Company _company(Map<String, Object?> row) {
    return Company(
      id: _string(row, 'id'),
      name: _string(row, 'company_name'),
      industry: _string(row, 'industry'),
      description: _string(row, 'short_description'),
      country: _string(row, 'country'),
      primaryLanguage: _string(row, 'primary_language', 'de'),
      website: _string(row, 'website'),
      email: _string(row, 'support_email'),
      phone: _stringOrNull(row, 'support_phone'),
      address: '',
      socialLinks: _stringMap(_map(row, 'social_links')),
      internalNotes: _string(row, 'internal_notes'),
    );
  }

  ProductOrService _product(Map<String, Object?> row) {
    return ProductOrService(
      id: _string(row, 'id'),
      name: _string(row, 'name'),
      description: _string(row, 'description'),
      type: _productType(row['type']),
    );
  }

  KnowledgeEntry _knowledgeEntry(Map<String, Object?> row) {
    return KnowledgeEntry(
      id: _string(row, 'id'),
      title: _string(row, 'title'),
      content: _string(row, 'content'),
      category: _knowledgeCategory(row['category']),
      riskLevel: _riskLevel(row['risk_level']),
      keywords: _stringList(row['keywords']),
      source: _string(row, 'source'),
      createdAt: _dateTime(row['created_at']),
      languageCode: _stringOrNull(row, 'language_code'),
    );
  }

  SourceMaterial _sourceMaterial(Map<String, Object?> row) {
    return SourceMaterial(
      id: _string(row, 'id'),
      title: _string(row, 'title'),
      type: _sourceType(row['type']),
      url: _stringOrNull(row, 'url'),
      contentSnippet: _stringOrNull(row, 'content_snippet'),
      status: _sourceStatus(row['status']),
      relatedKnowledgeEntryIds: _stringList(row['related_knowledge_entry_ids']),
      createdAt: _dateTime(row['created_at']),
      updatedAt: _dateTime(row['updated_at']),
      notes: _stringOrNull(row, 'notes'),
    );
  }

  BotQuestionLog _botLog(Map<String, Object?> row) {
    return BotQuestionLog(
      id: _string(row, 'id'),
      question: _string(row, 'question'),
      answer: _stringOrNull(row, 'answer'),
      matched: _bool(row['matched']),
      redirected: _bool(row['redirected']),
      timestamp: _dateTime(row['created_at']),
      reviewStatus: _reviewStatus(row['review_status']),
      reviewReason: _reviewReason(row['reason'], row['risk_level']),
      humanNote: _stringOrNull(row, 'human_note'),
      reviewedAt: _dateTimeOrNull(row['reviewed_at']),
    );
  }

  BusinessAuditItem _auditItem(Map<String, Object?> row) {
    return BusinessAuditItem(
      id: _string(row, 'id'),
      area: _auditArea(row['area']),
      title: _string(row, 'title'),
      description: _string(row, 'description'),
      status: _auditStatus(row['status']),
      priority: _auditPriority(row['priority']),
      note: _stringOrNull(row, 'note'),
      recommendation: _stringOrNull(row, 'recommendation'),
    );
  }

  IntakeInvitation _intakeInvitation(Map<String, Object?> row) {
    return IntakeInvitation(
      id: _string(row, 'id'),
      token: _string(row, 'token'),
      status: _enumByName(
        IntakeInvitationStatus.values,
        _normalized(row['status']),
        IntakeInvitationStatus.invited,
      ),
      greeting: _string(row, 'greeting'),
      createdAt: _dateTime(row['created_at']),
      updatedAt: _dateTime(row['updated_at']),
      startedAt: _dateTimeOrNull(row['started_at']),
      completedAt: _dateTimeOrNull(row['completed_at']),
      disabledAt: _dateTimeOrNull(row['disabled_at']),
    );
  }

  IntakeSession _intakeSession(Map<String, Object?> row) {
    return WorkspaceCodec.decodeIntakeSession({
      'id': _string(row, 'id'),
      'companyId': _string(row, 'company_id'),
      'status': _string(row, 'status', 'draft'),
      'currentStepIndex': _int(row['current_step']),
      'createdAt': _dateTime(row['created_at']).toIso8601String(),
      'updatedAt': _dateTime(row['updated_at']).toIso8601String(),
      'importedAt': _dateTimeOrNull(row['imported_at'])?.toIso8601String(),
      'chatStartedAt': _dateTimeOrNull(
        row['chat_started_at'],
      )?.toIso8601String(),
      'chatUpdatedAt': _dateTimeOrNull(
        row['chat_updated_at'],
      )?.toIso8601String(),
      'chatCompletedAt': _dateTimeOrNull(
        row['chat_completed_at'],
      )?.toIso8601String(),
      'chatCurrentQuestionIndex': _int(row['chat_current_question_index']),
      'skippedQuestionKeys': _stringList(row['skipped_question_keys']),
      'deferredQuestionKeys': _stringList(row['deferred_question_keys']),
      'basics': _map(row, 'basics'),
      'products': _map(row, 'products'),
      'targetGroups': _map(row, 'target_groups'),
      'websiteAndSupport': _map(row, 'website_support'),
      'sourcesAndReviews': _map(row, 'sources_reviews'),
      'marketingAndChannels': _map(row, 'marketing'),
      'goalsAndRisks': _map(row, 'goals_risks'),
    });
  }

  BusinessRules _businessRules(Map<String, Object?> json) {
    return BusinessRules(
      brandVoice: _string(json, 'brandVoice'),
      doNotSay: _stringList(json['noGoRules']).isNotEmpty
          ? _stringList(json['noGoRules'])
          : _stringList(json['doNotSay']),
      allowedSupportTopics: _stringList(json['allowedSupportTopics']),
      escalationNotes: _string(json, 'escalationNotes'),
      disclaimerText: _stringOrNull(json, 'disclaimerText'),
    );
  }

  BotConfiguration _botConfiguration(Map<String, Object?> json) {
    return BotConfiguration(
      status: _botStatus(json['status']),
      answerStyle: _answerStyle(json['answerStyle']),
      defaultLanguage: _string(json, 'defaultLanguage', 'de'),
      useDisclaimer: _bool(json['useDisclaimer']),
      disclaimerText: _string(json, 'disclaimerText'),
      alwaysEscalateRedFlags: _bool(json['alwaysEscalateRedFlags'], true),
      escalateNoMatch: _bool(json['escalateNoMatch'], true),
      escalateYellowRisk: _bool(json['escalateYellowRisk']),
      allowedTopics: _stringList(json['allowedTopics']),
      blockedTopics: _stringList(json['blockedTopics']),
      handoverMessage: _string(json, 'handoverMessage'),
    );
  }

  ProductType _productType(Object? value) {
    return switch (_normalized(value)) {
      'service' || 'dienstleistung' => ProductType.dienstleistung,
      _ => ProductType.produkt,
    };
  }

  KnowledgeCategory _knowledgeCategory(Object? value) {
    return _enumByName(
      KnowledgeCategory.values,
      _normalized(value) == 'product' ? 'produkt' : _normalized(value),
      KnowledgeCategory.faq,
    );
  }

  RiskLevel _riskLevel(Object? value) =>
      _enumByName(RiskLevel.values, _normalized(value), RiskLevel.green);

  SourceMaterialType _sourceType(Object? value) => _enumByName(
    SourceMaterialType.values,
    _normalized(value),
    SourceMaterialType.other,
  );

  SourceMaterialStatus _sourceStatus(Object? value) {
    final normalized = _normalized(value);
    return _enumByName(
      SourceMaterialStatus.values,
      normalized == 'new' ? 'newItem' : normalized,
      SourceMaterialStatus.newItem,
    );
  }

  ReviewStatus _reviewStatus(Object? value) =>
      _enumByName(ReviewStatus.values, _normalized(value), ReviewStatus.open);

  ReviewReason? _reviewReason(Object? reason, Object? riskLevel) {
    final normalized = _normalized(reason);
    final parsed = _enumByNameOrNull(ReviewReason.values, normalized);
    if (parsed != null) return parsed;
    return switch (_normalized(riskLevel)) {
      'red' => ReviewReason.redFlag,
      'yellow' => ReviewReason.yellowRisk,
      _ => null,
    };
  }

  AuditArea _auditArea(Object? value) => _enumByName(
    AuditArea.values,
    _normalized(value),
    AuditArea.companyProfile,
  );

  AuditItemStatus _auditStatus(Object? value) => _enumByName(
    AuditItemStatus.values,
    _normalized(value),
    AuditItemStatus.missing,
  );

  AuditPriority _auditPriority(Object? value) => _enumByName(
    AuditPriority.values,
    _normalized(value),
    AuditPriority.medium,
  );

  BotStatus _botStatus(Object? value) =>
      _enumByName(BotStatus.values, _normalized(value), BotStatus.draft);

  BotAnswerStyle _answerStyle(Object? value) => _enumByName(
    BotAnswerStyle.values,
    _normalized(value),
    BotAnswerStyle.balanced,
  );

  T _enumByName<T extends Enum>(List<T> values, String name, T fallback) {
    return _enumByNameOrNull(values, name) ?? fallback;
  }

  T? _enumByNameOrNull<T extends Enum>(List<T> values, String name) {
    if (name.isEmpty) return null;
    for (final value in values) {
      if (value.name.toLowerCase() == name.toLowerCase()) return value;
    }
    return null;
  }

  String _normalized(Object? value) => value?.toString().trim() ?? '';

  String _string(
    Map<String, Object?> json,
    String key, [
    String fallback = '',
  ]) {
    final value = json[key];
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String? _stringOrNull(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  bool _bool(Object? value, [bool fallback = false]) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return fallback;
  }

  int _int(Object? value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  List<String> _stringList(Object? value) {
    if (value is Iterable) {
      return [
        for (final item in value)
          if (item != null && item.toString().trim().isNotEmpty)
            item.toString().trim(),
      ];
    }
    if (value is String && value.trim().isNotEmpty) return [value.trim()];
    return const [];
  }

  Map<String, Object?> _map(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is Map) return value.cast<String, Object?>();
    return const {};
  }

  Map<String, String> _stringMap(Map<String, Object?> json) {
    return {
      for (final entry in json.entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    };
  }

  DateTime _dateTime(Object? value) {
    return _dateTimeOrNull(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime? _dateTimeOrNull(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
