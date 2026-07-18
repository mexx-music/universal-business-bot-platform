import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'tenant_onboarding_models.dart';

abstract class TenantOnboardingDataSource {
  Future<Map<String, Object?>> createInitialWorkspace(
    TenantOnboardingInput input,
  );
}

class SupabaseTenantOnboardingDataSource implements TenantOnboardingDataSource {
  const SupabaseTenantOnboardingDataSource(this._client);

  final sb.SupabaseClient _client;

  @override
  Future<Map<String, Object?>> createInitialWorkspace(
    TenantOnboardingInput input,
  ) async {
    final normalized = input.normalized();
    final rows = await _client.rpc<List<dynamic>>(
      'create_initial_tenant_workspace',
      params: {
        'company_name': normalized.companyName,
        'website': normalized.website,
        'industry': normalized.industry,
        'short_description': normalized.shortDescription,
        'primary_language': normalized.primaryLanguage,
        'workspace_name': normalized.workspaceName,
      },
    );

    if (rows.isEmpty || rows.first is! Map) {
      throw const OnboardingRemoteException(
        'Onboarding returned no workspace.',
      );
    }
    return (rows.first as Map).cast<String, Object?>();
  }
}

class UnsupportedTenantOnboardingDataSource
    implements TenantOnboardingDataSource {
  const UnsupportedTenantOnboardingDataSource();

  @override
  Future<Map<String, Object?>> createInitialWorkspace(
    TenantOnboardingInput input,
  ) async {
    throw const OnboardingRemoteException(
      'Tenant onboarding is not available in local mode.',
    );
  }
}
