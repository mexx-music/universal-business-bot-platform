import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/knowledge_builder/knowledge_import_mapper.dart';
import 'package:universalbusiness/knowledge_builder/models/knowledge_import_models.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';

void main() {
  test('maps drafts verbatim onto existing workspace knowledge entries', () {
    final createdAt = DateTime.utc(2026, 8, 3);
    final entries = const KnowledgeImportMapper().toWorkspaceEntries(const [
      KnowledgeImportDraft(
        id: 'faq',
        category: KnowledgeDraftCategory.faq,
        title: 'Wie wird verbunden?',
        content: 'Die App verbindet sich per Bluetooth.',
        sourceSentence: 'Die App verbindet sich per Bluetooth.',
        keywords: ['Bluetooth'],
        languageCode: 'de',
        knowledgeArea: 'hb_cure_app',
        detectedTopics: ['App', 'Bluetooth'],
      ),
      KnowledgeImportDraft(
        id: 'warning',
        category: KnowledgeDraftCategory.warning,
        title: 'Verbindung nicht trennen',
        content: 'Trennen Sie die Verbindung während des Updates nicht.',
        sourceSentence: 'Trennen Sie die Verbindung während des Updates nicht.',
      ),
    ], createdAt: createdAt);

    expect(entries, hasLength(2));
    expect(entries.first.content, 'Die App verbindet sich per Bluetooth.');
    expect(entries.first.category, KnowledgeCategory.faq);
    expect(entries.first.riskLevel, RiskLevel.green);
    expect(entries.first.languageCode, 'de');
    expect(entries.first.knowledgeArea, 'hb_cure_app');
    expect(entries.first.detectedTopics, ['App', 'Bluetooth']);
    expect(entries.first.source, KnowledgeEntrySources.knowledgeBuilder);
    expect(entries.first.createdAt, createdAt);
    expect(entries.last.riskLevel, RiskLevel.yellow);
    expect(entries.map((entry) => entry.id).toSet(), hasLength(2));
  });
}
