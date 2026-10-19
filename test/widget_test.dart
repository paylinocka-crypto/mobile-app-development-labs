import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_02/main.dart';

void main() {
  testWidgets('Login screen opens correctly', (tester) async {
    await tester.pumpWidget(const SmartFitApp());

    expect(find.text('SmartFit Weather'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Увійти'), findsOneWidget);
  });

  testWidgets('Login opens registration', (tester) async {
    await tester.pumpWidget(const SmartFitApp());

    await tester.tap(find.text('Немає акаунта? Зареєструватися'));

    await tester.pumpAndSettle();

    expect(find.text('Створити акаунт'), findsOneWidget);
    expect(find.text('Повторіть пароль'), findsOneWidget);
  });

  testWidgets('Login opens dashboard', (tester) async {
    await tester.pumpWidget(const SmartFitApp());

    await tester.tap(find.text('Увійти'));
    await tester.pumpAndSettle();

    expect(find.text('Добрий день!'), findsOneWidget);
    expect(find.text('Львів'), findsOneWidget);
    expect(find.text('6250'), findsOneWidget);
  });

  testWidgets('Dashboard opens workouts', (tester) async {
    await tester.pumpWidget(const SmartFitApp());

    await tester.tap(find.text('Увійти'));
    await tester.pumpAndSettle();

    final workoutButton = find.text('Переглянути тренування');

    await tester.ensureVisible(workoutButton);
    await tester.tap(workoutButton);
    await tester.pumpAndSettle();

    expect(find.text('Обери тренування'), findsOneWidget);
    expect(find.text('Біг на вулиці'), findsOneWidget);
  });

  testWidgets('Dashboard opens profile', (tester) async {
    await tester.pumpWidget(const SmartFitApp());

    await tester.tap(find.text('Увійти'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Мій профіль'));
    await tester.pumpAndSettle();

    expect(find.text('Мій профіль'), findsOneWidget);
    expect(find.text('Користувач SmartFit'), findsOneWidget);
  });
}
