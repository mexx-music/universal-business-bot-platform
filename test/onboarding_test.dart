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
import 'package:universalbusiness/onboarding/onboarding_controller.dart';
import 'package:universalbusiness/onboarding/tenant_onboarding_data_source.dart';
import 'package:universalbusiness/onboarding/tenant_onboarding_models.dart';
import 'package:universalbusiness/onboarding/tenant_onboarding_service.dart';
import 'package:universalbusiness/repositories/remote_workspace_data_source.dart';
import 'package:universalbusiness/repositories/tenant_context.dart';

void main() {
  test(
    'TenantOnboardingService normalisiert Input und sendet keine Systemfelder',
    () async {
      final dataSource = _CapturingOnboardingDataSource();
      final service = TenantOnboardingService(dataSource: dataSource);

      final result = await service.createInitialWorkspace(
        const TenantOnboardingInput(
          companyName: '  Neue Firma  ',
          website: 'www.neue-firma.test',
          industry: ' Beratung ',
          shortDescription: ' Kurz ',
          primaryLanguage: 'DE',
        ),
      );

      expect(result.tenantId, 'tenant-new');
      expect(dataSource.lastInput.companyName, 'Neue Firma');
      expect(dataSource.lastInput.website, 'https://www.neue-firma.test');
      expect(dataSource.lastInput.primaryLanguage, 'de');
    },
  );

  test('TenantOnboardingService validiert fachliche Eingaben', () async {
    final service = TenantOnboardingService(
      dataSource: _CapturingOnboardingDataSource(),
    );

    expect(
      () => service.createInitialWorkspace(
        const TenantOnboardingInput(companyName: '!'),
      ),
      throwsA(isA<OnboardingValidationException>()),
    );
    expect(
      () => service.createInitialWorkspace(
        const TenantOnboardingInput(
          companyName: 'Valid Company',
          website: 'javascript:alert(1)',
        ),
      ),
      throwsA(isA<OnboardingValidationException>()),
    );
    expect(
      () => service.createInitialWorkspace(
        const TenantOnboardingInput(
          companyName: 'Valid Company',
          primaryLanguage: 'fr',
        ),
      ),
      throwsA(isA<OnboardingValidationException>()),
    );
  });

  test(
    'OnboardingController verhindert Mehrfach-Submit und refreshed Tenant',
    () async {
      final authService = _MutableAuthService(restoredSession: _session);
      final auth = AuthController(authService);
      await auth.initialize();
      final dataSource = _DelayedOnboardingDataSource(
        onCreate: () => authService.tenantContext = _tenant,
      );
      final controller = OnboardingController(
        authController: auth,
        onboardingService: TenantOnboardingService(dataSource: dataSource),
      );

      final first = controller.submit(
        const TenantOnboardingInput(companyName: 'Neue Firma'),
      );
      final second = await controller.submit(
        const TenantOnboardingInput(companyName: 'Neue Firma'),
      );
      expect(second, isFalse);

      final success = await first;
      expect(success, isTrue);
      expect(dataSource.calls, 1);
      expect(auth.status, AuthStatus.authenticated);
      expect(controller.status, TenantOnboardingStatus.success);
    },
  );

  test('OnboardingController behält Formdaten bei Fehler', () async {
    final auth = AuthController(_MutableAuthService(restoredSession: _session));
    await auth.initialize();
    final controller = OnboardingController(
      authController: auth,
      onboardingService: TenantOnboardingService(
        dataSource: _FailingOnboardingDataSource(),
      ),
    );
    const input = TenantOnboardingInput(companyName: 'Fehler Firma');

    final success = await controller.submit(input);

    expect(success, isFalse);
    expect(controller.input.companyName, input.companyName);
    expect(controller.status, TenantOnboardingStatus.error);
    expect(controller.errorCode, 'remote_error');
  });

  testWidgets('Router schickt Nutzer ohne Membership zu /onboarding', (
    tester,
  ) async {
    await _setDesktopViewport(tester);
    final dependencies = await _dependencies(
      authService: _MutableAuthService(restoredSession: _session),
    );

    await tester.pumpWidget(UniversalBusinessApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(find.text('Ersten Workspace einrichten'), findsOneWidget);
    expect(dependencies.appState.companies, isEmpty);
  });

  testWidgets('Onboarding-Formular validiert Pflichtfeld und Website', (
    tester,
  ) async {
    await _setDesktopViewport(tester);
    final dependencies = await _dependencies(
      authService: _MutableAuthService(restoredSession: _session),
    );
    await tester.pumpWidget(UniversalBusinessApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    final submitButton = find.widgetWithText(
      FilledButton,
      'Workspace erstellen',
    );
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Bitte geben Sie den Firmennamen ein.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Neue Firma');
    await tester.enterText(find.byType(TextFormField).at(1), 'javascript:bad');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Bitte geben Sie eine gültige HTTPS-Website oder Domain ein.'),
      findsOneWidget,
    );
  });

  testWidgets('Onboarding-Erfolg lädt Remote-Workspace und navigiert weiter', (
    tester,
  ) async {
    await _setDesktopViewport(tester);
    final authService = _MutableAuthService(restoredSession: _session);
    final onboardingDataSource = _CapturingOnboardingDataSource(
      onCreate: () => authService.tenantContext = _tenant,
    );
    final dependencies = await _dependencies(
      authService: authService,
      onboardingDataSource: onboardingDataSource,
    );

    await tester.pumpWidget(UniversalBusinessApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Neue Firma');
    final submitButton = find.widgetWithText(
      FilledButton,
      'Workspace erstellen',
    );
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(authService.tenantContext, isNotNull);
    expect(dependencies.appState.hasWorkspaces, isTrue);
    expect(find.text('Dashboard'), findsWidgets);
  });
}

const _user = AuthUser(
  id: 'user-new',
  email: 'new@example.test',
  emailVerified: true,
);
const _session = AuthSession(user: _user);
const _tenant = TenantContext(
  tenantId: 'tenant-new',
  userId: 'user-new',
  role: 'owner',
);

Future<void> _setDesktopViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1800, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<AppDependencies> _dependencies({
  required _MutableAuthService authService,
  TenantOnboardingDataSource? onboardingDataSource,
}) async {
  final auth = AuthController(authService);
  await auth.initialize();
  return AppDependencies.createWithAuthController(
    authController: auth,
    remoteDataSource: _OnboardingRemoteDataSource(),
    onboardingService: TenantOnboardingService(
      dataSource: onboardingDataSource ?? _CapturingOnboardingDataSource(),
    ),
  );
}

class _MutableAuthService implements AuthService {
  _MutableAuthService({this.restoredSession});

  final AuthSession? restoredSession;
  TenantContext? tenantContext;
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
    return AuthOperationResult(
      session: restoredSession,
      user: restoredSession?.user,
    );
  }

  @override
  Future<AuthOperationResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _controller.add(restoredSession);
    return AuthOperationResult(
      session: restoredSession,
      user: restoredSession?.user,
    );
  }

  @override
  Future<void> signOut() async {
    _controller.add(null);
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> updatePassword(String password) async {}

  @override
  Future<List<TenantMembership>> loadTenantMemberships(AuthUser user) async {
    final context = tenantContext;
    if (context == null) return const [];
    return [
      TenantMembership(
        membershipId: context.membershipId ?? '${context.tenantId}:${user.id}',
        tenantId: context.tenantId,
        tenantName: context.tenantName ?? 'Neue Firma',
        role: context.role,
      ),
    ];
  }

  @override
  Future<TenantContext?> resolveTenantContext(AuthUser user) async {
    return tenantContext;
  }
}

class _CapturingOnboardingDataSource implements TenantOnboardingDataSource {
  _CapturingOnboardingDataSource({this.onCreate});

  final VoidCallback? onCreate;
  late TenantOnboardingInput lastInput;

  @override
  Future<Map<String, Object?>> createInitialWorkspace(
    TenantOnboardingInput input,
  ) async {
    lastInput = input;
    onCreate?.call();
    return const {
      'tenant_id': 'tenant-new',
      'workspace_id': 'workspace-new',
      'company_id': 'neue-firma',
    };
  }
}

class _DelayedOnboardingDataSource extends _CapturingOnboardingDataSource {
  _DelayedOnboardingDataSource({super.onCreate});

  int calls = 0;

  @override
  Future<Map<String, Object?>> createInitialWorkspace(
    TenantOnboardingInput input,
  ) async {
    calls++;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return super.createInitialWorkspace(input);
  }
}

class _FailingOnboardingDataSource implements TenantOnboardingDataSource {
  @override
  Future<Map<String, Object?>> createInitialWorkspace(
    TenantOnboardingInput input,
  ) async {
    throw const OnboardingRemoteException('Expected failure');
  }
}

class _OnboardingRemoteDataSource implements RemoteWorkspaceDataSource {
  @override
  Future<RemoteWorkspaceSnapshotRows> loadWorkspaceRows(String tenantId) async {
    expect(tenantId, 'tenant-new');
    return const RemoteWorkspaceSnapshotRows(
      workspaces: [
        {
          'id': 'workspace-new',
          'tenant_id': 'tenant-new',
          'name': 'Neue Firma',
        },
      ],
      companies: [
        {
          'workspace_id': 'workspace-new',
          'tenant_id': 'tenant-new',
          'id': 'neue-firma',
          'company_name': 'Neue Firma',
          'short_description': '',
          'industry': '',
          'country': '',
          'primary_language': 'de',
          'website': '',
          'support_email': '',
          'social_links': <String, Object?>{},
          'business_rules': <String, Object?>{},
          'bot_configuration': {'status': 'draft', 'defaultLanguage': 'de'},
          'internal_notes': '',
        },
      ],
      products: [],
      knowledgeEntries: [],
      sourceMaterials: [],
      botQuestionLogs: [],
      auditItems: [],
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
