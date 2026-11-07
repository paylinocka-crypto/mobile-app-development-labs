
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:lab_02/data/local_auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalAuthRepository repository;

  setUp(() {
    // Окреме порожнє сховище для кожного тесту.
    FlutterSecureStorage.setMockInitialValues({});

    repository = LocalAuthRepository();
  });

  test('Register: створення нового акаунта', () async {
    final user = await repository.register(
      name: 'Polina',
      email: 'polina@example.com',
      password: 'Password123',
    );

    expect(user.name, 'Polina');
    expect(user.email, 'polina@example.com');
    expect(user.id, isNotEmpty);

    // Реєстрація не повинна автоматично входити.
    final currentUser = await repository.getCurrentUser();
    expect(currentUser, isNull);
  });

  test('Sign In: правильний пароль', () async {
    await repository.register(
      name: 'Polina',
      email: 'polina@example.com',
      password: 'Password123',
    );

    final user = await repository.signIn(
      email: 'polina@example.com',
      password: 'Password123',
    );

    expect(user, isNotNull);
    expect(user!.name, 'Polina');

    final currentUser = await repository.getCurrentUser();

    expect(currentUser, isNotNull);
    expect(currentUser!.id, user.id);
  });

  test('Sign In: неправильний пароль', () async {
    await repository.register(
      name: 'Polina',
      email: 'polina@example.com',
      password: 'Password123',
    );

    final user = await repository.signIn(
      email: 'polina@example.com',
      password: 'WrongPassword123',
    );

    expect(user, isNull);
    expect(await repository.getCurrentUser(), isNull);
  });

  test('Register: заборона повторної пошти', () async {
    await repository.register(
      name: 'Polina',
      email: 'polina@example.com',
      password: 'Password123',
    );

    await expectLater(
      repository.register(
        name: 'Anna',
        email: 'POLINA@example.com',
        password: 'AnotherPassword123',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('Sign Out: завершення сесії', () async {
    await repository.register(
      name: 'Polina',
      email: 'polina@example.com',
      password: 'Password123',
    );

    await repository.signIn(
      email: 'polina@example.com',
      password: 'Password123',
    );

    expect(await repository.getCurrentUser(), isNotNull);

    await repository.signOut();

    expect(await repository.getCurrentUser(), isNull);

    // Після виходу акаунт залишається збереженим.
    final user = await repository.signIn(
      email: 'polina@example.com',
      password: 'Password123',
    );

    expect(user, isNotNull);
  });

  test('Register: занадто короткий пароль', () async {
    await expectLater(
      repository.register(
        name: 'Polina',
        email: 'polina@example.com',
        password: '123',
      ),
      throwsA(isA<FormatException>()),
    );

    expect(await repository.getCurrentUser(), isNull);
  });
}
