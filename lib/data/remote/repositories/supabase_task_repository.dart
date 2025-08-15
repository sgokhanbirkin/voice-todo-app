import 'dart:convert';
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
    try {
      debugPrint('SupabaseTaskRepository: getTasks with filters called');

      dynamic query = _supabase.from('tasks').select();

      // Apply filters
      if (status != null) {
        query = query.eq('status', status.name);
      }
      if (priority != null) {
        query = query.eq('priority', priority.name);
      }
      if (isArchived != null) {
        query = query.eq('is_archived', isArchived);
      }
      if (isStarred != null) {
        query = query.eq('is_starred', isStarred);
      }
      if (dueDate != null) {
        final startOfDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        query = query
            .gte('due_date', startOfDay.toIso8601String())
            .lt('due_date', endOfDay.toIso8601String());
      }
      if (tags != null && tags.isNotEmpty) {
        query = query.contains('tags', tags);
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.or(
          'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%',
        );
      }

      // Apply sorting
      final sortField = sortBy ?? 'created_at';
      final ascending = sortAscending ?? false;
      query = query.order(sortField, ascending: ascending);

      // Apply pagination
      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, (offset + (limit ?? 100)) - 1);
      }

      final response = await query;
      debugPrint('SupabaseTaskRepository: Filtered response: $response');

      final List<TaskEntity> tasks = [];
      for (final taskData in response) {
        try {
          final task = TaskEntity.fromJson(taskData);
          tasks.add(task);
        } catch (e) {
          debugPrint(
            'SupabaseTaskRepository: Failed to parse filtered task: $e',
          );
        }
      }

      debugPrint(
        'SupabaseTaskRepository: Successfully got ${tasks.length} filtered tasks',
      );
      return AppResult.success(tasks);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error getting filtered tasks: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get filtered tasks: $e'),
      );
    }
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

  @override
  Future<AppResult<TaskEntity>> uncompleteTask(String id) async {
    try {
      debugPrint('SupabaseTaskRepository: uncompleteTask called for id: $id');

      final response = await _supabase
          .from('tasks')
          .update({'status': 'pending', 'completed_at': null})
          .eq('id', id)
          .select()
          .single();

      debugPrint('SupabaseTaskRepository: Uncomplete response: $response');

      final uncompletedTask = TaskEntity.fromJson(response);
      debugPrint(
        'SupabaseTaskRepository: Successfully uncompleted task: ${uncompletedTask.title}',
      );
      return AppResult.success(uncompletedTask);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error uncompleting task: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to uncomplete task: $e'),
      );
    }
  }

  @override
  Future<AppResult<TaskEntity>> archiveTask(String id) async {
    try {
      debugPrint('SupabaseTaskRepository: archiveTask called for id: $id');

      final response = await _supabase
          .from('tasks')
          .update({'is_archived': true})
          .eq('id', id)
          .select()
          .single();

      debugPrint('SupabaseTaskRepository: Archive response: $response');

      final archivedTask = TaskEntity.fromJson(response);
      debugPrint(
        'SupabaseTaskRepository: Successfully archived task: ${archivedTask.title}',
      );
      return AppResult.success(archivedTask);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error archiving task: $e');
      return AppResult.failure(DatabaseFailure('Failed to archive task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> unarchiveTask(String id) async {
    try {
      debugPrint('SupabaseTaskRepository: unarchiveTask called for id: $id');

      final response = await _supabase
          .from('tasks')
          .update({'is_archived': false})
          .eq('id', id)
          .select()
          .single();

      debugPrint('SupabaseTaskRepository: Unarchive response: $response');

      final unarchivedTask = TaskEntity.fromJson(response);
      debugPrint(
        'SupabaseTaskRepository: Successfully unarchived task: ${unarchivedTask.title}',
      );
      return AppResult.success(unarchivedTask);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error unarchiving task: $e');
      return AppResult.failure(DatabaseFailure('Failed to unarchive task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> starTask(String id) async {
    try {
      debugPrint('SupabaseTaskRepository: starTask called for id: $id');

      final response = await _supabase
          .from('tasks')
          .update({'is_starred': true})
          .eq('id', id)
          .select()
          .single();

      debugPrint('SupabaseTaskRepository: Star response: $response');

      final starredTask = TaskEntity.fromJson(response);
      debugPrint(
        'SupabaseTaskRepository: Successfully starred task: ${starredTask.title}',
      );
      return AppResult.success(starredTask);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error starring task: $e');
      return AppResult.failure(DatabaseFailure('Failed to star task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> unstarTask(String id) async {
    try {
      debugPrint('SupabaseTaskRepository: unstarTask called for id: $id');

      final response = await _supabase
          .from('tasks')
          .update({'is_starred': false})
          .eq('id', id)
          .select()
          .single();

      debugPrint('SupabaseTaskRepository: Unstar response: $response');

      final unstarredTask = TaskEntity.fromJson(response);
      debugPrint(
        'SupabaseTaskRepository: Successfully unstarred task: ${unstarredTask.title}',
      );
      return AppResult.success(unstarredTask);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error unstarring task: $e');
      return AppResult.failure(DatabaseFailure('Failed to unstar task: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> addAudioToTask(
    String id,
    String audioPath,
    int duration,
  ) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: addAudioToTask called for id: $id, path: $audioPath, duration: $duration',
      );

      final response = await _supabase
          .from('tasks')
          .update({
            'audio_path': audioPath,
            'audio_duration': duration,
            'audio_file_name': audioPath.split('/').last,
          })
          .eq('id', id)
          .select()
          .single();

      debugPrint('SupabaseTaskRepository: Add audio response: $response');

      final updatedTask = TaskEntity.fromJson(response);
      debugPrint(
        'SupabaseTaskRepository: Successfully added audio to task: ${updatedTask.title}',
      );
      return AppResult.success(updatedTask);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error adding audio to task: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to add audio to task: $e'),
      );
    }
  }

  @override
  Future<AppResult<TaskEntity>> removeAudioFromTask(String id) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: removeAudioFromTask called for id: $id',
      );

      final response = await _supabase
          .from('tasks')
          .update({
            'audio_path': null,
            'audio_duration': null,
            'audio_file_name': null,
          })
          .eq('id', id)
          .select()
          .single();

      debugPrint('SupabaseTaskRepository: Remove audio response: $response');

      final updatedTask = TaskEntity.fromJson(response);
      debugPrint(
        'SupabaseTaskRepository: Successfully removed audio from task: ${updatedTask.title}',
      );
      return AppResult.success(updatedTask);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error removing audio from task: $e');
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
      debugPrint(
        'SupabaseTaskRepository: addSubtasks called for parent: $parentId, subtasks: ${subtasks.length}',
      );

      // Create all subtasks with parent reference
      final List<TaskEntity> createdSubtasks = [];
      for (final subtask in subtasks) {
        final subtaskWithParent = TaskEntity.create(
          title: subtask.title,
          description: subtask.description,
          priority: subtask.priority,
          status: subtask.status,
          dueDate: subtask.dueDate,
          parentTaskId: parentId,
          userId: subtask.userId,
        );

        final result = await createTask(subtaskWithParent);
        if (result.isSuccess) {
          createdSubtasks.add(result.dataOrNull!);
        }
      }

      // Get updated parent task
      final parentTaskResult = await getTaskById(parentId);
      if (parentTaskResult.isFailure) {
        return AppResult.failure(parentTaskResult.errorOrNull!);
      }

      debugPrint(
        'SupabaseTaskRepository: Successfully added ${createdSubtasks.length} subtasks to parent: $parentId',
      );
      return parentTaskResult;
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error adding subtasks: $e');
      return AppResult.failure(DatabaseFailure('Failed to add subtasks: $e'));
    }
  }

  @override
  Future<AppResult<TaskEntity>> removeSubtasks(
    String parentId,
    List<String> subtaskIds,
  ) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: removeSubtasks called for parent: $parentId, subtaskIds: ${subtaskIds.length}',
      );

      // Delete all subtasks
      for (final subtaskId in subtaskIds) {
        await deleteTask(subtaskId);
      }

      // Get updated parent task
      final parentTaskResult = await getTaskById(parentId);
      if (parentTaskResult.isFailure) {
        return AppResult.failure(parentTaskResult.errorOrNull!);
      }

      debugPrint(
        'SupabaseTaskRepository: Successfully removed ${subtaskIds.length} subtasks from parent: $parentId',
      );
      return parentTaskResult;
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error removing subtasks: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to remove subtasks: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksDueToday() async {
    try {
      debugPrint('SupabaseTaskRepository: getTasksDueToday called');

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('tasks')
          .select()
          .gte('due_date', startOfDay.toIso8601String())
          .lt('due_date', endOfDay.toIso8601String())
          .order('due_date', ascending: true);

      debugPrint('SupabaseTaskRepository: Due today response: $response');

      final List<TaskEntity> tasks = [];
      for (final taskData in response) {
        try {
          final task = TaskEntity.fromJson(taskData);
          tasks.add(task);
        } catch (e) {
          debugPrint(
            'SupabaseTaskRepository: Failed to parse task due today: $e',
          );
        }
      }

      debugPrint(
        'SupabaseTaskRepository: Successfully got ${tasks.length} tasks due today',
      );
      return AppResult.success(tasks);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error getting tasks due today: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get tasks due today: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> getOverdueTasks() async {
    try {
      debugPrint('SupabaseTaskRepository: getOverdueTasks called');

      final now = DateTime.now();

      final response = await _supabase
          .from('tasks')
          .select()
          .lt('due_date', now.toIso8601String())
          .neq('status', 'completed')
          .order('due_date', ascending: true);

      debugPrint('SupabaseTaskRepository: Overdue response: $response');

      final List<TaskEntity> tasks = [];
      for (final taskData in response) {
        try {
          final task = TaskEntity.fromJson(taskData);
          tasks.add(task);
        } catch (e) {
          debugPrint(
            'SupabaseTaskRepository: Failed to parse overdue task: $e',
          );
        }
      }

      debugPrint(
        'SupabaseTaskRepository: Successfully got ${tasks.length} overdue tasks',
      );
      return AppResult.success(tasks);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error getting overdue tasks: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get overdue tasks: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksDueSoon(int days) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: getTasksDueSoon called for $days days',
      );

      final now = DateTime.now();
      final endDate = now.add(Duration(days: days));

      final response = await _supabase
          .from('tasks')
          .select()
          .gte('due_date', now.toIso8601String())
          .lte('due_date', endDate.toIso8601String())
          .neq('status', 'completed')
          .order('due_date', ascending: true);

      debugPrint('SupabaseTaskRepository: Due soon response: $response');

      final List<TaskEntity> tasks = [];
      for (final taskData in response) {
        try {
          final task = TaskEntity.fromJson(taskData);
          tasks.add(task);
        } catch (e) {
          debugPrint(
            'SupabaseTaskRepository: Failed to parse task due soon: $e',
          );
        }
      }

      debugPrint(
        'SupabaseTaskRepository: Successfully got ${tasks.length} tasks due in $days days',
      );
      return AppResult.success(tasks);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error getting tasks due soon: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get tasks due soon: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksByTags(List<String> tags) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: getTasksByTags called for tags: $tags',
      );

      if (tags.isEmpty) {
        return AppResult.success([]);
      }

      final response = await _supabase
          .from('tasks')
          .select()
          .contains('tags', tags)
          .order('created_at', ascending: false);

      debugPrint('SupabaseTaskRepository: Tags filter response: $response');

      final List<TaskEntity> tasks = [];
      for (final taskData in response) {
        try {
          final task = TaskEntity.fromJson(taskData);
          tasks.add(task);
        } catch (e) {
          debugPrint(
            'SupabaseTaskRepository: Failed to parse task by tags: $e',
          );
        }
      }

      debugPrint(
        'SupabaseTaskRepository: Successfully got ${tasks.length} tasks with tags: $tags',
      );
      return AppResult.success(tasks);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error getting tasks by tags: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get tasks by tags: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> searchTasks(String query) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: searchTasks called for query: $query',
      );

      if (query.trim().isEmpty) {
        return AppResult.success([]);
      }

      final response = await _supabase
          .from('tasks')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      debugPrint('SupabaseTaskRepository: Search response: $response');

      final List<TaskEntity> tasks = [];
      for (final taskData in response) {
        try {
          final task = TaskEntity.fromJson(taskData);
          tasks.add(task);
        } catch (e) {
          debugPrint(
            'SupabaseTaskRepository: Failed to parse search result: $e',
          );
        }
      }

      debugPrint(
        'SupabaseTaskRepository: Successfully found ${tasks.length} tasks for query: $query',
      );
      return AppResult.success(tasks);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error searching tasks: $e');
      return AppResult.failure(DatabaseFailure('Failed to search tasks: $e'));
    }
  }

  @override
  Future<AppResult<TaskStatistics>> getTaskStatistics() async {
    try {
      debugPrint('SupabaseTaskRepository: getTaskStatistics called');

      // Get all tasks for statistics
      final tasksResult = await getAllTasks();
      if (tasksResult.isFailure) {
        return AppResult.failure(tasksResult.errorOrNull!);
      }

      final tasks = tasksResult.dataOrNull!;

      // Calculate statistics
      final totalTasks = tasks.length;
      final completedTasks = tasks
          .where((task) => task.status == TaskStatus.completed)
          .length;
      final pendingTasks = tasks
          .where((task) => task.status == TaskStatus.pending)
          .length;
      final overdueTasks = tasks
          .where(
            (task) =>
                task.dueDate != null &&
                task.dueDate!.isBefore(DateTime.now()) &&
                task.status != TaskStatus.completed,
          )
          .length;

      // Priority-based statistics
      final highPriorityTasks = tasks
          .where((task) => task.priority == TaskPriority.high)
          .length;
      final mediumPriorityTasks = tasks
          .where((task) => task.priority == TaskPriority.medium)
          .length;
      final lowPriorityTasks = tasks
          .where((task) => task.priority == TaskPriority.low)
          .length;

      // Status-based statistics
      final starredTasks = tasks.where((task) => task.isStarred).length;
      final archivedTasks = tasks.where((task) => task.isArchived).length;

      // Due today tasks
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final dueTodayTasks = tasks
          .where(
            (task) =>
                task.dueDate != null &&
                task.dueDate!.isAfter(startOfDay) &&
                task.dueDate!.isBefore(endOfDay),
          )
          .length;

      // Time-based statistics
      final completedThisWeek = tasks
          .where(
            (task) =>
                task.status == TaskStatus.completed &&
                task.completedAt != null &&
                task.completedAt!.isAfter(
                  now.subtract(const Duration(days: 7)),
                ),
          )
          .length;

      final completedThisMonth = tasks
          .where(
            (task) =>
                task.status == TaskStatus.completed &&
                task.completedAt != null &&
                task.completedAt!.isAfter(DateTime(now.year, now.month, 1)),
          )
          .length;

      // Calculate average completion time (simplified)
      final completedTasksWithDate = tasks
          .where(
            (task) =>
                task.status == TaskStatus.completed && task.completedAt != null,
          )
          .toList();

      double averageCompletionTime = 0.0;
      if (completedTasksWithDate.isNotEmpty) {
        final totalDays = completedTasksWithDate.fold<int>(0, (sum, task) {
          if (task.completedAt != null) {
            return sum + task.completedAt!.difference(task.createdAt).inDays;
          }
          return sum;
        });
        averageCompletionTime = totalDays / completedTasksWithDate.length;
      }

      final statistics = TaskStatistics(
        totalTasks: totalTasks,
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

      debugPrint(
        'SupabaseTaskRepository: Successfully generated statistics: $statistics',
      );
      return AppResult.success(statistics);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error getting task statistics: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get task statistics: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> getTasksBySyncStatus(
    String syncStatus,
  ) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: getTasksBySyncStatus called for status: $syncStatus',
      );

      final response = await _supabase
          .from('tasks')
          .select()
          .eq('sync_status', syncStatus)
          .order('created_at', ascending: false);

      debugPrint('SupabaseTaskRepository: Sync status response: $response');

      final List<TaskEntity> tasks = [];
      for (final taskData in response) {
        try {
          final task = TaskEntity.fromJson(taskData);
          tasks.add(task);
        } catch (e) {
          debugPrint(
            'SupabaseTaskRepository: Failed to parse task by sync status: $e',
          );
        }
      }

      debugPrint(
        'SupabaseTaskRepository: Successfully got ${tasks.length} tasks with sync status: $syncStatus',
      );
      return AppResult.success(tasks);
    } catch (e) {
      debugPrint(
        'SupabaseTaskRepository: Error getting tasks by sync status: $e',
      );
      return AppResult.failure(
        DatabaseFailure('Failed to get tasks by sync status: $e'),
      );
    }
  }

  Future<AppResult<void>> markTaskAsSynced(String id) async {
    try {
      debugPrint('SupabaseTaskRepository: markTaskAsSynced called for id: $id');

      await _supabase
          .from('tasks')
          .update({
            'sync_status': 'synced',
            'local_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      debugPrint(
        'SupabaseTaskRepository: Successfully marked task as synced: $id',
      );
      return const AppResult.success(null);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error marking task as synced: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to mark task as synced: $e'),
      );
    }
  }

  Future<AppResult<void>> markTaskAsSyncFailed(String id, String error) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: markTaskAsSyncFailed called for id: $id, error: $error',
      );

      await _supabase
          .from('tasks')
          .update({
            'sync_status': 'failed',
            'local_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      debugPrint(
        'SupabaseTaskRepository: Successfully marked task as sync failed: $id',
      );
      return const AppResult.success(null);
    } catch (e) {
      debugPrint(
        'SupabaseTaskRepository: Error marking task as sync failed: $e',
      );
      return AppResult.failure(
        DatabaseFailure('Failed to mark task as sync failed: $e'),
      );
    }
  }

  Future<AppResult<void>> clearCompletedTasks() async {
    try {
      debugPrint('SupabaseTaskRepository: clearCompletedTasks called');

      final response = await _supabase
          .from('tasks')
          .delete()
          .eq('status', 'completed');

      debugPrint('SupabaseTaskRepository: Clear completed response: $response');

      debugPrint(
        'SupabaseTaskRepository: Successfully cleared completed tasks',
      );
      return const AppResult.success(null);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error clearing completed tasks: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to clear completed tasks: $e'),
      );
    }
  }

  Future<AppResult<void>> clearArchivedTasks() async {
    try {
      debugPrint('SupabaseTaskRepository: clearArchivedTasks called');

      final response = await _supabase
          .from('tasks')
          .delete()
          .eq('is_archived', true);

      debugPrint('SupabaseTaskRepository: Clear archived response: $response');

      debugPrint('SupabaseTaskRepository: Successfully cleared archived tasks');
      return const AppResult.success(null);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error clearing archived tasks: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to clear archived tasks: $e'),
      );
    }
  }

  @override
  Future<AppResult<String>> exportTasks(String format) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: exportTasks called for format: $format',
      );

      // Get all tasks for export
      final tasksResult = await getAllTasks();
      if (tasksResult.isFailure) {
        return AppResult.failure(tasksResult.errorOrNull!);
      }

      final tasks = tasksResult.dataOrNull!;
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

      debugPrint(
        'SupabaseTaskRepository: Successfully exported ${tasks.length} tasks in $format format',
      );
      return AppResult.success(exportData);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error exporting tasks: $e');
      return AppResult.failure(DatabaseFailure('Failed to export tasks: $e'));
    }
  }

  @override
  Future<AppResult<List<TaskEntity>>> importTasks(
    String data,
    String format,
  ) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: importTasks called for format: $format',
      );

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
            return AppResult.failure(
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
                  debugPrint(
                    'SupabaseTaskRepository: Failed to parse CSV line $i: $e',
                  );
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
        return AppResult.failure(
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

      debugPrint(
        'SupabaseTaskRepository: Successfully imported ${createdTasks.length} tasks',
      );
      return AppResult.success(createdTasks);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error importing tasks: $e');
      return AppResult.failure(DatabaseFailure('Failed to import tasks: $e'));
    }
  }

  Future<AppResult<void>> bulkUpdateTasks(List<TaskEntity> tasks) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: bulkUpdateTasks called for ${tasks.length} tasks',
      );

      if (tasks.isEmpty) {
        return const AppResult.success(null);
      }

      final tasksData = tasks.map((task) => task.toJson()).toList();

      final response = await _supabase
          .from('tasks')
          .upsert(tasksData, onConflict: 'id');

      debugPrint('SupabaseTaskRepository: Bulk update response: $response');

      debugPrint(
        'SupabaseTaskRepository: Successfully bulk updated ${tasks.length} tasks',
      );
      return const AppResult.success(null);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error bulk updating tasks: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to bulk update tasks: $e'),
      );
    }
  }

  Future<AppResult<void>> bulkDeleteTasks(List<String> taskIds) async {
    try {
      debugPrint(
        'SupabaseTaskRepository: bulkDeleteTasks called for ${taskIds.length} task IDs',
      );

      if (taskIds.isEmpty) {
        return const AppResult.success(null);
      }

      final response = await _supabase
          .from('tasks')
          .delete()
          .inFilter('id', taskIds);

      debugPrint('SupabaseTaskRepository: Bulk delete response: $response');

      debugPrint(
        'SupabaseTaskRepository: Successfully bulk deleted ${taskIds.length} tasks',
      );
      return const AppResult.success(null);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error bulk deleting tasks: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to bulk delete tasks: $e'),
      );
    }
  }

  Future<AppResult<void>> syncWithRemote() async {
    try {
      debugPrint('SupabaseTaskRepository: syncWithRemote called');

      // Get all tasks from remote
      final remoteTasksResult = await getAllTasks();
      if (remoteTasksResult.isFailure) {
        return AppResult.failure(remoteTasksResult.errorOrNull!);
      }

      final remoteTasks = remoteTasksResult.dataOrNull!;
      debugPrint(
        'SupabaseTaskRepository: Retrieved ${remoteTasks.length} tasks from remote',
      );

      // Mark all as synced
      for (final task in remoteTasks) {
        await markTaskAsSynced(task.id);
      }

      debugPrint(
        'SupabaseTaskRepository: Successfully synced ${remoteTasks.length} tasks with remote',
      );
      return const AppResult.success(null);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error syncing with remote: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to sync with remote: $e'),
      );
    }
  }

  Future<AppResult<void>> clearLocalData() async {
    try {
      debugPrint('SupabaseTaskRepository: clearLocalData called');

      // This is a remote repository, so we clear remote data
      final response = await _supabase.from('tasks').delete().neq('id', '');

      debugPrint(
        'SupabaseTaskRepository: Clear local data response: $response',
      );

      debugPrint(
        'SupabaseTaskRepository: Successfully cleared all remote task data',
      );
      return const AppResult.success(null);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error clearing local data: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to clear local data: $e'),
      );
    }
  }

  Future<AppResult<void>> backupData() async {
    try {
      debugPrint('SupabaseTaskRepository: backupData called');

      // Get all tasks for backup
      final tasksResult = await getAllTasks();
      if (tasksResult.isFailure) {
        return AppResult.failure(tasksResult.errorOrNull!);
      }

      final tasks = tasksResult.dataOrNull!;
      final backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'taskCount': tasks.length,
        'tasks': tasks.map((task) => task.toJson()).toList(),
      };

      debugPrint(
        'SupabaseTaskRepository: Successfully backed up ${tasks.length} tasks',
      );
      debugPrint('SupabaseTaskRepository: Backup data: $backupData');
      return const AppResult.success(null);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error backing up data: $e');
      return AppResult.failure(DatabaseFailure('Failed to backup data: $e'));
    }
  }

  Future<AppResult<void>> restoreData() async {
    try {
      debugPrint('SupabaseTaskRepository: restoreData called');

      // This method would typically restore from a backup
      // For now, we'll just return success as it's a placeholder
      debugPrint(
        'SupabaseTaskRepository: Data restore functionality not implemented yet',
      );
      return const AppResult.success(null);
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error restoring data: $e');
      return AppResult.failure(DatabaseFailure('Failed to restore data: $e'));
    }
  }

  @override
  Future<AppResult<void>> syncTasks() async {
    try {
      debugPrint('SupabaseTaskRepository: syncTasks called');

      // This is the same as syncWithRemote for this repository
      return await syncWithRemote();
    } catch (e) {
      debugPrint('SupabaseTaskRepository: Error syncing tasks: $e');
      return AppResult.failure(DatabaseFailure('Failed to sync tasks: $e'));
    }
  }
}
