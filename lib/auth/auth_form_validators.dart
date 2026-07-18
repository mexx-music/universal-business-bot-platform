class AuthFormValidators {
  const AuthFormValidators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isValidEmail(String value) {
    return _emailPattern.hasMatch(value.trim());
  }

  static bool isValidPassword(String value) {
    return value.length >= 6;
  }
}
