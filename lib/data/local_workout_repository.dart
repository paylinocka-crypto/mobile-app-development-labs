import 'dart:convert';

import 'package:lab_02/domain/models/workout.dart';
import 'package:lab_02/domain/repositories/workout_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalWorkoutRepository implements WorkoutRepository {
  LocalWorkoutRepository({SharedPreferencesAsync? preferences})
    : _prefs = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  String _key(String userId) => 'workouts_$userId';

  @override
  Future<List<Workout>> getWorkouts(String userId) async {
    final stored = await _prefs.getString(_key(userId));

    if (stored == null) {
      return [];
    }

    final decoded = jsonDecode(stored) as List<dynamic>;

    return decoded.map((item) {
      final data = item as Map<String, dynamic>;

      return Workout(
        id: data['id'] as String,
        title: data['title'] as String,
        reason: data['reason'] as String,
      );
    }).toList();
  }

  Future<void> _save(String userId, List<Workout> workouts) async {
    final data = workouts.map((workout) {
      return {
        'id': workout.id,
        'title': workout.title,
        'reason': workout.reason,
      };
    }).toList();

    await _prefs.setString(_key(userId), jsonEncode(data));
  }

  @override
  Future<void> addWorkout(String userId, Workout workout) async {
    final workouts = await getWorkouts(userId);

    if (workouts.any((item) => item.id == workout.id)) {
      throw StateError('Тренування з таким ID уже існує');
    }

    workouts.add(workout);
    await _save(userId, workouts);
  }

  @override
  Future<void> updateWorkout(String userId, Workout workout) async {
    final workouts = await getWorkouts(userId);
    final index = workouts.indexWhere((item) => item.id == workout.id);

    if (index == -1) {
      throw StateError('Тренування не знайдено');
    }

    workouts[index] = workout;
    await _save(userId, workouts);
  }

  @override
  Future<void> deleteWorkout(String userId, String workoutId) async {
    final workouts = await getWorkouts(userId);
    workouts.removeWhere((item) => item.id == workoutId);
    await _save(userId, workouts);
  }
}
