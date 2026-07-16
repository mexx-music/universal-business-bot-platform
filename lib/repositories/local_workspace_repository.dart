import '../data/workspace_store.dart';
import '../models/company_workspace.dart';
import 'tenant_context.dart';
import 'workspace_repository.dart';

/// In-memory implementation backed by [WorkspaceStore] (mock data seed).
///
/// This is the only place that knows about [WorkspaceStore]; everything else
/// depends on [WorkspaceRepository]. The [tenantContext] is accepted but not
/// yet used for scoping — the local store holds exactly one tenant's data.
class LocalWorkspaceRepository implements WorkspaceRepository {
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
  Future<void> clear() {
    _store = WorkspaceStore();
    return Future.value();
  }
}
