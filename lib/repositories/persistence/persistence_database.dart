// Platform switch for the persistence backend. On the web this resolves to
// the IndexedDB-backed sembast factory; on all other platforms the stub
// returns null and the composition root falls back to the in-memory
// LocalWorkspaceRepository. Never import sembast_web outside the web branch.
export 'persistence_database_stub.dart'
    if (dart.library.js_interop) 'persistence_database_web.dart';
