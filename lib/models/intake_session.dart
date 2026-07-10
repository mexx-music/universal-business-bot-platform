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
  final String importantPages;
  final String frequentQuestions;
  final String supportProblems;
  final String sensitiveTopics;
  final bool? hasSensitiveTopics;

  const IntakeWebsiteAndSupport({
    this.importantPages = '',
    this.frequentQuestions = '',
    this.supportProblems = '',
    this.sensitiveTopics = '',
    this.hasSensitiveTopics,
  });

  IntakeWebsiteAndSupport copyWith({
    String? importantPages,
    String? frequentQuestions,
    String? supportProblems,
    String? sensitiveTopics,
    bool? hasSensitiveTopics,
  }) {
    return IntakeWebsiteAndSupport(
      importantPages: importantPages ?? this.importantPages,
      frequentQuestions: frequentQuestions ?? this.frequentQuestions,
      supportProblems: supportProblems ?? this.supportProblems,
      sensitiveTopics: sensitiveTopics ?? this.sensitiveTopics,
      hasSensitiveTopics: hasSensitiveTopics ?? this.hasSensitiveTopics,
    );
  }
}

class IntakeSourcesAndReviews {
  final String existingSources;
  final String reviews;
  final String socialMentions;
  final String trustMaterial;
  final bool? hasReviews;
  final bool? hasSocialMentions;
  final bool? hasTrustMaterial;

  const IntakeSourcesAndReviews({
    this.existingSources = '',
    this.reviews = '',
    this.socialMentions = '',
    this.trustMaterial = '',
    this.hasReviews,
    this.hasSocialMentions,
    this.hasTrustMaterial,
  });

  IntakeSourcesAndReviews copyWith({
    String? existingSources,
    String? reviews,
    String? socialMentions,
    String? trustMaterial,
    bool? hasReviews,
    bool? hasSocialMentions,
    bool? hasTrustMaterial,
  }) {
    return IntakeSourcesAndReviews(
      existingSources: existingSources ?? this.existingSources,
      reviews: reviews ?? this.reviews,
      socialMentions: socialMentions ?? this.socialMentions,
      trustMaterial: trustMaterial ?? this.trustMaterial,
      hasReviews: hasReviews ?? this.hasReviews,
      hasSocialMentions: hasSocialMentions ?? this.hasSocialMentions,
      hasTrustMaterial: hasTrustMaterial ?? this.hasTrustMaterial,
    );
  }
}

class IntakeMarketingAndChannels {
  final String channels;
  final String campaigns;
  final String worked;
  final String notWorked;
  final String reachProblems;

  const IntakeMarketingAndChannels({
    this.channels = '',
    this.campaigns = '',
    this.worked = '',
    this.notWorked = '',
    this.reachProblems = '',
  });

  IntakeMarketingAndChannels copyWith({
    String? channels,
    String? campaigns,
    String? worked,
    String? notWorked,
    String? reachProblems,
  }) {
    return IntakeMarketingAndChannels(
      channels: channels ?? this.channels,
      campaigns: campaigns ?? this.campaigns,
      worked: worked ?? this.worked,
      notWorked: notWorked ?? this.notWorked,
      reachProblems: reachProblems ?? this.reachProblems,
    );
  }
}

class IntakeGoalsAndRisks {
  final String companyGoals;
  final String shortTermPriorities;
  final String forbiddenClaims;
  final String botRestrictedTopics;

  const IntakeGoalsAndRisks({
    this.companyGoals = '',
    this.shortTermPriorities = '',
    this.forbiddenClaims = '',
    this.botRestrictedTopics = '',
  });

  IntakeGoalsAndRisks copyWith({
    String? companyGoals,
    String? shortTermPriorities,
    String? forbiddenClaims,
    String? botRestrictedTopics,
  }) {
    return IntakeGoalsAndRisks(
      companyGoals: companyGoals ?? this.companyGoals,
      shortTermPriorities: shortTermPriorities ?? this.shortTermPriorities,
      forbiddenClaims: forbiddenClaims ?? this.forbiddenClaims,
      botRestrictedTopics: botRestrictedTopics ?? this.botRestrictedTopics,
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
