import '../models/bot_question_log.dart';
import '../models/business_strategy.dart';
import '../models/company_workspace.dart';
import '../models/knowledge_entry.dart';
import '../models/marketing_strategy.dart';
import '../models/source_material.dart';

class WorkspaceMutationService {
  const WorkspaceMutationService();

  CompanyWorkspace replaceSourceMaterial(
    CompanyWorkspace workspace,
    SourceMaterial updated,
  ) {
    return workspace.copyWith(
      sourceMaterials: [
        for (final source in workspace.sourceMaterials)
          if (source.id == updated.id) updated else source,
      ],
    );
  }

  CompanyWorkspace deleteSourceMaterial(CompanyWorkspace workspace, String id) {
    return workspace.copyWith(
      sourceMaterials: workspace.sourceMaterials
          .where((source) => source.id != id)
          .toList(),
    );
  }

  CompanyWorkspace updateSourceStatus(
    CompanyWorkspace workspace,
    String id,
    SourceMaterialStatus status,
  ) {
    return workspace.copyWith(
      sourceMaterials: [
        for (final source in workspace.sourceMaterials)
          if (source.id == id)
            source.copyWith(status: status, updatedAt: DateTime.now())
          else
            source,
      ],
    );
  }

  CompanyWorkspace addKnowledgeEntryLinkedToSource({
    required CompanyWorkspace workspace,
    required KnowledgeEntry entry,
    String? sourceMaterialId,
    bool markSourceConverted = true,
  }) {
    return workspace.copyWith(
      knowledgeEntries: [...workspace.knowledgeEntries, entry],
      sourceMaterials: _linkSources(
        workspace.sourceMaterials,
        sourceMaterialId,
        entry.id,
        markSourceConverted,
      ),
    );
  }

  CompanyWorkspace addKnowledgeEntryFromReview({
    required CompanyWorkspace workspace,
    required KnowledgeEntry entry,
    required BotQuestionLog updatedLog,
    String? sourceMaterialId,
    bool markSourceConverted = true,
  }) {
    return workspace.copyWith(
      knowledgeEntries: [...workspace.knowledgeEntries, entry],
      sourceMaterials: _linkSources(
        workspace.sourceMaterials,
        sourceMaterialId,
        entry.id,
        markSourceConverted,
      ),
      botLogs: [
        for (final log in workspace.botLogs)
          if (log.id == updatedLog.id) updatedLog else log,
      ],
    );
  }

  CompanyWorkspace replaceBotLog(
    CompanyWorkspace workspace,
    BotQuestionLog updated,
  ) {
    return workspace.copyWith(
      botLogs: [
        for (final log in workspace.botLogs)
          if (log.id == updated.id) updated else log,
      ],
    );
  }

  CompanyWorkspace replaceMarketingAction(
    CompanyWorkspace workspace,
    MarketingAction updated,
  ) {
    final existing = workspace.marketingActions;
    final replaced = existing.any((action) => action.id == updated.id);
    return workspace.copyWith(
      marketingActions: [
        for (final action in existing)
          if (action.id == updated.id) updated else action,
        if (!replaced) updated,
      ],
    );
  }

  CompanyWorkspace replaceBusinessGoal(
    CompanyWorkspace workspace,
    BusinessGoal updated,
  ) {
    return workspace.copyWith(
      businessGoals: [
        for (final goal in workspace.businessGoals)
          if (goal.id == updated.id) updated else goal,
      ],
    );
  }

  List<SourceMaterial> _linkSources(
    List<SourceMaterial> sources,
    String? sourceMaterialId,
    String knowledgeEntryId,
    bool markSourceConverted,
  ) {
    return [
      for (final source in sources)
        if (source.id == sourceMaterialId)
          source.copyWith(
            status: markSourceConverted
                ? SourceMaterialStatus.converted
                : source.status,
            relatedKnowledgeEntryIds: [
              ...source.relatedKnowledgeEntryIds,
              knowledgeEntryId,
            ],
            updatedAt: DateTime.now(),
          )
        else
          source,
    ];
  }
}
