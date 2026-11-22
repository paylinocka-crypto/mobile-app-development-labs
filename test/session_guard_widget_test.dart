import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab_02/main.dart';
import 'package:lab_02/domain/models/app_user.dart';
import 'package:lab_02/domain/models/workout.dart';
import 'package:lab_02/domain/repositories/auth_repository.dart';
import 'package:lab_02/domain/repositories/workout_repository.dart';
import 'package:lab_02/screens/dashboard_screen.dart';
import 'package:lab_02/screens/login_screen.dart';
import 'package:lab_02/screens/profile_screen.dart';
import 'package:lab_02/screens/workout_screen.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.currentUser});

  AppUser? currentUser;

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
    return null;
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

class FakeWorkoutRepository implements WorkoutRepository {
  @override
  Future<List<Workout>> getWorkouts(String userId) async {
    return <Workout>[];
  }

  @override
  Future<void> addWorkout(String userId, Workout workout) async {}

  @override
  Future<void> updateWorkout(String userId, Workout workout) async {}

  @override
  Future<void> deleteWorkout(String userId, String workoutId) async {}
}

Future<void> openApp(WidgetTester tester, FakeAuthRepository auth) async {
  await tester.pumpWidget(
    SmartFitApp(
      authRepository: auth,
      workoutRepository: FakeWorkoutRepository(),
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> navigateTo(WidgetTester tester, String route) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));

  navigator.pushNamed(route);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Unauthorized user cannot open dashboard', (tester) async {
    final auth = FakeAuthRepository();

    await openApp(tester, auth);
    await navigateTo(tester, '/dashboard');

    expect(find.byType(DashboardScreen), findsNothing);

    expect(find.byType(LoginScreen), findsWidgets);
  });

  testWidgets('Unauthorized user cannot open workouts', (tester) async {
    final auth = FakeAuthRepository();

    await openApp(tester, auth);
    await navigateTo(tester, '/workouts');

    expect(find.byType(WorkoutScreen), findsNothing);

    expect(find.byType(LoginScreen), findsWidgets);
  });

  testWidgets('Unauthorized user cannot open profile', (tester) async {
    final auth = FakeAuthRepository();

    await openApp(tester, auth);
    await navigateTo(tester, '/profile');

    expect(find.byType(ProfileScreen), findsNothing);

    expect(find.byType(LoginScreen), findsWidgets);
  });

  testWidgets('Profile shows user data and logout ends session', (
    tester,
  ) async {
    final auth = FakeAuthRepository(
      currentUser: const AppUser(
        id: 'user-1',
        name: 'Polina',
        email: 'polina@example.com',
      ),
    );

    await openApp(tester, auth);
    await navigateTo(tester, '/profile');

    expect(find.byType(ProfileScreen), findsOneWidget);

    expect(find.text('Polina'), findsWidgets);

    expect(find.text('polina@example.com'), findsWidgets);

    await tester.tap(find.text('Вийти з акаунта'));

    await tester.pumpAndSettle();

    expect(await auth.getCurrentUser(), isNull);

    expect(find.byType(LoginScreen), findsOneWidget);

    expect(find.byType(ProfileScreen), findsNothing);
  });
}
