import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../product/responsive/responsive.dart';
import '../../../../../product/theme/app_theme.dart';
import '../../controllers/task_controller.dart';

// TODO LOCALIZATION
/// Loading, error, and empty states for home page body
class HomePageBodyStates {
  /// Build loading state with circular progress indicator
  static Widget buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          ResponsiveWidgets.verticalSpace(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
          ResponsiveWidgets.responsiveText(
            context,
            text: 'Loading tasks...',
            mobileFontSize: 16,
            tabletFontSize: 18,
            desktopFontSize: 20,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  /// Build error state with retry button
  static Widget buildErrorState(
    BuildContext context,
    TaskController controller,
  ) {
    return Center(
      child: ResponsiveWidgets.responsiveContainer(
        context,
        color: AppColors.error.withValues(alpha: 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ResponsiveWidgets.responsiveIcon(
              context,
              icon: Icons.error_outline,
              color: AppColors.error,
              mobileSize: 48,
              tabletSize: 56,
              desktopSize: 64,
            ),
            ResponsiveWidgets.verticalSpace(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
            ResponsiveWidgets.responsiveText(
              context,
              text: 'Failed to load tasks',
              mobileFontSize: 18,
              tabletFontSize: 20,
              desktopFontSize: 22,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            ResponsiveWidgets.verticalSpace(
              context,
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
            ResponsiveWidgets.responsiveText(
              context,
              text: 'Please check your connection and try again',
              mobileFontSize: 14,
              tabletFontSize: 16,
              desktopFontSize: 18,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            ResponsiveWidgets.verticalSpace(
              context,
              mobile: 24,
              tablet: 28,
              desktop: 32,
            ),
            ElevatedButton.icon(
              onPressed: () => controller.refresh(),
              icon: const Icon(Icons.refresh),
              label: ResponsiveWidgets.responsiveText(
                context,
                text: 'Retry',
                mobileFontSize: 16,
                tabletFontSize: 18,
                desktopFontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state when no tasks exist
  static Widget buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: ResponsiveWidgets.responsiveContainer(
        context,
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ResponsiveWidgets.responsiveIcon(
              context,
              icon: Icons.task_alt,
              color: Theme.of(context).colorScheme.primary,
              mobileSize: 64,
              tabletSize: 72,
              desktopSize: 80,
            ),
            ResponsiveWidgets.verticalSpace(
              context,
              mobile: 24,
              tablet: 28,
              desktop: 32,
            ),
            ResponsiveWidgets.responsiveText(
              context,
              text: l10n.noTasks,
              mobileFontSize: 20,
              tabletFontSize: 22,
              desktopFontSize: 24,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            ResponsiveWidgets.verticalSpace(
              context,
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
            ResponsiveWidgets.responsiveText(
              context,
              text: 'Create your first task to get started',
              mobileFontSize: 16,
              tabletFontSize: 18,
              desktopFontSize: 20,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            ResponsiveWidgets.verticalSpace(
              context,
              mobile: 32,
              tablet: 40,
              desktop: 48,
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to add task page or show dialog
              },
              icon: const Icon(Icons.add),
              label: ResponsiveWidgets.responsiveText(
                context,
                text: l10n.addTask,
                mobileFontSize: 16,
                tabletFontSize: 18,
                desktopFontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
