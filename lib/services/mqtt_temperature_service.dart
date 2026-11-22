import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// Стани підключення до MQTT-брокера.
enum TemperatureConnectionStatus { disconnected, connecting, connected, error }

class MqttTemperatureService {
  // Публічний брокер HiveMQ.
  static const String host = 'broker.hivemq.com';
  static const int port = 1883;

  // Топік для нашого навчального датчика.
  static const String topic = 'smartfit/lab04/demo-4f7b93/temperature';

  final StreamController<double> _temperatureController =
      StreamController<double>.broadcast();

  final ValueNotifier<TemperatureConnectionStatus> status = ValueNotifier(
    TemperatureConnectionStatus.disconnected,
  );

  MqttServerClient? _client;

  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>?
  _messageSubscription;

  bool _disposed = false;

  // Потік отриманих значень температури.
  Stream<double> get temperatures => _temperatureController.stream;

  // Перетворення текстового повідомлення на температуру.
  // Некоректні значення ігноруємо.
  static double? parseTemperature(String payload) {
    final text = payload.trim().replaceAll(',', '.');
    final value = double.tryParse(text);

    if (value == null || !value.isFinite) {
      return null;
    }

    // Допустимий діапазон для демонстраційного датчика.
    if (value < -60 || value > 80) {
      return null;
    }

    return value;
  }

  // Підключення до MQTT-брокера.
  Future<void> connect() async {
    if (_disposed) {
      throw StateError('MQTT-сервіс уже закрито');
    }

    if (status.value == TemperatureConnectionStatus.connecting ||
        status.value == TemperatureConnectionStatus.connected) {
      return;
    }

    status.value = TemperatureConnectionStatus.connecting;

    // Унікальний ідентифікатор MQTT-клієнта.
    final clientId = 'smartfit_${DateTime.now().microsecondsSinceEpoch}';

    final client = MqttServerClient(host, clientId)
      ..port = port
      ..keepAlivePeriod = 20
      ..logging(on: false);

    _client = client;

    client.setProtocolV311();

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();

    client.onDisconnected = () {
      if (!_disposed && status.value != TemperatureConnectionStatus.error) {
        status.value = TemperatureConnectionStatus.disconnected;
      }
    };

    try {
      // Обмежуємо час очікування підключення.
      await client.connect().timeout(const Duration(seconds: 12));

      if (_disposed) {
        client.disconnect();
        return;
      }

      if (client.connectionStatus?.state != MqttConnectionState.connected) {
        throw StateError('Не вдалося підключитися до MQTT');
      }

      final updates = client.updates;

      if (updates == null) {
        throw StateError('Потік MQTT-повідомлень недоступний');
      }

      // Слухаємо повідомлення від брокера.
      _messageSubscription = updates.listen((messages) {
        for (final received in messages) {
          if (received.topic != topic) {
            continue;
          }

          final message = received.payload;

          if (message is! MqttPublishMessage) {
            continue;
          }

          // Перетворюємо байти повідомлення на текст.
          final payload = MqttPublishPayload.bytesToStringAsString(
            message.payload.message,
          );

          final temperature = parseTemperature(payload);

          if (temperature != null && !_temperatureController.isClosed) {
            _temperatureController.add(temperature);
          }
        }
      });

      // Підписуємося на повідомлення датчика.
      final subscription = client.subscribe(topic, MqttQos.atMostOnce);

      if (subscription == null) {
        throw StateError('Не вдалося підписатися на топік');
      }

      status.value = TemperatureConnectionStatus.connected;
    } catch (_) {
      await _messageSubscription?.cancel();
      _messageSubscription = null;

      client.disconnect();

      if (!_disposed) {
        status.value = TemperatureConnectionStatus.error;
      }

      rethrow;
    }
  }

  // Коректно звільняємо ресурси.
  Future<void> dispose() async {
    if (_disposed) return;

    _disposed = true;

    await _messageSubscription?.cancel();
    _messageSubscription = null;

    _client?.disconnect();
    _client = null;

    await _temperatureController.close();
    status.dispose();
  }
}
