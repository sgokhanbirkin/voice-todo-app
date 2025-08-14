import 'package:flutter/material.dart';

/// Common application scaffold with consistent styling
class AppScaffold extends StatelessWidget {
  /// App bar title
  final String title;

  /// App bar actions
  final List<Widget>? actions;

  /// Leading widget in app bar
  final Widget? leading;

  /// Body content
  final Widget body;

  /// Floating action button
  final Widget? floatingActionButton;

  /// Bottom navigation bar
  final Widget? bottomNavigationBar;

  /// Drawer
  final Widget? drawer;

  /// End drawer
  final Widget? endDrawer;

  /// Whether to automatically handle back button
  final bool automaticallyImplyLeading;

  /// Whether to show app bar
  final bool showAppBar;

  const AppScaffold({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.automaticallyImplyLeading = true,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? _buildAppBar(context) : null,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
    );
  }

  /// Builds the app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    );
  }
}

/// Scaffold with loading state
class LoadingScaffold extends StatelessWidget {
  /// App bar title
  final String title;

  /// Loading message
  final String? loadingMessage;

  const LoadingScaffold({super.key, required this.title, this.loadingMessage});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (loadingMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                loadingMessage!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Scaffold with error state
class ErrorScaffold extends StatelessWidget {
  /// App bar title
  final String title;

  /// Error message
  final String errorMessage;

  /// Retry callback
  final VoidCallback? onRetry;

  const ErrorScaffold({
    super.key,
    required this.title,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                errorMessage,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// TODO: Add more scaffold variants (e.g., with bottom sheet, with modal)
// TODO: Implement responsive behavior for different screen sizes
// TODO: Add animation transitions (Part 5 - UI & Navigation)
// TODO: Create custom app bar with search functionality (Part 5 - UI & Navigation)
