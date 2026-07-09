import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';

void main() {
  testWidgets('App startet ohne Fehler', (WidgetTester tester) async {
    await tester.pumpWidget(UniversalBusinessApp());
    await tester.pumpAndSettle();
    expect(find.text('Universal Business Bot Plattform'), findsOneWidget);
    expect(find.text('HB Cure'), findsOneWidget);
    expect(find.text('SchnurrPurr'), findsOneWidget);
  });
}
