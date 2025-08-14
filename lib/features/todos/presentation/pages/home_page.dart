import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../product/widgets/app_scaffold.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Home page widget
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Ana Sayfa',
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // TODO: Navigate to settings
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            final authController = Get.find<AuthController>();
            await authController.signOut();
            Get.offAllNamed('/'); // Navigate back to login
          },
        ),
      ],
      body: const _HomePageBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add task page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Home page body content
class _HomePageBody extends StatelessWidget {
  const _HomePageBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Ana Sayfa',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Görev yönetimi yakında burada olacak!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to add task page
            },
            icon: const Icon(Icons.add),
            label: const Text('Görev Ekle'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
