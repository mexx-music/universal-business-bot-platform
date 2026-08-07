import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:universalbusiness/app/app_dependencies.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';
import 'package:universalbusiness/auth/auth_controller.dart';
import 'package:universalbusiness/auth/auth_operation_result.dart';
import 'package:universalbusiness/auth/auth_service.dart';
import 'package:universalbusiness/auth/auth_session.dart';
import 'package:universalbusiness/auth/auth_user.dart';
import 'package:universalbusiness/auth/tenant_membership.dart';
import 'package:universalbusiness/jury/jury_mode_controller.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/repositories/tenant_context.dart';
import 'package:universalbusiness/screens/dashboard/dashboard_screen.dart';
import 'package:universalbusiness/screens/jury/jury_tour_screen.dart';
import 'package:universalbusiness/screens/knowledge_builder/knowledge_builder_screen.dart';
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

Future<AppDependencies> productionLikeDemoDependencies() async {
  final auth = AuthController(_ProductionAuthService());
  await auth.initialize();
  final dependencies = AppDependencies.local(authController: auth);
  await dependencies.demoModeController.enterDemo();
  return dependencies;
}

void openKnowledgeBuilderOnStartup(WidgetTester tester) {
  tester.binding.platformDispatcher.defaultRouteNameTestValue =
      '/knowledge-builder';
  addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);
}

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

  for (final width in [320.0, 360.0, 390.0, 430.0, 820.0, 1400.0]) {
    testWidgets(
      'Knowledge Builder action works in the production shell at ${width.toInt()} px',
      (tester) async {
        openKnowledgeBuilderOnStartup(tester);
        await pumpApp(
          tester,
          size: Size(width, 900),
          dependencies: await productionLikeDemoDependencies(),
        );

        expect(find.byType(KnowledgeBuilderScreen), findsOneWidget);
        final input = find.byKey(const Key('kb-input'));
        await tester.ensureVisible(input);
        await tester.enterText(input, 'Bluetooth muss aktiviert sein.');
        await tester.pump();

        final action = find.byKey(const Key('kb-analyze-action'));
        expect(action.hitTestable(), findsOneWidget);
        await tester.tap(action);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('kb-analysis-summary')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final width in [320.0, 360.0, 390.0, 430.0]) {
    testWidgets(
      'short mobile viewport keeps editor and action reachable at ${width.toInt()} px',
      (tester) async {
        openKnowledgeBuilderOnStartup(tester);
        await pumpApp(
          tester,
          size: Size(width, 430),
          dependencies: await productionLikeDemoDependencies(),
        );

        expect(
          find.byKey(const Key('full-platform-mobile-navigation')),
          findsNothing,
        );
        final input = find.byKey(const Key('kb-input'));
        await tester.ensureVisible(input);
        await tester.enterText(input, 'Bluetooth muss aktiviert sein.');
        await tester.pump();

        final action = find.byKey(const Key('kb-analyze-action'));
        expect(action.hitTestable(), findsOneWidget);
        expect(tester.getRect(action).bottom, lessThanOrEqualTo(430));
        await tester.tap(action);
        await tester.pumpAndSettle();

        final summary = find.byKey(const Key('kb-analysis-summary'));
        expect(summary, findsOneWidget);
        await tester.ensureVisible(summary);
        final summaryRect = tester.getRect(summary);
        expect(summaryRect.top, lessThan(430));
        expect(summaryRect.bottom, greaterThan(56));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'open keyboard does not double-resize the mobile Knowledge Builder',
    (tester) async {
      openKnowledgeBuilderOnStartup(tester);
      await pumpApp(
        tester,
        size: const Size(390, 900),
        dependencies: await productionLikeDemoDependencies(),
      );

      final input = find.byKey(const Key('kb-input'));
      await tester.ensureVisible(input);
      await tester.enterText(
        input,
        List.filled(40, 'Dokumentierte Bluetooth-Aussage.').join('\n'),
      );
      // FakeViewPadding is expressed in physical pixels. The test view uses a
      // devicePixelRatio of 3, so 1410 px models a 470 logical-pixel keyboard.
      tester.view.viewInsets = const FakeViewPadding(bottom: 1410);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('full-platform-mobile-navigation')),
        findsNothing,
      );
      final action = find.byKey(const Key('kb-analyze-action'));
      expect(action.hitTestable(), findsOneWidget);
      expect(tester.getRect(action).bottom, lessThanOrEqualTo(430));
      await tester.tap(action);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('kb-analysis-summary')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

const _productionUser = AuthUser(
  id: 'production-user',
  email: 'production@example.test',
  emailVerified: true,
);

const _productionSession = AuthSession(user: _productionUser);

const _productionTenant = TenantContext(
  tenantId: 'production-tenant',
  userId: 'production-user',
  role: 'owner',
  tenantName: 'Production Tenant',
);

class _ProductionAuthService implements AuthService {
  @override
  bool get isLocal => false;

  @override
  AuthSession? get currentSession => _productionSession;

  @override
  AuthUser? get currentUser => _productionUser;

  @override
  Stream<AuthSession?> get authStateChanges => const Stream.empty();

  @override
  Future<AuthSession?> restoreSession() async => _productionSession;

  @override
  Future<TenantContext?> resolveTenantContext(AuthUser user) async =>
      _productionTenant;

  @override
  Future<List<TenantMembership>> loadTenantMemberships(AuthUser user) async => [
    const TenantMembership(
      membershipId: 'production-membership',
      tenantId: 'production-tenant',
      tenantName: 'Production Tenant',
      role: 'owner',
    ),
  ];

  @override
  Future<AuthOperationResult> signIn({
    required String email,
    required String password,
  }) async => const AuthOperationResult(
    session: _productionSession,
    user: _productionUser,
  );

  @override
  Future<AuthOperationResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async => const AuthOperationResult(user: _productionUser);

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> updatePassword(String password) async {}
}
