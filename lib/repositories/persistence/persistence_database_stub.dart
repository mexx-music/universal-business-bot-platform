import 'package:sembast/sembast.dart';

/// Non-web platforms have no default persistence backend yet; the
/// composition root falls back to the in-memory repository.
DatabaseFactory? get defaultPersistenceDatabaseFactory => null;
