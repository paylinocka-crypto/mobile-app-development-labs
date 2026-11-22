import 'package:flutter/material.dart';

import 'package:lab_02/data/local_auth_repository.dart';
import 'package:lab_02/data/local_workout_repository.dart';

import 'package:lab_02/domain/models/app_user.dart';
import 'package:lab_02/domain/repositories/auth_repository.dart';
import 'package:lab_02/domain/repositories/workout_repository.dart';

import 'package:lab_02/screens/dashboard_screen.dart';
import 'package:lab_02/screens/login_screen.dart';
import 'package:lab_02/screens/profile_screen.dart';
import 'package:lab_02/screens/registration_screen.dart';
import 'package:lab_02/screens/workout_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartFitApp());
}

class SmartFitApp extends StatelessWidget {
  const SmartFitApp({this.authRepository, this.workoutRepository, super.key});

  final AuthRepository? authRepository;
  final WorkoutRepository? workoutRepository;

  @override
  Widget build(BuildContext context) {
    final auth = authRepository ?? LocalAuthRepository();
    final workouts = workoutRepository ?? LocalWorkoutRepository();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartFit Weather',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(authRepository: auth),
        '/register': (context) => RegistrationScreen(authRepository: auth),
        '/dashboard': (context) => _SessionGuard(
          authRepository: auth,
          builder: (context) => DashboardScreen(
            authRepository: auth,
            workoutRepository: workouts,
          ),
        ),
        '/workouts': (context) => _SessionGuard(
          authRepository: auth,
          builder: (context) => const WorkoutScreen(),
        ),
        '/profile': (context) => _SessionGuard(
          authRepository: auth,
          builder: (context) => ProfileScreen(authRepository: auth),
        ),
      },
    );
  }
}

// Перевіряємо авторизацію перед відкриттям захищеного екрана.
class _SessionGuard extends StatefulWidget {
  const _SessionGuard({required this.authRepository, required this.builder});

  final AuthRepository authRepository;
  final WidgetBuilder builder;

  @override
  State<_SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<_SessionGuard> {
  late Future<AppUser?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = widget.authRepository.getCurrentUser();
  }

  @override
  void didUpdateWidget(covariant _SessionGuard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.authRepository != widget.authRepository) {
      _userFuture = widget.authRepository.getCurrentUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Не вдалося перевірити авторизацію',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      child: const Text('До входу'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.data == null) {
          return LoginScreen(authRepository: widget.authRepository);
        }

        return widget.builder(context);
      },
    );
  }
}
