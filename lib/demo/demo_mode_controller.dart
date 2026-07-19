import 'package:flutter/widgets.dart';

import '../data/app_state.dart';
import '../repositories/persistent_workspace_repository.dart';
import '../repositories/workspace_repository.dart';
import 'demo_preference_store.dart';

typedef DemoRepositoryFactory = Future<WorkspaceRepository> Function();

/// The single source of truth for the competition demo mode.
///
/// Entering the demo swaps AppState onto a dedicated demo repository
/// (its own IndexedDB database, seeded with the HB Cure / SchnurrPurr
/// showcase data) — production data and Supabase are never touched; all
/// demo writes stay local. The active flag is persisted so a browser
/// refresh keeps the demo running; leaving the demo wipes the demo data
/// and restores the regular repository for the current auth situation.
class DemoModeController extends ChangeNotifier {
  DemoModeController({
    required AppState appState,
    required DemoPreferenceStore preferenceStore,
    required DemoRepositoryFactory demoRepositoryFactory,
    required DemoRepositoryFactory exitRepositoryFactory,
    bool initiallyActive = false,
    WorkspaceRepository? initialDemoRepository,
  }) : _appState = appState,
       _preferenceStore = preferenceStore,
       _demoRepositoryFactory = demoRepositoryFactory,
       _exitRepositoryFactory = exitRepositoryFactory,
       _active = initiallyActive,
       _demoRepository = initialDemoRepository;

  final AppState _appState;
  final DemoPreferenceStore _preferenceStore;
  final DemoRepositoryFactory _demoRepositoryFactory;
  final DemoRepositoryFactory _exitRepositoryFactory;

  bool _active;
  bool _tourDismissed = false;
  bool _busy = false;
  WorkspaceRepository? _demoRepository;

  bool get isActive => _active;

  /// The light guided tour is shown while the demo runs, until dismissed.
  bool get isTourVisible => _active && !_tourDismissed;

  /// Starts the demo: activates and persists the flag, loads the demo
  /// repository and swaps it into AppState. Idempotent.
  Future<void> enterDemo() async {
    if (_active || _busy) return;
    _busy = true;
    try {
      _demoRepository = await _demoRepositoryFactory();
      _active = true;
      _tourDismissed = false;
      await _preferenceStore.saveActive(true);
      _appState.replaceWorkspaceRepository(
        _demoRepository!,
        status: WorkspaceLoadStatus.loaded,
      );
    } finally {
      _busy = false;
    }
    notifyListeners();
  }

  /// Leaves the demo: clears the persisted flag, wipes the demo data (the
  /// next demo starts fresh for the next juror) and restores the regular
  /// repository for the current auth situation.
  Future<void> exitDemo() async {
    if (!_active || _busy) return;
    _busy = true;
    try {
      _active = false;
      await _preferenceStore.saveActive(false);
      final demoRepository = _demoRepository;
      _demoRepository = null;
      if (demoRepository != null) {
        await demoRepository.clear();
        if (demoRepository is PersistentWorkspaceRepository) {
          await demoRepository.dispose();
        }
      }
      _appState.replaceWorkspaceRepository(await _exitRepositoryFactory());
    } finally {
      _busy = false;
    }
    notifyListeners();
  }

  void dismissTour() {
    if (_tourDismissed) return;
    _tourDismissed = true;
    notifyListeners();
  }

  static DemoModeController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DemoScope>()!.notifier!;
  }
}

class DemoScope extends InheritedNotifier<DemoModeController> {
  const DemoScope({super.key, required super.notifier, required super.child});
}
