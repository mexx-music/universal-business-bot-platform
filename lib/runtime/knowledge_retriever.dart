import '../models/bot_question_log.dart';
import '../models/company_workspace.dart';
import '../models/knowledge_entry.dart';
import '../models/source_material.dart';

/// The normalized form of a user question: distinct stopword-free terms plus
/// a simple synonym expansion per term.
class QueryProfile {
  const QueryProfile({
    required this.original,
    required this.baseTerms,
    required this.expansions,
  });

  final String original;

  /// Distinct meaningful terms of the question, in original order.
  final List<String> baseTerms;

  /// baseTerm -> {baseTerm, synonyms…}.
  final Map<String, Set<String>> expansions;

  bool get isEmpty => baseTerms.isEmpty;

  /// Every term worth searching for (base terms + synonyms).
  Set<String> get allTerms => {for (final terms in expansions.values) ...terms};

  /// Which base terms are covered by [matchedTerms] (directly or via a
  /// synonym). Used for coverage and gap detection.
  Set<String> coveredBaseTerms(Set<String> matchedTerms) {
    return {
      for (final term in baseTerms)
        if (expansions[term]!.any(matchedTerms.contains)) term,
    };
  }
}

/// Raw match signals for one knowledge entry (scoring happens in the
/// ranking, not here).
class EntryMatchSignals {
  const EntryMatchSignals({
    required this.entry,
    required this.titleTerms,
    required this.contentTerms,
    required this.keywordTerms,
    required this.categoryMatched,
    required this.reviewConfirmed,
  });

  final KnowledgeEntry entry;
  final Set<String> titleTerms;
  final Set<String> contentTerms;
  final Set<String> keywordTerms;
  final bool categoryMatched;

  /// A reviewed Human-Review log covers overlapping terms.
  final bool reviewConfirmed;

  Set<String> get allMatchedTerms => {
    ...titleTerms,
    ...contentTerms,
    ...keywordTerms,
  };
}

/// Raw match signals for one source material.
class SourceMatchSignals {
  const SourceMatchSignals({
    required this.source,
    required this.titleTerms,
    required this.snippetTerms,
    required this.notesTerms,
  });

  final SourceMaterial source;
  final Set<String> titleTerms;
  final Set<String> snippetTerms;
  final Set<String> notesTerms;

  Set<String> get allMatchedTerms => {
    ...titleTerms,
    ...snippetTerms,
    ...notesTerms,
  };
}

/// Everything the retriever found for one question in one workspace.
class RetrievalResult {
  const RetrievalResult({
    required this.query,
    required this.entrySignals,
    required this.sourceSignals,
    required this.reviewedSimilarLogs,
    required this.blockedTopicHits,
    required this.allowedTopicHits,
  });

  final QueryProfile query;
  final List<EntryMatchSignals> entrySignals;
  final List<SourceMatchSignals> sourceSignals;

  /// Human-reviewed logs (answered, not open) whose question overlaps the
  /// current one — earlier review work that corroborates an answer.
  final List<BotQuestionLog> reviewedSimilarLogs;

  /// Blocked bot topics the question touches.
  final List<String> blockedTopicHits;

  /// Allowed topics (bot configuration + business rules) the question hits.
  final List<String> allowedTopicHits;
}

/// Finds everything in a workspace that could be relevant for a question:
/// knowledge entries (incl. FAQ), source materials, reviewed Human-Review
/// results and the bot rules. Purely lexical — normalization, stopwords and
/// a small synonym list; no AI, no network, no side effects.
class KnowledgeRetriever {
  const KnowledgeRetriever();

  static const Set<String> _stopwords = {
    // German
    'aber', 'als', 'auch', 'auf', 'aus', 'bei', 'bin', 'bitte', 'das', 'dass',
    'dem', 'den', 'der', 'des', 'die', 'doch', 'ein', 'eine', 'einem',
    'einen', 'einer', 'für', 'gibt', 'hab', 'habe', 'haben', 'hat', 'ich',
    'ihr', 'ist', 'kann', 'können', 'mein', 'meine', 'meinem', 'meinen',
    'meiner', 'mich', 'mir', 'mit', 'muss', 'nach', 'nicht', 'noch', 'oder',
    'schon', 'sein', 'sich', 'sie', 'sind', 'soll', 'sollte', 'und', 'uns',
    'vom', 'von', 'vor', 'wann', 'war', 'warum', 'was', 'welche', 'welcher',
    'wenn', 'wer', 'werden', 'wie', 'wieso', 'wird', 'wir', 'wo', 'zum',
    'zur',
    // English
    'and', 'are', 'can', 'could', 'does', 'for', 'have', 'how', 'need',
    'not', 'our', 'should', 'that', 'the', 'this', 'want', 'what', 'when',
    'where', 'which', 'who', 'why', 'with', 'you', 'your',
  };

  /// Small, domain-neutral synonym groups. Deliberately simple example
  /// heuristics — a later block can move this into workspace configuration.
  static const List<List<String>> _synonymGroups = [
    ['preis', 'preise', 'kosten', 'kostet', 'price', 'teuer', 'günstig'],
    ['lieferung', 'versand', 'lieferzeit', 'zustellung', 'shipping'],
    ['rückgabe', 'retoure', 'umtausch', 'zurückgeben', 'return'],
    ['öffnungszeiten', 'geschäftszeiten', 'erreichbarkeit'],
    ['kontakt', 'support', 'hilfe', 'hotline', 'erreichen'],
    ['bezahlung', 'zahlung', 'bezahlen', 'rechnung', 'payment'],
    ['garantie', 'gewährleistung', 'warranty'],
    ['konto', 'account', 'anmeldung', 'login', 'registrierung'],
    ['app', 'anwendung', 'applikation'],
    ['gerät', 'geräte', 'device', 'hardware'],
  ];

  /// Normalizes a question into searchable terms with synonym expansion.
  QueryProfile profile(String userQuestion) {
    final terms = <String>[];
    for (final token in _tokenize(userQuestion)) {
      if (token.length < 3) continue;
      if (_stopwords.contains(token)) continue;
      if (!terms.contains(token)) terms.add(token);
    }
    final expansions = <String, Set<String>>{
      for (final term in terms)
        term: {
          term,
          for (final group in _synonymGroups)
            if (group.contains(term)) ...group,
        },
    };
    return QueryProfile(
      original: userQuestion,
      baseTerms: terms,
      expansions: expansions,
    );
  }

  RetrievalResult retrieve(String userQuestion, CompanyWorkspace workspace) {
    final query = profile(userQuestion);
    final searchTerms = query.allTerms;

    final reviewedSimilarLogs = <BotQuestionLog>[];
    final reviewedLogTerms = <Set<String>>[];
    for (final log in workspace.botLogs) {
      if (log.reviewStatus == ReviewStatus.open) continue;
      if (log.answer == null || log.answer!.trim().isEmpty) continue;
      final matched = _matchTerms(log.question, searchTerms);
      if (matched.isEmpty) continue;
      reviewedSimilarLogs.add(log);
      reviewedLogTerms.add(matched);
    }

    final entrySignals = <EntryMatchSignals>[];
    for (final entry in workspace.knowledgeEntries) {
      final titleTerms = _matchTerms(entry.title, searchTerms);
      final contentTerms = _matchTerms(entry.content, searchTerms);
      final keywordTerms = _matchTerms(entry.keywords.join(' '), searchTerms);
      final matched = {...titleTerms, ...contentTerms, ...keywordTerms};
      if (matched.isEmpty) continue;
      entrySignals.add(
        EntryMatchSignals(
          entry: entry,
          titleTerms: titleTerms,
          contentTerms: contentTerms,
          keywordTerms: keywordTerms,
          categoryMatched: query.baseTerms.contains(entry.category.name),
          reviewConfirmed: reviewedLogTerms.any(
            (logTerms) => logTerms.any(matched.contains),
          ),
        ),
      );
    }

    final sourceSignals = <SourceMatchSignals>[];
    for (final source in workspace.sourceMaterials) {
      if (source.status == SourceMaterialStatus.ignored) continue;
      final titleTerms = _matchTerms(source.title, searchTerms);
      final snippetTerms = _matchTerms(source.contentSnippet, searchTerms);
      final notesTerms = _matchTerms(source.notes, searchTerms);
      if (titleTerms.isEmpty && snippetTerms.isEmpty && notesTerms.isEmpty) {
        continue;
      }
      sourceSignals.add(
        SourceMatchSignals(
          source: source,
          titleTerms: titleTerms,
          snippetTerms: snippetTerms,
          notesTerms: notesTerms,
        ),
      );
    }

    return RetrievalResult(
      query: query,
      entrySignals: entrySignals,
      sourceSignals: sourceSignals,
      reviewedSimilarLogs: reviewedSimilarLogs,
      blockedTopicHits: _topicHits(
        workspace.botConfiguration.blockedTopics,
        searchTerms,
      ),
      allowedTopicHits: _topicHits({
        ...workspace.botConfiguration.allowedTopics,
        ...workspace.businessRules.allowedSupportTopics,
      }, searchTerms),
    );
  }

  /// Which of [terms] occur in [text]? Terms of 4+ characters match as
  /// substring (helps with German compounds), shorter ones only as whole
  /// words.
  Set<String> _matchTerms(String? text, Set<String> terms) {
    if (text == null || text.isEmpty) return const {};
    final normalized = _normalize(text);
    final words = normalized.split(' ').toSet();
    return {
      for (final term in terms)
        if (term.length >= 4 ? normalized.contains(term) : words.contains(term))
          term,
    };
  }

  List<String> _topicHits(Iterable<String> topics, Set<String> searchTerms) {
    return [
      for (final topic in topics)
        if (_matchTerms(topic, searchTerms).isNotEmpty) topic,
    ];
  }

  List<String> _tokenize(String text) {
    return _normalize(text).split(' ').where((t) => t.isNotEmpty).toList();
  }

  String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9äöüß]+'), ' ').trim();
  }
}
