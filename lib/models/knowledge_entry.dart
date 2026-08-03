import 'package:flutter/material.dart';

abstract final class KnowledgeEntrySources {
  /// Stable source marker for entries explicitly confirmed in Knowledge
  /// Builder. It is persisted in the already-existing `source` field.
  static const knowledgeBuilder = 'Knowledge Builder';

  static const _separator = ' · ';

  static String knowledgeBuilderWithOrigin(String origin) {
    final clean = origin.trim();
    return clean.isEmpty
        ? knowledgeBuilder
        : '$knowledgeBuilder$_separator$clean';
  }

  static bool isKnowledgeBuilder(String source) =>
      source == knowledgeBuilder ||
      source.startsWith('$knowledgeBuilder$_separator');
}

enum RiskLevel { green, yellow, red }

extension RiskLevelX on RiskLevel {
  String get displayName => switch (this) {
    RiskLevel.green => 'Sicher',
    RiskLevel.yellow => 'Wellness',
    RiskLevel.red => 'Gesperrt',
  };

  Color get color => switch (this) {
    RiskLevel.green => Colors.green,
    RiskLevel.yellow => Colors.orange,
    RiskLevel.red => Colors.red,
  };

  IconData get icon => switch (this) {
    RiskLevel.green => Icons.check_circle_outline,
    RiskLevel.yellow => Icons.info_outline,
    RiskLevel.red => Icons.block_outlined,
  };
}

enum KnowledgeCategory { faq, produkt, prozess, allgemein }

extension KnowledgeCategoryX on KnowledgeCategory {
  String get displayName => switch (this) {
    KnowledgeCategory.faq => 'FAQ',
    KnowledgeCategory.produkt => 'Produkt',
    KnowledgeCategory.prozess => 'Prozess',
    KnowledgeCategory.allgemein => 'Allgemein',
  };

  Color get color => switch (this) {
    KnowledgeCategory.faq => Colors.blue,
    KnowledgeCategory.produkt => Colors.green,
    KnowledgeCategory.prozess => Colors.orange,
    KnowledgeCategory.allgemein => Colors.grey,
  };

  IconData get icon => switch (this) {
    KnowledgeCategory.faq => Icons.help_outline,
    KnowledgeCategory.produkt => Icons.inventory_2_outlined,
    KnowledgeCategory.prozess => Icons.account_tree_outlined,
    KnowledgeCategory.allgemein => Icons.info_outline,
  };
}

class KnowledgeEntry {
  final String id;
  final String title;
  final String content;
  final KnowledgeCategory category;
  final RiskLevel riskLevel;
  final List<String> keywords;
  final String source;
  final DateTime createdAt;
  // ISO 639-1 code ('de', 'en'). Null = inherits app locale.
  final String? languageCode;

  /// Stable content scope used to prefer the right company/product context.
  /// This is metadata only and does not imply access restrictions.
  final String? knowledgeArea;

  /// Topics detected while structuring the source text.
  final List<String> detectedTopics;

  KnowledgeEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.riskLevel,
    required this.keywords,
    required this.source,
    required this.createdAt,
    this.languageCode,
    this.knowledgeArea,
    this.detectedTopics = const [],
  });
}
