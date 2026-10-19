import 'package:flutter/material.dart';
import 'package:lab_02/widgets/weather_card.dart';
import 'package:lab_02/widgets/workout_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartFit Weather'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person),
            tooltip: 'Мій профіль',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 700;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Добрий день!',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ось рекомендація для сьогоднішнього тренування.',
                      ),
                      const SizedBox(height: 24),

                      // Адаптивне розташування карток
                      if (isTablet)
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _WeatherSection()),
                            SizedBox(width: 16),
                            Expanded(child: _WorkoutSection()),
                          ],
                        )
                      else ...[
                        const _WeatherSection(),
                        const SizedBox(height: 16),
                        const _WorkoutSection(),
                      ],

                      const SizedBox(height: 24),

                      // Показники фітнес-пристрою
                      const _FitnessData(),

                      const SizedBox(height: 20),

                      // Перехід до екрана тренувань
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/workouts');
                        },
                        icon: const Icon(Icons.fitness_center),
                        label: const Text('Переглянути тренування'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Картка погоди
class _WeatherSection extends StatelessWidget {
  const _WeatherSection();

  @override
  Widget build(BuildContext context) {
    return const WeatherCard(
      city: 'Львів',
      temperature: '+21 °C',
      condition: 'Сонячно',
      rainChance: '0%',
      windSpeed: '3 м/с',
    );
  }
}

// Картка рекомендованого тренування
class _WorkoutSection extends StatelessWidget {
  const _WorkoutSection();

  @override
  Widget build(BuildContext context) {
    return const WorkoutCard(
      title: 'Тренування на вулиці',
      reason: 'Погода суха та комфортна для активності.',
      icon: Icons.directions_run,
    );
  }
}

// Показники фітнес-пристрою
class _FitnessData extends StatelessWidget {
  const _FitnessData();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Metric(icon: Icons.favorite, value: '74', label: 'Пульс'),
            _Metric(icon: Icons.directions_walk, value: '6250', label: 'Кроки'),
          ],
        ),
      ),
    );
  }
}

// Універсальний елемент показника
class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label),
      ],
    );
  }
}
