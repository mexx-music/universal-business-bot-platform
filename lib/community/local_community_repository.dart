import 'community_demo_data.dart';
import 'community_repository.dart';
import 'models/community_member.dart';
import 'models/community_task.dart';
import 'models/discovered_content.dart';
import 'models/human_action_report.dart';
import 'models/profile_match.dart';

/// In-memory [CommunityRepository] backed by fictional demo data.
///
/// CR-1 runs entirely locally: no APIs, no scraping, no persistence, nothing
/// published. This mirrors the maturity of most other entities in the app,
/// which are also local-first today.
class LocalCommunityRepository implements CommunityRepository {
  LocalCommunityRepository({
    List<DiscoveredContent>? discoveredContent,
    List<CommunityMember>? members,
    List<ProfileMatch>? matches,
    List<CommunityTask>? tasks,
    List<HumanActionReport>? reports,
  }) : _discoveredContent = discoveredContent ?? CommunityDemoData.content(),
       _members = members ?? CommunityDemoData.members(),
       _matches = matches ?? CommunityDemoData.matches(),
       _tasks = tasks ?? CommunityDemoData.tasks(),
       _reports = reports ?? CommunityDemoData.reports();

  final List<DiscoveredContent> _discoveredContent;
  final List<CommunityMember> _members;
  final List<ProfileMatch> _matches;
  final List<CommunityTask> _tasks;
  final List<HumanActionReport> _reports;

  @override
  List<DiscoveredContent> get discoveredContent =>
      List.unmodifiable(_discoveredContent);

  @override
  List<CommunityMember> get members => List.unmodifiable(_members);

  @override
  List<ProfileMatch> get matches => List.unmodifiable(_matches);

  @override
  List<CommunityTask> get tasks => List.unmodifiable(_tasks);

  @override
  List<HumanActionReport> get reports => List.unmodifiable(_reports);

  @override
  DiscoveredContent? findContent(String id) {
    for (final content in _discoveredContent) {
      if (content.id == id) return content;
    }
    return null;
  }

  @override
  CommunityMember? findMember(String id) {
    for (final member in _members) {
      if (member.id == id) return member;
    }
    return null;
  }

  @override
  List<ProfileMatch> matchesForContent(String contentId) {
    final result = _matches.where((m) => m.contentId == contentId).toList()
      ..sort((a, b) => b.overallMatchScore.compareTo(a.overallMatchScore));
    return result;
  }

  @override
  List<CommunityTask> tasksForContent(String contentId) {
    return _tasks.where((t) => t.contentId == contentId).toList();
  }
}
