import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../product/responsive/responsive.dart';
import '../../../../../product/theme/app_theme.dart';
import '../../controllers/task_controller.dart';
import '../../../domain/i_task_repository.dart';

/// Task statistics card widget for home page
class HomePageBodyStatistics extends StatelessWidget {
  final AppLocalizations l10n;
  final TaskController controller;

  const HomePageBodyStatistics({
    super.key,
    required this.l10n,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.taskStatistics.value;
      if (stats == null) return const SizedBox.shrink();

      return ResponsiveWidgets.responsiveCard(
        context,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: ResponsiveBuilder(
          mobile: (context) => _buildMobileStatistics(context, stats),
          tablet: (context) => _buildTabletStatistics(context, stats),
          desktop: (context) => _buildDesktopStatistics(context, stats),
        ),
      );
    });
  }

  Widget _buildMobileStatistics(BuildContext context, TaskStatistics stats) {
    return Row(
      children: [
        ResponsiveWidgets.responsiveIcon(
          context,
          icon: Icons.analytics,
          color: Theme.of(context).colorScheme.primary,
          mobileSize: 24,
          tabletSize: 28,
          desktopSize: 32,
        ),
        ResponsiveWidgets.horizontalSpace(
          context,
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
        ResponsiveWidgets.responsiveText(
          context,
          text: l10n.statistics,
          mobileFontSize: 18,
          tabletFontSize: 20,
          desktopFontSize: 22,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        _buildStatItem(
          context,
          l10n.tasks,
          stats.totalTasks.toString(),
          AppColors.primaryBlue,
        ),
        ResponsiveWidgets.horizontalSpace(
          context,
          mobile: 8,
          tablet: 12,
          desktop: 16,
        ),
        _buildStatItem(
          context,
          l10n.completed,
          stats.completedTasks.toString(),
          AppColors.success,
        ),
        ResponsiveWidgets.horizontalSpace(
          context,
          mobile: 8,
          tablet: 12,
          desktop: 16,
        ),
        _buildStatItem(
          context,
          l10n.pending,
          stats.pendingTasks.toString(),
          AppColors.warning,
        ),
        ResponsiveWidgets.horizontalSpace(
          context,
          mobile: 8,
          tablet: 12,
          desktop: 16,
        ),
        _buildStatItem(
          context,
          l10n.overdue,
          stats.overdueTasks.toString(),
          AppColors.error,
        ),
      ],
    );
  }

  Widget _buildTabletStatistics(BuildContext context, TaskStatistics stats) {
    return Row(
      children: [
        ResponsiveWidgets.responsiveIcon(
          context,
          icon: Icons.analytics,
          color: Theme.of(context).colorScheme.primary,
          mobileSize: 24,
          tabletSize: 28,
          desktopSize: 32,
        ),
        ResponsiveWidgets.horizontalSpace(
          context,
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
        Expanded(
          child: ResponsiveWidgets.responsiveText(
            context,
            text: l10n.statistics,
            mobileFontSize: 18,
            tabletFontSize: 20,
            desktopFontSize: 22,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        ResponsiveWidgets.horizontalSpace(
          context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
        _buildStatItem(
          context,
          l10n.tasks,
          stats.totalTasks.toString(),
          AppColors.primaryBlue,
        ),
        ResponsiveWidgets.horizontalSpace(
          context,
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
        _buildStatItem(
          context,
          l10n.completed,
          stats.completedTasks.toString(),
          AppColors.success,
        ),
        ResponsiveWidgets.horizontalSpace(
          context,
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
        _buildStatItem(
          context,
          l10n.pending,
          stats.pendingTasks.toString(),
          AppColors.warning,
        ),
        ResponsiveWidgets.horizontalSpace(
          context,
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
        _buildStatItem(
          context,
          l10n.overdue,
          stats.overdueTasks.toString(),
          AppColors.error,
        ),
      ],
    );
  }

  Widget _buildDesktopStatistics(BuildContext context, TaskStatistics stats) {
    return Row(
      children: [
        ResponsiveWidgets.responsiveIcon(
          context,
          icon: Icons.analytics,
          color: Theme.of(context).colorScheme.primary,
          mobileSize: 24,
          tabletSize: 28,
          desktopSize: 32,
        ),
        ResponsiveWidgets.horizontalSpace(
          context,
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
        Expanded(
          child: ResponsiveWidgets.responsiveText(
            context,
            text: l10n.statistics,
            mobileFontSize: 18,
            tabletFontSize: 20,
            desktopFontSize: 22,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        ResponsiveWidgets.horizontalSpace(
          context,
          mobile: 20,
          tablet: 24,
          desktop: 28,
        ),
        _buildStatItem(
          context,
          l10n.tasks,
          stats.totalTasks.toString(),
          AppColors.primaryBlue,
        ),
        ResponsiveWidgets.horizontalSpace(
          context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
        _buildStatItem(
          context,
          l10n.completed,
          stats.completedTasks.toString(),
          AppColors.success,
        ),
        ResponsiveWidgets.horizontalSpace(
          context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
        _buildStatItem(
          context,
          l10n.pending,
          stats.pendingTasks.toString(),
          AppColors.warning,
        ),
        ResponsiveWidgets.horizontalSpace(
          context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
        _buildStatItem(
          context,
          l10n.overdue,
          stats.overdueTasks.toString(),
          AppColors.error,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ResponsiveWidgets.responsiveText(
          context,
          text: value,
          mobileFontSize: 20,
          tabletFontSize: 24,
          desktopFontSize: 28,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        ResponsiveWidgets.verticalSpace(
          context,
          mobile: 4,
          tablet: 6,
          desktop: 8,
        ),
        ResponsiveWidgets.responsiveText(
          context,
          text: label,
          mobileFontSize: 12,
          tabletFontSize: 14,
          desktopFontSize: 16,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
