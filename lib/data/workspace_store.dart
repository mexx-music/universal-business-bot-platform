import '../models/company_workspace.dart';
import 'mock_data.dart';

class WorkspaceStore {
  List<CompanyWorkspace> _companies;
  String _selectedCompanyId;

  WorkspaceStore({List<CompanyWorkspace>? companies, String? selectedCompanyId})
    : _companies = companies ?? _cloneWorkspaces(MockData.companyWorkspaces),
      _selectedCompanyId =
          selectedCompanyId ?? MockData.companyWorkspaces.first.company.id;

  List<CompanyWorkspace> get companies => _companies;

  String get selectedCompanyId => _selectedCompanyId;

  CompanyWorkspace get selectedWorkspace {
    return _companies.firstWhere(
      (workspace) => workspace.company.id == _selectedCompanyId,
      orElse: () => _companies.first,
    );
  }

  bool selectCompany(String companyId) {
    if (_selectedCompanyId == companyId) return false;
    if (!_companies.any((workspace) => workspace.company.id == companyId)) {
      return false;
    }
    _selectedCompanyId = companyId;
    return true;
  }

  CompanyWorkspace? findWorkspace(String companyId) {
    for (final workspace in _companies) {
      if (workspace.company.id == companyId) return workspace;
    }
    return null;
  }

  void replaceSelectedWorkspace(CompanyWorkspace updated) {
    replaceWorkspace(updated.company.id, updated);
    _selectedCompanyId = updated.company.id;
  }

  bool replaceWorkspace(String companyId, CompanyWorkspace updated) {
    var replaced = false;
    _companies = [
      for (final workspace in _companies)
        if (workspace.company.id == companyId)
          (() {
            replaced = true;
            return updated;
          })()
        else
          workspace,
    ];
    return replaced;
  }

  bool updateWorkspace(
    String companyId,
    CompanyWorkspace Function(CompanyWorkspace workspace) update,
  ) {
    final workspace = findWorkspace(companyId);
    if (workspace == null) return false;
    return replaceWorkspace(companyId, update(workspace));
  }

  static List<CompanyWorkspace> _cloneWorkspaces(
    List<CompanyWorkspace> workspaces,
  ) {
    return workspaces
        .map(
          (workspace) => workspace.copyWith(
            products: List.from(workspace.products),
            knowledgeEntries: List.from(workspace.knowledgeEntries),
            botLogs: List.from(workspace.botLogs),
            auditItems: List.from(workspace.auditItems),
            sourceMaterials: List.from(workspace.sourceMaterials),
            marketingActions: List.from(workspace.marketingActions),
            businessGoals: List.from(workspace.businessGoals),
            intakeSession: workspace.intakeSession,
          ),
        )
        .toList();
  }
}
