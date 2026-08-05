import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/demo_data/demo_data_controller.dart';
import 'package:universalbusiness/jury/jury_mode_controller.dart';

void main() {
  group('JuryModeController', () {
    test('starts inactive and toggles with notifications', () {
      final c = JuryModeController();
      var notified = 0;
      c.addListener(() => notified++);
      expect(c.active, isFalse);

      c.enable();
      expect(c.active, isTrue);
      expect(notified, 1);

      c.enable(); // no-op
      expect(notified, 1);

      c.disable();
      expect(c.active, isFalse);
      expect(notified, 2);
    });
  });

  group('DemoDataController', () {
    test('defaults to enabled and toggles', () {
      final c = DemoDataController();
      var notified = 0;
      c.addListener(() => notified++);
      expect(c.enabled, isTrue);

      c.toggle();
      expect(c.enabled, isFalse);
      expect(notified, 1);

      c.setEnabled(false); // no-op
      expect(notified, 1);

      c.setEnabled(true);
      expect(c.enabled, isTrue);
      expect(notified, 2);
    });
  });
}
