import 'dart:convert';
import 'dart:math';
import 'dart:async';

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
import '../models/intake_invitation.dart';
import '../models/product_or_service.dart';
import '../models/knowledge_entry.dart';
import '../models/marketing_strategy.dart';
import '../models/bot_question_log.dart';
import '../models/project_status.dart';
import '../models/source_material.dart';
import '../models/intake_session.dart';
import '../models/action_record.dart';
import '../models/companion_check_in.dart';
import '../models/intake_mapping_preview.dart';
import '../recommendations/next_best_action.dart';
import '../recommendations/next_best_action_engine.dart';
import '../repositories/local_workspace_repository.dart';
import '../repositories/intake_invitation_repository.dart';
import '../repositories/remote_workspace_exception.dart';
import '../repositories/workspace_repository.dart';
import '../services/action_lifecycle_service.dart';
import '../services/check_in_service.dart';
import '../services/intake_mapping_service.dart';
import '../services/workspace_mutation_service.dart';

enum CompanyProfileStatus { incomplete, partial, complete }

enum PublicIntakeOpenResult { opened, notFound, disabled }

enum WorkspaceLoadStatus {
  initial,
  loading,
  loaded,
  empty,
  onboardingRequired,
  error,
}

class AppState extends ChangeNotifier {
  WorkspaceRepository _workspaceRepository;
  final WorkspaceMutationService _mutationService;
  final IntakeMappingService _intakeMappingService;
  final ActionLifecycleService _actionLifecycleService;
  final NextBestActionEngine _nextBestActionEngine;
  final CheckInService _checkInService;
  final BusinessIntelligenceCalculator _businessIntelligenceCalculator;
  final MarketingStrategyCalculator _marketingStrategyCalculator;
  final ProjectStatusCalculator _projectStatusCalculator;
  final BusinessStrategyCalculator _businessStrategyCalculator;
  final DashboardMetricsCalculator _dashboardMetricsCalculator;

  AppState({
    WorkspaceRepository? workspaceRepository,
    WorkspaceLoadStatus workspaceLoadStatus = WorkspaceLoadStatus.loaded,
    String? workspaceLoadError,
    WorkspaceMutationService mutationService = const WorkspaceMutationService(),
    IntakeMappingService intakeMappingService = const IntakeMappingService(),
    ActionLifecycleService actionLifecycleService =
        const ActionLifecycleService(),
    NextBestActionEngine nextBestActionEngine = const NextBestActionEngine(),
    CheckInService checkInService = const CheckInService(),
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
  }) : _workspaceRepository = workspaceRepository ?? LocalWorkspaceRepository(),
       _workspaceLoadStatus = workspaceLoadStatus,
       _workspaceLoadError = workspaceLoadError,
       _mutationService = mutationService,
       _intakeMappingService = intakeMappingService,
       _actionLifecycleService = actionLifecycleService,
       _nextBestActionEngine = nextBestActionEngine,
       _checkInService = checkInService,
       _businessIntelligenceCalculator = businessIntelligenceCalculator,
       _marketingStrategyCalculator = marketingStrategyCalculator,
       _projectStatusCalculator = projectStatusCalculator,
       _businessStrategyCalculator = businessStrategyCalculator,
       _dashboardMetricsCalculator = dashboardMetricsCalculator;

  WorkspaceLoadStatus _workspaceLoadStatus;
  String? _workspaceLoadError;
  bool _isSavingWorkspace = false;
  String? _workspaceSaveError;
  int _workspaceMutationGeneration = 0;

  WorkspaceLoadStatus get workspaceLoadStatus => _workspaceLoadStatus;
  String? get workspaceLoadError => _workspaceLoadError;
  bool get isSavingWorkspace => _isSavingWorkspace;
  String? get workspaceSaveError => _workspaceSaveError;
  bool get canWriteWorkspace =>
      _workspaceRepository.tenantContext.canWriteContent;
  bool get canReviewWorkspace =>
      _workspaceRepository.tenantContext.canReviewContent;
  bool get canDeleteWorkspace =>
      _workspaceRepository.tenantContext.canDeleteContent;
  bool get hasWorkspaces => _workspaceRepository.companies.isNotEmpty;

  void replaceWorkspaceRepository(
    WorkspaceRepository repository, {
    WorkspaceLoadStatus? status,
    String? error,
  }) {
    _workspaceMutationGeneration++;
    _isSavingWorkspace = false;
    _workspaceSaveError = null;
    _workspaceRepository = repository;
    _workspaceLoadStatus =
        status ??
        (repository.companies.isEmpty
            ? WorkspaceLoadStatus.empty
            : WorkspaceLoadStatus.loaded);
    _workspaceLoadError = error;
    notifyListeners();
  }

  void markWorkspaceLoading() {
    _workspaceLoadStatus = WorkspaceLoadStatus.loading;
    _workspaceLoadError = null;
    notifyListeners();
  }

  void clearWorkspaceData({
    WorkspaceLoadStatus status = WorkspaceLoadStatus.empty,
  }) {
    _workspaceMutationGeneration++;
    _isSavingWorkspace = false;
    _workspaceSaveError = null;
    _workspaceRepository.clear();
    _workspaceLoadStatus = status;
    _workspaceLoadError = null;
    notifyListeners();
  }

  List<CompanyWorkspace> get companies => _workspaceRepository.companies;

  String get selectedCompanyId => _workspaceRepository.selectedCompanyId;

  CompanyWorkspace get selectedWorkspace {
    return _workspaceRepository.selectedWorkspace;
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
  IntakeInvitation? get selectedIntakeInvitation =>
      selectedWorkspace.intakeInvitation;

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
  IntakeInvitation? get intakeInvitation => selectedIntakeInvitation;

  void selectCompany(String companyId) {
    if (_workspaceRepository.selectCompany(companyId)) notifyListeners();
  }

  String? selectedIntakeInvitationLink({Uri? baseUri}) {
    final invitation = selectedIntakeInvitation;
    if (invitation == null ||
        !invitation.isActive ||
        invitation.token.trim().isEmpty) {
      return null;
    }
    final base = baseUri ?? Uri.base;
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/onboarding/${invitation.token}',
    ).toString();
  }

  Future<void> reloadWorkspaces() async {
    final repository = _workspaceRepository;
    if (repository is! ReloadableWorkspaceRepository) return;
    await (repository as ReloadableWorkspaceRepository).reload();
    notifyListeners();
  }

  Future<IntakeInvitation> createIntakeInvitation() async {
    final repository = _workspaceRepository;
    final greeting = _defaultIntakeInvitationGreeting(selectedCompany);
    if (repository is IntakeInvitationRepository) {
      final invitation = await (repository as IntakeInvitationRepository)
          .createIntakeInvitation(greeting: greeting);
      _updateSelectedWorkspace(
        selectedWorkspace.copyWith(intakeInvitation: invitation),
      );
      notifyListeners();
      return invitation;
    }
    final now = DateTime.now();
    final invitation = IntakeInvitation(
      id: 'invite_${now.microsecondsSinceEpoch}',
      token: _generateInvitationToken(),
      status: IntakeInvitationStatus.invited,
      greeting: greeting,
      createdAt: now,
      updatedAt: now,
    );
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(intakeInvitation: invitation),
    );
    notifyListeners();
    return invitation;
  }

  Future<IntakeInvitation> regenerateIntakeInvitation() async {
    final repository = _workspaceRepository;
    if (repository is IntakeInvitationRepository) {
      final invitation = await (repository as IntakeInvitationRepository)
          .regenerateIntakeInvitation(
            greeting: selectedIntakeInvitation?.greeting,
          );
      _updateSelectedWorkspace(
        selectedWorkspace.copyWith(intakeInvitation: invitation),
      );
      notifyListeners();
      return invitation;
    }
    final now = DateTime.now();
    final existing = selectedIntakeInvitation;
    final invitation = IntakeInvitation(
      id: existing?.id ?? 'invite_${now.microsecondsSinceEpoch}',
      token: _generateInvitationToken(),
      status: IntakeInvitationStatus.invited,
      greeting:
          existing?.greeting ??
          _defaultIntakeInvitationGreeting(selectedCompany),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(intakeInvitation: invitation),
    );
    notifyListeners();
    return invitation;
  }

  Future<void> deactivateIntakeInvitation() async {
    final repository = _workspaceRepository;
    if (repository is IntakeInvitationRepository) {
      final invitation = await (repository as IntakeInvitationRepository)
          .deactivateIntakeInvitation();
      if (invitation != null) {
        _updateSelectedWorkspace(
          selectedWorkspace.copyWith(intakeInvitation: invitation),
        );
        notifyListeners();
      }
      return;
    }
    final existing = selectedIntakeInvitation;
    if (existing == null || !existing.isActive) return;
    final now = DateTime.now();
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        intakeInvitation: existing.copyWith(
          status: IntakeInvitationStatus.disabled,
          updatedAt: now,
          disabledAt: now,
        ),
      ),
    );
    notifyListeners();
  }

  PublicIntakeOpenResult openPublicIntakeInvitation(String token) {
    final cleanToken = token.trim();
    if (cleanToken.isEmpty) return PublicIntakeOpenResult.notFound;
    CompanyWorkspace? target;
    for (final workspace in companies) {
      if (workspace.intakeInvitation?.token == cleanToken) {
        target = workspace;
        break;
      }
    }
    if (target == null) return PublicIntakeOpenResult.notFound;
    final invitation = target.intakeInvitation!;
    if (!invitation.isActive) return PublicIntakeOpenResult.disabled;

    if (selectedCompanyId != target.company.id) {
      _workspaceRepository.selectCompany(target.company.id);
    }
    startOrResumeIntake();
    _markPublicIntakeStarted();
    notifyListeners();
    return PublicIntakeOpenResult.opened;
  }

  Future<void> updateCompany(Company updated) {
    return _runWorkspaceMutation(
      () => _workspaceRepository.updateCompany(
        updated,
        businessRules: selectedBusinessRules,
        botConfiguration: selectedBotConfiguration,
      ),
    );
  }

  Future<void> updateBusinessRules(BusinessRules updated) {
    return _runWorkspaceMutation(
      () => _workspaceRepository.updateCompany(
        selectedCompany,
        businessRules: updated,
        botConfiguration: selectedBotConfiguration,
      ),
    );
  }

  Future<void> updateBotConfiguration(BotConfiguration updated) {
    return _runWorkspaceMutation(
      () => _workspaceRepository.updateCompany(
        selectedCompany,
        businessRules: selectedBusinessRules,
        botConfiguration: updated,
      ),
    );
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
    final existing = selectedIntakeSession ?? startOrResumeIntake();
    final status = existing.status == IntakeStatus.completed
        ? IntakeStatus.completed
        : IntakeStatus.inProgress;
    final updated = existing.copyWith(
      status: status,
      chatStartedAt: existing.chatStartedAt ?? now,
      chatUpdatedAt: now,
    );
    final invitation = _invitationForIntakeStart(now);
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        intakeSession: updated,
        intakeInvitation: invitation,
      ),
    );
    notifyListeners();
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
    _markPublicIntakeCompleted();
  }

  // --- Next Best Actions & company memory ---

  NextBestActionPlan get nextBestActionPlan =>
      _nextBestActionEngine.recommendPlan(selectedWorkspace);

  List<NextBestAction> get nextBestActions => nextBestActionPlan.actions;

  List<ActionRecord> get actionRecords => selectedWorkspace.actionRecords;

  List<ActionRecord> get inProgressActionRecords => actionRecords
      .where((record) => record.status == ActionRecordStatus.inProgress)
      .toList();

  List<ActionRecord> get actionRecordsAwaitingRating =>
      actionRecords.where((record) => record.awaitsRating).toList();

  void acceptNextAction(NextBestAction action) {
    _updateSelectedWorkspace(
      _actionLifecycleService.acceptAction(selectedWorkspace, action),
    );
    notifyListeners();
  }

  void deferNextAction(NextBestAction action, {required DateTime until}) {
    _updateSelectedWorkspace(
      _actionLifecycleService.deferAction(
        selectedWorkspace,
        action,
        until: until,
      ),
    );
    notifyListeners();
  }

  void declineNextAction(NextBestAction action, {String? reason}) {
    _updateSelectedWorkspace(
      _actionLifecycleService.declineAction(
        selectedWorkspace,
        action,
        reason: reason,
      ),
    );
    notifyListeners();
  }

  void startNextAction(NextBestAction action) {
    _updateSelectedWorkspace(
      _actionLifecycleService.startAction(selectedWorkspace, action),
    );
    notifyListeners();
  }

  void completeNextAction(
    NextBestAction action, {
    ActionResultRating? rating,
    String? resultNote,
    String? actualOutcome,
    bool? repeatRequested,
  }) {
    _updateSelectedWorkspace(
      _actionLifecycleService.completeAction(
        selectedWorkspace,
        action,
        rating: rating,
        resultNote: resultNote,
        actualOutcome: actualOutcome,
        repeatRequested: repeatRequested,
      ),
    );
    notifyListeners();
  }

  void completeActionRecord(
    String recordId, {
    ActionResultRating? rating,
    String? resultNote,
    String? actualOutcome,
    bool? repeatRequested,
  }) {
    _updateSelectedWorkspace(
      _actionLifecycleService.completeRecord(
        selectedWorkspace,
        recordId,
        rating: rating,
        resultNote: resultNote,
        actualOutcome: actualOutcome,
        repeatRequested: repeatRequested,
      ),
    );
    notifyListeners();
  }

  void rateActionRecord(
    String recordId, {
    required ActionResultRating rating,
    String? resultNote,
    String? actualOutcome,
    bool? repeatRequested,
  }) {
    _updateSelectedWorkspace(
      _actionLifecycleService.rateRecord(
        selectedWorkspace,
        recordId,
        rating: rating,
        resultNote: resultNote,
        actualOutcome: actualOutcome,
        repeatRequested: repeatRequested,
      ),
    );
    notifyListeners();
  }

  // --- Companion check-in rhythm ---

  List<CompanionCheckIn> get checkIns => selectedWorkspace.checkIns;

  CompanionCheckIn? get activeCheckIn =>
      _checkInService.activeCheckIn(selectedWorkspace);

  CompanionCheckIn? get lastCompletedCheckIn =>
      _checkInService.lastCompletedCheckIn(selectedWorkspace);

  /// Live content of the active check-in (current data, same period).
  CompanionCheckIn? get activeCheckInPreview {
    final active = activeCheckIn;
    if (active == null) return null;
    return _checkInService.preview(selectedWorkspace, active);
  }

  DateTime get nextRecommendedCheckIn =>
      _checkInService.nextRecommendedCheckIn(selectedWorkspace);

  void startCheckIn() {
    final updated = _checkInService.startCheckIn(selectedWorkspace);
    if (identical(updated, selectedWorkspace)) return;
    _updateSelectedWorkspace(updated);
    notifyListeners();
  }

  void updateCheckInNotes(String checkInId, String notes) {
    _updateSelectedWorkspace(
      _checkInService.updateUserNotes(selectedWorkspace, checkInId, notes),
    );
    notifyListeners();
  }

  void completeCheckIn(
    String checkInId, {
    String? userNotes,
    List<String>? confirmedNextActionIds,
  }) {
    _updateSelectedWorkspace(
      _checkInService.completeCheckIn(
        selectedWorkspace,
        checkInId,
        userNotes: userNotes,
        confirmedNextActionIds: confirmedNextActionIds,
      ),
    );
    notifyListeners();
  }

  void skipCheckIn(String checkInId) {
    _updateSelectedWorkspace(
      _checkInService.skipCheckIn(selectedWorkspace, checkInId),
    );
    notifyListeners();
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

  Future<void> addKnowledgeEntry(KnowledgeEntry entry) {
    return _runWorkspaceMutation(
      () => _workspaceRepository.createKnowledgeEntry(entry),
    );
  }

  Future<void> addKnowledgeEntryLinkedToSource({
    required KnowledgeEntry entry,
    String? sourceMaterialId,
    bool markSourceConverted = true,
  }) {
    return _runWorkspaceMutation(() async {
      final savedEntry = await _workspaceRepository.createKnowledgeEntry(entry);
      if (sourceMaterialId == null) return null;
      final source = _sourceMaterialById(sourceMaterialId);
      if (source == null) return null;
      await _workspaceRepository.updateSourceMaterial(
        source.copyWith(
          status: markSourceConverted
              ? SourceMaterialStatus.converted
              : source.status,
          relatedKnowledgeEntryIds: [
            ...source.relatedKnowledgeEntryIds,
            savedEntry.id,
          ],
          updatedAt: DateTime.now(),
        ),
      );
      return null;
    });
  }

  Future<void> removeKnowledgeEntry(String id) {
    return _runWorkspaceMutation(
      () => _workspaceRepository.deleteKnowledgeEntry(id),
    );
  }

  Future<void> addBotLog(BotQuestionLog log) {
    return _runWorkspaceMutation(
      () => _workspaceRepository.createBotQuestionLog(log),
    );
  }

  Future<void> addSourceMaterial(SourceMaterial source) {
    return _runWorkspaceMutation(
      () => _workspaceRepository.createSourceMaterial(source),
    );
  }

  Future<void> updateSourceMaterial(SourceMaterial updated) {
    return _runWorkspaceMutation(
      () => _workspaceRepository.updateSourceMaterial(updated),
    );
  }

  Future<void> deleteSourceMaterial(String id) {
    return _runWorkspaceMutation(
      () => _workspaceRepository.deleteSourceMaterial(id),
    );
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

  Future<void> updateBotLog(BotQuestionLog updated) {
    return _runWorkspaceMutation(
      () => _workspaceRepository.updateBotQuestionLog(updated),
    );
  }

  Future<void> addKnowledgeEntryFromReview({
    required KnowledgeEntry entry,
    required BotQuestionLog updatedLog,
    String? sourceMaterialId,
    bool markSourceConverted = true,
  }) {
    return _runWorkspaceMutation(() async {
      final savedEntry = await _workspaceRepository.createKnowledgeEntry(entry);
      if (sourceMaterialId != null) {
        final source = _sourceMaterialById(sourceMaterialId);
        if (source != null) {
          await _workspaceRepository.updateSourceMaterial(
            source.copyWith(
              status: markSourceConverted
                  ? SourceMaterialStatus.converted
                  : source.status,
              relatedKnowledgeEntryIds: [
                ...source.relatedKnowledgeEntryIds,
                savedEntry.id,
              ],
              updatedAt: DateTime.now(),
            ),
          );
        }
      }
      await _workspaceRepository.updateBotQuestionLog(updatedLog);
      return null;
    });
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
    BusinessAuditItem? item;
    for (final existing in selectedAuditItems) {
      if (existing.id == id) {
        item = existing;
        break;
      }
    }
    if (item == null) return;
    final current = item;
    _runWorkspaceMutation(
      () => _workspaceRepository.updateAuditItem(update(current)),
    );
  }

  void _updateSourceStatus(String id, SourceMaterialStatus status) {
    final source = _sourceMaterialById(id);
    if (source == null) return;
    _runWorkspaceMutation(
      () => _workspaceRepository.updateSourceMaterial(
        source.copyWith(status: status, updatedAt: DateTime.now()),
      ),
    );
  }

  void _updateIntake(IntakeSession Function(IntakeSession session) update) {
    final existing = selectedIntakeSession ?? startOrResumeIntake();
    final status = existing.status == IntakeStatus.completed
        ? IntakeStatus.completed
        : IntakeStatus.inProgress;
    final updated = update(
      existing.copyWith(status: status, updatedAt: DateTime.now()),
    );
    final invitation = _invitationForIntakeUpdate(updated);
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        intakeSession: updated,
        intakeInvitation: invitation,
      ),
    );
    final repository = _workspaceRepository;
    if (repository is IntakeInvitationRepository) {
      unawaited(
        (repository as IntakeInvitationRepository)
            .updateIntakeSession(updated, invitation: invitation)
            .catchError((Object error) {
              _workspaceSaveError = _friendlyRepositoryError(error);
              notifyListeners();
              return updated;
            }),
      );
    }
    notifyListeners();
  }

  IntakeInvitation? _invitationForIntakeUpdate(IntakeSession session) {
    final invitation = selectedIntakeInvitation;
    if (invitation == null ||
        invitation.status == IntakeInvitationStatus.disabled) {
      return invitation;
    }
    final now = DateTime.now();
    if (session.status == IntakeStatus.completed) {
      return invitation.copyWith(
        status: IntakeInvitationStatus.completed,
        updatedAt: now,
        completedAt: now,
      );
    }
    if (invitation.status == IntakeInvitationStatus.invited ||
        invitation.status == IntakeInvitationStatus.started) {
      return invitation.copyWith(
        status: IntakeInvitationStatus.partial,
        updatedAt: now,
        startedAt: invitation.startedAt ?? now,
      );
    }
    return invitation.copyWith(updatedAt: now);
  }

  IntakeInvitation? _invitationForIntakeStart(DateTime now) {
    final invitation = selectedIntakeInvitation;
    if (invitation == null ||
        invitation.status == IntakeInvitationStatus.disabled ||
        invitation.status == IntakeInvitationStatus.completed) {
      return invitation;
    }
    if (invitation.status == IntakeInvitationStatus.invited) {
      return invitation.copyWith(
        status: IntakeInvitationStatus.started,
        startedAt: invitation.startedAt ?? now,
        updatedAt: now,
      );
    }
    return invitation.copyWith(updatedAt: now);
  }

  void _markPublicIntakeStarted() {
    final invitation = selectedIntakeInvitation;
    if (invitation == null ||
        invitation.status == IntakeInvitationStatus.disabled ||
        invitation.status == IntakeInvitationStatus.completed) {
      return;
    }
    if (invitation.status != IntakeInvitationStatus.invited) return;
    final now = DateTime.now();
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        intakeInvitation: invitation.copyWith(
          status: IntakeInvitationStatus.started,
          startedAt: now,
          updatedAt: now,
        ),
      ),
    );
  }

  void _markPublicIntakeCompleted() {
    final invitation = selectedIntakeInvitation;
    if (invitation == null ||
        invitation.status == IntakeInvitationStatus.disabled) {
      return;
    }
    final now = DateTime.now();
    _updateSelectedWorkspace(
      selectedWorkspace.copyWith(
        intakeInvitation: invitation.copyWith(
          status: IntakeInvitationStatus.completed,
          completedAt: now,
          updatedAt: now,
        ),
      ),
    );
  }

  String _generateInvitationToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(24, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  String _defaultIntakeInvitationGreeting(Company company) {
    final language = company.primaryLanguage.trim().toLowerCase();
    if (language.startsWith('en')) {
      return 'Welcome to the company questionnaire for ${company.name}.';
    }
    return 'Willkommen beim Firmenfragebogen für ${company.name}.';
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
    unawaited(
      _workspaceRepository.saveSelectedWorkspace(updated).catchError((
        Object error,
      ) {
        _workspaceSaveError = _friendlyRepositoryError(error);
        notifyListeners();
      }),
    );
  }

  SourceMaterial? _sourceMaterialById(String id) {
    for (final source in selectedSourceMaterials) {
      if (source.id == id) return source;
    }
    return null;
  }

  Future<void> _runWorkspaceMutation(Future<Object?> Function() action) async {
    if (_isSavingWorkspace) return;
    final generation = _workspaceMutationGeneration;
    _isSavingWorkspace = true;
    _workspaceSaveError = null;
    notifyListeners();
    try {
      await action();
      if (generation != _workspaceMutationGeneration) return;
      _workspaceSaveError = null;
    } catch (error) {
      if (generation != _workspaceMutationGeneration) return;
      _workspaceSaveError = _friendlyRepositoryError(error);
    } finally {
      if (generation == _workspaceMutationGeneration) {
        _isSavingWorkspace = false;
        notifyListeners();
      }
    }
  }

  String _friendlyRepositoryError(Object error) {
    if (error is NoActiveWorkspaceException) {
      return 'No active workspace is available.';
    }
    if (error is MissingTenantException || error is MissingSessionException) {
      return 'Please sign in again before saving changes.';
    }
    if (error is NoWritePermissionException) {
      return 'You do not have permission to change this workspace.';
    }
    if (error is RepositoryRecordNotFoundException) {
      return 'The record could not be found anymore.';
    }
    if (error is RepositoryValidationException) {
      return 'Please check the entered data and try again.';
    }
    if (error is RepositoryConflictException) {
      return 'The record changed elsewhere. Please reload and try again.';
    }
    return 'The change could not be saved.';
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
