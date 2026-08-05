import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/app/app_dependencies.dart';
import 'package:universalbusiness/app/universal_business_bot_app.dart';
import 'package:universalbusiness/getting_started/getting_started_demo.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/screens/getting_started/getting_started_screen.dart';

Future<void> pumpGettingStarted(
  WidgetTester tester, {
  Locale locale = const Locale('de'),
  Size size = const Size(1200, 2800),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: const GettingStartedScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations gettingStartedL10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(GettingStartedScreen)))!;

Future<void> tapNext(WidgetTester tester) async {
  final button = find.byKey(const Key('getting-started-next'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  test('defines a five-step, sub-20-minute demo journey', () {
    expect(gettingStartedSteps, hasLength(5));
    expect(
      gettingStartedSteps.map((step) => step.id),
      GettingStartedStepId.values,
    );
    expect(
      gettingStartedSteps.fold<int>(
        0,
        (total, step) => total + step.estimatedMinutes,
      ),
      19,
    );
    expect(gettingStartedImportKeys, hasLength(7));
    expect(gettingStartedAnalysisKeys, hasLength(7));
  });

  testWidgets('starts with an optional local-only company profile', (
    tester,
  ) async {
    await pumpGettingStarted(tester);
    final l = gettingStartedL10n(tester);

    expect(find.byKey(const Key('getting-started-hero')), findsOneWidget);
    expect(find.byKey(const Key('getting-started-timeline')), findsOneWidget);
    expect(find.byKey(const Key('getting-started-progress')), findsOneWidget);
    for (final step in GettingStartedStepId.values) {
      expect(
        find.byKey(ValueKey('getting-started-step-${step.name}')),
        findsOneWidget,
      );
    }
    expect(find.byKey(const Key('getting-started-company')), findsOneWidget);
    expect(find.byKey(const Key('getting-started-industry')), findsOneWidget);
    expect(find.byKey(const Key('getting-started-country')), findsOneWidget);
    expect(find.byKey(const Key('getting-started-language')), findsOneWidget);
    expect(find.byKey(const Key('getting-started-website')), findsOneWidget);
    expect(find.byKey(const Key('getting-started-logo')), findsOneWidget);
    expect(find.text(l.gettingStartedDemoBoundary), findsOneWidget);
    expect(find.text(l.gettingStartedOptionalNote), findsOneWidget);
    expect(find.byKey(const Key('getting-started-success')), findsNothing);
  });

  testWidgets('shows the complete import, analysis, review and ready journey', (
    tester,
  ) async {
    await pumpGettingStarted(tester);
    final l = gettingStartedL10n(tester);

    await tapNext(tester);
    for (final key in gettingStartedImportKeys) {
      expect(
        find.byKey(ValueKey('getting-started-import-$key')),
        findsOneWidget,
      );
    }
    expect(find.text(l.gettingStartedImportBoundary), findsOneWidget);

    await tapNext(tester);
    expect(
      find.byKey(const Key('getting-started-analysis-animation')),
      findsOneWidget,
    );
    for (final key in gettingStartedAnalysisKeys) {
      expect(
        find.byKey(ValueKey('getting-started-detected-$key')),
        findsOneWidget,
      );
    }
    expect(find.text(l.gettingStartedAnalysisHumanNote), findsOneWidget);

    await tapNext(tester);
    expect(
      find.byKey(const ValueKey('getting-started-review-faq')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('getting-started-review-support')),
      findsOneWidget,
    );
    expect(find.text(l.gettingStartedReviewBoundary), findsOneWidget);
    expect(find.text(l.gettingStartedReviewConfirmed), findsOneWidget);
    expect(find.text(l.gettingStartedReviewConfirm), findsOneWidget);

    await tapNext(tester);
    expect(find.text(l.gettingStartedReadyQuestions), findsOneWidget);
    expect(find.text(l.gettingStartedReadyGrounded), findsOneWidget);
    expect(find.text(l.gettingStartedReadyOperations), findsOneWidget);
    expect(find.text(l.gettingStartedReadyBoundary), findsOneWidget);

    await tapNext(tester);
    expect(find.byKey(const Key('getting-started-success')), findsOneWidget);
    expect(find.text(l.gettingStartedSuccessTitle), findsOneWidget);
    expect(find.text(l.gettingStartedSuccessCompany), findsOneWidget);
    expect(find.text(l.gettingStartedSuccessDocuments), findsOneWidget);
    expect(find.text(l.gettingStartedSuccessKnowledge), findsOneWidget);
    expect(find.text(l.gettingStartedSuccessAi), findsOneWidget);
    expect(find.text(l.gettingStartedSuccessOperations), findsOneWidget);
  });

  testWidgets('labels the timing explicitly as a demo estimate', (
    tester,
  ) async {
    await pumpGettingStarted(tester);
    final l = gettingStartedL10n(tester);

    expect(find.byKey(const Key('getting-started-time')), findsOneWidget);
    expect(find.text(l.gettingStartedTime2), findsOneWidget);
    expect(find.text(l.gettingStartedTime5), findsOneWidget);
    expect(find.text(l.gettingStartedTime10), findsOneWidget);
    expect(find.text(l.gettingStartedTimeUnder20), findsOneWidget);
    expect(find.text(l.gettingStartedTimeDisclaimer), findsOneWidget);
  });

  testWidgets('is fully localized in English', (tester) async {
    await pumpGettingStarted(tester, locale: const Locale('en'));

    expect(
      find.text('Get a company ready in a few clear steps'),
      findsOneWidget,
    );
    expect(find.text('Create the company'), findsWidgets);
    expect(find.text('Step 1 of 5'), findsOneWidget);
    expect(find.text('under 20 minutes'), findsOneWidget);
    expect(
      find.text(
        'Journey only: no registration, upload, AI analysis or storage '
        'takes place.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('has no overflow on mobile, tablet and desktop', (tester) async {
    for (final size in const [
      Size(360, 900),
      Size(820, 1100),
      Size(1440, 1500),
    ]) {
      await pumpGettingStarted(tester, size: size);
      expect(tester.takeException(), isNull, reason: 'overflow at $size');

      for (final step in GettingStartedStepId.values.skip(1)) {
        final node = find.byKey(ValueKey('getting-started-step-${step.name}'));
        await tester.ensureVisible(node);
        await tester.tap(node);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${step.name} overflow at $size',
        );
      }
    }
  });

  testWidgets('landing navigation opens the public getting-started journey', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UniversalBusinessApp(dependencies: AppDependencies.local()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('landing-getting-started')));
    await tester.pumpAndSettle();

    expect(find.byType(GettingStartedScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
