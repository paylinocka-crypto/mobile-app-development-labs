import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lab_02/services/network_status_service.dart';

class NetworkWarningBanner extends StatefulWidget {
  const NetworkWarningBanner({this.service, super.key});

  // Можемо передати тестовий сервіс.
  final NetworkStatusService? service;

  @override
  State<NetworkWarningBanner> createState() => _NetworkWarningBannerState();
}

class _NetworkWarningBannerState extends State<NetworkWarningBanner> {
  late final NetworkStatusService _service;
  late final bool _ownsService;

  @override
  void initState() {
    super.initState();

    _ownsService = widget.service == null;
    _service = widget.service ?? NetworkStatusService();

    // Починаємо відстежувати зміни мережі.
    unawaited(
      _service.start().catchError((Object error) {
        // Якщо стан не вдалося визначити,
        // застосунок не повинен аварійно завершуватися.
      }),
    );
  }

  @override
  void dispose() {
    // Сервіс, створений самим віджетом, закриваємо.
    // Переданий ззовні сервіс належить його власнику.
    if (_ownsService) {
      unawaited(_service.dispose());
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool?>(
      valueListenable: _service.isConnected,
      builder: (context, isConnected, child) {
        // Показуємо попередження лише за
        // підтвердженої відсутності мережі.
        if (isConnected != false) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.red.shade700,
          child: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Немає мережевого підключення. '
                  'Доступний обмежений режим.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
