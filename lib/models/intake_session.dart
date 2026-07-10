enum IntakeStatus { draft, inProgress, completed }

class IntakeBasics {
  final String companyName;
  final String shortDescription;
  final String industry;
  final String country;
  final String primaryLanguage;
  final String website;
  final String supportEmail;
  final String supportPhone;
  final bool? hasWebsite;

  const IntakeBasics({
    this.companyName = '',
    this.shortDescription = '',
    this.industry = '',
    this.country = '',
    this.primaryLanguage = '',
    this.website = '',
    this.supportEmail = '',
    this.supportPhone = '',
    this.hasWebsite,
  });

  IntakeBasics copyWith({
    String? companyName,
    String? shortDescription,
    String? industry,
    String? country,
    String? primaryLanguage,
    String? website,
    String? supportEmail,
    String? supportPhone,
    bool? hasWebsite,
  }) {
    return IntakeBasics(
      companyName: companyName ?? this.companyName,
      shortDescription: shortDescription ?? this.shortDescription,
      industry: industry ?? this.industry,
      country: country ?? this.country,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      website: website ?? this.website,
      supportEmail: supportEmail ?? this.supportEmail,
      supportPhone: supportPhone ?? this.supportPhone,
      hasWebsite: hasWebsite ?? this.hasWebsite,
    );
  }
}

class IntakeProducts {
  final String importantProducts;
  final String mainProduct;
  final String explanationNeeded;
  final String priorityProducts;

  const IntakeProducts({
    this.importantProducts = '',
    this.mainProduct = '',
    this.explanationNeeded = '',
    this.priorityProducts = '',
  });

  IntakeProducts copyWith({
    String? importantProducts,
    String? mainProduct,
    String? explanationNeeded,
    String? priorityProducts,
  }) {
    return IntakeProducts(
      importantProducts: importantProducts ?? this.importantProducts,
      mainProduct: mainProduct ?? this.mainProduct,
      explanationNeeded: explanationNeeded ?? this.explanationNeeded,
      priorityProducts: priorityProducts ?? this.priorityProducts,
    );
  }
}

class IntakeTargetGroups {
  final String targetGroup;
  final String marketType;
  final String problemSolved;
  final String customerBenefit;
  final String differentiation;

  const IntakeTargetGroups({
    this.targetGroup = '',
    this.marketType = '',
    this.problemSolved = '',
    this.customerBenefit = '',
    this.differentiation = '',
  });

  IntakeTargetGroups copyWith({
    String? targetGroup,
    String? marketType,
    String? problemSolved,
    String? customerBenefit,
    String? differentiation,
  }) {
    return IntakeTargetGroups(
      targetGroup: targetGroup ?? this.targetGroup,
      marketType: marketType ?? this.marketType,
      problemSolved: problemSolved ?? this.problemSolved,
      customerBenefit: customerBenefit ?? this.customerBenefit,
      differentiation: differentiation ?? this.differentiation,
    );
  }
}

class IntakeWebsiteAndSupport {
  final String websiteUrl;
  final bool? hasShop;
  final String shopUrl;
  final bool? hasFaqArea;
  final String faqUrl;
  final String websiteMaintainer;
  final bool? canEditWebsiteQuickly;
  final String websitePlanned;
  final String importantPages;
  final String frequentQuestions;
  final bool? hasSupportQuestions;
  final String preSalesQuestions;
  final String afterSalesQuestions;
  final String technicalProblems;
  final String complaintsOrMisunderstandings;
  final String supportOwner;
  final String standardizableQuestions;
  final String supportProblems;
  final String sensitiveTopics;
  final bool? hasSensitiveTopics;

  const IntakeWebsiteAndSupport({
    this.websiteUrl = '',
    this.hasShop,
    this.shopUrl = '',
    this.hasFaqArea,
    this.faqUrl = '',
    this.websiteMaintainer = '',
    this.canEditWebsiteQuickly,
    this.websitePlanned = '',
    this.importantPages = '',
    this.frequentQuestions = '',
    this.hasSupportQuestions,
    this.preSalesQuestions = '',
    this.afterSalesQuestions = '',
    this.technicalProblems = '',
    this.complaintsOrMisunderstandings = '',
    this.supportOwner = '',
    this.standardizableQuestions = '',
    this.supportProblems = '',
    this.sensitiveTopics = '',
    this.hasSensitiveTopics,
  });

  IntakeWebsiteAndSupport copyWith({
    String? websiteUrl,
    bool? hasShop,
    String? shopUrl,
    bool? hasFaqArea,
    String? faqUrl,
    String? websiteMaintainer,
    bool? canEditWebsiteQuickly,
    String? websitePlanned,
    String? importantPages,
    String? frequentQuestions,
    bool? hasSupportQuestions,
    String? preSalesQuestions,
    String? afterSalesQuestions,
    String? technicalProblems,
    String? complaintsOrMisunderstandings,
    String? supportOwner,
    String? standardizableQuestions,
    String? supportProblems,
    String? sensitiveTopics,
    bool? hasSensitiveTopics,
  }) {
    return IntakeWebsiteAndSupport(
      websiteUrl: websiteUrl ?? this.websiteUrl,
      hasShop: hasShop ?? this.hasShop,
      shopUrl: shopUrl ?? this.shopUrl,
      hasFaqArea: hasFaqArea ?? this.hasFaqArea,
      faqUrl: faqUrl ?? this.faqUrl,
      websiteMaintainer: websiteMaintainer ?? this.websiteMaintainer,
      canEditWebsiteQuickly:
          canEditWebsiteQuickly ?? this.canEditWebsiteQuickly,
      websitePlanned: websitePlanned ?? this.websitePlanned,
      importantPages: importantPages ?? this.importantPages,
      frequentQuestions: frequentQuestions ?? this.frequentQuestions,
      hasSupportQuestions: hasSupportQuestions ?? this.hasSupportQuestions,
      preSalesQuestions: preSalesQuestions ?? this.preSalesQuestions,
      afterSalesQuestions: afterSalesQuestions ?? this.afterSalesQuestions,
      technicalProblems: technicalProblems ?? this.technicalProblems,
      complaintsOrMisunderstandings:
          complaintsOrMisunderstandings ?? this.complaintsOrMisunderstandings,
      supportOwner: supportOwner ?? this.supportOwner,
      standardizableQuestions:
          standardizableQuestions ?? this.standardizableQuestions,
      supportProblems: supportProblems ?? this.supportProblems,
      sensitiveTopics: sensitiveTopics ?? this.sensitiveTopics,
      hasSensitiveTopics: hasSensitiveTopics ?? this.hasSensitiveTopics,
    );
  }
}

class IntakeSourcesAndReviews {
  final String existingSources;
  final bool? hasMaterials;
  final String materialDetails;
  final String materialLocations;
  final String materialFreshness;
  final String importantMaterials;
  final bool? materialsUsableForKnowledgeBase;
  final String reviews;
  final String reviewPlatforms;
  final String reviewCountEstimate;
  final String reviewLinksOrFiles;
  final String reviewTypes;
  final bool? reviewsPubliclyUsable;
  final bool? reviewsEmbeddedOnWebsite;
  final String collectReviewsPlanned;
  final String socialMentions;
  final String trustMaterial;
  final bool? hasReviews;
  final bool? hasSocialMentions;
  final bool? hasTrustMaterial;

  const IntakeSourcesAndReviews({
    this.existingSources = '',
    this.hasMaterials,
    this.materialDetails = '',
    this.materialLocations = '',
    this.materialFreshness = '',
    this.importantMaterials = '',
    this.materialsUsableForKnowledgeBase,
    this.reviews = '',
    this.reviewPlatforms = '',
    this.reviewCountEstimate = '',
    this.reviewLinksOrFiles = '',
    this.reviewTypes = '',
    this.reviewsPubliclyUsable,
    this.reviewsEmbeddedOnWebsite,
    this.collectReviewsPlanned = '',
    this.socialMentions = '',
    this.trustMaterial = '',
    this.hasReviews,
    this.hasSocialMentions,
    this.hasTrustMaterial,
  });

  IntakeSourcesAndReviews copyWith({
    String? existingSources,
    bool? hasMaterials,
    String? materialDetails,
    String? materialLocations,
    String? materialFreshness,
    String? importantMaterials,
    bool? materialsUsableForKnowledgeBase,
    String? reviews,
    String? reviewPlatforms,
    String? reviewCountEstimate,
    String? reviewLinksOrFiles,
    String? reviewTypes,
    bool? reviewsPubliclyUsable,
    bool? reviewsEmbeddedOnWebsite,
    String? collectReviewsPlanned,
    String? socialMentions,
    String? trustMaterial,
    bool? hasReviews,
    bool? hasSocialMentions,
    bool? hasTrustMaterial,
  }) {
    return IntakeSourcesAndReviews(
      existingSources: existingSources ?? this.existingSources,
      hasMaterials: hasMaterials ?? this.hasMaterials,
      materialDetails: materialDetails ?? this.materialDetails,
      materialLocations: materialLocations ?? this.materialLocations,
      materialFreshness: materialFreshness ?? this.materialFreshness,
      importantMaterials: importantMaterials ?? this.importantMaterials,
      materialsUsableForKnowledgeBase:
          materialsUsableForKnowledgeBase ??
          this.materialsUsableForKnowledgeBase,
      reviews: reviews ?? this.reviews,
      reviewPlatforms: reviewPlatforms ?? this.reviewPlatforms,
      reviewCountEstimate: reviewCountEstimate ?? this.reviewCountEstimate,
      reviewLinksOrFiles: reviewLinksOrFiles ?? this.reviewLinksOrFiles,
      reviewTypes: reviewTypes ?? this.reviewTypes,
      reviewsPubliclyUsable:
          reviewsPubliclyUsable ?? this.reviewsPubliclyUsable,
      reviewsEmbeddedOnWebsite:
          reviewsEmbeddedOnWebsite ?? this.reviewsEmbeddedOnWebsite,
      collectReviewsPlanned:
          collectReviewsPlanned ?? this.collectReviewsPlanned,
      socialMentions: socialMentions ?? this.socialMentions,
      trustMaterial: trustMaterial ?? this.trustMaterial,
      hasReviews: hasReviews ?? this.hasReviews,
      hasSocialMentions: hasSocialMentions ?? this.hasSocialMentions,
      hasTrustMaterial: hasTrustMaterial ?? this.hasTrustMaterial,
    );
  }
}

class IntakeMarketingAndChannels {
  final bool? hasSocialChannels;
  final String socialPlatforms;
  final String socialProfileLinks;
  final String activeChannels;
  final String inactiveChannels;
  final String postingFrequency;
  final String workingChannels;
  final String futureSocialPlatforms;
  final bool? hasRunAds;
  final String advertisingChannels;
  final String approximateBudget;
  final String successfulMeasures;
  final String unsuccessfulMeasures;
  final String availableMetrics;
  final String adAccountAccess;
  final String futureAdChannels;
  final String channels;
  final String campaigns;
  final String worked;
  final String notWorked;
  final String reachProblems;

  const IntakeMarketingAndChannels({
    this.hasSocialChannels,
    this.socialPlatforms = '',
    this.socialProfileLinks = '',
    this.activeChannels = '',
    this.inactiveChannels = '',
    this.postingFrequency = '',
    this.workingChannels = '',
    this.futureSocialPlatforms = '',
    this.hasRunAds,
    this.advertisingChannels = '',
    this.approximateBudget = '',
    this.successfulMeasures = '',
    this.unsuccessfulMeasures = '',
    this.availableMetrics = '',
    this.adAccountAccess = '',
    this.futureAdChannels = '',
    this.channels = '',
    this.campaigns = '',
    this.worked = '',
    this.notWorked = '',
    this.reachProblems = '',
  });

  IntakeMarketingAndChannels copyWith({
    bool? hasSocialChannels,
    String? socialPlatforms,
    String? socialProfileLinks,
    String? activeChannels,
    String? inactiveChannels,
    String? postingFrequency,
    String? workingChannels,
    String? futureSocialPlatforms,
    bool? hasRunAds,
    String? advertisingChannels,
    String? approximateBudget,
    String? successfulMeasures,
    String? unsuccessfulMeasures,
    String? availableMetrics,
    String? adAccountAccess,
    String? futureAdChannels,
    String? channels,
    String? campaigns,
    String? worked,
    String? notWorked,
    String? reachProblems,
  }) {
    return IntakeMarketingAndChannels(
      hasSocialChannels: hasSocialChannels ?? this.hasSocialChannels,
      socialPlatforms: socialPlatforms ?? this.socialPlatforms,
      socialProfileLinks: socialProfileLinks ?? this.socialProfileLinks,
      activeChannels: activeChannels ?? this.activeChannels,
      inactiveChannels: inactiveChannels ?? this.inactiveChannels,
      postingFrequency: postingFrequency ?? this.postingFrequency,
      workingChannels: workingChannels ?? this.workingChannels,
      futureSocialPlatforms:
          futureSocialPlatforms ?? this.futureSocialPlatforms,
      hasRunAds: hasRunAds ?? this.hasRunAds,
      advertisingChannels: advertisingChannels ?? this.advertisingChannels,
      approximateBudget: approximateBudget ?? this.approximateBudget,
      successfulMeasures: successfulMeasures ?? this.successfulMeasures,
      unsuccessfulMeasures: unsuccessfulMeasures ?? this.unsuccessfulMeasures,
      availableMetrics: availableMetrics ?? this.availableMetrics,
      adAccountAccess: adAccountAccess ?? this.adAccountAccess,
      futureAdChannels: futureAdChannels ?? this.futureAdChannels,
      channels: channels ?? this.channels,
      campaigns: campaigns ?? this.campaigns,
      worked: worked ?? this.worked,
      notWorked: notWorked ?? this.notWorked,
      reachProblems: reachProblems ?? this.reachProblems,
    );
  }
}

class IntakeGoalsAndRisks {
  final bool? hasSensitiveTopics;
  final String sensitiveTopics;
  final String companyGoals;
  final String shortTermPriorities;
  final String prohibitedStatements;
  final String forbiddenClaims;
  final String botRestrictedTopics;
  final String alwaysEscalateTopics;
  final String legalRestrictions;

  const IntakeGoalsAndRisks({
    this.hasSensitiveTopics,
    this.sensitiveTopics = '',
    this.companyGoals = '',
    this.shortTermPriorities = '',
    this.prohibitedStatements = '',
    this.forbiddenClaims = '',
    this.botRestrictedTopics = '',
    this.alwaysEscalateTopics = '',
    this.legalRestrictions = '',
  });

  IntakeGoalsAndRisks copyWith({
    bool? hasSensitiveTopics,
    String? sensitiveTopics,
    String? companyGoals,
    String? shortTermPriorities,
    String? prohibitedStatements,
    String? forbiddenClaims,
    String? botRestrictedTopics,
    String? alwaysEscalateTopics,
    String? legalRestrictions,
  }) {
    return IntakeGoalsAndRisks(
      hasSensitiveTopics: hasSensitiveTopics ?? this.hasSensitiveTopics,
      sensitiveTopics: sensitiveTopics ?? this.sensitiveTopics,
      companyGoals: companyGoals ?? this.companyGoals,
      shortTermPriorities: shortTermPriorities ?? this.shortTermPriorities,
      prohibitedStatements: prohibitedStatements ?? this.prohibitedStatements,
      forbiddenClaims: forbiddenClaims ?? this.forbiddenClaims,
      botRestrictedTopics: botRestrictedTopics ?? this.botRestrictedTopics,
      alwaysEscalateTopics: alwaysEscalateTopics ?? this.alwaysEscalateTopics,
      legalRestrictions: legalRestrictions ?? this.legalRestrictions,
    );
  }
}

class IntakeSession {
  final String id;
  final String companyId;
  final IntakeStatus status;
  final int currentStepIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? importedAt;
  final DateTime? chatStartedAt;
  final DateTime? chatUpdatedAt;
  final DateTime? chatCompletedAt;
  final int chatCurrentQuestionIndex;
  final List<String> skippedQuestionKeys;
  final List<String> deferredQuestionKeys;
  final IntakeBasics basics;
  final IntakeProducts products;
  final IntakeTargetGroups targetGroups;
  final IntakeWebsiteAndSupport websiteAndSupport;
  final IntakeSourcesAndReviews sourcesAndReviews;
  final IntakeMarketingAndChannels marketingAndChannels;
  final IntakeGoalsAndRisks goalsAndRisks;

  const IntakeSession({
    required this.id,
    required this.companyId,
    required this.status,
    required this.currentStepIndex,
    required this.createdAt,
    required this.updatedAt,
    this.importedAt,
    this.chatStartedAt,
    this.chatUpdatedAt,
    this.chatCompletedAt,
    this.chatCurrentQuestionIndex = 0,
    this.skippedQuestionKeys = const [],
    this.deferredQuestionKeys = const [],
    this.basics = const IntakeBasics(),
    this.products = const IntakeProducts(),
    this.targetGroups = const IntakeTargetGroups(),
    this.websiteAndSupport = const IntakeWebsiteAndSupport(),
    this.sourcesAndReviews = const IntakeSourcesAndReviews(),
    this.marketingAndChannels = const IntakeMarketingAndChannels(),
    this.goalsAndRisks = const IntakeGoalsAndRisks(),
  });

  factory IntakeSession.empty({
    required String companyId,
    IntakeBasics basics = const IntakeBasics(),
  }) {
    final now = DateTime.now();
    return IntakeSession(
      id: 'intake_${now.microsecondsSinceEpoch}',
      companyId: companyId,
      status: IntakeStatus.draft,
      currentStepIndex: 0,
      createdAt: now,
      updatedAt: now,
      basics: basics,
    );
  }

  IntakeSession copyWith({
    IntakeStatus? status,
    int? currentStepIndex,
    DateTime? updatedAt,
    DateTime? importedAt,
    DateTime? chatStartedAt,
    DateTime? chatUpdatedAt,
    DateTime? chatCompletedAt,
    int? chatCurrentQuestionIndex,
    List<String>? skippedQuestionKeys,
    List<String>? deferredQuestionKeys,
    IntakeBasics? basics,
    IntakeProducts? products,
    IntakeTargetGroups? targetGroups,
    IntakeWebsiteAndSupport? websiteAndSupport,
    IntakeSourcesAndReviews? sourcesAndReviews,
    IntakeMarketingAndChannels? marketingAndChannels,
    IntakeGoalsAndRisks? goalsAndRisks,
  }) {
    return IntakeSession(
      id: id,
      companyId: companyId,
      status: status ?? this.status,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      importedAt: importedAt ?? this.importedAt,
      chatStartedAt: chatStartedAt ?? this.chatStartedAt,
      chatUpdatedAt: chatUpdatedAt ?? this.chatUpdatedAt,
      chatCompletedAt: chatCompletedAt ?? this.chatCompletedAt,
      chatCurrentQuestionIndex:
          chatCurrentQuestionIndex ?? this.chatCurrentQuestionIndex,
      skippedQuestionKeys: skippedQuestionKeys ?? this.skippedQuestionKeys,
      deferredQuestionKeys: deferredQuestionKeys ?? this.deferredQuestionKeys,
      basics: basics ?? this.basics,
      products: products ?? this.products,
      targetGroups: targetGroups ?? this.targetGroups,
      websiteAndSupport: websiteAndSupport ?? this.websiteAndSupport,
      sourcesAndReviews: sourcesAndReviews ?? this.sourcesAndReviews,
      marketingAndChannels: marketingAndChannels ?? this.marketingAndChannels,
      goalsAndRisks: goalsAndRisks ?? this.goalsAndRisks,
    );
  }
}
