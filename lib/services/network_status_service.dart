import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkStatusService {
  NetworkStatusService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  // null — стан мережі поки невідомий.
  // true — мережевий інтерфейс доступний.
  // false — немає активного мережевого інтерфейсу.
  final ValueNotifier<bool?> isConnected = ValueNotifier<bool?>(null);

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _disposed = false;
  bool _started = false;

  // Перевірка наявності мережевого підключення.
  static bool hasNetworkInterface(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return false;
    }

    return results.any((result) => result != ConnectivityResult.none);
  }

  // Запуск моніторингу змін мережі.
  Future<void> start() async {
    if (_disposed) {
      throw StateError('Сервіс моніторингу мережі закритий');
    }

    if (_started) return;

    _started = true;

    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        if (_disposed) return;

        isConnected.value = hasNetworkInterface(results);
      },
      onError: (Object error) {
        if (_disposed) return;

        isConnected.value = null;
      },
    );

    await refresh();
  }

  // Отримання поточного стану мережі.
  Future<bool?> refresh() async {
    if (_disposed) return null;

    try {
      final results = await _connectivity.checkConnectivity();

      final connected = hasNetworkInterface(results);

      if (!_disposed) {
        isConnected.value = connected;
      }

      return connected;
    } catch (_) {
      if (!_disposed) {
        isConnected.value = null;
      }

      return null;
    }
  }

  // Зупинка моніторингу та очищення ресурсів.
  Future<void> dispose() async {
    if (_disposed) return;

    _disposed = true;

    await _subscription?.cancel();
    _subscription = null;

    isConnected.dispose();
  }
}
