import 'package:flutter/material.dart';

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
  });
}
