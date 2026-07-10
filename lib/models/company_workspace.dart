import 'business_audit.dart';
import 'business_rules.dart';
import 'bot_configuration.dart';
import 'bot_question_log.dart';
import 'company.dart';
import 'intake_session.dart';
import 'knowledge_entry.dart';
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
  final IntakeSession? intakeSession;

  const CompanyWorkspace({
    required this.company,
    required this.products,
    required this.knowledgeEntries,
    required this.botLogs,
    required this.auditItems,
    required this.businessRules,
    required this.botConfiguration,
    required this.sourceMaterials,
    this.intakeSession,
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
    IntakeSession? intakeSession,
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
      intakeSession: intakeSession ?? this.intakeSession,
    );
  }
}
