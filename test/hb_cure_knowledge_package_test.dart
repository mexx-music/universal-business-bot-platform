import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/ai/ai_controller.dart';
import 'package:universalbusiness/ai/ai_provider_registry.dart';
import 'package:universalbusiness/ai/grounded_answer_service.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/knowledge_builder/data/hb_cure_knowledge_package.dart';
import 'package:universalbusiness/knowledge_builder/knowledge_import_analyzer.dart';
import 'package:universalbusiness/knowledge_builder/knowledge_import_mapper.dart';
import 'package:universalbusiness/knowledge_builder/knowledge_package_analysis_enricher.dart';
import 'package:universalbusiness/knowledge_builder/models/company_knowledge_package.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';

void main() {
  test('contains every required HB Cure area and separated source types', () {
    final package = hbCureKnowledgePackage;

    expect(
      package.includedAreas('de'),
      containsAll(<String>[
        'Unternehmen',
        'HB Cure Überblick',
        'H&B Cure App',
        'CureBase',
        'CureClip',
        'Programme',
        'Kennenlernangebot',
        'FAQ',
        'Support',
        'Kontakt',
      ]),
    );
    expect(package.documents.length, greaterThanOrEqualTo(10));
    expect(
      package.documents.map((document) => document.source.type).toSet(),
      containsAll({
        KnowledgePackageSourceType.publicCompanyWebsite,
        KnowledgePackageSourceType.confirmedProductDocumentation,
        KnowledgePackageSourceType.confirmedSupportDocumentation,
      }),
    );
    expect(
      package.documents
          .where(
            (document) =>
                document.source.type ==
                KnowledgePackageSourceType.publicCompanyWebsite,
          )
          .every(
            (document) =>
                document.source.name('de') == 'Healing-&-Balance-Website',
          ),
      isTrue,
    );
  });

  test('marks sensitive and time-dependent documents explicitly', () {
    final package = hbCureKnowledgePackage;
    final riskTypes = package.documents
        .map((document) => document.risk.type)
        .toSet();

    expect(package.reviewRequiredDocumentCount, greaterThanOrEqualTo(2));
    expect(riskTypes, contains(KnowledgePackageRiskType.impactRelatedClaim));
    expect(riskTypes, contains(KnowledgePackageRiskType.testimonial));
    expect(package.timeSensitiveDocumentCount, greaterThanOrEqualTo(3));
    expect(
      package.documents
          .where((document) => document.freshness.timeSensitive)
          .every((document) => document.freshness.reviewRecommended),
      isTrue,
    );
  });

  test('German and English package content stays language-consistent', () {
    final package = hbCureKnowledgePackage;
    final german = package.editorContent('de');
    final english = package.editorContent('en');

    expect(german, contains('Zum HB-Cure-System gehören'));
    expect(german, contains('keine Kaufpflicht'));
    expect(german, isNot(contains('The HB Cure system consists')));
    expect(package.title('de'), 'HB Cure – vollständiges Demo-Wissen');

    expect(english, contains('The HB Cure system consists'));
    expect(english, contains('There is no obligation to purchase'));
    expect(english, isNot(contains('Zum HB-Cure-System gehören')));
    expect(package.title('en'), 'HB Cure – complete demo knowledge');
  });

  test(
    'existing analyzer receives package text and provenance is retained',
    () {
      final state = AppState();
      final package = hbCureKnowledgePackage;
      final analysis = const KnowledgeImportAnalyzer().analyze(
        package.editorContent('de'),
        workspace: state.selectedWorkspace,
      );
      final enriched = const KnowledgePackageAnalysisEnricher().enrich(
        analysis: analysis,
        package: package,
        languageCode: 'de',
      );

      expect(enriched.drafts, isNotEmpty);
      expect(
        enriched.drafts.every((draft) => draft.languageCode == 'de'),
        isTrue,
      );
      expect(
        enriched.drafts.every((draft) => draft.packageMetadata != null),
        isTrue,
      );
      expect(
        enriched.drafts
            .map((draft) => draft.packageMetadata!.sourceType)
            .toSet(),
        containsAll({
          'Öffentliche Unternehmenswebsite',
          'Bestätigte Produktdokumentation',
          'Bestätigte Support-Dokumentation',
        }),
      );
    },
  );

  test(
    'mapper preserves package origins and review risk in existing model',
    () {
      final state = AppState();
      final analysis = const KnowledgePackageAnalysisEnricher().enrich(
        analysis: const KnowledgeImportAnalyzer().analyze(
          hbCureKnowledgePackage.editorContent('de'),
          workspace: state.selectedWorkspace,
        ),
        package: hbCureKnowledgePackage,
        languageCode: 'de',
      );
      final entries = const KnowledgeImportMapper().toWorkspaceEntries(
        analysis.drafts,
        createdAt: DateTime.utc(2026, 8, 3),
      );

      expect(
        entries.every(
          (entry) => KnowledgeEntrySources.isKnowledgeBuilder(entry.source),
        ),
        isTrue,
      );
      expect(
        entries.any(
          (entry) => entry.source.contains('Healing-&-Balance-Website'),
        ),
        isTrue,
      );
      expect(
        entries.any(
          (entry) =>
              entry.source.contains('Interne HB-Cure-Produktdokumentation'),
        ),
        isTrue,
      );
      expect(
        entries.any((entry) => entry.riskLevel == RiskLevel.yellow),
        isTrue,
      );
    },
  );

  test('confirmed package answers the prepared core question set', () async {
    final state = AppState();
    final analysis = const KnowledgePackageAnalysisEnricher().enrich(
      analysis: const KnowledgeImportAnalyzer().analyze(
        hbCureKnowledgePackage.editorContent('de'),
        workspace: state.selectedWorkspace,
      ),
      package: hbCureKnowledgePackage,
      languageCode: 'de',
    );
    final entries = const KnowledgeImportMapper().toWorkspaceEntries(
      analysis.drafts,
    );
    final workspace = state.selectedWorkspace.copyWith(
      knowledgeEntries: entries,
      sourceMaterials: const [],
    );
    final service = GroundedAnswerService(
      aiController: AiController(AiProviderRegistry.mock()),
    );
    const questions = [
      'Was ist HB Cure?',
      'Welche Produkte gehören zu HB Cure?',
      'Was ist CureBase?',
      'Was ist CureClip?',
      'Was macht die H&B Cure App?',
      'Wie verbinde ich ein Gerät mit der App?',
      'Wie starte ich ein Frequenzprogramm?',
      'Wie viele Programme enthält die App?',
      'Was mache ich bei Verbindungsproblemen?',
      'Gibt es ein Kennenlernangebot?',
      'Muss ich nach dem Testmonat kaufen?',
      'Wie erreiche ich Healing & Balance?',
    ];

    for (final question in questions) {
      final result = await service.answer(
        GroundedAnswerRequest(
          question: question,
          workspace: workspace,
          language: 'de',
        ),
      );
      expect(
        result.outcome,
        GroundedOutcome.answered,
        reason: 'Expected package knowledge for: $question',
      );
      expect(result.sources, isNotEmpty, reason: question);
      expect(result.answer, isNotEmpty, reason: question);
    }
  });
}
