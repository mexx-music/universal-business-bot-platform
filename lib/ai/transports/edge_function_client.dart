/// A tiny, injectable abstraction over "invoke a Supabase Edge Function".
///
/// The transport depends only on this interface — not on `supabase_flutter` —
/// so it can be unit-tested with a fake and no network. The production
/// implementation ([SupabaseEdgeFunctionClient]) is the only place that
/// touches the Supabase SDK.
abstract interface class EdgeFunctionClient {
  /// Invokes [functionName] with a JSON [body]. Must return the HTTP status
  /// and decoded JSON body (including for error statuses, where the body
  /// carries the machine-readable `error.code`). May throw for pure network
  /// failures — the transport maps those to a network error.
  Future<EdgeFunctionResponse> invoke(
    String functionName, {
    required Map<String, Object?> body,
  });
}

class EdgeFunctionResponse {
  const EdgeFunctionResponse({required this.status, this.data});

  final int status;

  /// Decoded JSON object, or null when the body was empty/non-object.
  final Map<String, Object?>? data;
}

/// Thrown when a real provider is explicitly selected but its required
/// configuration is missing (e.g. AI_PROVIDER=gemini without an initialized
/// Supabase transport). Never carries secrets.
class AiConfigurationException implements Exception {
  const AiConfigurationException(this.message);

  final String message;

  @override
  String toString() => 'AiConfigurationException: $message';
}
