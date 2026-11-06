import 'package:flutter/material.dart';
import 'package:lab_02/screens/dashboard_screen.dart';
import 'package:lab_02/screens/login_screen.dart';
import 'package:lab_02/screens/registration_screen.dart';
import 'package:lab_02/screens/workout_screen.dart';
import 'package:lab_02/screens/profile_screen.dart';

void main() {
  runApp(const SmartFitApp());
}

class SmartFitApp extends StatelessWidget {
  const SmartFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartFit Weather',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/workouts': (context) => const WorkoutScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
