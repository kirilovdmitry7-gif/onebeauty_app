enum AuthErrorCode {
  emailPasswordRequired,
  phoneCodeRequired,
  invalidCode,
  unknown,
}

class AuthError implements Exception {
  final AuthErrorCode code;
  const AuthError(this.code);

  @override
  String toString() => 'AuthError($code)';
}
