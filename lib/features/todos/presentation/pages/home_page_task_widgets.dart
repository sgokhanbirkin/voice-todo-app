part of 'home_page.dart';

/// Task priority filter cards widget
class _TaskPriorityFilters extends StatelessWidget {
  final AppLocalizations l10n;
  final TaskController controller;

  const _TaskPriorityFilters({
    required this.l10n,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.getResponsiveSpacing(
        context,
        mobile: 40,
        tablet: 48,
        desktop: 56,
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.getResponsiveSpacing(
            context,
            mobile: 4,
            tablet: 8,
            desktop: 12,
          ),
        ),
        children: [
          _buildPriorityFilterCard(
            context,
            TaskPriority.high,
            l10n.taskPriorityHigh,
            AppColors.priorityHigh,
          ),
          SizedBox(width: Responsive.getResponsiveSpacing(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          )),
          _buildPriorityFilterCard(
            context,
            TaskPriority.medium,
            l10n.taskPriorityMedium,
            AppColors.priorityMedium,
          ),
          SizedBox(width: Responsive.getResponsiveSpacing(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          )),
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
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
            vertical: Responsive.getResponsiveSpacing(
              context,
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(
              Responsive.getResponsiveSpacing(
                context,
                mobile: 20,
                tablet: 24,
                desktop: 28,
              ),
            ),
            border: Border.all(
              color: isSelected
                  ? color
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
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
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: Responsive.getResponsiveSpacing(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              )),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? color
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    mobile: 12,
                    tablet: 13,
                    desktop: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Task section header with expand/collapse functionality
class _TaskSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _TaskSectionHeader({
    required this.title,
    required this.count,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.getResponsiveSpacing(
            context,
            mobile: 4,
            tablet: 8,
            desktop: 12,
          ),
          vertical: Responsive.getResponsiveSpacing(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: Responsive.getResponsiveSpacing(
                context,
                mobile: 4,
                tablet: 5,
                desktop: 6,
              ),
              height: Responsive.getResponsiveSpacing(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: Responsive.getResponsiveSpacing(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            )),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                ),
              ),
            ),
            SizedBox(width: Responsive.getResponsiveSpacing(
              context,
              mobile: 8,
              tablet: 12,
              desktop: 16,
            )),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
                vertical: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 2,
                  tablet: 4,
                  desktop: 6,
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    mobile: 12,
                    tablet: 13,
                    desktop: 14,
                  ),
                ),
              ),
            ),
            SizedBox(width: Responsive.getResponsiveSpacing(
              context,
              mobile: 8,
              tablet: 12,
              desktop: 16,
            )),
            AnimatedRotation(
              turns: isExpanded ? 0.0 : -0.25, // 0° open, -90° closed
              duration: AppTheme.shortAnimation,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                size: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual task card widget
class _TaskCard extends StatelessWidget {
  final TaskEntity task;
  final AppLocalizations l10n;
  final TaskController controller;

  const _TaskCard({
    required this.task,
    required this.l10n,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;

    return Card(
      margin: EdgeInsets.only(
        bottom: Responsive.getResponsiveSpacing(
          context,
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
      ),
      color: isCompleted
          ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
          : null,
      child: Opacity(
        opacity: isCompleted ? 0.7 : 1.0,
        child: Padding(
          padding: EdgeInsets.all(
            Responsive.getResponsiveSpacing(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task header with checkbox and menu
              Row(
                children: [
                  Checkbox(
                    value: task.status == TaskStatus.completed,
                    onChanged: (value) async {
                      if (value == true) {
                        await controller.completeTask(task.id);
                      } else {
                        await controller.uncompleteTask(task.id);
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                        fontSize: Responsive.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'star':
                          if (task.isStarred) {
                            await controller.unstarTask(task.id);
                          } else {
                            await controller.starTask(task.id);
                          }
                          break;
                        case 'delete':
                          await controller.deleteTask(task.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'star',
                        child: Row(
                          children: [
                            Icon(
                              task.isStarred ? Icons.star_border : Icons.star,
                            ),
                            SizedBox(width: Responsive.getResponsiveSpacing(
                              context,
                              mobile: 8,
                              tablet: 10,
                              desktop: 12,
                            )),
                            Text(
                              task.isStarred ? 'Yıldızı Kaldır' : 'Yıldızla',
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, color: AppColors.error),
                            SizedBox(width: Responsive.getResponsiveSpacing(
                              context,
                              mobile: 8,
                              tablet: 10,
                              desktop: 12,
                            )),
                            Text(
                              l10n.delete,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Task description
              if (task.description != null) ...[
                SizedBox(height: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                )),
                Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: Responsive.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              SizedBox(height: Responsive.getResponsiveSpacing(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              )),

              // Task chips
              Wrap(
                spacing: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
                runSpacing: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 4,
                  tablet: 6,
                  desktop: 8,
                ),
                children: [
                  _buildPriorityChip(context, task.priority),
                  _buildStatusChip(context, task.status),
                  if (task.isOverdue)
                    Chip(
                      label: const Text('Gecikmiş'),
                      backgroundColor: AppColors.error.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: AppColors.error,
                        fontSize: Responsive.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 13,
                          desktop: 14,
                        ),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  if (task.isStarred)
                    Chip(
                      label: const Text('Yıldızlı'),
                      backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: AppColors.warning,
                        fontSize: Responsive.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 13,
                          desktop: 14,
                        ),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context, TaskPriority priority) {
    Color color;
    String label;

    switch (priority) {
      case TaskPriority.low:
        color = AppColors.priorityLow;
        label = l10n.taskPriorityLow;
        break;
      case TaskPriority.medium:
        color = AppColors.priorityMedium;
        label = l10n.taskPriorityMedium;
        break;
      case TaskPriority.high:
        color = AppColors.priorityHigh;
        label = l10n.taskPriorityHigh;
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: color,
        fontSize: Responsive.getResponsiveFontSize(
          context,
          mobile: 12,
          tablet: 13,
          desktop: 14,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildStatusChip(BuildContext context, TaskStatus status) {
    Color color;
    String label;

    switch (status) {
      case TaskStatus.pending:
        color = AppColors.statusPending;
        label = l10n.taskPending;
        break;
      case TaskStatus.inProgress:
        color = AppColors.statusInProgress;
        label = 'Devam Ediyor'; // TODO: Add to localization
        break;
      case TaskStatus.completed:
        color = AppColors.statusCompleted;
        label = l10n.taskCompleted;
        break;
      case TaskStatus.cancelled:
        color = AppColors.statusCancelled;
        label = 'İptal Edildi'; // TODO: Add to localization
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: color,
        fontSize: Responsive.getResponsiveFontSize(
          context,
          mobile: 12,
          tablet: 13,
          desktop: 14,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
