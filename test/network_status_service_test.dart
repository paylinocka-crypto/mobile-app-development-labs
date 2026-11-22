import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_02/services/network_status_service.dart';

void main() {
  group('Lab04: network status', () {
    test('No connection returns false', () {
      final result = NetworkStatusService.hasNetworkInterface([
        ConnectivityResult.none,
      ]);

      expect(result, isFalse);
    });

    test('Wi-Fi connection returns true', () {
      final result = NetworkStatusService.hasNetworkInterface([
        ConnectivityResult.wifi,
      ]);

      expect(result, isTrue);
    });

    test('Mobile connection returns true', () {
      final result = NetworkStatusService.hasNetworkInterface([
        ConnectivityResult.mobile,
      ]);

      expect(result, isTrue);
    });

    test('Empty connection list returns false', () {
      final result = NetworkStatusService.hasNetworkInterface([]);

      expect(result, isFalse);
    });

    test('Multiple connections are supported', () {
      final result = NetworkStatusService.hasNetworkInterface([
        ConnectivityResult.wifi,
        ConnectivityResult.mobile,
      ]);

      expect(result, isTrue);
    });
  });
}
