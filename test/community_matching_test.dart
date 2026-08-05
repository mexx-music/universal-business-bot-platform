import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/community/community_demo_data.dart';
import 'package:universalbusiness/community/community_matching_service.dart';
import 'package:universalbusiness/community/local_community_repository.dart';
import 'package:universalbusiness/community/models/community_enums.dart';
import 'package:universalbusiness/community/models/community_member.dart';
import 'package:universalbusiness/community/models/discovered_content.dart';
import 'package:universalbusiness/community/models/profile_match.dart';
import 'package:universalbusiness/models/knowledge_entry.dart' show RiskLevel;

void main() {
  const service = CommunityMatchingService();

  DiscoveredContent content({
    String id = 'c',
    String companyId = 'schnurr-purr',
    CommunityPlatform platform = CommunityPlatform.reddit,
    String language = 'de',
    String country = 'DE',
    List<String> topics = const ['katzen', 'stress'],
    List<CommunityActionType> recommended = const [
      CommunityActionType.personalExperience,
    ],
  }) {
    return DiscoveredContent(
      id: id,
      companyId: companyId,
      platform: platform,
      sourceUrl: 'https://example.invalid/x',
      title: 'T',
      originalText: 'O',
      language: language,
      country: country,
      topicTags: topics,
      detectedIntent: ContentIntent.question,
      sentiment: ContentSentiment.neutral,
      relevanceScore: 50,
      riskLevel: RiskLevel.green,
      discoveredAt: DateTime(2026, 7, 20),
      status: ContentStatus.newContent,
      recommendedActionTypes: recommended,
    );
  }

  CommunityMember member({
    String id = 'm',
    List<String> languages = const ['de'],
    String country = 'DE',
    List<String> interests = const ['katzen'],
    List<String> experience = const ['katzen'],
    List<CommunityPlatform> platforms = const [CommunityPlatform.reddit],
    List<String> publicTopics = const ['katzen'],
    List<CommunityActionType> preferred = const [
      CommunityActionType.personalExperience,
    ],
    List<HumanIntelligenceDomain> domains = const [
      HumanIntelligenceDomain.communityEngagement,
    ],
    List<String> excludedTopics = const [],
    List<String> excludedCompanies = const [],
    bool consent = true,
    bool available = true,
    MemberStatus status = MemberStatus.active,
    int authenticity = 90,
  }) {
    return CommunityMember(
      id: id,
      displayName: id,
      country: country,
      languages: languages,
      platformProfiles: [
        for (final p in platforms)
          MemberPlatformProfile(platform: p, handle: id),
      ],
      declaredInterests: interests,
      verifiedTopics: const [],
      publicActivityTopics: publicTopics,
      writingStyle: 's',
      experienceCategories: experience,
      isVerified: true,
      accountAuthenticityScore: authenticity,
      qualityScore: 80,
      availability: 'x',
      compensationEnabled: true,
      disclosureRequirements: const [],
      status: status,
      preferredActions: preferred,
      supportedDomains: domains,
      excludedTopics: excludedTopics,
      excludedCompanyIds: excludedCompanies,
      profileAnalysisConsent: consent,
      isAvailable: available,
    );
  }

  group('Score computation', () {
    test('a perfect fit scores 100 across all components', () {
      final m = service.evaluate(content(), member());
      expect(m.overallMatchScore, 100);
      expect(m.eligible, isTrue);
      expect(m.components.every((c) => c.matched), isTrue);
    });

    test('component points match the documented weights', () {
      final m = service.evaluate(content(), member());
      int points(MatchFactor f) =>
          m.components.firstWhere((c) => c.factor == f).points;
      expect(points(MatchFactor.language), 25);
      expect(points(MatchFactor.topic), 20);
      expect(points(MatchFactor.platform), 15);
      expect(points(MatchFactor.experience), 15);
      expect(points(MatchFactor.country), 10);
      expect(points(MatchFactor.publicActivity), 10);
      expect(points(MatchFactor.preferredAction), 5);
    });

    test('language mismatch removes exactly its component', () {
      final m = service.evaluate(content(), member(languages: ['en']));
      expect(m.overallMatchScore, 75);
      expect(
        m.components
            .firstWhere((c) => c.factor == MatchFactor.language)
            .matched,
        isFalse,
      );
      expect(m.eligible, isTrue);
    });

    test('missing platform removes its points and warns', () {
      final m = service.evaluate(
        content(),
        member(platforms: [CommunityPlatform.instagram]),
      );
      expect(
        m.components.firstWhere((c) => c.factor == MatchFactor.platform).points,
        0,
      );
      expect(m.warnings, contains(MatchWarning.notOnPlatform));
      expect(m.eligible, isTrue);
    });
  });

  group('Hard exclusions', () {
    test('excluded topic blocks (and names the topic)', () {
      final m = service.evaluate(
        content(topics: ['katzen', 'stress']),
        member(excludedTopics: ['stress']),
      );
      expect(m.eligible, isFalse);
      final block = m.blockReasons.firstWhere(
        (b) => b.reason == MatchBlock.topicExcluded,
      );
      expect(block.detail, 'stress');
    });

    test('excluded company blocks', () {
      final m = service.evaluate(
        content(companyId: 'schnurr-purr'),
        member(excludedCompanies: ['schnurr-purr']),
      );
      expect(m.eligible, isFalse);
      expect(
        m.blockReasons.map((b) => b.reason),
        contains(MatchBlock.companyExcluded),
      );
    });

    test('unavailable and paused members are blocked', () {
      expect(
        service.evaluate(content(), member(available: false)).eligible,
        isFalse,
      );
      expect(
        service
            .evaluate(content(), member(status: MemberStatus.paused))
            .eligible,
        isFalse,
      );
    });

    test('unsupported domain blocks', () {
      final m = service.evaluate(
        content(),
        member(domains: [HumanIntelligenceDomain.translation]),
      );
      expect(m.eligible, isFalse);
      expect(
        m.blockReasons.map((b) => b.reason),
        contains(MatchBlock.domainUnsupported),
      );
    });
  });

  group('Consent rule', () {
    test('without consent the public-activity factor is not used and a '
        'warning is added', () {
      final withConsent = service.evaluate(content(), member(consent: true));
      final withoutConsent = service.evaluate(
        content(),
        member(consent: false),
      );

      final pub = withoutConsent.components.firstWhere(
        (c) => c.factor == MatchFactor.publicActivity,
      );
      expect(pub.matched, isFalse);
      expect(pub.points, 0);
      expect(pub.detail, isNull);
      expect(
        withoutConsent.warnings,
        contains(MatchWarning.profileAnalysisNoConsent),
      );
      // Still eligible — consent is not a hard block.
      expect(withoutConsent.eligible, isTrue);
      // Consent version does count the public-activity points.
      expect(
        withConsent.overallMatchScore - withoutConsent.overallMatchScore,
        10,
      );
    });
  });

  group('Determinism and ordering', () {
    test('same inputs produce identical output', () {
      final a = service.matchContent(content(), CommunityDemoData.members());
      final b = service.matchContent(content(), CommunityDemoData.members());
      expect(
        a.map((m) => '${m.memberId}:${m.overallMatchScore}:${m.eligible}'),
        b.map((m) => '${m.memberId}:${m.overallMatchScore}:${m.eligible}'),
      );
    });

    test('eligible first, then score desc, ties by member id', () {
      final members = [
        member(id: 'm-b', authenticity: 90),
        member(id: 'm-a', authenticity: 90),
        member(id: 'm-blocked', available: false),
      ];
      final ranked = service.matchContent(content(), members);
      // Blocked one is last.
      expect(ranked.last.memberId, 'm-blocked');
      // Equal scores → id ascending.
      expect(ranked[0].memberId, 'm-a');
      expect(ranked[1].memberId, 'm-b');
    });
  });

  group('Both directions', () {
    test('member-first matching evaluates across all content', () {
      final ranked = service.matchMember(
        member(id: 'lena'),
        CommunityDemoData.content(),
      );
      expect(ranked.length, CommunityDemoData.content().length);
    });

    test('global member usage: a member matches content of different '
        'companies', () {
      final repo = LocalCommunityRepository();
      final lena = repo.matchesForMember('m-1');
      final companies = {
        for (final m in lena.where((m) => m.eligible))
          repo.findContent(m.contentId)!.companyId,
      };
      // Lena (cats) fits SchnurrPurr; the pool is not company-bound.
      expect(companies, contains('schnurr-purr'));
    });
  });

  group('Demo data shows the required match situations against dc-1', () {
    final repo = LocalCommunityRepository();
    final matches = {
      for (final m in repo.matchesForContent('dc-1')) m.memberId: m,
    };

    test('very good, language conflict, platform missing, exclusions, '
        'consent and unavailable are all present', () {
      // Very good match.
      expect(matches['m-1']!.overallMatchScore, greaterThanOrEqualTo(90));
      expect(matches['m-1']!.eligible, isTrue);
      // Language conflict (Elif writes EN).
      expect(
        matches['m-9']!.components
            .firstWhere((c) => c.factor == MatchFactor.language)
            .matched,
        isFalse,
      );
      // Platform missing (Bea on Instagram only).
      expect(matches['m-10']!.warnings, contains(MatchWarning.notOnPlatform));
      // Topic excluded (Cem excludes stress).
      expect(matches['m-11']!.eligible, isFalse);
      // Company excluded (Doro excludes SchnurrPurr).
      expect(matches['m-12']!.eligible, isFalse);
      // Missing consent (Ferda).
      expect(
        matches['m-13']!.warnings,
        contains(MatchWarning.profileAnalysisNoConsent),
      );
      // Unavailable (Gino).
      expect(matches['m-14']!.eligible, isFalse);
    });
  });
}
