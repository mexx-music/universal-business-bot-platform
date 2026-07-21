import 'package:web/web.dart' as web;

import 'app_locale_preference_store_base.dart';

class WebAppLocalePreferenceStore implements AppLocalePreferenceStore {
  static const _key = 'universalbusiness_locale';

  const WebAppLocalePreferenceStore();

  @override
  Future<String?> readLocaleCode() async {
    return web.window.localStorage.getItem(_key);
  }

  @override
  Future<void> saveLocaleCode(String code) async {
    web.window.localStorage.setItem(_key, code);
  }
}

AppLocalePreferenceStore createAppLocalePreferenceStore() {
  return const WebAppLocalePreferenceStore();
}
