import 'package:web/web.dart' as web;

import 'demo_preference_store.dart';

DemoPreferenceStore createPlatformDemoPreferenceStore() {
  return const WebDemoPreferenceStore();
}

class WebDemoPreferenceStore implements DemoPreferenceStore {
  const WebDemoPreferenceStore();

  static const _key = 'ubp.demoMode';

  @override
  Future<bool> readActive() async {
    return web.window.localStorage.getItem(_key) == '1';
  }

  @override
  Future<void> saveActive(bool active) async {
    if (active) {
      web.window.localStorage.setItem(_key, '1');
    } else {
      web.window.localStorage.removeItem(_key);
    }
  }
}
