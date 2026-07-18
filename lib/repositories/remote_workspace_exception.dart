class RemoteWorkspaceException implements Exception {
  const RemoteWorkspaceException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class MissingTenantException extends RemoteWorkspaceException {
  const MissingTenantException()
    : super('No active tenant membership is available.');
}

class NoActiveWorkspaceException extends RemoteWorkspaceException {
  const NoActiveWorkspaceException()
    : super('No active workspace is available.');
}

class MissingSessionException extends RemoteWorkspaceException {
  const MissingSessionException() : super('No active session is available.');
}

class NoWritePermissionException extends RemoteWorkspaceException {
  const NoWritePermissionException()
    : super('The current role is not allowed to change this workspace.');
}

class RepositoryRecordNotFoundException extends RemoteWorkspaceException {
  const RepositoryRecordNotFoundException()
    : super('The requested record was not found.');
}

class RepositoryValidationException extends RemoteWorkspaceException {
  const RepositoryValidationException(super.message, [super.cause]);
}

class RepositoryConflictException extends RemoteWorkspaceException {
  const RepositoryConflictException(super.message, [super.cause]);
}

class RepositoryTechnicalException extends RemoteWorkspaceException {
  const RepositoryTechnicalException(super.message, [super.cause]);
}
