import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab_02/services/network_status_service.dart';
import 'package:lab_02/widgets/network_warning_banner.dart';

class FakeNetworkStatusService extends NetworkStatusService {
  FakeNetworkStatusService(bool? connected) {
    isConnected.value = connected;
  }

  @override
  Future<void> start() async {
    // Для тесту реальний мережевий плагін не потрібен.
  }
}

void main() {
  testWidgets('Lab04: offline warning is displayed', (tester) async {
    final service = FakeNetworkStatusService(false);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NetworkWarningBanner(service: service)),
      ),
    );

    expect(find.textContaining('Немає мережевого підключення'), findsOneWidget);

    expect(find.byIcon(Icons.wifi_off), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());

    await service.dispose();
  });

  testWidgets('Lab04: warning reacts to network changes', (tester) async {
    final service = FakeNetworkStatusService(true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NetworkWarningBanner(service: service)),
      ),
    );

    // Мережа доступна — попередження немає.
    expect(find.textContaining('Немає мережевого підключення'), findsNothing);

    // Імітуємо втрату мережі.
    service.isConnected.value = false;
    await tester.pump();

    expect(find.textContaining('Немає мережевого підключення'), findsOneWidget);

    // Імітуємо відновлення мережі.
    service.isConnected.value = true;
    await tester.pump();

    expect(find.textContaining('Немає мережевого підключення'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());

    await service.dispose();
  });
}
