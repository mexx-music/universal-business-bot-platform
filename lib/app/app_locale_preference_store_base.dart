abstract class AppLocalePreferenceStore {
  Future<String?> readLocaleCode();

  Future<void> saveLocaleCode(String code);
}
