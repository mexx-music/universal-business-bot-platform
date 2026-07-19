import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/data/intake_chat_flow.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/models/company_workspace.dart';
import 'package:universalbusiness/models/intake_invitation.dart';
import 'package:universalbusiness/models/intake_session.dart';
import 'package:universalbusiness/public_intake/public_intake_service.dart';
import 'package:universalbusiness/public_intake/public_intake_workspace_repository.dart';
import 'package:universalbusiness/screens/intake/intake_screen.dart';

void main() {
  test(
    'reset clears intake answers, completion state and keeps company data',
    () async {
      final state = AppState()..selectCompany('hb-cure');
      final companyName = state.selectedCompany.name;
      final knowledgeCount = state.selectedKnowledgeEntries.length;
      final otherSession = state.companies
          .firstWhere((workspace) => workspace.company.id == 'schnurr-purr')
          .intakeSession;
      final token = (await state.createIntakeInvitation()).token;

      _answer(state, 'companyName', 'Klaus Demo Company');
      _answer(state, 'shortDescription', 'Already answered');
      state.markIntakeChatCompleted();

      expect(state.intakeSession?.status, IntakeStatus.completed);
      expect(state.intakeSession?.chatCompletedAt, isNotNull);

      final success = await state.resetCompanyIntake();

      expect(success, isTrue);
      expect(state.selectedCompany.name, companyName);
      expect(state.selectedKnowledgeEntries.length, knowledgeCount);
      expect(state.intakeSession?.status, IntakeStatus.draft);
      expect(state.intakeSession?.currentStepIndex, 0);
      expect(state.intakeSession?.chatCurrentQuestionIndex, 0);
      expect(state.intakeSession?.chatCompletedAt, isNull);
      expect(state.intakeSession?.skippedQuestionKeys, isEmpty);
      expect(state.intakeSession?.deferredQuestionKeys, isEmpty);
      expect(state.intakeSession?.basics.companyName, isEmpty);
      expect(state.intakeSession?.products.importantProducts, isEmpty);
      expect(
        IntakeChatFlow.nextQuestion(state.intakeSession!)?.questionKey,
        'companyName',
      );
      expect(state.selectedIntakeInvitation?.token, token);
      expect(
        state.selectedIntakeInvitation?.status,
        IntakeInvitationStatus.invited,
      );
      expect(state.selectedIntakeInvitation?.completedAt, isNull);

      state.selectCompany('schnurr-purr');
      expect(state.intakeSession?.id, otherSession?.id);
      expect(
        state.intakeSession?.basics.companyName,
        otherSession?.basics.companyName,
      );
    },
  );

  test('same public URL starts at the first question after reset', () async {
    final state = AppState()..selectCompany('hb-cure');
    final token = (await state.createIntakeInvitation()).token;
    expect(
      state.openPublicIntakeInvitation(token),
      PublicIntakeOpenResult.opened,
    );
    _answer(state, 'companyName', 'Answered over public link');
    state.markIntakeChatCompleted();

    await state.resetCompanyIntake();

    expect(
      state.openPublicIntakeInvitation(token),
      PublicIntakeOpenResult.opened,
    );
    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)?.questionKey,
      'companyName',
    );
    expect(state.intakeSession?.basics.companyName, isEmpty);
  });

  test('public questionnaire user cannot reset intake', () async {
    final base = AppState()..selectCompany('hb-cure');
    _answer(base, 'companyName', 'Public Answer');
    final workspace = base.selectedWorkspace.copyWith(
      intakeInvitation: IntakeInvitation(
        id: 'invite-public',
        token: 'public-token',
        status: IntakeInvitationStatus.started,
        greeting: 'Hallo',
        createdAt: DateTime(2026, 7, 19),
        updatedAt: DateTime(2026, 7, 19),
      ),
    );
    final publicState = AppState(
      workspaceRepository: PublicIntakeWorkspaceRepository(
        token: 'public-token',
        service: _NoopPublicIntakeService(workspace),
        workspace: workspace,
      ),
    );

    final success = await publicState.resetCompanyIntake();

    expect(success, isFalse);
    expect(publicState.intakeSession?.basics.companyName, 'Public Answer');
  });

  testWidgets('canceling the reset dialog changes nothing', (tester) async {
    await _setDesktopViewport(tester);
    final state = AppState()..selectCompany('hb-cure');
    _answer(state, 'companyName', 'Do not delete');

    await _pumpIntakeScreen(tester, state);
    await tester.tap(find.text('Firmenaufnahme zurücksetzen'));
    await tester.pumpAndSettle();
    expect(find.text('Firmenaufnahme zurücksetzen?'), findsOneWidget);

    await tester.tap(find.text('Abbrechen').last);
    await tester.pumpAndSettle();

    expect(state.intakeSession?.basics.companyName, 'Do not delete');
  });

  testWidgets('successful reset updates the intake UI immediately', (
    tester,
  ) async {
    await _setDesktopViewport(tester);
    final state = AppState()..selectCompany('hb-cure');
    _answer(state, 'companyName', 'Delete me');
    state.markIntakeChatCompleted();

    await _pumpIntakeScreen(tester, state);
    await tester.tap(find.text('Firmenaufnahme zurücksetzen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zurücksetzen').last);
    await tester.pumpAndSettle();

    expect(find.text('Firmenaufnahme wurde zurückgesetzt.'), findsOneWidget);
    expect(find.text('Schritt 1 von 7'), findsOneWidget);
    expect(state.intakeSession?.basics.companyName, isEmpty);
    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)?.questionKey,
      'companyName',
    );
  });
}

void _answer(AppState state, String questionKey, String answer) {
  IntakeChatFlow.saveAnswer(
    state,
    IntakeChatFlow.questionByKey(questionKey),
    answer,
  );
}

Future<void> _setDesktopViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1400, 1100));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> _pumpIntakeScreen(WidgetTester tester, AppState state) async {
  await tester.pumpWidget(
    AppStateScope(
      notifier: state,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: const IntakeScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _NoopPublicIntakeService implements PublicIntakeService {
  const _NoopPublicIntakeService(this.workspace);

  final CompanyWorkspace workspace;

  @override
  bool get isSupported => true;

  @override
  Future<PublicIntakeOpenResponse> open(String token) async {
    return PublicIntakeOpenResponse(
      status: PublicIntakeRemoteStatus.opened,
      workspace: workspace,
    );
  }

  @override
  Future<PublicIntakeOpenResponse> save({
    required String token,
    required IntakeSession session,
  }) async {
    return PublicIntakeOpenResponse(
      status: PublicIntakeRemoteStatus.opened,
      workspace: workspace.copyWith(intakeSession: session),
    );
  }
}
