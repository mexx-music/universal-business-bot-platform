import 'community_demo_data.dart';
import 'community_matching_service.dart';
import 'community_repository.dart';
import 'models/community_member.dart';
import 'models/community_task.dart';
import 'models/discovered_content.dart';
import 'models/human_action_report.dart';
import 'models/profile_match.dart';

/// In-memory [CommunityRepository] backed by fictional demo data. Matches are
/// computed by the deterministic [CommunityMatchingService], never stored by
/// hand — so scores stay explainable and consistent.
///
/// CR-2 remains entirely local and read-only: no APIs, no scraping, no
/// persistence, nothing published.
class LocalCommunityRepository implements CommunityRepository {
  LocalCommunityRepository({
    List<DiscoveredContent>? discoveredContent,
    List<CommunityMember>? members,
    List<CommunityTask>? tasks,
    List<HumanActionReport>? reports,
    CommunityMatchingService matchingService = const CommunityMatchingService(),
  }) : _discoveredContent = discoveredContent ?? CommunityDemoData.content(),
       _members = members ?? CommunityDemoData.members(),
       _tasks = tasks ?? CommunityDemoData.tasks(),
       _reports = reports ?? CommunityDemoData.reports(),
       _matching = matchingService;

  final List<DiscoveredContent> _discoveredContent;
  final List<CommunityMember> _members;
  final List<CommunityTask> _tasks;
  final List<HumanActionReport> _reports;
  final CommunityMatchingService _matching;

  @override
  List<DiscoveredContent> get discoveredContent =>
      List.unmodifiable(_discoveredContent);

  @override
  List<CommunityMember> get members => List.unmodifiable(_members);

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
    final content = findContent(contentId);
    if (content == null) return const [];
    return _matching.matchContent(content, _members);
  }

  @override
  List<ProfileMatch> matchesForMember(String memberId) {
    final member = findMember(memberId);
    if (member == null) return const [];
    return _matching.matchMember(member, _discoveredContent);
  }

  @override
  List<CommunityTask> tasksForContent(String contentId) {
    return _tasks.where((t) => t.contentId == contentId).toList();
  }
}
