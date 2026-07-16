@TestOn('browser')
library;

// Runs against real IndexedDB in Chrome:
//   flutter test --platform chrome test/web_persistence_browser_test.dart
// Verifies the actual web storage path (open → mutate → close → reopen),
// which the VM tests can only simulate with the in-memory factory.

import 'package:flutter_test/flutter_test.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:universalbusiness/repositories/persistent_workspace_repository.dart';

void main() {
  test('workspace changes survive close and reopen on real IndexedDB',
      () async {
    const dbName = 'universalbusiness_browser_test.db';

    // Start from empty storage.
    await databaseFactoryWeb.deleteDatabase(dbName);

    final repo = await PersistentWorkspaceRepository.open(
      databaseFactory: databaseFactoryWeb,
      dbName: dbName,
    );
    expect(repo.companies, isNotEmpty);
    final secondId = repo.companies.last.company.id;

    await repo.saveSelectedWorkspace(
      repo.selectedWorkspace.copyWith(
        company: repo.selectedWorkspace.company.copyWith(
          name: 'IndexedDB Reload Check',
        ),
      ),
    );
    repo.selectCompany(secondId);
    await repo.dispose();

    final reloaded = await PersistentWorkspaceRepository.open(
      databaseFactory: databaseFactoryWeb,
      dbName: dbName,
    );
    expect(reloaded.selectedCompanyId, secondId);
    expect(
      reloaded.companies.first.company.name,
      'IndexedDB Reload Check',
    );
    await reloaded.dispose();
    await databaseFactoryWeb.deleteDatabase(dbName);
  });
}
