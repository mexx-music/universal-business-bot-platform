import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/knowledge_builder/knowledge_import_analyzer.dart';
import 'package:universalbusiness/knowledge_builder/models/knowledge_import_models.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';

const _analyzer = KnowledgeImportAnalyzer();

KnowledgeEntry existing(String id, String title, String content) =>
    KnowledgeEntry(
      id: id,
      title: title,
      content: content,
      category: KnowledgeCategory.faq,
      riskLevel: RiskLevel.green,
      keywords: const [],
      source: 'Test',
      createdAt: DateTime(2026, 1, 1),
    );

const _sampleText = '''
Die App läuft unter Android und iOS.
Bluetooth muss aktiviert sein.
Zum Installieren laden Sie die App herunter.
Achtung: Das Gerät niemals während eines Updates ausschalten.
Die App benötigt mindestens Android Version 9.
Kontakt: support@example.com
Programme werden lokal gespeichert.
''';

Set<KnowledgeDraftCategory> _categories(KnowledgeImportAnalysis a) =>
    a.drafts.map((d) => d.category).toSet();

void main() {
  group('KnowledgeImportAnalyzer', () {
    test('analyzes a long free text into sentences and drafts', () {
      final a = _analyzer.analyze(_sampleText);
      expect(a.analyzedSentences, 7);
      expect(a.drafts, isNotEmpty);
      expect(
        a.detectedTopicLabels,
        containsAll(['Bluetooth', 'App', 'Android']),
      );
      expect(a.detectedTopics, a.detectedTopicLabels.length);
    });

    test('recognizes multiple categories', () {
      final cats = _categories(_analyzer.analyze(_sampleText));
      expect(cats, contains(KnowledgeDraftCategory.faq));
      expect(cats, contains(KnowledgeDraftCategory.installation));
      expect(cats, contains(KnowledgeDraftCategory.technicalRequirement));
      expect(cats, contains(KnowledgeDraftCategory.warning));
      expect(cats, contains(KnowledgeDraftCategory.contact));
      expect(cats, contains(KnowledgeDraftCategory.productFeature));
    });

    test('FAQ drafts get a generated question; content stays verbatim', () {
      final a = _analyzer.analyze('Bluetooth muss aktiviert sein.');
      final draft = a.drafts.single;
      expect(draft.category, KnowledgeDraftCategory.faq);
      expect(draft.question, 'Muss Bluetooth aktiviert sein?');
      // Content is the user's own text, never rewritten or extended.
      expect(draft.content, 'Bluetooth muss aktiviert sein');
      expect(draft.keywords, contains('bluetooth'));
      expect(draft.languageCode, 'de');
    });

    test('English input produces English questions and metadata', () {
      final draft = _analyzer
          .analyze('The HB Cure App must support Bluetooth connections.')
          .drafts
          .single;

      expect(draft.languageCode, 'en');
      expect(
        draft.question,
        'Must the HB Cure App support Bluetooth connections?',
      );
      expect(draft.knowledgeArea, 'hb_cure_app');
      expect(draft.detectedTopics, containsAll(['Bluetooth', 'Connection']));
    });

    test('German input keeps German generated wording and detects scope', () {
      final draft = _analyzer
          .analyze('Die HB Cure App muss das Gerät über Bluetooth verbinden.')
          .drafts
          .single;

      expect(draft.languageCode, 'de');
      expect(
        draft.question,
        'Muss die HB Cure App das Gerät über Bluetooth verbinden?',
      );
      expect(draft.knowledgeArea, 'hb_cure_app');
      expect(draft.detectedTopics, containsAll(['Bluetooth', 'Gerät', 'App']));
    });

    test('recognizes a direct customer question as FAQ', () {
      final draft = _analyzer
          .analyze('Wie verbinde ich das Gerät mit der HB Cure App?')
          .drafts
          .single;

      expect(draft.category, KnowledgeDraftCategory.faq);
      expect(draft.title, 'Wie verbinde ich das Gerät mit der HB Cure App?');
      expect(draft.knowledgeArea, 'hb_cure_app');
    });

    test('ambiguous input does not assume a default language', () {
      final draft = _analyzer.analyze('Bluetooth Firmware 12').drafts.single;
      expect(draft.languageCode, isNull);
    });

    test('detects near-duplicates within the same batch', () {
      final a = _analyzer.analyze(
        'Bluetooth muss aktiviert sein.\n'
        'Bluetooth muss aktiviert werden.',
      );
      expect(a.drafts.length, 2);
      expect(a.possibleDuplicates, 1);
      expect(a.drafts.first.isPossibleDuplicate, isFalse);
      expect(a.drafts.last.isPossibleDuplicate, isTrue);
    });

    test('matches an existing entry instead of proposing a fresh one', () {
      final a = _analyzer.analyze(
        'Bluetooth muss aktiviert sein.',
        existingEntries: [
          existing(
            'e1',
            'Bluetooth aktivieren',
            'Bluetooth muss vor der Nutzung aktiviert werden.',
          ),
        ],
      );
      final draft = a.drafts.single;
      expect(draft.matchesExisting, isTrue);
      expect(draft.existingMatch!.existingEntryId, 'e1');
      expect(a.existingMatches, 1);
      expect(a.newEntries, 0);
    });

    test('a brand-new topic does not match unrelated existing entries', () {
      final a = _analyzer.analyze(
        'Die App benötigt mindestens Android Version 9.',
        existingEntries: [
          existing(
            'e1',
            'Rückgaberecht',
            'Rücksendungen sind 14 Tage möglich.',
          ),
        ],
      );
      expect(a.drafts.single.matchesExisting, isFalse);
      expect(a.newEntries, 1);
      expect(a.existingMatches, 0);
    });

    test('counts unclear (too short) statements without drafting them', () {
      final a = _analyzer.analyze(
        'Fertig.\nOK.\nBluetooth muss aktiviert sein.',
      );
      expect(a.unclearStatements, 2);
      expect(a.drafts.length, 1);
    });

    test('empty input yields an empty analysis', () {
      final a = _analyzer.analyze('   \n  \n');
      expect(a.isEmpty, isTrue);
      expect(a.analyzedSentences, 0);
      expect(a.detectedTopics, 0);
    });
  });
}
