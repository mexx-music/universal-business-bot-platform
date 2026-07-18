import '../models/company_workspace.dart';
import 'knowledge_answer_context.dart';
import 'knowledge_ranking.dart';
import 'knowledge_retriever.dart';

/// Orchestrates retrieval and ranking into a [KnowledgeAnswerContext]:
/// question in, structured answer context out. Pure and side-effect free —
/// the workspace is only read, never modified.
///
/// This is the layer a future answer generator (LLM, template engine, bot
/// widget) plugs into: it receives the top entries/sources, the confidence
/// and the gaps, and never searches the workspace itself.
class KnowledgeRuntime {
  const KnowledgeRuntime({
    this.retriever = const KnowledgeRetriever(),
    this.ranking = const KnowledgeRanking(),
    this.maxEntries = 5,
    this.maxSources = 3,
    this.gapThreshold = 40,
  });

  final KnowledgeRetriever retriever;
  final KnowledgeRanking ranking;

  /// How many top matches the context carries.
  final int maxEntries;
  final int maxSources;

  /// Below this confidence a [KnowledgeGap] is created.
  final int gapThreshold;

  KnowledgeAnswerContext buildContext({
    required String userQuestion,
    required CompanyWorkspace workspace,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final retrieval = retriever.retrieve(userQuestion, workspace);
    final query = retrieval.query;

    final topEntries = ranking
        .rankEntries(retrieval, now: timestamp)
        .where((match) => match.score > 0)
        .take(maxEntries)
        .toList();
    final topSources = ranking
        .rankSources(retrieval, now: timestamp)
        .where((match) => match.score > 0)
        .take(maxSources)
        .toList();

    // Coverage: which question terms are answered by anything we found.
    final matchedTerms = <String>{
      for (final match in topEntries)
        ...retrieval.entrySignals
            .firstWhere((s) => s.entry.id == match.entry.id)
            .allMatchedTerms,
      for (final match in topSources)
        ...retrieval.sourceSignals
            .firstWhere((s) => s.source.id == match.source.id)
            .allMatchedTerms,
    };
    final coveredTerms = query.coveredBaseTerms(matchedTerms);
    final missingTerms = [
      for (final term in query.baseTerms)
        if (!coveredTerms.contains(term)) term,
    ];
    final coverage = query.isEmpty
        ? 0.0
        : coveredTerms.length / query.baseTerms.length;

    final confidence = _confidence(
      query: query,
      coverage: coverage,
      topEntries: topEntries,
      retrieval: retrieval,
    );

    final reasoning = _reasoning(
      query: query,
      coverage: coverage,
      confidence: confidence,
      topEntries: topEntries,
      topSources: topSources,
      retrieval: retrieval,
    );

    final missingInformation = <String>[
      for (final term in missingTerms)
        'Kein freigegebenes Wissen zum Begriff „$term".',
      if (topEntries.isEmpty && !query.isEmpty)
        'Kein Wissenseintrag passt zu dieser Frage.',
    ];

    final openQuestions = <String>[
      for (final term in missingTerms)
        'Soll zu „$term" ein Wissenseintrag angelegt werden?',
      for (final topic in retrieval.blockedTopicHits)
        'Frage berührt das gesperrte Thema „$topic" – '
            'menschliche Übergabe erforderlich.',
      if (topEntries.any((match) => match.restricted))
        'Bester Treffer liegt in einem gesperrten Bereich – '
            'Antwort nur durch einen Menschen.',
    ];

    final gap = confidence < gapThreshold
        ? KnowledgeGap(
            companyId: workspace.company.id,
            question: userQuestion,
            reason: topEntries.isEmpty
                ? 'Für diese Frage existiert noch kein freigegebenes Wissen.'
                : 'Das vorhandene Wissen deckt die Frage nur unzureichend ab.',
            missingTerms: missingTerms,
            confidence: confidence,
            createdAt: timestamp,
          )
        : null;

    return KnowledgeAnswerContext(
      question: userQuestion,
      companyId: workspace.company.id,
      queryTerms: query.baseTerms,
      topEntries: topEntries,
      topSources: topSources,
      confidence: confidence,
      reasoning: reasoning,
      missingInformation: missingInformation,
      openQuestions: openQuestions,
      blockedTopicHits: retrieval.blockedTopicHits,
      gap: gap,
    );
  }

  /// Confidence 0–100:
  ///   best answerable entry score × 0.65
  /// + term coverage × 25
  /// + corroboration (up to 10 for further strong matches)
  /// + review bonus (5 when Human Review already confirmed similar answers)
  /// capped at 25 when only restricted knowledge matches or the question
  /// touches a blocked topic — such questions must not be answered by a bot,
  /// regardless of how much knowledge exists.
  int _confidence({
    required QueryProfile query,
    required double coverage,
    required List<ScoredKnowledgeMatch> topEntries,
    required RetrievalResult retrieval,
  }) {
    if (query.isEmpty) return 0;

    final answerable = [
      for (final match in topEntries)
        if (!match.restricted) match,
    ];
    final topScore = answerable.isEmpty ? 0 : answerable.first.score;
    final corroboration =
        (answerable.skip(1).where((m) => m.score >= 40).length * 5).clamp(
          0,
          10,
        );
    final reviewBonus = retrieval.reviewedSimilarLogs.isEmpty ? 0 : 5;

    var confidence =
        (topScore * 0.65 + coverage * 25 + corroboration + reviewBonus)
            .round()
            .clamp(0, 100);

    final onlyRestrictedKnowledge =
        answerable.isEmpty && topEntries.any((match) => match.restricted);
    final restrictedOutranksAnswerable =
        answerable.isNotEmpty &&
        topEntries.first.restricted &&
        topEntries.first.score > answerable.first.score;
    if (retrieval.blockedTopicHits.isNotEmpty ||
        onlyRestrictedKnowledge ||
        restrictedOutranksAnswerable) {
      confidence = confidence.clamp(0, 25);
    }
    return confidence;
  }

  List<String> _reasoning({
    required QueryProfile query,
    required double coverage,
    required int confidence,
    required List<ScoredKnowledgeMatch> topEntries,
    required List<ScoredSourceMatch> topSources,
    required RetrievalResult retrieval,
  }) {
    final coveragePercent = (coverage * 100).round();
    return [
      if (query.isEmpty)
        'Die Frage enthält keine auswertbaren Begriffe.'
      else
        'Suchbegriffe: ${query.baseTerms.join(', ')} '
            '($coveragePercent % durch Wissen abgedeckt).',
      if (topEntries.isNotEmpty)
        'Bester Treffer: „${topEntries.first.entry.title}" '
            '(Score ${topEntries.first.score}).',
      if (topSources.isNotEmpty)
        'Beste Quelle: „${topSources.first.source.title}" '
            '(Score ${topSources.first.score}).',
      if (retrieval.reviewedSimilarLogs.isNotEmpty)
        'Ähnliche Frage wurde bereits durch Human Review beantwortet '
            '(${retrieval.reviewedSimilarLogs.length}×).',
      if (retrieval.allowedTopicHits.isNotEmpty)
        'Frage liegt im erlaubten Themenbereich '
            '(${retrieval.allowedTopicHits.join(', ')}).',
      if (retrieval.blockedTopicHits.isNotEmpty)
        'Frage berührt gesperrte Themen '
            '(${retrieval.blockedTopicHits.join(', ')}) – Confidence begrenzt.',
      'Confidence: $confidence %.',
    ];
  }
}
