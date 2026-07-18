import 'package:supabase_flutter/supabase_flutter.dart';

import 'remote_workspace_exception.dart';

class RemoteWorkspaceSnapshotRows {
  const RemoteWorkspaceSnapshotRows({
    required this.workspaces,
    required this.companies,
    required this.products,
    required this.knowledgeEntries,
    required this.sourceMaterials,
    required this.botQuestionLogs,
    required this.auditItems,
    this.intakeSessions = const [],
    this.intakeInvitations = const [],
  });

  final List<Map<String, Object?>> workspaces;
  final List<Map<String, Object?>> companies;
  final List<Map<String, Object?>> products;
  final List<Map<String, Object?>> knowledgeEntries;
  final List<Map<String, Object?>> sourceMaterials;
  final List<Map<String, Object?>> botQuestionLogs;
  final List<Map<String, Object?>> auditItems;
  final List<Map<String, Object?>> intakeSessions;
  final List<Map<String, Object?>> intakeInvitations;
}

abstract class RemoteIntakeInvitationDataSource {
  Future<Map<String, Object?>> createIntakeInvitation({
    required String workspaceId,
    required String companyId,
    required String greeting,
  });

  Future<Map<String, Object?>> regenerateIntakeInvitation({
    required String workspaceId,
    required String companyId,
    String? greeting,
  });

  Future<Map<String, Object?>?> deactivateIntakeInvitation({
    required String workspaceId,
    required String companyId,
  });

  Future<Map<String, Object?>> updateIntakeSession({
    required String workspaceId,
    required String companyId,
    required Map<String, Object?> payload,
  });
}

abstract class RemoteWorkspaceDataSource {
  Future<RemoteWorkspaceSnapshotRows> loadWorkspaceRows(String tenantId);

  Future<Map<String, Object?>> insertRow(
    String table,
    Map<String, Object?> payload,
  );

  Future<Map<String, Object?>> updateTenantRow({
    required String table,
    required String tenantId,
    required String workspaceId,
    required String id,
    required Map<String, Object?> payload,
  });

  Future<void> deleteTenantRow({
    required String table,
    required String tenantId,
    required String workspaceId,
    required String id,
  });

  Future<Map<String, Object?>> updateCompanyRow({
    required String tenantId,
    required String workspaceId,
    required Map<String, Object?> payload,
  });
}

class SupabaseWorkspaceDataSource
    implements RemoteWorkspaceDataSource, RemoteIntakeInvitationDataSource {
  const SupabaseWorkspaceDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<RemoteWorkspaceSnapshotRows> loadWorkspaceRows(String tenantId) async {
    try {
      final workspaces = await _selectTenantRows(
        'workspaces',
        tenantId,
        orderColumn: 'created_at',
      );
      final companies = await _selectTenantRows('companies', tenantId);
      final products = await _selectTenantRows(
        'products',
        tenantId,
        orderColumn: 'priority',
      );
      final knowledgeEntries = await _selectTenantRows(
        'knowledge_entries',
        tenantId,
        orderColumn: 'created_at',
      );
      final sourceMaterials = await _selectTenantRows(
        'source_materials',
        tenantId,
        orderColumn: 'created_at',
      );
      final botQuestionLogs = await _selectTenantRows(
        'bot_question_logs',
        tenantId,
        orderColumn: 'created_at',
      );
      final auditItems = await _selectTenantRows(
        'audit_items',
        tenantId,
        orderColumn: 'created_at',
      );
      final intakeSessions = await _selectTenantRows(
        'intake_sessions',
        tenantId,
        orderColumn: 'updated_at',
      );
      final intakeInvitations = await _selectTenantRows(
        'intake_invitations',
        tenantId,
        orderColumn: 'updated_at',
      );

      return RemoteWorkspaceSnapshotRows(
        workspaces: workspaces,
        companies: companies,
        products: products,
        knowledgeEntries: knowledgeEntries,
        sourceMaterials: sourceMaterials,
        botQuestionLogs: botQuestionLogs,
        auditItems: auditItems,
        intakeSessions: intakeSessions,
        intakeInvitations: intakeInvitations,
      );
    } catch (error) {
      throw RemoteWorkspaceException(
        'Remote workspace data could not be loaded.',
        error,
      );
    }
  }

  Future<List<Map<String, Object?>>> _selectTenantRows(
    String table,
    String tenantId, {
    String? orderColumn,
  }) async {
    final query = _client
        .from(table)
        .select()
        .eq('tenant_id', tenantId)
        .isFilter('deleted_at', null);
    if (orderColumn != null) {
      return _castRows(await query.order(orderColumn));
    }
    return _castRows(await query);
  }

  List<Map<String, Object?>> _castRows(List<dynamic> rows) {
    return [
      for (final row in rows)
        if (row is Map) row.cast<String, Object?>(),
    ];
  }

  @override
  Future<Map<String, Object?>> insertRow(
    String table,
    Map<String, Object?> payload,
  ) async {
    try {
      final row = await _client.from(table).insert(payload).select().single();
      return _castRow(row);
    } catch (error) {
      throw RemoteWorkspaceException(
        'Remote workspace data could not be inserted.',
        error,
      );
    }
  }

  @override
  Future<Map<String, Object?>> updateTenantRow({
    required String table,
    required String tenantId,
    required String workspaceId,
    required String id,
    required Map<String, Object?> payload,
  }) async {
    try {
      final row = await _client
          .from(table)
          .update(payload)
          .eq('tenant_id', tenantId)
          .eq('workspace_id', workspaceId)
          .eq('id', id)
          .select()
          .single();
      return _castRow(row);
    } catch (error) {
      throw RemoteWorkspaceException(
        'Remote workspace data could not be updated.',
        error,
      );
    }
  }

  @override
  Future<void> deleteTenantRow({
    required String table,
    required String tenantId,
    required String workspaceId,
    required String id,
  }) async {
    try {
      await _client
          .from(table)
          .delete()
          .eq('tenant_id', tenantId)
          .eq('workspace_id', workspaceId)
          .eq('id', id)
          .select('id')
          .single();
    } catch (error) {
      throw RemoteWorkspaceException(
        'Remote workspace data could not be deleted.',
        error,
      );
    }
  }

  @override
  Future<Map<String, Object?>> updateCompanyRow({
    required String tenantId,
    required String workspaceId,
    required Map<String, Object?> payload,
  }) async {
    try {
      final row = await _client
          .from('companies')
          .update(payload)
          .eq('tenant_id', tenantId)
          .eq('workspace_id', workspaceId)
          .select()
          .single();
      return _castRow(row);
    } catch (error) {
      throw RemoteWorkspaceException(
        'Remote company data could not be updated.',
        error,
      );
    }
  }

  @override
  Future<Map<String, Object?>> createIntakeInvitation({
    required String workspaceId,
    required String companyId,
    required String greeting,
  }) async {
    return _rpcRow('create_intake_invitation', {
      'target_workspace_id': workspaceId,
      'target_company_id': companyId,
      'invitation_greeting': greeting,
    });
  }

  @override
  Future<Map<String, Object?>> regenerateIntakeInvitation({
    required String workspaceId,
    required String companyId,
    String? greeting,
  }) async {
    return _rpcRow('regenerate_intake_invitation', {
      'target_workspace_id': workspaceId,
      'target_company_id': companyId,
      if (greeting != null) 'invitation_greeting': greeting,
    });
  }

  @override
  Future<Map<String, Object?>?> deactivateIntakeInvitation({
    required String workspaceId,
    required String companyId,
  }) async {
    final result = await _client.rpc(
      'deactivate_intake_invitation',
      params: {
        'target_workspace_id': workspaceId,
        'target_company_id': companyId,
      },
    );
    if (result == null) return null;
    return _castRow(result);
  }

  @override
  Future<Map<String, Object?>> updateIntakeSession({
    required String workspaceId,
    required String companyId,
    required Map<String, Object?> payload,
  }) async {
    try {
      final row = await _client
          .from('intake_sessions')
          .upsert({
            ...payload,
            'workspace_id': workspaceId,
            'company_id': companyId,
          })
          .select()
          .single();
      return _castRow(row);
    } catch (error) {
      throw RemoteWorkspaceException(
        'Remote intake data could not be saved.',
        error,
      );
    }
  }

  Future<Map<String, Object?>> _rpcRow(
    String name,
    Map<String, Object?> params,
  ) async {
    try {
      final result = await _client.rpc(name, params: params);
      return _castRow(result);
    } catch (error) {
      throw RemoteWorkspaceException('Remote RPC failed: $name.', error);
    }
  }

  Map<String, Object?> _castRow(dynamic row) {
    if (row is Map) return row.cast<String, Object?>();
    throw const RemoteWorkspaceException('Remote response was not a row.');
  }
}
