import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voice_todo/features/todos/presentation/pages/add_task/add_task_page.dart';
import 'package:voice_todo/features/todos/presentation/pages/home/home_page.dart';
import 'package:voice_todo/features/todos/presentation/pages/settings/settings_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../data/remote/supabase_service.dart';

/// Application router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: _authGuard,
    routes: [
      // Auth Routes
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Main App Routes (Protected)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/add-task',
        name: 'add-task',
        builder: (context, state) => const AddTaskPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => _buildErrorPage(context, state),
  );

  /// Authentication guard for protected routes
  static String? _authGuard(BuildContext context, GoRouterState state) {
    final supabaseService = SupabaseService.instance;
    final isAuthenticated = supabaseService.isAuthenticated;
    final isAuthRoute =
        state.matchedLocation == '/' || state.matchedLocation == '/register';

    // If user is not authenticated and trying to access protected route
    if (!isAuthenticated && !isAuthRoute) {
      return '/';
    }

    // If user is authenticated and trying to access auth route
    if (isAuthenticated && isAuthRoute) {
      return '/home';
    }

    // No redirect needed
    return null;
  }

  /// Error page builder
  static Widget _buildErrorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sayfa Bulunamadı')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Sayfa bulunamadı',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Aradığınız sayfa mevcut değil: ${state.matchedLocation}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigation helper methods
class AppNavigation {
  /// Navigate to home page
  static void goToHome(BuildContext context) {
    if (context.mounted) {
      context.go('/home');
    }
  }

  /// Navigate to login page
  static void goToLogin(BuildContext context) {
    if (context.mounted) {
      context.go('/');
    }
  }

  /// Navigate to register page
  static void goToRegister(BuildContext context) {
    if (context.mounted) {
      context.go('/register');
    }
  }

  /// Navigate to add task page
  static void goToAddTask(BuildContext context) {
    if (context.mounted) {
      context.go('/add-task');
    }
  }

  /// Navigate to settings page
  static void goToSettings(BuildContext context) {
    if (context.mounted) {
      context.go('/settings');
    }
  }

  /// Go back
  static void goBack(BuildContext context) {
    if (context.mounted) {
      context.pop();
    }
  }
}
