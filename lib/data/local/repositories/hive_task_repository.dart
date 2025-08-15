import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/todos/domain/task_entity.dart';
import '../../../features/todos/domain/i_task_repository.dart';
import '../../../core/result.dart';
import '../../../core/errors.dart';
import '../../../core/logger.dart';
import '../hive_database_manager.dart';

/// Local task repository implementation using Hive
class HiveTaskRepository implements ITaskRepository {
  final HiveDatabaseManager _database = HiveDatabaseManager.instance;
  final Logger _logger = Logger.instance;

  Box<TaskEntity> get _tasksBox => _database.tasksBox;

  @override
  Future<AppResult<List<TaskEntity>>> getAllTasks() async {
    try {
      // Database ready check removed - using direct box access

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
      // Database ready check removed - using direct box access

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
      // Database ready check removed - using direct box access

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
      // Database ready check removed - using direct box access

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
      // Database ready check removed - using direct box access

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
      // Database ready check removed - using direct box access

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
      // Database ready check removed - using direct box access

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
      // Database ready check removed - using direct box access

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
      // Database ready check removed - using direct box access

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
      // Database ready check removed - using direct box access
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
      // Database ready check removed - using direct box access

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
        averageCompletionTime: _calculateAverageCompletionTime(tasks),
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
                  t.status == TaskStatus.completed &&
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

  // Additional methods from original repository...
  // (All other methods remain the same with proper path updates)

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

  @override
  Future<AppResult<TaskEntity>> completeTask(String id) async {
    try {
      // Database ready check removed - using direct box access

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
      // Database ready check removed - using direct box access

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
      return AppResult.failure(
        DatabaseFailure('Failed to uncomplete task: $e'),
      );
    }
  }

  @override
  Future<AppResult<TaskEntity>> unarchiveTask(String id) async {
    try {
      // Database ready check removed - using direct box access

      final task = _tasksBox.get(id);
      if (task == null) {
        return AppResult.failure(DatabaseFailure('Task not found: $id'));
      }

      final unarchivedTask = task.copyWith(
        isArchived: false,
        localUpdatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await _tasksBox.put(id, unarchivedTask);

      _logger.info('Unarchived task: ${task.title}');
      return AppResult.success(unarchivedTask);
    } catch (e) {
      _logger.error('Failed to unarchive task: $e');
      return AppResult.failure(DatabaseFailure('Failed to unarchive task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> starTask(String id) async {
    try {
      // Database ready check removed - using direct box access

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
      // Database ready check removed - using direct box access

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
  Future<AppResult<TaskEntity>> archiveTask(String id) async {
    try {
      // Database ready check removed - using direct box access

      final task = _tasksBox.get(id);
      if (task == null) {
        return AppResult.failure(DatabaseFailure('Task not found: $id'));
      }

      final archivedTask = task.copyWith(
        isArchived: true,
        localUpdatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await _tasksBox.put(id, archivedTask);

      _logger.info('Archived task: ${task.title}');
      return AppResult.success(archivedTask);
    } catch (e) {
      _logger.error('Failed to archive task: $e');
      return AppResult.failure(DatabaseFailure('Failed to archive task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> addAudioToTask(
    String id,
    String audioPath,
    int duration,
  ) async {
    try {
      // Database ready check removed - using direct box access

      final task = _tasksBox.get(id);
      if (task == null) {
        return AppResult.failure(DatabaseFailure('Task not found: $id'));
      }

      final updatedTask = task.copyWith(
        audioPath: audioPath,
        audioDuration: Duration(seconds: duration),
        localUpdatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await _tasksBox.put(id, updatedTask);

      _logger.info('Added audio to task: ${task.title}');
      return AppResult.success(updatedTask);
    } catch (e) {
      _logger.error('Failed to add audio to task: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to add audio to task: $e'),
      );
    }
  }

  @override
  Future<AppResult<TaskEntity>> removeAudioFromTask(String id) async {
    try {
      // Database ready check removed - using direct box access

      final task = _tasksBox.get(id);
      if (task == null) {
        return AppResult.failure(DatabaseFailure('Task not found: $id'));
      }

      final updatedTask = task.copyWith(
        audioPath: null,
        audioDuration: null,
        localUpdatedAt: DateTime.now(),
        syncStatus: 'pending',
      );

      await _tasksBox.put(id, updatedTask);

      _logger.info('Removed audio from task: ${task.title}');
      return AppResult.success(updatedTask);
    } catch (e) {
      _logger.error('Failed to remove audio from task: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to remove audio from task: $e'),
      );
    }
  }

  @override
  Future<AppResult<TaskEntity>> addSubtasks(
    String parentId,
    List<TaskEntity> subtasks,
  ) async {
    try {
      // Database ready check removed - using direct box access

      final parentTask = _tasksBox.get(parentId);
      if (parentTask == null) {
        return AppResult.failure(
          DatabaseFailure('Parent task not found: $parentId'),
        );
      }

      // Create all subtasks with parent reference
      final List<TaskEntity> createdSubtasks = [];
      for (final subtask in subtasks) {
        final subtaskWithParent = subtask.copyWith(
          parentTaskId: parentId,
          localCreatedAt: DateTime.now(),
          localUpdatedAt: DateTime.now(),
          syncStatus: 'pending',
        );

        await _tasksBox.put(subtaskWithParent.id, subtaskWithParent);
        createdSubtasks.add(subtaskWithParent);
      }

      _logger.info(
        'Added ${createdSubtasks.length} subtasks to parent: ${parentTask.title}',
      );
      return AppResult.success(parentTask);
    } catch (e) {
      _logger.error('Failed to add subtasks: $e');
      return AppResult.failure(DatabaseFailure('Failed to add subtasks: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> removeSubtasks(
    String parentId,
    List<String> subtaskIds,
  ) async {
    try {
      // Database ready check removed - using direct box access

      final parentTask = _tasksBox.get(parentId);
      if (parentTask == null) {
        return AppResult.failure(
          DatabaseFailure('Parent task not found: $parentId'),
        );
      }

      // Delete all subtasks
      for (final subtaskId in subtaskIds) {
        await _tasksBox.delete(subtaskId);
      }

      _logger.info(
        'Removed ${subtaskIds.length} subtasks from parent: ${parentTask.title}',
      );
      return AppResult.success(parentTask);
    } catch (e) {
      _logger.error('Failed to remove subtasks: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to remove subtasks: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksDueToday() async {
    try {
      // Database ready check removed - using direct box access

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final tasks = _tasksBox.values
          .cast<TaskEntity>()
          .where(
            (task) =>
                task.dueDate != null &&
                task.dueDate!.isAfter(startOfDay) &&
                task.dueDate!.isBefore(endOfDay),
          )
          .toList();

      _logger.info('Found ${tasks.length} tasks due today');
      return AppResult.success(tasks);
    } catch (e) {
      _logger.error('Failed to get tasks due today: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get tasks due today: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksDueSoon(int days) async {
    try {
      // Database ready check removed - using direct box access

      final now = DateTime.now();
      final endDate = now.add(Duration(days: days));

      final tasks = _tasksBox.values
          .cast<TaskEntity>()
          .where(
            (task) =>
                task.dueDate != null &&
                task.dueDate!.isAfter(now) &&
                task.dueDate!.isBefore(endDate) &&
                task.status != TaskStatus.completed,
          )
          .toList();

      _logger.info('Found ${tasks.length} tasks due in $days days');
      return AppResult.success(tasks);
    } catch (e) {
      _logger.error('Failed to get tasks due soon: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get tasks due soon: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksByTags(List<String> tags) async {
    try {
      // Database ready check removed - using direct box access

      if (tags.isEmpty) {
        return const AppResult.success([]);
      }

      final tasks = _tasksBox.values
          .cast<TaskEntity>()
          .where((task) => task.tags.any((tag) => tags.contains(tag)))
          .toList();

      _logger.info('Found ${tasks.length} tasks with tags: $tags');
      return AppResult.success(tasks);
    } catch (e) {
      _logger.error('Failed to get tasks by tags: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get tasks by tags: $e'),
      );
    }
  }

  @override
  Future<AppResult<String>> exportTasks(String format) async {
    try {
      // Database ready check removed - using direct box access

      final tasks = _tasksBox.values.cast<TaskEntity>().toList();
      String exportData;

      switch (format.toLowerCase()) {
        case 'json':
          exportData = tasks.map((task) => task.toJson()).toList().toString();
          break;
        case 'csv':
          // Simple CSV export
          final csvHeader =
              'Title,Description,Priority,Status,Due Date,Created At\n';
          final csvRows = tasks
              .map(
                (task) =>
                    '${task.title},${task.description ?? ""},${task.priority.name},${task.status.name},${task.dueDate?.toIso8601String() ?? ""},${task.createdAt.toIso8601String()}',
              )
              .join('\n');
          exportData = csvHeader + csvRows;
          break;
        default:
          return AppResult.failure(
            DatabaseFailure('Unsupported export format: $format'),
          );
      }

      _logger.info('Exported ${tasks.length} tasks in $format format');
      return AppResult.success(exportData);
    } catch (e) {
      _logger.error('Failed to export tasks: $e');
      return AppResult.failure(DatabaseFailure('Failed to export tasks: $e'));
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> importTasks(
    String data,
    String format,
  ) async {
    try {
      // Database ready check removed - using direct box access

      List<TaskEntity> tasks = [];

      switch (format.toLowerCase()) {
        case 'json':
          try {
            final List<dynamic> jsonList = jsonDecode(data);
            tasks = jsonList.map((json) => TaskEntity.fromJson(json)).toList();
          } catch (e) {
            return AppResult.failure(
              DatabaseFailure('Invalid JSON format: $e'),
            );
          }
          break;
        case 'csv':
          // Simple CSV import
          final lines = data.split('\n');
          if (lines.length < 2) {
            return const AppResult.failure(
              DatabaseFailure('Invalid CSV format: insufficient data'),
            );
          }

          for (int i = 1; i < lines.length; i++) {
            final line = lines[i].trim();
            if (line.isNotEmpty) {
              final values = line.split(',');
              if (values.length >= 6) {
                try {
                  final task = TaskEntity.create(
                    title: values[0],
                    description: values[1].isEmpty ? null : values[1],
                    priority: TaskPriority.values.firstWhere(
                      (p) => p.name == values[2],
                      orElse: () => TaskPriority.medium,
                    ),
                    status: TaskStatus.values.firstWhere(
                      (s) => s.name == values[3],
                      orElse: () => TaskStatus.pending,
                    ),
                    dueDate: values[4].isEmpty
                        ? null
                        : DateTime.parse(values[4]),
                  );
                  tasks.add(task);
                } catch (e) {
                  _logger.error('Failed to parse CSV line $i: $e');
                }
              }
            }
          }
          break;
        default:
          return AppResult.failure(
            DatabaseFailure('Unsupported import format: $format'),
          );
      }

      if (tasks.isEmpty) {
        return const AppResult.failure(
          DatabaseFailure('No valid tasks found in import data'),
        );
      }

      // Create all imported tasks
      final List<TaskEntity> createdTasks = [];
      for (final task in tasks) {
        final result = await createTask(task);
        if (result.isSuccess) {
          createdTasks.add(result.dataOrNull!);
        }
      }

      _logger.info('Successfully imported ${createdTasks.length} tasks');
      return AppResult.success(createdTasks);
    } catch (e) {
      _logger.error('Failed to import tasks: $e');
      return AppResult.failure(DatabaseFailure('Failed to import tasks: $e'));
    }
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
    try {
      // Database ready check removed - using direct box access

      var tasks = _tasksBox.values.cast<TaskEntity>().toList();

      // Apply filters
      if (status != null) {
        tasks = tasks.where((task) => task.status == status).toList();
      }
      if (priority != null) {
        tasks = tasks.where((task) => task.priority == priority).toList();
      }
      if (isArchived != null) {
        tasks = tasks.where((task) => task.isArchived == isArchived).toList();
      }
      if (isStarred != null) {
        tasks = tasks.where((task) => task.isStarred == isStarred).toList();
      }
      if (dueDate != null) {
        final startOfDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        tasks = tasks
            .where(
              (task) =>
                  task.dueDate != null &&
                  task.dueDate!.isAfter(startOfDay) &&
                  task.dueDate!.isBefore(endOfDay),
            )
            .toList();
      }
      if (tags != null && tags.isNotEmpty) {
        tasks = tasks
            .where((task) => task.tags.any((tag) => tags.contains(tag)))
            .toList();
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final lowercaseQuery = searchQuery.toLowerCase();
        tasks = tasks
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
      }

      // Apply sorting
      final sortField = sortBy ?? 'createdAt';
      final ascending = sortAscending ?? false;
      tasks.sort((a, b) {
        dynamic aValue, bValue;
        switch (sortField) {
          case 'title':
            aValue = a.title;
            bValue = b.title;
            break;
          case 'priority':
            aValue = a.priority.index;
            bValue = b.priority.index;
            break;
          case 'status':
            aValue = a.status.index;
            bValue = b.status.index;
            break;
          case 'dueDate':
            aValue = a.dueDate ?? DateTime(9999, 12, 31);
            bValue = b.dueDate ?? DateTime(9999, 12, 31);
            break;
          case 'createdAt':
          default:
            aValue = a.createdAt;
            bValue = b.createdAt;
            break;
        }

        if (ascending) {
          return aValue.compareTo(bValue);
        } else {
          return bValue.compareTo(aValue);
        }
      });

      // Apply pagination
      if (offset != null && limit != null) {
        final start = offset;
        final end = (offset + limit).clamp(0, tasks.length);
        tasks = tasks.sublist(start, end);
      } else if (limit != null) {
        tasks = tasks.take(limit).toList();
      }

      _logger.info('Retrieved ${tasks.length} filtered tasks');
      return AppResult.success(tasks);
    } catch (e) {
      _logger.error('Failed to get filtered tasks: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get filtered tasks: $e'),
      );
    }
  }

  @override
  Future<AppResult<void>> syncTasks() async {
    try {
      // Database ready check removed - using direct box access

      // For local repository, sync means marking all tasks as synced
      final tasks = _tasksBox.values.cast<TaskEntity>().toList();

      for (final task in tasks) {
        if (task.syncStatus != 'synced') {
          final syncedTask = task.copyWith(
            syncStatus: 'synced',
            localUpdatedAt: DateTime.now(),
          );
          await _tasksBox.put(task.id, syncedTask);
        }
      }

      _logger.info('Synced ${tasks.length} tasks');
      return const AppResult.success(null);
    } catch (e) {
      _logger.error('Failed to sync tasks: $e');
      return AppResult.failure(DatabaseFailure('Failed to sync tasks: $e'));
    }
  }

  /// Calculate average completion time from completed tasks
  double _calculateAverageCompletionTime(List<TaskEntity> tasks) {
    final completedTasksWithDate = tasks
        .where(
          (task) =>
              task.status == TaskStatus.completed && task.completedAt != null,
        )
        .toList();

    if (completedTasksWithDate.isEmpty) return 0.0;

    final totalDays = completedTasksWithDate.fold<int>(0, (sum, task) {
      if (task.completedAt != null) {
        return sum + task.completedAt!.difference(task.createdAt).inDays;
      }
      return sum;
    });

    return totalDays / completedTasksWithDate.length;
  }
}
