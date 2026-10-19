import 'package:flutter/material.dart';
import 'package:lab_02/widgets/app_button.dart';
import 'package:lab_02/widgets/app_text_field.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Реєстрація')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    children: [
                      const Icon(Icons.person_add, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Створити акаунт',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Зареєструйтеся у SmartFit Weather',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      const AppTextField(label: 'Ім’я'),
                      const SizedBox(height: 16),
                      const AppTextField(label: 'Електронна пошта'),
                      const SizedBox(height: 16),
                      const AppTextField(label: 'Пароль', obscureText: true),
                      const SizedBox(height: 16),
                      const AppTextField(
                        label: 'Повторіть пароль',
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      AppButton(text: 'Зареєструватися', onPressed: () {}),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Вже є акаунт? Увійти'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
