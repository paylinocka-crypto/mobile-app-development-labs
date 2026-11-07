import 'package:flutter/material.dart';
import 'package:lab_02/domain/models/app_user.dart';
import 'package:lab_02/domain/repositories/auth_repository.dart';
import 'package:lab_02/domain/repositories/workout_repository.dart';
import 'package:lab_02/widgets/weather_card.dart';
import 'package:lab_02/widgets/workout_card.dart';
import 'package:lab_02/widgets/workout_manager.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.authRepository,
    required this.workoutRepository,
    super.key,
  });

  final AuthRepository authRepository;
  final WorkoutRepository workoutRepository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Future<AppUser?> _currentUserFuture;

  @override
  void initState() {
    super.initState();

    // Завантажуємо користувача лише один раз.
    _currentUserFuture = widget.authRepository.getCurrentUser();
  }

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

            const weather = WeatherCard(
              city: 'Львів',
              temperature: '+21 °C',
              condition: 'Сонячно',
              rainChance: '0%',
              windSpeed: '3 м/с',
            );

            const recommendation = WorkoutCard(
              title: 'Тренування на вулиці',
              reason: 'Погода суха та комфортна для активності.',
              icon: Icons.directions_run,
            );

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

                      if (isTablet)
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: weather),
                            SizedBox(width: 16),
                            Expanded(child: recommendation),
                          ],
                        )
                      else ...[
                        weather,
                        const SizedBox(height: 16),
                        recommendation,
                      ],

                      const SizedBox(height: 24),

                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _Metric(
                                icon: Icons.favorite,
                                value: '74',
                                label: 'Пульс',
                              ),
                              _Metric(
                                icon: Icons.directions_walk,
                                value: '6250',
                                label: 'Кроки',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // CRUD тренувань поточного користувача.
                      FutureBuilder<AppUser?>(
                        future: _currentUserFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return const Text(
                              'Не вдалося отримати дані користувача',
                            );
                          }

                          final user = snapshot.data;

                          if (user == null) {
                            return const Text(
                              'Увійдіть, щоб керувати тренуваннями',
                            );
                          }

                          return WorkoutManager(
                            repository: widget.workoutRepository,
                            userId: user.id,
                          );
                        },
                      ),

                      const SizedBox(height: 20),

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
