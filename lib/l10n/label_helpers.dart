import 'package:flutter/widgets.dart';
import '../models/bot_question_log.dart';
import '../models/knowledge_entry.dart';
import '../models/product_or_service.dart';
import '../knowledge_builder/models/knowledge_import_models.dart';
import '../research/models/research_enums.dart';
import '../roles/models/portal_role.dart';
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

String knowledgeLinkTypeLabel(BuildContext context, KnowledgeLinkType type) {
  final l = AppLocalizations.of(context)!;
  return switch (type) {
    KnowledgeLinkType.productPage => l.knowledgeLinkProduct,
    KnowledgeLinkType.prices => l.knowledgeLinkPrices,
    KnowledgeLinkType.faq => l.knowledgeLinkFaq,
    KnowledgeLinkType.guide => l.knowledgeLinkGuide,
    KnowledgeLinkType.download => l.knowledgeLinkDownload,
    KnowledgeLinkType.video => l.knowledgeLinkVideo,
    KnowledgeLinkType.support => l.knowledgeLinkSupport,
    KnowledgeLinkType.contact => l.knowledgeLinkContact,
    KnowledgeLinkType.blog => l.knowledgeLinkBlog,
    KnowledgeLinkType.shop => l.knowledgeLinkShop,
    KnowledgeLinkType.form => l.knowledgeLinkForm,
    KnowledgeLinkType.website => l.knowledgeLinkWebsite,
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

/// Locale-aware title for a portal [PortalTier].
String portalTierTitle(BuildContext context, PortalTier tier) {
  final l = AppLocalizations.of(context)!;
  return switch (tier) {
    PortalTier.company => l.rolePortalCompanyTitle,
    PortalTier.employee => l.rolePortalEmployeeTitle,
    PortalTier.customer => l.rolePortalCustomerTitle,
  };
}

/// Locale-aware name of a [PortalTier] persona.
String portalTierLabel(BuildContext context, PortalTier tier) {
  final l = AppLocalizations.of(context)!;
  return switch (tier) {
    PortalTier.company => l.roleTierCompany,
    PortalTier.employee => l.roleTierEmployee,
    PortalTier.customer => l.roleTierCustomer,
  };
}

/// Locale-aware name of an [EmployeeRole] department.
String employeeRoleLabel(BuildContext context, EmployeeRole role) {
  final l = AppLocalizations.of(context)!;
  return switch (role) {
    EmployeeRole.support => l.roleDeptSupport,
    EmployeeRole.marketing => l.roleDeptMarketing,
    EmployeeRole.technical => l.roleDeptTechnical,
    EmployeeRole.sales => l.roleDeptSales,
  };
}

/// Locale-aware label for a [PortalSection]. Reuses existing navigation labels
/// where a section maps to an existing area.
String portalSectionLabel(BuildContext context, PortalSection section) {
  final l = AppLocalizations.of(context)!;
  return switch (section) {
    PortalSection.dashboard => l.navDashboard,
    PortalSection.knowledge => l.navKnowledge,
    PortalSection.knowledgeBuilder => l.navKnowledgeBuilder,
    PortalSection.products => l.roleSecProducts,
    PortalSection.aiAssistant => l.navBotTest,
    PortalSection.reviewAnswers => l.navReview,
    PortalSection.community => l.navCommunityRadar,
    PortalSection.analytics => l.navBusinessIntelligence,
    PortalSection.companyEvolution => l.navCompanyEvolution,
    PortalSection.research => l.roleSecResearch,
    PortalSection.competitors => l.roleSecCompetitors,
    PortalSection.marketing => l.navMarketingStrategy,
    PortalSection.sources => l.navSources,
    PortalSection.employees => l.roleSecEmployees,
    PortalSection.roles => l.roleSecRoles,
    PortalSection.aiSettings => l.navBotSettings,
    PortalSection.customerAssistant => l.roleSecCustomerAssistant,
    PortalSection.contact => l.roleSecContact,
  };
}

/// Locale-aware label for a Knowledge Builder [KnowledgeDraftCategory].
String knowledgeDraftCategoryLabel(
  BuildContext context,
  KnowledgeDraftCategory category,
) {
  final l = AppLocalizations.of(context)!;
  return switch (category) {
    KnowledgeDraftCategory.faq => l.kbCatFaq,
    KnowledgeDraftCategory.installation => l.kbCatInstallation,
    KnowledgeDraftCategory.stepByStep => l.kbCatStepByStep,
    KnowledgeDraftCategory.technicalRequirement => l.kbCatTechnicalRequirement,
    KnowledgeDraftCategory.warning => l.kbCatWarning,
    KnowledgeDraftCategory.troubleshooting => l.kbCatTroubleshooting,
    KnowledgeDraftCategory.productFeature => l.kbCatProductFeature,
    KnowledgeDraftCategory.tip => l.kbCatTip,
    KnowledgeDraftCategory.definition => l.kbCatDefinition,
    KnowledgeDraftCategory.contact => l.kbCatContact,
    KnowledgeDraftCategory.general => l.kbCatGeneral,
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
