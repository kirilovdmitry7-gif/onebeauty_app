import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  final String? email;
  final String? phone;

  const AuthUser({required this.id, this.email, this.phone});
}

abstract class AuthRepository {
  Future<AuthUser?> currentUser();

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> signInWithPhone({
    required String phone,
    required String code, // для MVP: код вводится на втором шаге (заглушка)
  });

  Future<void> sendPhoneCode({required String phone});

  Future<AuthUser> signInWithGoogle();

  Future<void> signOut();
}
