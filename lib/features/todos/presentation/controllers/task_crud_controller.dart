import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/task_entity.dart';
import '../../domain/i_task_repository.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../../../core/result.dart';
import '../../../../core/errors.dart';

/// Controller responsible for managing task CRUD operations
class TaskCRUDController extends GetxController {
  final ITaskRepository _taskRepository;
  final SyncManager _syncManager = Get.find<SyncManager>();

  /// Whether tasks are currently loading
  final RxBool isLoading = false.obs;

  /// Whether there was an error
  final RxBool hasError = false.obs;

  /// Error message if any
  final RxString errorMessage = ''.obs;

  /// Callback function to notify when tasks change
  Function()? onTasksChanged;

  TaskCRUDController(this._taskRepository);

  /// Shows a snackbar safely
  void _showSnackbar(String title, String message, {bool isError = false}) {
    try {
      if (Get.context != null) {
        Get.snackbar(
          title,
          message,
          backgroundColor: isError
              ? Colors.red.withValues(alpha: 0.9)
              : Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      // Silently handle snackbar errors - using debugPrint in development
      debugPrint('Snackbar error: $e');
    }
  }

  /// Validates task title
  String? validateTaskTitle(String? title) {
    return Validators.taskTitle(title);
  }

  /// Validates task description
  String? validateTaskDescription(String? description) {
    return Validators.taskDescription(description);
  }

  /// Creates a new task with validation
  Future<AppResult<TaskEntity>> createTask(TaskEntity task) async {
    try {
      // Validate task data
      final titleError = validateTaskTitle(task.title);
      final descriptionError = validateTaskDescription(task.description);

      if (titleError != null) {
        return AppResult.failure(ValidationFailure(titleError));
      }

      if (descriptionError != null) {
        return AppResult.failure(ValidationFailure(descriptionError));
      }

      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _taskRepository.createTask(task);

      result.fold(
        (createdTask) {
          // Add to sync queue for Supabase
          _syncManager.addTaskToSyncQueue(createdTask);
          _showSnackbar('Success', 'Task created successfully');
          _notifyTasksChanged();
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
          _showSnackbar(
            'Error',
            'Failed to create task: ${failure.message}',
            isError: true,
          );
        },
      );

      return result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error: $e';
      _showSnackbar('Error', 'Unexpected error: $e', isError: true);
      return AppResult.failure(UnknownFailure('Unexpected error: $e'));
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates an existing task
  Future<AppResult<TaskEntity>> updateTask(TaskEntity task) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _taskRepository.updateTask(task);

      result.fold(
        (updatedTask) {
          // Add to sync queue for Supabase
          _syncManager.addTaskToSyncQueue(updatedTask);
          _showSnackbar('Success', 'Task updated successfully');
          _notifyTasksChanged();
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
          _showSnackbar(
            'Error',
            'Failed to update task: ${failure.message}',
            isError: true,
          );
        },
      );

      return result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error: $e';
      _showSnackbar('Error', 'Unexpected error: $e', isError: true);
      return AppResult.failure(UnknownFailure('Unexpected error: $e'));
    } finally {
      isLoading.value = false;
    }
  }

  /// Deletes a task
  Future<AppResult<void>> deleteTask(String taskId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _taskRepository.deleteTask(taskId);

      result.fold(
        (_) {
          // Add to sync queue for Supabase delete
          _syncManager.addTaskDeleteToSyncQueue(taskId);
          _showSnackbar('Success', 'Task deleted successfully');
          _notifyTasksChanged();
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
          _showSnackbar(
            'Error',
            'Failed to delete task: ${failure.message}',
            isError: true,
          );
        },
      );

      return result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error: $e';
      _showSnackbar('Error', 'Unexpected error: $e', isError: true);
      return AppResult.failure(UnknownFailure('Unexpected error: $e'));
    } finally {
      isLoading.value = false;
    }
  }

  /// Completes a task
  Future<AppResult<TaskEntity>> completeTask(String taskId) async {
    try {
      hasError.value = false;
      errorMessage.value = '';

      final result = await _taskRepository.completeTask(taskId);

      result.fold(
        (updatedTask) {
          _showSnackbar('Success', 'Task completed successfully');
          _notifyTasksChanged();
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
          _showSnackbar(
            'Error',
            'Failed to complete task: ${failure.message}',
            isError: true,
          );
        },
      );

      return result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error: $e';
      _showSnackbar('Error', 'Unexpected error: $e', isError: true);
      return AppResult.failure(UnknownFailure('Unexpected error: $e'));
    }
  }

  /// Uncompletes a task
  Future<AppResult<TaskEntity>> uncompleteTask(String taskId) async {
    try {
      hasError.value = false;
      errorMessage.value = '';

      final result = await _taskRepository.uncompleteTask(taskId);

      result.fold(
        (updatedTask) {
          _showSnackbar('Success', 'Task marked as pending');
          _notifyTasksChanged();
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
          _showSnackbar(
            'Error',
            'Failed to uncomplete task: ${failure.message}',
            isError: true,
          );
        },
      );

      return result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error: $e';
      _showSnackbar('Error', 'Unexpected error: $e', isError: true);
      return AppResult.failure(UnknownFailure('Unexpected error: $e'));
    }
  }

  /// Stars a task
  Future<AppResult<TaskEntity>> starTask(String taskId) async {
    try {
      hasError.value = false;
      errorMessage.value = '';

      final result = await _taskRepository.starTask(taskId);

      result.fold(
        (updatedTask) {
          _showSnackbar('Success', 'Task starred successfully');
          _notifyTasksChanged();
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
          _showSnackbar(
            'Error',
            'Failed to star task: ${failure.message}',
            isError: true,
          );
        },
      );

      return result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error: $e';
      _showSnackbar('Error', 'Unexpected error: $e', isError: true);
      return AppResult.failure(UnknownFailure('Unexpected error: $e'));
    }
  }

  /// Unstars a task
  Future<AppResult<TaskEntity>> unstarTask(String taskId) async {
    try {
      hasError.value = false;
      errorMessage.value = '';

      final result = await _taskRepository.unstarTask(taskId);

      result.fold(
        (updatedTask) {
          _showSnackbar('Success', 'Task unstarred successfully');
          _notifyTasksChanged();
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
          _showSnackbar(
            'Error',
            'Failed to unstar task: ${failure.message}',
            isError: true,
          );
        },
      );

      return result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error: $e';
      _showSnackbar('Error', 'Unexpected error: $e', isError: true);
      return AppResult.failure(UnknownFailure('Unexpected error: $e'));
    }
  }

  /// Archives a task
  Future<AppResult<TaskEntity>> archiveTask(String taskId) async {
    try {
      hasError.value = false;
      errorMessage.value = '';

      final result = await _taskRepository.archiveTask(taskId);

      result.fold(
        (updatedTask) {
          _showSnackbar('Success', 'Task archived successfully');
          _notifyTasksChanged();
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
          _showSnackbar(
            'Error',
            'Failed to archive task: ${failure.message}',
            isError: true,
          );
        },
      );

      return result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error: $e';
      _showSnackbar('Error', 'Unexpected error: $e', isError: true);
      return AppResult.failure(UnknownFailure('Unexpected error: $e'));
    }
  }

  /// Unarchives a task
  Future<AppResult<TaskEntity>> unarchiveTask(String taskId) async {
    try {
      hasError.value = false;
      errorMessage.value = '';

      final result = await _taskRepository.unarchiveTask(taskId);

      result.fold(
        (updatedTask) {
          _showSnackbar('Success', 'Task unarchived successfully');
          _notifyTasksChanged();
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
          _showSnackbar(
            'Error',
            'Failed to unarchive task: ${failure.message}',
            isError: true,
          );
        },
      );

      return result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error: $e';
      _showSnackbar('Error', 'Unexpected error: $e', isError: true);
      return AppResult.failure(UnknownFailure('Unexpected error: $e'));
    }
  }

  /// Adds audio to a task
  Future<AppResult<TaskEntity>> addAudioToTask(
    String id,
    String audioPath,
    int duration,
  ) async {
    try {
      hasError.value = false;
      errorMessage.value = '';

      final result = await _taskRepository.addAudioToTask(
        id,
        audioPath,
        duration,
      );

      result.fold(
        (updatedTask) {
          _showSnackbar('Success', 'Audio added to task successfully');
          _notifyTasksChanged();
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
          _showSnackbar(
            'Error',
            'Failed to add audio to task: ${failure.message}',
            isError: true,
          );
        },
      );

      return result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error: $e';
      _showSnackbar('Error', 'Unexpected error: $e', isError: true);
      return AppResult.failure(UnknownFailure('Unexpected error: $e'));
    }
  }

  /// Removes audio from a task
  Future<AppResult<TaskEntity>> removeAudioFromTask(String id) async {
    try {
      hasError.value = false;
      errorMessage.value = '';

      final result = await _taskRepository.removeAudioFromTask(id);

      result.fold(
        (updatedTask) {
          _showSnackbar('Success', 'Audio removed from task successfully');
          _notifyTasksChanged();
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
          _showSnackbar(
            'Error',
            'Failed to remove audio from task: ${failure.message}',
            isError: true,
          );
        },
      );

      return result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error: $e';
      _showSnackbar('Error', 'Unexpected error: $e', isError: true);
      return AppResult.failure(UnknownFailure('Unexpected error: $e'));
    }
  }

  /// Notifies that tasks have changed
  void _notifyTasksChanged() {
    if (onTasksChanged != null) {
      onTasksChanged!();
    }
  }

  /// Clears error state
  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }

  /// Resets loading state
  void resetLoading() {
    isLoading.value = false;
  }
}

/// Custom failure types for better error handling
class ValidationFailure extends Failure {
  ValidationFailure(super.message) : super(code: 'VALIDATION_ERROR');
}

class UnknownFailure extends Failure {
  UnknownFailure(super.message) : super(code: 'UNKNOWN_ERROR');
}
