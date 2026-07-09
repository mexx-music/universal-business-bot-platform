import 'business_audit.dart';
import 'bot_question_log.dart';
import 'company.dart';
import 'knowledge_entry.dart';
import 'product_or_service.dart';

class CompanyWorkspace {
  final Company company;
  final List<ProductOrService> products;
  final List<KnowledgeEntry> knowledgeEntries;
  final List<BotQuestionLog> botLogs;
  final List<BusinessAuditItem> auditItems;

  const CompanyWorkspace({
    required this.company,
    required this.products,
    required this.knowledgeEntries,
    required this.botLogs,
    required this.auditItems,
  });

  CompanyWorkspace copyWith({
    Company? company,
    List<ProductOrService>? products,
    List<KnowledgeEntry>? knowledgeEntries,
    List<BotQuestionLog>? botLogs,
    List<BusinessAuditItem>? auditItems,
  }) {
    return CompanyWorkspace(
      company: company ?? this.company,
      products: products ?? this.products,
      knowledgeEntries: knowledgeEntries ?? this.knowledgeEntries,
      botLogs: botLogs ?? this.botLogs,
      auditItems: auditItems ?? this.auditItems,
    );
  }
}
