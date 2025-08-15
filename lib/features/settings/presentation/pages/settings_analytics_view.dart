part of 'settings_page.dart';

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

          ResponsiveWidgets.verticalSpace(
            context,
            mobile: 24,
            tablet: 32,
            desktop: 40,
          ),

          // Task Statistics
          _TaskStatisticsSection(l10n: l10n, controller: taskController),

          ResponsiveWidgets.verticalSpace(
            context,
            mobile: 24,
            tablet: 32,
            desktop: 40,
          ),

          // Audio Insights
          _AudioInsightsSection(l10n: l10n, controller: taskController),

          ResponsiveWidgets.verticalSpace(
            context,
            mobile: 24,
            tablet: 32,
            desktop: 40,
          ),

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
          _OverviewGridSection(
            l10n: l10n,
            controller: taskController,
            crossAxisCount: crossAxisCount,
          ),

          ResponsiveWidgets.verticalSpace(
            context,
            mobile: 32,
            tablet: 40,
            desktop: 48,
          ),

          // Statistics and Insights Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _TaskStatisticsSection(
                  l10n: l10n,
                  controller: taskController,
                ),
              ),
              ResponsiveWidgets.horizontalSpace(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
              Expanded(
                child: _AudioInsightsSection(
                  l10n: l10n,
                  controller: taskController,
                ),
              ),
            ],
          ),

          ResponsiveWidgets.verticalSpace(
            context,
            mobile: 32,
            tablet: 40,
            desktop: 48,
          ),

          // Productivity Section
          _ProductivitySection(l10n: l10n, controller: taskController),
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
