import 'dart:async';

import 'package:flutter/widgets.dart';

import '../repositories/tenant_context.dart';
import 'auth_operation_result.dart';
import 'auth_service.dart';
import 'auth_session.dart';
import 'auth_status.dart';
import 'auth_user.dart';
import 'local_auth_service.dart';
import 'tenant_membership.dart';
import 'tenant_preference_store.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._service, {TenantPreferenceStore? tenantPreferenceStore})
    : _tenantPreferenceStore =
          tenantPreferenceStore ?? MemoryTenantPreferenceStore();

  factory AuthController.local() {
    final controller = AuthController(LocalAuthService());
    controller._session = controller._service.currentSession;
    controller._user = controller._service.currentUser;
    controller._tenantContext = const TenantContext.local();
    controller._tenantMemberships = const [
      TenantMembership(
        membershipId: 'local:local-user',
        tenantId: 'local',
        tenantName: 'Lokaler Modus',
        role: 'owner',
      ),
    ];
    controller._status = AuthStatus.local;
    return controller;
  }

  final AuthService _service;
  final TenantPreferenceStore _tenantPreferenceStore;
  StreamSubscription<AuthSession?>? _subscription;

  AuthStatus _status = AuthStatus.initializing;
  AuthSession? _session;
  AuthUser? _user;
  TenantContext? _tenantContext;
  List<TenantMembership> _tenantMemberships = const [];
  String? _errorMessage;
  int _authGeneration = 0;

  AuthStatus get status => _status;
  AuthSession? get session => _session;
  AuthUser? get user => _user;
  TenantContext? get tenantContext => _tenantContext;
  List<TenantMembership> get tenantMemberships =>
      List.unmodifiable(_tenantMemberships);
  String? get errorMessage => _errorMessage;
  bool get isLocalMode => _status == AuthStatus.local;
  bool get isSupabaseMode => !_service.isLocal;
  bool get isSwitchingTenant => _status == AuthStatus.switchingTenant;
  bool get hasMultipleTenantMemberships => _tenantMemberships.length > 1;
  bool get canOpenProtectedRoutes =>
      _status == AuthStatus.local || _status == AuthStatus.authenticated;

  Future<void> initialize() async {
    _setStatus(AuthStatus.initializing);
    try {
      final restored = await _service.restoreSession();
      await _applySession(restored, notify: false);
      _subscription = _service.authStateChanges.listen((session) {
        unawaited(_applySession(session));
      });
    } catch (error) {
      _errorMessage = _safeError(error);
      _setStatus(AuthStatus.error);
    }
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    await _runAuthOperation(
      () => _service.signIn(email: email, password: password),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _runAuthOperation(
      () => _service.signUp(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
  }

  Future<void> signOut() async {
    if (_service.isLocal) return;
    try {
      await _service.signOut();
      _session = null;
      _user = null;
      _tenantContext = null;
      _tenantMemberships = const [];
      _errorMessage = null;
      _setStatus(AuthStatus.unauthenticated);
    } catch (error) {
      _errorMessage = _safeError(error);
      notifyListeners();
    }
  }

  Future<void> refreshTenantContext() async {
    if (_service.isLocal) {
      _tenantContext = const TenantContext.local();
      final user = _session?.user ?? _service.currentUser;
      _tenantMemberships = user == null
          ? const []
          : await _service.loadTenantMemberships(user);
      _setStatus(AuthStatus.local);
      return;
    }
    final session = _session ?? _service.currentSession;
    if (session == null) {
      _tenantContext = null;
      _setStatus(AuthStatus.unauthenticated);
      return;
    }
    await _applySession(session);
  }

  Future<void> resetPassword(String email) async {
    try {
      await _service.resetPassword(email);
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = _safeError(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePassword(String password) async {
    try {
      await _service.updatePassword(password);
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = _safeError(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _runAuthOperation(
    Future<AuthOperationResult> Function() action,
  ) async {
    try {
      _setStatus(AuthStatus.initializing);
      final result = await action();
      if (result.session != null) {
        await _applySession(result.session);
        return;
      }
      _session = null;
      _user = result.user;
      _tenantContext = null;
      _errorMessage = result.message;
      _setStatus(
        result.user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.onboardingRequired,
      );
    } catch (error) {
      _errorMessage = _safeError(error);
      _session = null;
      _user = null;
      _tenantContext = null;
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<void> _applySession(AuthSession? session, {bool notify = true}) async {
    final generation = ++_authGeneration;
    _session = session;
    _user = session?.user ?? _service.currentUser;
    _errorMessage = null;

    if (_service.isLocal) {
      _tenantContext = const TenantContext.local();
      final user = session?.user ?? _service.currentUser;
      _tenantMemberships = user == null
          ? const []
          : await _service.loadTenantMemberships(user);
      _status = AuthStatus.local;
    } else if (session == null) {
      _tenantContext = null;
      _tenantMemberships = const [];
      _status = AuthStatus.unauthenticated;
    } else {
      await _resolveMembershipSelection(session.user, generation);
    }
    if (notify) notifyListeners();
  }

  Future<void> _resolveMembershipSelection(
    AuthUser user,
    int generation,
  ) async {
    final memberships = await _service.loadTenantMemberships(user);
    if (generation != _authGeneration) return;
    _tenantMemberships = memberships;

    if (memberships.isEmpty) {
      _tenantContext = null;
      _status = AuthStatus.onboardingRequired;
      return;
    }
    if (memberships.length == 1) {
      _tenantContext = memberships.single.toTenantContext(user);
      await _tenantPreferenceStore.saveLastTenantId(
        user.id,
        memberships.single.tenantId,
      );
      if (generation != _authGeneration) return;
      _status = AuthStatus.authenticated;
      return;
    }

    final lastTenantId = await _tenantPreferenceStore.readLastTenantId(user.id);
    if (generation != _authGeneration) return;
    final preferred = _membershipByTenantId(lastTenantId);
    if (preferred != null) {
      _tenantContext = preferred.toTenantContext(user);
      _status = AuthStatus.authenticated;
      return;
    }

    _tenantContext = null;
    _status = AuthStatus.tenantSelectionRequired;
  }

  Future<bool> selectTenant(String tenantId) async {
    if (_service.isLocal) return true;
    if (_status == AuthStatus.switchingTenant) return false;
    final user = _user ?? _session?.user ?? _service.currentUser;
    if (user == null) {
      _tenantContext = null;
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
    final membership = _membershipByTenantId(tenantId);
    if (membership == null) {
      _tenantContext = null;
      _errorMessage = 'Tenant access is no longer available.';
      _setStatus(
        _tenantMemberships.isEmpty
            ? AuthStatus.onboardingRequired
            : AuthStatus.tenantSelectionRequired,
      );
      return false;
    }

    final generation = ++_authGeneration;
    _tenantContext = null;
    _errorMessage = null;
    _setStatus(AuthStatus.switchingTenant);
    await _tenantPreferenceStore.saveLastTenantId(user.id, membership.tenantId);
    if (generation != _authGeneration) return false;
    _tenantContext = membership.toTenantContext(user);
    _setStatus(AuthStatus.authenticated);
    return true;
  }

  Future<void> reloadTenantMemberships() async {
    if (_service.isLocal) return;
    final session = _session ?? _service.currentSession;
    if (session == null) {
      _tenantContext = null;
      _tenantMemberships = const [];
      _setStatus(AuthStatus.unauthenticated);
      return;
    }
    await _applySession(session);
  }

  TenantMembership? _membershipByTenantId(String? tenantId) {
    if (tenantId == null || tenantId.trim().isEmpty) return null;
    for (final membership in _tenantMemberships) {
      if (membership.tenantId == tenantId && membership.isActive) {
        return membership;
      }
    }
    return null;
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  String _safeError(Object error) {
    final text = error.toString();
    if (text.trim().isEmpty) return 'Authentication failed.';
    if (text.length > 180) return 'Authentication failed.';
    return text.replaceFirst(RegExp(r'^(AuthException|Exception):\s*'), '');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  static AuthController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthScope>()!.notifier!;
  }
}

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({super.key, required super.notifier, required super.child});
}
