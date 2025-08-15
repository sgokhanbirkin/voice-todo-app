part of 'task_detail_page.dart';

/// Utility Methods
extension _TaskDetailPageUtils on _TaskDetailPageState {
  String _getPriorityText(TaskPriority priority) {
    final l10n = AppLocalizations.of(context)!;
    switch (priority) {
      case TaskPriority.high:
        return l10n.high;
      case TaskPriority.medium:
        return l10n.medium;
      case TaskPriority.low:
        return l10n.low;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.error;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.low:
        return AppColors.success;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    final l10n = AppLocalizations.of(context)!;
    if (taskDate == today) {
      return l10n.today;
    } else if (taskDate == yesterday) {
      return l10n.yesterday;
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
