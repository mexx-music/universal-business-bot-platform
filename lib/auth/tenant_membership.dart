import '../repositories/tenant_context.dart';
import 'auth_user.dart';

class TenantMembership {
  const TenantMembership({
    required this.membershipId,
    required this.tenantId,
    required this.tenantName,
    required this.role,
    this.isActive = true,
    this.tenantSlug,
    this.workspaceCount,
    this.workspaceId,
    this.workspaceName,
    this.updatedAt,
  });

  final String membershipId;
  final String tenantId;
  final String tenantName;
  final String role;
  final bool isActive;
  final String? tenantSlug;
  final int? workspaceCount;
  final String? workspaceId;
  final String? workspaceName;
  final DateTime? updatedAt;

  TenantContext toTenantContext(AuthUser user) {
    return TenantContext(
      tenantId: tenantId,
      userId: user.id,
      role: role,
      membershipId: membershipId,
      tenantName: tenantName,
      workspaceId: workspaceId,
      workspaceName: workspaceName,
    );
  }

  static TenantMembership? fromJson(Map<String, dynamic> json) {
    final tenantId = _string(json['tenant_id']);
    final role = _normalizeRole(_string(json['role']));
    if (tenantId == null || role == null) return null;

    final userId = _string(json['user_id']);
    final membershipId =
        _string(json['membership_id']) ??
        (userId == null ? tenantId : '$tenantId:$userId');
    final tenantName = _string(json['tenant_name']) ?? 'Company';
    final status = _string(json['membership_status']) ?? 'active';
    final updated = _string(json['membership_updated_at']);

    return TenantMembership(
      membershipId: membershipId,
      tenantId: tenantId,
      tenantName: tenantName,
      role: role,
      isActive: status == 'active',
      tenantSlug: _string(json['tenant_slug']),
      workspaceCount: _int(json['workspace_count']),
      workspaceId: _string(json['primary_workspace_id']),
      workspaceName: _string(json['primary_workspace_name']),
      updatedAt: updated == null ? null : DateTime.tryParse(updated),
    );
  }

  static String? _string(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static String? _normalizeRole(String? value) {
    return switch (value) {
      'owner' || 'admin' || 'editor' || 'reviewer' || 'viewer' => value,
      _ => null,
    };
  }
}
