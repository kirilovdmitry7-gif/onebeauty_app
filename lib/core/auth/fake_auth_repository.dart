import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  static const _kEmail = 'fake_auth_email';
  static const _kPassword = 'fake_auth_password';
  static const _kPhone = 'fake_auth_phone';
  static const _kSignedIn = 'fake_auth_signed_in';
  static const _kUserId = 'fake_auth_user_id';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<AuthUser?> currentUser() async {
    final p = await _prefs;
    final signedIn = p.getBool(_kSignedIn) ?? false;
    if (!signedIn) return null;
    final id = p.getString(_kUserId) ?? 'u_${Random().nextInt(999999)}';
    final email = p.getString(_kEmail);
    final phone = p.getString(_kPhone);
    return AuthUser(id: id, email: email, phone: phone);
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final p = await _prefs;
    final storedEmail = p.getString(_kEmail);
    final storedPass = p.getString(_kPassword);
    if (storedEmail == email && storedPass == password) {
      await p.setBool(_kSignedIn, true);
      await p.setString(_kUserId, p.getString(_kUserId) ?? 'u_${Random().nextInt(999999)}');
      return AuthUser(id: p.getString(_kUserId)!, email: email);
    }
    throw Exception('Неверный email или пароль');
  }

  @override
  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final p = await _prefs;
    await p.setString(_kEmail, email);
    await p.setString(_kPassword, password);
    await p.setBool(_kSignedIn, true);
    await p.setString(_kUserId, 'u_${Random().nextInt(999999)}');
    return AuthUser(id: p.getString(_kUserId)!, email: email);
  }

  @override
  Future<void> sendPhoneCode({required String phone}) async {
    // Заглушка: в реале отправляем SMS через провайдера.
    final p = await _prefs;
    await p.setString(_kPhone, phone);
    // код всегда "0000" в MVP
  }

  @override
  Future<AuthUser> signInWithPhone({
    required String phone,
    required String code,
  }) async {
    final p = await _prefs;
    final savedPhone = p.getString(_kPhone);
    if (savedPhone == phone && code == '0000') {
      await p.setBool(_kSignedIn, true);
      await p.setString(_kUserId, p.getString(_kUserId) ?? 'u_${Random().nextInt(999999)}');
      return AuthUser(id: p.getString(_kUserId)!, phone: phone);
    }
    throw Exception('Неверный код подтверждения');
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    // Заглушка: в реале откроется Google Sign-In.
    final p = await _prefs;
    await p.setBool(_kSignedIn, true);
    await p.setString(_kUserId, p.getString(_kUserId) ?? 'u_${Random().nextInt(999999)}');
    return AuthUser(id: p.getString(_kUserId)!, email: 'google_user@example.com');
  }

  @override
  Future<void> signOut() async {
    final p = await _prefs;
    await p.setBool(_kSignedIn, false);
  }
}
