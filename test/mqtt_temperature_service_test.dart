import 'package:flutter_test/flutter_test.dart';
import 'package:lab_02/services/mqtt_temperature_service.dart';

void main() {
  group('Lab04: MQTT temperature parsing', () {
    test('Correct temperature is accepted', () {
      final result = MqttTemperatureService.parseTemperature('21.5');

      expect(result, 21.5);
    });

    test('Temperature with comma is accepted', () {
      final result = MqttTemperatureService.parseTemperature(' 22,7 ');

      expect(result, 22.7);
    });

    test('Invalid text is rejected', () {
      final result = MqttTemperatureService.parseTemperature('hello');

      expect(result, isNull);
    });

    test('Temperature outside expected range is rejected', () {
      final result = MqttTemperatureService.parseTemperature('150');

      expect(result, isNull);
    });

    test('NaN is rejected', () {
      final result = MqttTemperatureService.parseTemperature('NaN');

      expect(result, isNull);
    });
  });
}
