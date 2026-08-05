import 'package:flutter/material.dart';

enum GettingStartedStepId {
  companyProfile,
  knowledgeImport,
  analysis,
  humanReview,
  ready,
}

class GettingStartedStepDefinition {
  const GettingStartedStepDefinition({
    required this.id,
    required this.icon,
    required this.estimatedMinutes,
  });

  final GettingStartedStepId id;
  final IconData icon;
  final int estimatedMinutes;
}

/// Static presentation model for the public onboarding demo. It has no upload,
/// registration, persistence, AI or workspace integration.
const gettingStartedSteps = <GettingStartedStepDefinition>[
  GettingStartedStepDefinition(
    id: GettingStartedStepId.companyProfile,
    icon: Icons.domain_add_outlined,
    estimatedMinutes: 2,
  ),
  GettingStartedStepDefinition(
    id: GettingStartedStepId.knowledgeImport,
    icon: Icons.upload_file_outlined,
    estimatedMinutes: 5,
  ),
  GettingStartedStepDefinition(
    id: GettingStartedStepId.analysis,
    icon: Icons.manage_search_outlined,
    estimatedMinutes: 1,
  ),
  GettingStartedStepDefinition(
    id: GettingStartedStepId.humanReview,
    icon: Icons.how_to_reg_outlined,
    estimatedMinutes: 10,
  ),
  GettingStartedStepDefinition(
    id: GettingStartedStepId.ready,
    icon: Icons.rocket_launch_outlined,
    estimatedMinutes: 1,
  ),
];

const gettingStartedImportKeys = <String>[
  'website',
  'pdf',
  'faq',
  'manuals',
  'products',
  'support',
  'videos',
];

const gettingStartedAnalysisKeys = <String>[
  'products',
  'faq',
  'documents',
  'support',
  'downloads',
  'contact',
  'knowledgeAreas',
];
