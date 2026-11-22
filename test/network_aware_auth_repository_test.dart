import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab_02/data/network_aware_auth_repository.dart';
import 'package:lab_02/domain/models/app_user.dart';
import 'package:lab_02/domain/repositories/auth_repository.dart';
import 'package:lab_02/screens/login_screen.dart';

// Тестовий репозиторій авторизації.
class FakeAuthRepository implements AuthRepository {
  int signInCalls = 0;

  AppUser? currentUser = const AppUser(
    id: 'user-1',
    name: 'Polina',
    email: 'polina@example.com',
  );

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return AppUser(id: 'new-user', name: name, email: email);
  }

  @override
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    currentUser = const AppUser(
      id: 'user-1',
      name: 'Polina',
      email: 'polina@example.com',
    );
    return currentUser;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    return currentUser;
  }

  @override
  Future<void> signOut() async {
    currentUser = null;
  }
}

void main() {
  group('Lab04: network-aware authentication', () {
    test('Offline login is blocked', () async {
      final delegate = FakeAuthRepository();

      final repository = NetworkAwareAuthRepository(
        delegate: delegate,
        checkNetwork: () async => false,
      );

      await expectLater(
        repository.signIn(email: 'polina@example.com', password: 'Password123'),
        throwsA(isA<OfflineLoginException>()),
      );

      expect(delegate.signInCalls, 0);
    });

    test('Unknown network status blocks login', () async {
      final delegate = FakeAuthRepository();

      final repository = NetworkAwareAuthRepository(
        delegate: delegate,
        checkNetwork: () async => null,
      );

      await expectLater(
        repository.signIn(email: 'polina@example.com', password: 'Password123'),
        throwsA(isA<OfflineLoginException>()),
      );

      expect(delegate.signInCalls, 0);
    });

    test('Online login is allowed', () async {
      final delegate = FakeAuthRepository();

      final repository = NetworkAwareAuthRepository(
        delegate: delegate,
        checkNetwork: () async => true,
      );

      final user = await repository.signIn(
        email: 'polina@example.com',
        password: 'Password123',
      );

      expect(user, isNotNull);
      expect(delegate.signInCalls, 1);
    });

    test('Existing session works offline', () async {
      final delegate = FakeAuthRepository();

      final repository = NetworkAwareAuthRepository(
        delegate: delegate,
        checkNetwork: () async => false,
      );

      final user = await repository.getCurrentUser();

      expect(user?.name, 'Polina');
      expect(delegate.signInCalls, 0);
    });

    test('Logout works offline', () async {
      final delegate = FakeAuthRepository();

      final repository = NetworkAwareAuthRepository(
        delegate: delegate,
        checkNetwork: () async => false,
      );

      await repository.signOut();

      expect(await repository.getCurrentUser(), isNull);
    });

    testWidgets('Offline login shows an error', (tester) async {
      final delegate = FakeAuthRepository();

      final repository = NetworkAwareAuthRepository(
        delegate: delegate,
        checkNetwork: () async => false,
      );

      await tester.pumpWidget(
        MaterialApp(home: LoginScreen(authRepository: repository)),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'polina@example.com',
      );

      await tester.enterText(find.byType(TextFormField).at(1), 'Password123');

      await tester.tap(find.text('Увійти'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Немає мережевого підключення'), findsWidgets);

      expect(delegate.signInCalls, 0);
    });
  });
}
