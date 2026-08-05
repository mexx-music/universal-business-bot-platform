import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/demo/demo_mode_controller.dart';
import 'package:universalbusiness/demo/demo_preference_store.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/repositories/local_workspace_repository.dart';
import 'package:universalbusiness/screens/dashboard/dashboard_screen.dart';
import 'package:universalbusiness/screens/jury/jury_tour_screen.dart';

void main() {
  group('DemoModeController', () {
    test(
      'enter activates and persists the flag and swaps the repository',
      () async {
        final regularRepository = LocalWorkspaceRepository();
        final appState = AppState(workspaceRepository: regularRepository);
        final store = MemoryDemoPreferenceStore();
        final controller = DemoModeController(
          appState: appState,
          preferenceStore: store,
          demoRepositoryFactory: () async => LocalWorkspaceRepository(),
          exitRepositoryFactory: () async => regularRepository,
        );

        expect(controller.isActive, isFalse);
        await controller.enterDemo();

        expect(controller.isActive, isTrue);
        expect(controller.isTourVisible, isTrue);
        expect(await store.readActive(), isTrue);
        // Demo data is the showcase seed.
        expect(appState.companies, isNotEmpty);
        expect(
          appState.companies.map((w) => w.company.id),
          containsAll(['hb-cure', 'schnurr-purr']),
        );
      },
    );

    test('demo writes never touch the regular repository', () async {
      final regularRepository = LocalWorkspaceRepository();
      final originalName = regularRepository.selectedWorkspace.company.name;
      final appState = AppState(workspaceRepository: regularRepository);
      final controller = DemoModeController(
        appState: appState,
        preferenceStore: MemoryDemoPreferenceStore(),
        demoRepositoryFactory: () async => LocalWorkspaceRepository(),
        exitRepositoryFactory: () async => regularRepository,
      );

      await controller.enterDemo();
      appState.updateCompany(
        appState.selectedCompany.copyWith(name: 'Nur Demo'),
      );
      expect(appState.selectedCompany.name, 'Nur Demo');
      expect(regularRepository.selectedWorkspace.company.name, originalName);

      await controller.exitDemo();
      expect(controller.isActive, isFalse);
      expect(appState.selectedCompany.name, originalName);
    });

    test('exit resets the persisted flag and clears demo data', () async {
      final store = MemoryDemoPreferenceStore(active: true);
      final demoRepository = LocalWorkspaceRepository();
      final appState = AppState(workspaceRepository: demoRepository);
      final controller = DemoModeController(
        appState: appState,
        preferenceStore: store,
        demoRepositoryFactory: () async => LocalWorkspaceRepository(),
        exitRepositoryFactory: () async => LocalWorkspaceRepository(),
        initiallyActive: true,
        initialDemoRepository: demoRepository,
      );

      // Restored demo session (as after a browser refresh).
      expect(controller.isActive, isTrue);

      await controller.exitDemo();
      expect(controller.isActive, isFalse);
      expect(await store.readActive(), isFalse);
    });

    test('dismissing the tour hides it for the session', () async {
      final appState = AppState(
        workspaceRepository: LocalWorkspaceRepository(),
      );
      final controller = DemoModeController(
        appState: appState,
        preferenceStore: MemoryDemoPreferenceStore(),
        demoRepositoryFactory: () async => LocalWorkspaceRepository(),
        exitRepositoryFactory: () async => LocalWorkspaceRepository(),
      );
      await controller.enterDemo();
      expect(controller.isTourVisible, isTrue);
      controller.dismissTour();
      expect(controller.isTourVisible, isFalse);
      expect(controller.isActive, isTrue);
    });
  });

  group('Demo flow', () {
    testWidgets(
      'public two-minute path ends in the unrestricted full platform',
      (tester) async {
        tester.view.physicalSize = const Size(1400, 2000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(UniversalBusinessApp());
        await tester.pumpAndSettle();

        expect(find.text('BusinessBrain in 2 Minuten erleben'), findsOneWidget);
        await tester.tap(find.text('BusinessBrain in 2 Minuten erleben'));
        await tester.pumpAndSettle();

        expect(find.byType(JuryTourScreen), findsOneWidget);
        final l = AppLocalizations.of(
          tester.element(find.byType(JuryTourScreen)),
        )!;
        for (var i = 0; i < JuryTourScreen.stepCount - 1; i++) {
          await tester.tap(find.byKey(const Key('jury-next')));
          await tester.pumpAndSettle();
        }

        expect(find.text(l.juryFinish), findsOneWidget);
        await tester.tap(find.byKey(const Key('jury-finish')));
        await tester.pumpAndSettle();

        expect(find.byType(DashboardScreen), findsOneWidget);
        expect(find.text(l.navBotSettings), findsWidgets);
        expect(find.text(l.juryExit), findsNothing);
      },
    );
  });
}
