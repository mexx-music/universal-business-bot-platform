import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:universalbusiness/app/app_dependencies.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/screens/business_story/business_story_screen.dart';
import 'package:universalbusiness/screens/jury/jury_start_screen.dart';
import 'package:universalbusiness/screens/jury/jury_tour_screen.dart';
import 'package:universalbusiness/screens/operations/operations_dashboard_screen.dart';

Future<void> pumpApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1200, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    UniversalBusinessApp(dependencies: AppDependencies.local()),
  );
  await tester.pumpAndSettle();
}

void goTo(WidgetTester tester, String route) {
  GoRouter.of(tester.element(find.byType(Navigator).first)).go(route);
}

void main() {
  testWidgets('explore activates jury mode with simplified navigation', (
    tester,
  ) async {
    await pumpApp(tester);
    goTo(tester, '/jury');
    await tester.pumpAndSettle();

    final l = AppLocalizations.of(
      tester.element(find.byType(JuryStartScreen)),
    )!;
    await tester.tap(find.text(l.heroExplore));
    await tester.pumpAndSettle();

    // Simplified jury navigation: the 5 main areas + "Weitere Module", with an
    // exit action. Other full-nav areas are folded away (not shown directly).
    expect(find.text(l.navMore), findsWidgets);
    expect(find.text(l.juryExit), findsWidgets);
    expect(find.text(l.navBusinessStory), findsWidgets);
    expect(find.text(l.navBotSettings), findsNothing);
  });

  testWidgets('guided jury demo walks the existing screens', (tester) async {
    await pumpApp(tester);
    goTo(tester, '/jury-demo');
    await tester.pumpAndSettle();

    final l = AppLocalizations.of(tester.element(find.byType(JuryTourScreen)))!;

    // Step 1: Business Story embedded with its intro.
    expect(find.text(l.juryTrans1), findsOneWidget);
    expect(find.byType(BusinessStoryScreen), findsOneWidget);

    // Step 2: Operations Dashboard embedded.
    await tester.tap(find.byKey(const Key('jury-next')));
    await tester.pumpAndSettle();
    expect(find.text(l.juryTrans2), findsOneWidget);
    expect(find.byType(OperationsDashboardScreen), findsOneWidget);
  });
}
