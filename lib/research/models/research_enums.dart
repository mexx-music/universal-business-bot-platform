// Enums for the Research Engine foundation (G-5).
//
// This layer only models *structured external information*. It performs no web
// research, crawling or API access — see docs/hackathon-2/RESEARCH_FOUNDATION.md.

/// The kind of external source a [ResearchDocument] originates from.
enum ResearchDocumentType {
  website,
  news,
  blog,
  socialPost,
  review,
  pressRelease,
  forum,
  video,
  financial,
  unknown,
}

extension ResearchDocumentTypeX on ResearchDocumentType {
  String get displayName => switch (this) {
    ResearchDocumentType.website => 'Website',
    ResearchDocumentType.news => 'News',
    ResearchDocumentType.blog => 'Blog',
    ResearchDocumentType.socialPost => 'Social Post',
    ResearchDocumentType.review => 'Bewertung',
    ResearchDocumentType.pressRelease => 'Pressemitteilung',
    ResearchDocumentType.forum => 'Forum',
    ResearchDocumentType.video => 'Video',
    ResearchDocumentType.financial => 'Finanzbericht',
    ResearchDocumentType.unknown => 'Unbekannt',
  };
}

/// What a single [ResearchEvidence] statement is about.
enum ResearchEvidenceCategory {
  product,
  marketing,
  expansion,
  hiring,
  finance,
  partnership,
  reputation,
  strategy,
  other,
}

extension ResearchEvidenceCategoryX on ResearchEvidenceCategory {
  String get displayName => switch (this) {
    ResearchEvidenceCategory.product => 'Produkt',
    ResearchEvidenceCategory.marketing => 'Marketing',
    ResearchEvidenceCategory.expansion => 'Expansion',
    ResearchEvidenceCategory.hiring => 'Personal',
    ResearchEvidenceCategory.finance => 'Finanzen',
    ResearchEvidenceCategory.partnership => 'Partnerschaft',
    ResearchEvidenceCategory.reputation => 'Reputation',
    ResearchEvidenceCategory.strategy => 'Strategie',
    ResearchEvidenceCategory.other => 'Sonstiges',
  };
}

/// The kind of milestone a [CompanyTimelineEvent] represents.
enum TimelineCategory {
  founding,
  product,
  marketing,
  partnership,
  expansion,
  legal,
  finance,
  hiring,
  strategy,
  crisis,
  milestone,
}

extension TimelineCategoryX on TimelineCategory {
  String get displayName => switch (this) {
    TimelineCategory.founding => 'Gründung',
    TimelineCategory.product => 'Produkt',
    TimelineCategory.marketing => 'Marketing',
    TimelineCategory.partnership => 'Partnerschaft',
    TimelineCategory.expansion => 'Expansion',
    TimelineCategory.legal => 'Recht',
    TimelineCategory.finance => 'Finanzen',
    TimelineCategory.hiring => 'Personal',
    TimelineCategory.strategy => 'Strategie',
    TimelineCategory.crisis => 'Krise',
    TimelineCategory.milestone => 'Meilenstein',
  };
}
