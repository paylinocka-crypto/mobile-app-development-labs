import 'package:flutter_test/flutter_test.dart';
import 'package:lab_02/domain/validators/auth_validator.dart';

void main() {
  group('Перевірка даних користувача', () {
    test('Правильне ім’я проходить перевірку', () {
      expect(AuthValidator.validateName('Пауліна'), isNull);
      expect(AuthValidator.validateName('Марія-Анна'), isNull);
    });

    test('Неправильне ім’я відхиляється', () {
      expect(AuthValidator.validateName(''), isNotNull);
      expect(AuthValidator.validateName('П'), isNotNull);
      expect(AuthValidator.validateName('Поля123'), isNotNull);
    });

    test('Перевірка електронної пошти', () {
      expect(AuthValidator.validateEmail('polya@gmail.com'), isNull);

      expect(AuthValidator.validateEmail('polyagmail.com'), isNotNull);

      expect(AuthValidator.validateEmail('polya@'), isNotNull);
    });

    test('Пароль має містити мінімум 8 символів', () {
      expect(AuthValidator.validatePassword('12345678'), isNull);

      expect(AuthValidator.validatePassword('12345'), isNotNull);

      expect(AuthValidator.validatePassword(''), isNotNull);
    });

    test('Підтвердження пароля повинно збігатися', () {
      expect(
        AuthValidator.validateConfirmPassword('Password123', 'Password123'),
        isNull,
      );

      expect(
        AuthValidator.validateConfirmPassword('Password456', 'Password123'),
        isNotNull,
      );
    });
  });
}
