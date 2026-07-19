import '../models/company_workspace.dart';
import '../models/bot_question_log.dart';
import '../models/business_audit.dart';
import '../models/business_rules.dart';
import '../models/bot_configuration.dart';
import '../models/company.dart';
import '../models/knowledge_entry.dart';
import '../models/intake_invitation.dart';
import '../models/intake_session.dart';
import '../models/product_or_service.dart';
import '../models/source_material.dart';
import 'tenant_context.dart';

/// Single data-access boundary for company workspaces.
///
/// [AppState] (and therefore the whole UI) talks only to this interface.
/// Swapping the local in-memory implementation for a persistent or remote
/// one (localStorage, REST, Supabase, Firebase) means writing a new
/// implementation and wiring it in [AppDependencies] — screens, widgets and
/// AppState stay untouched.
///
/// Reads are synchronous snapshots by design: every implementation keeps the
/// current state in memory and serves it without awaiting storage. Writes are
/// local-first: the in-memory snapshot is updated synchronously (so callers
/// and the UI observe the change immediately), and the returned Future
/// completes once the change has been handed to the backing storage.
abstract class WorkspaceRepository {
  /// The tenant/user this repository is scoped to. All data returned or
  /// written belongs to this context.
  TenantContext get tenantContext;

  List<CompanyWorkspace> get companies;

  String get selectedCompanyId;

  CompanyWorkspace get selectedWorkspace;

  /// Selects [companyId] as the active workspace.
  /// Returns false if unknown or already selected.
  /// Implementations persist the selection in the background.
  bool selectCompany(String companyId);

  CompanyWorkspace? findWorkspace(String companyId);

  /// Persists [updated] under [companyId]. Resolves to false if unknown.
  Future<bool> saveWorkspace(String companyId, CompanyWorkspace updated);

  /// Persists [updated] and makes it the selected workspace.
  Future<void> saveSelectedWorkspace(CompanyWorkspace updated);

  Future<IntakeSession> resetIntakeSession(
    IntakeSession session, {
    IntakeInvitation? invitation,
  });

  Future<Company> updateCompany(
    Company company, {
    BusinessRules? businessRules,
    BotConfiguration? botConfiguration,
  });

  Future<ProductOrService> createProduct(ProductOrService product);

  Future<ProductOrService> updateProduct(ProductOrService product);

  Future<void> deleteProduct(String id);

  Future<KnowledgeEntry> createKnowledgeEntry(KnowledgeEntry entry);

  Future<KnowledgeEntry> updateKnowledgeEntry(KnowledgeEntry entry);

  Future<void> deleteKnowledgeEntry(String id);

  Future<SourceMaterial> createSourceMaterial(SourceMaterial source);

  Future<SourceMaterial> updateSourceMaterial(SourceMaterial source);

  Future<void> deleteSourceMaterial(String id);

  Future<BotQuestionLog> createBotQuestionLog(BotQuestionLog log);

  Future<BotQuestionLog> updateBotQuestionLog(BotQuestionLog log);

  Future<BusinessAuditItem> updateAuditItem(BusinessAuditItem item);

  /// Removes all locally persisted data for this repository. Intended for
  /// tests and future admin/debug tooling — there is deliberately no UI for
  /// it. After a clear, the next app start behaves like a first start.
  Future<void> clear();
}
