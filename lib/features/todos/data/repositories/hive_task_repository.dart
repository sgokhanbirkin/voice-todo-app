import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/task_entity.dart';
import '../../domain/i_task_repository.dart';
import '../../../../core/result.dart';
import '../../../../core/errors.dart';
import '../../../../core/logger.dart';
import '../../../../core/database/hive_database.dart';

/// Local task repository implementation using Hive
class HiveTaskRepository implements ITaskRepository {
  final HiveDatabase _database = HiveDatabase.instance;
  final Logger _logger = Logger.instance;

  Box get _tasksBox => _database.tasksBox;

  @override
  Future<AppResult<List<TaskEntity>>> getAllTasks() async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final tasks = _tasksBox.values.cast<TaskEntity>().toList();
      _logger.info('Retrieved ${tasks.length} tasks from local database');

      return AppResult.success(tasks);
    } catch (e) {
      _logger.error('Failed to get all tasks: $e');
      return AppResult.failure(DatabaseFailure('Failed to get tasks: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> getTaskById(String id) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final task = _tasksBox.get(id);
      if (task == null) {
        return AppResult.failure(DatabaseFailure('Task not found: $id'));
      }

      _logger.info('Retrieved task: ${task.title}');
      return AppResult.success(task);
    } catch (e) {
      _logger.error('Failed to get task by ID $id: $e');
      return AppResult.failure(DatabaseFailure('Failed to get task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> createTask(TaskEntity task) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      // Set local timestamps
      final taskWithLocalTimestamps = task.copyWith(
        localCreatedAt: DateTime.now(),
        localUpdatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await _tasksBox.put(task.id, taskWithLocalTimestamps);

      _logger.info('Created task: ${task.title}');
      return AppResult.success(taskWithLocalTimestamps);
    } catch (e) {
      _logger.error('Failed to create task: $e');
      return AppResult.failure(DatabaseFailure('Failed to create task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> updateTask(TaskEntity task) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      // Check if task exists
      final existingTask = _tasksBox.get(task.id);
      if (existingTask == null) {
        return AppResult.failure(DatabaseFailure('Task not found: ${task.id}'));
      }

      // Update local timestamp and sync status
      final updatedTask = task.copyWith(
        localUpdatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await _tasksBox.put(task.id, updatedTask);

      _logger.info('Updated task: ${task.title}');
      return AppResult.success(updatedTask);
    } catch (e) {
      _logger.error('Failed to update task: $e');
      return AppResult.failure(DatabaseFailure('Failed to update task: $e'));
    }
  }

  @override
  Future<AppResult<void>> deleteTask(String id) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final task = _tasksBox.get(id);
      if (task == null) {
        return AppResult.failure(DatabaseFailure('Task not found: $id'));
      }

      await _tasksBox.delete(id);

      _logger.info('Deleted task: ${task.title}');
      return const AppResult.success(null);
    } catch (e) {
      _logger.error('Failed to delete task $id: $e');
      return AppResult.failure(DatabaseFailure('Failed to delete task: $e'));
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksByStatus(
    TaskStatus status,
  ) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final tasks = _tasksBox.values
          .cast<TaskEntity>()
          .where((task) => task.status == status)
          .toList();

      _logger.info(
        'Retrieved ${tasks.length} tasks with status: ${status.name}',
      );
      return AppResult.success(tasks);
    } catch (e) {
      _logger.error('Failed to get tasks by status: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get tasks by status: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksByPriority(
    TaskPriority priority,
  ) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final tasks = _tasksBox.values
          .cast<TaskEntity>()
          .where((task) => task.priority == priority)
          .toList();

      _logger.info(
        'Retrieved ${tasks.length} tasks with priority: ${priority.name}',
      );
      return AppResult.success(tasks);
    } catch (e) {
      _logger.error('Failed to get tasks by priority: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get tasks by priority: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> searchTasks(String query) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final lowercaseQuery = query.toLowerCase();
      final tasks = _tasksBox.values
          .cast<TaskEntity>()
          .where(
            (task) =>
                task.title.toLowerCase().contains(lowercaseQuery) ||
                (task.description?.toLowerCase().contains(lowercaseQuery) ??
                    false) ||
                task.tags.any(
                  (tag) => tag.toLowerCase().contains(lowercaseQuery),
                ),
          )
          .toList();

      _logger.info('Found ${tasks.length} tasks matching query: $query');
      return AppResult.success(tasks);
    } catch (e) {
      _logger.error('Failed to search tasks: $e');
      return AppResult.failure(DatabaseFailure('Failed to search tasks: $e'));
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> getOverdueTasks() async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final now = DateTime.now();
      final overdueTasks = _tasksBox.values
          .cast<TaskEntity>()
          .where(
            (task) =>
                task.dueDate != null &&
                task.status != TaskStatus.completed &&
                now.isAfter(task.dueDate!),
          )
          .toList();

      _logger.info('Found ${overdueTasks.length} overdue tasks');
      return AppResult.success(overdueTasks);
    } catch (e) {
      _logger.error('Failed to get overdue tasks: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get overdue tasks: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksBySyncStatus(
    String syncStatus,
  ) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }
      final tasks = _tasksBox.values.cast<TaskEntity>().toList();
      final filteredTasks = tasks
          .where((task) => task.syncStatus == syncStatus)
          .toList();
      _logger.info(
        'Retrieved ${filteredTasks.length} tasks with sync status: $syncStatus',
      );
      return AppResult.success(filteredTasks);
    } catch (e) {
      _logger.error('Failed to get tasks by sync status: $e');
      return const AppResult.failure(
        DatabaseFailure('Failed to get tasks by sync status'),
      );
    }
  }

  @override
  Future<AppResult<TaskStatistics>> getTaskStatistics() async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final tasks = _tasksBox.values.cast<TaskEntity>().toList();
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final monthAgo = DateTime(now.year, now.month - 1, now.day);

      final stats = TaskStatistics(
        totalTasks: tasks.length,
        completedTasks: tasks
            .where((t) => t.status == TaskStatus.completed)
            .length,
        pendingTasks: tasks.where((t) => t.status == TaskStatus.pending).length,
        overdueTasks: tasks.where((t) => t.isOverdue).length,
        dueTodayTasks: tasks
            .where(
              (t) =>
                  t.dueDate != null &&
                  t.dueDate!.year == now.year &&
                  t.dueDate!.month == now.month &&
                  t.dueDate!.day == now.day,
            )
            .length,
        highPriorityTasks: tasks
            .where((t) => t.priority == TaskPriority.high)
            .length,
        mediumPriorityTasks: tasks
            .where((t) => t.priority == TaskPriority.medium)
            .length,
        lowPriorityTasks: tasks
            .where((t) => t.priority == TaskPriority.low)
            .length,
        starredTasks: tasks.where((t) => t.isStarred).length,
        archivedTasks: tasks.where((t) => t.isArchived).length,
        averageCompletionTime: 0.0, // TODO: Calculate from completed tasks
        completedThisWeek: tasks
            .where(
              (t) =>
                  t.status == TaskStatus.completed &&
                  t.completedAt != null &&
                  t.completedAt!.isAfter(weekAgo),
            )
            .length,
        completedThisMonth: tasks
            .where(
              (t) =>
                  t.status == TaskStatus.pending &&
                  t.completedAt != null &&
                  t.completedAt!.isAfter(monthAgo),
            )
            .length,
      );

      _logger.info(
        'Generated task statistics: ${stats.totalTasks} total tasks',
      );
      return AppResult.success(stats);
    } catch (e) {
      _logger.error('Failed to get task statistics: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get task statistics: $e'),
      );
    }
  }

  Future<AppResult<List<TaskEntity>>> getTasksByUserId(String userId) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final tasks = _tasksBox.values
          .cast<TaskEntity>()
          .where((task) => task.userId == userId)
          .toList();

      _logger.info('Retrieved ${tasks.length} tasks for user: $userId');
      return AppResult.success(tasks);
    } catch (e) {
      _logger.error('Failed to get tasks by user ID: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get tasks by user ID: $e'),
      );
    }
  }

  Future<AppResult<List<TaskEntity>>> getPendingSyncTasks() async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final pendingTasks = _tasksBox.values
          .cast<TaskEntity>()
          .where((task) => task.syncStatus == 'pending')
          .toList();

      _logger.info('Found ${pendingTasks.length} tasks pending sync');
      return AppResult.success(pendingTasks);
    } catch (e) {
      _logger.error('Failed to get pending sync tasks: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get pending sync tasks: $e'),
      );
    }
  }

  Future<AppResult<bool>> markTaskAsSynced(String taskId) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final task = _tasksBox.get(taskId);
      if (task == null) {
        return AppResult.failure(DatabaseFailure('Task not found: $taskId'));
      }

      final updatedTask = task.copyWith(syncStatus: 'synced');
      await _tasksBox.put(taskId, updatedTask);

      _logger.info('Marked task as synced: ${task.title}');
      return const AppResult.success(true);
    } catch (e) {
      _logger.error('Failed to mark task as synced: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to mark task as synced: $e'),
      );
    }
  }

  Future<AppResult<bool>> clearCompletedTasks() async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final completedTasks = _tasksBox.values
          .cast<TaskEntity>()
          .where((task) => task.status == TaskStatus.completed)
          .toList();

      for (final task in completedTasks) {
        await _tasksBox.delete(task.id);
      }

      _logger.info('Cleared ${completedTasks.length} completed tasks');
      return const AppResult.success(true);
    } catch (e) {
      _logger.error('Failed to clear completed tasks: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to clear completed tasks: $e'),
      );
    }
  }

  @override
  Future<AppResult<TaskEntity>> archiveTask(String taskId) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final task = _tasksBox.get(taskId);
      if (task == null) {
        return AppResult.failure(DatabaseFailure('Task not found: $taskId'));
      }

      final archivedTask = task.copyWith(
        isArchived: true,
        localUpdatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await _tasksBox.put(taskId, archivedTask);

      _logger.info('Archived task: ${task.title}');
      return AppResult.success(archivedTask);
    } catch (e) {
      _logger.error('Failed to archive task: $e');
      return AppResult.failure(DatabaseFailure('Failed to archive task: $e'));
    }
  }

  Future<AppResult<bool>> toggleTaskStar(String taskId) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final task = _tasksBox.get(taskId);
      if (task == null) {
        return AppResult.failure(DatabaseFailure('Task not found: $taskId'));
      }

      final toggledTask = task.copyWith(
        isStarred: !task.isStarred,
        localUpdatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await _tasksBox.put(taskId, toggledTask);

      _logger.info('Toggled star for task: ${task.title}');
      return const AppResult.success(true);
    } catch (e) {
      _logger.error('Failed to toggle task star: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to toggle task star: $e'),
      );
    }
  }

  /// Get database statistics
  Map<String, int> getDatabaseStats() {
    return _database.getDatabaseStats();
  }

  /// Clear all local data (for testing/debugging)
  Future<void> clearAllData() async {
    try {
      await _database.clearAllData();
      _logger.info('All local task data cleared');
    } catch (e) {
      _logger.error('Failed to clear all data: $e');
    }
  }

  // TODO: Implement remaining interface methods
  @override
  Future<AppResult<TaskEntity>> completeTask(String id) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final task = _tasksBox.get(id);
      if (task == null) {
        return AppResult.failure(DatabaseFailure('Task not found: $id'));
      }

      final completedTask = task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
        localUpdatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await _tasksBox.put(id, completedTask);

      _logger.info('Completed task: ${task.title}');
      return AppResult.success(completedTask);
    } catch (e) {
      _logger.error('Failed to complete task: $e');
      return AppResult.failure(DatabaseFailure('Failed to complete task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> uncompleteTask(String id) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final task = _tasksBox.get(id);
      if (task == null) {
        return AppResult.failure(DatabaseFailure('Task not found: $id'));
      }

      final uncompletedTask = task.copyWith(
        status: TaskStatus.pending,
        completedAt: null,
        localUpdatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await _tasksBox.put(id, uncompletedTask);

      _logger.info('Uncompleted task: ${task.title}');
      return AppResult.success(uncompletedTask);
    } catch (e) {
      _logger.error('Failed to uncomplete task: $e');
      return AppResult.failure(DatabaseFailure('Failed to uncomplete task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> unarchiveTask(String id) async {
    // TODO: Implement unarchive task
    throw UnimplementedError('unarchiveTask not implemented yet');
  }

  @override
  Future<AppResult<TaskEntity>> starTask(String id) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final task = _tasksBox.get(id);
      if (task == null) {
        return AppResult.failure(DatabaseFailure('Task not found: $id'));
      }

      final starredTask = task.copyWith(
        isStarred: true,
        localUpdatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await _tasksBox.put(id, starredTask);

      _logger.info('Starred task: ${task.title}');
      return AppResult.success(starredTask);
    } catch (e) {
      _logger.error('Failed to star task: $e');
      return AppResult.failure(DatabaseFailure('Failed to star task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> unstarTask(String id) async {
    try {
      if (!_database.isReady) {
        return const AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final task = _tasksBox.get(id);
      if (task == null) {
        return AppResult.failure(DatabaseFailure('Task not found: $id'));
      }

      final unstarredTask = task.copyWith(
        isStarred: false,
        localUpdatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await _tasksBox.put(id, unstarredTask);

      _logger.info('Unstarred task: ${task.title}');
      return AppResult.success(unstarredTask);
    } catch (e) {
      _logger.error('Failed to unstar task: $e');
      return AppResult.failure(DatabaseFailure('Failed to unstar task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> addAudioToTask(
    String id,
    String audioPath,
    int duration,
  ) async {
    // TODO: Implement add audio to task
    throw UnimplementedError('addAudioToTask not implemented yet');
  }

  @override
  Future<AppResult<TaskEntity>> removeAudioFromTask(String id) async {
    // TODO: Implement remove audio from task
    throw UnimplementedError('removeAudioFromTask not implemented yet');
  }

  @override
  Future<AppResult<TaskEntity>> addSubtasks(
    String parentId,
    List<TaskEntity> subtasks,
  ) async {
    // TODO: Implement add subtasks
    throw UnimplementedError('addSubtasks not implemented yet');
  }

  @override
  Future<AppResult<TaskEntity>> removeSubtasks(
    String parentId,
    List<String> subtaskIds,
  ) async {
    // TODO: Implement remove subtasks
    throw UnimplementedError('removeSubtasks not implemented yet');
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksDueToday() async {
    // TODO: Implement get tasks due today
    throw UnimplementedError('getTasksDueToday not implemented yet');
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksDueSoon(int days) async {
    // TODO: Implement get tasks due soon
    throw UnimplementedError('getTasksDueSoon not implemented yet');
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksByTags(List<String> tags) async {
    // TODO: Implement get tasks by tags
    throw UnimplementedError('getTasksByTags not implemented yet');
  }

  Future<AppResult<bool>> syncWithRemote() async {
    // TODO: Implement sync with remote
    throw UnimplementedError('syncWithRemote not implemented yet');
  }

  @override
  Future<AppResult<String>> exportTasks(String format) async {
    // TODO: Implement export tasks
    throw UnimplementedError('exportTasks not implemented yet');
  }

  @override
  Future<AppResult<List<TaskEntity>>> importTasks(
    String data,
    String format,
  ) async {
    // TODO: Implement import tasks
    throw UnimplementedError('importTasks not implemented yet');
  }

  @override
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
  }) async {
    // TODO: Implement get tasks with filtering
    throw UnimplementedError('getTasks with filtering not implemented yet');
  }

  @override
  Future<AppResult<void>> syncTasks() {
    // TODO: implement syncTasks
    throw UnimplementedError();
  }
}
