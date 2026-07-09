import 'package:flutter/widgets.dart';
import '../models/bot_question_log.dart';
import '../models/knowledge_entry.dart';
import '../models/product_or_service.dart';
import 'app_localizations.dart';

/// Locale-aware label for [KnowledgeCategory].
/// Use this in all UI contexts instead of `category.displayName`.
String knowledgeCategoryLabel(
  BuildContext context,
  KnowledgeCategory category,
) {
  final l = AppLocalizations.of(context)!;
  return switch (category) {
    KnowledgeCategory.faq => l.categoryFaq,
    KnowledgeCategory.produkt => l.categoryProdukt,
    KnowledgeCategory.prozess => l.categoryProzess,
    KnowledgeCategory.allgemein => l.categoryAllgemein,
  };
}

/// Locale-aware label for [RiskLevel].
/// Use this in all UI contexts instead of `riskLevel.displayName`.
String riskLevelLabel(BuildContext context, RiskLevel riskLevel) {
  final l = AppLocalizations.of(context)!;
  return switch (riskLevel) {
    RiskLevel.green => l.riskGreen,
    RiskLevel.yellow => l.riskYellow,
    RiskLevel.red => l.riskRed,
  };
}

/// Locale-aware label for [ProductType].
/// Use this in all UI contexts instead of `type.displayName`.
String productTypeLabel(BuildContext context, ProductType type) {
  final l = AppLocalizations.of(context)!;
  return switch (type) {
    ProductType.produkt => l.typeProdukt,
    ProductType.dienstleistung => l.typeDienstleistung,
  };
}

String reviewStatusLabel(BuildContext context, ReviewStatus status) {
  final l = AppLocalizations.of(context)!;
  return switch (status) {
    ReviewStatus.open => l.reviewStatusOpen,
    ReviewStatus.reviewed => l.reviewStatusReviewed,
    ReviewStatus.closed => l.reviewStatusClosed,
  };
}

String reviewReasonLabel(BuildContext context, ReviewReason reason) {
  final l = AppLocalizations.of(context)!;
  return switch (reason) {
    ReviewReason.noMatch => l.reviewReasonNoMatch,
    ReviewReason.redFlag => l.reviewReasonRedFlag,
    ReviewReason.yellowRisk => l.reviewReasonYellowRisk,
    ReviewReason.lowConfidence => l.reviewReasonLowConfidence,
  };
}
