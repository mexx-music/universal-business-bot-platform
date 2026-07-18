import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/data/intake_chat_flow.dart';
import 'package:universalbusiness/data/mock_data.dart';
import 'package:universalbusiness/models/company_workspace.dart';
import 'package:universalbusiness/models/intake_invitation.dart';
import 'package:universalbusiness/models/intake_session.dart';
import 'package:universalbusiness/public_intake/public_intake_service.dart';
import 'package:universalbusiness/public_intake/public_intake_workspace_repository.dart';

void main() {
  test('public intake repository autosaves answers with the token', () async {
    final service = _FakePublicIntakeService(
      workspace: _workspace(invitationStatus: IntakeInvitationStatus.started),
    );
    final state = AppState(
      workspaceRepository: PublicIntakeWorkspaceRepository(
        token: 'secure-token',
        service: service,
        workspace: _workspace(invitationStatus: IntakeInvitationStatus.started),
      ),
    );

    final question = IntakeChatFlow.questionByKey('companyName');
    IntakeChatFlow.saveAnswer(state, question, 'HB Cure Remote Klaus');
    await Future<void>.delayed(Duration.zero);

    expect(service.lastSavedToken, 'secure-token');
    expect(service.lastSavedSession?.companyId, 'hb-cure');
    expect(
      service.lastSavedSession?.basics.companyName,
      'HB Cure Remote Klaus',
    );
  });

  test(
    'public intake repository blocks saves after disabled token response',
    () {
      final service = _FakePublicIntakeService(
        workspace: _workspace(invitationStatus: IntakeInvitationStatus.started),
        saveStatus: PublicIntakeRemoteStatus.disabled,
      );
      final repository = PublicIntakeWorkspaceRepository(
        token: 'disabled-token',
        service: service,
        workspace: _workspace(invitationStatus: IntakeInvitationStatus.started),
      );

      expect(
        repository.saveSelectedWorkspace(
          repository.selectedWorkspace.copyWith(
            intakeSession: repository.selectedWorkspace.intakeSession?.copyWith(
              currentStepIndex: 5,
            ),
          ),
        ),
        throwsA(anything),
      );
    },
  );

  test('remote public open can resume an existing partial session', () async {
    final workspace = _workspace(
      invitationStatus: IntakeInvitationStatus.partial,
    );
    final service = _FakePublicIntakeService(workspace: workspace);

    final response = await service.open('resume-token');

    expect(response.status, PublicIntakeRemoteStatus.opened);
    expect(response.workspace?.company.id, 'hb-cure');
    expect(
      response.workspace?.intakeInvitation?.status,
      IntakeInvitationStatus.partial,
    );
    expect(response.workspace?.intakeSession?.companyId, 'hb-cure');
  });
}

CompanyWorkspace _workspace({
  required IntakeInvitationStatus invitationStatus,
}) {
  final base = MockData.companyWorkspaces.first;
  final now = DateTime(2026, 7, 18);
  return base.copyWith(
    products: const [],
    knowledgeEntries: const [],
    botLogs: const [],
    auditItems: const [],
    sourceMaterials: const [],
    intakeSession: base.intakeSession,
    intakeInvitation: IntakeInvitation(
      id: 'invite-hb',
      token: '',
      status: invitationStatus,
      greeting: 'Willkommen beim Firmenfragebogen für HB Cure.',
      createdAt: now,
      updatedAt: now,
    ),
  );
}

class _FakePublicIntakeService implements PublicIntakeService {
  _FakePublicIntakeService({
    required this.workspace,
    this.saveStatus = PublicIntakeRemoteStatus.opened,
  });

  final CompanyWorkspace workspace;
  final PublicIntakeRemoteStatus saveStatus;
  String? lastSavedToken;
  IntakeSession? lastSavedSession;

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
    lastSavedToken = token;
    lastSavedSession = session;
    return PublicIntakeOpenResponse(status: saveStatus, workspace: workspace);
  }
}
