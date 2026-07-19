import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../../auth/auth_form_validators.dart';
import '../../auth/auth_status.dart';
import '../../l10n/app_localizations.dart';

enum _AuthFormMode { signIn, signUp, resetPassword }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  _AuthFormMode _mode = _AuthFormMode.signIn;
  bool _acceptedTerms = false;
  bool _submitting = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = AuthController.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hub_rounded,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _title(l),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _subtitle(l),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (auth.status == AuthStatus.onboardingRequired) ...[
                          const SizedBox(height: 16),
                          _InfoBanner(
                            icon: Icons.info_outline,
                            text: l.authOnboardingRequired,
                          ),
                        ],
                        if (_message != null) ...[
                          const SizedBox(height: 16),
                          _InfoBanner(
                            icon: Icons.mark_email_read_outlined,
                            text: _message!,
                          ),
                        ],
                        if (auth.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          _InfoBanner(
                            icon: Icons.error_outline,
                            text: auth.errorMessage ?? l.authGenericError,
                            isError: true,
                          ),
                        ],
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            labelText: l.authEmailLabel,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (!AuthFormValidators.isValidEmail(value ?? '')) {
                              return l.authInvalidEmail;
                            }
                            return null;
                          },
                        ),
                        if (_mode != _AuthFormMode.resetPassword) ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              labelText: l.authPasswordLabel,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (!AuthFormValidators.isValidPassword(
                                value ?? '',
                              )) {
                                return l.authPasswordTooShort;
                              }
                              return null;
                            },
                          ),
                        ],
                        if (_mode == _AuthFormMode.signUp) ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l.authDisplayNameLabel,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _acceptedTerms,
                            onChanged: (value) =>
                                setState(() => _acceptedTerms = value ?? false),
                            title: Text(l.authAcceptTerms),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _submitting ? null : () => _submit(auth),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _submitting ? l.authPleaseWait : _primaryLabel(l),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_mode == _AuthFormMode.signIn)
                          OutlinedButton(
                            onPressed: _submitting
                                ? null
                                : () => setState(() {
                                    _mode = _AuthFormMode.signUp;
                                    _message = null;
                                  }),
                            child: Text(l.authCreateAccount),
                          ),
                        if (_mode != _AuthFormMode.signIn)
                          TextButton(
                            onPressed: _submitting
                                ? null
                                : () => setState(() {
                                    _mode = _AuthFormMode.signIn;
                                    _message = null;
                                  }),
                            child: Text(l.authBackToSignIn),
                          ),
                        TextButton(
                          onPressed: _submitting
                              ? null
                              : () => setState(() {
                                  _mode = _AuthFormMode.resetPassword;
                                  _message = null;
                                }),
                          child: Text(l.authForgotPassword),
                        ),
                        const Divider(height: 28),
                        TextButton.icon(
                          onPressed: () => context.go('/'),
                          icon: const Icon(Icons.arrow_back),
                          label: Text(l.authBackHome),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _title(AppLocalizations l) {
    return switch (_mode) {
      _AuthFormMode.signIn => l.authSignInTitle,
      _AuthFormMode.signUp => l.authSignUpTitle,
      _AuthFormMode.resetPassword => l.authResetTitle,
    };
  }

  String _subtitle(AppLocalizations l) {
    return switch (_mode) {
      _AuthFormMode.signIn => l.authSignInSubtitle,
      _AuthFormMode.signUp => l.authSignUpSubtitle,
      _AuthFormMode.resetPassword => l.authResetSubtitle,
    };
  }

  String _primaryLabel(AppLocalizations l) {
    return switch (_mode) {
      _AuthFormMode.signIn => l.authSignInButton,
      _AuthFormMode.signUp => l.authSignUpButton,
      _AuthFormMode.resetPassword => l.authResetButton,
    };
  }

  Future<void> _submit(AuthController auth) async {
    final l = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_mode == _AuthFormMode.signUp && !_acceptedTerms) {
      setState(() => _message = l.authTermsRequired);
      return;
    }

    setState(() {
      _submitting = true;
      _message = null;
    });

    try {
      final email = _emailController.text.trim();
      if (_mode == _AuthFormMode.signIn) {
        await auth.signIn(email: email, password: _passwordController.text);
      } else if (_mode == _AuthFormMode.signUp) {
        final result = await auth.signUp(
          email: email,
          password: _passwordController.text,
          displayName: _nameController.text,
        );
        _message = result.user == null ? null : l.authVerificationHint;
      } else {
        await auth.resetPassword(email);
        _message = l.authResetSent;
      }

      if (!mounted) return;
      if (auth.canOpenProtectedRoutes) {
        final from = GoRouterState.of(context).uri.queryParameters['from'];
        context.go(from == null || from.isEmpty ? '/companies' : from);
      } else if (auth.status == AuthStatus.onboardingRequired) {
        context.go('/onboarding');
      } else {
        setState(() {});
      }
    } catch (_) {
      if (mounted) setState(() {});
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.text,
    this.isError = false,
  });

  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? colors.errorContainer : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isError
                ? colors.onErrorContainer
                : colors.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isError
                    ? colors.onErrorContainer
                    : colors.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
