import '../models/knowledge_entry.dart';

/// Resolves the language of a grounded-answer question independently from the
/// current UI locale and keeps knowingly different-language documents out of
/// the evidence sent to the model.
///
/// BusinessBrain currently supports German and English. Ambiguous product
/// names such as "CureBase" deliberately fall back to the UI language. Legacy
/// entries without language metadata are inspected deterministically; truly
/// ambiguous entries remain usable because they are not known to be written
/// in another language.
class GroundedLanguageResolver {
  const GroundedLanguageResolver();

  String resolveQuestionLanguage(
    String question, {
    required String fallbackLanguage,
  }) {
    return detect(question) ?? normalize(fallbackLanguage) ?? 'en';
  }

  bool entryMatches(KnowledgeEntry entry, String questionLanguage) {
    final target = normalize(questionLanguage);
    if (target == null) return true;

    final declared = normalize(entry.languageCode);
    if (declared != null) return declared == target;

    final detected = detect('${entry.title} ${entry.content}');
    return detected == null || detected == target;
  }

  String? normalize(String? languageCode) {
    final normalized = languageCode?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    if (normalized.startsWith('de')) return 'de';
    if (normalized.startsWith('en')) return 'en';
    return null;
  }

  String? detect(String text) {
    var german = 0;
    var english = 0;
    for (final token in _tokens(text)) {
      if (_germanSignals.contains(token)) german++;
      if (_englishSignals.contains(token)) english++;
      if (RegExp(r'[äöüß]').hasMatch(token)) german += 2;
    }
    if (german > english) return 'de';
    if (english > german) return 'en';
    return null;
  }

  Iterable<String> _tokens(String text) => text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9äöüß]+'))
      .where((token) => token.isNotEmpty);

  static const _germanSignals = {
    'der',
    'die',
    'das',
    'den',
    'dem',
    'des',
    'ein',
    'eine',
    'einen',
    'einem',
    'einer',
    'und',
    'oder',
    'ist',
    'sind',
    'war',
    'wird',
    'werden',
    'wie',
    'was',
    'warum',
    'wo',
    'wann',
    'welche',
    'welcher',
    'welches',
    'funktioniert',
    'muss',
    'müssen',
    'kann',
    'können',
    'für',
    'mit',
    'aus',
    'über',
    'nicht',
    'bitte',
    'benötigt',
    'unterstützt',
    'gerät',
    'verbindung',
    'wissen',
    'antwort',
    'wir',
  };

  static const _englishSignals = {
    'the',
    'a',
    'an',
    'and',
    'or',
    'is',
    'are',
    'was',
    'will',
    'how',
    'what',
    'why',
    'where',
    'when',
    'which',
    'does',
    'work',
    'works',
    'must',
    'can',
    'for',
    'with',
    'from',
    'about',
    'not',
    'please',
    'needs',
    'requires',
    'supports',
    'device',
    'connection',
    'knowledge',
    'answer',
    'we',
  };
}
