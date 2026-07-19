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
import '../repositories/persistence/workspace_codec.dart';
import '../repositories/remote_workspace_exception.dart';
import '../repositories/tenant_context.dart';
import '../repositories/workspace_repository.dart';
import 'public_intake_service.dart';

class PublicIntakeWorkspaceRepository implements WorkspaceRepository {
  PublicIntakeWorkspaceRepository({
    required String token,
    required PublicIntakeService service,
    required CompanyWorkspace workspace,
  }) : _token = token,
       _service = service,
       _workspace = workspace;

  final String _token;
  final PublicIntakeService _service;
  CompanyWorkspace _workspace;

  @override
  TenantContext get tenantContext => const TenantContext(
    tenantId: 'public-intake',
    userId: 'public-intake',
    role: 'viewer',
  );

  @override
  List<CompanyWorkspace> get companies => [_workspace];

  @override
  String get selectedCompanyId => _workspace.company.id;

  @override
  CompanyWorkspace get selectedWorkspace => _workspace;

  @override
  bool selectCompany(String companyId) => companyId == _workspace.company.id;

  @override
  CompanyWorkspace? findWorkspace(String companyId) =>
      companyId == _workspace.company.id ? _workspace : null;

  @override
  Future<bool> saveWorkspace(String companyId, CompanyWorkspace updated) async {
    if (companyId != _workspace.company.id) return false;
    await saveSelectedWorkspace(updated);
    return true;
  }

  @override
  Future<void> saveSelectedWorkspace(CompanyWorkspace updated) async {
    if (updated.company.id != _workspace.company.id) {
      throw const NoActiveWorkspaceException();
    }
    final previous = _workspace;
    _workspace = updated;
    final session = updated.intakeSession;
    if (session == null ||
        !_shouldSaveSession(previous.intakeSession, session)) {
      return;
    }
    final response = await _service.save(token: _token, session: session);
    final saved = response.workspace;
    if (response.status == PublicIntakeRemoteStatus.opened && saved != null) {
      _workspace = saved;
    } else if (response.status == PublicIntakeRemoteStatus.disabled) {
      throw const NoWritePermissionException();
    } else if (response.status == PublicIntakeRemoteStatus.remoteError ||
        response.status == PublicIntakeRemoteStatus.notConfigured) {
      throw const RepositoryTechnicalException(
        'The public questionnaire could not be saved remotely.',
      );
    } else {
      throw const RepositoryRecordNotFoundException();
    }
  }

  @override
  Future<IntakeSession> resetIntakeSession(
    IntakeSession session, {
    IntakeInvitation? invitation,
  }) async {
    throw const NoWritePermissionException();
  }

  @override
  Future<Company> updateCompany(
    Company company, {
    BusinessRules? businessRules,
    BotConfiguration? botConfiguration,
  }) async {
    throw const NoWritePermissionException();
  }

  @override
  Future<ProductOrService> createProduct(ProductOrService product) async {
    throw const NoWritePermissionException();
  }

  @override
  Future<ProductOrService> updateProduct(ProductOrService product) async {
    throw const NoWritePermissionException();
  }

  @override
  Future<void> deleteProduct(String id) async {
    throw const NoWritePermissionException();
  }

  @override
  Future<KnowledgeEntry> createKnowledgeEntry(KnowledgeEntry entry) async {
    throw const NoWritePermissionException();
  }

  @override
  Future<KnowledgeEntry> updateKnowledgeEntry(KnowledgeEntry entry) async {
    throw const NoWritePermissionException();
  }

  @override
  Future<void> deleteKnowledgeEntry(String id) async {
    throw const NoWritePermissionException();
  }

  @override
  Future<SourceMaterial> createSourceMaterial(SourceMaterial source) async {
    throw const NoWritePermissionException();
  }

  @override
  Future<SourceMaterial> updateSourceMaterial(SourceMaterial source) async {
    throw const NoWritePermissionException();
  }

  @override
  Future<void> deleteSourceMaterial(String id) async {
    throw const NoWritePermissionException();
  }

  @override
  Future<BotQuestionLog> createBotQuestionLog(BotQuestionLog log) async {
    throw const NoWritePermissionException();
  }

  @override
  Future<BotQuestionLog> updateBotQuestionLog(BotQuestionLog log) async {
    throw const NoWritePermissionException();
  }

  @override
  Future<BusinessAuditItem> updateAuditItem(BusinessAuditItem item) async {
    throw const NoWritePermissionException();
  }

  @override
  Future<void> clear() async {}

  bool _shouldSaveSession(IntakeSession? previous, IntakeSession current) {
    if (previous == null) return true;
    final previousJson = Map<String, Object?>.from(
      WorkspaceCodec.encodeIntakeSession(previous),
    );
    final currentJson = Map<String, Object?>.from(
      WorkspaceCodec.encodeIntakeSession(current),
    );
    for (final key in ['updatedAt', 'chatStartedAt', 'chatUpdatedAt']) {
      previousJson.remove(key);
      currentJson.remove(key);
    }
    return previousJson.toString() != currentJson.toString();
  }
}
