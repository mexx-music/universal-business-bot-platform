import 'package:flutter/widgets.dart';
import '../models/business_audit.dart';
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
          auditItems: List.from(workspace.auditItems),
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
  List<BusinessAuditItem> get selectedAuditItems =>
      selectedWorkspace.auditItems;

  Company get company => selectedCompany;
  List<ProductOrService> get products => selectedProducts;
  List<KnowledgeEntry> get knowledgeEntries => selectedKnowledgeEntries;
  List<BotQuestionLog> get botLogs => selectedBotLogs;
  List<BusinessAuditItem> get auditItems => selectedAuditItems;

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

  void updateAuditItemStatus(String id, AuditItemStatus status) {
    _updateAuditItem(id, (item) => item.copyWith(status: status));
  }

  void updateAuditItemPriority(String id, AuditPriority priority) {
    _updateAuditItem(id, (item) => item.copyWith(priority: priority));
  }

  void updateAuditItemNote(String id, String? note) {
    _updateAuditItem(id, (item) {
      final cleanNote = note?.trim();
      return item.copyWith(
        note: cleanNote == null || cleanNote.isEmpty ? null : cleanNote,
      );
    });
  }

  int get auditMissingCount =>
      auditItems.where((item) => item.status == AuditItemStatus.missing).length;

  int get auditPartialCount =>
      auditItems.where((item) => item.status == AuditItemStatus.partial).length;

  int get auditCompleteCount => auditItems
      .where((item) => item.status == AuditItemStatus.complete)
      .length;

  int get auditHighPriorityOpenCount => auditItems
      .where(
        (item) =>
            item.priority == AuditPriority.high &&
            item.status != AuditItemStatus.complete,
      )
      .length;

  // 0.0 - 1.0; weighted by priority, with partial items counting halfway.
  double get auditScore {
    if (auditItems.isEmpty) return 0.0;
    double score = 0;
    double maxScore = 0;
    for (final item in auditItems) {
      final weight = _priorityWeight(item.priority);
      maxScore += weight;
      score += switch (item.status) {
        AuditItemStatus.complete => weight,
        AuditItemStatus.partial => weight * 0.5,
        AuditItemStatus.missing => 0,
      };
    }
    return maxScore == 0 ? 0.0 : score / maxScore;
  }

  void _updateAuditItem(
    String id,
    BusinessAuditItem Function(BusinessAuditItem item) update,
  ) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        auditItems: [
          for (final item in selectedAuditItems)
            if (item.id == id) update(item) else item,
        ],
      ),
    );
    notifyListeners();
  }

  int _priorityWeight(AuditPriority priority) {
    return switch (priority) {
      AuditPriority.low => 1,
      AuditPriority.medium => 2,
      AuditPriority.high => 3,
    };
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
