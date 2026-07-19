import '../models/company_workspace.dart';
import '../models/bot_configuration.dart';
import '../models/bot_question_log.dart';
import '../models/business_audit.dart';
import '../models/business_rules.dart';
import '../models/company.dart';
import '../models/intake_invitation.dart';
import '../models/intake_session.dart';
import '../models/knowledge_entry.dart';
import '../models/product_or_service.dart';
import '../models/source_material.dart';
import 'remote_workspace_exception.dart';
import 'tenant_context.dart';
import 'workspace_repository.dart';

class EmptyWorkspaceRepository implements WorkspaceRepository {
  EmptyWorkspaceRepository({required this.tenantContext});

  @override
  final TenantContext tenantContext;

  @override
  List<CompanyWorkspace> get companies => const [];

  @override
  String get selectedCompanyId => '';

  @override
  CompanyWorkspace get selectedWorkspace {
    throw StateError('No workspace is loaded.');
  }

  @override
  bool selectCompany(String companyId) => false;

  @override
  CompanyWorkspace? findWorkspace(String companyId) => null;

  @override
  Future<bool> saveWorkspace(String companyId, CompanyWorkspace updated) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<void> saveSelectedWorkspace(CompanyWorkspace updated) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<IntakeSession> resetIntakeSession(
    IntakeSession session, {
    IntakeInvitation? invitation,
  }) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<Company> updateCompany(
    Company company, {
    BusinessRules? businessRules,
    BotConfiguration? botConfiguration,
  }) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<ProductOrService> createProduct(ProductOrService product) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<ProductOrService> updateProduct(ProductOrService product) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<void> deleteProduct(String id) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<KnowledgeEntry> createKnowledgeEntry(KnowledgeEntry entry) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<KnowledgeEntry> updateKnowledgeEntry(KnowledgeEntry entry) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<void> deleteKnowledgeEntry(String id) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<SourceMaterial> createSourceMaterial(SourceMaterial source) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<SourceMaterial> updateSourceMaterial(SourceMaterial source) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<void> deleteSourceMaterial(String id) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<BotQuestionLog> createBotQuestionLog(BotQuestionLog log) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<BotQuestionLog> updateBotQuestionLog(BotQuestionLog log) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<BusinessAuditItem> updateAuditItem(BusinessAuditItem item) async {
    throw const NoActiveWorkspaceException();
  }

  @override
  Future<void> clear() async {}
}
