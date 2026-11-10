import 'package:lab_02/domain/models/workout.dart';

abstract class WorkoutRepository {
  Future<List<Workout>> getWorkouts(String userId);

  Future<void> addWorkout(String userId, Workout workout);

  Future<void> updateWorkout(String userId, Workout workout);

  Future<void> deleteWorkout(String userId, String workoutId);
}
