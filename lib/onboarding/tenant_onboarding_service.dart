import 'tenant_onboarding_data_source.dart';
import 'tenant_onboarding_models.dart';

class TenantOnboardingService {
  const TenantOnboardingService({
    required TenantOnboardingDataSource dataSource,
  }) : _dataSource = dataSource;

  final TenantOnboardingDataSource _dataSource;

  Future<TenantOnboardingResult> createInitialWorkspace(
    TenantOnboardingInput input,
  ) async {
    final normalized = _validate(input);
    try {
      final row = await _dataSource.createInitialWorkspace(normalized);
      return TenantOnboardingResult(
        tenantId: _string(row['tenant_id']),
        workspaceId: _string(row['workspace_id']),
        companyId: _string(row['company_id']),
      );
    } on TenantOnboardingException {
      rethrow;
    } catch (error) {
      final text = error.toString().toLowerCase();
      if (text.contains('already_completed') ||
          text.contains('duplicate key')) {
        throw const OnboardingAlreadyCompletedException();
      }
      if (text.contains('authentication_required') ||
          text.contains('jwt') ||
          text.contains('auth')) {
        throw const OnboardingUnauthenticatedException();
      }
      if (text.contains('invalid_company_name')) {
        throw const OnboardingValidationException('invalid_company_name');
      }
      if (text.contains('invalid_primary_language')) {
        throw const OnboardingValidationException('invalid_primary_language');
      }
      if (text.contains('invalid_website')) {
        throw const OnboardingValidationException('invalid_website');
      }
      throw OnboardingRemoteException('Tenant onboarding failed.', error);
    }
  }

  TenantOnboardingInput _validate(TenantOnboardingInput input) {
    final normalized = input.normalized();
    final name = normalized.companyName;
    if (name.length < 2 || name.length > 120 || !_containsLetterOrDigit(name)) {
      throw const OnboardingValidationException('invalid_company_name');
    }

    final description = normalized.shortDescription;
    if (description != null && description.length > 600) {
      throw const OnboardingValidationException('invalid_short_description');
    }

    if (!const {'de', 'en'}.contains(normalized.primaryLanguage)) {
      throw const OnboardingValidationException('invalid_primary_language');
    }

    final website = normalized.website;
    if (website != null && !_isValidHttpsUrl(website)) {
      throw const OnboardingValidationException('invalid_website');
    }

    return normalized;
  }

  bool _containsLetterOrDigit(String value) {
    return RegExp(r'[A-Za-z0-9ÄÖÜäöüß]').hasMatch(value);
  }

  bool _isValidHttpsUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'https') return false;
    if (uri.host.trim().isEmpty || !uri.host.contains('.')) return false;
    return true;
  }

  String _string(Object? value) => value?.toString().trim() ?? '';
}
