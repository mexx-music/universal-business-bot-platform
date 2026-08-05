import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/community/community_controller.dart';
import 'package:universalbusiness/community/community_demo_data.dart';
import 'package:universalbusiness/community/local_community_repository.dart';
import 'package:universalbusiness/community/models/community_enums.dart';
import 'package:universalbusiness/models/knowledge_entry.dart' show RiskLevel;

void main() {
  group('Platform action capabilities', () {
    test('openOriginal and skip are always available', () {
      for (final platform in CommunityPlatform.values) {
        final actions = allowedActionsFor(platform);
        expect(actions, contains(CommunityActionType.openOriginal));
        expect(actions, contains(CommunityActionType.skip));
      }
    });

    test('actions are platform-dependent', () {
      // Instagram allows a short comment but not a factual answer/repost.
      expect(
        isActionAllowedOn(
          CommunityPlatform.instagram,
          CommunityActionType.shortPersonalComment,
        ),
        isTrue,
      );
      expect(
        isActionAllowedOn(
          CommunityPlatform.instagram,
          CommunityActionType.factualAnswer,
        ),
        isFalse,
      );
      // Repost is an X capability, not a forum one.
      expect(
        isActionAllowedOn(CommunityPlatform.x, CommunityActionType.repost),
        isTrue,
      );
      expect(
        isActionAllowedOn(CommunityPlatform.forum, CommunityActionType.repost),
        isFalse,
      );
      // Forum supports factual answers.
      expect(
        isActionAllowedOn(
          CommunityPlatform.forum,
          CommunityActionType.factualAnswer,
        ),
        isTrue,
      );
    });
  });

  group('Demo data integrity', () {
    final content = CommunityDemoData.content();
    final members = CommunityDemoData.members();
    final tasks = CommunityDemoData.tasks();
    final reports = CommunityDemoData.reports();

    test('meets the CR-1 volume and variety requirements', () {
      expect(content.length, greaterThanOrEqualTo(10));
      expect(members.length, greaterThanOrEqualTo(8));

      // Multiple platforms, languages, countries, risk levels.
      expect({for (final c in content) c.platform}.length, greaterThan(2));
      expect({for (final c in content) c.language}, containsAll(['de', 'en']));
      expect({for (final c in content) c.country}.length, greaterThan(2));
      expect({
        for (final c in content) c.riskLevel,
      }, containsAll([RiskLevel.green, RiskLevel.yellow, RiskLevel.red]));
    });

    test('tasks include open, accepted, completed and declined states', () {
      final statuses = {for (final t in tasks) t.status};
      expect(statuses, contains(CommunityTaskStatus.open));
      expect(statuses, contains(CommunityTaskStatus.accepted));
      expect(statuses, contains(CommunityTaskStatus.completed));
      expect(statuses, contains(CommunityTaskStatus.declined));
    });

    test('every recommended action is allowed on its platform', () {
      for (final c in content) {
        for (final action in c.recommendedActionTypes) {
          expect(
            isActionAllowedOn(c.platform, action),
            isTrue,
            reason:
                '${action.name} not allowed on ${c.platform.name} '
                '(content ${c.id})',
          );
        }
      }
    });

    test('red-risk content never recommends active engagement', () {
      const engaging = {
        CommunityActionType.shortPersonalComment,
        CommunityActionType.personalExperience,
        CommunityActionType.factualAnswer,
        CommunityActionType.repost,
        CommunityActionType.share,
      };
      for (final c in content.where((c) => c.riskLevel == RiskLevel.red)) {
        expect(
          c.recommendedActionTypes.any(engaging.contains),
          isFalse,
          reason: 'red content ${c.id} must not push active engagement',
        );
      }
    });

    test('references are consistent (tasks, reports)', () {
      final contentIds = {for (final c in content) c.id};
      final memberIds = {for (final m in members) m.id};
      final taskIds = {for (final t in tasks) t.id};

      for (final t in tasks) {
        expect(contentIds, contains(t.contentId));
        if (t.assignedMemberId != null) {
          expect(memberIds, contains(t.assignedMemberId));
        }
      }
      for (final r in reports) {
        expect(taskIds, contains(r.taskId));
        expect(memberIds, contains(r.performedBy));
      }
    });

    test('member pool is company-independent (spans multiple companies)', () {
      final companyIds = {for (final c in content) c.companyId};
      expect(companyIds.length, greaterThan(1));
      // The same member can be matched to content from different companies —
      // proving the pool is not owned by any single company.
      final repo = LocalCommunityRepository();
      final byMemberCompanies = <String, Set<String>>{};
      for (final c in content) {
        for (final m in repo.matchesForContent(c.id)) {
          byMemberCompanies.putIfAbsent(m.memberId, () => {}).add(c.companyId);
        }
      }
      expect(
        byMemberCompanies.values.any((companies) => companies.length > 1),
        isTrue,
      );
    });
  });

  group('LocalCommunityRepository', () {
    test('matchesForContent lists eligible first, score descending', () {
      final repo = LocalCommunityRepository();
      final matches = repo.matchesForContent('dc-1');
      expect(matches, isNotEmpty);
      // All eligible come before any ineligible.
      final firstIneligible = matches.indexWhere((m) => !m.eligible);
      if (firstIneligible != -1) {
        for (var i = firstIneligible; i < matches.length; i++) {
          expect(matches[i].eligible, isFalse);
        }
      }
      // Scores descending within the eligible sublist.
      final eligible = matches.where((m) => m.eligible).toList();
      for (var i = 1; i < eligible.length; i++) {
        expect(
          eligible[i - 1].overallMatchScore,
          greaterThanOrEqualTo(eligible[i].overallMatchScore),
        );
      }
    });

    test('lookups and task filtering work', () {
      final repo = LocalCommunityRepository();
      expect(repo.findContent('dc-1'), isNotNull);
      expect(repo.findContent('nope'), isNull);
      expect(repo.findMember('m-1'), isNotNull);
      expect(repo.tasksForContent('dc-1'), isNotEmpty);
    });

    test('read accessors return unmodifiable views', () {
      final repo = LocalCommunityRepository();
      expect(() => repo.members.clear(), throwsUnsupportedError);
      expect(() => repo.discoveredContent.clear(), throwsUnsupportedError);
    });
  });

  group('CommunityController', () {
    test('exposes company mapping, distinct ids and open task count', () {
      final controller = CommunityController(LocalCommunityRepository());
      expect(controller.companyName('hb-cure'), 'HB Cure');
      expect(controller.companyName('unknown'), 'unknown');
      expect(controller.companyIds.length, greaterThan(1));
      expect(controller.openTaskCount, greaterThan(0));
    });
  });
}
