import 'package:get/get.dart';
import '../../domain/task_entity.dart';
import '../../domain/i_task_repository.dart';

/// Controller responsible for managing task list operations
class TaskListController extends GetxController {
  final ITaskRepository _taskRepository;

  /// Observable list of all tasks
  final RxList<TaskEntity> tasks = <TaskEntity>[].obs;

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

  /// Whether tasks are currently loading
  final RxBool isLoading = false.obs;

  /// Whether there was an error loading tasks
  final RxBool hasError = false.obs;

  /// Error message if any
  final RxString errorMessage = ''.obs;

  /// Selected task for editing
  final Rx<TaskEntity?> selectedTask = Rx<TaskEntity?>(null);

  TaskListController(this._taskRepository);

  @override
  void onInit() {
    super.onInit();
    loadTasks();
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

  /// Refreshes all data
  @override
  Future<void> refresh() async {
    await loadTasks();
  }

  /// Sets the selected task
  void setSelectedTask(TaskEntity? task) {
    selectedTask.value = task;
  }

  /// Clears the selected task
  void clearSelectedTask() {
    selectedTask.value = null;
  }

  /// Gets task by ID
  TaskEntity? getTaskById(String id) {
    try {
      return tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Gets tasks count by status
  int getTasksCountByStatus(TaskStatus status) {
    return tasks.where((task) => task.status == status).length;
  }

  /// Gets tasks count by priority
  int getTasksCountByPriority(TaskPriority priority) {
    return tasks.where((task) => task.priority == priority).length;
  }

  /// Gets total tasks count
  int get totalTasksCount => tasks.length;

  /// Gets completed tasks count
  int get completedTasksCount => completedTasks.length;

  /// Gets pending tasks count
  int get pendingTasksCount => pendingTasks.length;

  /// Gets overdue tasks count
  int get overdueTasksCount => overdueTasks.length;

  /// Gets due today tasks count
  int get dueTodayTasksCount => dueTodayTasks.length;

  /// Gets starred tasks count
  int get starredTasksCount => starredTasks.length;

  /// Gets archived tasks count
  int get archivedTasksCount => archivedTasks.length;
}
