part of 'home_page.dart';

/// Task priority filter cards widget
class _TaskPriorityFilters extends StatelessWidget {
  final AppLocalizations l10n;
  final TaskController controller;

  const _TaskPriorityFilters({required this.l10n, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveWidgets.verticalSpace(
        context,
        mobile: 40,
        tablet: 48,
        desktop: 56,
      ).height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: ResponsiveWidgets.responsivePadding(
          context,
          horizontal: 4,
        ),
        children: [
          _buildPriorityFilterCard(
            context,
            TaskPriority.high,
            l10n.taskPriorityHigh,
            AppColors.priorityHigh,
          ),
          ResponsiveWidgets.horizontalSpace(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          ),
          _buildPriorityFilterCard(
            context,
            TaskPriority.medium,
            l10n.taskPriorityMedium,
            AppColors.priorityMedium,
          ),
          ResponsiveWidgets.horizontalSpace(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          ),
          _buildPriorityFilterCard(
            context,
            TaskPriority.low,
            l10n.taskPriorityLow,
            AppColors.priorityLow,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityFilterCard(
    BuildContext context,
    TaskPriority priority,
    String label,
    Color color,
  ) {
    return Obx(() {
      final isSelected = controller.filterPriority.value == priority;

      return GestureDetector(
        onTap: () {
          if (controller.filterPriority.value == priority) {
            // Same priority clicked - clear filter
            controller.setFilterPriority(null);
          } else {
            // Different priority clicked - set filter
            controller.setFilterPriority(priority);
          }
        },
        child: ResponsiveWidgets.responsiveContainer(
          context,
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.surface,
          borderRadius: Responsive.getResponsiveSpacing(
            context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
          ),
          border: Border.all(
            color: isSelected
                ? color
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
                height: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              ResponsiveWidgets.horizontalSpace(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
              ResponsiveWidgets.responsiveText(
                context,
                text: label,
                mobileFontSize: 12,
                tabletFontSize: 13,
                desktopFontSize: 14,
                style: TextStyle(
                  color: isSelected
                      ? color
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
