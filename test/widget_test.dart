import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';

void main() {
  testWidgets('App startet ohne Fehler', (WidgetTester tester) async {
    await tester.pumpWidget(UniversalBusinessApp());
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Die intelligente Plattform für Unternehmenswissen und digitales Wachstum',
      ),
      findsOneWidget,
    );
    expect(find.text('Plattform kennenlernen'), findsOneWidget);
    expect(find.text('Demo ansehen'), findsWidgets);
  });
}
