class PublicIntakeUrlException implements Exception {
  const PublicIntakeUrlException(this.message);

  final String message;

  @override
  String toString() => message;
}

Uri buildPublicIntakeUrl(
  String token, {
  Uri? baseUri,
  String publicAppUrl = const String.fromEnvironment('PUBLIC_APP_URL'),
}) {
  final normalizedToken = token.trim();
  if (normalizedToken.isEmpty) {
    throw const PublicIntakeUrlException('Missing invitation token.');
  }

  final currentBase = baseUri ?? Uri.base;
  final origin =
      _httpOriginOrNull(currentBase) ?? _configuredOrigin(publicAppUrl);
  if (origin == null) {
    throw const PublicIntakeUrlException(
      'No public HTTP(S) base URL is configured for invitation links.',
    );
  }

  return Uri(
    scheme: origin.scheme,
    host: origin.host,
    port: origin.hasPort ? origin.port : null,
    pathSegments: ['onboarding', normalizedToken],
  );
}

Uri? _httpOriginOrNull(Uri uri) {
  if (!_isHttpScheme(uri.scheme) || uri.host.trim().isEmpty) return null;
  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
  );
}

Uri? _configuredOrigin(String publicAppUrl) {
  final value = publicAppUrl.trim();
  if (value.isEmpty) return null;
  final uri = Uri.tryParse(value);
  if (uri == null) return null;
  return _httpOriginOrNull(uri);
}

bool _isHttpScheme(String scheme) {
  return scheme == 'http' || scheme == 'https';
}
