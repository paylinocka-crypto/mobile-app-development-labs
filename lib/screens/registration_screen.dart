import 'package:flutter/material.dart';
import 'package:lab_02/domain/repositories/auth_repository.dart';
import 'package:lab_02/domain/validators/auth_validator.dart';
import 'package:lab_02/widgets/app_button.dart';
import 'package:lab_02/widgets/app_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({required this.authRepository, super.key});

  final AuthRepository authRepository;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isLoading || _formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.authRepository.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Акаунт створено! Тепер увійдіть.')),
      );
      Navigator.pop(context);
    } on FormatException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message);
      }
    } on StateError catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message.toString());
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Не вдалося створити акаунт';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Реєстрація')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(Icons.person_add, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Створити акаунт',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Ім’я',
                      controller: _nameController,
                      validator: AuthValidator.validateName,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Електронна пошта',
                      controller: _emailController,
                      validator: AuthValidator.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Пароль',
                      controller: _passwordController,
                      obscureText: true,
                      validator: AuthValidator.validatePassword,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Повторіть пароль',
                      controller: _confirmController,
                      obscureText: true,
                      validator: (value) =>
                          AuthValidator.validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      AppButton(text: 'Зареєструватися', onPressed: _register),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Вже є акаунт? Увійти'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
