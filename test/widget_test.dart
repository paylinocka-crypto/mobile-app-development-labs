import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab_02/main.dart';
import 'package:lab_02/domain/models/app_user.dart';
import 'package:lab_02/domain/models/workout.dart';
import 'package:lab_02/domain/repositories/auth_repository.dart';
import 'package:lab_02/domain/repositories/workout_repository.dart';
import 'package:lab_02/screens/login_screen.dart';
import 'package:lab_02/screens/registration_screen.dart';
import 'package:lab_02/screens/dashboard_screen.dart';
import 'package:lab_02/screens/workout_screen.dart';
import 'package:lab_02/screens/profile_screen.dart';

// Тестовий репозиторій авторизації.
class FakeAuthRepository implements AuthRepository {
  AppUser? _currentUser;

  final AppUser _demoUser = const AppUser(
    id: 'test-user-1',
    name: 'Тестовий користувач',
    email: 'demo@example.com',
  );

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = AppUser(id: 'test-user-2', name: name, email: email);

    _currentUser = user;
    return user;
  }

  @override
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    if (email.trim().toLowerCase() == _demoUser.email &&
        password == 'Password123') {
      _currentUser = _demoUser;
      return _demoUser;
    }

    return null;
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}

// Тестовий репозиторій тренувань.
// Не використовує SharedPreferences.
class FakeWorkoutRepository implements WorkoutRepository {
  final Map<String, List<Workout>> _storage = {};

  @override
  Future<List<Workout>> getWorkouts(String userId) async {
    return List<Workout>.of(_storage[userId] ?? <Workout>[]);
  }

  @override
  Future<void> addWorkout(String userId, Workout workout) async {
    final workouts = _storage.putIfAbsent(userId, () => <Workout>[]);

    if (workouts.any((item) => item.id == workout.id)) {
      throw StateError('Тренування вже існує');
    }

    workouts.add(workout);
  }

  @override
  Future<void> updateWorkout(String userId, Workout workout) async {
    final workouts = _storage[userId];

    if (workouts == null) {
      throw StateError('Тренування не знайдено');
    }

    final index = workouts.indexWhere((item) => item.id == workout.id);

    if (index == -1) {
      throw StateError('Тренування не знайдено');
    }

    workouts[index] = workout;
  }

  @override
  Future<void> deleteWorkout(String userId, String workoutId) async {
    _storage[userId]?.removeWhere((item) => item.id == workoutId);
  }
}

// Створюємо застосунок з тестовими репозиторіями.
Widget createTestApp() {
  return SmartFitApp(
    authRepository: FakeAuthRepository(),
    workoutRepository: FakeWorkoutRepository(),
  );
}

// Допоміжна функція для входу в застосунок.
Future<void> openDashboard(WidgetTester tester) async {
  await tester.pumpWidget(createTestApp());

  await tester.enterText(find.byType(TextFormField).at(0), 'demo@example.com');

  await tester.enterText(find.byType(TextFormField).at(1), 'Password123');

  await tester.tap(find.text('Увійти'));
  await tester.pumpAndSettle();

  expect(find.byType(DashboardScreen), findsOneWidget);
}

void main() {
  testWidgets('Login screen opens correctly', (tester) async {
    await tester.pumpWidget(createTestApp());

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Login opens registration', (tester) async {
    await tester.pumpWidget(createTestApp());

    await tester.tap(find.text('Немає акаунта? Зареєструватися'));

    await tester.pumpAndSettle();

    expect(find.byType(RegistrationScreen), findsOneWidget);
  });

  testWidgets('Valid login opens dashboard', (tester) async {
    await openDashboard(tester);

    expect(find.text('SmartFit Weather'), findsOneWidget);
  });

  testWidgets('Wrong password blocks login', (tester) async {
    await tester.pumpWidget(createTestApp());

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'demo@example.com',
    );

    await tester.enterText(
      find.byType(TextFormField).at(1),
      'WrongPassword123',
    );

    await tester.tap(find.text('Увійти'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);

    expect(find.byType(DashboardScreen), findsNothing);
  });

  testWidgets('Dashboard opens workouts', (tester) async {
    await openDashboard(tester);

    final button = find.text('Переглянути тренування');

    await tester.ensureVisible(button);
    await tester.pumpAndSettle();

    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutScreen), findsOneWidget);
  });

  testWidgets('Dashboard opens profile', (tester) async {
    await openDashboard(tester);

    await tester.tap(find.byTooltip('Мій профіль'));

    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
