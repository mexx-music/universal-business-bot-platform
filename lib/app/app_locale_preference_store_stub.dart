import 'app_locale_preference_store_base.dart';

class NoopAppLocalePreferenceStore implements AppLocalePreferenceStore {
  const NoopAppLocalePreferenceStore();

  @override
  Future<String?> readLocaleCode() async => null;

  @override
  Future<void> saveLocaleCode(String code) async {}
}

AppLocalePreferenceStore createAppLocalePreferenceStore() {
  return const NoopAppLocalePreferenceStore();
}
