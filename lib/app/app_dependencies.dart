import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_controller.dart';
import '../auth/local_auth_service.dart';
import '../auth/auth_status.dart';
import '../auth/supabase_auth_service.dart';
import '../auth/tenant_preference_store_factory.dart';
import '../data/app_state.dart';
import '../demo/demo_mode_controller.dart';
import '../demo/demo_preference_store.dart';
import '../demo/demo_preference_store_factory.dart';
import '../onboarding/onboarding_controller.dart';
import '../onboarding/tenant_onboarding_data_source.dart';
import '../onboarding/tenant_onboarding_service.dart';
import '../public_intake/public_intake_service.dart';
import '../repositories/empty_workspace_repository.dart';
import '../repositories/local_workspace_repository.dart';
import '../repositories/persistence/persistence_database.dart';
import '../repositories/persistent_workspace_repository.dart';
import '../repositories/remote_workspace_data_source.dart';
import '../repositories/remote_workspace_repository.dart';
import '../repositories/tenant_context.dart';
import '../repositories/workspace_repository.dart';
import '../tenant_selection/tenant_selection_controller.dart';

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
    required this.authController,
    required this.workspaceRepository,
    required this.appState,
    required this.onboardingController,
    required this.tenantSelectionController,
    required this.publicIntakeService,
    required this.demoModeController,
    RemoteWorkspaceDataSource? remoteDataSource,
  });

  /// Separate IndexedDB database for the competition demo — demo writes can
  /// never touch regular local data or Supabase.
  static const String demoDatabaseName = 'universalbusiness_demo.db';

  /// Wires the app for production use: the persistent (IndexedDB-backed)
  /// repository where available, otherwise the in-memory one.
  ///
  /// Falls back to [AppDependencies.local] when no persistence backend
  /// exists for the platform or opening it fails (unavailable IndexedDB,
  /// data written by a newer app version, storage errors). The fallback
  /// never deletes or overwrites stored data — the session just runs in
  /// memory.
  static Future<AppDependencies> create() async {
    final authController = await _createAuthController();
    final client = authController.isSupabaseMode
        ? Supabase.instance.client
        : null;
    final remoteDataSource = client == null
        ? null
        : SupabaseWorkspaceDataSource(client);
    final onboardingService = TenantOnboardingService(
      dataSource: client == null
          ? const UnsupportedTenantOnboardingDataSource()
          : SupabaseTenantOnboardingDataSource(client),
    );
    final publicIntakeService = client == null
        ? const UnsupportedPublicIntakeService()
        : SupabasePublicIntakeService(client);
    return _createWithAuth(
      authController: authController,
      remoteDataSource: remoteDataSource,
      onboardingService: onboardingService,
      publicIntakeService: publicIntakeService,
    );
  }

  @visibleForTesting
  static Future<AppDependencies> createWithAuthController({
    required AuthController authController,
    RemoteWorkspaceDataSource? remoteDataSource,
    TenantOnboardingService? onboardingService,
    PublicIntakeService? publicIntakeService,
  }) {
    return _createWithAuth(
      authController: authController,
      remoteDataSource: remoteDataSource,
      onboardingService: onboardingService,
      publicIntakeService: publicIntakeService,
    );
  }

  static Future<AppDependencies> _createWithAuth({
    required AuthController authController,
    RemoteWorkspaceDataSource? remoteDataSource,
    TenantOnboardingService? onboardingService,
    PublicIntakeService? publicIntakeService,
  }) async {
    final tenantContext =
        authController.tenantContext ?? _fallbackTenant(authController);

    // Competition demo mode survives a browser refresh: when the persisted
    // flag is set, the app boots straight onto the demo repository — no
    // Supabase access is needed or made for the demo.
    final demoPreferenceStore = createDemoPreferenceStore();
    final restoredDemoRepository = await _restoreDemoRepository(
      demoPreferenceStore,
    );

    if (authController.isSupabaseMode) {
      final repositoryResult = restoredDemoRepository != null
          ? _RepositoryResult(
              repository: restoredDemoRepository,
              status: WorkspaceLoadStatus.loaded,
            )
          : await _remoteOrEmptyRepository(
              authController: authController,
              remoteDataSource: remoteDataSource,
            );
      final appState = AppState(
        workspaceRepository: repositoryResult.repository,
        workspaceLoadStatus: repositoryResult.status,
        workspaceLoadError: repositoryResult.error,
      );
      final onboardingController = OnboardingController(
        authController: authController,
        onboardingService:
            onboardingService ??
            const TenantOnboardingService(
              dataSource: UnsupportedTenantOnboardingDataSource(),
            ),
      );
      final tenantSelectionController = TenantSelectionController(
        authController: authController,
        appState: appState,
      );
      final demoModeController = DemoModeController(
        appState: appState,
        preferenceStore: demoPreferenceStore,
        demoRepositoryFactory: _openDemoRepository,
        exitRepositoryFactory: () async => (await _remoteOrEmptyRepository(
          authController: authController,
          remoteDataSource: remoteDataSource,
        )).repository,
        initiallyActive: restoredDemoRepository != null,
        initialDemoRepository: restoredDemoRepository,
      );
      final dependencies = AppDependencies._(
        tenantContext: repositoryResult.repository.tenantContext,
        authController: authController,
        workspaceRepository: repositoryResult.repository,
        appState: appState,
        onboardingController: onboardingController,
        tenantSelectionController: tenantSelectionController,
        publicIntakeService:
            publicIntakeService ?? const UnsupportedPublicIntakeService(),
        demoModeController: demoModeController,
        remoteDataSource: remoteDataSource,
      );
      dependencies._attachAuthRepositoryBridge(remoteDataSource);
      return dependencies;
    }

    final databaseFactory = defaultPersistenceDatabaseFactory;
    if (databaseFactory == null && restoredDemoRepository == null) {
      return AppDependencies.local(authController: authController);
    }
    try {
      final regularRepository = restoredDemoRepository != null
          ? null
          : await PersistentWorkspaceRepository.open(
              databaseFactory: databaseFactory!,
              tenantContext: tenantContext,
            );
      final repository = restoredDemoRepository ?? regularRepository!;
      final appState = AppState(workspaceRepository: repository);
      return AppDependencies._(
        tenantContext: tenantContext,
        authController: authController,
        workspaceRepository: repository,
        appState: appState,
        onboardingController: OnboardingController(
          authController: authController,
          onboardingService:
              onboardingService ??
              const TenantOnboardingService(
                dataSource: UnsupportedTenantOnboardingDataSource(),
              ),
        ),
        tenantSelectionController: TenantSelectionController(
          authController: authController,
          appState: appState,
        ),
        publicIntakeService:
            publicIntakeService ?? const UnsupportedPublicIntakeService(),
        demoModeController: DemoModeController(
          appState: appState,
          preferenceStore: demoPreferenceStore,
          demoRepositoryFactory: _openDemoRepository,
          exitRepositoryFactory: () async =>
              regularRepository ??
              await _openRegularLocalRepository(tenantContext),
          initiallyActive: restoredDemoRepository != null,
          initialDemoRepository: restoredDemoRepository,
        ),
      );
    } catch (error) {
      debugPrint(
        'Persistent storage unavailable, running in memory only: $error',
      );
      return AppDependencies.local(authController: authController);
    }
  }

  /// Wires the app against the local in-memory repository — used by tests,
  /// as demo fallback, and whenever persistent storage is unavailable.
  factory AppDependencies.local({AuthController? authController}) {
    final controller = authController ?? AuthController.local();
    final tenantContext =
        controller.tenantContext ?? const TenantContext.local();
    final workspaceRepository = LocalWorkspaceRepository(
      tenantContext: tenantContext,
    );
    final appState = AppState(workspaceRepository: workspaceRepository);
    return AppDependencies._(
      tenantContext: tenantContext,
      authController: controller,
      workspaceRepository: workspaceRepository,
      appState: appState,
      onboardingController: OnboardingController(
        authController: controller,
        onboardingService: const TenantOnboardingService(
          dataSource: UnsupportedTenantOnboardingDataSource(),
        ),
      ),
      tenantSelectionController: TenantSelectionController(
        authController: controller,
        appState: appState,
      ),
      publicIntakeService: const UnsupportedPublicIntakeService(),
      demoModeController: DemoModeController(
        appState: appState,
        preferenceStore: MemoryDemoPreferenceStore(),
        demoRepositoryFactory: () async =>
            LocalWorkspaceRepository(tenantContext: tenantContext),
        exitRepositoryFactory: () async => workspaceRepository,
      ),
    );
  }

  static TenantContext _fallbackTenant(AuthController authController) {
    final user = authController.user;
    if (user == null) return const TenantContext.local();
    return TenantContext(tenantId: '', userId: user.id, role: 'viewer');
  }

  static Future<_RepositoryResult> _remoteOrEmptyRepository({
    required AuthController authController,
    required RemoteWorkspaceDataSource? remoteDataSource,
  }) async {
    final tenantContext = authController.tenantContext;
    if (authController.status == AuthStatus.onboardingRequired) {
      return _RepositoryResult(
        repository: EmptyWorkspaceRepository(
          tenantContext: tenantContext ?? _fallbackTenant(authController),
        ),
        status: WorkspaceLoadStatus.onboardingRequired,
      );
    }
    if (authController.status == AuthStatus.tenantSelectionRequired ||
        authController.status == AuthStatus.switchingTenant) {
      return _RepositoryResult(
        repository: EmptyWorkspaceRepository(
          tenantContext: tenantContext ?? _fallbackTenant(authController),
        ),
        status: WorkspaceLoadStatus.empty,
      );
    }
    if (authController.status != AuthStatus.authenticated ||
        tenantContext == null ||
        remoteDataSource == null) {
      return _RepositoryResult(
        repository: EmptyWorkspaceRepository(
          tenantContext: tenantContext ?? _fallbackTenant(authController),
        ),
        status: WorkspaceLoadStatus.empty,
      );
    }

    try {
      final repository = await RemoteWorkspaceRepository.open(
        tenantContext: tenantContext,
        dataSource: remoteDataSource,
      );
      return _RepositoryResult(
        repository: repository,
        status: repository.companies.isEmpty
            ? WorkspaceLoadStatus.empty
            : WorkspaceLoadStatus.loaded,
      );
    } catch (error) {
      debugPrint('Remote workspace load failed: $error');
      return _RepositoryResult(
        repository: EmptyWorkspaceRepository(tenantContext: tenantContext),
        status: WorkspaceLoadStatus.error,
        error: 'Workspace data could not be loaded.',
      );
    }
  }

  void _attachAuthRepositoryBridge(
    RemoteWorkspaceDataSource? remoteDataSource,
  ) {
    var activeTenantId = appState.hasWorkspaces
        ? workspaceRepository.tenantContext.tenantId
        : null;
    var loading = false;
    var bridgeGeneration = 0;

    authController.addListener(() async {
      if (!authController.isSupabaseMode) return;
      // A running demo owns the repository; auth changes must not clobber it.
      if (demoModeController.isActive) return;
      final status = authController.status;

      if (status == AuthStatus.unauthenticated ||
          status == AuthStatus.onboardingRequired ||
          status == AuthStatus.tenantSelectionRequired ||
          status == AuthStatus.switchingTenant) {
        bridgeGeneration++;
        activeTenantId = null;
        appState.replaceWorkspaceRepository(
          EmptyWorkspaceRepository(
            tenantContext:
                authController.tenantContext ?? _fallbackTenant(authController),
          ),
          status: status == AuthStatus.onboardingRequired
              ? WorkspaceLoadStatus.onboardingRequired
              : status == AuthStatus.switchingTenant
              ? WorkspaceLoadStatus.loading
              : WorkspaceLoadStatus.empty,
        );
        return;
      }

      final tenantContext = authController.tenantContext;
      if (status != AuthStatus.authenticated ||
          tenantContext == null ||
          remoteDataSource == null ||
          loading ||
          activeTenantId == tenantContext.tenantId) {
        return;
      }

      final generation = ++bridgeGeneration;
      loading = true;
      activeTenantId = tenantContext.tenantId;
      appState.markWorkspaceLoading();
      final result = await _remoteOrEmptyRepository(
        authController: authController,
        remoteDataSource: remoteDataSource,
      );
      if (generation != bridgeGeneration) {
        loading = false;
        return;
      }
      appState.replaceWorkspaceRepository(
        result.repository,
        status: result.status,
        error: result.error,
      );
      loading = false;
    });
  }

  /// Restores the demo repository when the persisted demo flag is set.
  static Future<WorkspaceRepository?> _restoreDemoRepository(
    DemoPreferenceStore store,
  ) async {
    if (!await store.readActive()) return null;
    try {
      return await _openDemoRepository();
    } catch (error) {
      debugPrint('Demo mode could not be restored: $error');
      await store.saveActive(false);
      return null;
    }
  }

  /// The demo runs on its own IndexedDB database (seeded with the showcase
  /// mock data), falling back to in-memory — never on production storage.
  static Future<WorkspaceRepository> _openDemoRepository() async {
    final databaseFactory = defaultPersistenceDatabaseFactory;
    if (databaseFactory != null) {
      try {
        return await PersistentWorkspaceRepository.open(
          databaseFactory: databaseFactory,
          dbName: demoDatabaseName,
        );
      } catch (error) {
        debugPrint('Demo storage unavailable, using in-memory demo: $error');
      }
    }
    return LocalWorkspaceRepository();
  }

  static Future<WorkspaceRepository> _openRegularLocalRepository(
    TenantContext tenantContext,
  ) async {
    final databaseFactory = defaultPersistenceDatabaseFactory;
    if (databaseFactory != null) {
      try {
        return await PersistentWorkspaceRepository.open(
          databaseFactory: databaseFactory,
          tenantContext: tenantContext,
        );
      } catch (error) {
        debugPrint('Persistent storage unavailable after demo exit: $error');
      }
    }
    return LocalWorkspaceRepository(tenantContext: tenantContext);
  }

  static Future<AuthController> _createAuthController() async {
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabasePublishableKey = String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
    );

    if (supabaseUrl.trim().isEmpty || supabasePublishableKey.trim().isEmpty) {
      final controller = AuthController(LocalAuthService());
      await controller.initialize();
      return controller;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl.trim(),
        publishableKey: supabasePublishableKey.trim(),
      );
      final controller = AuthController(
        SupabaseAuthService(Supabase.instance.client),
        tenantPreferenceStore: createTenantPreferenceStore(),
      );
      await controller.initialize();
      return controller;
    } catch (error) {
      debugPrint(
        'Supabase initialization failed, running in local mode: $error',
      );
      final controller = AuthController(LocalAuthService());
      await controller.initialize();
      return controller;
    }
  }

  final TenantContext tenantContext;
  final AuthController authController;
  final WorkspaceRepository workspaceRepository;
  final AppState appState;
  final OnboardingController onboardingController;
  final TenantSelectionController tenantSelectionController;
  final PublicIntakeService publicIntakeService;
  final DemoModeController demoModeController;
}

class _RepositoryResult {
  const _RepositoryResult({
    required this.repository,
    required this.status,
    this.error,
  });

  final WorkspaceRepository repository;
  final WorkspaceLoadStatus status;
  final String? error;
}
