import 'package:shared_preferences/shared_preferences.dart';
import 'auth_errors.dart';

class AuthUser {
  final String? email;
  final String? phone;
  final String? displayName;
  const AuthUser({this.email, this.phone, this.displayName});
}

class AuthService {
  static const _keySignedIn = 'auth_signed_in_v1';
  static const _keyEmail = 'auth_email_v1';
  static const _keyPhone = 'auth_phone_v1';

  Future<AuthUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final signed = prefs.getBool(_keySignedIn) ?? false;
    if (!signed) return null;
    return AuthUser(
      email: prefs.getString(_keyEmail),
      phone: prefs.getString(_keyPhone),
    );
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySignedIn, false);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPhone);
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const AuthError(AuthErrorCode.emailPasswordRequired);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySignedIn, true);
    await prefs.setString(_keyEmail, email.trim());
    await prefs.remove(_keyPhone);
  }

  Future<void> registerWithEmail(String email, String password) async {
    await signInWithEmail(email, password);
  }

  Future<void> signInWithPhone(String phone, String code) async {
    if (phone.trim().isEmpty || code.trim().isEmpty) {
      throw const AuthError(AuthErrorCode.phoneCodeRequired);
    }
    if (code != '0000') {
      throw const AuthError(AuthErrorCode.invalidCode);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySignedIn, true);
    await prefs.setString(_keyPhone, phone.trim());
    await prefs.remove(_keyEmail);
  }

  Future<void> signInWithGoogle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySignedIn, true);
    await prefs.setString(_keyEmail, 'user@gmail.mock');
    await prefs.remove(_keyPhone);
  }
}
