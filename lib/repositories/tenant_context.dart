/// Identifies on whose behalf repository operations run.
///
/// Today there is no login, so the app always operates as the single
/// [TenantContext.local] context. Once auth exists, the composition root
/// ([AppDependencies]) creates one context per signed-in user/tenant and
/// hands it to every repository — no repository or UI code changes needed.
class TenantContext {
  const TenantContext({required this.tenantId, required this.userId});

  /// The single implicit tenant used while the app runs without auth.
  const TenantContext.local() : this(tenantId: 'local', userId: 'local-user');

  /// Which tenant's data a repository is scoped to. A future cloud
  /// implementation uses this for data isolation (e.g. row-level security).
  final String tenantId;

  /// The acting user, for future authorization and audit trails.
  final String userId;

  bool get isLocal => tenantId == 'local';
}
