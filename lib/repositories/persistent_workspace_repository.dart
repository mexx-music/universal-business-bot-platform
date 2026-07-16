import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';

import '../data/workspace_store.dart';
import '../models/company_workspace.dart';
import 'persistence/workspace_codec.dart';
import 'tenant_context.dart';
import 'workspace_repository.dart';

/// Thrown when the persisted data was written by a newer app version than
/// this build understands. The data is left untouched; the composition root
/// falls back to an in-memory repository for the session.
class SchemaVersionException implements Exception {
  const SchemaVersionException({required this.found, required this.supported});

  final Object? found;
  final int supported;

  @override
  String toString() =>
      'SchemaVersionException: stored schemaVersion $found, '
      'this build supports up to $supported';
}

/// [WorkspaceRepository] backed by a sembast database — IndexedDB on the web.
///
/// State model: the full workspace list lives in memory (loaded once in
/// [open]); reads never touch storage. Every mutation updates the in-memory
/// state synchronously and appends the persistence write to a serialized
/// queue, so writes reach storage in mutation order and a storage failure
/// can never corrupt ordering or crash the app (the error is recorded in
/// [lastPersistenceError] and logged, the session keeps running in memory).
///
/// Layout: one record per workspace in the `workspaces` store (key =
/// company id), plus a single `meta` record holding `schemaVersion` and
/// `selectedCompanyId`. Future migrations hook into [_migrateIfNeeded].
class PersistentWorkspaceRepository implements WorkspaceRepository {
  static const int schemaVersion = 1;
  static const String defaultDbName = 'universalbusiness.db';

  static final StoreRef<String, Map<String, Object?>> _workspacesStore =
      stringMapStoreFactory.store('workspaces');
  static final StoreRef<String, Map<String, Object?>> _metaStore =
      stringMapStoreFactory.store('meta');
  static final RecordRef<String, Map<String, Object?>> _metaRecord =
      _metaStore.record('meta');

  PersistentWorkspaceRepository._({
    required Database db,
    required this.tenantContext,
    required List<CompanyWorkspace> companies,
    required String selectedCompanyId,
    required this.loadedFromFallback,
  }) : _db = db,
       _companies = companies,
       _selectedCompanyId = selectedCompanyId;

  final Database _db;

  @override
  final TenantContext tenantContext;

  /// True when persisted data existed but no valid workspace could be
  /// decoded, so this session runs on the mock seed. The stored (broken)
  /// data is intentionally not bulk-overwritten; only workspaces the user
  /// actually mutates get re-persisted.
  final bool loadedFromFallback;

  List<CompanyWorkspace> _companies;
  String _selectedCompanyId;

  Future<void> _writeQueue = Future<void>.value();

  /// Last storage error, if any. Persistence errors never surface in the UI;
  /// they are kept here for debugging/telemetry.
  Object? lastPersistenceError;

  /// The default seed for a first start: the mock workspaces, cloned so the
  /// static mock data is never mutated.
  static List<CompanyWorkspace> defaultSeed() => WorkspaceStore().companies;

  /// Opens (and on first start seeds) the persistent repository.
  ///
  /// Throws [SchemaVersionException] when the stored data is newer than this
  /// build, and rethrows storage failures — callers (the composition root)
  /// are expected to fall back to [LocalWorkspaceRepository] in that case.
  static Future<PersistentWorkspaceRepository> open({
    required DatabaseFactory databaseFactory,
    String dbName = defaultDbName,
    TenantContext tenantContext = const TenantContext.local(),
    List<CompanyWorkspace> Function() seed = defaultSeed,
  }) async {
    final db = await databaseFactory.openDatabase(dbName);
    try {
      final meta = await _metaRecord.get(db);
      if (meta != null) {
        final storedVersion = meta['schemaVersion'];
        if (storedVersion is! int || storedVersion > schemaVersion) {
          throw SchemaVersionException(
            found: storedVersion,
            supported: schemaVersion,
          );
        }
        await _migrateIfNeeded(db, storedVersion);
      }

      final records = await _workspacesStore.find(db);

      if (meta == null && records.isEmpty) {
        // First start: seed from mock data and persist the seed.
        final companies = seed();
        final selectedId = companies.first.company.id;
        await db.transaction((txn) async {
          for (final workspace in companies) {
            await _workspacesStore
                .record(workspace.company.id)
                .put(txn, WorkspaceCodec.encodeWorkspace(workspace));
          }
          await _metaRecord.put(txn, _metaJson(selectedId));
        });
        return PersistentWorkspaceRepository._(
          db: db,
          tenantContext: tenantContext,
          companies: companies,
          selectedCompanyId: selectedId,
          loadedFromFallback: false,
        );
      }

      // Regular start: decode what is stored; skip individual broken records.
      final companies = <CompanyWorkspace>[];
      for (final record in records) {
        try {
          companies.add(WorkspaceCodec.decodeWorkspace(record.value));
        } catch (error) {
          debugPrint(
            'Skipping unreadable workspace record "${record.key}": $error',
          );
        }
      }

      var loadedFromFallback = false;
      if (companies.isEmpty) {
        // Data exists but nothing is readable: run on the mock seed for this
        // session, but do not overwrite the stored data wholesale.
        companies.addAll(seed());
        loadedFromFallback = true;
        debugPrint(
          'No readable workspace data found; running on mock seed '
          'without overwriting stored records.',
        );
      }

      final storedSelectedId = meta?['selectedCompanyId'];
      final selectedId =
          storedSelectedId is String &&
              companies.any((w) => w.company.id == storedSelectedId)
          ? storedSelectedId
          : companies.first.company.id;

      return PersistentWorkspaceRepository._(
        db: db,
        tenantContext: tenantContext,
        companies: companies,
        selectedCompanyId: selectedId,
        loadedFromFallback: loadedFromFallback,
      );
    } catch (_) {
      await db.close();
      rethrow;
    }
  }

  /// Placeholder for future schema migrations (`storedVersion` <
  /// [schemaVersion]). With only schema version 1 in existence there is
  /// nothing to do yet.
  static Future<void> _migrateIfNeeded(Database db, int storedVersion) async {
    if (storedVersion >= schemaVersion) return;
    // Future migrations run here, step by step, then update the meta record.
  }

  static Map<String, Object?> _metaJson(String selectedCompanyId) => {
    'schemaVersion': schemaVersion,
    'selectedCompanyId': selectedCompanyId,
    'updatedAt': DateTime.now().toIso8601String(),
  };

  // --- reads (in-memory snapshot) ---

  @override
  List<CompanyWorkspace> get companies => _companies;

  @override
  String get selectedCompanyId => _selectedCompanyId;

  @override
  CompanyWorkspace get selectedWorkspace {
    return _companies.firstWhere(
      (workspace) => workspace.company.id == _selectedCompanyId,
      orElse: () => _companies.first,
    );
  }

  @override
  CompanyWorkspace? findWorkspace(String companyId) {
    for (final workspace in _companies) {
      if (workspace.company.id == companyId) return workspace;
    }
    return null;
  }

  // --- mutations (in-memory first, then queued persistence) ---

  @override
  bool selectCompany(String companyId) {
    if (_selectedCompanyId == companyId) return false;
    if (findWorkspace(companyId) == null) return false;
    _selectedCompanyId = companyId;
    _enqueue(() => _metaRecord.put(_db, _metaJson(_selectedCompanyId)));
    return true;
  }

  @override
  Future<bool> saveWorkspace(String companyId, CompanyWorkspace updated) {
    if (findWorkspace(companyId) == null) return Future.value(false);
    _replaceInMemory(companyId, updated);
    return _persistWorkspace(companyId, updated).then((_) => true);
  }

  @override
  Future<void> saveSelectedWorkspace(CompanyWorkspace updated) {
    final companyId = updated.company.id;
    if (findWorkspace(companyId) == null) {
      _companies = [..._companies, updated];
    } else {
      _replaceInMemory(companyId, updated);
    }
    _selectedCompanyId = companyId;
    final persisted = _persistWorkspace(companyId, updated);
    _enqueue(() => _metaRecord.put(_db, _metaJson(_selectedCompanyId)));
    return persisted;
  }

  @override
  Future<void> clear() {
    return _enqueue(() async {
      await _db.transaction((txn) async {
        await _workspacesStore.delete(txn);
        await _metaStore.delete(txn);
      });
    });
  }

  /// Completes once all writes enqueued so far have been attempted.
  /// Never throws — errors are captured in [lastPersistenceError].
  Future<void> flush() => _writeQueue;

  /// Flushes pending writes and closes the database. For tests and a clean
  /// shutdown; the app itself keeps the repository open for its lifetime.
  Future<void> dispose() async {
    await flush();
    await _db.close();
  }

  void _replaceInMemory(String companyId, CompanyWorkspace updated) {
    _companies = [
      for (final workspace in _companies)
        if (workspace.company.id == companyId) updated else workspace,
    ];
  }

  Future<void> _persistWorkspace(String companyId, CompanyWorkspace updated) {
    final json = WorkspaceCodec.encodeWorkspace(updated);
    final newId = updated.company.id;
    return _enqueue(() async {
      if (newId != companyId) {
        await _workspacesStore.record(companyId).delete(_db);
      }
      await _workspacesStore.record(newId).put(_db, json);
    });
  }

  /// Appends [action] to the serialized write queue. The returned Future
  /// reflects the action itself (including errors, for callers that await);
  /// the queue swallows the error after recording it so one failed write
  /// neither breaks subsequent writes nor crashes fire-and-forget callers.
  Future<T> _enqueue<T>(Future<T> Function() action) {
    final result = _writeQueue.then((_) => action());
    _writeQueue = result.then(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        lastPersistenceError = error;
        debugPrint('Workspace persistence write failed: $error');
      },
    );
    return result;
  }
}
