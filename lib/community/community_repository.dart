import 'models/community_member.dart';
import 'models/community_task.dart';
import 'models/discovered_content.dart';
import 'models/human_action_report.dart';
import 'models/profile_match.dart';

/// Data-access boundary for the Community Radar / Human Intelligence Network.
///
/// Deliberately read-only in CR-1: the module surfaces discovered content and
/// (read-only) matches, members and tasks. Mutations (task lifecycle, reports,
/// compliance guards) arrive in later blocks behind this same interface, so
/// the UI and controller never need to know whether data is in-memory, in
/// IndexedDB or remote.
///
/// Members are a shared, company-independent pool; content, matches, tasks and
/// reports reference companies and members only by id.
abstract class CommunityRepository {
  List<DiscoveredContent> get discoveredContent;
  List<CommunityMember> get members;
  List<ProfileMatch> get matches;
  List<CommunityTask> get tasks;
  List<HumanActionReport> get reports;

  DiscoveredContent? findContent(String id);
  CommunityMember? findMember(String id);

  /// Matches for a content item, highest [ProfileMatch.overallMatchScore]
  /// first.
  List<ProfileMatch> matchesForContent(String contentId);

  List<CommunityTask> tasksForContent(String contentId);
}
