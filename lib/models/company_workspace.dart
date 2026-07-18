import 'action_record.dart';
import 'business_audit.dart';
import 'companion_check_in.dart';
import 'business_rules.dart';
import 'bot_configuration.dart';
import 'bot_question_log.dart';
import 'business_strategy.dart';
import 'company.dart';
import 'intake_invitation.dart';
import 'intake_session.dart';
import 'knowledge_entry.dart';
import 'marketing_strategy.dart';
import 'product_or_service.dart';
import 'source_material.dart';

class CompanyWorkspace {
  final Company company;
  final List<ProductOrService> products;
  final List<KnowledgeEntry> knowledgeEntries;
  final List<BotQuestionLog> botLogs;
  final List<BusinessAuditItem> auditItems;
  final BusinessRules businessRules;
  final BotConfiguration botConfiguration;
  final List<SourceMaterial> sourceMaterials;
  final List<MarketingAction> marketingActions;
  final List<BusinessGoal> businessGoals;
  final IntakeSession? intakeSession;
  final IntakeInvitation? intakeInvitation;

  /// Company memory: persisted decisions about recommended actions.
  final List<ActionRecord> actionRecords;

  /// Company memory: persisted check-in moments (companion rhythm).
  final List<CompanionCheckIn> checkIns;

  const CompanyWorkspace({
    required this.company,
    required this.products,
    required this.knowledgeEntries,
    required this.botLogs,
    required this.auditItems,
    required this.businessRules,
    required this.botConfiguration,
    required this.sourceMaterials,
    this.marketingActions = const [],
    this.businessGoals = const [],
    this.intakeSession,
    this.intakeInvitation,
    this.actionRecords = const [],
    this.checkIns = const [],
  });

  CompanyWorkspace copyWith({
    Company? company,
    List<ProductOrService>? products,
    List<KnowledgeEntry>? knowledgeEntries,
    List<BotQuestionLog>? botLogs,
    List<BusinessAuditItem>? auditItems,
    BusinessRules? businessRules,
    BotConfiguration? botConfiguration,
    List<SourceMaterial>? sourceMaterials,
    List<MarketingAction>? marketingActions,
    List<BusinessGoal>? businessGoals,
    IntakeSession? intakeSession,
    IntakeInvitation? intakeInvitation,
    List<ActionRecord>? actionRecords,
    List<CompanionCheckIn>? checkIns,
  }) {
    return CompanyWorkspace(
      company: company ?? this.company,
      products: products ?? this.products,
      knowledgeEntries: knowledgeEntries ?? this.knowledgeEntries,
      botLogs: botLogs ?? this.botLogs,
      auditItems: auditItems ?? this.auditItems,
      businessRules: businessRules ?? this.businessRules,
      botConfiguration: botConfiguration ?? this.botConfiguration,
      sourceMaterials: sourceMaterials ?? this.sourceMaterials,
      marketingActions: marketingActions ?? this.marketingActions,
      businessGoals: businessGoals ?? this.businessGoals,
      intakeSession: intakeSession ?? this.intakeSession,
      intakeInvitation: intakeInvitation ?? this.intakeInvitation,
      actionRecords: actionRecords ?? this.actionRecords,
      checkIns: checkIns ?? this.checkIns,
    );
  }
}
