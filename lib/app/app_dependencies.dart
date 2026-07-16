import 'package:flutter/foundation.dart';

import '../data/app_state.dart';
import '../repositories/local_workspace_repository.dart';
import '../repositories/persistence/persistence_database.dart';
import '../repositories/persistent_workspace_repository.dart';
import '../repositories/tenant_context.dart';
import '../repositories/workspace_repository.dart';

/// Composition root: the single place where concrete implementations are
/// chosen and wired together. No globals, no hidden singletons — everything
/// downstream receives its dependencies via constructor.
///
/// Future variants (e.g. `AppDependencies.remote(session)`) swap the
/// repository implementation and derive the [TenantContext] from the
/// signed-in user, without touching AppState, screens or widgets.
class AppDependencies {
  AppDependencies._({
    required this.tenantContext,
    required this.workspaceRepository,
    required this.appState,
  });

  /// Wires the app for production use: the persistent (IndexedDB-backed)
  /// repository where available, otherwise the in-memory one.
  ///
  /// Falls back to [AppDependencies.local] when no persistence backend
  /// exists for the platform or opening it fails (unavailable IndexedDB,
  /// data written by a newer app version, storage errors). The fallback
  /// never deletes or overwrites stored data — the session just runs in
  /// memory.
  static Future<AppDependencies> create() async {
    const tenantContext = TenantContext.local();
    final databaseFactory = defaultPersistenceDatabaseFactory;
    if (databaseFactory == null) return AppDependencies.local();
    try {
      final repository = await PersistentWorkspaceRepository.open(
        databaseFactory: databaseFactory,
        tenantContext: tenantContext,
      );
      return AppDependencies._(
        tenantContext: tenantContext,
        workspaceRepository: repository,
        appState: AppState(workspaceRepository: repository),
      );
    } catch (error) {
      debugPrint(
        'Persistent storage unavailable, running in memory only: $error',
      );
      return AppDependencies.local();
    }
  }

  /// Wires the app against the local in-memory repository — used by tests,
  /// as demo fallback, and whenever persistent storage is unavailable.
  factory AppDependencies.local() {
    const tenantContext = TenantContext.local();
    final workspaceRepository = LocalWorkspaceRepository(
      tenantContext: tenantContext,
    );
    return AppDependencies._(
      tenantContext: tenantContext,
      workspaceRepository: workspaceRepository,
      appState: AppState(workspaceRepository: workspaceRepository),
    );
  }

  final TenantContext tenantContext;
  final WorkspaceRepository workspaceRepository;
  final AppState appState;
}
