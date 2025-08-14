part of 'add_task_page.dart';

/// Priority selection component with responsive design
/// Adapts between radio list (mobile) and chips (tablet/desktop)
class _AddTaskPrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final Function(TaskPriority) onPriorityChanged;

  const _AddTaskPrioritySelector({
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.taskPriority,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: Responsive.getResponsiveSpacing(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          ),
        ),
        ResponsiveBuilder(
          mobile: (context) => Column(
            children: TaskPriority.values
                .map(
                  (priority) => _buildPriorityOption(context, l10n, priority),
                )
                .toList(),
          ),
          tablet: (context) => Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            children: TaskPriority.values
                .map((priority) => _buildPriorityChip(context, l10n, priority))
                .toList(),
          ),
          desktop: (context) => Row(
            children: TaskPriority.values
                .map(
                  (priority) => Expanded(
                    child: _buildPriorityChip(context, l10n, priority),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  /// Build priority option for mobile (radio list)
  Widget _buildPriorityOption(
    BuildContext context,
    AppLocalizations l10n,
    TaskPriority priority,
  ) {
    final color = _getPriorityColor(priority);
    final label = _getPriorityLabel(l10n, priority);

    return RadioListTile<TaskPriority>(
      value: priority,
      groupValue: selectedPriority,
      onChanged: (value) {
        if (value != null) {
          onPriorityChanged(value);
        }
      },
      title: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Text(label),
        ],
      ),
      activeColor: color,
    );
  }

  /// Build priority chip for tablet/desktop
  Widget _buildPriorityChip(
    BuildContext context,
    AppLocalizations l10n,
    TaskPriority priority,
  ) {
    final isSelected = selectedPriority == priority;
    final color = _getPriorityColor(priority);
    final label = _getPriorityLabel(l10n, priority);

    return GestureDetector(
      onTap: () => onPriorityChanged(priority),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? color
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
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
  }

  /// Get priority color
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
    }
  }

  /// Get priority label
  String _getPriorityLabel(AppLocalizations l10n, TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return l10n.taskPriorityLow;
      case TaskPriority.medium:
        return l10n.taskPriorityMedium;
      case TaskPriority.high:
        return l10n.taskPriorityHigh;
    }
  }
}
