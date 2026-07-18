import 'package:flutter/widgets.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_status.dart';
import 'tenant_onboarding_models.dart';
import 'tenant_onboarding_service.dart';

class OnboardingController extends ChangeNotifier {
  OnboardingController({
    required AuthController authController,
    required TenantOnboardingService onboardingService,
  }) : _authController = authController,
       _onboardingService = onboardingService;

  final AuthController _authController;
  final TenantOnboardingService _onboardingService;

  TenantOnboardingStatus _status = TenantOnboardingStatus.initial;
  String? _errorCode;
  TenantOnboardingInput _input = const TenantOnboardingInput(companyName: '');
  int _generation = 0;

  TenantOnboardingStatus get status => _status;
  String? get errorCode => _errorCode;
  TenantOnboardingInput get input => _input;
  bool get isSubmitting => _status == TenantOnboardingStatus.submitting;

  void updateInput(TenantOnboardingInput input) {
    _input = input;
    if (_status == TenantOnboardingStatus.initial) {
      _status = TenantOnboardingStatus.editing;
    }
    _errorCode = null;
    notifyListeners();
  }

  Future<bool> submit(TenantOnboardingInput input) async {
    if (isSubmitting) return false;
    final generation = ++_generation;
    _input = input;
    _status = TenantOnboardingStatus.submitting;
    _errorCode = null;
    notifyListeners();

    try {
      if (_authController.status != AuthStatus.onboardingRequired) {
        await _authController.refreshTenantContext();
        if (_authController.status == AuthStatus.authenticated) {
          return _completeIfCurrent(generation);
        }
        throw const OnboardingUnauthenticatedException();
      }

      await _onboardingService.createInitialWorkspace(input);
      await _authController.refreshTenantContext();
      if (_authController.status == AuthStatus.authenticated) {
        return _completeIfCurrent(generation);
      }
      throw const OnboardingRemoteException(
        'Membership could not be resolved.',
      );
    } on OnboardingAlreadyCompletedException {
      await _authController.refreshTenantContext();
      if (_authController.status == AuthStatus.authenticated) {
        return _completeIfCurrent(generation);
      }
      _failIfCurrent(generation, 'already_completed');
      return false;
    } on OnboardingValidationException catch (error) {
      _failIfCurrent(generation, error.message);
      return false;
    } on OnboardingUnauthenticatedException {
      _failIfCurrent(generation, 'session_expired');
      return false;
    } catch (_) {
      await _authController.refreshTenantContext();
      if (_authController.status == AuthStatus.authenticated) {
        return _completeIfCurrent(generation);
      }
      _failIfCurrent(generation, 'remote_error');
      return false;
    }
  }

  void cancelPending() {
    _generation++;
    if (isSubmitting) {
      _status = TenantOnboardingStatus.editing;
      notifyListeners();
    }
  }

  bool _completeIfCurrent(int generation) {
    if (generation != _generation) return false;
    _status = TenantOnboardingStatus.success;
    _errorCode = null;
    notifyListeners();
    return true;
  }

  void _failIfCurrent(int generation, String errorCode) {
    if (generation != _generation) return;
    _status = TenantOnboardingStatus.error;
    _errorCode = errorCode;
    notifyListeners();
  }

  static OnboardingController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<OnboardingScope>()!
        .notifier!;
  }
}

class OnboardingScope extends InheritedNotifier<OnboardingController> {
  const OnboardingScope({
    super.key,
    required super.notifier,
    required super.child,
  });
}
