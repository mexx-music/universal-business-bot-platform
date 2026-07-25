import 'package:flutter/widgets.dart';

import 'community_demo_data.dart';
import 'community_repository.dart';
import 'models/community_member.dart';
import 'models/community_task.dart';
import 'models/discovered_content.dart';
import 'models/profile_match.dart';

/// Exposes the Community Radar / Human Intelligence Network data to the UI.
///
/// CR-1 is read-only: the controller reads through a [CommunityRepository]
/// (in-memory demo today) and offers lookups the screens need. Later blocks
/// add mutations (task lifecycle, reports) here and delegate to the
/// repository — the same pattern as the app's other controllers.
class CommunityController extends ChangeNotifier {
  CommunityController(this._repository);

  final CommunityRepository _repository;

  List<DiscoveredContent> get discoveredContent =>
      _repository.discoveredContent;

  List<CommunityMember> get members => _repository.members;

  int get openTaskCount => _repository.tasks.where((t) => t.isOpen).length;

  DiscoveredContent? content(String id) => _repository.findContent(id);

  CommunityMember? member(String id) => _repository.findMember(id);

  List<ProfileMatch> matchesForContent(String contentId) =>
      _repository.matchesForContent(contentId);

  List<CommunityTask> tasksForContent(String contentId) =>
      _repository.tasksForContent(contentId);

  /// Human-readable company name for a company id (demo mapping).
  String companyName(String companyId) =>
      CommunityDemoData.companyNames[companyId] ?? companyId;

  /// Distinct company ids present in the radar (for the company filter).
  List<String> get companyIds {
    final ids = <String>{for (final c in discoveredContent) c.companyId};
    return ids.toList()..sort();
  }

  static CommunityController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CommunityScope>()!
        .notifier!;
  }
}

class CommunityScope extends InheritedNotifier<CommunityController> {
  const CommunityScope({
    super.key,
    required super.notifier,
    required super.child,
  });
}
