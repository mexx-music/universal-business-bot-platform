import '../../models/knowledge_entry.dart';

/// Generic, local package model for preparing multi-document company knowledge
/// before it enters the existing Knowledge Builder analysis and review flow.
/// It performs no import, analysis, persistence or network access.
class CompanyKnowledgePackage {
  const CompanyKnowledgePackage({
    required this.id,
    required this.titleDe,
    required this.titleEn,
    required this.descriptionDe,
    required this.descriptionEn,
    required this.includedAreasDe,
    required this.includedAreasEn,
    required this.documents,
  });

  final String id;
  final String titleDe;
  final String titleEn;
  final String descriptionDe;
  final String descriptionEn;
  final List<String> includedAreasDe;
  final List<String> includedAreasEn;
  final List<KnowledgePackageDocument> documents;

  String title(String languageCode) => languageCode == 'de' ? titleDe : titleEn;

  String description(String languageCode) =>
      languageCode == 'de' ? descriptionDe : descriptionEn;

  List<String> includedAreas(String languageCode) =>
      languageCode == 'de' ? includedAreasDe : includedAreasEn;

  String editorContent(String languageCode) => documents
      .map((document) => document.content(languageCode).trim())
      .where((content) => content.isNotEmpty)
      .join('\n\n');

  int get timeSensitiveDocumentCount =>
      documents.where((document) => document.freshness.timeSensitive).length;

  int get reviewRequiredDocumentCount => documents
      .where((document) => document.risk.requiresExplicitReview)
      .length;
}

class KnowledgePackageDocument {
  const KnowledgePackageDocument({
    required this.id,
    required this.areaDe,
    required this.areaEn,
    required this.documentTypeDe,
    required this.documentTypeEn,
    required this.contentDe,
    required this.contentEn,
    required this.source,
    this.risk = const KnowledgePackageRisk.standard(),
    this.freshness = const KnowledgePackageFreshness.stable(),
    this.websiteLinkDe,
    this.websiteLinkEn,
  });

  final String id;
  final String areaDe;
  final String areaEn;
  final String documentTypeDe;
  final String documentTypeEn;
  final String contentDe;
  final String contentEn;
  final KnowledgePackageSource source;
  final KnowledgePackageRisk risk;
  final KnowledgePackageFreshness freshness;
  final KnowledgeEntryLink? websiteLinkDe;
  final KnowledgeEntryLink? websiteLinkEn;

  String area(String languageCode) => languageCode == 'de' ? areaDe : areaEn;

  String documentType(String languageCode) =>
      languageCode == 'de' ? documentTypeDe : documentTypeEn;

  String content(String languageCode) =>
      languageCode == 'de' ? contentDe : contentEn;

  KnowledgeEntryLink? websiteLink(String languageCode) => languageCode == 'de'
      ? websiteLinkDe ?? websiteLinkEn
      : websiteLinkEn ?? websiteLinkDe;

  KnowledgePackageDocumentMetadata metadata(String languageCode) =>
      KnowledgePackageDocumentMetadata(
        documentId: id,
        area: area(languageCode),
        documentType: documentType(languageCode),
        sourceName: source.name(languageCode),
        sourceType: source.type.label(languageCode),
        dataStatus: source.dataStatus(languageCode),
        risk: risk,
        freshness: freshness,
        websiteLink: websiteLink(languageCode),
      );
}

enum KnowledgePackageSourceType {
  publicCompanyWebsite,
  confirmedProductDocumentation,
  confirmedSupportDocumentation;

  String label(String languageCode) {
    final de = languageCode == 'de';
    return switch (this) {
      publicCompanyWebsite =>
        de ? 'Öffentliche Unternehmenswebsite' : 'Public company website',
      confirmedProductDocumentation =>
        de
            ? 'Bestätigte Produktdokumentation'
            : 'Confirmed product documentation',
      confirmedSupportDocumentation =>
        de
            ? 'Bestätigte Support-Dokumentation'
            : 'Confirmed support documentation',
    };
  }
}

class KnowledgePackageSource {
  const KnowledgePackageSource({
    required this.id,
    required this.nameDe,
    required this.nameEn,
    required this.type,
    required this.dataStatusDe,
    required this.dataStatusEn,
  });

  final String id;
  final String nameDe;
  final String nameEn;
  final KnowledgePackageSourceType type;
  final String dataStatusDe;
  final String dataStatusEn;

  String name(String languageCode) => languageCode == 'de' ? nameDe : nameEn;

  String dataStatus(String languageCode) =>
      languageCode == 'de' ? dataStatusDe : dataStatusEn;
}

enum KnowledgePackageRiskType {
  standard,
  legalOrProfessionalReview,
  impactRelatedClaim,
  testimonial,
}

class KnowledgePackageRisk {
  const KnowledgePackageRisk.standard()
    : type = KnowledgePackageRiskType.standard;

  const KnowledgePackageRisk.legalOrProfessionalReview()
    : type = KnowledgePackageRiskType.legalOrProfessionalReview;

  const KnowledgePackageRisk.impactRelatedClaim()
    : type = KnowledgePackageRiskType.impactRelatedClaim;

  const KnowledgePackageRisk.testimonial()
    : type = KnowledgePackageRiskType.testimonial;

  final KnowledgePackageRiskType type;

  bool get requiresExplicitReview => type != KnowledgePackageRiskType.standard;
}

class KnowledgePackageFreshness {
  const KnowledgePackageFreshness.stable()
    : timeSensitive = false,
      lastChecked = null,
      reviewRecommended = false;

  const KnowledgePackageFreshness.timeSensitive({required this.lastChecked})
    : timeSensitive = true,
      reviewRecommended = true;

  final bool timeSensitive;
  final DateTime? lastChecked;
  final bool reviewRecommended;
}

/// Small immutable provenance snapshot attached to analyzer drafts. It keeps
/// the package model out of the workspace schema while allowing the existing
/// mapper to preserve a human-readable source in `KnowledgeEntry.source`.
class KnowledgePackageDocumentMetadata {
  const KnowledgePackageDocumentMetadata({
    required this.documentId,
    required this.area,
    required this.documentType,
    required this.sourceName,
    required this.sourceType,
    required this.dataStatus,
    required this.risk,
    required this.freshness,
    this.websiteLink,
  });

  final String documentId;
  final String area;
  final String documentType;
  final String sourceName;
  final String sourceType;
  final String dataStatus;
  final KnowledgePackageRisk risk;
  final KnowledgePackageFreshness freshness;
  final KnowledgeEntryLink? websiteLink;
}
