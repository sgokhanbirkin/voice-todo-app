import 'package:get/get.dart';
import '../../domain/task_entity.dart';
import '../../domain/i_task_repository.dart';
import 'task_list_controller.dart';
import 'task_filter_controller.dart';
import 'task_sort_controller.dart';
import 'task_statistics_controller.dart';
import 'task_crud_controller.dart';

// Re-export SortOrder for convenience
export 'task_sort_controller.dart' show SortOrder;

/// Main task controller that orchestrates other specialized controllers
/// This controller follows the Facade pattern to provide a unified interface
class TaskController extends GetxController {
  final ITaskRepository _taskRepository;

  // Specialized controllers
  late final TaskListController _listController;
  late final TaskFilterController _filterController;
  late final TaskSortController _sortController;
  late final TaskStatisticsController _statisticsController;
  late final TaskCRUDController _crudController;

  TaskController(this._taskRepository);

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  /// Initialize all specialized controllers
  void _initializeControllers() {
    // Initialize list controller
    _listController = TaskListController(_taskRepository);

    // Initialize filter controller with callback
    _filterController = TaskFilterController(
      onFiltersChanged: _updateFilteredTasks,
    );

    // Initialize sort controller with callback
    _sortController = TaskSortController(onSortChanged: _updateFilteredTasks);

    // Initialize statistics controller
    _statisticsController = TaskStatisticsController(_taskRepository);

    // Initialize CRUD controller with callback
    _crudController = TaskCRUDController(_taskRepository);
    _crudController.onTasksChanged = _onTasksChanged;

    // Load initial data
    _listController.loadTasks();
    _statisticsController.loadTaskStatistics();
  }

  // ===== DELEGATED PROPERTIES =====

  /// Observable list of all tasks
  RxList<TaskEntity> get tasks => _listController.tasks;

  /// Observable list of filtered tasks
  final RxList<TaskEntity> filteredTasks = <TaskEntity>[].obs;

  /// Observable list of completed tasks
  RxList<TaskEntity> get completedTasks => _listController.completedTasks;

  /// Observable list of pending tasks
  RxList<TaskEntity> get pendingTasks => _listController.pendingTasks;

  /// Observable list of overdue tasks
  RxList<TaskEntity> get overdueTasks => _listController.overdueTasks;

  /// Observable list of tasks due today
  RxList<TaskEntity> get dueTodayTasks => _listController.dueTodayTasks;

  /// Observable list of starred tasks
  RxList<TaskEntity> get starredTasks => _listController.starredTasks;

  /// Observable list of archived tasks
  RxList<TaskEntity> get archivedTasks => _listController.archivedTasks;

  /// Current search query
  RxString get searchQuery => _filterController.searchQuery;

  /// Current filter status
  Rx<TaskStatus?> get filterStatus => _filterController.filterStatus;

  /// Current filter priority
  Rx<TaskPriority?> get filterPriority => _filterController.filterPriority;

  /// Audio filter
  RxBool get audioFilter => _filterController.audioFilter;

  /// Completed filter
  RxBool get completedFilter => _filterController.completedFilter;

  /// Pending filter
  RxBool get pendingFilter => _filterController.pendingFilter;

  /// Overdue filter
  RxBool get overdueFilter => _filterController.overdueFilter;

  /// Whether pending tasks section is expanded
  RxBool get isPendingExpanded => _filterController.isPendingExpanded;

  /// Whether completed tasks section is expanded
  RxBool get isCompletedExpanded => _filterController.isCompletedExpanded;

  /// Current sort field
  RxString get sortBy => _sortController.sortBy;

  /// Current sort direction
  RxBool get sortAscending => _sortController.sortAscending;

  /// Current sort order
  Rx<SortOrder> get sortOrder => _sortController.sortOrder;

  /// Whether tasks are currently loading
  RxBool get isLoading => _listController.isLoading;

  /// Whether there was an error loading tasks
  RxBool get hasError => _listController.hasError;

  /// Error message if any
  RxString get errorMessage => _listController.errorMessage;

  /// Selected task for editing
  Rx<TaskEntity?> get selectedTask => _listController.selectedTask;

  /// Task statistics
  Rx<TaskStatistics?> get taskStatistics =>
      _statisticsController.taskStatistics;

  // ===== DELEGATED METHODS =====

  /// Loads all tasks from the repository
  Future<void> loadTasks() async {
    await _listController.loadTasks();
  }

  /// Loads task statistics
  Future<void> loadTaskStatistics() async {
    await _statisticsController.loadTaskStatistics();
  }

  /// Refreshes all data
  @override
  Future<void> refresh() async {
    await _listController.refresh();
    await _statisticsController.refresh();
  }

  /// Sets the search query and updates filtered tasks
  void setSearchQuery(String query) {
    _filterController.setSearchQuery(query);
  }

  /// Sets the filter status and updates filtered tasks
  void setFilterStatus(TaskStatus? status) {
    _filterController.setFilterStatus(status);
  }

  /// Sets the filter priority and updates filtered tasks
  void setFilterPriority(TaskPriority? priority) {
    _filterController.setFilterPriority(priority);
  }

  /// Set sort order
  void setSortOrder(SortOrder order) {
    _sortController.setSortOrder(order);
  }

  /// Sets the sort field and updates filtered tasks
  void setSortBy(String field) {
    _sortController.setSortBy(field);
  }

  /// Toggles the sort direction and updates filtered tasks
  void toggleSortDirection() {
    _sortController.toggleSortDirection();
  }

  /// Toggles pending tasks section expansion
  void togglePendingExpansion() {
    _filterController.togglePendingExpansion();
  }

  /// Toggles completed tasks section expansion
  void toggleCompletedExpansion() {
    _filterController.toggleCompletedExpansion();
  }

  /// Clears all filters and search
  void clearFilters() {
    _filterController.clearFilters();
  }

  /// Clears all advanced filters
  void clearAllFilters() {
    _filterController.clearAllFilters();
  }

  /// Toggle audio filter
  void toggleAudioFilter() {
    _filterController.toggleAudioFilter();
  }

  /// Toggle completed filter
  void toggleCompletedFilter() {
    _filterController.toggleCompletedFilter();
  }

  /// Toggle pending filter
  void togglePendingFilter() {
    _filterController.togglePendingFilter();
  }

  /// Toggle overdue filter
  void toggleOverdueFilter() {
    _filterController.toggleOverdueFilter();
  }

  /// Creates a new task with validation
  Future<void> createTask(TaskEntity task) async {
    final result = await _crudController.createTask(task);
    if (result.isSuccess) {
      await _listController.loadTasks();
      await _statisticsController.loadTaskStatistics();
    }
  }

  /// Updates an existing task
  Future<void> updateTask(TaskEntity task) async {
    final result = await _crudController.updateTask(task);
    if (result.isSuccess) {
      await _listController.loadTasks();
      await _statisticsController.loadTaskStatistics();
    }
  }

  /// Deletes a task
  Future<void> deleteTask(String taskId) async {
    final result = await _crudController.deleteTask(taskId);
    if (result.isSuccess) {
      await _listController.loadTasks();
      await _statisticsController.loadTaskStatistics();
    }
  }

  /// Completes a task
  Future<void> completeTask(String taskId) async {
    final result = await _crudController.completeTask(taskId);
    if (result.isSuccess) {
      await _listController.loadTasks();
      await _statisticsController.loadTaskStatistics();
    }
  }

  /// Uncompletes a task
  Future<void> uncompleteTask(String taskId) async {
    final result = await _crudController.uncompleteTask(taskId);
    if (result.isSuccess) {
      await _listController.loadTasks();
      await _statisticsController.loadTaskStatistics();
    }
  }

  /// Stars a task
  Future<void> starTask(String taskId) async {
    final result = await _crudController.starTask(taskId);
    if (result.isSuccess) {
      await _listController.loadTasks();
    }
  }

  /// Unstars a task
  Future<void> unstarTask(String taskId) async {
    final result = await _crudController.unstarTask(taskId);
    if (result.isSuccess) {
      await _listController.loadTasks();
    }
  }

  /// Archives a task
  Future<void> archiveTask(String taskId) async {
    final result = await _crudController.archiveTask(taskId);
    if (result.isSuccess) {
      await _listController.loadTasks();
      await _statisticsController.loadTaskStatistics();
    }
  }

  /// Unarchives a task
  Future<void> unarchiveTask(String taskId) async {
    final result = await _crudController.unarchiveTask(taskId);
    if (result.isSuccess) {
      await _listController.loadTasks();
      await _statisticsController.loadTaskStatistics();
    }
  }

  /// Adds audio to a task
  Future<void> addAudioToTask(String id, String audioPath, int duration) async {
    final result = await _crudController.addAudioToTask(
      id,
      audioPath,
      duration,
    );
    if (result.isSuccess) {
      await _listController.loadTasks();
    }
  }

  /// Removes audio from a task
  Future<void> removeAudioFromTask(String id) async {
    final result = await _crudController.removeAudioFromTask(id);
    if (result.isSuccess) {
      await _listController.loadTasks();
    }
  }

  /// Sets the selected task
  void setSelectedTask(TaskEntity? task) {
    _listController.setSelectedTask(task);
  }

  /// Clears the selected task
  void clearSelectedTask() {
    _listController.clearSelectedTask();
  }

  /// Gets task by ID
  TaskEntity? getTaskById(String id) {
    return _listController.getTaskById(id);
  }

  /// Gets tasks count by status
  int getTasksCountByStatus(TaskStatus status) {
    return _listController.getTasksCountByStatus(status);
  }

  /// Gets tasks count by priority
  int getTasksCountByPriority(TaskPriority priority) {
    return _listController.getTasksCountByPriority(priority);
  }

  /// Gets total tasks count
  int get totalTasksCount => _listController.totalTasksCount;

  /// Gets completed tasks count
  int get completedTasksCount => _listController.completedTasksCount;

  /// Gets pending tasks count
  int get pendingTasksCount => _listController.pendingTasksCount;

  /// Gets overdue tasks count
  int get overdueTasksCount => _listController.overdueTasksCount;

  /// Gets due today tasks count
  int get dueTodayTasksCount => _listController.dueTodayTasksCount;

  /// Gets starred tasks count
  int get starredTasksCount => _listController.starredTasksCount;

  /// Gets archived tasks count
  int get archivedTasksCount => _listController.archivedTasksCount;

  /// Gets completion percentage
  double get completionPercentage => _statisticsController.completionPercentage;

  /// Gets overdue percentage
  double get overduePercentage => _statisticsController.overduePercentage;

  /// Gets productivity score
  int get productivityScore => _statisticsController.productivityScore;

  /// Gets productivity level
  String get productivityLevel => _statisticsController.productivityLevel;

  /// Gets productivity emoji
  String get productivityEmoji => _statisticsController.productivityEmoji;

  /// Gets statistics summary
  String get statisticsSummary => _statisticsController.statisticsSummary;

  /// Gets filter summary
  String get filterSummary => _filterController.filterSummary;

  /// Gets active filter count
  int get activeFilterCount => _filterController.activeFilterCount;

  /// Gets sort description
  String get sortDescription => _sortController.sortDescription;

  /// Gets sort icon
  String get sortIcon => _sortController.sortIcon;

  /// Checks if any filter is active
  bool get hasActiveFilters => _filterController.hasActiveFilters;

  // ===== VALIDATION METHODS =====

  /// Validates task title
  String? validateTaskTitle(String? title) {
    return _crudController.validateTaskTitle(title);
  }

  /// Validates task description
  String? validateTaskDescription(String? description) {
    return _crudController.validateTaskDescription(description);
  }

  /// Checks if statistics are available
  bool get hasStatistics => _statisticsController.hasStatistics;

  // ===== PRIVATE METHODS =====

  /// Updates the filtered tasks based on current filters and search
  void _updateFilteredTasks() {
    // Apply filters first
    var filtered = _filterController.applyFilters(tasks);

    // Apply sorting
    filtered = _sortController.applySorting(filtered);

    // Update filtered tasks
    filteredTasks.assignAll(filtered);
  }

  /// Called when tasks change (from CRUD operations)
  void _onTasksChanged() {
    _updateFilteredTasks();
  }

  @override
  void onClose() {
    // Clean up controllers if needed
    super.onClose();
  }
}
