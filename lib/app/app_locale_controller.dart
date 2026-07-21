import 'package:flutter/material.dart';

import 'app_locale_preference_store.dart';

class AppLocaleController extends ChangeNotifier {
  static const Locale fallbackLocale = Locale('de');
  static const Set<String> supportedLanguageCodes = {'de', 'en'};

  final AppLocalePreferenceStore _preferenceStore;
  Locale _locale;
  bool _disposed = false;

  AppLocaleController({
    AppLocalePreferenceStore? preferenceStore,
    Locale initialLocale = fallbackLocale,
  }) : _preferenceStore = preferenceStore ?? createAppLocalePreferenceStore(),
       _locale = _normalizeLocale(initialLocale);

  Locale get locale => _locale;

  Future<void> restore() async {
    final storedCode = await _readStoredLocaleCode();
    if (storedCode == null) return;
    await setLocaleCode(storedCode, persist: false);
  }

  Future<void> setLocaleCode(String languageCode, {bool persist = true}) async {
    if (_disposed) return;
    if (!supportedLanguageCodes.contains(languageCode)) return;
    final next = Locale(languageCode);
    if (_locale.languageCode == next.languageCode) return;
    _locale = next;
    notifyListeners();
    if (persist) {
      await _saveLocaleCode(languageCode);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<String?> _readStoredLocaleCode() async {
    try {
      return await _preferenceStore.readLocaleCode();
    } catch (error) {
      debugPrint('Locale preference could not be read: $error');
      return null;
    }
  }

  Future<void> _saveLocaleCode(String languageCode) async {
    try {
      await _preferenceStore.saveLocaleCode(languageCode);
    } catch (error) {
      debugPrint('Locale preference could not be saved: $error');
    }
  }

  static Locale _normalizeLocale(Locale locale) {
    return supportedLanguageCodes.contains(locale.languageCode)
        ? Locale(locale.languageCode)
        : fallbackLocale;
  }
}

class AppLocaleScope extends InheritedNotifier<AppLocaleController> {
  const AppLocaleScope({
    super.key,
    required AppLocaleController notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppLocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope?.notifier != null, 'No AppLocaleScope found in context.');
    return scope!.notifier!;
  }

  static AppLocaleController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppLocaleScope>()
        ?.notifier;
  }
}
