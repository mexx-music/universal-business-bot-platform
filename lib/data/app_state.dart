import 'package:flutter/widgets.dart';
import '../calculators/business_intelligence_calculator.dart';
import '../calculators/business_strategy_calculator.dart';
import '../calculators/dashboard_metrics_calculator.dart';
import '../calculators/marketing_strategy_calculator.dart';
import '../calculators/project_status_calculator.dart';
import '../models/business_audit.dart';
import '../models/business_intelligence.dart';
import '../models/business_rules.dart';
import '../models/business_strategy.dart';
import '../models/bot_configuration.dart';
import '../models/company.dart';
import '../models/company_workspace.dart';
import '../models/product_or_service.dart';
import '../models/knowledge_entry.dart';
import '../models/marketing_strategy.dart';
import '../models/bot_question_log.dart';
import '../models/project_status.dart';
import '../models/source_material.dart';
import '../models/intake_session.dart';
import '../models/intake_mapping_preview.dart';
import '../services/intake_mapping_service.dart';
import '../services/workspace_mutation_service.dart';
import 'workspace_store.dart';

enum CompanyProfileStatus { incomplete, partial, complete }

class AppState extends ChangeNotifier {
  final WorkspaceStore _workspaceStore;
  final WorkspaceMutationService _mutationService;
  final IntakeMappingService _intakeMappingService;
  final BusinessIntelligenceCalculator _businessIntelligenceCalculator;
  final MarketingStrategyCalculator _marketingStrategyCalculator;
  final ProjectStatusCalculator _projectStatusCalculator;
  final BusinessStrategyCalculator _businessStrategyCalculator;
  final DashboardMetricsCalculator _dashboardMetricsCalculator;

  AppState({
    WorkspaceStore? workspaceStore,
    WorkspaceMutationService mutationService = const WorkspaceMutationService(),
    IntakeMappingService intakeMappingService = const IntakeMappingService(),
    BusinessIntelligenceCalculator businessIntelligenceCalculator =
        const BusinessIntelligenceCalculator(),
    MarketingStrategyCalculator marketingStrategyCalculator =
        const MarketingStrategyCalculator(),
    ProjectStatusCalculator projectStatusCalculator =
        const ProjectStatusCalculator(),
    BusinessStrategyCalculator businessStrategyCalculator =
        const BusinessStrategyCalculator(),
    DashboardMetricsCalculator dashboardMetricsCalculator =
        const DashboardMetricsCalculator(),
  }) : _workspaceStore = workspaceStore ?? WorkspaceStore(),
       _mutationService = mutationService,
       _intakeMappingService = intakeMappingService,
       _businessIntelligenceCalculator = businessIntelligenceCalculator,
       _marketingStrategyCalculator = marketingStrategyCalculator,
       _projectStatusCalculator = projectStatusCalculator,
       _businessStrategyCalculator = businessStrategyCalculator,
       _dashboardMetricsCalculator = dashboardMetricsCalculator;

  List<CompanyWorkspace> get companies => _workspaceStore.companies;

  String get selectedCompanyId => _workspaceStore.selectedCompanyId;

  CompanyWorkspace get selectedWorkspace {
    return _workspaceStore.selectedWorkspace;
  }

  Company get selectedCompany => selectedWorkspace.company;
  List<ProductOrService> get selectedProducts => selectedWorkspace.products;
  List<KnowledgeEntry> get selectedKnowledgeEntries =>
      selectedWorkspace.knowledgeEntries;
  List<BotQuestionLog> get selectedBotLogs => selectedWorkspace.botLogs;
  List<BusinessAuditItem> get selectedAuditItems =>
      selectedWorkspace.auditItems;
  BusinessRules get selectedBusinessRules => selectedWorkspace.businessRules;
  BotConfiguration get selectedBotConfiguration =>
      selectedWorkspace.botConfiguration;
  List<SourceMaterial> get selectedSourceMaterials =>
      selectedWorkspace.sourceMaterials;
  List<MarketingAction> get selectedMarketingActions =>
      marketingStrategy.actions;
  List<BusinessGoal> get selectedBusinessGoals =>
      selectedWorkspace.businessGoals;
  IntakeSession? get selectedIntakeSession => selectedWorkspace.intakeSession;

  Company get company => selectedCompany;
  List<ProductOrService> get products => selectedProducts;
  List<KnowledgeEntry> get knowledgeEntries => selectedKnowledgeEntries;
  List<BotQuestionLog> get botLogs => selectedBotLogs;
  List<BusinessAuditItem> get auditItems => selectedAuditItems;
  BusinessRules get businessRules => selectedBusinessRules;
  BotConfiguration get botConfiguration => selectedBotConfiguration;
  List<SourceMaterial> get sourceMaterials => selectedSourceMaterials;
  List<MarketingAction> get marketingActions => selectedMarketingActions;
  List<BusinessGoal> get businessGoals => selectedBusinessGoals;
  IntakeSession? get intakeSession => selectedIntakeSession;

  void selectCompany(String companyId) {
    if (_workspaceStore.selectCompany(companyId)) notifyListeners();
  }

  void updateCompany(Company updated) {
    _updateSelectedWorkspace(selectedWorkspace.copyWith(company: updated));
    notifyListeners();
  }

  void updateBusinessRules(BusinessRules updated) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(businessRules: updated),
    );
    notifyListeners();
  }

  void updateBotConfiguration(BotConfiguration updated) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(botConfiguration: updated),
    );
    notifyListeners();
  }

  IntakeSession startOrResumeIntake() {
    final existing = selectedIntakeSession;
    if (existing != null) return existing;

    final c = selectedCompany;
    final session = IntakeSession.empty(
      companyId: c.id,
      basics: IntakeBasics(
        companyName: c.name,
        shortDescription: c.shortDescription,
        industry: c.industry,
        country: c.country,
        primaryLanguage: c.primaryLanguage,
        website: c.website,
        supportEmail: c.supportEmail,
        supportPhone: c.supportPhone,
        hasWebsite: c.website.trim().isNotEmpty,
      ),
    );
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(intakeSession: session),
    );
    notifyListeners();
    return session;
  }

  void updateIntakeBasics(IntakeBasics basics) {
    _updateIntake((session) => session.copyWith(basics: basics));
  }

  void updateIntakeProducts(IntakeProducts products) {
    _updateIntake((session) => session.copyWith(products: products));
  }

  void updateIntakeTargetGroups(IntakeTargetGroups targetGroups) {
    _updateIntake((session) => session.copyWith(targetGroups: targetGroups));
  }

  void updateIntakeWebsiteAndSupport(
    IntakeWebsiteAndSupport websiteAndSupport,
  ) {
    _updateIntake(
      (session) => session.copyWith(websiteAndSupport: websiteAndSupport),
    );
  }

  void updateIntakeSourcesAndReviews(
    IntakeSourcesAndReviews sourcesAndReviews,
  ) {
    _updateIntake(
      (session) => session.copyWith(sourcesAndReviews: sourcesAndReviews),
    );
  }

  void updateIntakeMarketingAndChannels(
    IntakeMarketingAndChannels marketingAndChannels,
  ) {
    _updateIntake(
      (session) => session.copyWith(marketingAndChannels: marketingAndChannels),
    );
  }

  void updateIntakeGoalsAndRisks(IntakeGoalsAndRisks goalsAndRisks) {
    _updateIntake((session) => session.copyWith(goalsAndRisks: goalsAndRisks));
  }

  void setIntakeStep(int stepIndex) {
    _updateIntake((session) => session.copyWith(currentStepIndex: stepIndex));
  }

  void completeIntake() {
    _updateIntake(
      (session) =>
          session.copyWith(status: IntakeStatus.completed, currentStepIndex: 7),
    );
  }

  void markIntakeChatStarted() {
    final now = DateTime.now();
    _updateIntake(
      (session) => session.copyWith(
        chatStartedAt: session.chatStartedAt ?? now,
        chatUpdatedAt: now,
      ),
    );
  }

  void setIntakeChatQuestionIndex(int index) {
    _updateIntake(
      (session) => session.copyWith(
        chatCurrentQuestionIndex: index,
        chatUpdatedAt: DateTime.now(),
      ),
    );
  }

  void skipIntakeChatQuestion(String questionKey, int nextQuestionIndex) {
    _updateIntake(
      (session) => session.copyWith(
        skippedQuestionKeys: _appendUnique(
          session.skippedQuestionKeys,
          questionKey,
        ),
        chatCurrentQuestionIndex: nextQuestionIndex,
        chatUpdatedAt: DateTime.now(),
      ),
    );
  }

  void deferIntakeChatQuestion(String questionKey, int nextQuestionIndex) {
    _updateIntake(
      (session) => session.copyWith(
        deferredQuestionKeys: _appendUnique(
          session.deferredQuestionKeys,
          questionKey,
        ),
        chatCurrentQuestionIndex: nextQuestionIndex,
        chatUpdatedAt: DateTime.now(),
      ),
    );
  }

  void markIntakeChatCompleted() {
    final now = DateTime.now();
    _updateIntake(
      (session) => session.copyWith(
        status: IntakeStatus.completed,
        currentStepIndex: 7,
        chatCompletedAt: now,
        chatUpdatedAt: now,
      ),
    );
  }

  IntakeMappingPreview generateIntakeMappingPreview() {
    return _intakeMappingService.createPreview(selectedWorkspace);
  }

  void importSelectedIntakeMapping(IntakeMappingPreview preview) {
    final updated = _intakeMappingService.importSelectedMapping(
      selectedWorkspace,
      preview,
    );
    if (identical(updated, selectedWorkspace)) return;
    _updateSelectedWorkspace(updated);
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

  void addKnowledgeEntryLinkedToSource({
    required KnowledgeEntry entry,
    String? sourceMaterialId,
    bool markSourceConverted = true,
  }) {
    _updateSelectedWorkspace(
      _mutationService.addKnowledgeEntryLinkedToSource(
        workspace: selectedWorkspace,
        entry: entry,
        sourceMaterialId: sourceMaterialId,
        markSourceConverted: markSourceConverted,
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

  void addSourceMaterial(SourceMaterial source) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        sourceMaterials: [...selectedSourceMaterials, source],
      ),
    );
    notifyListeners();
  }

  void updateSourceMaterial(SourceMaterial updated) {
    _updateSelectedWorkspace(
      _mutationService.replaceSourceMaterial(selectedWorkspace, updated),
    );
    notifyListeners();
  }

  void deleteSourceMaterial(String id) {
    _updateSelectedWorkspace(
      _mutationService.deleteSourceMaterial(selectedWorkspace, id),
    );
    notifyListeners();
  }

  void markSourceAsReviewed(String id) {
    _updateSourceStatus(id, SourceMaterialStatus.reviewed);
  }

  void markSourceAsConverted(String id) {
    _updateSourceStatus(id, SourceMaterialStatus.converted);
  }

  void updateMarketingAction(MarketingAction updated) {
    _updateSelectedWorkspace(
      _mutationService.replaceMarketingAction(selectedWorkspace, updated),
    );
    notifyListeners();
  }

  void addBusinessGoal(BusinessGoal goal) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        businessGoals: [...selectedBusinessGoals, goal],
      ),
    );
    notifyListeners();
  }

  void updateBusinessGoal(BusinessGoal updated) {
    _updateSelectedWorkspace(
      _mutationService.replaceBusinessGoal(selectedWorkspace, updated),
    );
    notifyListeners();
  }

  void deleteBusinessGoal(String id) {
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        businessGoals: selectedBusinessGoals
            .where((goal) => goal.id != id)
            .toList(),
      ),
    );
    notifyListeners();
  }

  int get sourceMaterialCount => selectedSourceMaterials.length;

  int get newSourceMaterialCount => selectedSourceMaterials
      .where((source) => source.status == SourceMaterialStatus.newItem)
      .length;

  String intakeStatusFor(CompanyWorkspace workspace) {
    final session = workspace.intakeSession;
    if (session == null) return 'notStarted';
    return session.status.name;
  }

  void updateBotLog(BotQuestionLog updated) {
    _updateSelectedWorkspace(
      _mutationService.replaceBotLog(selectedWorkspace, updated),
    );
    notifyListeners();
  }

  void addKnowledgeEntryFromReview({
    required KnowledgeEntry entry,
    required BotQuestionLog updatedLog,
    String? sourceMaterialId,
    bool markSourceConverted = true,
  }) {
    _updateSelectedWorkspace(
      _mutationService.addKnowledgeEntryFromReview(
        workspace: selectedWorkspace,
        entry: entry,
        updatedLog: updatedLog,
        sourceMaterialId: sourceMaterialId,
        markSourceConverted: markSourceConverted,
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

  int get auditHighPriorityMissingCount => auditItems
      .where(
        (item) =>
            item.priority == AuditPriority.high &&
            item.status == AuditItemStatus.missing,
      )
      .length;

  int get openReviewCount =>
      botLogs.where((log) => log.reviewStatus == ReviewStatus.open).length;

  int get blockedBotLogCount => botLogs.where((log) => log.redirected).length;

  MarketingStrategySnapshot get marketingStrategy {
    return marketingStrategyFor(selectedWorkspace);
  }

  BusinessStrategySnapshot get businessStrategy {
    return businessStrategyFor(selectedWorkspace);
  }

  BusinessIntelligenceSnapshot get businessIntelligence {
    return businessIntelligenceFor(selectedWorkspace);
  }

  DashboardMetrics get dashboardMetrics {
    return _dashboardMetricsCalculator.calculate(selectedWorkspace);
  }

  MarketingStrategySnapshot marketingStrategyFor(CompanyWorkspace workspace) {
    return _marketingStrategyCalculator.calculate(workspace);
  }

  BusinessStrategySnapshot businessStrategyFor(CompanyWorkspace workspace) {
    return _businessStrategyCalculator.calculate(workspace);
  }

  BusinessIntelligenceSnapshot businessIntelligenceFor(
    CompanyWorkspace workspace,
  ) {
    return _businessIntelligenceCalculator.calculate(workspace);
  }

  ProjectStatusSnapshot get projectStatus {
    return projectStatusFor(selectedWorkspace);
  }

  ProjectStatusSnapshot projectStatusFor(CompanyWorkspace workspace) {
    return _projectStatusCalculator.calculate(workspace);
  }

  int sourceMaterialCountFor(CompanyWorkspace workspace) {
    return workspace.sourceMaterials.length;
  }

  int newSourceMaterialCountFor(CompanyWorkspace workspace) {
    return workspace.sourceMaterials
        .where((source) => source.status == SourceMaterialStatus.newItem)
        .length;
  }

  CompanyProfileStatus get companyProfileStatus {
    return companyProfileStatusFor(selectedWorkspace);
  }

  CompanyProfileStatus companyProfileStatusFor(CompanyWorkspace workspace) {
    final c = workspace.company;
    final rules = workspace.businessRules;
    final checks = [
      c.name.isNotEmpty,
      c.description.isNotEmpty,
      c.industry.isNotEmpty,
      c.country.isNotEmpty,
      c.primaryLanguage.isNotEmpty,
      c.website.isNotEmpty,
      c.email.isNotEmpty,
      c.socialLinks.values.any((value) => value.trim().isNotEmpty),
      rules.brandVoice.isNotEmpty,
      rules.allowedSupportTopics.isNotEmpty,
    ];
    final complete = checks.where((check) => check).length;
    if (complete >= 8) return CompanyProfileStatus.complete;
    if (complete >= 4) return CompanyProfileStatus.partial;
    return CompanyProfileStatus.incomplete;
  }

  double auditScoreFor(CompanyWorkspace workspace) {
    return _projectStatusCalculator.auditScoreFor(workspace);
  }

  int openReviewCountFor(CompanyWorkspace workspace) {
    return workspace.botLogs
        .where((log) => log.reviewStatus == ReviewStatus.open)
        .length;
  }

  int blockedBotLogCountFor(CompanyWorkspace workspace) {
    return workspace.botLogs.where((log) => log.redirected).length;
  }

  // 0.0 - 1.0; weighted by priority, with partial items counting halfway.
  double get auditScore {
    return auditScoreFor(selectedWorkspace);
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

  void _updateSourceStatus(String id, SourceMaterialStatus status) {
    _updateSelectedWorkspace(
      _mutationService.updateSourceStatus(selectedWorkspace, id, status),
    );
    notifyListeners();
  }

  void _updateIntake(IntakeSession Function(IntakeSession session) update) {
    final existing = selectedIntakeSession ?? startOrResumeIntake();
    final status = existing.status == IntakeStatus.completed
        ? IntakeStatus.completed
        : IntakeStatus.inProgress;
    final updated = update(
      existing.copyWith(status: status, updatedAt: DateTime.now()),
    );
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(intakeSession: updated),
    );
    notifyListeners();
  }

  bool _containsSimilar(Iterable<String> existingValues, String candidate) {
    final normalizedCandidate = _normalize(candidate);
    if (normalizedCandidate.isEmpty) return true;
    return existingValues.any((existing) {
      final normalizedExisting = _normalize(existing);
      if (normalizedExisting.isEmpty) return false;
      return normalizedExisting == normalizedCandidate ||
          normalizedExisting.contains(normalizedCandidate) ||
          normalizedCandidate.contains(normalizedExisting);
    });
  }

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\wäöüß ]', unicode: true), '');
  }

  List<String> _appendUnique(List<String> current, String value) {
    final clean = value.trim();
    if (clean.isEmpty || _containsSimilar(current, clean)) return current;
    return [...current, clean];
  }

  void _updateSelectedWorkspace(CompanyWorkspace updated) {
    _workspaceStore.replaceSelectedWorkspace(updated);
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
