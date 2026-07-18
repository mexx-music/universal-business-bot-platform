import 'dart:async';

import '../repositories/tenant_context.dart';
import 'auth_operation_result.dart';
import 'auth_session.dart';
import 'tenant_membership.dart';
import 'auth_user.dart';

abstract class AuthService {
  bool get isLocal;
  AuthSession? get currentSession;
  AuthUser? get currentUser;
  Stream<AuthSession?> get authStateChanges;

  Future<AuthSession?> restoreSession();
  Future<AuthOperationResult> signUp({
    required String email,
    required String password,
    String? displayName,
  });
  Future<AuthOperationResult> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> updatePassword(String password);

  Future<List<TenantMembership>> loadTenantMemberships(AuthUser user) async {
    final context = await resolveTenantContext(user);
    if (context == null) return const [];
    return [
      TenantMembership(
        membershipId:
            context.membershipId ?? '${context.tenantId}:${context.userId}',
        tenantId: context.tenantId,
        tenantName: context.tenantName ?? 'Company',
        role: context.role,
        workspaceId: context.workspaceId,
        workspaceName: context.workspaceName,
      ),
    ];
  }

  Future<TenantContext?> resolveTenantContext(AuthUser user);
}
