import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../product/responsive/responsive.dart';
import '../../../../product/theme/app_theme.dart';
import '../../../../product/widgets/app_scaffold.dart';
import '../controllers/task_controller.dart';

/// Settings and Analytics page with insights and statistics
/// Provides comprehensive task analytics, audio insights, and productivity metrics
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AppScaffold(
      title: l10n.analytics,
      body: ResponsiveBuilder(
        mobile: (context) => const _AnalyticsView(),
        tablet: (context) => const _AnalyticsGridView(crossAxisCount: 2),
        desktop: (context) => const _AnalyticsGridView(crossAxisCount: 3),
      ),
    );
  }
}

/// Analytics view for mobile devices
class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final taskController = Get.find<TaskController>();

    return SingleChildScrollView(
      padding: Responsive.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          _OverviewSection(l10n: l10n, controller: taskController),
          
          ResponsiveWidgets.verticalSpace(context, mobile: 24, tablet: 32, desktop: 40),
          
          // Task Statistics
          _TaskStatisticsSection(l10n: l10n, controller: taskController),
          
          ResponsiveWidgets.verticalSpace(context, mobile: 24, tablet: 32, desktop: 40),
          
          // Audio Insights
          _AudioInsightsSection(l10n: l10n, controller: taskController),
          
          ResponsiveWidgets.verticalSpace(context, mobile: 24, tablet: 32, desktop: 40),
          
          // Productivity Trends
          _ProductivitySection(l10n: l10n, controller: taskController),
        ],
      ),
    );
  }
}

/// Analytics grid view for tablet and desktop
class _AnalyticsGridView extends StatelessWidget {
  final int crossAxisCount;
  
  const _AnalyticsGridView({required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final taskController = Get.find<TaskController>();

    return SingleChildScrollView(
      padding: Responsive.getResponsivePadding(context),
      child: Column(
        children: [
          // Overview Cards Grid
          _OverviewGridSection(l10n: l10n, controller: taskController, crossAxisCount: crossAxisCount),
          
          ResponsiveWidgets.verticalSpace(context, mobile: 32, tablet: 40, desktop: 48),
          
          // Statistics and Insights Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _TaskStatisticsSection(l10n: l10n, controller: taskController),
              ),
              ResponsiveWidgets.horizontalSpace(context, mobile: 16, tablet: 20, desktop: 24),
              Expanded(
                child: _AudioInsightsSection(l10n: l10n, controller: taskController),
              ),
            ],
          ),
          
          ResponsiveWidgets.verticalSpace(context, mobile: 32, tablet: 40, desktop: 48),
          
          // Productivity Section
          _ProductivitySection(l10n: l10n, controller: taskController),
        ],
      ),
    );
  }
}

/// Overview statistics cards section
class _OverviewSection extends StatelessWidget {
  final AppLocalizations l10n;
  final TaskController controller;

  const _OverviewSection({required this.l10n, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveWidgets.responsiveText(
          context,
          text: l10n.statistics,
          mobileFontSize: 20,
          tabletFontSize: 22,
          desktopFontSize: 24,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        ResponsiveWidgets.verticalSpace(context, mobile: 16, tablet: 20, desktop: 24),
        
        Obx(() {
          final stats = controller.taskStatistics.value;
          if (stats == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildOverviewCard(
                    context,
                    l10n.tasks,
                    stats.totalTasks.toString(),
                    Icons.task_alt,
                    AppColors.primaryBlue,
                  )),
                  ResponsiveWidgets.horizontalSpace(context, mobile: 12, tablet: 16, desktop: 20),
                  Expanded(child: _buildOverviewCard(
                    context,
                    l10n.completed,
                    stats.completedTasks.toString(),
                    Icons.check_circle,
                    AppColors.success,
                  )),
                ],
              ),
              
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              
              Row(
                children: [
                  Expanded(child: _buildOverviewCard(
                    context,
                    l10n.pending,
                    stats.pendingTasks.toString(),
                    Icons.pending_actions,
                    AppColors.warning,
                  )),
                  ResponsiveWidgets.horizontalSpace(context, mobile: 12, tablet: 16, desktop: 20),
                  Expanded(child: _buildOverviewCard(
                    context,
                    l10n.overdue,
                    stats.overdueTasks.toString(),
                    Icons.schedule,
                    AppColors.error,
                  )),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return ResponsiveWidgets.responsiveContainer(
      context,
      color: color.withValues(alpha: 0.1),
      child: Column(
        children: [
          Row(
            children: [
              ResponsiveWidgets.responsiveIcon(
                context,
                icon: icon,
                color: color,
                mobileSize: 24,
                tabletSize: 28,
                desktopSize: 32,
              ),
              ResponsiveWidgets.horizontalSpace(context, mobile: 8, tablet: 12, desktop: 16),
              Expanded(
                child: ResponsiveWidgets.responsiveText(
                  context,
                  text: title,
                  mobileFontSize: 14,
                  tabletFontSize: 16,
                  desktopFontSize: 18,
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          ResponsiveWidgets.verticalSpace(context, mobile: 8, tablet: 12, desktop: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: ResponsiveWidgets.responsiveText(
              context,
              text: value,
              mobileFontSize: 24,
              tabletFontSize: 28,
              desktopFontSize: 32,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overview grid section for tablet/desktop
class _OverviewGridSection extends StatelessWidget {
  final AppLocalizations l10n;
  final TaskController controller;
  final int crossAxisCount;

  const _OverviewGridSection({
    required this.l10n,
    required this.controller,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveWidgets.responsiveText(
          context,
          text: l10n.statistics,
          mobileFontSize: 20,
          tabletFontSize: 22,
          desktopFontSize: 24,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        ResponsiveWidgets.verticalSpace(context, mobile: 16, tablet: 20, desktop: 24),
        
        Obx(() {
          final stats = controller.taskStatistics.value;
          if (stats == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final cards = [
            _buildOverviewCardData(l10n.tasks, stats.totalTasks.toString(), Icons.task_alt, AppColors.primaryBlue),
            _buildOverviewCardData(l10n.completed, stats.completedTasks.toString(), Icons.check_circle, AppColors.success),
            _buildOverviewCardData(l10n.pending, stats.pendingTasks.toString(), Icons.pending_actions, AppColors.warning),
            _buildOverviewCardData(l10n.overdue, stats.overdueTasks.toString(), Icons.schedule, AppColors.error),
          ];
          
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: Responsive.getResponsiveSpacing(context, mobile: 16, tablet: 20, desktop: 24),
              mainAxisSpacing: Responsive.getResponsiveSpacing(context, mobile: 16, tablet: 20, desktop: 24),
              childAspectRatio: 1.5,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return _buildOverviewCard(context, card.title, card.value, card.icon, card.color);
            },
          );
        }),
      ],
    );
  }

  _OverviewCardData _buildOverviewCardData(String title, String value, IconData icon, Color color) {
    return _OverviewCardData(title: title, value: value, icon: icon, color: color);
  }

  Widget _buildOverviewCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return ResponsiveWidgets.responsiveContainer(
      context,
      color: color.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ResponsiveWidgets.responsiveIcon(
            context,
            icon: icon,
            color: color,
            mobileSize: 32,
            tabletSize: 36,
            desktopSize: 40,
          ),
          ResponsiveWidgets.verticalSpace(context, mobile: 8, tablet: 12, desktop: 16),
          ResponsiveWidgets.responsiveText(
            context,
            text: value,
            mobileFontSize: 24,
            tabletFontSize: 28,
            desktopFontSize: 32,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          ResponsiveWidgets.verticalSpace(context, mobile: 4, tablet: 6, desktop: 8),
          ResponsiveWidgets.responsiveText(
            context,
            text: title,
            mobileFontSize: 14,
            tabletFontSize: 16,
            desktopFontSize: 18,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Task statistics section with charts and insights
class _TaskStatisticsSection extends StatelessWidget {
  final AppLocalizations l10n;
  final TaskController controller;

  const _TaskStatisticsSection({required this.l10n, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveWidgets.responsiveText(
          context,
          text: l10n.taskTrends,
          mobileFontSize: 18,
          tabletFontSize: 20,
          desktopFontSize: 22,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        ResponsiveWidgets.verticalSpace(context, mobile: 16, tablet: 20, desktop: 24),
        
        ResponsiveWidgets.responsiveContainer(
          context,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            children: [
              // Priority Distribution
              _buildStatRow(context, l10n.priorityDistribution, '60% High, 30% Medium, 10% Low'),
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              
              // Completion Rate
              _buildStatRow(context, l10n.completionRate, '78%'),
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              
              // Average Completion Time
              _buildStatRow(context, l10n.averageCompletionTime, '2.5 days'),
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              
              // Most Productive Day
              _buildStatRow(context, l10n.mostProductiveDay, 'Tuesday'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: ResponsiveWidgets.responsiveText(
            context,
            text: label,
            mobileFontSize: 14,
            tabletFontSize: 16,
            desktopFontSize: 18,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: ResponsiveWidgets.responsiveText(
            context,
            text: value,
            mobileFontSize: 14,
            tabletFontSize: 16,
            desktopFontSize: 18,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// Audio insights section
class _AudioInsightsSection extends StatelessWidget {
  final AppLocalizations l10n;
  final TaskController controller;

  const _AudioInsightsSection({required this.l10n, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveWidgets.responsiveText(
          context,
          text: l10n.audioInsights,
          mobileFontSize: 18,
          tabletFontSize: 20,
          desktopFontSize: 22,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        ResponsiveWidgets.verticalSpace(context, mobile: 16, tablet: 20, desktop: 24),
        
        ResponsiveWidgets.responsiveContainer(
          context,
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Column(
            children: [
              _buildAudioStat(
                context,
                l10n.totalRecordings,
                '24',
                Icons.mic,
                AppColors.audioRecording,
              ),
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              
              _buildAudioStat(
                context,
                l10n.totalDuration,
                '2h 35m',
                Icons.schedule,
                AppColors.primaryBlue,
              ),
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              
              _buildAudioStat(
                context,
                l10n.averageLength,
                '6m 28s',
                Icons.timer,
                AppColors.success,
              ),
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              
              _buildAudioStat(
                context,
                l10n.recordingQuality,
                'High',
                Icons.high_quality,
                AppColors.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        ResponsiveWidgets.responsiveIcon(
          context,
          icon: icon,
          color: color,
          mobileSize: 20,
          tabletSize: 24,
          desktopSize: 28,
        ),
        ResponsiveWidgets.horizontalSpace(context, mobile: 12, tablet: 16, desktop: 20),
        Expanded(
          child: ResponsiveWidgets.responsiveText(
            context,
            text: label,
            mobileFontSize: 14,
            tabletFontSize: 16,
            desktopFontSize: 18,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        ResponsiveWidgets.responsiveText(
          context,
          text: value,
          mobileFontSize: 16,
          tabletFontSize: 18,
          desktopFontSize: 20,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Productivity trends section
class _ProductivitySection extends StatelessWidget {
  final AppLocalizations l10n;
  final TaskController controller;

  const _ProductivitySection({required this.l10n, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveWidgets.responsiveText(
          context,
          text: l10n.productivity,
          mobileFontSize: 18,
          tabletFontSize: 20,
          desktopFontSize: 22,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        ResponsiveWidgets.verticalSpace(context, mobile: 16, tablet: 20, desktop: 24),
        
        ResponsiveBuilder(
          mobile: (context) => Column(
            children: [
              _buildProgressCard(context, l10n.weeklyProgress, 85, AppColors.success),
              ResponsiveWidgets.verticalSpace(context, mobile: 16, tablet: 20, desktop: 24),
              _buildProgressCard(context, l10n.monthlyProgress, 72, AppColors.primaryBlue),
            ],
          ),
          tablet: (context) => Row(
            children: [
              Expanded(child: _buildProgressCard(context, l10n.weeklyProgress, 85, AppColors.success)),
              ResponsiveWidgets.horizontalSpace(context, mobile: 16, tablet: 20, desktop: 24),
              Expanded(child: _buildProgressCard(context, l10n.monthlyProgress, 72, AppColors.primaryBlue)),
            ],
          ),
          desktop: (context) => Row(
            children: [
              Expanded(child: _buildProgressCard(context, l10n.weeklyProgress, 85, AppColors.success)),
              ResponsiveWidgets.horizontalSpace(context, mobile: 16, tablet: 20, desktop: 24),
              Expanded(child: _buildProgressCard(context, l10n.monthlyProgress, 72, AppColors.primaryBlue)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, String title, int progress, Color color) {
    return ResponsiveWidgets.responsiveContainer(
      context,
      color: color.withValues(alpha: 0.1),
      child: Column(
        children: [
          ResponsiveWidgets.responsiveText(
            context,
            text: title,
            mobileFontSize: 16,
            tabletFontSize: 18,
            desktopFontSize: 20,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          ResponsiveWidgets.verticalSpace(context, mobile: 16, tablet: 20, desktop: 24),
          
          // Progress indicator (simplified)
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: Responsive.getResponsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * (progress / 100),
                height: Responsive.getResponsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          ResponsiveWidgets.verticalSpace(context, mobile: 8, tablet: 12, desktop: 16),
          
          ResponsiveWidgets.responsiveText(
            context,
            text: '$progress%',
            mobileFontSize: 20,
            tabletFontSize: 24,
            desktopFontSize: 28,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Helper class for overview card data
class _OverviewCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _OverviewCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}