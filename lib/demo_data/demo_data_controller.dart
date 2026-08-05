import 'package:flutter/widgets.dart';

/// Central demo switch (BLOCK 9). A single source of truth for whether the app
/// presents demo data (Operations Dashboard figures, DEMO badges, …). Existing
/// demo data is unchanged — this only centralises the on/off state so demo vs.
/// live can be toggled in one place instead of per screen. Default: demo on.
///
/// No new logic: screens read [enabled] and keep using their existing demo data.
class DemoDataController extends ChangeNotifier {
  DemoDataController({bool enabled = true}) : _enabled = enabled;

  bool _enabled;

  bool get enabled => _enabled;

  void setEnabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();
  }

  void toggle() => setEnabled(!_enabled);

  static DemoDataController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DemoDataScope>()?.notifier;

  /// True unless a scope explicitly disables demo mode (backward compatible:
  /// screens rendered without the scope keep showing demo data).
  static bool enabledOf(BuildContext context) =>
      maybeOf(context)?.enabled ?? true;
}

class DemoDataScope extends InheritedNotifier<DemoDataController> {
  const DemoDataScope({
    super.key,
    required super.notifier,
    required super.child,
  });
}
