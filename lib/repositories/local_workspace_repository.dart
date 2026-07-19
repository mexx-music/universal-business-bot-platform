import 'dart:convert';
import 'dart:math';

import '../data/workspace_store.dart';
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
import 'tenant_context.dart';
import 'workspace_repository.dart';

/// In-memory implementation backed by [WorkspaceStore] (mock data seed).
///
/// This is the only place that knows about [WorkspaceStore]; everything else
/// depends on [WorkspaceRepository]. The [tenantContext] is accepted but not
/// yet used for scoping — the local store holds exactly one tenant's data.
class LocalWorkspaceRepository
    implements
        WorkspaceRepository,
        IntakeInvitationRepository,
        ReloadableWorkspaceRepository {
  LocalWorkspaceRepository({
    WorkspaceStore? store,
    this.tenantContext = const TenantContext.local(),
  }) : _store = store ?? WorkspaceStore();

  WorkspaceStore _store;

  @override
  final TenantContext tenantContext;

  @override
  List<CompanyWorkspace> get companies => _store.companies;

  @override
  String get selectedCompanyId => _store.selectedCompanyId;

  @override
  CompanyWorkspace get selectedWorkspace => _store.selectedWorkspace;

  @override
  bool selectCompany(String companyId) => _store.selectCompany(companyId);

  @override
  CompanyWorkspace? findWorkspace(String companyId) =>
      _store.findWorkspace(companyId);

  @override
  Future<bool> saveWorkspace(String companyId, CompanyWorkspace updated) {
    return Future.value(_store.replaceWorkspace(companyId, updated));
  }

  @override
  Future<void> saveSelectedWorkspace(CompanyWorkspace updated) {
    _store.replaceSelectedWorkspace(updated);
    return Future.value();
  }

  @override
  Future<IntakeInvitation> createIntakeInvitation({
    required String greeting,
  }) async {
    final now = DateTime.now();
    final invitation = IntakeInvitation(
      id: 'invite_${now.microsecondsSinceEpoch}',
      token: _generateToken(),
      status: IntakeInvitationStatus.invited,
      greeting: greeting,
      createdAt: now,
      updatedAt: now,
    );
    await saveSelectedWorkspace(
      selectedWorkspace.copyWith(intakeInvitation: invitation),
    );
    return invitation;
  }

  @override
  Future<IntakeInvitation> regenerateIntakeInvitation({String? greeting}) {
    return createIntakeInvitation(
      greeting:
          greeting ??
          selectedWorkspace.intakeInvitation?.greeting ??
          'Willkommen beim Firmenfragebogen für ${selectedWorkspace.company.name}.',
    );
  }

  @override
  Future<IntakeInvitation?> deactivateIntakeInvitation() async {
    final invitation = selectedWorkspace.intakeInvitation;
    if (invitation == null) return null;
    final updated = invitation.copyWith(
      status: IntakeInvitationStatus.disabled,
      updatedAt: DateTime.now(),
      disabledAt: DateTime.now(),
    );
    await saveSelectedWorkspace(
      selectedWorkspace.copyWith(intakeInvitation: updated),
    );
    return updated;
  }

  @override
  Future<IntakeSession> updateIntakeSession(
    IntakeSession session, {
    IntakeInvitation? invitation,
  }) async {
    await saveSelectedWorkspace(
      selectedWorkspace.copyWith(
        intakeSession: session,
        intakeInvitation: invitation,
      ),
    );
    return session;
  }

  @override
  Future<IntakeSession> resetIntakeSession(
    IntakeSession session, {
    IntakeInvitation? invitation,
  }) async {
    await saveSelectedWorkspace(
      selectedWorkspace.copyWith(
        intakeSession: session,
        intakeInvitation: invitation ?? selectedWorkspace.intakeInvitation,
      ),
    );
    return session;
  }

  @override
  Future<void> reload() async {}

  String _generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  @override
  Future<Company> updateCompany(
    Company company, {
    BusinessRules? businessRules,
    BotConfiguration? botConfiguration,
  }) async {
    await saveSelectedWorkspace(
      selectedWorkspace.copyWith(
        company: company,
        businessRules: businessRules,
        botConfiguration: botConfiguration,
      ),
    );
    return company;
  }

  @override
  Future<ProductOrService> createProduct(ProductOrService product) async {
    await saveSelectedWorkspace(
      selectedWorkspace.copyWith(
        products: [...selectedWorkspace.products, product],
      ),
    );
    return product;
  }

  @override
  Future<ProductOrService> updateProduct(ProductOrService product) async {
    await saveSelectedWorkspace(
      selectedWorkspace.copyWith(
        products: [
          for (final existing in selectedWorkspace.products)
            if (existing.id == product.id) product else existing,
        ],
      ),
    );
    return product;
  }

  @override
  Future<void> deleteProduct(String id) {
    return saveSelectedWorkspace(
      selectedWorkspace.copyWith(
        products: selectedWorkspace.products
            .where((product) => product.id != id)
            .toList(),
      ),
    );
  }

  @override
  Future<KnowledgeEntry> createKnowledgeEntry(KnowledgeEntry entry) async {
    await saveSelectedWorkspace(
      selectedWorkspace.copyWith(
        knowledgeEntries: [...selectedWorkspace.knowledgeEntries, entry],
      ),
    );
    return entry;
  }

  @override
  Future<KnowledgeEntry> updateKnowledgeEntry(KnowledgeEntry entry) async {
    await saveSelectedWorkspace(
      selectedWorkspace.copyWith(
        knowledgeEntries: [
          for (final existing in selectedWorkspace.knowledgeEntries)
            if (existing.id == entry.id) entry else existing,
        ],
      ),
    );
    return entry;
  }

  @override
  Future<void> deleteKnowledgeEntry(String id) {
    return saveSelectedWorkspace(
      selectedWorkspace.copyWith(
        knowledgeEntries: selectedWorkspace.knowledgeEntries
            .where((entry) => entry.id != id)
            .toList(),
      ),
    );
  }

  @override
  Future<SourceMaterial> createSourceMaterial(SourceMaterial source) async {
    await saveSelectedWorkspace(
      selectedWorkspace.copyWith(
        sourceMaterials: [...selectedWorkspace.sourceMaterials, source],
      ),
    );
    return source;
  }

  @override
  Future<SourceMaterial> updateSourceMaterial(SourceMaterial source) async {
    await saveSelectedWorkspace(
      selectedWorkspace.copyWith(
        sourceMaterials: [
          for (final existing in selectedWorkspace.sourceMaterials)
            if (existing.id == source.id) source else existing,
        ],
      ),
    );
    return source;
  }

  @override
  Future<void> deleteSourceMaterial(String id) {
    return saveSelectedWorkspace(
      selectedWorkspace.copyWith(
        sourceMaterials: selectedWorkspace.sourceMaterials
            .where((source) => source.id != id)
            .toList(),
      ),
    );
  }

  @override
  Future<BotQuestionLog> createBotQuestionLog(BotQuestionLog log) async {
    await saveSelectedWorkspace(
      selectedWorkspace.copyWith(botLogs: [...selectedWorkspace.botLogs, log]),
    );
    return log;
  }

  @override
  Future<BotQuestionLog> updateBotQuestionLog(BotQuestionLog log) async {
    await saveSelectedWorkspace(
      selectedWorkspace.copyWith(
        botLogs: [
          for (final existing in selectedWorkspace.botLogs)
            if (existing.id == log.id) log else existing,
        ],
      ),
    );
    return log;
  }

  @override
  Future<BusinessAuditItem> updateAuditItem(BusinessAuditItem item) async {
    await saveSelectedWorkspace(
      selectedWorkspace.copyWith(
        auditItems: [
          for (final existing in selectedWorkspace.auditItems)
            if (existing.id == item.id) item else existing,
        ],
      ),
    );
    return item;
  }

  @override
  Future<void> clear() {
    _store = WorkspaceStore();
    return Future.value();
  }
}
