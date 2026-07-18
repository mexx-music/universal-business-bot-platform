abstract class TenantPreferenceStore {
  Future<String?> readLastTenantId(String userId);
  Future<void> saveLastTenantId(String userId, String tenantId);
}

class MemoryTenantPreferenceStore implements TenantPreferenceStore {
  MemoryTenantPreferenceStore([Map<String, String>? values])
    : _values = values ?? <String, String>{};

  final Map<String, String> _values;

  @override
  Future<String?> readLastTenantId(String userId) async {
    return _values[_key(userId)];
  }

  @override
  Future<void> saveLastTenantId(String userId, String tenantId) async {
    _values[_key(userId)] = tenantId;
  }

  String _key(String userId) => 'lastTenant:$userId';
}
