import 'package:web/web.dart' as web;

import 'tenant_preference_store.dart';

TenantPreferenceStore createPlatformTenantPreferenceStore() {
  return const WebTenantPreferenceStore();
}

class WebTenantPreferenceStore implements TenantPreferenceStore {
  const WebTenantPreferenceStore();

  @override
  Future<String?> readLastTenantId(String userId) async {
    return web.window.localStorage.getItem(_key(userId));
  }

  @override
  Future<void> saveLastTenantId(String userId, String tenantId) async {
    web.window.localStorage.setItem(_key(userId), tenantId);
  }

  String _key(String userId) => 'ubp.lastTenant.$userId';
}
