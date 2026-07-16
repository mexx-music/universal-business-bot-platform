import 'package:sembast_web/sembast_web.dart';

/// Web persistence backend: sembast on top of IndexedDB.
DatabaseFactory? get defaultPersistenceDatabaseFactory => databaseFactoryWeb;
