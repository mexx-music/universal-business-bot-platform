import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/app/app_dependencies.dart';
import 'package:universalbusiness/auth/auth_controller.dart';
import 'package:universalbusiness/auth/auth_operation_result.dart';
import 'package:universalbusiness/auth/auth_service.dart';
import 'package:universalbusiness/auth/auth_session.dart';
import 'package:universalbusiness/auth/auth_status.dart';
import 'package:universalbusiness/auth/auth_user.dart';
import 'package:universalbusiness/auth/tenant_membership.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/models/bot_question_log.dart';
import 'package:universalbusiness/models/business_audit.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';
import 'package:universalbusiness/models/product_or_service.dart';
import 'package:universalbusiness/models/source_material.dart';
import 'package:universalbusiness/repositories/empty_workspace_repository.dart';
import 'package:universalbusiness/repositories/local_workspace_repository.dart';
import 'package:universalbusiness/repositories/remote_workspace_data_source.dart';
import 'package:universalbusiness/repositories/remote_workspace_exception.dart';
import 'package:universalbusiness/repositories/remote_workspace_repository.dart';
import 'package:universalbusiness/repositories/tenant_context.dart';

void main() {
  test('LocalWorkspaceRepository liefert Demo-Daten', () {
    final repository = LocalWorkspaceRepository();

    expect(repository.tenantContext.isLocal, isTrue);
    expect(repository.companies.length, greaterThanOrEqualTo(2));
    expect(repository.findWorkspace('hb-cure'), isNotNull);
    expect(repository.findWorkspace('schnurr-purr'), isNotNull);
  });

  test('RemoteWorkspaceRepository mappt Supabase-Daten korrekt', () async {
    final repository = await RemoteWorkspaceRepository.open(
      tenantContext: _tenant,
      dataSource: _FakeRemoteDataSource(_rows),
    );

    expect(repository.companies, hasLength(1));
    final workspace = repository.selectedWorkspace;
    expect(workspace.company.name, 'Remote Company');
    expect(workspace.products.single.name, 'Remote Product');
    expect(workspace.knowledgeEntries.single.title, 'Remote FAQ');
    expect(workspace.sourceMaterials.single.title, 'Remote Source');
    expect(workspace.botLogs.single.question, 'Remote question?');
    expect(workspace.auditItems.single.title, 'Remote Audit');
    expect(workspace.botConfiguration.useDisclaimer, isTrue);
    expect(workspace.businessRules.doNotSay, contains('No risky claims'));
  });

  test('RemoteWorkspaceRepository behandelt fehlenden Tenant kontrolliert', () {
    expect(
      () => RemoteWorkspaceRepository.open(
        tenantContext: const TenantContext.local(),
        dataSource: _FakeRemoteDataSource(_rows),
      ),
      throwsA(isA<MissingTenantException>()),
    );
  });

  test('RemoteWorkspaceRepository gibt Repository-Fehler weiter', () {
    expect(
      () => RemoteWorkspaceRepository.open(
        tenantContext: _tenant,
        dataSource: _FailingRemoteDataSource(),
      ),
      throwsA(isA<RemoteWorkspaceException>()),
    );
  });

  test('AppDependencies wählt im lokalen Modus das lokale Repository', () {
    final dependencies = AppDependencies.local();

    expect(dependencies.workspaceRepository, isA<LocalWorkspaceRepository>());
    expect(dependencies.appState.hasWorkspaces, isTrue);
  });

  test(
    'AppDependencies wählt im Supabase-Modus das Remote Repository',
    () async {
      final auth = AuthController(
        _FakeAuthService(restoredSession: _session, tenantContext: _tenant),
      );
      await auth.initialize();

      final dependencies = await AppDependencies.createWithAuthController(
        authController: auth,
        remoteDataSource: _FakeRemoteDataSource(_rows),
      );

      expect(
        dependencies.workspaceRepository,
        isA<RemoteWorkspaceRepository>(),
      );
      expect(dependencies.appState.selectedCompany.name, 'Remote Company');
    },
  );

  test('Nutzer ohne Membership sieht keine lokalen Demo-Daten', () async {
    final auth = AuthController(_FakeAuthService(restoredSession: _session));
    await auth.initialize();

    final dependencies = await AppDependencies.createWithAuthController(
      authController: auth,
      remoteDataSource: _FakeRemoteDataSource(_rows),
    );

    expect(auth.status, AuthStatus.onboardingRequired);
    expect(dependencies.workspaceRepository, isA<EmptyWorkspaceRepository>());
    expect(dependencies.appState.companies, isEmpty);
  });

  test('Logout entfernt Remote-Workspace-Daten aus dem AppState', () async {
    final service = _FakeAuthService(
      restoredSession: _session,
      tenantContext: _tenant,
    );
    final auth = AuthController(service);
    await auth.initialize();
    final dependencies = await AppDependencies.createWithAuthController(
      authController: auth,
      remoteDataSource: _FakeRemoteDataSource(_rows),
    );

    expect(dependencies.appState.hasWorkspaces, isTrue);

    await auth.signOut();
    await Future<void>.delayed(Duration.zero);

    expect(dependencies.appState.companies, isEmpty);
  });

  test('Remote CRUD erstellt Knowledge Entry mit TenantContext', () async {
    final dataSource = _CrudRemoteDataSource(_rows);
    final repository = await RemoteWorkspaceRepository.open(
      tenantContext: _tenant,
      dataSource: dataSource,
    );

    final saved = await repository.createKnowledgeEntry(
      KnowledgeEntry(
        id: 'knowledge-new',
        title: 'New FAQ',
        content: 'Server answer',
        category: KnowledgeCategory.faq,
        riskLevel: RiskLevel.green,
        keywords: const ['new'],
        source: 'Manual',
        createdAt: DateTime(2026),
        languageCode: 'de',
      ),
    );

    expect(saved.title, 'New FAQ');
    expect(
      repository.selectedWorkspace.knowledgeEntries.last.id,
      'knowledge-new',
    );
    expect(dataSource.lastInsertTable, 'knowledge_entries');
    expect(dataSource.lastInsertPayload['tenant_id'], 'tenant-a');
    expect(dataSource.lastInsertPayload['workspace_id'], 'workspace-a');
    expect(dataSource.lastInsertPayload['company_id'], 'remote-company');
    expect(dataSource.lastInsertPayload, isNot(contains('created_by')));
  });

  test(
    'Remote CRUD aktualisiert Product, Source, Bot Log und Audit Item',
    () async {
      final dataSource = _CrudRemoteDataSource(_rows);
      final repository = await RemoteWorkspaceRepository.open(
        tenantContext: _tenant,
        dataSource: dataSource,
      );

      await repository.updateProduct(
        const ProductOrService(
          id: 'product-a',
          name: 'Updated Product',
          description: 'Updated',
          type: ProductType.dienstleistung,
        ),
      );
      expect(dataSource.lastUpdateTable, 'products');
      expect(
        repository.selectedWorkspace.products.single.name,
        'Updated Product',
      );

      await repository.updateSourceMaterial(
        repository.selectedWorkspace.sourceMaterials.single.copyWith(
          status: SourceMaterialStatus.converted,
          relatedKnowledgeEntryIds: const ['knowledge-a', 'knowledge-new'],
        ),
      );
      expect(dataSource.lastUpdateTable, 'source_materials');
      expect(
        repository.selectedWorkspace.sourceMaterials.single.status,
        SourceMaterialStatus.converted,
      );

      await repository.updateBotQuestionLog(
        repository.selectedWorkspace.botLogs.single.copyWith(
          reviewStatus: ReviewStatus.reviewed,
          reviewedAt: DateTime.utc(2026, 2),
        ),
      );
      expect(dataSource.lastUpdateTable, 'bot_question_logs');
      expect(
        repository.selectedWorkspace.botLogs.single.reviewStatus,
        ReviewStatus.reviewed,
      );

      await repository.updateAuditItem(
        repository.selectedWorkspace.auditItems.single.copyWith(
          status: AuditItemStatus.partial,
        ),
      );
      expect(dataSource.lastUpdateTable, 'audit_items');
      expect(
        repository.selectedWorkspace.auditItems.single.status,
        AuditItemStatus.partial,
      );
    },
  );

  test('Viewer darf keine Remote-Schreiboperationen ausführen', () async {
    final repository = await RemoteWorkspaceRepository.open(
      tenantContext: const TenantContext(
        tenantId: 'tenant-a',
        userId: 'viewer-a',
        role: 'viewer',
      ),
      dataSource: _CrudRemoteDataSource(_rows),
    );

    expect(
      () => repository.createKnowledgeEntry(
        KnowledgeEntry(
          id: 'blocked',
          title: 'Blocked',
          content: 'Blocked',
          category: KnowledgeCategory.faq,
          riskLevel: RiskLevel.green,
          keywords: const [],
          source: '',
          createdAt: DateTime(2026),
        ),
      ),
      throwsA(isA<NoWritePermissionException>()),
    );
  });

  test('EmptyWorkspaceRepository blockiert Schreiboperationen', () {
    final repository = EmptyWorkspaceRepository(tenantContext: _tenant);

    expect(
      () => repository.createKnowledgeEntry(
        KnowledgeEntry(
          id: 'blocked',
          title: 'Blocked',
          content: 'Blocked',
          category: KnowledgeCategory.faq,
          riskLevel: RiskLevel.green,
          keywords: const [],
          source: '',
          createdAt: DateTime(2026),
        ),
      ),
      throwsA(isA<NoActiveWorkspaceException>()),
    );
  });

  test(
    'AppState übernimmt fehlgeschlagene Remote-Mutation nicht lokal',
    () async {
      final repository = await RemoteWorkspaceRepository.open(
        tenantContext: _tenant,
        dataSource: _FailingWriteDataSource(_rows),
      );
      final state = AppState(workspaceRepository: repository);
      final before = state.selectedKnowledgeEntries.length;

      await state.addKnowledgeEntry(
        KnowledgeEntry(
          id: 'will-fail',
          title: 'Will fail',
          content: 'No local write',
          category: KnowledgeCategory.faq,
          riskLevel: RiskLevel.green,
          keywords: const [],
          source: '',
          createdAt: DateTime(2026),
        ),
      );

      expect(state.selectedKnowledgeEntries, hasLength(before));
      expect(state.workspaceSaveError, isNotNull);
      expect(state.isSavingWorkspace, isFalse);
    },
  );
}

const _user = AuthUser(
  id: 'user-a',
  email: 'user@example.test',
  emailVerified: true,
);
const _session = AuthSession(user: _user);
const _tenant = TenantContext(
  tenantId: 'tenant-a',
  userId: 'user-a',
  role: 'owner',
  membershipId: 'tenant-a:user-a',
);

final _rows = RemoteWorkspaceSnapshotRows(
  workspaces: [
    {
      'id': 'workspace-a',
      'tenant_id': 'tenant-a',
      'name': 'Remote Workspace',
      'created_at': '2026-01-01T00:00:00Z',
    },
  ],
  companies: [
    {
      'workspace_id': 'workspace-a',
      'tenant_id': 'tenant-a',
      'id': 'remote-company',
      'company_name': 'Remote Company',
      'short_description': 'Remote description',
      'industry': 'Services',
      'country': 'AT',
      'primary_language': 'de',
      'website': 'https://remote.example',
      'support_email': 'support@remote.example',
      'support_phone': '+430000000',
      'social_links': {'website': 'https://remote.example'},
      'business_rules': {
        'brandVoice': 'clear',
        'noGoRules': ['No risky claims'],
        'allowedSupportTopics': ['Support'],
        'escalationNotes': 'Ask a human',
      },
      'bot_configuration': {
        'status': 'testReady',
        'answerStyle': 'balanced',
        'defaultLanguage': 'de',
        'useDisclaimer': true,
        'disclaimerText': 'Remote disclaimer',
        'alwaysEscalateRedFlags': true,
        'escalateNoMatch': true,
        'escalateYellowRisk': false,
        'allowedTopics': ['Support'],
        'blockedTopics': ['Diagnosis'],
        'handoverMessage': 'Human handover',
      },
      'internal_notes': 'Remote note',
    },
  ],
  products: [
    {
      'workspace_id': 'workspace-a',
      'id': 'product-a',
      'name': 'Remote Product',
      'description': 'Remote product description',
      'type': 'product',
    },
  ],
  knowledgeEntries: [
    {
      'workspace_id': 'workspace-a',
      'id': 'knowledge-a',
      'title': 'Remote FAQ',
      'content': 'Remote answer',
      'category': 'faq',
      'risk_level': 'green',
      'keywords': ['remote', 'faq'],
      'source': 'Remote Source',
      'created_at': '2026-01-02T00:00:00Z',
      'language_code': 'de',
    },
  ],
  sourceMaterials: [
    {
      'workspace_id': 'workspace-a',
      'id': 'source-a',
      'title': 'Remote Source',
      'type': 'website',
      'url': 'https://remote.example/source',
      'content_snippet': 'Snippet',
      'status': 'reviewed',
      'related_knowledge_entry_ids': ['knowledge-a'],
      'created_at': '2026-01-02T00:00:00Z',
      'updated_at': '2026-01-03T00:00:00Z',
    },
  ],
  botQuestionLogs: [
    {
      'workspace_id': 'workspace-a',
      'id': 'log-a',
      'question': 'Remote question?',
      'answer': 'Remote answer',
      'matched': true,
      'redirected': false,
      'reason': null,
      'risk_level': 'green',
      'review_status': 'closed',
      'created_at': '2026-01-04T00:00:00Z',
    },
  ],
  auditItems: [
    {
      'workspace_id': 'workspace-a',
      'id': 'audit-a',
      'area': 'website',
      'title': 'Remote Audit',
      'description': 'Remote audit description',
      'status': 'complete',
      'priority': 'medium',
    },
  ],
);

class _FakeRemoteDataSource implements RemoteWorkspaceDataSource {
  const _FakeRemoteDataSource(this.rows);

  final RemoteWorkspaceSnapshotRows rows;

  @override
  Future<RemoteWorkspaceSnapshotRows> loadWorkspaceRows(String tenantId) async {
    expect(tenantId, 'tenant-a');
    return rows;
  }

  @override
  Future<Map<String, Object?>> insertRow(
    String table,
    Map<String, Object?> payload,
  ) {
    throw UnimplementedError('insertRow is not used in this test.');
  }

  @override
  Future<Map<String, Object?>> updateTenantRow({
    required String table,
    required String tenantId,
    required String workspaceId,
    required String id,
    required Map<String, Object?> payload,
  }) {
    throw UnimplementedError('updateTenantRow is not used in this test.');
  }

  @override
  Future<void> deleteTenantRow({
    required String table,
    required String tenantId,
    required String workspaceId,
    required String id,
  }) {
    throw UnimplementedError('deleteTenantRow is not used in this test.');
  }

  @override
  Future<Map<String, Object?>> updateCompanyRow({
    required String tenantId,
    required String workspaceId,
    required Map<String, Object?> payload,
  }) {
    throw UnimplementedError('updateCompanyRow is not used in this test.');
  }
}

class _FailingRemoteDataSource implements RemoteWorkspaceDataSource {
  @override
  Future<RemoteWorkspaceSnapshotRows> loadWorkspaceRows(String tenantId) async {
    throw const RemoteWorkspaceException('Expected failure');
  }

  @override
  Future<Map<String, Object?>> insertRow(
    String table,
    Map<String, Object?> payload,
  ) {
    throw UnimplementedError('insertRow is not used in this test.');
  }

  @override
  Future<Map<String, Object?>> updateTenantRow({
    required String table,
    required String tenantId,
    required String workspaceId,
    required String id,
    required Map<String, Object?> payload,
  }) {
    throw UnimplementedError('updateTenantRow is not used in this test.');
  }

  @override
  Future<void> deleteTenantRow({
    required String table,
    required String tenantId,
    required String workspaceId,
    required String id,
  }) {
    throw UnimplementedError('deleteTenantRow is not used in this test.');
  }

  @override
  Future<Map<String, Object?>> updateCompanyRow({
    required String tenantId,
    required String workspaceId,
    required Map<String, Object?> payload,
  }) {
    throw UnimplementedError('updateCompanyRow is not used in this test.');
  }
}

class _CrudRemoteDataSource implements RemoteWorkspaceDataSource {
  _CrudRemoteDataSource(this.rows);

  final RemoteWorkspaceSnapshotRows rows;
  String? lastInsertTable;
  Map<String, Object?> lastInsertPayload = const {};
  String? lastUpdateTable;
  Map<String, Object?> lastUpdatePayload = const {};

  @override
  Future<RemoteWorkspaceSnapshotRows> loadWorkspaceRows(String tenantId) async {
    expect(tenantId, 'tenant-a');
    return rows;
  }

  @override
  Future<Map<String, Object?>> insertRow(
    String table,
    Map<String, Object?> payload,
  ) async {
    lastInsertTable = table;
    lastInsertPayload = payload;
    return {
      ..._baseRowFor(table),
      ...payload,
      'created_at': '2026-02-01T00:00:00Z',
      'updated_at': '2026-02-01T00:00:00Z',
    };
  }

  @override
  Future<Map<String, Object?>> updateTenantRow({
    required String table,
    required String tenantId,
    required String workspaceId,
    required String id,
    required Map<String, Object?> payload,
  }) async {
    expect(tenantId, 'tenant-a');
    expect(workspaceId, 'workspace-a');
    lastUpdateTable = table;
    lastUpdatePayload = payload;
    return {
      ..._baseRowFor(table, id: id),
      ...payload,
      'tenant_id': tenantId,
      'workspace_id': workspaceId,
      'id': id,
      'updated_at': '2026-02-02T00:00:00Z',
    };
  }

  @override
  Future<void> deleteTenantRow({
    required String table,
    required String tenantId,
    required String workspaceId,
    required String id,
  }) async {
    expect(tenantId, 'tenant-a');
    expect(workspaceId, 'workspace-a');
    lastUpdateTable = table;
  }

  @override
  Future<Map<String, Object?>> updateCompanyRow({
    required String tenantId,
    required String workspaceId,
    required Map<String, Object?> payload,
  }) async {
    expect(tenantId, 'tenant-a');
    expect(workspaceId, 'workspace-a');
    lastUpdateTable = 'companies';
    lastUpdatePayload = payload;
    return {..._rows.companies.single, ...payload};
  }

  Map<String, Object?> _baseRowFor(String table, {String? id}) {
    return switch (table) {
      'products' => {
        'workspace_id': 'workspace-a',
        'id': id ?? 'product-new',
        'name': '',
        'description': '',
        'type': 'product',
      },
      'knowledge_entries' => {
        'workspace_id': 'workspace-a',
        'id': id ?? 'knowledge-new',
        'title': '',
        'content': '',
        'category': 'faq',
        'risk_level': 'green',
        'keywords': <String>[],
        'source': '',
        'created_at': '2026-02-01T00:00:00Z',
        'language_code': 'de',
      },
      'source_materials' => {
        'workspace_id': 'workspace-a',
        'id': id ?? 'source-new',
        'title': '',
        'type': 'other',
        'status': 'new',
        'related_knowledge_entry_ids': <String>[],
        'created_at': '2026-02-01T00:00:00Z',
        'updated_at': '2026-02-01T00:00:00Z',
      },
      'bot_question_logs' => {
        'workspace_id': 'workspace-a',
        'id': id ?? 'log-new',
        'question': '',
        'matched': false,
        'redirected': false,
        'risk_level': 'green',
        'review_status': 'open',
        'created_at': '2026-02-01T00:00:00Z',
      },
      'audit_items' => {
        'workspace_id': 'workspace-a',
        'id': id ?? 'audit-new',
        'area': 'website',
        'title': '',
        'description': '',
        'status': 'missing',
        'priority': 'medium',
      },
      _ => {'workspace_id': 'workspace-a', 'id': id ?? 'new'},
    };
  }
}

class _FailingWriteDataSource extends _CrudRemoteDataSource {
  _FailingWriteDataSource(super.rows);

  @override
  Future<Map<String, Object?>> insertRow(
    String table,
    Map<String, Object?> payload,
  ) {
    throw const RemoteWorkspaceException('Expected write failure');
  }
}

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.restoredSession, this.tenantContext});

  final AuthSession? restoredSession;
  final TenantContext? tenantContext;
  final StreamController<AuthSession?> _controller =
      StreamController<AuthSession?>.broadcast();

  @override
  bool get isLocal => false;

  @override
  AuthSession? get currentSession => restoredSession;

  @override
  AuthUser? get currentUser => restoredSession?.user;

  @override
  Stream<AuthSession?> get authStateChanges => _controller.stream;

  @override
  Future<AuthSession?> restoreSession() async => restoredSession;

  @override
  Future<AuthOperationResult> signIn({
    required String email,
    required String password,
  }) async {
    _controller.add(restoredSession);
    return AuthOperationResult(
      session: restoredSession,
      user: restoredSession?.user,
    );
  }

  @override
  Future<AuthOperationResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return AuthOperationResult(user: restoredSession?.user);
  }

  @override
  Future<void> signOut() async {
    _controller.add(null);
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> updatePassword(String password) async {}

  @override
  Future<List<TenantMembership>> loadTenantMemberships(AuthUser user) async {
    final context = tenantContext;
    if (context == null) return const [];
    return [
      TenantMembership(
        membershipId: context.membershipId ?? '${context.tenantId}:${user.id}',
        tenantId: context.tenantId,
        tenantName: context.tenantName ?? 'Remote Tenant',
        role: context.role,
      ),
    ];
  }

  @override
  Future<TenantContext?> resolveTenantContext(AuthUser user) async {
    return tenantContext;
  }
}
