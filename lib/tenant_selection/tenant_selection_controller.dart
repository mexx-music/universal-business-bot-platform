import 'package:flutter/widgets.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_status.dart';
import '../auth/tenant_membership.dart';
import '../data/app_state.dart';

enum TenantSelectionStatus {
  initial,
  loadingMemberships,
  selectionRequired,
  switching,
  active,
  empty,
  error,
}

class TenantSelectionController extends ChangeNotifier {
  TenantSelectionController({
    required AuthController authController,
    required AppState appState,
  }) : _authController = authController,
       _appState = appState {
    _authController.addListener(_forwardAuthState);
  }

  final AuthController _authController;
  final AppState _appState;
  String? _errorMessage;

  List<TenantMembership> get memberships => _authController.tenantMemberships;
  String? get activeTenantId => _authController.tenantContext?.tenantId;
  String? get activeTenantName => _authController.tenantContext?.tenantName;
  String? get errorMessage => _errorMessage ?? _authController.errorMessage;

  TenantSelectionStatus get status {
    return switch (_authController.status) {
      AuthStatus.initializing => TenantSelectionStatus.loadingMemberships,
      AuthStatus.switchingTenant => TenantSelectionStatus.switching,
      AuthStatus.tenantSelectionRequired =>
        TenantSelectionStatus.selectionRequired,
      AuthStatus.onboardingRequired => TenantSelectionStatus.empty,
      AuthStatus.authenticated => TenantSelectionStatus.active,
      AuthStatus.error => TenantSelectionStatus.error,
      _ => TenantSelectionStatus.initial,
    };
  }

  bool get isSwitching => status == TenantSelectionStatus.switching;
  bool get canSwitchNow => !_appState.isSavingWorkspace && !isSwitching;

  Future<bool> refresh() async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _authController.reloadTenantMemberships();
      return true;
    } catch (_) {
      _errorMessage = 'Tenant access could not be refreshed.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> selectTenant(String tenantId) async {
    if (!canSwitchNow) {
      _errorMessage = 'Please wait until the current save operation finishes.';
      notifyListeners();
      return false;
    }
    _errorMessage = null;
    notifyListeners();
    final ok = await _authController.selectTenant(tenantId);
    if (!ok && _errorMessage == null) {
      _errorMessage = 'Tenant switch failed.';
      notifyListeners();
    }
    return ok;
  }

  void _forwardAuthState() => notifyListeners();

  @override
  void dispose() {
    _authController.removeListener(_forwardAuthState);
    super.dispose();
  }

  static TenantSelectionController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TenantSelectionScope>()!
        .notifier!;
  }
}

class TenantSelectionScope
    extends InheritedNotifier<TenantSelectionController> {
  const TenantSelectionScope({
    super.key,
    required super.notifier,
    required super.child,
  });
}
