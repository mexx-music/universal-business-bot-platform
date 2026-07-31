import 'package:flutter/widgets.dart';
import '../models/bot_question_log.dart';
import '../models/knowledge_entry.dart';
import '../models/product_or_service.dart';
import '../research/models/research_enums.dart';
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

/// Locale-aware label for [TimelineCategory].
String timelineCategoryLabel(BuildContext context, TimelineCategory category) {
  final l = AppLocalizations.of(context)!;
  return switch (category) {
    TimelineCategory.founding => l.timelineCategoryFounding,
    TimelineCategory.product => l.timelineCategoryProduct,
    TimelineCategory.marketing => l.timelineCategoryMarketing,
    TimelineCategory.partnership => l.timelineCategoryPartnership,
    TimelineCategory.expansion => l.timelineCategoryExpansion,
    TimelineCategory.legal => l.timelineCategoryLegal,
    TimelineCategory.finance => l.timelineCategoryFinance,
    TimelineCategory.hiring => l.timelineCategoryHiring,
    TimelineCategory.strategy => l.timelineCategoryStrategy,
    TimelineCategory.crisis => l.timelineCategoryCrisis,
    TimelineCategory.milestone => l.timelineCategoryMilestone,
  };
}

/// Locale-aware label for [ResearchDocumentType].
String researchDocumentTypeLabel(
  BuildContext context,
  ResearchDocumentType type,
) {
  final l = AppLocalizations.of(context)!;
  return switch (type) {
    ResearchDocumentType.website => l.researchDocTypeWebsite,
    ResearchDocumentType.news => l.researchDocTypeNews,
    ResearchDocumentType.blog => l.researchDocTypeBlog,
    ResearchDocumentType.socialPost => l.researchDocTypeSocialPost,
    ResearchDocumentType.review => l.researchDocTypeReview,
    ResearchDocumentType.pressRelease => l.researchDocTypePressRelease,
    ResearchDocumentType.forum => l.researchDocTypeForum,
    ResearchDocumentType.video => l.researchDocTypeVideo,
    ResearchDocumentType.financial => l.researchDocTypeFinancial,
    ResearchDocumentType.unknown => l.researchDocTypeUnknown,
  };
}

/// Locale-aware label for [ResearchEvidenceCategory].
String researchEvidenceCategoryLabel(
  BuildContext context,
  ResearchEvidenceCategory category,
) {
  final l = AppLocalizations.of(context)!;
  return switch (category) {
    ResearchEvidenceCategory.product => l.researchEvidenceCategoryProduct,
    ResearchEvidenceCategory.marketing => l.researchEvidenceCategoryMarketing,
    ResearchEvidenceCategory.expansion => l.researchEvidenceCategoryExpansion,
    ResearchEvidenceCategory.hiring => l.researchEvidenceCategoryHiring,
    ResearchEvidenceCategory.finance => l.researchEvidenceCategoryFinance,
    ResearchEvidenceCategory.partnership =>
      l.researchEvidenceCategoryPartnership,
    ResearchEvidenceCategory.reputation => l.researchEvidenceCategoryReputation,
    ResearchEvidenceCategory.strategy => l.researchEvidenceCategoryStrategy,
    ResearchEvidenceCategory.other => l.researchEvidenceCategoryOther,
  };
}
