import 'package:flutter/material.dart';

void main() {
  runApp(const CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 01',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final TextEditingController _controller = TextEditingController();

  int _counter = 0;

  void _processInput() {
    final input = _controller.text.trim();

    if (input == 'Avada Kedavra') {
      setState(() {
        _counter = 0;
      });

      _controller.clear();
      return;
    }

    final number = int.tryParse(input);

    if (number != null) {
      setState(() {
        _counter += number;
      });

      _controller.clear();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Помилка: введіть ціле число або команду Avada Kedavra.'),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Лабораторна робота №1')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Поточне значення лічильника:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text('$_counter', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Число або команда',
                hintText: 'Наприклад: 5 або Avada Kedavra',
              ),
              onSubmitted: (_) => _processInput(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _processInput,
              child: const Text('Виконати'),
            ),
          ],
        ),
      ),
    );
  }
}
