import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:lab_02/data/local_workout_repository.dart';
import 'package:lab_02/domain/models/workout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalWorkoutRepository repository;
  late SharedPreferencesAsync preferences;

  const workout = Workout(
    id: 'workout-1',
    title: 'Morning Run',
    reason: 'Running for 30 minutes',
  );

  setUp(() {
    // Кожен тест отримує окреме порожнє сховище.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    preferences = SharedPreferencesAsync();

    repository = LocalWorkoutRepository(preferences: preferences);
  });

  test('Create: додавання тренування', () async {
    await repository.addWorkout('user-1', workout);

    final workouts = await repository.getWorkouts('user-1');

    expect(workouts.length, 1);
    expect(workouts.first.id, 'workout-1');
    expect(workouts.first.title, 'Morning Run');
    expect(workouts.first.reason, 'Running for 30 minutes');
  });

  test('Read: дані доступні новому екземпляру репозиторію', () async {
    await repository.addWorkout('user-1', workout);

    final anotherRepository = LocalWorkoutRepository(
      preferences: SharedPreferencesAsync(),
    );

    final workouts = await anotherRepository.getWorkouts('user-1');

    expect(workouts.length, 1);
    expect(workouts.first.title, 'Morning Run');
  });

  test('Update: редагування тренування', () async {
    await repository.addWorkout('user-1', workout);

    final updated = workout.copyWith(
      title: 'Evening Run',
      reason: 'Running for 45 minutes',
    );

    await repository.updateWorkout('user-1', updated);

    final workouts = await repository.getWorkouts('user-1');

    expect(workouts.length, 1);
    expect(workouts.first.title, 'Evening Run');
    expect(workouts.first.reason, 'Running for 45 minutes');
  });

  test('Delete: видалення тренування', () async {
    await repository.addWorkout('user-1', workout);

    await repository.deleteWorkout('user-1', 'workout-1');

    final workouts = await repository.getWorkouts('user-1');

    expect(workouts, isEmpty);
  });

  test('Ізоляція даних різних користувачів', () async {
    await repository.addWorkout('user-1', workout);

    const secondWorkout = Workout(
      id: 'workout-2',
      title: 'Cycling',
      reason: 'Cycling for 20 minutes',
    );

    await repository.addWorkout('user-2', secondWorkout);

    final firstUser = await repository.getWorkouts('user-1');
    final secondUser = await repository.getWorkouts('user-2');

    expect(firstUser.length, 1);
    expect(secondUser.length, 1);

    expect(firstUser.first.title, 'Morning Run');
    expect(secondUser.first.title, 'Cycling');

    await repository.deleteWorkout('user-1', 'workout-1');

    final remaining = await repository.getWorkouts('user-2');

    expect(remaining.length, 1);
    expect(remaining.first.title, 'Cycling');
  });

  test('Заборона дублювання ID тренувань', () async {
    await repository.addWorkout('user-1', workout);

    await expectLater(
      repository.addWorkout('user-1', workout),
      throwsA(isA<StateError>()),
    );

    final workouts = await repository.getWorkouts('user-1');

    expect(workouts.length, 1);
  });
}
