import 'package:flutter/widgets.dart';
import '../models/company.dart';
import '../models/company_workspace.dart';
import '../models/product_or_service.dart';
import '../models/knowledge_entry.dart';
import '../models/bot_question_log.dart';
import 'mock_data.dart';

class AppState extends ChangeNotifier {
  List<CompanyWorkspace> companies = MockData.companyWorkspaces
      .map(
        (workspace) => workspace.copyWith(
          products: List.from(workspace.products),
          knowledgeEntries: List.from(workspace.knowledgeEntries),
          botLogs: List.from(workspace.botLogs),
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

  Company get company => selectedCompany;
  List<ProductOrService> get products => selectedProducts;
  List<KnowledgeEntry> get knowledgeEntries => selectedKnowledgeEntries;
  List<BotQuestionLog> get botLogs => selectedBotLogs;

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

  void addKnowledgeEntry(KnowledgeEntry entry) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        knowledgeEntries: [...selectedKnowledgeEntries, entry],
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
  }) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        knowledgeEntries: [...selectedKnowledgeEntries, entry],
        botLogs: [
          for (final log in selectedBotLogs)
            if (log.id == updatedLog.id) updatedLog else log,
        ],
      ),
    );
    notifyListeners();
  }

  // 0.0 – 1.0; based on same weights as AuditScreen checklist
  double get auditScore {
    int score = 0;
    if (company.name.isNotEmpty) score += 10;
    if (company.industry.isNotEmpty) score += 10;
    if (company.description.length >= 50) score += 10;
    if (company.website.isNotEmpty) score += 5;
    if (products.isNotEmpty) score += 15;
    if (knowledgeEntries.isNotEmpty) score += 15;
    if (knowledgeEntries.length >= 10) score += 15;
    if (botLogs.isNotEmpty) score += 20;
    return score / 100.0;
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
