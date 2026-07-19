import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/app/app_dependencies.dart';
import 'package:universalbusiness/auth/auth_controller.dart';
import 'package:universalbusiness/auth/auth_form_validators.dart';
import 'package:universalbusiness/auth/auth_operation_result.dart';
import 'package:universalbusiness/auth/auth_service.dart';
import 'package:universalbusiness/auth/auth_session.dart';
import 'package:universalbusiness/auth/auth_status.dart';
import 'package:universalbusiness/auth/auth_user.dart';
import 'package:universalbusiness/auth/local_auth_service.dart';
import 'package:universalbusiness/auth/tenant_membership.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/repositories/tenant_context.dart';
import 'package:universalbusiness/router/app_router.dart';

void main() {
  test('LocalAuthService restores local demo session', () async {
    final service = LocalAuthService();
    final session = await service.restoreSession();
    final tenant = await service.resolveTenantContext(session!.user);

    expect(service.isLocal, isTrue);
    expect(session.user.id, 'local-user');
    expect(tenant, isNotNull);
    expect(tenant!.isLocal, isTrue);
  });

  test('AuthController starts in local mode without Supabase config', () async {
    final controller = AuthController(LocalAuthService());
    await controller.initialize();

    expect(controller.status, AuthStatus.local);
    expect(controller.canOpenProtectedRoutes, isTrue);
    expect(controller.tenantContext!.isLocal, isTrue);
  });

  test(
    'AuthController restores authenticated session and tenant context',
    () async {
      final service = _FakeAuthService(
        restoredSession: _session,
        tenantContext: const TenantContext(
          tenantId: 'tenant-a',
          userId: 'user-a',
          role: 'editor',
        ),
      );
      final controller = AuthController(service);
      await controller.initialize();

      expect(controller.status, AuthStatus.authenticated);
      expect(controller.user!.email, 'user@example.test');
      expect(controller.tenantContext!.tenantId, 'tenant-a');
      expect(controller.tenantContext!.role, 'editor');
    },
  );

  test(
    'AuthController marks signed-in users without tenant as onboarding',
    () async {
      final controller = AuthController(
        _FakeAuthService(restoredSession: _session),
      );
      await controller.initialize();

      expect(controller.status, AuthStatus.onboardingRequired);
      expect(controller.canOpenProtectedRoutes, isFalse);
    },
  );

  test('AuthController handles sign-in and logout', () async {
    final service = _FakeAuthService(
      signInResult: AuthOperationResult(session: _session, user: _user),
      tenantContext: const TenantContext(
        tenantId: 'tenant-a',
        userId: 'user-a',
        role: 'owner',
      ),
    );
    final controller = AuthController(service);
    await controller.initialize();
    await controller.signIn(email: 'user@example.test', password: 'secret1');

    expect(controller.status, AuthStatus.authenticated);

    await controller.signOut();
    expect(controller.status, AuthStatus.unauthenticated);
  });

  test('AuthController forwards sign-up errors to the UI', () async {
    final controller = AuthController(
      _FakeAuthService(signUpError: Exception('Email address not authorized')),
    );
    await controller.initialize();

    await expectLater(
      controller.signUp(email: 'blocked@example.test', password: 'secret1'),
      throwsA(isA<Exception>()),
    );

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.errorMessage, 'Email address not authorized');
  });

  test('Login validation accepts only email and six-character passwords', () {
    expect(AuthFormValidators.isValidEmail('person@example.com'), isTrue);
    expect(AuthFormValidators.isValidEmail('person'), isFalse);
    expect(AuthFormValidators.isValidPassword('123456'), isTrue);
    expect(AuthFormValidators.isValidPassword('12345'), isFalse);
  });

  testWidgets('Router guard sends unauthenticated Supabase users to login', (
    tester,
  ) async {
    final authController = AuthController(_FakeAuthService());
    await authController.initialize();
    final dependencies = AppDependencies.local(authController: authController);
    final router = createAppRouter(authController);

    await tester.pumpWidget(
      AuthScope(
        notifier: authController,
        child: AppStateScope(
          notifier: dependencies.appState,
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('de'),
            routerConfig: router,
          ),
        ),
      ),
    );

    router.go('/dashboard');
    await tester.pumpAndSettle();

    expect(find.text('Anmelden'), findsWidgets);
  });
}

const _user = AuthUser(
  id: 'user-a',
  email: 'user@example.test',
  emailVerified: true,
);

const _session = AuthSession(user: _user);

class _FakeAuthService implements AuthService {
  _FakeAuthService({
    this.restoredSession,
    this.signInResult,
    this.signUpError,
    this.tenantContext,
  });

  final AuthSession? restoredSession;
  final AuthOperationResult? signInResult;
  final Object? signUpError;
  final TenantContext? tenantContext;
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
    final result =
        signInResult ??
        const AuthOperationResult(session: _session, user: _user);
    _controller.add(result.session);
    return result;
  }

  @override
  Future<AuthOperationResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final error = signUpError;
    if (error != null) throw error;
    return const AuthOperationResult(user: _user);
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
        tenantName: context.tenantName ?? 'Test Tenant',
        role: context.role,
      ),
    ];
  }

  @override
  Future<TenantContext?> resolveTenantContext(AuthUser user) async {
    return tenantContext;
  }
}
