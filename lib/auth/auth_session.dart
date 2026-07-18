import 'auth_user.dart';

class AuthSession {
  const AuthSession({required this.user, this.expiresAt});

  final AuthUser user;
  final DateTime? expiresAt;
}
