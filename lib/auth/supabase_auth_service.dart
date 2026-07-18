import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../repositories/tenant_context.dart';
import 'auth_operation_result.dart';
import 'auth_service.dart';
import 'auth_session.dart';
import 'tenant_membership.dart';
import 'auth_user.dart';

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client);

  final sb.SupabaseClient _client;

  @override
  bool get isLocal => false;

  @override
  AuthSession? get currentSession => _mapSession(_client.auth.currentSession);

  @override
  AuthUser? get currentUser => _mapUser(_client.auth.currentUser);

  @override
  Stream<AuthSession?> get authStateChanges {
    return _client.auth.onAuthStateChange.map(
      (event) => _mapSession(event.session),
    );
  }

  @override
  Future<AuthSession?> restoreSession() async {
    return currentSession;
  }

  @override
  Future<AuthOperationResult> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return AuthOperationResult(
      session: _mapSession(response.session),
      user: _mapUser(response.user),
    );
  }

  @override
  Future<AuthOperationResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        if (displayName != null && displayName.trim().isNotEmpty)
          'display_name': displayName.trim(),
      },
    );
    return AuthOperationResult(
      session: _mapSession(response.session),
      user: _mapUser(response.user),
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<void> resetPassword(String email) {
    final redirectTo = const String.fromEnvironment('AUTH_REDIRECT_URL');
    return _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: redirectTo.isEmpty ? null : redirectTo,
    );
  }

  @override
  Future<void> updatePassword(String password) {
    return _client.auth.updateUser(sb.UserAttributes(password: password));
  }

  @override
  Future<List<TenantMembership>> loadTenantMemberships(AuthUser user) async {
    final rows = await _client.rpc('active_tenant_memberships');
    final memberships = <TenantMembership>[];
    for (final row in rows) {
      if (row is! Map) continue;
      final membership = TenantMembership.fromJson(
        row.map((key, value) => MapEntry(key.toString(), value)),
      );
      if (membership != null && membership.isActive) {
        memberships.add(membership);
      }
    }
    return memberships;
  }

  @override
  Future<TenantContext?> resolveTenantContext(AuthUser user) async {
    final memberships = await loadTenantMemberships(user);
    if (memberships.length != 1) return null;
    return memberships.single.toTenantContext(user);
  }

  AuthSession? _mapSession(sb.Session? session) {
    if (session == null) return null;
    final user = _mapUser(session.user);
    if (user == null) return null;
    return AuthSession(
      user: user,
      expiresAt: session.expiresAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000),
    );
  }

  AuthUser? _mapUser(sb.User? user) {
    if (user == null) return null;
    final metadataName = user.userMetadata?['display_name'];
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      displayName: metadataName is String ? metadataName : null,
      emailVerified: user.emailConfirmedAt != null,
    );
  }
}
