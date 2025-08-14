import 'package:get/get.dart';
import '../../domain/task_entity.dart';
import '../../domain/i_task_repository.dart';
import '../../../../core/validation/validators.dart';

/// Task controller for managing task state and operations
class TaskController extends GetxController {
  final ITaskRepository _taskRepository;

  /// Observable list of all tasks
  final RxList<TaskEntity> tasks = <TaskEntity>[].obs;

  /// Observable list of filtered tasks
  final RxList<TaskEntity> filteredTasks = <TaskEntity>[].obs;

  /// Observable list of completed tasks
  final RxList<TaskEntity> completedTasks = <TaskEntity>[].obs;

  /// Observable list of pending tasks
  final RxList<TaskEntity> pendingTasks = <TaskEntity>[].obs;

  /// Observable list of overdue tasks
  final RxList<TaskEntity> overdueTasks = <TaskEntity>[].obs;

  /// Observable list of tasks due today
  final RxList<TaskEntity> dueTodayTasks = <TaskEntity>[].obs;

  /// Observable list of starred tasks
  final RxList<TaskEntity> starredTasks = <TaskEntity>[].obs;

  /// Observable list of archived tasks
  final RxList<TaskEntity> archivedTasks = <TaskEntity>[].obs;

  /// Current search query
  final RxString searchQuery = ''.obs;

  /// Current filter status
  final Rx<TaskStatus?> filterStatus = Rx<TaskStatus?>(null);

  /// Current filter priority
  final Rx<TaskPriority?> filterPriority = Rx<TaskPriority?>(null);

  /// Current sort field
  final RxString sortBy = 'createdAt'.obs;

  /// Current sort direction
  final RxBool sortAscending = false.obs;

  /// Whether tasks are currently loading
  final RxBool isLoading = false.obs;

  /// Whether there was an error loading tasks
  final RxBool hasError = false.obs;

  /// Error message if any
  final RxString errorMessage = ''.obs;

  /// Selected task for editing
  final Rx<TaskEntity?> selectedTask = Rx<TaskEntity?>(null);

  /// Task statistics
  final Rx<TaskStatistics?> taskStatistics = Rx<TaskStatistics?>(null);

  TaskController(this._taskRepository);

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  /// Validates task title
  String? validateTaskTitle(String? title) {
    return Validators.taskTitle(title);
  }

  /// Validates task description
  String? validateTaskDescription(String? description) {
    return Validators.taskDescription(description);
  }

  /// Loads all tasks from the repository
  Future<void> loadTasks() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _taskRepository.getAllTasks();

      result.fold(
        (tasks) {
          this.tasks.value = tasks;
          _updateFilteredTasks();
          _updateCategorizedTasks();
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

  /// Creates a new task with validation
  Future<void> createTask(TaskEntity task) async {
    try {
      // Validate task data
      final titleError = validateTaskTitle(task.title);
      final descriptionError = validateTaskDescription(task.description);

      if (titleError != null) {
        Get.snackbar('Validation Error', titleError);
        return;
      }

      if (descriptionError != null) {
        Get.snackbar('Validation Error', descriptionError);
        return;
      }

      isLoading.value = true;

      final result = await _taskRepository.createTask(task);

      result.fold(
        (createdTask) {
          tasks.add(createdTask);
          _updateFilteredTasks();
          _updateCategorizedTasks();
          Get.snackbar('Success', 'Task created successfully');
        },
        (failure) {
          Get.snackbar('Error', 'Failed to create task: ${failure.message}');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates an existing task
  Future<void> updateTask(TaskEntity task) async {
    try {
      isLoading.value = true;

      final result = await _taskRepository.updateTask(task);

      result.fold(
        (updatedTask) {
          final index = tasks.indexWhere((t) => t.id == updatedTask.id);
          if (index != -1) {
            tasks[index] = updatedTask;
            _updateFilteredTasks();
            _updateCategorizedTasks();
            Get.snackbar('Success', 'Task updated successfully');
          }
        },
        (failure) {
          Get.snackbar('Error', 'Failed to update task: ${failure.message}');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Deletes a task
  Future<void> deleteTask(String taskId) async {
    try {
      isLoading.value = true;

      final result = await _taskRepository.deleteTask(taskId);

      result.fold(
        (_) {
          tasks.removeWhere((task) => task.id == taskId);
          _updateFilteredTasks();
          _updateCategorizedTasks();
          Get.snackbar('Success', 'Task deleted successfully');
        },
        (failure) {
          Get.snackbar('Error', 'Failed to delete task: ${failure.message}');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Completes a task
  Future<void> completeTask(String taskId) async {
    try {
      final result = await _taskRepository.completeTask(taskId);

      result.fold(
        (updatedTask) {
          final index = tasks.indexWhere((t) => t.id == taskId);
          if (index != -1) {
            tasks[index] = updatedTask;
            _updateFilteredTasks();
            _updateCategorizedTasks();
          }
        },
        (failure) {
          Get.snackbar('Error', 'Failed to complete task: ${failure.message}');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
    }
  }

  /// Uncompletes a task
  Future<void> uncompleteTask(String taskId) async {
    try {
      final result = await _taskRepository.uncompleteTask(taskId);

      result.fold(
        (updatedTask) {
          final index = tasks.indexWhere((t) => t.id == taskId);
          if (index != -1) {
            tasks[index] = updatedTask;
            _updateFilteredTasks();
            _updateCategorizedTasks();
          }
        },
        (failure) {
          Get.snackbar(
            'Error',
            'Failed to uncomplete task: ${failure.message}',
          );
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
    }
  }

  /// Stars a task
  Future<void> starTask(String taskId) async {
    try {
      final result = await _taskRepository.starTask(taskId);

      result.fold(
        (updatedTask) {
          final index = tasks.indexWhere((t) => t.id == taskId);
          if (index != -1) {
            tasks[index] = updatedTask;
            _updateFilteredTasks();
            _updateCategorizedTasks();
          }
        },
        (failure) {
          Get.snackbar('Error', 'Failed to star task: ${failure.message}');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
    }
  }

  /// Unstars a task
  Future<void> unstarTask(String taskId) async {
    try {
      final result = await _taskRepository.unstarTask(taskId);

      result.fold(
        (updatedTask) {
          final index = tasks.indexWhere((t) => t.id == taskId);
          if (index != -1) {
            tasks[index] = updatedTask;
            _updateFilteredTasks();
            _updateCategorizedTasks();
          }
        },
        (failure) {
          Get.snackbar('Error', 'Failed to unstar task: ${failure.message}');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
    }
  }

  /// Sets the search query and updates filtered tasks
  void setSearchQuery(String query) {
    searchQuery.value = query;
    _updateFilteredTasks();
  }

  /// Sets the filter status and updates filtered tasks
  void setFilterStatus(TaskStatus? status) {
    filterStatus.value = status;
    _updateFilteredTasks();
  }

  /// Sets the filter priority and updates filtered tasks
  void setFilterPriority(TaskPriority? priority) {
    filterPriority.value = priority;
    _updateFilteredTasks();
  }

  /// Sets the sort field and updates filtered tasks
  void setSortBy(String field) {
    sortBy.value = field;
    _updateFilteredTasks();
  }

  /// Toggles the sort direction and updates filtered tasks
  void toggleSortDirection() {
    sortAscending.value = !sortAscending.value;
    _updateFilteredTasks();
  }

  /// Updates the filtered tasks based on current filters and search
  void _updateFilteredTasks() {
    var filtered = List<TaskEntity>.from(tasks);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ) ||
            (task.description?.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ??
                false);
      }).toList();
    }

    // Apply status filter
    if (filterStatus.value != null) {
      filtered = filtered
          .where((task) => task.status == filterStatus.value)
          .toList();
    }

    // Apply priority filter
    if (filterPriority.value != null) {
      filtered = filtered
          .where((task) => task.priority == filterPriority.value)
          .toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;

      switch (sortBy.value) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'priority':
          comparison = a.priority.index.compareTo(b.priority.index);
          break;
        case 'dueDate':
          if (a.dueDate == null && b.dueDate == null) {
            comparison = 0;
          } else if (a.dueDate == null) {
            comparison = 1;
          } else if (b.dueDate == null) {
            comparison = -1;
          } else {
            comparison = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case 'createdAt':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }

      return sortAscending.value ? comparison : -comparison;
    });

    filteredTasks.value = filtered;
  }

  /// Updates categorized task lists
  void _updateCategorizedTasks() {
    completedTasks.value = tasks
        .where((task) => task.status == TaskStatus.completed)
        .toList();
    pendingTasks.value = tasks
        .where((task) => task.status == TaskStatus.pending)
        .toList();
    overdueTasks.value = tasks.where((task) => task.isOverdue).toList();
    dueTodayTasks.value = tasks.where((task) => task.isDueToday).toList();
    starredTasks.value = tasks.where((task) => task.isStarred).toList();
    archivedTasks.value = tasks.where((task) => task.isArchived).toList();
  }

  /// Loads task statistics
  Future<void> loadTaskStatistics() async {
    try {
      final result = await _taskRepository.getTaskStatistics();

      result.fold(
        (statistics) {
          taskStatistics.value = statistics;
        },
        (failure) {
          // Handle statistics loading failure silently
        },
      );
    } catch (e) {
      // Handle statistics loading error silently
    }
  }

  /// Refreshes all data
  @override
  Future<void> refresh() async {
    await loadTasks();
    await loadTaskStatistics();
  }

  /// Clears all filters and search
  void clearFilters() {
    searchQuery.value = '';
    filterStatus.value = null;
    filterPriority.value = null;
    sortBy.value = 'createdAt';
    sortAscending.value = false;
    _updateFilteredTasks();
  }
}

// TODO: Add more controller methods for advanced features
// TODO: Implement task caching and offline support
// TODO: Add task synchronization with remote storage
// TODO: Implement task analytics and reporting
