import 'tenant_preference_store_stub.dart'
    if (dart.library.html) 'tenant_preference_store_web.dart';
import 'tenant_preference_store.dart';

TenantPreferenceStore createTenantPreferenceStore() {
  return createPlatformTenantPreferenceStore();
}
