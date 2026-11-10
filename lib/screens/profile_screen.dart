import 'package:flutter/material.dart';
import 'package:lab_02/domain/models/app_user.dart';
import 'package:lab_02/domain/repositories/auth_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.authRepository, super.key});

  final AuthRepository authRepository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<AppUser?> _userFuture;
  bool _loggingOut = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _userFuture = widget.authRepository.getCurrentUser();
  }

  Future<void> _logout() async {
    if (_loggingOut) return;

    setState(() {
      _loggingOut = true;
      _error = null;
    });

    try {
      await widget.authRepository.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Не вдалося вийти з акаунта';
        _loggingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Мій профіль')),
      body: SafeArea(
        child: FutureBuilder<AppUser?>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Не вдалося завантажити профіль'),
              );
            }

            final user = snapshot.data;

            if (user == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Користувач не авторизований'),
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
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      CircleAvatar(
                        radius: 43,
                        backgroundColor: colors.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.email,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.badge_outlined),
                              title: const Text('Імʼя'),
                              subtitle: Text(user.name),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.email_outlined),
                              title: const Text('Електронна пошта'),
                              subtitle: Text(user.email),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _error!,
                            style: TextStyle(color: colors.error),
                          ),
                        ),
                      OutlinedButton.icon(
                        onPressed: _loggingOut ? null : _logout,
                        icon: _loggingOut
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.logout),
                        label: const Text('Вийти з акаунта'),
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
