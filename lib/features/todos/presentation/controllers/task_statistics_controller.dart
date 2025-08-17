import 'package:get/get.dart';
import '../../domain/i_task_repository.dart';
import '../../domain/task_entity.dart';

/// Controller responsible for managing task statistics
class TaskStatisticsController extends GetxController {
  final ITaskRepository _taskRepository;

  /// Task statistics
  final Rx<TaskStatistics?> taskStatistics = Rx<TaskStatistics?>(null);

  /// Whether statistics are currently loading
  final RxBool isLoading = false.obs;

  /// Whether there was an error loading statistics
  final RxBool hasError = false.obs;

  /// Error message if any
  final RxString errorMessage = ''.obs;

  TaskStatisticsController(this._taskRepository);

  @override
  void onInit() {
    super.onInit();
    loadTaskStatistics();
  }

  /// Loads task statistics
  Future<void> loadTaskStatistics() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _taskRepository.getTaskStatistics();

      result.fold(
        (statistics) {
          taskStatistics.value = statistics;
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
        },
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Refreshes statistics
  @override
  Future<void> refresh() async {
    await loadTaskStatistics();
  }

  /// Gets completion percentage
  double get completionPercentage {
    if (taskStatistics.value == null) return 0.0;
    return taskStatistics.value!.completionPercentage;
  }

  /// Gets overdue percentage
  double get overduePercentage {
    if (taskStatistics.value == null) return 0.0;
    return taskStatistics.value!.overduePercentage;
  }

  /// Gets total tasks count
  int get totalTasks {
    if (taskStatistics.value == null) return 0;
    return taskStatistics.value!.totalTasks;
  }

  /// Gets completed tasks count
  int get completedTasks {
    if (taskStatistics.value == null) return 0;
    return taskStatistics.value!.completedTasks;
  }

  /// Gets pending tasks count
  int get pendingTasks {
    if (taskStatistics.value == null) return 0;
    return taskStatistics.value!.pendingTasks;
  }

  /// Gets overdue tasks count
  int get overdueTasks {
    if (taskStatistics.value == null) return 0;
    return taskStatistics.value!.overdueTasks;
  }

  /// Gets due today tasks count
  int get dueTodayTasks {
    if (taskStatistics.value == null) return 0;
    return taskStatistics.value!.dueTodayTasks;
  }

  /// Gets high priority tasks count
  int get highPriorityTasks {
    if (taskStatistics.value == null) return 0;
    return taskStatistics.value!.highPriorityTasks;
  }

  /// Gets medium priority tasks count
  int get mediumPriorityTasks {
    if (taskStatistics.value == null) return 0;
    return taskStatistics.value!.mediumPriorityTasks;
  }

  /// Gets low priority tasks count
  int get lowPriorityTasks {
    if (taskStatistics.value == null) return 0;
    return taskStatistics.value!.lowPriorityTasks;
  }

  /// Gets starred tasks count
  int get starredTasks {
    if (taskStatistics.value == null) return 0;
    return taskStatistics.value!.starredTasks;
  }

  /// Gets archived tasks count
  int get archivedTasks {
    if (taskStatistics.value == null) return 0;
    return taskStatistics.value!.archivedTasks;
  }

  /// Gets average completion time
  double get averageCompletionTime {
    if (taskStatistics.value == null) return 0.0;
    return taskStatistics.value!.averageCompletionTime;
  }

  /// Gets completed this week count
  int get completedThisWeek {
    if (taskStatistics.value == null) return 0;
    return taskStatistics.value!.completedThisWeek;
  }

  /// Gets completed this month count
  int get completedThisMonth {
    if (taskStatistics.value == null) return 0;
    return taskStatistics.value!.completedThisMonth;
  }

  /// Checks if statistics are available
  bool get hasStatistics => taskStatistics.value != null;

  /// Gets productivity score (0-100)
  int get productivityScore {
    if (taskStatistics.value == null) return 0;

    final total = taskStatistics.value!.totalTasks;
    if (total == 0) return 0;

    final completed = taskStatistics.value!.completedTasks;
    final overdue = taskStatistics.value!.overdueTasks;

    // Base score from completion rate
    final completionScore = (completed / total) * 60;

    // Penalty for overdue tasks
    final overduePenalty = (overdue / total) * 40;

    final finalScore = (completionScore - overduePenalty).round();
    return finalScore.clamp(0, 100);
  }

  /// Gets productivity level description
  String get productivityLevel {
    final score = productivityScore;

    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Very Good';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Average';
    if (score >= 40) return 'Below Average';
    return 'Needs Improvement';
  }

  /// Gets productivity emoji
  String get productivityEmoji {
    final score = productivityScore;

    if (score >= 90) return '🚀';
    if (score >= 80) return '⭐';
    if (score >= 70) return '👍';
    if (score >= 60) return '😐';
    if (score >= 40) return '😕';
    return '😞';
  }

  /// Gets statistics summary for display
  String get statisticsSummary {
    if (!hasStatistics) return 'No statistics available';

    return '$completedTasks/$totalTasks completed • $overdueTasks overdue • $productivityLevel';
  }

  /// Calculates statistics from a list of tasks
  TaskStatistics calculateStatisticsFromTasks(List<TaskEntity> tasks) {
    if (tasks.isEmpty) {
      return const TaskStatistics(
        totalTasks: 0,
        completedTasks: 0,
        pendingTasks: 0,
        overdueTasks: 0,
        dueTodayTasks: 0,
        highPriorityTasks: 0,
        mediumPriorityTasks: 0,
        lowPriorityTasks: 0,
        starredTasks: 0,
        archivedTasks: 0,
        averageCompletionTime: 0.0,
        completedThisWeek: 0,
        completedThisMonth: 0,
      );
    }

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    int completedTasks = 0;
    int pendingTasks = 0;
    int overdueTasks = 0;
    int dueTodayTasks = 0;
    int highPriorityTasks = 0;
    int mediumPriorityTasks = 0;
    int lowPriorityTasks = 0;
    int starredTasks = 0;
    int archivedTasks = 0;
    int completedThisWeek = 0;
    int completedThisMonth = 0;
    double totalCompletionTime = 0.0;

    for (final task in tasks) {
      // Count by status
      switch (task.status) {
        case TaskStatus.completed:
          completedTasks++;
          if (task.completedAt != null) {
            final completionTime = task.completedAt!
                .difference(task.createdAt)
                .inDays;
            totalCompletionTime += completionTime;

            if (task.completedAt!.isAfter(weekAgo)) {
              completedThisWeek++;
            }
            if (task.completedAt!.isAfter(monthAgo)) {
              completedThisMonth++;
            }
          }
          break;
        case TaskStatus.pending:
          pendingTasks++;
          break;
        case TaskStatus.inProgress:
          pendingTasks++;
          break;
        case TaskStatus.cancelled:
          // Don't count cancelled tasks
          break;
      }

      // Count by priority
      switch (task.priority) {
        case TaskPriority.high:
          highPriorityTasks++;
          break;
        case TaskPriority.medium:
          mediumPriorityTasks++;
          break;
        case TaskPriority.low:
          lowPriorityTasks++;
          break;
      }

      // Count other properties
      if (task.isOverdue) overdueTasks++;
      if (task.isDueToday) dueTodayTasks++;
      if (task.isStarred) starredTasks++;
      if (task.isArchived) archivedTasks++;
    }

    final averageCompletionTime = completedTasks > 0
        ? totalCompletionTime / completedTasks
        : 0.0;

    return TaskStatistics(
      totalTasks: tasks.length,
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      overdueTasks: overdueTasks,
      dueTodayTasks: dueTodayTasks,
      highPriorityTasks: highPriorityTasks,
      mediumPriorityTasks: mediumPriorityTasks,
      lowPriorityTasks: lowPriorityTasks,
      starredTasks: starredTasks,
      archivedTasks: archivedTasks,
      averageCompletionTime: averageCompletionTime,
      completedThisWeek: completedThisWeek,
      completedThisMonth: completedThisMonth,
    );
  }
}
