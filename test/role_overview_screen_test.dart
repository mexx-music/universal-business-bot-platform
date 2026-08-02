import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/roles/models/portal_role.dart';
import 'package:universalbusiness/screens/roles/role_overview_screen.dart';

Future<void> pumpScreen(
  WidgetTester tester, {
  Locale locale = const Locale('de'),
  Size size = const Size(1000, 1400),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: const RoleOverviewScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(RoleOverviewScreen)))!;

/// Taps a tier inside the tier SegmentedButton (avoids matching identically
/// named section pills, e.g. "Mitarbeiter").
Future<void> tapTier(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byWidgetPredicate((w) => w is SegmentedButton<PortalTier>),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('company portal shows full nav incl. system areas + day', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    expect(find.text(l.rolePortalCompanyTitle), findsOneWidget);
    // Shared knowledge base + demo notice are visible.
    expect(find.text(l.roleSharedKnowledgeNote), findsOneWidget);
    expect(find.text(l.roleTrustNotice), findsOneWidget);
    // Admin sees system settings and role management.
    expect(find.text(l.roleSecRoles), findsOneWidget);
    expect(find.text(l.navBotSettings), findsOneWidget);
    // Company day-in-the-life.
    expect(find.text(l.roleDayCompany1), findsOneWidget);
  });

  testWidgets('employee portal is reduced and hides system settings', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    await tapTier(tester, l.roleTierEmployee);

    // Department selector appears; support is the default.
    expect(find.text(l.roleSelectDepartment), findsOneWidget);
    expect(find.text(l.rolePortalEmployeeTitle), findsOneWidget);
    // Support sees review + knowledge, never AI settings / roles.
    expect(find.text(l.navReview), findsOneWidget);
    expect(find.text(l.navBotSettings), findsNothing);
    expect(find.text(l.roleSecRoles), findsNothing);
    expect(find.text(l.roleDayEmployee1), findsOneWidget);
  });

  testWidgets('switching department changes the reduced navigation', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    await tapTier(tester, l.roleTierEmployee);
    // Support has no community area yet.
    expect(find.text(l.navCommunityRadar), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, l.roleDeptMarketing));
    await tester.pumpAndSettle();

    // Marketing gains community; the support review area is gone.
    expect(find.text(l.navCommunityRadar), findsOneWidget);
    expect(find.text(l.navReview), findsNothing);
  });

  testWidgets('customer portal is public-only, no internal data', (
    tester,
  ) async {
    await pumpScreen(tester);
    final l = l10n(tester);

    await tapTier(tester, l.roleTierCustomer);

    expect(find.text(l.rolePortalCustomerTitle), findsOneWidget);
    expect(find.text(l.roleSecCustomerAssistant), findsOneWidget);
    expect(find.text(l.roleSecContact), findsOneWidget);
    // No internal areas.
    expect(find.text(l.navKnowledge), findsNothing);
    expect(find.text(l.navCommunityRadar), findsNothing);
    expect(find.text(l.roleSecResearch), findsNothing);
    expect(find.text(l.roleDayCustomer1), findsOneWidget);
  });

  testWidgets('is localized in English', (tester) async {
    await pumpScreen(tester, locale: const Locale('en'));
    final l = l10n(tester);
    expect(l.rolePortalCompanyTitle, 'Company portal');
    expect(find.text('Company portal'), findsOneWidget);
    expect(find.text(l.roleSectionsTitle), findsOneWidget);
  });

  testWidgets('lays out without overflow on mobile and desktop', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(360, 800));
    final l = l10n(tester);
    await tapTier(tester, l.roleTierEmployee);
    expect(tester.takeException(), isNull);

    await pumpScreen(tester, size: const Size(1400, 1000));
    expect(tester.takeException(), isNull);
  });
}
