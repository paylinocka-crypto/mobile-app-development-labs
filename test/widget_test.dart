import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_01/main.dart';

void main() {
  testWidgets('Counter processes integer input', (tester) async {
    await tester.pumpWidget(const CounterApp());

    expect(find.text('0'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '5');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('Avada Kedavra resets counter', (tester) async {
    await tester.pumpWidget(const CounterApp());

    await tester.enterText(find.byType(TextField), '10');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('10'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Avada Kedavra');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Invalid decimal input shows error', (tester) async {
    await tester.pumpWidget(const CounterApp());

    await tester.enterText(find.byType(TextField), '3.14');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('0'), findsOneWidget);

    expect(
      find.text(
        'Помилка: введіть ціле число або команду Avada Kedavra.',
      ),
      findsOneWidget,
    );
  });
}