import 'dart:async';

import '../repositories/tenant_context.dart';
import 'auth_operation_result.dart';
import 'auth_service.dart';
import 'auth_session.dart';
import 'tenant_membership.dart';
import 'auth_user.dart';

class LocalAuthService implements AuthService {
  LocalAuthService()
    : _session = const AuthSession(
        user: AuthUser(
          id: 'local-user',
          email: 'local@universalbusiness.local',
          displayName: 'Lokaler Modus',
          emailVerified: true,
        ),
      );

  final AuthSession _session;
  final StreamController<AuthSession?> _controller =
      StreamController<AuthSession?>.broadcast();

  @override
  bool get isLocal => true;

  @override
  AuthSession? get currentSession => _session;

  @override
  AuthUser? get currentUser => _session.user;

  @override
  Stream<AuthSession?> get authStateChanges => _controller.stream;

  @override
  Future<AuthSession?> restoreSession() async => _session;

  @override
  Future<AuthOperationResult> signIn({
    required String email,
    required String password,
  }) async {
    _controller.add(_session);
    return AuthOperationResult(session: _session, user: _session.user);
  }

  @override
  Future<AuthOperationResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _controller.add(_session);
    return AuthOperationResult(session: _session, user: _session.user);
  }

  @override
  Future<void> signOut() async {
    _controller.add(_session);
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> updatePassword(String password) async {}

  @override
  Future<List<TenantMembership>> loadTenantMemberships(AuthUser user) async {
    return const [
      TenantMembership(
        membershipId: 'local:local-user',
        tenantId: 'local',
        tenantName: 'Lokaler Modus',
        role: 'owner',
      ),
    ];
  }

  @override
  Future<TenantContext?> resolveTenantContext(AuthUser user) async {
    return const TenantContext.local();
  }
}
