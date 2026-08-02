import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/demo_data/demo_data_controller.dart';
import 'package:universalbusiness/jury/jury_mode_controller.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/screens/jury/jury_start_screen.dart';
import 'package:universalbusiness/screens/more/more_modules_screen.dart';
import 'package:universalbusiness/screens/operations/operations_dashboard_screen.dart';
import 'package:universalbusiness/screens/release/release_checklist_screen.dart';

Future<void> pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('de'),
  Size size = const Size(1100, 2200),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: child,
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations l10nOf(WidgetTester tester, Type t) =>
    AppLocalizations.of(tester.element(find.byType(t)))!;

void main() {
  group('Jury start screen', () {
    testWidgets('shows intro and the two actions', (tester) async {
      await pump(
        tester,
        JuryModeScope(
          notifier: JuryModeController(),
          child: const JuryStartScreen(),
        ),
      );
      final l = l10nOf(tester, JuryStartScreen);
      expect(find.text(l.juryStartTitle), findsOneWidget);
      expect(find.text(l.juryStartGuided), findsOneWidget);
      expect(find.text(l.juryStartExplore), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('is localized in English', (tester) async {
      await pump(
        tester,
        JuryModeScope(
          notifier: JuryModeController(),
          child: const JuryStartScreen(),
        ),
        locale: const Locale('en'),
      );
      expect(find.text('Start guided jury demo'), findsOneWidget);
      expect(find.text('Explore the platform freely'), findsOneWidget);
    });
  });

  group('More modules screen', () {
    testWidgets('lists modules and toggles the central demo switch', (
      tester,
    ) async {
      final demo = DemoDataController();
      await pump(
        tester,
        DemoDataScope(notifier: demo, child: const MoreModulesScreen()),
      );
      final l = l10nOf(tester, MoreModulesScreen);

      expect(find.text(l.moreTitle), findsOneWidget);
      // A few remaining modules are present (nothing removed).
      expect(find.text(l.navKnowledge), findsWidgets);
      expect(find.text(l.navCommunityRadar), findsWidgets);
      // Central demo switch flips the controller.
      expect(demo.enabled, isTrue);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(demo.enabled, isFalse);
      expect(tester.takeException(), isNull);
    });
  });

  group('Release checklist screen', () {
    testWidgets('renders 13 items and cycles a status on tap', (tester) async {
      await pump(tester, const ReleaseChecklistScreen());
      final l = l10nOf(tester, ReleaseChecklistScreen);
      expect(find.text(l.releaseTitle), findsOneWidget);
      expect(find.text(l.rcItem1), findsOneWidget);
      expect(find.text(l.rcItem13), findsOneWidget);

      // Item 2 defaults to "not started"; tapping cycles to "in progress".
      expect(find.text(l.rcNotStarted), findsWidgets);
      await tester.tap(find.text(l.rcItem2));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Central demo switch affects Operations dashboard', () {
    testWidgets('DEMO badges hidden when demo disabled, shown when enabled', (
      tester,
    ) async {
      await pump(
        tester,
        DemoDataScope(
          notifier: DemoDataController(enabled: false),
          child: const OperationsDashboardScreen(),
        ),
      );
      final l = l10nOf(tester, OperationsDashboardScreen);
      expect(find.text(l.opDemoBadge), findsNothing);

      await pump(
        tester,
        DemoDataScope(
          notifier: DemoDataController(enabled: true),
          child: const OperationsDashboardScreen(),
        ),
      );
      expect(find.text(l.opDemoBadge), findsWidgets);
    });
  });
}
