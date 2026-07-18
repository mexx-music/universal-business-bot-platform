enum TenantOnboardingStatus { initial, editing, submitting, success, error }

class TenantOnboardingInput {
  const TenantOnboardingInput({
    required this.companyName,
    this.website,
    this.industry,
    this.shortDescription,
    this.primaryLanguage = 'de',
    this.workspaceName,
  });

  final String companyName;
  final String? website;
  final String? industry;
  final String? shortDescription;
  final String primaryLanguage;
  final String? workspaceName;

  TenantOnboardingInput normalized() {
    return TenantOnboardingInput(
      companyName: companyName.trim(),
      website: _normalizeWebsite(website),
      industry: _emptyToNull(industry),
      shortDescription: _emptyToNull(shortDescription),
      primaryLanguage: primaryLanguage.trim().toLowerCase(),
      workspaceName: _emptyToNull(workspaceName),
    );
  }

  static String? _emptyToNull(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }

  static String? _normalizeWebsite(String? value) {
    final clean = _emptyToNull(value);
    if (clean == null) return null;
    final lower = clean.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return clean;
    }
    return 'https://$clean';
  }
}

class TenantOnboardingResult {
  const TenantOnboardingResult({
    required this.tenantId,
    required this.workspaceId,
    required this.companyId,
  });

  final String tenantId;
  final String workspaceId;
  final String companyId;
}

class TenantOnboardingException implements Exception {
  const TenantOnboardingException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class OnboardingValidationException extends TenantOnboardingException {
  const OnboardingValidationException(super.message, [super.cause]);
}

class OnboardingAlreadyCompletedException extends TenantOnboardingException {
  const OnboardingAlreadyCompletedException()
    : super('Initial tenant onboarding is already completed.');
}

class OnboardingUnauthenticatedException extends TenantOnboardingException {
  const OnboardingUnauthenticatedException()
    : super('No authenticated session is available.');
}

class OnboardingConflictException extends TenantOnboardingException {
  const OnboardingConflictException(super.message, [super.cause]);
}

class OnboardingRemoteException extends TenantOnboardingException {
  const OnboardingRemoteException(super.message, [super.cause]);
}
