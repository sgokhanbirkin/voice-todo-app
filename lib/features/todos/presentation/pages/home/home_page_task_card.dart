part of 'home_page.dart';

/// Individual task card widget
class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final AppLocalizations l10n;
  final TaskController controller;

  const TaskCard({
    super.key,
    required this.task,
    required this.l10n,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;

    // Get priority color for enhanced card
    Color? priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = AppColors.priorityHigh;
        break;
      case TaskPriority.medium:
        priorityColor = AppColors.priorityMedium;
        break;
      case TaskPriority.low:
        priorityColor = AppColors.priorityLow;
        break;
    }

    return InkWell(
      onTap: () {
        context.push('/task-detail/${task.id}');
      },
      borderRadius: BorderRadius.circular(12),
      child: ResponsiveWidgets.enhancedTaskCard(
        context,
        isCompleted: isCompleted,
        priorityColor: priorityColor,
        margin: EdgeInsets.only(
          bottom: Responsive.getResponsiveSpacing(
            context,
            mobile: 12,
            tablet: 16,
            desktop: 20,
          ),
        ),
        child: Opacity(
          opacity: isCompleted ? 0.8 : 1.0,
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
                    child: ResponsiveWidgets.responsiveText(
                      context,
                      text: task.title,
                      mobileFontSize: 16,
                      tabletFontSize: 18,
                      desktopFontSize: 20,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  _buildTaskPopupMenu(context),
                ],
              ),

              // Task description
              if (task.description != null) ...[
                ResponsiveWidgets.verticalSpace(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
                ResponsiveWidgets.responsiveText(
                  context,
                  text: task.description!,
                  mobileFontSize: 14,
                  tabletFontSize: 15,
                  desktopFontSize: 16,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Task dates
              ResponsiveWidgets.verticalSpace(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
              _buildTaskDates(context),

              ResponsiveWidgets.verticalSpace(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),

              // Task chips
              _buildTaskChips(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
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
              Icon(task.isStarred ? Icons.star_border : Icons.star),
              ResponsiveWidgets.horizontalSpace(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
              Text(task.isStarred ? l10n.unstarTask : l10n.starTask),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete, color: AppColors.error),
              ResponsiveWidgets.horizontalSpace(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
              Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskDates(BuildContext context) {
    return Row(
      children: [
        // Created date
        ...[
          Icon(
            Icons.schedule,
            size: Responsive.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          ResponsiveWidgets.horizontalSpace(
            context,
            mobile: 4,
            tablet: 6,
            desktop: 8,
          ),
          ResponsiveWidgets.responsiveText(
            context,
            text: _formatDate(task.createdAt),
            mobileFontSize: 12,
            tabletFontSize: 13,
            desktopFontSize: 14,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],

        // Due date
        if (task.dueDate != null) ...[
          ResponsiveWidgets.horizontalSpace(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
          Icon(
            Icons.event,
            size: Responsive.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            color: task.dueDate!.isBefore(DateTime.now())
                ? AppColors.error
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          ResponsiveWidgets.horizontalSpace(
            context,
            mobile: 4,
            tablet: 6,
            desktop: 8,
          ),
          ResponsiveWidgets.responsiveText(
            context,
            text: _formatDate(task.dueDate!),
            mobileFontSize: 12,
            tabletFontSize: 13,
            desktopFontSize: 14,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: task.dueDate!.isBefore(DateTime.now())
                  ? AppColors.error
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Bugün';
    } else if (taskDate == yesterday) {
      return 'Dün';
    } else if (taskDate == tomorrow) {
      return 'Yarın';
    } else {
      // Diğer tarihler için normal format
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildTaskChips(BuildContext context) {
    return Wrap(
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
        if (task.isOverdue) _buildOverdueChip(context),
        if (task.isStarred) _buildStarredChip(context),
      ],
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

    return _buildChip(context, label, color);
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
        label = l10n.taskStatusInProgress;
        break;
      case TaskStatus.completed:
        color = AppColors.statusCompleted;
        label = l10n.taskCompleted;
        break;
      case TaskStatus.cancelled:
        color = AppColors.statusCancelled;
        label = l10n.taskStatusCancelled;
        break;
    }

    return _buildChip(context, label, color);
  }

  Widget _buildOverdueChip(BuildContext context) {
    return _buildChip(context, l10n.overdue, AppColors.error);
  }

  Widget _buildStarredChip(BuildContext context) {
    return _buildChip(context, l10n.starred, AppColors.warning);
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
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
