import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/app/app_dependencies.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';
import 'package:universalbusiness/auth/auth_controller.dart';
import 'package:universalbusiness/auth/auth_operation_result.dart';
import 'package:universalbusiness/auth/auth_service.dart';
import 'package:universalbusiness/auth/auth_session.dart';
import 'package:universalbusiness/auth/auth_status.dart';
import 'package:universalbusiness/auth/auth_user.dart';
import 'package:universalbusiness/auth/tenant_membership.dart';
import 'package:universalbusiness/auth/tenant_preference_store.dart';
import 'package:universalbusiness/repositories/remote_workspace_data_source.dart';
import 'package:universalbusiness/repositories/tenant_context.dart';
import 'package:universalbusiness/tenant_selection/tenant_selection_controller.dart';

void main() {
  test('no active membership requires onboarding', () async {
    final auth = AuthController(
      _MembershipAuthService(restoredSession: _session, memberships: const []),
    );

    await auth.initialize();

    expect(auth.status, AuthStatus.onboardingRequired);
    expect(auth.tenantContext, isNull);
  });

  test('single active membership is selected automatically', () async {
    final auth = AuthController(
      _MembershipAuthService(
        restoredSession: _session,
        memberships: const [_tenantA],
      ),
    );

    await auth.initialize();

    expect(auth.status, AuthStatus.authenticated);
    expect(auth.tenantContext!.tenantId, 'tenant-a');
    expect(auth.tenantContext!.tenantName, 'Tenant A');
  });

  test('multiple memberships without preference require selection', () async {
    final auth = AuthController(
      _MembershipAuthService(
        restoredSession: _session,
        memberships: const [_tenantA, _tenantB],
      ),
    );

    await auth.initialize();

    expect(auth.status, AuthStatus.tenantSelectionRequired);
    expect(auth.tenantContext, isNull);
  });

  test('valid saved tenant preference is restored', () async {
    final preferences = MemoryTenantPreferenceStore();
    await preferences.saveLastTenantId(_user.id, 'tenant-b');
    final auth = AuthController(
      _MembershipAuthService(
        restoredSession: _session,
        memberships: const [_tenantA, _tenantB],
      ),
      tenantPreferenceStore: preferences,
    );

    await auth.initialize();

    expect(auth.status, AuthStatus.authenticated);
    expect(auth.tenantContext!.tenantId, 'tenant-b');
    expect(auth.tenantContext!.role, 'viewer');
  });

  test('invalid saved tenant preference is ignored', () async {
    final preferences = MemoryTenantPreferenceStore();
    await preferences.saveLastTenantId(_user.id, 'tenant-missing');
    final auth = AuthController(
      _MembershipAuthService(
        restoredSession: _session,
        memberships: const [_tenantA, _tenantB],
      ),
      tenantPreferenceStore: preferences,
    );

    await auth.initialize();

    expect(auth.status, AuthStatus.tenantSelectionRequired);
    expect(auth.tenantContext, isNull);
  });

  test('TenantSelectionController selects and stores tenant', () async {
    final preferences = MemoryTenantPreferenceStore();
    final auth = AuthController(
      _MembershipAuthService(
        restoredSession: _session,
        memberships: const [_tenantA, _tenantB],
      ),
      tenantPreferenceStore: preferences,
    );
    await auth.initialize();
    final dependencies = await AppDependencies.createWithAuthController(
      authController: auth,
      remoteDataSource: _RowsByTenantDataSource(),
    );
    final controller = dependencies.tenantSelectionController;

    final selected = await controller.selectTenant('tenant-b');
    await Future<void>.delayed(Duration.zero);

    expect(selected, isTrue);
    expect(controller.status, TenantSelectionStatus.active);
    expect(auth.tenantContext!.tenantId, 'tenant-b');
    expect(await preferences.readLastTenantId(_user.id), 'tenant-b');
    expect(dependencies.appState.hasWorkspaces, isTrue);
    expect(dependencies.appState.selectedCompany.name, 'Tenant B Company');
  });

  testWidgets('router shows tenant selection for multiple memberships', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1100, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthController(
      _MembershipAuthService(
        restoredSession: _session,
        memberships: const [_tenantA, _tenantB],
      ),
    );
    await auth.initialize();
    final dependencies = await AppDependencies.createWithAuthController(
      authController: auth,
      remoteDataSource: _RowsByTenantDataSource(),
    );

    await tester.pumpWidget(UniversalBusinessApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(find.text('Welche Firma möchten Sie öffnen?'), findsOneWidget);
    expect(find.text('Tenant A'), findsOneWidget);
    expect(find.text('Tenant B'), findsOneWidget);
  });
}

const _user = AuthUser(
  id: 'user-a',
  email: 'user@example.test',
  emailVerified: true,
);
const _session = AuthSession(user: _user);
const _tenantA = TenantMembership(
  membershipId: 'tenant-a:user-a',
  tenantId: 'tenant-a',
  tenantName: 'Tenant A',
  role: 'owner',
  workspaceCount: 1,
  workspaceId: 'workspace-a',
  workspaceName: 'Workspace A',
);
const _tenantB = TenantMembership(
  membershipId: 'tenant-b:user-a',
  tenantId: 'tenant-b',
  tenantName: 'Tenant B',
  role: 'viewer',
  workspaceCount: 1,
  workspaceId: 'workspace-b',
  workspaceName: 'Workspace B',
);

class _MembershipAuthService implements AuthService {
  _MembershipAuthService({
    required this.restoredSession,
    required this.memberships,
  });

  final AuthSession? restoredSession;
  final List<TenantMembership> memberships;
  final StreamController<AuthSession?> _controller =
      StreamController<AuthSession?>.broadcast();

  @override
  bool get isLocal => false;

  @override
  AuthSession? get currentSession => restoredSession;

  @override
  AuthUser? get currentUser => restoredSession?.user;

  @override
  Stream<AuthSession?> get authStateChanges => _controller.stream;

  @override
  Future<AuthSession?> restoreSession() async => restoredSession;

  @override
  Future<AuthOperationResult> signIn({
    required String email,
    required String password,
  }) async {
    _controller.add(restoredSession);
    return AuthOperationResult(session: restoredSession, user: currentUser);
  }

  @override
  Future<AuthOperationResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return const AuthOperationResult(user: _user);
  }

  @override
  Future<void> signOut() async => _controller.add(null);

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> updatePassword(String password) async {}

  @override
  Future<List<TenantMembership>> loadTenantMemberships(AuthUser user) async {
    return memberships;
  }

  @override
  Future<TenantContext?> resolveTenantContext(AuthUser user) async {
    return null;
  }
}

class _RowsByTenantDataSource implements RemoteWorkspaceDataSource {
  @override
  Future<RemoteWorkspaceSnapshotRows> loadWorkspaceRows(String tenantId) async {
    final suffix = tenantId == 'tenant-b' ? 'b' : 'a';
    final title = tenantId == 'tenant-b'
        ? 'Tenant B Company'
        : 'Tenant A Company';
    return RemoteWorkspaceSnapshotRows(
      workspaces: [
        {
          'id': 'workspace-$suffix',
          'tenant_id': tenantId,
          'name': 'Workspace $suffix',
        },
      ],
      companies: [
        {
          'workspace_id': 'workspace-$suffix',
          'tenant_id': tenantId,
          'id': 'company-$suffix',
          'company_name': title,
          'short_description': '',
          'industry': '',
          'country': '',
          'primary_language': 'de',
          'website': '',
          'support_email': '',
          'support_phone': '',
          'social_links': <String, Object?>{},
          'internal_notes': '',
          'business_rules': <String, Object?>{},
          'bot_configuration': <String, Object?>{},
        },
      ],
      products: const [],
      knowledgeEntries: const [],
      sourceMaterials: const [],
      botQuestionLogs: const [],
      auditItems: const [],
    );
  }

  @override
  Future<Map<String, Object?>> insertRow(
    String table,
    Map<String, Object?> payload,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>> updateTenantRow({
    required String table,
    required String tenantId,
    required String workspaceId,
    required String id,
    required Map<String, Object?> payload,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTenantRow({
    required String table,
    required String tenantId,
    required String workspaceId,
    required String id,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>> updateCompanyRow({
    required String tenantId,
    required String workspaceId,
    required Map<String, Object?> payload,
  }) {
    throw UnimplementedError();
  }
}
