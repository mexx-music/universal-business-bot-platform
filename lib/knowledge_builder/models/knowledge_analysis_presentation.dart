import 'knowledge_import_models.dart';

/// Presentation-only document types derived from the categories the existing
/// analyzer has already produced. No additional AI analysis happens here.
enum KnowledgeDocumentType {
  faqCollection,
  productDescription,
  instructions,
  technicalDocumentation,
  companyKnowledge,
}

/// One demo question tied to exactly one analyzed draft. Its answer and source
/// are verbatim user input, so the preview cannot introduce new facts.
class KnowledgeDemoQuestion {
  const KnowledgeDemoQuestion({required this.question, required this.draft});

  final String question;
  final KnowledgeImportDraft draft;

  String get answer => draft.content;
  String get sourceSentence => draft.sourceSentence;
}

/// Transparent, deterministic metrics for the Knowledge Builder journey.
/// Every value can be traced back to [KnowledgeImportAnalysis].
class KnowledgeAnalysisPresentation {
  const KnowledgeAnalysisPresentation({
    required this.analysis,
    required this.documentType,
    required this.faqCount,
    required this.productFeatureCount,
    required this.stepCount,
    required this.warningCount,
    required this.requirementCount,
    required this.definitionCount,
    required this.tipCount,
    required this.keywordCount,
    required this.similarTopicCount,
    required this.productCount,
    required this.deviceCount,
    required this.functionCount,
    required this.demoQuestions,
  });

  factory KnowledgeAnalysisPresentation.fromAnalysis(
    KnowledgeImportAnalysis analysis,
  ) {
    int count(KnowledgeDraftCategory category) =>
        analysis.drafts.where((draft) => draft.category == category).length;

    final faq = count(KnowledgeDraftCategory.faq);
    final productFeatures = count(KnowledgeDraftCategory.productFeature);
    final steps =
        count(KnowledgeDraftCategory.stepByStep) +
        count(KnowledgeDraftCategory.installation);
    final warnings = count(KnowledgeDraftCategory.warning);
    final requirements = count(KnowledgeDraftCategory.technicalRequirement);
    final definitions = count(KnowledgeDraftCategory.definition);
    final tips = count(KnowledgeDraftCategory.tip);

    final keywords = <String>{
      for (final draft in analysis.drafts)
        for (final keyword in draft.keywords) keyword.toLowerCase(),
    };
    final topicFrequency = <String, int>{};
    for (final draft in analysis.drafts) {
      for (final topic in draft.detectedTopics.toSet()) {
        final normalized = topic.toLowerCase();
        topicFrequency[normalized] = (topicFrequency[normalized] ?? 0) + 1;
      }
    }
    final productAreas = <String>{
      for (final draft in analysis.drafts)
        if (_isProductArea(draft.knowledgeArea)) draft.knowledgeArea!,
    };
    final deviceTopics = <String>{
      for (final topic in analysis.drafts.expand((d) => d.detectedTopics))
        if (_deviceTopics.contains(topic.toLowerCase())) topic.toLowerCase(),
    };

    return KnowledgeAnalysisPresentation(
      analysis: analysis,
      documentType: _documentType(
        faq: faq,
        productFeatures: productFeatures,
        steps: steps,
        warnings: warnings,
        requirements: requirements,
        definitions: definitions,
      ),
      faqCount: faq,
      productFeatureCount: productFeatures,
      stepCount: steps,
      warningCount: warnings,
      requirementCount: requirements,
      definitionCount: definitions,
      tipCount: tips,
      keywordCount: keywords.length,
      similarTopicCount: topicFrequency.values
          .where((count) => count > 1)
          .length,
      productCount: productAreas.length,
      deviceCount: deviceTopics.length,
      functionCount: productFeatures,
      demoQuestions: _demoQuestions(analysis),
    );
  }

  final KnowledgeImportAnalysis analysis;
  final KnowledgeDocumentType documentType;
  final int faqCount;
  final int productFeatureCount;
  final int stepCount;
  final int warningCount;
  final int requirementCount;
  final int definitionCount;
  final int tipCount;
  final int keywordCount;
  final int similarTopicCount;
  final int productCount;
  final int deviceCount;
  final int functionCount;
  final List<KnowledgeDemoQuestion> demoQuestions;

  static KnowledgeDocumentType _documentType({
    required int faq,
    required int productFeatures,
    required int steps,
    required int warnings,
    required int requirements,
    required int definitions,
  }) {
    final groups = <KnowledgeDocumentType, int>{
      KnowledgeDocumentType.faqCollection: faq,
      KnowledgeDocumentType.productDescription: productFeatures + definitions,
      KnowledgeDocumentType.instructions: steps,
      KnowledgeDocumentType.technicalDocumentation: warnings + requirements,
    };
    final best = groups.entries.reduce(
      (current, next) => next.value > current.value ? next : current,
    );
    return best.value == 0 ? KnowledgeDocumentType.companyKnowledge : best.key;
  }

  static bool _isProductArea(String? area) => switch (area) {
    'hb_cure_app' ||
    'curebase' ||
    'cureclip' ||
    'schnurrpurr' ||
    'other_product' => true,
    _ => false,
  };

  static const _deviceTopics = {
    'gerät',
    'device',
    'bluetooth',
    'firmware',
    'android',
    'ios',
  };

  static List<KnowledgeDemoQuestion> _demoQuestions(
    KnowledgeImportAnalysis analysis,
  ) {
    final languageCode = analysis.inputLanguageCode;
    final questions = <KnowledgeDemoQuestion>[];
    final seen = <String>{};
    for (final draft in analysis.drafts) {
      final question = draft.question?.trim().isNotEmpty == true
          ? draft.question!.trim()
          : _questionForDraft(draft, languageCode);
      if (question.isEmpty || !seen.add(question.toLowerCase())) continue;
      questions.add(KnowledgeDemoQuestion(question: question, draft: draft));
      if (questions.length == 4) break;
    }
    return List.unmodifiable(questions);
  }

  static String _questionForDraft(
    KnowledgeImportDraft draft,
    String? languageCode,
  ) {
    final english = languageCode == 'en';
    final subject = _subject(draft, english: english);
    return switch (draft.category) {
      KnowledgeDraftCategory.installation ||
      KnowledgeDraftCategory.stepByStep =>
        english ? 'How do I use $subject?' : 'Wie verwende ich $subject?',
      KnowledgeDraftCategory.technicalRequirement =>
        english
            ? 'What technical requirements apply to $subject?'
            : 'Welche technischen Voraussetzungen gelten für $subject?',
      KnowledgeDraftCategory.warning =>
        english
            ? 'What should I keep in mind about $subject?'
            : 'Was ist bei $subject zu beachten?',
      KnowledgeDraftCategory.troubleshooting =>
        english
            ? 'What does the document say about problems with $subject?'
            : 'Was sagt das Dokument zu Problemen mit $subject?',
      KnowledgeDraftCategory.productFeature =>
        english ? 'How does $subject work?' : 'Wie funktioniert $subject?',
      KnowledgeDraftCategory.definition =>
        english ? 'What does $subject mean?' : 'Was bedeutet $subject?',
      KnowledgeDraftCategory.tip =>
        english
            ? 'What guidance does the document provide about $subject?'
            : 'Welche Hinweise enthält das Dokument zu $subject?',
      KnowledgeDraftCategory.faq ||
      KnowledgeDraftCategory.contact ||
      KnowledgeDraftCategory.general =>
        english
            ? 'What does the document say about $subject?'
            : 'Was sagt das Dokument zu $subject?',
    };
  }

  static String _subject(KnowledgeImportDraft draft, {required bool english}) {
    final topics = draft.detectedTopics.take(2).toList();
    if (topics.isNotEmpty) {
      return topics.join(english ? ' and ' : ' und ');
    }
    final keywords = draft.keywords.take(2).toList();
    if (keywords.isNotEmpty) {
      return keywords.join(english ? ' and ' : ' und ');
    }
    return draft.title;
  }
}
