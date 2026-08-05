import '../models/knowledge_entry.dart';
import 'models/knowledge_import_models.dart';

/// Maps reviewed Knowledge Builder drafts onto the existing workspace model.
///
/// This is a deterministic model conversion. It does not analyze, enrich or
/// rewrite any draft content.
class KnowledgeImportMapper {
  const KnowledgeImportMapper();

  List<KnowledgeEntry> toWorkspaceEntries(
    List<KnowledgeImportDraft> drafts, {
    DateTime? createdAt,
    Map<String, KnowledgeEntryLink?> websiteLinks = const {},
  }) {
    final timestamp = createdAt ?? DateTime.now();
    return [
      for (var index = 0; index < drafts.length; index++)
        _toWorkspaceEntry(
          drafts[index],
          timestamp,
          index,
          websiteLinks.containsKey(drafts[index].id)
              ? websiteLinks[drafts[index].id]
              : drafts[index].websiteLink,
        ),
    ];
  }

  KnowledgeEntry _toWorkspaceEntry(
    KnowledgeImportDraft draft,
    DateTime timestamp,
    int index,
    KnowledgeEntryLink? websiteLink,
  ) {
    return KnowledgeEntry(
      id: 'kb_${timestamp.microsecondsSinceEpoch}_$index',
      title: draft.title,
      content: draft.content,
      category: _category(draft.category),
      riskLevel:
          draft.category == KnowledgeDraftCategory.warning ||
              (draft.packageMetadata?.risk.requiresExplicitReview ?? false)
          ? RiskLevel.yellow
          : RiskLevel.green,
      keywords: List.unmodifiable(draft.keywords),
      source: draft.packageMetadata == null
          ? KnowledgeEntrySources.knowledgeBuilder
          : KnowledgeEntrySources.knowledgeBuilderWithOrigin(
              draft.packageMetadata!.sourceName,
            ),
      createdAt: timestamp,
      languageCode: draft.languageCode,
      knowledgeArea: draft.knowledgeArea,
      detectedTopics: List.unmodifiable(draft.detectedTopics),
      websiteLink: websiteLink?.canOpen == true ? websiteLink : null,
    );
  }

  KnowledgeCategory _category(KnowledgeDraftCategory category) =>
      switch (category) {
        KnowledgeDraftCategory.faq => KnowledgeCategory.faq,
        KnowledgeDraftCategory.productFeature => KnowledgeCategory.produkt,
        KnowledgeDraftCategory.installation ||
        KnowledgeDraftCategory.stepByStep ||
        KnowledgeDraftCategory.troubleshooting => KnowledgeCategory.prozess,
        KnowledgeDraftCategory.technicalRequirement ||
        KnowledgeDraftCategory.warning ||
        KnowledgeDraftCategory.tip ||
        KnowledgeDraftCategory.definition ||
        KnowledgeDraftCategory.contact ||
        KnowledgeDraftCategory.general => KnowledgeCategory.allgemein,
      };
}
