/// Persists whether the competition demo mode is active, so a browser
/// refresh does not break a running demo. No credentials, no secrets —
/// just a boolean flag.
abstract class DemoPreferenceStore {
  Future<bool> readActive();
  Future<void> saveActive(bool active);
}

class MemoryDemoPreferenceStore implements DemoPreferenceStore {
  MemoryDemoPreferenceStore({bool active = false}) : _active = active;

  bool _active;

  @override
  Future<bool> readActive() async => _active;

  @override
  Future<void> saveActive(bool active) async {
    _active = active;
  }
}
