import 'package:flutter/material.dart';
import 'package:lab_02/widgets/app_button.dart';
import 'package:lab_02/widgets/app_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fitness_center, size: 72),
                      const SizedBox(height: 16),
                      Text(
                        'SmartFit Weather',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Плануй тренування відповідно до погоди',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      const AppTextField(label: 'Електронна пошта'),
                      const SizedBox(height: 16),
                      const AppTextField(label: 'Пароль', obscureText: true),
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Увійти',
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/dashboard');
                        },
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('Немає акаунта? Зареєструватися'),
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
