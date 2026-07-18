import 'auth_session.dart';
import 'auth_user.dart';

class AuthOperationResult {
  const AuthOperationResult({this.session, this.user, this.message});

  final AuthSession? session;
  final AuthUser? user;
  final String? message;
}
