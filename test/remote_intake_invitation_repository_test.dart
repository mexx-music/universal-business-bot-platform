import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/models/intake_session.dart';
import 'package:universalbusiness/repositories/remote_workspace_data_source.dart';
import 'package:universalbusiness/repositories/remote_workspace_repository.dart';
import 'package:universalbusiness/repositories/tenant_context.dart';

void main() {
  test(
    'remote repository creates invitation through tenant-scoped RPC',
    () async {
      final dataSource = _InvitationDataSource();
      final repository = await RemoteWorkspaceRepository.open(
        tenantContext: _tenant,
        dataSource: dataSource,
      );

      final invitation = await repository.createIntakeInvitation(
        greeting: 'Hallo Klaus.',
      );

      expect(dataSource.lastWorkspaceId, 'workspace-a');
      expect(dataSource.lastCompanyId, 'hb-cure');
      expect(dataSource.lastGreeting, 'Hallo Klaus.');
      expect(invitation.token, 'clear-token');
      expect(
        repository.selectedWorkspace.intakeInvitation?.token,
        'clear-token',
      );
    },
  );

  test(
    'remote repository persists intake session in selected workspace',
    () async {
      final dataSource = _InvitationDataSource();
      final repository = await RemoteWorkspaceRepository.open(
        tenantContext: _tenant,
        dataSource: dataSource,
      );

      final session = IntakeSession.empty(
        companyId: 'hb-cure',
      ).copyWith(status: IntakeStatus.inProgress, currentStepIndex: 3);
      await repository.updateIntakeSession(session);

      expect(dataSource.lastIntakePayload['tenant_id'], 'tenant-a');
      expect(dataSource.lastIntakePayload['workspace_id'], 'workspace-a');
      expect(dataSource.lastIntakePayload['company_id'], 'hb-cure');
      expect(dataSource.lastIntakePayload['current_step'], 3);
    },
  );
}

const _tenant = TenantContext(
  tenantId: 'tenant-a',
  userId: 'user-a',
  role: 'owner',
  workspaceId: 'workspace-a',
);

class _InvitationDataSource
    implements RemoteWorkspaceDataSource, RemoteIntakeInvitationDataSource {
  String? lastWorkspaceId;
  String? lastCompanyId;
  String? lastGreeting;
  Map<String, Object?> lastIntakePayload = const {};

  @override
  Future<RemoteWorkspaceSnapshotRows> loadWorkspaceRows(String tenantId) async {
    return const RemoteWorkspaceSnapshotRows(
      workspaces: [
        {
          'id': 'workspace-a',
          'tenant_id': 'tenant-a',
          'name': 'HB Cure',
          'created_at': '2026-01-01T00:00:00Z',
        },
      ],
      companies: [
        {
          'workspace_id': 'workspace-a',
          'tenant_id': 'tenant-a',
          'id': 'hb-cure',
          'company_name': 'HB Cure',
          'primary_language': 'de',
          'business_rules': <String, Object?>{},
          'bot_configuration': <String, Object?>{},
        },
      ],
      products: [],
      knowledgeEntries: [],
      sourceMaterials: [],
      botQuestionLogs: [],
      auditItems: [],
    );
  }

  @override
  Future<Map<String, Object?>> createIntakeInvitation({
    required String workspaceId,
    required String companyId,
    required String greeting,
  }) async {
    lastWorkspaceId = workspaceId;
    lastCompanyId = companyId;
    lastGreeting = greeting;
    return _invitationRow(token: 'clear-token', greeting: greeting);
  }

  @override
  Future<Map<String, Object?>> regenerateIntakeInvitation({
    required String workspaceId,
    required String companyId,
    String? greeting,
  }) async {
    return _invitationRow(token: 'new-clear-token', greeting: greeting ?? '');
  }

  @override
  Future<Map<String, Object?>?> deactivateIntakeInvitation({
    required String workspaceId,
    required String companyId,
  }) async {
    return _invitationRow(status: 'disabled');
  }

  @override
  Future<Map<String, Object?>> updateIntakeSession({
    required String workspaceId,
    required String companyId,
    required Map<String, Object?> payload,
  }) async {
    lastIntakePayload = payload;
    return {
      ...payload,
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-02T00:00:00Z',
    };
  }

  @override
  Future<Map<String, Object?>> insertRow(
    String table,
    Map<String, Object?> payload,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>> updateTenantRow({
    required String table,
    required String tenantId,
    required String workspaceId,
    required String id,
    required Map<String, Object?> payload,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTenantRow({
    required String table,
    required String tenantId,
    required String workspaceId,
    required String id,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>> updateCompanyRow({
    required String tenantId,
    required String workspaceId,
    required Map<String, Object?> payload,
  }) {
    throw UnimplementedError();
  }

  Map<String, Object?> _invitationRow({
    String token = '',
    String status = 'invited',
    String greeting = 'Hallo.',
  }) {
    return {
      'id': 'invite-a',
      'token': token,
      'status': status,
      'greeting': greeting,
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
    };
  }
}
