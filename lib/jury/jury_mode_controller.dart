import 'package:flutter/widgets.dart';

/// Presentation-only Jury Mode flag (BLOCK 9). When active, the app shell shows
/// a simplified navigation (five main areas + "Weitere Module"). No feature is
/// removed and no business logic changes — this only reorganises the
/// information architecture for jury/investor viewing. Default: inactive.
class JuryModeController extends ChangeNotifier {
  bool _active = false;

  bool get active => _active;

  void enable() {
    if (_active) return;
    _active = true;
    notifyListeners();
  }

  void disable() {
    if (!_active) return;
    _active = false;
    notifyListeners();
  }

  static JuryModeController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<JuryModeScope>()!.notifier!;

  static JuryModeController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<JuryModeScope>()?.notifier;
}

class JuryModeScope extends InheritedNotifier<JuryModeController> {
  const JuryModeScope({
    super.key,
    required super.notifier,
    required super.child,
  });
}
