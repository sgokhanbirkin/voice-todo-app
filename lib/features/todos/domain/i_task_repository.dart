import 'task_entity.dart';
import '../../../core/result.dart';

/// Task repository interface for CRUD operations
abstract class ITaskRepository {
  /// Creates a new task
  Future<AppResult<TaskEntity>> createTask(TaskEntity task);

  /// Retrieves a task by its ID
  Future<AppResult<TaskEntity>> getTaskById(String id);

  /// Retrieves all tasks
  Future<AppResult<List<TaskEntity>>> getAllTasks();

  /// Retrieves tasks with optional filtering
  Future<AppResult<List<TaskEntity>>> getTasks({
    TaskStatus? status,
    TaskPriority? priority,
    bool? isArchived,
    bool? isStarred,
    DateTime? dueDate,
    List<String>? tags,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
    int? limit,
    int? offset,
  });

  /// Updates an existing task
  Future<AppResult<TaskEntity>> updateTask(TaskEntity task);

  /// Deletes a task by its ID
  Future<AppResult<void>> deleteTask(String id);

  /// Marks a task as completed
  Future<AppResult<TaskEntity>> completeTask(String id);

  /// Marks a task as pending
  Future<AppResult<TaskEntity>> uncompleteTask(String id);

  /// Archives a task
  Future<AppResult<TaskEntity>> archiveTask(String id);

  /// Unarchives a task
  Future<AppResult<TaskEntity>> unarchiveTask(String id);

  /// Stars/favorites a task
  Future<AppResult<TaskEntity>> starTask(String id);

  /// Unstars/unfavorites a task
  Future<AppResult<TaskEntity>> unstarTask(String id);

  /// Adds audio to a task
  Future<AppResult<TaskEntity>> addAudioToTask(
    String id,
    String audioPath,
    int duration,
  );

  /// Removes audio from a task
  Future<AppResult<TaskEntity>> removeAudioFromTask(String id);

  /// Adds subtasks to a task
  Future<AppResult<TaskEntity>> addSubtasks(
    String parentId,
    List<TaskEntity> subtasks,
  );

  /// Removes subtasks from a task
  Future<AppResult<TaskEntity>> removeSubtasks(
    String parentId,
    List<String> subtaskIds,
  );

  /// Gets tasks due today
  Future<AppResult<List<TaskEntity>>> getTasksDueToday();

  /// Gets overdue tasks
  Future<AppResult<List<TaskEntity>>> getOverdueTasks();

  /// Gets tasks due soon (within specified days)
  Future<AppResult<List<TaskEntity>>> getTasksDueSoon(int days);

  /// Gets tasks by priority
  Future<AppResult<List<TaskEntity>>> getTasksByPriority(TaskPriority priority);

  /// Gets tasks by status
  Future<AppResult<List<TaskEntity>>> getTasksByStatus(TaskStatus status);

  /// Gets tasks by tags
  Future<AppResult<List<TaskEntity>>> getTasksByTags(List<String> tags);

  /// Searches tasks by title or description
  Future<AppResult<List<TaskEntity>>> searchTasks(String query);

  /// Gets task statistics
  Future<AppResult<TaskStatistics>> getTaskStatistics();

  /// Gets tasks by sync status
  Future<AppResult<List<TaskEntity>>> getTasksBySyncStatus(String syncStatus);

  /// Syncs local tasks with remote storage
  Future<AppResult<void>> syncTasks();

  /// Exports tasks to different formats
  Future<AppResult<String>> exportTasks(String format);

  /// Imports tasks from different formats
  Future<AppResult<List<TaskEntity>>> importTasks(String data, String format);
}

/// Task statistics data
class TaskStatistics {
  /// Total number of tasks
  final int totalTasks;

  /// Number of completed tasks
  final int completedTasks;

  /// Number of pending tasks
  final int pendingTasks;

  /// Number of overdue tasks
  final int overdueTasks;

  /// Number of tasks due today
  final int dueTodayTasks;

  /// Number of high priority tasks
  final int highPriorityTasks;

  /// Number of medium priority tasks
  final int mediumPriorityTasks;

  /// Number of low priority tasks
  final int lowPriorityTasks;

  /// Number of starred tasks
  final int starredTasks;

  /// Number of archived tasks
  final int archivedTasks;

  /// Average completion time in days
  final double averageCompletionTime;

  /// Tasks completed this week
  final int completedThisWeek;

  /// Tasks completed this month
  final int completedThisMonth;

  const TaskStatistics({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.dueTodayTasks,
    required this.highPriorityTasks,
    required this.mediumPriorityTasks,
    required this.lowPriorityTasks,
    required this.starredTasks,
    required this.archivedTasks,
    required this.averageCompletionTime,
    required this.completedThisWeek,
    required this.completedThisMonth,
  });

  /// Creates statistics from JSON data
  factory TaskStatistics.fromJson(Map<String, dynamic> json) {
    return TaskStatistics(
      totalTasks: json['totalTasks'] as int? ?? 0,
      completedTasks: json['completedTasks'] as int? ?? 0,
      pendingTasks: json['pendingTasks'] as int? ?? 0,
      overdueTasks: json['overdueTasks'] as int? ?? 0,
      dueTodayTasks: json['dueTodayTasks'] as int? ?? 0,
      highPriorityTasks: json['highPriorityTasks'] as int? ?? 0,
      mediumPriorityTasks: json['mediumPriorityTasks'] as int? ?? 0,
      lowPriorityTasks: json['lowPriorityTasks'] as int? ?? 0,
      starredTasks: json['starredTasks'] as int? ?? 0,
      archivedTasks: json['archivedTasks'] as int? ?? 0,
      averageCompletionTime:
          (json['averageCompletionTime'] as num?)?.toDouble() ?? 0.0,
      completedThisWeek: json['completedThisWeek'] as int? ?? 0,
      completedThisMonth: json['completedThisMonth'] as int? ?? 0,
    );
  }

  /// Converts statistics to JSON data
  Map<String, dynamic> toJson() {
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'overdueTasks': overdueTasks,
      'dueTodayTasks': dueTodayTasks,
      'highPriorityTasks': highPriorityTasks,
      'mediumPriorityTasks': mediumPriorityTasks,
      'lowPriorityTasks': lowPriorityTasks,
      'starredTasks': starredTasks,
      'archivedTasks': archivedTasks,
      'averageCompletionTime': averageCompletionTime,
      'completedThisWeek': completedThisWeek,
      'completedThisMonth': completedThisMonth,
    };
  }

  /// Gets completion percentage
  double get completionPercentage {
    if (totalTasks == 0) return 0.0;
    return (completedTasks / totalTasks) * 100;
  }

  /// Gets overdue percentage
  double get overduePercentage {
    if (totalTasks == 0) return 0.0;
    return (overdueTasks / totalTasks) * 100;
  }
}

// TODO: Add more repository methods for advanced features
// TODO: Implement task caching and optimization
// TODO: Add batch operations support
// TODO: Implement task versioning and history
