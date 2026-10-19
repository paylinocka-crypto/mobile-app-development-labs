import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мій профіль')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const CircleAvatar(
                  radius: 45,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),

                Text(
                  'Користувач SmartFit',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),
                const Text('Мій фітнес-профіль', textAlign: TextAlign.center),

                const SizedBox(height: 32),

                const Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.person_outline),
                        title: Text('Ім’я'),
                        subtitle: Text('Демо користувач'),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.location_city),
                        title: Text('Місто'),
                        subtitle: Text('Львів'),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.fitness_center),
                        title: Text('Мета'),
                        subtitle: Text('Регулярні тренування'),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.watch),
                        title: Text('Фітнес-пристрій'),
                        subtitle: Text('SmartFit Band (демо)'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Повернутися до входу'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
