import 'package:lab_02/domain/models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AppUser?> signIn({required String email, required String password});

  Future<AppUser?> getCurrentUser();

  Future<void> signOut();
}
