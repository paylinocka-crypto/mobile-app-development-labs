import 'package:flutter/material.dart';
import 'package:lab_02/widgets/workout_card.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мої тренування')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Обери тренування',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text('Варіанти активності залежно від погоди'),
                const SizedBox(height: 24),
                const WorkoutCard(
                  title: 'Біг на вулиці',
                  reason: 'Підходить для сухої та комфортної погоди.',
                  icon: Icons.directions_run,
                ),
                const SizedBox(height: 12),
                const WorkoutCard(
                  title: 'Тренування у спортзалі',
                  reason: 'Хороший варіант під час дощу або холоду.',
                  icon: Icons.fitness_center,
                ),
                const SizedBox(height: 12),
                const WorkoutCard(
                  title: 'Домашня розминка',
                  reason: 'Легка активність, яку можна виконувати вдома.',
                  icon: Icons.self_improvement,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
