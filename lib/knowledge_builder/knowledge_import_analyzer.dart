import '../models/knowledge_entry.dart';
import '../models/company_workspace.dart';
import '../knowledge/knowledge_context.dart';
import 'models/knowledge_import_models.dart';

/// Deterministic, offline analyzer that turns a large blob of unstructured
/// company text into a *preview* of structured knowledge drafts.
///
/// It performs no network call and does not touch Gemini, the edge function or
/// grounded retrieval. Crucially it never invents facts: draft content is the
/// user's own sentence verbatim; only titles, FAQ questions and keywords are
/// generated (all explicitly allowed), and existing/duplicate matches are
/// detected — never merged or saved automatically.
class KnowledgeImportAnalyzer {
  const KnowledgeImportAnalyzer({
    this.existingMatchThreshold = 0.34,
    this.duplicateThreshold = 0.6,
    this.minMeaningfulTokens = 2,
    this.contextDetector = const KnowledgeContextDetector(),
  });

  /// Jaccard token overlap at/above which a draft is treated as complementing
  /// an existing entry.
  final double existingMatchThreshold;

  /// Overlap at/above which two drafts in the same batch are near-duplicates.
  final double duplicateThreshold;

  /// Sentences with fewer meaningful tokens are counted as "unclear".
  final int minMeaningfulTokens;
  final KnowledgeContextDetector contextDetector;

  KnowledgeImportAnalysis analyze(
    String rawText, {
    List<KnowledgeEntry> existingEntries = const [],
    CompanyWorkspace? workspace,
  }) {
    final sentences = _splitSentences(rawText);
    if (sentences.isEmpty) return const KnowledgeImportAnalysis.empty();

    final languageCode = _detectLanguage(rawText);
    final dominantArea = contextDetector.detectArea(
      rawText,
      workspace: workspace,
    );
    final documentTopics = contextDetector.detectTopics(
      rawText,
      languageCode: languageCode,
    );

    final existing = [
      for (final e in existingEntries)
        (
          entry: e,
          tokens: _tokenSet('${e.title} ${e.content} ${e.keywords.join(' ')}'),
        ),
    ];

    final drafts = <KnowledgeImportDraft>[];
    final draftTokenSets = <Set<String>>[];
    var unclear = 0;
    var index = 0;

    for (final sentence in sentences) {
      final tokens = _tokenSet(sentence);
      if (tokens.length < minMeaningfulTokens) {
        unclear++;
        continue;
      }

      final category = _classify(sentence);
      final keywords = _keywords(sentence);
      final isFaq = category == KnowledgeDraftCategory.faq;
      final area =
          contextDetector.detectArea(sentence, workspace: workspace) ??
          dominantArea;
      final sentenceTopics = contextDetector.detectTopics(
        sentence,
        languageCode: languageCode,
      );

      // Existing-entry match: best token overlap above the threshold.
      KnowledgeImportMatch? match;
      var bestSim = existingMatchThreshold;
      for (final e in existing) {
        final existingArea =
            e.entry.knowledgeArea ??
            contextDetector.detectArea(
              '${e.entry.title} ${e.entry.content} ${e.entry.keywords.join(' ')}',
              workspace: workspace,
            );
        if (area != null && existingArea != null && area != existingArea) {
          continue;
        }
        final sim = _jaccard(tokens, e.tokens);
        if (sim >= bestSim) {
          bestSim = sim;
          match = KnowledgeImportMatch(
            existingEntryId: e.entry.id,
            existingTitle: e.entry.title,
            existingExcerpt: _excerpt(e.entry.content),
            similarity: sim,
          );
        }
      }

      // Duplicate within this batch: similar to an earlier draft.
      var duplicate = false;
      for (final prior in draftTokenSets) {
        if (_jaccard(tokens, prior) >= duplicateThreshold) {
          duplicate = true;
          break;
        }
      }

      drafts.add(
        KnowledgeImportDraft(
          id: 'draft_${index++}',
          category: category,
          title: _title(
            sentence,
            keywords,
            isFaq: isFaq,
            languageCode: languageCode,
          ),
          content: sentence,
          sourceSentence: sentence,
          question: isFaq ? _question(sentence, languageCode) : null,
          keywords: keywords,
          languageCode: languageCode,
          knowledgeArea: area,
          detectedTopics: sentenceTopics.isEmpty
              ? documentTopics
              : sentenceTopics,
          existingMatch: match,
          isPossibleDuplicate: duplicate,
        ),
      );
      draftTokenSets.add(tokens);
    }

    return KnowledgeImportAnalysis(
      analyzedSentences: sentences.length,
      unclearStatements: unclear,
      drafts: List.unmodifiable(drafts),
      inputLanguageCode: languageCode,
      knowledgeArea: dominantArea,
      detectedTopicLabels: documentTopics,
    );
  }

  // --- Sentence splitting ---------------------------------------------------

  List<String> _splitSentences(String raw) {
    final normalized = raw.replaceAll('\r', '\n');
    final parts = <String>[];
    for (final line in normalized.split('\n')) {
      // Split each line further on sentence terminators, keeping it simple.
      for (final piece in line.split(RegExp(r'(?<=[.!?])\s+'))) {
        final s = piece.trim();
        if (s.isNotEmpty) parts.add(_stripTrailing(s));
      }
    }
    return parts;
  }

  String _stripTrailing(String s) =>
      s.replaceAll(RegExp(r'[.!?]+$'), '').trim();

  // --- Classification (first match wins) ------------------------------------

  KnowledgeDraftCategory _classify(String sentence) {
    final s = sentence.toLowerCase();

    if (_contact(s)) return KnowledgeDraftCategory.contact;
    if (_questionStart(s)) return KnowledgeDraftCategory.faq;
    if (_any(s, _warningWords)) return KnowledgeDraftCategory.warning;
    if (_any(s, _requirementWords)) {
      return KnowledgeDraftCategory.technicalRequirement;
    }
    if (_stepMarker(s)) return KnowledgeDraftCategory.stepByStep;
    if (_any(s, _installWords)) return KnowledgeDraftCategory.installation;
    if (_any(s, _troubleWords)) return KnowledgeDraftCategory.troubleshooting;
    if (_any(s, _faqModals)) return KnowledgeDraftCategory.faq;
    if (_any(s, _featureWords)) return KnowledgeDraftCategory.productFeature;
    if (_any(s, _definitionWords)) return KnowledgeDraftCategory.definition;
    if (_any(s, _tipWords)) return KnowledgeDraftCategory.tip;
    return KnowledgeDraftCategory.general;
  }

  bool _contact(String s) =>
      RegExp(r'\S+@\S+\.\S+').hasMatch(s) ||
      RegExp(r'https?://|www\.').hasMatch(s) ||
      RegExp(r'\+?\d[\d /()-]{6,}\d').hasMatch(s) ||
      s.contains('kontakt') ||
      s.contains('contact') ||
      s.contains('hotline');

  bool _questionStart(String s) => RegExp(
    r'^(wie|was|wo|wann|warum|wieso|wer|welche|welcher|welches|how|what|where|when|why|who|which)\b',
    caseSensitive: false,
  ).hasMatch(s.trim());

  bool _stepMarker(String s) =>
      RegExp(r'^\s*\d+[.)]\s').hasMatch(s) ||
      s.contains('schritt ') ||
      s.startsWith('zuerst') ||
      s.contains('anschließend') ||
      s.contains('als erstes') ||
      s.contains('danach ') ||
      s.startsWith('first') ||
      s.contains('next ') ||
      s.contains('afterwards');

  static const _warningWords = [
    'achtung',
    'warnung',
    'warnhinweis',
    'vorsicht',
    'gefahr',
    'niemals',
    'auf keinen fall',
    'warning',
    'caution',
    'danger',
    'never',
    'do not',
  ];
  static const _requirementWords = [
    'mindestens',
    'voraussetzung',
    'erforderlich',
    'benötigt version',
    ' version ',
    'betriebssystem',
    'arbeitsspeicher',
    'speicherplatz',
    'minimum',
    'requirement',
    'required',
    'requires version',
    'operating system',
    'memory',
    'storage',
  ];
  static const _installWords = [
    'installier',
    'einricht',
    'setup',
    'download',
    'herunterlad',
    'install',
    'set up',
  ];
  static const _troubleWords = [
    'problem',
    'fehler',
    'funktioniert nicht',
    'lässt sich nicht',
    'beheben',
    'lösung',
    'error',
    'does not work',
    'cannot',
    'fix',
    'solution',
  ];
  static const _faqModals = [
    'muss',
    'müssen',
    'kann ',
    'können',
    'darf',
    'dürfen',
    'soll ',
    'sollen',
    'läuft unter',
    'unterstützt',
    'benötigt',
    'braucht',
    'must ',
    'can ',
    'may ',
    'should ',
    'supports',
    'needs',
    'requires',
  ];
  static const _featureWords = [
    'update',
    'firmware',
    'aktualisier',
    'funktion',
    'feature',
    'speichert',
    'synchronisier',
    'ermöglicht',
    'stores',
    'synchronizes',
    'allows',
  ];
  static const _definitionWords = [
    ' ist ein ',
    ' ist eine ',
    'bezeichnet',
    'bedeutet',
    'versteht man',
    ' is a ',
    ' means ',
    ' refers to ',
  ];
  static const _tipWords = [
    'tipp',
    'empfehl',
    'am besten',
    'hinweis:',
    'tip',
    'recommend',
    'best to',
  ];

  bool _any(String s, List<String> words) => words.any(s.contains);

  // --- Title / question generation (allowed) --------------------------------

  String _title(
    String sentence,
    List<String> keywords, {
    required bool isFaq,
    required String? languageCode,
  }) {
    if (isFaq) return _question(sentence, languageCode);
    if (keywords.isNotEmpty) {
      return keywords.take(2).map(_capitalize).join(' ');
    }
    final words = sentence.split(RegExp(r'\s+')).take(5).join(' ');
    return _capitalize(words);
  }

  /// Turns a statement into a question using only grammar from the detected
  /// input language. Ambiguous text is preserved and merely gets a question
  /// mark; there is no hard-coded default language.
  String _question(String sentence, String? languageCode) {
    final s = _stripTrailing(sentence).trim();
    if (languageCode == 'en') return _englishQuestion(s);
    if (languageCode != 'de') return '${_capitalize(s)}?';
    final modal = RegExp(
      r'^(.*?)\s+(muss|müssen|kann|können|darf|dürfen|soll|sollen)\s+(.*)$',
      caseSensitive: false,
    ).firstMatch(s);
    if (modal != null) {
      final subject = modal.group(1)!.trim();
      final verb = _capitalize(modal.group(2)!.trim());
      final rest = modal.group(3)!.trim();
      return '$verb ${_lowercaseLeadingArticle(subject, 'de')} $rest?';
    }
    final laeuft = RegExp(
      r'^(.*?)\s+läuft\s+(.*)$',
      caseSensitive: false,
    ).firstMatch(s);
    if (laeuft != null) {
      return 'Läuft ${laeuft.group(1)!.trim()} ${laeuft.group(2)!.trim()}?';
    }
    final verb = RegExp(
      r'^(.*?)\s+(unterstützt|benötigt|braucht)\s+(.*)$',
      caseSensitive: false,
    ).firstMatch(s);
    if (verb != null) {
      return '${_capitalize(verb.group(2)!.trim())} ${verb.group(1)!.trim()} '
          '${verb.group(3)!.trim()}?';
    }
    return '${_capitalize(s)}?';
  }

  String _englishQuestion(String sentence) {
    final modal = RegExp(
      r'^(.*?)\s+(must|can|may|should)\s+(.*)$',
      caseSensitive: false,
    ).firstMatch(sentence);
    if (modal != null) {
      return '${_capitalize(modal.group(2)!.trim())} '
          '${_lowercaseLeadingArticle(modal.group(1)!.trim(), 'en')} '
          '${modal.group(3)!.trim()}?';
    }
    final verb = RegExp(
      r'^(.*?)\s+(supports|needs|requires)\s+(.*)$',
      caseSensitive: false,
    ).firstMatch(sentence);
    if (verb != null) {
      final baseVerb = switch (verb.group(2)!.toLowerCase()) {
        'supports' => 'support',
        'needs' => 'need',
        _ => 'require',
      };
      return 'Does ${verb.group(1)!.trim()} $baseVerb '
          '${verb.group(3)!.trim()}?';
    }
    return '${_capitalize(sentence)}?';
  }

  String? _detectLanguage(String text) {
    final tokens = _tokens(text).toList();
    var de = 0;
    var en = 0;
    for (final token in tokens) {
      if (_germanLanguageSignals.contains(token)) de++;
      if (_englishLanguageSignals.contains(token)) en++;
      if (RegExp(r'[äöüß]').hasMatch(token)) de += 2;
    }
    if (de > en) return 'de';
    if (en > de) return 'en';
    return null;
  }

  // --- Keywords -------------------------------------------------------------

  List<String> _keywords(String sentence) {
    final seen = <String>{};
    final out = <String>[];
    for (final token in _tokens(sentence)) {
      if (token.length < 4 || _stopwords.contains(token)) continue;
      if (seen.add(token)) out.add(token);
      if (out.length >= 6) break;
    }
    return out;
  }

  // --- Tokenisation & similarity -------------------------------------------

  Iterable<String> _tokens(String s) => s
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9äöüß]+'))
      .where((t) => t.isNotEmpty);

  Set<String> _tokenSet(String s) => {
    for (final t in _tokens(s))
      if (t.length >= 4 && !_stopwords.contains(t)) t,
  };

  double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final inter = a.intersection(b).length;
    final union = a.union(b).length;
    return union == 0 ? 0 : inter / union;
  }

  String _excerpt(String content, {int max = 160}) {
    final n = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    return n.length <= max ? n : '${n.substring(0, max).trimRight()}…';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _lowercaseLeadingArticle(String text, String languageCode) {
    final articles = languageCode == 'de'
        ? const {'Der', 'Die', 'Das', 'Ein', 'Eine'}
        : const {'The', 'A', 'An'};
    final words = text.split(' ');
    if (words.isNotEmpty && articles.contains(words.first)) {
      words[0] = words.first.toLowerCase();
    }
    return words.join(' ');
  }

  static const _germanLanguageSignals = {
    'der',
    'die',
    'das',
    'den',
    'dem',
    'ein',
    'eine',
    'einen',
    'und',
    'oder',
    'ist',
    'sind',
    'muss',
    'müssen',
    'kann',
    'können',
    'wird',
    'werden',
    'für',
    'mit',
    'nicht',
    'benötigt',
    'unterstützt',
    'gerät',
    'verbindung',
  };

  static const _englishLanguageSignals = {
    'the',
    'a',
    'an',
    'and',
    'or',
    'is',
    'are',
    'must',
    'can',
    'will',
    'for',
    'with',
    'not',
    'needs',
    'requires',
    'supports',
    'device',
    'connection',
  };

  static const _stopwords = {
    'oder',
    'und',
    'aber',
    'auch',
    'eine',
    'einen',
    'einem',
    'eines',
    'der',
    'die',
    'das',
    'dem',
    'den',
    'des',
    'ein',
    'ist',
    'sind',
    'wird',
    'werden',
    'kann',
    'muss',
    'soll',
    'für',
    'mit',
    'von',
    'vor',
    'aus',
    'auf',
    'bei',
    'nach',
    'über',
    'unter',
    'sowie',
    'dass',
    'wenn',
    'nicht',
    'noch',
    'nur',
    'sich',
    'dies',
    'diese',
    'dieser',
    'sein',
    'seine',
    'the',
    'a',
    'an',
    'and',
    'or',
    'is',
    'are',
    'for',
    'with',
    'this',
    'that',
    'must',
    'can',
    'should',
    'will',
    'have',
    'from',
  };
}
