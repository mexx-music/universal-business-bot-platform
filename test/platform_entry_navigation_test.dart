import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:universalbusiness/app/app_dependencies.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';
import 'package:universalbusiness/jury/jury_mode_controller.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/screens/dashboard/dashboard_screen.dart';
import 'package:universalbusiness/screens/jury/jury_tour_screen.dart';
import 'package:universalbusiness/screens/public/landing_screen.dart';

Future<void> pumpApp(
  WidgetTester tester, {
  Size size = const Size(1200, 900),
  AppDependencies? dependencies,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    UniversalBusinessApp(dependencies: dependencies ?? AppDependencies.local()),
  );
  await tester.pumpAndSettle();
}

AppLocalizations l10nFor(WidgetTester tester, Type type) =>
    AppLocalizations.of(tester.element(find.byType(type)))!;

void main() {
  testWidgets('landing Explore platform uses the full existing AppShell', (
    tester,
  ) async {
    final dependencies = AppDependencies.local();
    await pumpApp(tester, dependencies: dependencies);
    final l = l10nFor(tester, LandingScreen);
    final juryMode = JuryModeController.of(
      tester.element(find.byType(LandingScreen)),
    );

    // Even stale state from a previous jury route must be cleared.
    juryMode.enable();
    await tester.pump();
    await tester.tap(find.text(l.landingLearnMoreButton));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(juryMode.active, isFalse);
    expect(dependencies.demoModeController.isActive, isFalse);
    expect(find.byKey(const Key('full-platform-shell')), findsOneWidget);
    expect(find.text(l.navBusinessIntelligence), findsWidgets);
    expect(find.text(l.juryExit), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('jury conclusion uses the same unrestricted platform entry', (
    tester,
  ) async {
    await pumpApp(tester);
    final landingL10n = l10nFor(tester, LandingScreen);

    await tester.tap(find.text(landingL10n.demoStartButton));
    await tester.pumpAndSettle();

    expect(find.byType(JuryTourScreen), findsOneWidget);
    final l = l10nFor(tester, JuryTourScreen);
    final juryMode = JuryModeController.of(
      tester.element(find.byType(JuryTourScreen)),
    );
    expect(juryMode.active, isTrue);

    for (var i = 0; i < JuryTourScreen.stepCount - 1; i++) {
      await tester.tap(find.byKey(const Key('jury-next')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Jetzt selbst die Plattform erkunden'), findsOneWidget);
    await tester.tap(find.byKey(const Key('jury-finish')));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(juryMode.active, isFalse);
    expect(find.byKey(const Key('full-platform-shell')), findsOneWidget);
    expect(find.text(l.juryExit), findsNothing);
  });

  testWidgets('browser history cannot carry jury mode into the platform', (
    tester,
  ) async {
    await pumpApp(tester);
    final router = GoRouter.of(tester.element(find.byType(Navigator).first));

    // Platform route information events are what browser back/forward sends
    // to Router on the web.
    await router.routeInformationProvider.didPushRouteInformation(
      RouteInformation(uri: Uri.parse('/jury-demo')),
    );
    await tester.pumpAndSettle();
    final juryMode = JuryModeController.of(
      tester.element(find.byType(JuryTourScreen)),
    );
    expect(juryMode.active, isTrue);

    await router.routeInformationProvider.didPushRouteInformation(
      RouteInformation(uri: Uri.parse('/dashboard')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(juryMode.active, isFalse);
    expect(router.routeInformationProvider.value.uri.path, '/dashboard');
    expect(find.text('Jury-Modus beenden'), findsNothing);

    // Replaying back and forward stays deterministic and loop-free.
    await router.routeInformationProvider.didPushRouteInformation(
      RouteInformation(uri: Uri.parse('/jury-demo')),
    );
    await tester.pumpAndSettle();
    expect(juryMode.active, isTrue);

    await router.routeInformationProvider.didPushRouteInformation(
      RouteInformation(uri: Uri.parse('/dashboard')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(juryMode.active, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('direct dashboard URL survives app startup like a refresh', (
    tester,
  ) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/dashboard';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );

    await pumpApp(tester);

    expect(find.byType(DashboardScreen), findsOneWidget);
    final juryMode = JuryModeController.of(
      tester.element(find.byType(DashboardScreen)),
    );
    expect(juryMode.active, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('full-platform entry remains responsive on mobile', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(390, 900));
    final l = l10nFor(tester, LandingScreen);

    final explore = find.text(l.landingLearnMoreButton);
    await tester.ensureVisible(explore);
    await tester.pumpAndSettle();
    await tester.tap(explore);
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text(l.juryExit), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
