import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:universalbusiness/data/mock_data.dart';
import 'package:universalbusiness/models/action_record.dart';
import 'package:universalbusiness/models/companion_check_in.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';
import 'package:universalbusiness/repositories/local_workspace_repository.dart';
import 'package:universalbusiness/repositories/persistence/workspace_codec.dart';
import 'package:universalbusiness/repositories/persistent_workspace_repository.dart';

void main() {
  final workspacesStore = stringMapStoreFactory.store('workspaces');
  final metaRecord = stringMapStoreFactory.store('meta').record('meta');

  Future<PersistentWorkspaceRepository> openRepo(DatabaseFactory factory) {
    return PersistentWorkspaceRepository.open(databaseFactory: factory);
  }

  test('first start seeds mock data and persists it', () async {
    final factory = newDatabaseFactoryMemory();
    final repo = await openRepo(factory);

    expect(repo.companies.map((w) => w.company.id), [
      for (final workspace in MockData.companyWorkspaces) workspace.company.id,
    ]);
    expect(repo.selectedCompanyId, MockData.companyWorkspaces.first.company.id);
    expect(repo.loadedFromFallback, isFalse);
    await repo.dispose();

    final db = await factory.openDatabase(
      PersistentWorkspaceRepository.defaultDbName,
    );
    final records = await workspacesStore.find(db);
    final meta = await metaRecord.get(db);
    expect(records, hasLength(MockData.companyWorkspaces.length));
    expect(meta?['schemaVersion'], PersistentWorkspaceRepository.schemaVersion);
    expect(
      meta?['selectedCompanyId'],
      MockData.companyWorkspaces.first.company.id,
    );
    await db.close();
  });

  test('mutations survive a reload and workspaces stay separated', () async {
    final factory = newDatabaseFactoryMemory();
    final repo = await openRepo(factory);
    final otherId = repo.companies.last.company.id;
    final untouchedEntryCount = repo.companies.last.knowledgeEntries.length;

    final updated = repo.selectedWorkspace.copyWith(
      company: repo.selectedWorkspace.company.copyWith(
        name: 'Persistierte Firma',
      ),
      knowledgeEntries: [
        ...repo.selectedWorkspace.knowledgeEntries,
        KnowledgeEntry(
          id: 'persist-test',
          title: 'Bleibt erhalten',
          content: 'Inhalt',
          category: KnowledgeCategory.faq,
          riskLevel: RiskLevel.green,
          keywords: const ['persistenz'],
          source: 'Test',
          createdAt: DateTime(2026, 7, 16),
        ),
      ],
    );
    await repo.saveSelectedWorkspace(updated);
    await repo.dispose();

    final reloaded = await openRepo(factory);
    expect(reloaded.selectedWorkspace.company.name, 'Persistierte Firma');
    expect(
      reloaded.selectedWorkspace.knowledgeEntries.any(
        (entry) => entry.id == 'persist-test',
      ),
      isTrue,
    );
    final other = reloaded.findWorkspace(otherId)!;
    expect(other.knowledgeEntries, hasLength(untouchedEntryCount));
    expect(
      other.knowledgeEntries.any((entry) => entry.id == 'persist-test'),
      isFalse,
    );
    await reloaded.dispose();
  });

  test('selected workspace survives a reload', () async {
    final factory = newDatabaseFactoryMemory();
    final repo = await openRepo(factory);
    final secondId = repo.companies.last.company.id;

    expect(repo.selectCompany(secondId), isTrue);
    await repo.flush();
    await repo.dispose();

    final reloaded = await openRepo(factory);
    expect(reloaded.selectedCompanyId, secondId);
    await reloaded.dispose();
  });

  test(
    'a single corrupted record is skipped, the rest keeps working',
    () async {
      final factory = newDatabaseFactoryMemory();
      final repo = await openRepo(factory);
      final ids = repo.companies.map((w) => w.company.id).toList();
      await repo.dispose();

      final db = await factory.openDatabase(
        PersistentWorkspaceRepository.defaultDbName,
      );
      await workspacesStore.record(ids.first).put(db, {'garbage': true});
      await db.close();

      final reloaded = await openRepo(factory);
      expect(reloaded.loadedFromFallback, isFalse);
      expect(reloaded.companies.map((w) => w.company.id), [ids.last]);
      expect(reloaded.selectedCompanyId, ids.last);
      await reloaded.dispose();
    },
  );

  test(
    'fully corrupted data falls back to mock seed without overwriting it',
    () async {
      final factory = newDatabaseFactoryMemory();
      final repo = await openRepo(factory);
      final ids = repo.companies.map((w) => w.company.id).toList();
      await repo.dispose();

      final db = await factory.openDatabase(
        PersistentWorkspaceRepository.defaultDbName,
      );
      for (final id in ids) {
        await workspacesStore.record(id).put(db, {'garbage': true});
      }
      await db.close();

      final reloaded = await openRepo(factory);
      expect(reloaded.loadedFromFallback, isTrue);
      expect(reloaded.companies.map((w) => w.company.id), ids);
      await reloaded.flush();
      await reloaded.dispose();

      // The broken records were not bulk-overwritten by the fallback.
      final checkDb = await factory.openDatabase(
        PersistentWorkspaceRepository.defaultDbName,
      );
      final record = await workspacesStore.record(ids.first).get(checkDb);
      expect(record, {'garbage': true});
      await checkDb.close();
    },
  );

  test(
    'data from a newer schema version is refused and left untouched',
    () async {
      final factory = newDatabaseFactoryMemory();
      final repo = await openRepo(factory);
      await repo.dispose();

      final db = await factory.openDatabase(
        PersistentWorkspaceRepository.defaultDbName,
      );
      final meta = Map<String, Object?>.from((await metaRecord.get(db))!);
      meta['schemaVersion'] = PersistentWorkspaceRepository.schemaVersion + 1;
      await metaRecord.put(db, meta);
      await db.close();

      await expectLater(
        openRepo(factory),
        throwsA(isA<SchemaVersionException>()),
      );

      final checkDb = await factory.openDatabase(
        PersistentWorkspaceRepository.defaultDbName,
      );
      expect(
        (await metaRecord.get(checkDb))?['schemaVersion'],
        PersistentWorkspaceRepository.schemaVersion + 1,
      );
      expect(
        await workspacesStore.find(checkDb),
        hasLength(MockData.companyWorkspaces.length),
      );
      await checkDb.close();
    },
  );

  test('clear() removes persisted data; next start reseeds', () async {
    final factory = newDatabaseFactoryMemory();
    final repo = await openRepo(factory);
    await repo.saveSelectedWorkspace(
      repo.selectedWorkspace.copyWith(
        company: repo.selectedWorkspace.company.copyWith(name: 'Vor Reset'),
      ),
    );
    await repo.clear();
    await repo.dispose();

    final db = await factory.openDatabase(
      PersistentWorkspaceRepository.defaultDbName,
    );
    expect(await workspacesStore.find(db), isEmpty);
    expect(await metaRecord.get(db), isNull);
    await db.close();

    final reseeded = await openRepo(factory);
    expect(
      reseeded.selectedWorkspace.company.name,
      MockData.companyWorkspaces.first.company.name,
    );
    await reseeded.dispose();
  });

  test('action records survive a reload with all fields', () async {
    final factory = newDatabaseFactoryMemory();
    final repo = await openRepo(factory);
    final record = ActionRecord(
      id: 'ar_expandFaq_1',
      actionType: 'expandFaq',
      titleSnapshot: 'FAQ erweitern',
      descriptionSnapshot: 'Mehr FAQ-Einträge anlegen.',
      status: ActionRecordStatus.completed,
      createdAt: DateTime(2026, 6, 1),
      acceptedAt: DateTime(2026, 6, 1),
      startedAt: DateTime(2026, 6, 2),
      completedAt: DateTime(2026, 6, 20),
      resultRating: ActionResultRating.helpedALot,
      resultNote: 'Deutlich weniger Support-Anfragen',
      expectedImpact: 'high',
      actualOutcome: 'Bot-Trefferquote +20 %',
      repeatRequested: true,
      sourceReasonKeys: const ['knowledgeEntries: 3× category=faq'],
    );

    await repo.saveSelectedWorkspace(
      repo.selectedWorkspace.copyWith(actionRecords: [record]),
    );
    await repo.dispose();

    final reloaded = await openRepo(factory);
    final loaded = reloaded.selectedWorkspace.actionRecords.single;
    expect(loaded.id, record.id);
    expect(loaded.actionType, 'expandFaq');
    expect(loaded.status, ActionRecordStatus.completed);
    expect(loaded.completedAt, record.completedAt);
    expect(loaded.resultRating, ActionResultRating.helpedALot);
    expect(loaded.resultNote, record.resultNote);
    expect(loaded.actualOutcome, record.actualOutcome);
    expect(loaded.repeatRequested, isTrue);
    expect(loaded.sourceReasonKeys, record.sourceReasonKeys);
    await reloaded.dispose();
  });

  test('check-ins survive a reload with all fields', () async {
    final factory = newDatabaseFactoryMemory();
    final repo = await openRepo(factory);
    final checkIn = CompanionCheckIn(
      id: 'ci_1',
      workspaceId: repo.selectedWorkspace.company.id,
      periodStart: DateTime(2026, 6, 16),
      periodEnd: DateTime(2026, 7, 16),
      createdAt: DateTime(2026, 7, 16),
      completedAt: DateTime(2026, 7, 16, 10, 30),
      status: CheckInStatus.completed,
      summary: '2 Maßnahmen abgeschlossen.',
      completedActionIds: const ['r1', 'r2'],
      ratedActionIds: const ['r1'],
      awaitingRatingActionIds: const ['r2'],
      positiveOutcomes: const ['Ein positiver Effekt wurde gemeldet.'],
      lessonsLearned: const ['FAQ-Ausbau lohnt sich.'],
      userNotes: 'Guter Monat.',
      nextActionIds: const ['expandFaq', 'activateBot'],
      dataConfidence: CheckInDataConfidence.medium,
      needsHumanReview: true,
    );

    await repo.saveSelectedWorkspace(
      repo.selectedWorkspace.copyWith(checkIns: [checkIn]),
    );
    await repo.dispose();

    final reloaded = await openRepo(factory);
    final loaded = reloaded.selectedWorkspace.checkIns.single;
    expect(loaded.id, checkIn.id);
    expect(loaded.status, CheckInStatus.completed);
    expect(loaded.completedAt, checkIn.completedAt);
    expect(loaded.summary, checkIn.summary);
    expect(loaded.completedActionIds, checkIn.completedActionIds);
    expect(loaded.awaitingRatingActionIds, checkIn.awaitingRatingActionIds);
    expect(loaded.positiveOutcomes, checkIn.positiveOutcomes);
    expect(loaded.lessonsLearned, checkIn.lessonsLearned);
    expect(loaded.userNotes, 'Guter Monat.');
    expect(loaded.nextActionIds, checkIn.nextActionIds);
    expect(loaded.dataConfidence, CheckInDataConfidence.medium);
    expect(loaded.needsHumanReview, isTrue);
    await reloaded.dispose();
  });

  test('schema v2 data is migrated to v3 without data loss', () async {
    final factory = newDatabaseFactoryMemory();
    final repo = await openRepo(factory);
    final companyName = repo.selectedWorkspace.company.name;
    await repo.dispose();

    final db = await factory.openDatabase(
      PersistentWorkspaceRepository.defaultDbName,
    );
    final meta = Map<String, Object?>.from((await metaRecord.get(db))!);
    meta['schemaVersion'] = 2;
    await metaRecord.put(db, meta);
    for (final record in await workspacesStore.find(db)) {
      final payload = Map<String, Object?>.from(record.value)
        ..remove('checkIns');
      await workspacesStore.record(record.key).put(db, payload);
    }
    await db.close();

    final migrated = await openRepo(factory);
    expect(migrated.selectedWorkspace.company.name, companyName);
    expect(migrated.selectedWorkspace.checkIns, isEmpty);
    await migrated.dispose();

    final checkDb = await factory.openDatabase(
      PersistentWorkspaceRepository.defaultDbName,
    );
    expect(
      (await metaRecord.get(checkDb))?['schemaVersion'],
      PersistentWorkspaceRepository.schemaVersion,
    );
    await checkDb.close();
  });

  test('schema v1 data is migrated to v2 without data loss', () async {
    final factory = newDatabaseFactoryMemory();
    final repo = await openRepo(factory);
    final companyName = repo.selectedWorkspace.company.name;
    await repo.dispose();

    // Downgrade the store to look like v1: old meta version and workspace
    // payloads without the actionRecords field.
    final db = await factory.openDatabase(
      PersistentWorkspaceRepository.defaultDbName,
    );
    final meta = Map<String, Object?>.from((await metaRecord.get(db))!);
    meta['schemaVersion'] = 1;
    await metaRecord.put(db, meta);
    for (final record in await workspacesStore.find(db)) {
      final payload = Map<String, Object?>.from(record.value)
        ..remove('actionRecords');
      await workspacesStore.record(record.key).put(db, payload);
    }
    await db.close();

    final migrated = await openRepo(factory);
    expect(migrated.selectedWorkspace.company.name, companyName);
    expect(migrated.selectedWorkspace.actionRecords, isEmpty);
    expect(migrated.companies, hasLength(MockData.companyWorkspaces.length));
    await migrated.dispose();

    final checkDb = await factory.openDatabase(
      PersistentWorkspaceRepository.defaultDbName,
    );
    expect(
      (await metaRecord.get(checkDb))?['schemaVersion'],
      PersistentWorkspaceRepository.schemaVersion,
    );
    await checkDb.close();
  });

  test('codec round-trips the full workspace graph', () {
    for (final workspace in MockData.companyWorkspaces) {
      final decoded = WorkspaceCodec.decodeWorkspace(
        WorkspaceCodec.encodeWorkspace(workspace),
      );

      expect(decoded.company.id, workspace.company.id);
      expect(decoded.company.socialLinks, workspace.company.socialLinks);
      expect(decoded.products.length, workspace.products.length);
      expect(
        decoded.knowledgeEntries.map((e) => e.id),
        workspace.knowledgeEntries.map((e) => e.id),
      );
      for (var i = 0; i < workspace.knowledgeEntries.length; i++) {
        expect(
          decoded.knowledgeEntries[i].category,
          workspace.knowledgeEntries[i].category,
        );
        expect(
          decoded.knowledgeEntries[i].riskLevel,
          workspace.knowledgeEntries[i].riskLevel,
        );
        expect(
          decoded.knowledgeEntries[i].createdAt,
          workspace.knowledgeEntries[i].createdAt,
        );
      }
      expect(decoded.botLogs.length, workspace.botLogs.length);
      expect(decoded.auditItems.length, workspace.auditItems.length);
      for (var i = 0; i < workspace.auditItems.length; i++) {
        expect(decoded.auditItems[i].status, workspace.auditItems[i].status);
        expect(
          decoded.auditItems[i].priority,
          workspace.auditItems[i].priority,
        );
      }
      expect(
        decoded.businessRules.brandVoice,
        workspace.businessRules.brandVoice,
      );
      expect(
        decoded.botConfiguration.status,
        workspace.botConfiguration.status,
      );
      expect(decoded.sourceMaterials.length, workspace.sourceMaterials.length);
      expect(decoded.businessGoals.length, workspace.businessGoals.length);
      expect(decoded.intakeSession?.id, workspace.intakeSession?.id);
    }
  });

  test('codec tolerates unknown enum values and unknown fields', () {
    final json = WorkspaceCodec.encodeWorkspace(
      MockData.companyWorkspaces.first,
    );
    final tampered = Map<String, Object?>.from(json);
    tampered['completelyUnknownField'] = {'nested': true};
    final entries = List<Object?>.from(tampered['knowledgeEntries'] as List);
    final firstEntry = Map<String, Object?>.from(entries.first as Map);
    firstEntry['riskLevel'] = 'doesNotExist';
    entries[0] = firstEntry;
    tampered['knowledgeEntries'] = entries;

    final decoded = WorkspaceCodec.decodeWorkspace(tampered);
    expect(decoded.knowledgeEntries.first.riskLevel, RiskLevel.yellow);
  });

  test('LocalWorkspaceRepository still fulfils the async contract', () async {
    final repo = LocalWorkspaceRepository();
    final updated = repo.selectedWorkspace.copyWith(
      company: repo.selectedWorkspace.company.copyWith(name: 'Lokal'),
    );

    await repo.saveSelectedWorkspace(updated);
    expect(repo.selectedWorkspace.company.name, 'Lokal');

    expect(await repo.saveWorkspace('does-not-exist', updated), isFalse);

    await repo.clear();
    expect(
      repo.selectedWorkspace.company.name,
      MockData.companyWorkspaces.first.company.name,
    );
  });
}
