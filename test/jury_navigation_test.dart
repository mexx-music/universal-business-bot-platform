import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:universalbusiness/app/app_dependencies.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';
import 'package:universalbusiness/jury/jury_mode_controller.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/screens/dashboard/dashboard_screen.dart';
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
  testWidgets('explore opens the unrestricted platform without jury mode', (
    tester,
  ) async {
    await pumpApp(tester);
    goTo(tester, '/jury');
    await tester.pumpAndSettle();

    final l = AppLocalizations.of(
      tester.element(find.byType(JuryStartScreen)),
    )!;
    final juryMode = JuryModeController.of(
      tester.element(find.byType(JuryStartScreen)),
    );
    juryMode.enable();
    await tester.pump();

    await tester.tap(find.text(l.heroExplore));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(juryMode.active, isFalse);
    // The original full AppShell is visible; nothing is folded away.
    expect(find.byKey(const Key('full-platform-shell')), findsOneWidget);
    expect(find.text(l.navDashboard), findsWidgets);
    expect(find.text(l.juryExit), findsNothing);
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
