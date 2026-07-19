import 'demo_preference_store.dart';
import 'demo_preference_store_stub.dart'
    if (dart.library.html) 'demo_preference_store_web.dart';

DemoPreferenceStore createDemoPreferenceStore() {
  return createPlatformDemoPreferenceStore();
}
