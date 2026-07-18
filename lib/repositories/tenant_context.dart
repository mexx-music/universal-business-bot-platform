/// Identifies on whose behalf repository operations run.
///
/// Today there is no login, so the app always operates as the single
/// [TenantContext.local] context. Once auth exists, the composition root
/// ([AppDependencies]) creates one context per signed-in user/tenant and
/// hands it to every repository — no repository or UI code changes needed.
class TenantContext {
  const TenantContext({
    required this.tenantId,
    required this.userId,
    this.role = 'owner',
    this.membershipId,
    this.tenantName,
    this.workspaceId,
    this.workspaceName,
  });

  /// The single implicit tenant used while the app runs without auth.
  const TenantContext.local() : this(tenantId: 'local', userId: 'local-user');

  /// Which tenant's data a repository is scoped to. A future cloud
  /// implementation uses this for data isolation (e.g. row-level security).
  final String tenantId;

  /// The acting user, for future authorization and audit trails.
  final String userId;

  /// Role resolved from tenant membership. In local mode the user acts as an
  /// owner of the local demo tenant.
  final String role;

  /// Stable identifier for the active membership if the backend exposes one.
  final String? membershipId;

  /// Human-readable tenant name resolved from the active membership.
  final String? tenantName;

  /// Optional active workspace selected within the tenant.
  final String? workspaceId;

  /// Human-readable workspace name for the active workspace.
  final String? workspaceName;

  bool get isLocal => tenantId == 'local';

  bool get canWriteContent => const {'owner', 'admin', 'editor'}.contains(role);

  bool get canReviewContent =>
      const {'owner', 'admin', 'editor', 'reviewer'}.contains(role);

  bool get canDeleteContent => const {'owner', 'admin'}.contains(role);

  TenantContext copyWith({
    String? tenantId,
    String? userId,
    String? role,
    String? membershipId,
    String? tenantName,
    String? workspaceId,
    String? workspaceName,
  }) {
    return TenantContext(
      tenantId: tenantId ?? this.tenantId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      membershipId: membershipId ?? this.membershipId,
      tenantName: tenantName ?? this.tenantName,
      workspaceId: workspaceId ?? this.workspaceId,
      workspaceName: workspaceName ?? this.workspaceName,
    );
  }
}
