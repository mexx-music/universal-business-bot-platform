import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/data/intake_chat_flow.dart';
import 'package:universalbusiness/models/intake_invitation.dart';

void main() {
  test('creates a non-slug public intake token and link', () async {
    final state = AppState()..selectCompany('hb-cure');

    final invitation = await state.createIntakeInvitation();
    final link = state.selectedIntakeInvitationLink(
      baseUri: Uri.parse('https://platform.example/dashboard?tab=company'),
    );

    expect(invitation.token, isNot(contains('hb-cure')));
    expect(invitation.token.length, greaterThanOrEqualTo(30));
    expect(link, 'https://platform.example/onboarding/${invitation.token}');
    expect(invitation.status, IntakeInvitationStatus.invited);
  });

  test(
    'public intake token opens only the assigned company workspace',
    () async {
      final state = AppState()..selectCompany('hb-cure');
      final hbToken = (await state.createIntakeInvitation()).token;
      state.selectCompany('schnurr-purr');
      final schnurrToken = (await state.createIntakeInvitation()).token;

      expect(
        state.openPublicIntakeInvitation(hbToken),
        PublicIntakeOpenResult.opened,
      );
      expect(state.selectedCompanyId, 'hb-cure');
      expect(state.selectedIntakeInvitation?.token, hbToken);
      expect(
        state.selectedIntakeInvitation?.status,
        IntakeInvitationStatus.started,
      );

      expect(
        state.openPublicIntakeInvitation(schnurrToken),
        PublicIntakeOpenResult.opened,
      );
      expect(state.selectedCompanyId, 'schnurr-purr');
    },
  );

  test('invalid and disabled public intake tokens are blocked', () async {
    final state = AppState()..selectCompany('hb-cure');
    final token = (await state.createIntakeInvitation()).token;

    expect(
      state.openPublicIntakeInvitation('missing-token'),
      PublicIntakeOpenResult.notFound,
    );

    await state.deactivateIntakeInvitation();

    expect(
      state.openPublicIntakeInvitation(token),
      PublicIntakeOpenResult.disabled,
    );
    expect(
      state.selectedIntakeInvitation?.status,
      IntakeInvitationStatus.disabled,
    );
  });

  test(
    'autosaved public intake answer stays assigned to the target company',
    () async {
      final state = AppState()..selectCompany('hb-cure');
      final token = (await state.createIntakeInvitation()).token;
      state.selectCompany('schnurr-purr');

      expect(
        state.openPublicIntakeInvitation(token),
        PublicIntakeOpenResult.opened,
      );

      final question = IntakeChatFlow.questionByKey('companyName');
      IntakeChatFlow.saveAnswer(state, question, 'HB Cure Klaus Demo');

      expect(state.selectedCompanyId, 'hb-cure');
      expect(state.intakeSession?.basics.companyName, 'HB Cure Klaus Demo');
      expect(
        state.selectedIntakeInvitation?.status,
        IntakeInvitationStatus.partial,
      );

      state.selectCompany('schnurr-purr');
      expect(
        state.intakeSession?.basics.companyName,
        isNot('HB Cure Klaus Demo'),
      );
    },
  );

  test('completion marks the public invitation as completed', () async {
    final state = AppState()..selectCompany('hb-cure');
    final token = (await state.createIntakeInvitation()).token;

    expect(
      state.openPublicIntakeInvitation(token),
      PublicIntakeOpenResult.opened,
    );
    state.markIntakeChatCompleted();

    expect(
      state.selectedIntakeInvitation?.status,
      IntakeInvitationStatus.completed,
    );
    expect(state.selectedIntakeInvitation?.completedAt, isNotNull);
  });
}
