import '../models/knowledge_entry.dart';
import '../models/source_material.dart';
import 'knowledge_answer_context.dart';
import 'knowledge_retriever.dart';

/// Turns raw retrieval signals into 0–100 scores with human-readable
/// reasons. Plain example heuristics, no AI:
///
/// Knowledge entries          Source materials
///   title matches      35      title matches      25
///   keywords match     25      snippet matches    15
///   content matches    15      notes match        10
///   category matches    5      reviewed/converted 10
///   review confirmed   10      fresh (≤ 365 d)     5
///   fresh (≤ 365 d)     5
///   risk level green    5
///
/// Term-based weights are scaled by how many of the question's terms the
/// field covers, so an entry matching "kosten" *and* "abo" outranks one
/// matching only "kosten". Red-risk entries keep their relevance score but
/// are flagged [ScoredKnowledgeMatch.restricted].
class KnowledgeRanking {
  const KnowledgeRanking({this.freshnessWindow = const Duration(days: 365)});

  final Duration freshnessWindow;

  List<ScoredKnowledgeMatch> rankEntries(
    RetrievalResult retrieval, {
    required DateTime now,
  }) {
    final matches = <ScoredKnowledgeMatch>[
      for (final signals in retrieval.entrySignals)
        _scoreEntry(signals, retrieval.query, now),
    ];
    // Score descending, then id ascending for deterministic order.
    matches.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.entry.id.compareTo(b.entry.id);
    });
    return matches;
  }

  List<ScoredSourceMatch> rankSources(
    RetrievalResult retrieval, {
    required DateTime now,
  }) {
    final matches = <ScoredSourceMatch>[
      for (final signals in retrieval.sourceSignals)
        _scoreSource(signals, retrieval.query, now),
    ];
    matches.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.source.id.compareTo(b.source.id);
    });
    return matches;
  }

  ScoredKnowledgeMatch _scoreEntry(
    EntryMatchSignals signals,
    QueryProfile query,
    DateTime now,
  ) {
    var score = 0.0;
    final reasons = <String>[];

    score += _termScore(35, 'Titel passt', signals.titleTerms, query, reasons);
    score += _termScore(
      25,
      'Schlagwörter passen',
      signals.keywordTerms,
      query,
      reasons,
    );
    score += _termScore(
      15,
      'Inhalt passt',
      signals.contentTerms,
      query,
      reasons,
    );
    if (signals.categoryMatched) {
      score += 5;
      reasons.add('Kategorie passt (${signals.entry.category.name})');
    }
    if (signals.reviewConfirmed) {
      score += 10;
      reasons.add('Durch Human Review bestätigt');
    }
    if (_isFresh(signals.entry.createdAt, now)) {
      score += 5;
      reasons.add('Aktueller Eintrag');
    }
    final restricted = signals.entry.riskLevel == RiskLevel.red;
    if (signals.entry.riskLevel == RiskLevel.green) {
      score += 5;
      reasons.add('Freigegebenes Wissen (Risikostufe Grün)');
    } else if (restricted) {
      reasons.add('Gesperrtes Thema (Risikostufe Rot) – nur Eskalation');
    }

    return ScoredKnowledgeMatch(
      entry: signals.entry,
      score: score.round().clamp(0, 100),
      reasons: reasons,
      restricted: restricted,
    );
  }

  ScoredSourceMatch _scoreSource(
    SourceMatchSignals signals,
    QueryProfile query,
    DateTime now,
  ) {
    var score = 0.0;
    final reasons = <String>[];

    score += _termScore(25, 'Titel passt', signals.titleTerms, query, reasons);
    score += _termScore(
      15,
      'Inhalt passt',
      signals.snippetTerms,
      query,
      reasons,
    );
    score += _termScore(
      10,
      'Notizen passen',
      signals.notesTerms,
      query,
      reasons,
    );
    final status = signals.source.status;
    if (status == SourceMaterialStatus.reviewed ||
        status == SourceMaterialStatus.converted) {
      score += 10;
      reasons.add('Geprüfte Quelle (${status.name})');
    }
    if (_isFresh(signals.source.updatedAt, now)) {
      score += 5;
      reasons.add('Aktuelle Quelle');
    }

    return ScoredSourceMatch(
      source: signals.source,
      score: score.round().clamp(0, 100),
      reasons: reasons,
    );
  }

  /// Weight scaled by the fraction of question terms this field covers.
  double _termScore(
    double weight,
    String label,
    Set<String> matchedTerms,
    QueryProfile query,
    List<String> reasons,
  ) {
    if (matchedTerms.isEmpty || query.isEmpty) return 0;
    final covered = query.coveredBaseTerms(matchedTerms);
    if (covered.isEmpty) return 0;
    reasons.add('$label (${covered.join(', ')})');
    return weight * covered.length / query.baseTerms.length;
  }

  bool _isFresh(DateTime timestamp, DateTime now) {
    final age = now.difference(timestamp);
    return !age.isNegative && age <= freshnessWindow;
  }
}
