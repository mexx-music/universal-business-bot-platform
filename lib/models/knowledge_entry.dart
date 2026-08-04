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

/// Optional destination on the company's own website. These values are
/// editorial metadata only: BusinessBrain never crawls or validates the URL.
enum KnowledgeLinkType {
  productPage,
  prices,
  faq,
  guide,
  download,
  video,
  support,
  contact,
  blog,
  shop,
  form,
  website,
}

extension KnowledgeLinkTypeX on KnowledgeLinkType {
  int get displayPriority => switch (this) {
    KnowledgeLinkType.productPage => 0,
    KnowledgeLinkType.prices => 1,
    KnowledgeLinkType.faq => 2,
    KnowledgeLinkType.guide => 3,
    KnowledgeLinkType.download => 4,
    KnowledgeLinkType.video => 5,
    KnowledgeLinkType.support => 6,
    KnowledgeLinkType.contact => 7,
    KnowledgeLinkType.blog => 8,
    KnowledgeLinkType.shop => 9,
    KnowledgeLinkType.form => 10,
    KnowledgeLinkType.website => 11,
  };

  IconData get icon => switch (this) {
    KnowledgeLinkType.productPage => Icons.inventory_2_outlined,
    KnowledgeLinkType.prices => Icons.sell_outlined,
    KnowledgeLinkType.faq => Icons.quiz_outlined,
    KnowledgeLinkType.guide => Icons.menu_book_outlined,
    KnowledgeLinkType.download => Icons.download_outlined,
    KnowledgeLinkType.video => Icons.play_circle_outline,
    KnowledgeLinkType.support => Icons.support_agent_outlined,
    KnowledgeLinkType.contact => Icons.contact_mail_outlined,
    KnowledgeLinkType.blog => Icons.article_outlined,
    KnowledgeLinkType.shop => Icons.shopping_bag_outlined,
    KnowledgeLinkType.form => Icons.assignment_outlined,
    KnowledgeLinkType.website => Icons.language_outlined,
  };
}

class KnowledgeEntryLink {
  const KnowledgeEntryLink({this.url = '', this.title = '', this.type});

  final String url;
  final String title;
  final KnowledgeLinkType? type;

  bool get canOpen => url.trim().isNotEmpty;

  KnowledgeEntryLink copyWith({
    String? url,
    String? title,
    KnowledgeLinkType? type,
    bool clearType = false,
  }) => KnowledgeEntryLink(
    url: url ?? this.url,
    title: title ?? this.title,
    type: clearType ? null : type ?? this.type,
  );
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

  /// Optional editorial deep-link attached to this exact confirmed entry.
  /// It is shown only when the entry is actually used for a grounded answer.
  final KnowledgeEntryLink? websiteLink;

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
    this.websiteLink,
  });
}
