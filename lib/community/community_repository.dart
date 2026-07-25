import 'models/community_member.dart';
import 'models/community_task.dart';
import 'models/discovered_content.dart';
import 'models/human_action_report.dart';
import 'models/profile_match.dart';

/// Data-access boundary for the Community Radar / Human Intelligence Network.
///
/// Read-only in CR-1/CR-2: the module surfaces discovered content, members and
/// (deterministically computed, read-only) matches. Mutations (task lifecycle,
/// reports, compliance guards) arrive in later blocks behind this same
/// interface, so the UI and controller never learn whether data is in-memory,
/// in IndexedDB or remote.
///
/// Members are a shared, company-independent pool; content, matches, tasks and
/// reports reference companies and members only by id.
abstract class CommunityRepository {
  List<DiscoveredContent> get discoveredContent;
  List<CommunityMember> get members;
  List<CommunityTask> get tasks;
  List<HumanActionReport> get reports;

  DiscoveredContent? findContent(String id);
  CommunityMember? findMember(String id);

  /// All members ranked against a content item: eligible first (highest score
  /// first), then ineligible; deterministic order.
  List<ProfileMatch> matchesForContent(String contentId);

  /// All content ranked against a member, same ordering rules.
  List<ProfileMatch> matchesForMember(String memberId);

  List<CommunityTask> tasksForContent(String contentId);
}
