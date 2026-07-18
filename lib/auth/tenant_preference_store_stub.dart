import 'tenant_preference_store.dart';

TenantPreferenceStore createPlatformTenantPreferenceStore() {
  return MemoryTenantPreferenceStore();
}
