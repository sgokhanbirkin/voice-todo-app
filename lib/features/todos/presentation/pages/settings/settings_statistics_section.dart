part of 'settings_page.dart';

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
