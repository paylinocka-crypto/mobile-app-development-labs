class AuthValidator {
  const AuthValidator._();

  static String? validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Введіть ім’я';
    }

    if (name.length < 2) {
      return 'Ім’я повинно містити мінімум 2 символи';
    }

    final namePattern = RegExp(r"^[A-Za-zА-Яа-яІіЇїЄєҐґ'’ -]+$");

    if (!namePattern.hasMatch(name)) {
      return 'Ім’я може містити лише літери, пробіли та дефіси';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Введіть електронну пошту';
    }

    final emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailPattern.hasMatch(email) || email.contains('..')) {
      return 'Введіть коректну електронну пошту';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.trim().isEmpty) {
      return 'Введіть пароль';
    }

    if (password.length < 8) {
      return 'Пароль повинен містити мінімум 8 символів';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Повторіть пароль';
    }

    if (value != password) {
      return 'Паролі не збігаються';
    }

    return null;
  }
}
