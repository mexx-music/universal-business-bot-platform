import '../models/knowledge_entry.dart';
import '../runtime/knowledge_answer_context.dart';

/// The business question a user is trying to answer. Detection is deliberately
/// lexical and only influences evidence ordering; it never creates facts.
enum GroundedQuestionType {
  price,
  availability,
  purchase,
  offer,
  productDefinition,
  productFunction,
  usage,
  connection,
  troubleshooting,
  technicalRequirement,
  contact,
  warranty,
  delivery,
  medicalSensitive,
  company,
  general,
}

/// Whether the selected, confirmed evidence answers the core of the question.
enum GroundedEvidenceCoverage {
  fullyAnswerable,
  partiallyAnswerable,
  notAnswerable,
  sensitiveReview,
}

class GroundedQuestionProfile {
  const GroundedQuestionProfile({
    required this.type,
    required this.objectTerms,
    required this.objectLabel,
    required this.priorityTerms,
    required this.relatedTerms,
  });

  final GroundedQuestionType type;
  final List<String> objectTerms;
  final String? objectLabel;
  final Set<String> priorityTerms;
  final Set<String> relatedTerms;

  bool get isSensitive => type == GroundedQuestionType.medicalSensitive;
}

/// Small, domain-neutral classifier for the common business questions handled
/// by BusinessBrain. It is deterministic, offline and side-effect free.
class GroundedQuestionAnalyzer {
  const GroundedQuestionAnalyzer();

  static const _stopwords = <String>{
    'aber',
    'als',
    'auch',
    'auf',
    'aus',
    'bei',
    'bin',
    'bitte',
    'das',
    'dass',
    'dem',
    'den',
    'der',
    'des',
    'die',
    'doch',
    'ein',
    'eine',
    'einem',
    'einen',
    'einer',
    'für',
    'gibt',
    'hab',
    'habe',
    'haben',
    'hat',
    'ich',
    'ihr',
    'ist',
    'kann',
    'können',
    'mache',
    'machen',
    'mein',
    'meine',
    'mich',
    'mir',
    'mit',
    'muss',
    'nach',
    'nicht',
    'noch',
    'oder',
    'sein',
    'sich',
    'sie',
    'sind',
    'soll',
    'sollte',
    'und',
    'uns',
    'vom',
    'von',
    'vor',
    'wann',
    'war',
    'warum',
    'was',
    'welche',
    'welcher',
    'wenn',
    'wer',
    'werden',
    'wie',
    'wieso',
    'wird',
    'wir',
    'wo',
    'tun',
    'zum',
    'zur',
    'and',
    'are',
    'can',
    'could',
    'does',
    'do',
    'for',
    'have',
    'how',
    'is',
    'need',
    'much',
    'not',
    'our',
    'should',
    'that',
    'the',
    'this',
    'to',
    'want',
    'what',
    'when',
    'where',
    'which',
    'who',
    'why',
    'with',
    'you',
    'your',
  };

  GroundedQuestionProfile analyze(String question) {
    final normalized = _normalize(question);
    final type = _detectType(normalized);
    final priorityTerms = _priorityTerms[type] ?? const <String>{};
    final relatedTerms = _relatedTerms[type] ?? const <String>{};
    final excluded = {
      ...priorityTerms,
      ...relatedTerms,
      ..._genericQuestionWords,
    };
    final originalTokens = RegExp(
      r"[A-Za-z0-9ÄÖÜäöüß&'-]+",
    ).allMatches(question).map((match) => match.group(0)!).toList();
    final objectTokens = <String>[];
    for (final token in originalTokens) {
      final clean = _normalize(token);
      if (clean.length < 3 ||
          _stopwords.contains(clean) ||
          _genericActionRoots.any((root) => clean.startsWith(root)) ||
          excluded.any((term) => _matches(clean, term))) {
        continue;
      }
      if (!objectTokens.any((existing) => _normalize(existing) == clean)) {
        objectTokens.add(token);
      }
    }

    return GroundedQuestionProfile(
      type: type,
      objectTerms: [for (final token in objectTokens) _normalize(token)],
      objectLabel: objectTokens.isEmpty ? null : objectTokens.join(' '),
      priorityTerms: priorityTerms,
      relatedTerms: relatedTerms,
    );
  }

  GroundedQuestionType _detectType(String question) {
    bool hasAny(Iterable<String> terms) =>
        terms.any((term) => _contains(question, term));

    if (hasAny(_medicalTriggers)) return GroundedQuestionType.medicalSensitive;
    if (hasAny(_priceTriggers)) return GroundedQuestionType.price;
    if (hasAny(_contactTriggers)) return GroundedQuestionType.contact;
    if (hasAny(_troubleshootingTriggers)) {
      return GroundedQuestionType.troubleshooting;
    }
    if (hasAny(_connectionTriggers)) return GroundedQuestionType.connection;
    if (hasAny(_warrantyTriggers)) return GroundedQuestionType.warranty;
    if (hasAny(_deliveryTriggers)) return GroundedQuestionType.delivery;
    if (hasAny(_technicalTriggers)) {
      return GroundedQuestionType.technicalRequirement;
    }
    if (hasAny(_availabilityTriggers)) {
      return GroundedQuestionType.availability;
    }
    if (hasAny(_purchaseTriggers)) return GroundedQuestionType.purchase;
    if (hasAny(_offerTriggers)) return GroundedQuestionType.offer;
    if (hasAny(_definitionTriggers)) {
      return GroundedQuestionType.productDefinition;
    }
    if (hasAny(_functionTriggers)) return GroundedQuestionType.productFunction;
    if (hasAny(_usageTriggers)) return GroundedQuestionType.usage;
    if (hasAny(_companyTriggers)) return GroundedQuestionType.company;
    return GroundedQuestionType.general;
  }

  static bool _contains(String text, String term) => term.contains(' ')
      ? text.contains(term)
      : text
            .split(' ')
            .any(
              (word) =>
                  word == term ||
                  word.startsWith(term) ||
                  (term.length >= 4 && word.contains(term)),
            );

  static bool _matches(String token, String term) =>
      token == term || token.startsWith(term) || term.startsWith(token);

  static String _normalize(String text) =>
      text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9äöüß]+'), ' ').trim();

  static const _genericQuestionWords = <String>{
    'information',
    'informationen',
    'frage',
    'answer',
    'antwort',
    'tell',
    'sagen',
    'erklären',
    'explain',
    'about',
    'über',
    'gehören',
    'belong',
  };

  static const _genericActionRoots = <String>{
    'funktion',
    'verbind',
    'connect',
    'koppel',
    'pair',
    'start',
    'bedien',
    'benutz',
    'verwend',
    'operate',
    'erreich',
    'reach',
    'kost',
    'bestell',
    'order',
  };

  static const _medicalTriggers = <String>{
    'heilen',
    'heilt',
    'heilung',
    'krankheit',
    'therap',
    'medizin',
    'wirkung',
    'gesundheit',
    'cure disease',
    'heal disease',
    'healing claim',
    'disease',
    'diagnos',
    'therapy',
    'medical',
    'effect',
    'health',
    'symptom',
  };
  static const _priceTriggers = <String>{
    'preis',
    'kost',
    'euro',
    'eur',
    'dollar',
    'chf',
    'price',
    'cost',
    'how much',
  };
  static const _contactTriggers = <String>{
    'kontakt',
    'erreich',
    'telefon',
    'e mail',
    'anschrift',
    'adresse',
    'contact',
    'reach',
    'phone',
    'telephone',
    'email',
    'address',
  };
  static const _troubleshootingTriggers = <String>{
    'fehler',
    'funktioniert nicht',
    'geht nicht',
    'störung',
    'hilfe',
    'abbruch',
    'problem',
    'error',
    'not working',
    'fails',
    'failure',
    'troubleshoot',
    'support',
  };
  static const _connectionTriggers = <String>{
    'verbind',
    'koppl',
    'einricht',
    'pair',
    'connect',
    'bluetooth',
    'setup',
  };
  static const _warrantyTriggers = <String>{
    'garantie',
    'gewährleistung',
    'warranty',
    'guarantee',
  };
  static const _deliveryTriggers = <String>{
    'liefer',
    'versand',
    'zustellung',
    'shipping',
    'delivery',
    'dispatch',
  };
  static const _technicalTriggers = <String>{
    'voraussetzung',
    'kompatib',
    'betriebssystem',
    'version',
    'akku',
    'reichweite',
    'requirement',
    'compatible',
    'operating system',
    'battery',
    'range',
  };
  static const _availabilityTriggers = <String>{
    'verfügbar',
    'lieferbar',
    'vorrätig',
    'bestand',
    'available',
    'availability',
    'in stock',
    'stock',
  };
  static const _purchaseTriggers = <String>{
    'kauf',
    'bestell',
    'shop',
    'zahlung',
    'buy',
    'purchase',
    'order',
    'checkout',
    'payment',
  };
  static const _offerTriggers = <String>{
    'angebot',
    'testzeit',
    'testmonat',
    'kennenlern',
    'probe',
    'trial',
    'offer',
    'test period',
  };
  static const _definitionTriggers = <String>{
    'was ist',
    'wer ist',
    'worum handelt',
    'what is',
    'who is',
    'what are',
  };
  static const _functionTriggers = <String>{
    'funktion',
    'was macht',
    'wozu',
    'kann das',
    'kann die',
    'feature',
    'function',
    'what does',
    'what can',
    'capability',
  };
  static const _usageTriggers = <String>{
    'bedien',
    'benutz',
    'verwend',
    'auswähl',
    'schritt',
    'use',
    'using',
    'operate',
    'start',
    'select',
    'step',
  };
  static const _companyTriggers = <String>{
    'unternehmen',
    'firma',
    'geschäft',
    'company',
    'business',
    'organisation',
  };

  static const Map<GroundedQuestionType, Set<String>> _priorityTerms = {
    GroundedQuestionType.price: {
      'preis',
      'preise',
      'kostet',
      'kosten',
      'euro',
      'eur',
      '€',
      'dollar',
      'usd',
      'chf',
      'franken',
      'price',
      'prices',
      'cost',
      'costs',
      r'$',
      '£',
      'kostenlos',
      'free of charge',
    },
    GroundedQuestionType.availability: {
      'verfügbar',
      'lieferbar',
      'vorrätig',
      'bestand',
      'available',
      'availability',
      'in stock',
      'stock',
    },
    GroundedQuestionType.purchase: {
      'kaufen',
      'kauf',
      'bestellen',
      'bestellung',
      'shop',
      'zahlung',
      'buy',
      'purchase',
      'order',
      'checkout',
      'payment',
    },
    GroundedQuestionType.offer: {
      'angebot',
      'testzeitraum',
      'testmonat',
      'kennenlernangebot',
      'probe',
      'trial',
      'offer',
      'test period',
      '30 tage',
      '30 days',
    },
    GroundedQuestionType.productDefinition: {
      'produktbeschreibung',
      'gerät',
      'produkt',
      'stationär',
      'mobil',
      'product description',
      'device',
      'system',
      'product',
      'stationary',
      'mobile',
    },
    GroundedQuestionType.productFunction: {
      'funktion',
      'funktioniert',
      'steuert',
      'unterstützt',
      'ermöglicht',
      'feature',
      'function',
      'controls',
      'supports',
      'enables',
    },
    GroundedQuestionType.usage: {
      'bedienen',
      'benutzen',
      'verwenden',
      'starten',
      'auswählen',
      'schritt',
      'operate',
      'use',
      'start',
      'select',
      'step',
    },
    GroundedQuestionType.connection: {
      'bluetooth',
      'verbinden',
      'verbindung',
      'koppeln',
      'einrichten',
      'gerät auswählen',
      'bestätigen',
      'reichweite',
      'akkustand',
      'connect',
      'connection',
      'pair',
      'setup',
      'select device',
      'confirm',
      'range',
      'battery level',
    },
    GroundedQuestionType.troubleshooting: {
      'problem',
      'fehler',
      'neustart',
      'akku',
      'reichweite',
      'error',
      'support',
      'restart',
      'firmware',
      'battery',
      'range',
    },
    GroundedQuestionType.technicalRequirement: {
      'voraussetzung',
      'kompatibel',
      'betriebssystem',
      'akku',
      'reichweite',
      'requirement',
      'compatible',
      'operating system',
      'version',
      'battery',
      'range',
    },
    GroundedQuestionType.contact: {
      'kontakt',
      'telefon',
      'e mail',
      'anschrift',
      'adresse',
      'contact',
      'phone',
      'telephone',
      'email',
      'address',
      'support',
    },
    GroundedQuestionType.warranty: {
      'garantie',
      'gewährleistung',
      'warranty',
      'guarantee',
    },
    GroundedQuestionType.delivery: {
      'lieferung',
      'lieferzeit',
      'versand',
      'zustellung',
      'shipping',
      'delivery',
      'dispatch',
    },
    GroundedQuestionType.medicalSensitive: {
      'wirkung',
      'heilung',
      'krankheit',
      'diagnose',
      'therapie',
      'medizinisch',
      'keine heilversprechen',
      'effect',
      'healing',
      'disease',
      'diagnosis',
      'therapy',
      'medical',
      'no healing claims',
    },
    GroundedQuestionType.company: {
      'unternehmen',
      'firma',
      'geschäft',
      'standort',
      'company',
      'business',
      'location',
      'team',
    },
    GroundedQuestionType.general: {},
  };

  static const Map<GroundedQuestionType, Set<String>> _relatedTerms = {
    GroundedQuestionType.price: {
      'angebot',
      'kaufen',
      'kauf',
      'leihpreis',
      'miete',
      'testangebot',
      'offer',
      'buy',
      'purchase',
      'rental',
      'lease',
      'trial',
    },
  };
}

class GroundedEvidenceAssessment {
  const GroundedEvidenceAssessment({
    required this.coverage,
    required this.matches,
    required this.coreMatchIds,
    required this.missingCoreInformation,
    this.stalePriceDate,
  });

  final GroundedEvidenceCoverage coverage;
  final List<ScoredKnowledgeMatch> matches;
  final Set<String> coreMatchIds;
  final bool missingCoreInformation;
  final DateTime? stalePriceDate;

  bool isCoreMatch(ScoredKnowledgeMatch match) =>
      coreMatchIds.contains(match.entry.id);
}

/// Reorders the existing retrieval result around the user's concrete question.
/// It never searches another store and never changes or fabricates entries.
class GroundedEvidencePrioritizer {
  const GroundedEvidencePrioritizer({
    this.freshnessWindow = const Duration(days: 365),
  });

  final Duration freshnessWindow;

  GroundedEvidenceAssessment assess({
    required GroundedQuestionProfile profile,
    required Iterable<ScoredKnowledgeMatch> candidates,
    required DateTime now,
    required int maxSources,
  }) {
    final scored = <_IntentScoredMatch>[
      for (final match in candidates) _score(profile, match),
    ];
    scored.sort((a, b) {
      final byIntent = b.intentScore.compareTo(a.intentScore);
      if (byIntent != 0) return byIntent;
      final byRetrieval = b.match.score.compareTo(a.match.score);
      return byRetrieval != 0
          ? byRetrieval
          : a.match.entry.id.compareTo(b.match.entry.id);
    });

    final relevant = scored
        .where(
          (item) =>
              (profile.objectTerms.isEmpty || item.objectHits > 0) &&
              (item.intentScore > 0 || item.objectHits > 0),
        )
        .toList();
    if (relevant.isEmpty) {
      return const GroundedEvidenceAssessment(
        coverage: GroundedEvidenceCoverage.notAnswerable,
        matches: [],
        coreMatchIds: {},
        missingCoreInformation: true,
      );
    }

    final core = relevant.where((item) => item.isCore).toList();
    final contextual = relevant.where((item) => !item.isCore).toList();
    final selected = <_IntentScoredMatch>[];
    selected.addAll(core.take(maxSources));

    final typeNeedsCore =
        profile.type != GroundedQuestionType.general &&
        profile.type != GroundedQuestionType.productDefinition;
    final priceHasValue =
        profile.type == GroundedQuestionType.price &&
        core.any((item) => _containsConfirmedPrice(item.searchable));
    final priceExplicitlyMissing =
        profile.type == GroundedQuestionType.price &&
        core.any((item) => _containsMissingPrice(item.searchable));
    final objectCovered =
        profile.objectTerms.isEmpty ||
        profile.objectTerms.every(
          (term) => relevant.any((item) => _contains(item.searchable, term)),
        );
    final hasCoreAnswer = profile.type == GroundedQuestionType.price
        ? priceHasValue
        : profile.type == GroundedQuestionType.productDefinition
        ? relevant.any((item) => item.objectHits > 0) && objectCovered
        : (core.isNotEmpty || !typeNeedsCore) && objectCovered;
    final missingCore = !hasCoreAnswer || priceExplicitlyMissing;

    // Context is useful only when the exact answer is absent. This keeps a
    // confirmed price from being buried under generic product descriptions.
    if (missingCore || selected.isEmpty) {
      for (final item in contextual) {
        if (selected.length >= maxSources || selected.length >= 3) break;
        selected.add(item);
      }
    }
    if (selected.isEmpty) selected.addAll(relevant.take(maxSources));

    final sensitive =
        profile.isSensitive ||
        selected.any((item) => item.match.entry.riskLevel != RiskLevel.green);
    final coverage = sensitive
        ? GroundedEvidenceCoverage.sensitiveReview
        : hasCoreAnswer && !priceExplicitlyMissing
        ? GroundedEvidenceCoverage.fullyAnswerable
        : GroundedEvidenceCoverage.partiallyAnswerable;

    DateTime? stalePriceDate;
    if (priceHasValue) {
      final pricedEntries = core
          .where((item) => _containsConfirmedPrice(item.searchable))
          .map((item) => item.match.entry)
          .toList();
      pricedEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final latest = pricedEntries.first.createdAt;
      final age = now.difference(latest);
      if (!age.isNegative && age > freshnessWindow) stalePriceDate = latest;
    }

    return GroundedEvidenceAssessment(
      coverage: coverage,
      matches: [for (final item in selected) item.match],
      coreMatchIds: {for (final item in core) item.match.entry.id},
      missingCoreInformation: missingCore,
      stalePriceDate: stalePriceDate,
    );
  }

  _IntentScoredMatch _score(
    GroundedQuestionProfile profile,
    ScoredKnowledgeMatch match,
  ) {
    final searchable = _normalize(
      '${match.entry.title} ${match.entry.content} '
      '${match.entry.keywords.join(' ')} '
      '${match.entry.detectedTopics.join(' ')}',
    );
    final priorityHits = profile.priorityTerms
        .where((term) => _contains(searchable, _normalize(term)))
        .length;
    final relatedHits = profile.relatedTerms
        .where((term) => _contains(searchable, _normalize(term)))
        .length;
    final objectHits = profile.objectTerms
        .where((term) => _contains(searchable, term))
        .length;
    final definitionCore =
        profile.type == GroundedQuestionType.productDefinition &&
        objectHits > 0;
    final generalCore =
        profile.type == GroundedQuestionType.general && objectHits > 0;
    return _IntentScoredMatch(
      match: match,
      searchable: searchable,
      priorityHits: priorityHits,
      relatedHits: relatedHits,
      objectHits: objectHits,
      isCore: priorityHits > 0 || definitionCore || generalCore,
    );
  }

  static bool _containsConfirmedPrice(String text) {
    if (_containsMissingPrice(text)) return false;
    return RegExp(
          r'(?:\d[\d.,\s]*\s*(?:€|eur|euro|usd|dollar|chf|franken|£)|(?:€|£|\$)\s*\d)',
          caseSensitive: false,
        ).hasMatch(text) ||
        _contains(text, 'kostenlos') ||
        _contains(text, 'free of charge');
  }

  static bool _containsMissingPrice(String text) => <String>{
    'kein bestätigter preis',
    'keine bestätigte preisangabe',
    'preis nicht bestätigt',
    'preis ist nicht bestätigt',
    'preis nicht hinterlegt',
    'preis wird nicht genannt',
    'leihpreis oder eine kaufanrechnung ist nicht bestätigt',
    'no confirmed price',
    'price is not confirmed',
    'price is not stored',
    'price is not stated',
    'rental price or purchase credit is not confirmed',
  }.any((phrase) => _contains(text, phrase));

  static bool _contains(String text, String term) {
    if (term.isEmpty) return false;
    if (term.contains(' ')) return text.contains(term);
    return text
        .split(' ')
        .any(
          (word) =>
              word == term ||
              word.startsWith(term) ||
              (term.length >= 4 && word.contains(term)),
        );
  }

  static String _normalize(String text) =>
      text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9äöüß€£\$]+'), ' ').trim();
}

class _IntentScoredMatch {
  const _IntentScoredMatch({
    required this.match,
    required this.searchable,
    required this.priorityHits,
    required this.relatedHits,
    required this.objectHits,
    required this.isCore,
  });

  final ScoredKnowledgeMatch match;
  final String searchable;
  final int priorityHits;
  final int relatedHits;
  final int objectHits;
  final bool isCore;

  int get intentScore =>
      priorityHits * 100 + relatedHits * 25 + objectHits * 20;
}
