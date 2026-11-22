import 'package:flutter/material.dart';
import 'package:lab_02/domain/models/workout.dart';
import 'package:lab_02/domain/repositories/workout_repository.dart';
import 'package:lab_02/widgets/workout_form_dialog.dart';

class WorkoutManager extends StatefulWidget {
  const WorkoutManager({
    required this.repository,
    required this.userId,
    super.key,
  });

  final WorkoutRepository repository;
  final String userId;

  @override
  State<WorkoutManager> createState() => _WorkoutManagerState();
}

class _WorkoutManagerState extends State<WorkoutManager> {
  List<Workout> _workouts = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  @override
  void didUpdateWidget(covariant WorkoutManager oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId ||
        oldWidget.repository != widget.repository) {
      _workouts = [];
      _loading = true;
      _error = null;
      _loadWorkouts();
    }
  }

  Future<void> _loadWorkouts() async {
    final userId = widget.userId;

    try {
      final workouts = await widget.repository.getWorkouts(userId);

      if (!mounted || widget.userId != userId) return;

      setState(() {
        _workouts = workouts;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted || widget.userId != userId) return;

      setState(() {
        _loading = false;
        _error = 'Не вдалося завантажити тренування';
      });
    }
  }

  Future<void> _saveWorkout([Workout? existing]) async {
    if (_saving) return;

    final input = await showDialog<WorkoutInput>(
      context: context,
      builder: (context) => WorkoutFormDialog(workout: existing),
    );

    if (input == null || !mounted) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (existing == null) {
        final workout = Workout(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: input.title,
          reason: input.reason,
        );

        await widget.repository.addWorkout(widget.userId, workout);
      } else {
        final updated = existing.copyWith(
          title: input.title,
          reason: input.reason,
        );

        await widget.repository.updateWorkout(widget.userId, updated);
      }

      await _loadWorkouts();
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Не вдалося зберегти тренування';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _deleteWorkout(Workout workout) async {
    if (_saving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити тренування?'),
        content: Text('Тренування "${workout.title}" буде видалено.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.repository.deleteWorkout(widget.userId, workout.id);

      await _loadWorkouts();
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Не вдалося видалити тренування';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Мої тренування',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            FilledButton.icon(
              onPressed: _saving ? null : () => _saveWorkout(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Додати'),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          'Створюй та керуй своїми тренуваннями',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
        ),

        const SizedBox(height: 14),

        if (_saving) const LinearProgressIndicator(),

        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_error!, style: TextStyle(color: colors.error)),
          ),

        if (_loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_workouts.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center_outlined,
                  size: 32,
                  color: colors.primary,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Тренувань поки немає',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Натисни «Додати», щоб створити перше.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          for (final workout in _workouts)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.directions_run,
                        color: colors.onPrimaryContainer,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            workout.reason,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Редагувати',
                      onPressed: _saving ? null : () => _saveWorkout(workout),
                      icon: const Icon(Icons.edit_outlined, size: 21),
                    ),
                    IconButton(
                      tooltip: 'Видалити',
                      onPressed: _saving ? null : () => _deleteWorkout(workout),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 21,
                        color: colors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
