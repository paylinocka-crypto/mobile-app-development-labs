import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lab_02/data/password_hasher.dart';
import 'package:lab_02/domain/models/app_user.dart';
import 'package:lab_02/domain/repositories/auth_repository.dart';
import 'package:lab_02/domain/validators/auth_validator.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository({FlutterSecureStorage? storage, PasswordHasher? hasher})
    : _storage = storage ?? FlutterSecureStorage(),
      _hasher = hasher ?? PasswordHasher();

  static const _accountsKey = 'smartfit_accounts_v1';
  static const _sessionKey = 'smartfit_current_user_v1';

  final FlutterSecureStorage _storage;
  final PasswordHasher _hasher;

  Future<List<Map<String, dynamic>>> _readAccounts() async {
    final stored = await _storage.read(key: _accountsKey);

    if (stored == null) {
      return [];
    }

    final decoded = jsonDecode(stored) as List<dynamic>;

    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  AppUser _toUser(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
    );
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final nameError = AuthValidator.validateName(name);
    final emailError = AuthValidator.validateEmail(email);
    final passwordError = AuthValidator.validatePassword(password);

    for (final error in [nameError, emailError, passwordError]) {
      if (error != null) {
        throw FormatException(error);
      }
    }

    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    final accounts = await _readAccounts();

    final emailExists = accounts.any(
      (account) => account['email'] == cleanEmail,
    );

    if (emailExists) {
      throw StateError('Ця електронна пошта вже зареєстрована');
    }

    final salt = _hasher.generateSalt();
    final passwordHash = await _hasher.hash(password, salt);

    final id = _hasher.generateId();

    accounts.add({
      'id': id,
      'name': cleanName,
      'email': cleanEmail,
      'salt': salt,
      'passwordHash': passwordHash,
    });

    await _storage.write(key: _accountsKey, value: jsonEncode(accounts));

    // Реєстрація створює акаунт,
    // але не виконує автоматичний вхід.
    return AppUser(id: id, name: cleanName, email: cleanEmail);
  }

  @override
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    if (AuthValidator.validateEmail(email) != null ||
        AuthValidator.validatePassword(password) != null) {
      return null;
    }

    final cleanEmail = email.trim().toLowerCase();
    final accounts = await _readAccounts();

    for (final account in accounts) {
      if (account['email'] != cleanEmail) {
        continue;
      }

      final valid = await _hasher.verify(
        password,
        account['salt'] as String,
        account['passwordHash'] as String,
      );

      if (!valid) {
        return null;
      }

      final user = _toUser(account);

      await _storage.write(key: _sessionKey, value: user.id);

      return user;
    }

    return null;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final currentId = await _storage.read(key: _sessionKey);

    if (currentId == null) {
      return null;
    }

    final accounts = await _readAccounts();

    for (final account in accounts) {
      if (account['id'] == currentId) {
        return _toUser(account);
      }
    }

    return null;
  }

  @override
  Future<void> signOut() async {
    await _storage.delete(key: _sessionKey);
  }
}
