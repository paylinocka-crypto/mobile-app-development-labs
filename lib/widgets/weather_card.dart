import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.rainChance,
    required this.windSpeed,
    super.key,
  });

  final String city;
  final String temperature;
  final String condition;
  final String rainChance;
  final String windSpeed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(city, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.wb_sunny, size: 48),
                const SizedBox(width: 16),
                Text(
                  temperature,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(condition),
            const SizedBox(height: 8),
            Text('Ймовірність дощу: $rainChance'),
            Text('Вітер: $windSpeed'),
          ],
        ),
      ),
    );
  }
}
