import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';

void main() {
  testWidgets('App startet ohne Fehler', (WidgetTester tester) async {
    await tester.pumpWidget(UniversalBusinessApp());
    await tester.pumpAndSettle();
    expect(
      find.text('Das digitale Gehirn\nIhres Unternehmens.'),
      findsOneWidget,
    );
    expect(find.text('Plattform kennenlernen'), findsOneWidget);
    expect(find.text('BusinessBrain in 2 Minuten erleben'), findsOneWidget);
    expect(find.text('Demo ansehen'), findsWidgets);
  });

  testWidgets('language switch updates the visible app locale DE → EN → DE', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(UniversalBusinessApp());
    await tester.pumpAndSettle();

    expect(
      find.text('Das digitale Gehirn\nIhres Unternehmens.'),
      findsOneWidget,
    );

    await tester.tap(find.text('EN').first);
    await tester.pumpAndSettle();

    expect(find.text('The digital brain\nfor your business.'), findsOneWidget);
    expect(find.text('View demo'), findsWidgets);

    await tester.tap(find.text('DE').first);
    await tester.pumpAndSettle();

    expect(
      find.text('Das digitale Gehirn\nIhres Unternehmens.'),
      findsOneWidget,
    );
    expect(find.text('Demo ansehen'), findsWidgets);
  });

  testWidgets('desktop sidebar does not overflow at a low viewport height', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1300, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(UniversalBusinessApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Plattform kennenlernen'));
    await tester.pumpAndSettle();

    tester.view.physicalSize = const Size(1300, 420);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('full-platform-shell')), findsOneWidget);
    expect(find.text('Jury-Modus beenden'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
