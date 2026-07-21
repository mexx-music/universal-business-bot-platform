import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/demo/demo_mode_controller.dart';
import 'package:universalbusiness/demo/demo_preference_store.dart';
import 'package:universalbusiness/repositories/local_workspace_repository.dart';

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
      'juror path: landing → start demo → pick company → dashboard with '
      'badge → leave demo',
      (tester) async {
        tester.view.physicalSize = const Size(1400, 2000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(UniversalBusinessApp());
        await tester.pumpAndSettle();

        // Landing shows the primary demo entry.
        expect(find.text('Demo starten'), findsOneWidget);
        await tester.tap(find.text('Demo starten'));
        await tester.pumpAndSettle();

        // Demo company selection.
        expect(find.text('Welche Demo möchten Sie ansehen?'), findsOneWidget);
        expect(find.text('Healing und Balance GmbH'), findsWidgets);
        expect(find.text('SchnurrPurr'), findsWidgets);
        await tester.tap(find.text('Healing und Balance GmbH').first);
        await tester.pumpAndSettle();

        // Dashboard with visible demo badge and guided tour.
        expect(find.text('Demo-Modus'), findsWidgets);
        expect(find.text('So erkunden Sie die Demo'), findsOneWidget);
        expect(find.text('Demo verlassen'), findsOneWidget);

        // Leaving the demo returns to the landing page.
        await tester.tap(find.text('Demo verlassen'));
        await tester.pumpAndSettle();
        expect(find.text('Demo starten'), findsOneWidget);
      },
    );
  });
}
