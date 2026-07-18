import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../onboarding/onboarding_controller.dart';
import '../../onboarding/tenant_onboarding_models.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _websiteController = TextEditingController();
  final _industryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _workspaceController = TextEditingController();
  String _language = 'de';

  @override
  void dispose() {
    _companyController.dispose();
    _websiteController.dispose();
    _industryController.dispose();
    _descriptionController.dispose();
    _workspaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final controller = OnboardingController.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) {
                      final submitting = controller.isSubmitting;
                      return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.domain_add_outlined,
                              size: 44,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l.onboardingTitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l.onboardingSubtitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (controller.errorCode != null) ...[
                              const SizedBox(height: 18),
                              _MessageBanner(
                                text: _errorText(l, controller.errorCode!),
                                isError: true,
                              ),
                            ],
                            if (controller.status ==
                                TenantOnboardingStatus.success) ...[
                              const SizedBox(height: 18),
                              _MessageBanner(text: l.onboardingSuccess),
                            ],
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _companyController,
                              enabled: !submitting,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l.onboardingCompanyNameLabel,
                                helperText: l.onboardingCompanyNameHelper,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  _validateCompanyName(l, value ?? ''),
                              onChanged: (_) => _syncController(controller),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _websiteController,
                              enabled: !submitting,
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l.onboardingWebsiteLabel,
                                helperText: l.onboardingWebsiteHelper,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  _validateWebsite(l, value ?? ''),
                              onChanged: (_) => _syncController(controller),
                            ),
                            const SizedBox(height: 14),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final compact = constraints.maxWidth < 620;
                                final industry = TextFormField(
                                  controller: _industryController,
                                  enabled: !submitting,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: l.onboardingIndustryLabel,
                                    helperText: l.onboardingIndustryHelper,
                                    border: const OutlineInputBorder(),
                                  ),
                                  onChanged: (_) => _syncController(controller),
                                );
                                final language =
                                    DropdownButtonFormField<String>(
                                      initialValue: _language,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        labelText: l.onboardingLanguageLabel,
                                        border: const OutlineInputBorder(),
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                          value: 'de',
                                          child: Text(l.languageGerman),
                                        ),
                                        DropdownMenuItem(
                                          value: 'en',
                                          child: Text(l.languageEnglish),
                                        ),
                                      ],
                                      onChanged: submitting
                                          ? null
                                          : (value) {
                                              setState(
                                                () => _language = value ?? 'de',
                                              );
                                              _syncController(controller);
                                            },
                                    );
                                if (compact) {
                                  return Column(
                                    children: [
                                      industry,
                                      const SizedBox(height: 14),
                                      language,
                                    ],
                                  );
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: industry),
                                    const SizedBox(width: 14),
                                    SizedBox(width: 180, child: language),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _descriptionController,
                              enabled: !submitting,
                              minLines: 3,
                              maxLines: 5,
                              maxLength: 600,
                              decoration: InputDecoration(
                                labelText: l.onboardingDescriptionLabel,
                                helperText: l.onboardingDescriptionHelper,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  (value ?? '').trim().length > 600
                                  ? l.onboardingDescriptionTooLong
                                  : null,
                              onChanged: (_) => _syncController(controller),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _workspaceController,
                              enabled: !submitting,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: l.onboardingWorkspaceLabel,
                                helperText: l.onboardingWorkspaceHelper,
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (_) => _syncController(controller),
                              onFieldSubmitted: (_) =>
                                  submitting ? null : _submit(controller),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: submitting
                                  ? null
                                  : () => _submit(controller),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Text(
                                  submitting
                                      ? l.onboardingSubmitting
                                      : l.onboardingSubmit,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton.icon(
                              onPressed: submitting
                                  ? null
                                  : () => context.go('/'),
                              icon: const Icon(Icons.arrow_back),
                              label: Text(l.authBackHome),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(OnboardingController controller) async {
    if (!_formKey.currentState!.validate()) return;
    final success = await controller.submit(_input());
    if (!mounted || !success) return;
    context.go('/dashboard');
  }

  void _syncController(OnboardingController controller) {
    controller.updateInput(_input());
  }

  TenantOnboardingInput _input() {
    return TenantOnboardingInput(
      companyName: _companyController.text,
      website: _websiteController.text,
      industry: _industryController.text,
      shortDescription: _descriptionController.text,
      primaryLanguage: _language,
      workspaceName: _workspaceController.text,
    );
  }

  String? _validateCompanyName(AppLocalizations l, String value) {
    final clean = value.trim();
    if (clean.isEmpty) return l.onboardingCompanyNameRequired;
    if (clean.length < 2) return l.onboardingCompanyNameTooShort;
    if (clean.length > 120) return l.onboardingCompanyNameTooLong;
    if (!RegExp(r'[A-Za-z0-9ÄÖÜäöüß]').hasMatch(clean)) {
      return l.onboardingCompanyNameInvalid;
    }
    return null;
  }

  String? _validateWebsite(AppLocalizations l, String value) {
    final clean = value.trim();
    if (clean.isEmpty) return null;
    final normalized =
        clean.toLowerCase().startsWith('http://') ||
            clean.toLowerCase().startsWith('https://')
        ? clean
        : 'https://$clean';
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        !uri.host.contains('.')) {
      return l.onboardingWebsiteInvalid;
    }
    return null;
  }

  String _errorText(AppLocalizations l, String code) {
    return switch (code) {
      'invalid_company_name' => l.onboardingCompanyNameInvalid,
      'invalid_short_description' => l.onboardingDescriptionTooLong,
      'invalid_primary_language' => l.onboardingLanguageInvalid,
      'invalid_website' => l.onboardingWebsiteInvalid,
      'already_completed' => l.onboardingAlreadyCompleted,
      'session_expired' => l.onboardingSessionExpired,
      _ => l.onboardingRemoteError,
    };
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.text, this.isError = false});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? colors.errorContainer : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isError
              ? colors.onErrorContainer
              : colors.onSecondaryContainer,
        ),
      ),
    );
  }
}
