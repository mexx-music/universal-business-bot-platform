import 'models/company_knowledge_package.dart';
import 'models/knowledge_import_models.dart';

/// Attaches package provenance to the deterministic analyzer result by mapping
/// every verbatim source sentence back to its containing package document.
/// It does not classify, rewrite, add or remove knowledge.
class KnowledgePackageAnalysisEnricher {
  const KnowledgePackageAnalysisEnricher();

  KnowledgeImportAnalysis enrich({
    required KnowledgeImportAnalysis analysis,
    required CompanyKnowledgePackage package,
    required String languageCode,
  }) {
    final documents = [
      for (final document in package.documents)
        (
          document: document,
          normalizedContent: _normalize(document.content(languageCode)),
        ),
    ];

    return KnowledgeImportAnalysis(
      analyzedSentences: analysis.analyzedSentences,
      unclearStatements: analysis.unclearStatements,
      inputLanguageCode: analysis.inputLanguageCode,
      knowledgeArea: analysis.knowledgeArea,
      detectedTopicLabels: analysis.detectedTopicLabels,
      drafts: [
        for (final draft in analysis.drafts)
          _withMetadata(draft, documents, languageCode),
      ],
    );
  }

  KnowledgeImportDraft _withMetadata(
    KnowledgeImportDraft draft,
    List<({KnowledgePackageDocument document, String normalizedContent})>
    documents,
    String languageCode,
  ) {
    final sentence = _normalize(draft.sourceSentence);
    KnowledgePackageDocument? sourceDocument;
    for (final candidate in documents) {
      if (sentence.isNotEmpty &&
          candidate.normalizedContent.contains(sentence)) {
        sourceDocument = candidate.document;
        break;
      }
    }
    return KnowledgeImportDraft(
      id: draft.id,
      category: draft.category,
      title: draft.title,
      content: draft.content,
      sourceSentence: draft.sourceSentence,
      question: draft.question,
      keywords: draft.keywords,
      languageCode: draft.languageCode,
      knowledgeArea: draft.knowledgeArea,
      detectedTopics: draft.detectedTopics,
      packageMetadata: sourceDocument?.metadata(languageCode),
      existingMatch: draft.existingMatch,
      isPossibleDuplicate: draft.isPossibleDuplicate,
    );
  }

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'[.!?]+$'), '')
      .trim();
}
