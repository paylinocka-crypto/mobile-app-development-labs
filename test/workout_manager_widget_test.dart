import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab_02/domain/models/workout.dart';
import 'package:lab_02/domain/repositories/workout_repository.dart';
import 'package:lab_02/widgets/workout_form_dialog.dart';
import 'package:lab_02/widgets/workout_manager.dart';

class FakeWorkoutRepository implements WorkoutRepository {
  final Map<String, List<Workout>> _storage = {};

  @override
  Future<List<Workout>> getWorkouts(String userId) async {
    return List<Workout>.of(_storage[userId] ?? <Workout>[]);
  }

  @override
  Future<void> addWorkout(String userId, Workout workout) async {
    _storage.putIfAbsent(userId, () => []).add(workout);
  }

  @override
  Future<void> updateWorkout(String userId, Workout workout) async {
    final workouts = _storage[userId]!;
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

Future<void> openManager(
  WidgetTester tester,
  FakeWorkoutRepository repository,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: WorkoutManager(repository: repository, userId: 'user-1'),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Create, Update and Delete through UI', (tester) async {
    final repository = FakeWorkoutRepository();

    await openManager(tester, repository);

    expect(find.text('Тренувань поки немає'), findsOneWidget);

    // CREATE
    await tester.tap(find.text('Додати'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Morning Run');

    await tester.enterText(
      find.byType(TextFormField).last,
      'Running for 30 minutes',
    );

    await tester.tap(find.text('Додати').last);
    await tester.pumpAndSettle();

    expect(find.text('Morning Run'), findsOneWidget);

    // UPDATE
    await tester.tap(find.byTooltip('Редагувати'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Evening Run');

    await tester.enterText(
      find.byType(TextFormField).last,
      'Running for 45 minutes',
    );

    await tester.tap(find.text('Зберегти'));
    await tester.pumpAndSettle();

    expect(find.text('Evening Run'), findsOneWidget);
    expect(find.text('Morning Run'), findsNothing);

    // DELETE
    await tester.tap(find.byTooltip('Видалити'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Видалити'));
    await tester.pumpAndSettle();

    expect(find.text('Evening Run'), findsNothing);
    expect(find.text('Тренувань поки немає'), findsOneWidget);

    final workouts = await repository.getWorkouts('user-1');
    expect(workouts, isEmpty);
  });

  testWidgets('Empty fields block workout creation', (tester) async {
    final repository = FakeWorkoutRepository();

    await openManager(tester, repository);

    await tester.tap(find.text('Додати'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Додати').last);
    await tester.pumpAndSettle();

    expect(find.text('Введіть назву тренування'), findsOneWidget);

    expect(find.text('Введіть опис тренування'), findsOneWidget);

    expect(find.byType(WorkoutFormDialog), findsOneWidget);

    final workouts = await repository.getWorkouts('user-1');
    expect(workouts, isEmpty);
  });

  testWidgets('Cancel deletion keeps workout', (tester) async {
    final repository = FakeWorkoutRepository();

    const workout = Workout(
      id: 'test-1',
      title: 'Morning Run',
      reason: 'Running for 30 minutes',
    );

    await repository.addWorkout('user-1', workout);

    await openManager(tester, repository);

    await tester.tap(find.byTooltip('Видалити'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Скасувати'));
    await tester.pumpAndSettle();

    expect(find.text('Morning Run'), findsOneWidget);

    final workouts = await repository.getWorkouts('user-1');
    expect(workouts.length, 1);
  });
}
