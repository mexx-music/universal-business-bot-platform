import 'package:flutter/material.dart';

enum RoadmapStageStatus { available, vision }

enum RoadmapStageId {
  verifiedCompanyKnowledge,
  customerIntelligence,
  websiteIntelligence,
  marketingIntelligence,
  competitiveIntelligence,
  businessIntelligence,
  digitalBusinessBrain,
}

class RoadmapStageDefinition {
  const RoadmapStageDefinition({
    required this.id,
    required this.status,
    required this.icon,
    required this.featureKeys,
    this.nextExpansion = false,
  });

  final RoadmapStageId id;
  final RoadmapStageStatus status;
  final IconData icon;
  final List<String> featureKeys;
  final bool nextExpansion;
}

/// Presentation-only product roadmap. It contains no service calls, feature
/// flags, delivery dates or implementation claims.
const businessBrainRoadmap = <RoadmapStageDefinition>[
  RoadmapStageDefinition(
    id: RoadmapStageId.verifiedCompanyKnowledge,
    status: RoadmapStageStatus.available,
    icon: Icons.verified_outlined,
    featureKeys: [
      'knowledgeBuilder',
      'humanReview',
      'groundedAnswers',
      'websiteLinks',
      'operationsCenter',
    ],
  ),
  RoadmapStageDefinition(
    id: RoadmapStageId.customerIntelligence,
    status: RoadmapStageStatus.vision,
    icon: Icons.forum_outlined,
    nextExpansion: true,
    featureKeys: [
      'frequentQuestions',
      'recurringProblems',
      'productInterest',
      'supportTrends',
      'faqSuggestions',
    ],
  ),
  RoadmapStageDefinition(
    id: RoadmapStageId.websiteIntelligence,
    status: RoadmapStageStatus.vision,
    icon: Icons.language_outlined,
    featureKeys: [
      'analyseWebsite',
      'detectProductPages',
      'detectDownloads',
      'detectFaq',
      'detectKnowledgeGaps',
      'keepWebsiteCurrent',
    ],
  ),
  RoadmapStageDefinition(
    id: RoadmapStageId.marketingIntelligence,
    status: RoadmapStageStatus.vision,
    icon: Icons.campaign_outlined,
    featureKeys: [
      'improveLandingPage',
      'googleBusiness',
      'googleAds',
      'facebook',
      'instagram',
      'linkedIn',
      'reddit',
      'youTube',
      'newsletter',
      'marketingIdeas',
      'contentSuggestions',
    ],
  ),
  RoadmapStageDefinition(
    id: RoadmapStageId.competitiveIntelligence,
    status: RoadmapStageStatus.vision,
    icon: Icons.radar_outlined,
    featureKeys: [
      'observeCompetitors',
      'detectPriceChanges',
      'marketTrends',
      'newProducts',
      'strengthsWeaknesses',
    ],
  ),
  RoadmapStageDefinition(
    id: RoadmapStageId.businessIntelligence,
    status: RoadmapStageStatus.vision,
    icon: Icons.insights_outlined,
    featureKeys: [
      'customerProblems',
      'productIdeas',
      'improvementSuggestions',
      'salesOpportunities',
      'frequentObjections',
    ],
  ),
  RoadmapStageDefinition(
    id: RoadmapStageId.digitalBusinessBrain,
    status: RoadmapStageStatus.vision,
    icon: Icons.hub_outlined,
    featureKeys: [
      'recogniseConnections',
      'recommendPriorities',
      'prepareTasks',
      'createReports',
      'decisionBriefs',
    ],
  ),
];
