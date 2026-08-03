import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/knowledge_builder/models/knowledge_analysis_presentation.dart';
import 'package:universalbusiness/knowledge_builder/models/knowledge_import_models.dart';

void main() {
  test('derives every metric from the existing analysis result', () {
    const analysis = KnowledgeImportAnalysis(
      analyzedSentences: 4,
      unclearStatements: 0,
      inputLanguageCode: 'de',
      knowledgeArea: 'hb_cure_app',
      detectedTopicLabels: ['Bluetooth', 'App', 'Android'],
      drafts: [
        KnowledgeImportDraft(
          id: '1',
          category: KnowledgeDraftCategory.faq,
          title: 'FAQ 1',
          content: 'Text',
          sourceSentence: 'Text',
          keywords: ['bluetooth', 'app'],
          knowledgeArea: 'hb_cure_app',
          detectedTopics: ['Bluetooth', 'App'],
        ),
        KnowledgeImportDraft(
          id: '2',
          category: KnowledgeDraftCategory.faq,
          title: 'FAQ 2',
          content: 'Text',
          sourceSentence: 'Text',
          keywords: ['bluetooth', 'android'],
          knowledgeArea: 'hb_cure_app',
          detectedTopics: ['Bluetooth', 'Android'],
          existingMatch: KnowledgeImportMatch(
            existingEntryId: 'e1',
            existingTitle: 'Existing',
            existingExcerpt: 'Existing text',
            similarity: 0.5,
          ),
        ),
        KnowledgeImportDraft(
          id: '3',
          category: KnowledgeDraftCategory.productFeature,
          title: 'Feature',
          content: 'Text',
          sourceSentence: 'Text',
          keywords: ['app'],
          knowledgeArea: 'hb_cure_app',
          detectedTopics: ['App'],
          isPossibleDuplicate: true,
        ),
      ],
    );

    final result = KnowledgeAnalysisPresentation.fromAnalysis(analysis);

    expect(result.documentType, KnowledgeDocumentType.faqCollection);
    expect(result.faqCount, 2);
    expect(result.productFeatureCount, 1);
    expect(result.keywordCount, 3);
    expect(result.similarTopicCount, 2);
    expect(result.productCount, 1);
    expect(result.deviceCount, 2);
    expect(result.functionCount, 1);
  });
}
