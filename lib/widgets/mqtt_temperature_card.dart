import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lab_02/services/mqtt_temperature_service.dart';

class MqttTemperatureCard extends StatefulWidget {
  const MqttTemperatureCard({super.key});

  @override
  State<MqttTemperatureCard> createState() => _MqttTemperatureCardState();
}

class _MqttTemperatureCardState extends State<MqttTemperatureCard> {
  late final MqttTemperatureService _service;
  late final StreamSubscription<double> _temperatureSubscription;

  double? _temperature;
  String? _error;

  @override
  void initState() {
    super.initState();

    _service = MqttTemperatureService();

    // Отримуємо нові значення температури.
    _temperatureSubscription = _service.temperatures.listen((value) {
      if (!mounted) return;

      setState(() {
        _temperature = value;
        _error = null;
      });
    });
  }

  // Підключення до MQTT запускається кнопкою.
  Future<void> _connect() async {
    setState(() {
      _error = null;
    });

    try {
      await _service.connect();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Не вдалося підключитися до MQTT-брокера.';
      });
    }
  }

  String _statusText(TemperatureConnectionStatus status) {
    switch (status) {
      case TemperatureConnectionStatus.disconnected:
        return 'Не підключено';
      case TemperatureConnectionStatus.connecting:
        return 'Підключення...';
      case TemperatureConnectionStatus.connected:
        return 'Підключено до брокера';
      case TemperatureConnectionStatus.error:
        return 'Помилка підключення';
    }
  }

  @override
  void dispose() {
    // Зупиняємо прослуховування потоку.
    unawaited(_temperatureSubscription.cancel());

    // Закриваємо MQTT-з'єднання.
    unawaited(_service.dispose());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ValueListenableBuilder<TemperatureConnectionStatus>(
      valueListenable: _service.status,
      builder: (context, status, child) {
        final isConnected = status == TemperatureConnectionStatus.connected;

        final isConnecting = status == TemperatureConnectionStatus.connecting;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MQTT-датчик температури',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(
                      Icons.sensors,
                      color: isConnected
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_statusText(status))),
                    if (isConnecting)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    _temperature == null
                        ? '-- °C'
                        : '${_temperature!.toStringAsFixed(1)} °C',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _temperature == null
                      ? 'Очікування даних від датчика'
                      : 'Останнє отримане значення',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  'Брокер: ${MqttTemperatureService.host}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Топік: ${MqttTemperatureService.topic}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: colors.error)),
                ],

                const SizedBox(height: 16),

                if (!isConnected)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isConnecting ? null : _connect,
                      icon: const Icon(Icons.wifi),
                      label: Text(
                        status == TemperatureConnectionStatus.error
                            ? 'Повторити підключення'
                            : 'Підключитися до MQTT',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
