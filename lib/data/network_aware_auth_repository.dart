import 'package:lab_02/domain/models/app_user.dart';
import 'package:lab_02/domain/repositories/auth_repository.dart';
import 'package:lab_02/services/network_status_service.dart';

// Помилка під час спроби входу без мережі.
class OfflineLoginException implements Exception {
  const OfflineLoginException();
}

// Репозиторій, який перевіряє мережу перед авторизацією.
class NetworkAwareAuthRepository implements AuthRepository {
  NetworkAwareAuthRepository({
    required this.delegate,
    Future<bool?> Function()? checkNetwork,
  }) : _checkNetwork = checkNetwork ?? _checkCurrentNetwork;

  final AuthRepository delegate;
  final Future<bool?> Function() _checkNetwork;

  // Перевірка поточного стану мережі.
  static Future<bool?> _checkCurrentNetwork() async {
    final service = NetworkStatusService();

    try {
      return await service.refresh();
    } finally {
      await service.dispose();
    }
  }

  // Реєстрація через основний репозиторій.
  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) {
    return delegate.register(name: name, email: email, password: password);
  }

  // Новий вхід дозволений лише за наявності мережі.
  @override
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    final isConnected = await _checkNetwork();

    if (isConnected != true) {
      throw const OfflineLoginException();
    }

    return delegate.signIn(email: email, password: password);
  }

  // Автологін працює без мережі.
  @override
  Future<AppUser?> getCurrentUser() {
    return delegate.getCurrentUser();
  }

  // Завершення сесії працює навіть офлайн.
  @override
  Future<void> signOut() {
    return delegate.signOut();
  }
}
