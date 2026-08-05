import 'package:supabase_flutter/supabase_flutter.dart';

import 'edge_function_client.dart';

/// Production [EdgeFunctionClient] backed by an initialized Supabase client.
///
/// This is the ONLY file in the AI layer that imports `supabase_flutter`. It
/// normalizes both success and error responses (Supabase throws
/// [FunctionException] on non-2xx) into a plain [EdgeFunctionResponse] so the
/// transport can map the machine-readable `error.code` uniformly.
class SupabaseEdgeFunctionClient implements EdgeFunctionClient {
  const SupabaseEdgeFunctionClient(this._client);

  final SupabaseClient _client;

  @override
  Future<EdgeFunctionResponse> invoke(
    String functionName, {
    required Map<String, Object?> body,
  }) async {
    try {
      final res = await _client.functions.invoke(functionName, body: body);
      return EdgeFunctionResponse(status: res.status, data: _asMap(res.data));
    } on FunctionException catch (e) {
      // Non-2xx: the error body (with error.code) rides in `details`.
      return EdgeFunctionResponse(status: e.status, data: _asMap(e.details));
    }
    // Any other error (network/SDK) propagates and is mapped by the transport.
  }

  Map<String, Object?>? _asMap(Object? data) {
    if (data is Map<String, Object?>) return data;
    if (data is Map) return data.cast<String, Object?>();
    return null;
  }
}
