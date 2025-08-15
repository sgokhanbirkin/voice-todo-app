import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../features/todos/domain/i_task_repository.dart';
import '../../../features/todos/domain/task_entity.dart';
import '../../../core/result.dart';
import '../../../core/errors.dart';

/// Supabase implementation of task repository
class SupabaseTaskRepository implements ITaskRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<AppResult<List<TaskEntity>>> getAllTasks() async {
    try {
      debugPrint('SupabaseTaskRepository: getAllTasks called');

      final response = await _supabase
          .from('tasks')
          .select()
          .order('created_at', ascending: false);

      debugPrint('SupabaseTaskRepository: Raw response: $response');

      if (response == null) {
        debugPrint('SupabaseTaskRepository: No response from Supabase');
        return const AppResult.failure(
          DatabaseFailure('No response from database'),
        );
      }

      final List<TaskEntity> tasks = [];
      for (final taskData in response) {
        try {
          final task = TaskEntity.fromJson(taskData);
          tasks.add(task);
          debugPrint('SupabaseTaskRepository: Parsed task: ${task.title}');
        } catch (e) {
          debugPrint('SupabaseTaskRepository: Failed to parse task: $e');
          debugPrint('SupabaseTaskRepository: Raw task data: $taskData');
        }
      }

      debugPrint(
        'SupabaseTaskRepository: Successfully parsed ${tasks.length} tasks',
      );
      return AppResult.success(tasks);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error getting tasks: $e');
      return AppResult.failure(DatabaseFailure('Failed to get tasks: $e'));
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
    // TODO: Implement advanced filtering
    throw UnimplementedError();
  }

  @override
  Future<AppResult<TaskEntity>> getTaskById(String id) async {
    try {
      debugPrint('SupabaseTaskRepository: getTaskById called for id: $id');

      final response = await _supabase
          .from('tasks')
          .select()
          .eq('id', id)
          .single();

      debugPrint('SupabaseTaskRepository: Task response: $response');

      if (response == null) {
        return const AppResult.failure(DatabaseFailure('Task not found'));
      }

      final task = TaskEntity.fromJson(response);
      debugPrint(
        'SupabaseTaskRepository: Successfully got task: ${task.title}',
      );
      return AppResult.success(task);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error getting task by id: $e');
      return AppResult.failure(DatabaseFailure('Failed to get task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> createTask(TaskEntity task) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: createTask called for: ${task.title}',
      );

      final taskData = task.toJson();
      debugPrint('SupabaseTaskRepository: Task data to insert: $taskData');

      final response = await _supabase
          .from('tasks')
          .insert(taskData)
          .select()
          .single();

      debugPrint('SupabaseTaskRepository: Create response: $response');

      final createdTask = TaskEntity.fromJson(response);
      debugPrint(
        'SupabaseTaskRepository: Successfully created task: ${createdTask.title}',
      );
      return AppResult.success(createdTask);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error creating task: $e');
      return AppResult.failure(DatabaseFailure('Failed to create task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> updateTask(TaskEntity task) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: updateTask called for: ${task.title}',
      );

      final taskData = task.toJson();
      debugPrint('SupabaseTaskRepository: Task data to update: $taskData');

      final response = await _supabase
          .from('tasks')
          .update(taskData)
          .eq('id', task.id)
          .select()
          .single();

      debugPrint('SupabaseTaskRepository: Update response: $response');

      final updatedTask = TaskEntity.fromJson(response);
      debugPrint(
        'SupabaseTaskRepository: Successfully updated task: ${updatedTask.title}',
      );
      return AppResult.success(updatedTask);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error updating task: $e');
      return AppResult.failure(DatabaseFailure('Failed to update task: $e'));
    }
  }

  @override
  Future<AppResult<void>> deleteTask(String id) async {
    try {
      debugPrint('SupabaseTaskRepository: deleteTask called for id: $id');

      await _supabase.from('tasks').delete().eq('id', id);

      debugPrint(
        'SupabaseTaskRepository: Successfully deleted task with id: $id',
      );
      return const AppResult.success(null);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error deleting task: $e');
      return AppResult.failure(DatabaseFailure('Failed to delete task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> completeTask(String id) async {
    try {
      debugPrint('SupabaseTaskRepository: completeTask called for id: $id');

      final response = await _supabase
          .from('tasks')
          .update({
            'status': 'completed',
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      debugPrint('SupabaseTaskRepository: Complete response: $response');

      final completedTask = TaskEntity.fromJson(response);
      debugPrint(
        'SupabaseTaskRepository: Successfully completed task: ${completedTask.title}',
      );
      return AppResult.success(completedTask);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error completing task: $e');
      return AppResult.failure(DatabaseFailure('Failed to complete task: $e'));
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksByStatus(
    TaskStatus status,
  ) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: getTasksByStatus called for status: $status',
      );

      final response = await _supabase
          .from('tasks')
          .select()
          .eq('status', status.name)
          .order('created_at', ascending: false);

      debugPrint('SupabaseTaskRepository: Status filter response: $response');

      if (response == null) {
        return const AppResult.failure(
          DatabaseFailure('No response from database'),
        );
      }

      final List<TaskEntity> tasks = [];
      for (final taskData in response) {
        try {
          final task = TaskEntity.fromJson(taskData);
          tasks.add(task);
        } catch (e) {
          debugPrint(
            'SupabaseTaskRepository: Failed to parse task by status: $e',
          );
        }
      }

      debugPrint(
        'SupabaseTaskRepository: Successfully got ${tasks.length} tasks with status: $status',
      );
      return AppResult.success(tasks);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error getting tasks by status: $e');
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
      debugPrint(
        'SupabaseTaskRepository: getTasksByPriority called for priority: $priority',
      );

      final response = await _supabase
          .from('tasks')
          .select()
          .eq('priority', priority.name)
          .order('created_at', ascending: false);

      debugPrint('SupabaseTaskRepository: Priority filter response: $response');

      if (response == null) {
        return const AppResult.failure(
          DatabaseFailure('No response from database'),
        );
      }

      final List<TaskEntity> tasks = [];
      for (final taskData in response) {
        try {
          final task = TaskEntity.fromJson(taskData);
          tasks.add(task);
        } catch (e) {
          debugPrint(
            'SupabaseTaskRepository: Failed to parse task by priority: $e',
          );
        }
      }

      debugPrint(
        'SupabaseTaskRepository: Successfully got ${tasks.length} tasks with priority: $priority',
      );
      return AppResult.success(tasks);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error getting tasks by priority: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get tasks by priority: $e'),
      );
    }
  }

  // TODO: Implement remaining methods for full sync
  @override
  Future<AppResult<TaskEntity>> uncompleteTask(String id) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<TaskEntity>> archiveTask(String id) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<TaskEntity>> unarchiveTask(String id) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<TaskEntity>> starTask(String id) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<TaskEntity>> unstarTask(String id) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<TaskEntity>> addAudioToTask(
    String id,
    String audioPath,
    int duration,
  ) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<TaskEntity>> removeAudioFromTask(String id) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<TaskEntity>> addSubtasks(
    String parentId,
    List<TaskEntity> subtasks,
  ) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<TaskEntity>> removeSubtasks(
    String parentId,
    List<String> subtaskIds,
  ) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksDueToday() async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<List<TaskEntity>>> getOverdueTasks() async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksDueSoon(int days) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksByTags(List<String> tags) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<List<TaskEntity>>> searchTasks(String query) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<TaskStatistics>> getTaskStatistics() async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksBySyncStatus(
    String syncStatus,
  ) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<void>> markTaskAsSynced(String id) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<void>> markTaskAsSyncFailed(String id, String error) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<void>> clearCompletedTasks() async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<void>> clearArchivedTasks() async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<String>> exportTasks(String format) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<List<TaskEntity>>> importTasks(
    String data,
    String format,
  ) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<void>> bulkUpdateTasks(List<TaskEntity> tasks) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<void>> bulkDeleteTasks(List<String> taskIds) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<void>> syncWithRemote() async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<void>> clearLocalData() async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<void>> backupData() async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<void>> restoreData() async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<AppResult<void>> syncTasks() async {
    // TODO: Implement
    throw UnimplementedError();
  }
}
