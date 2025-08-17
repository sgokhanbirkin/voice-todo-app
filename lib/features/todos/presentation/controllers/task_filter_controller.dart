import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../domain/task_entity.dart';

/// Controller responsible for managing task filtering operations
class TaskFilterController extends GetxController {
  /// Current search query
  final RxString searchQuery = ''.obs;

  /// Current filter status
  final Rx<TaskStatus?> filterStatus = Rx<TaskStatus?>(null);

  /// Current filter priority
  final Rx<TaskPriority?> filterPriority = Rx<TaskPriority?>(null);

  /// Audio filter
  final RxBool audioFilter = false.obs;

  /// Completed filter
  final RxBool completedFilter = false.obs;

  /// Pending filter
  final RxBool pendingFilter = false.obs;

  /// Overdue filter
  final RxBool overdueFilter = false.obs;

  /// Whether pending tasks section is expanded
  final RxBool isPendingExpanded = true.obs;

  /// Whether completed tasks section is expanded
  final RxBool isCompletedExpanded = true.obs;

  /// Callback function to update filtered tasks
  Function()? onFiltersChanged;

  TaskFilterController({this.onFiltersChanged});

  /// Sets the search query and triggers filter update
  void setSearchQuery(String query) {
    searchQuery.value = query;
    _notifyFiltersChanged();
  }

  /// Sets the filter status and triggers filter update
  void setFilterStatus(TaskStatus? status) {
    filterStatus.value = status;
    _notifyFiltersChanged();
  }

  /// Sets the filter priority and triggers filter update
  void setFilterPriority(TaskPriority? priority) {
    debugPrint('🔥 Filter changing from ${filterPriority.value} to $priority');
    filterPriority.value = priority;
    _notifyFiltersChanged();
    debugPrint('🔥 After filter: Priority filter updated');
  }

  /// Toggles pending tasks section expansion
  void togglePendingExpansion() {
    isPendingExpanded.value = !isPendingExpanded.value;
  }

  /// Toggles completed tasks section expansion
  void toggleCompletedExpansion() {
    isCompletedExpanded.value = !isCompletedExpanded.value;
  }

  /// Toggle audio filter
  void toggleAudioFilter() {
    audioFilter.value = !audioFilter.value;
    _notifyFiltersChanged();
  }

  /// Toggle completed filter
  void toggleCompletedFilter() {
    completedFilter.value = !completedFilter.value;
    _notifyFiltersChanged();
  }

  /// Toggle pending filter
  void togglePendingFilter() {
    pendingFilter.value = !pendingFilter.value;
    _notifyFiltersChanged();
  }

  /// Toggle overdue filter
  void toggleOverdueFilter() {
    overdueFilter.value = !overdueFilter.value;
    _notifyFiltersChanged();
  }

  /// Clears all filters and search
  void clearFilters() {
    searchQuery.value = '';
    filterStatus.value = null;
    filterPriority.value = null;
    _notifyFiltersChanged();
  }

  /// Clears all advanced filters (audio, completed, pending, overdue)
  void clearAllFilters() {
    clearFilters();
    audioFilter.value = false;
    completedFilter.value = false;
    pendingFilter.value = false;
    overdueFilter.value = false;
    _notifyFiltersChanged();
  }

  /// Applies filters to a list of tasks
  List<TaskEntity> applyFilters(List<TaskEntity> tasks) {
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

    // Apply audio filter
    if (audioFilter.value) {
      filtered = filtered
          .where((task) => task.audioPath != null && task.audioPath!.isNotEmpty)
          .toList();
    }

    // Apply completed filter
    if (completedFilter.value) {
      filtered = filtered
          .where((task) => task.status == TaskStatus.completed)
          .toList();
    }

    // Apply pending filter
    if (pendingFilter.value) {
      filtered = filtered
          .where((task) => task.status == TaskStatus.pending)
          .toList();
    }

    // Apply overdue filter
    if (overdueFilter.value) {
      filtered = filtered
          .where(
            (task) =>
                task.dueDate != null && task.dueDate!.isBefore(DateTime.now()),
          )
          .toList();
    }

    return filtered;
  }

  /// Checks if any filter is active
  bool get hasActiveFilters {
    return searchQuery.value.isNotEmpty ||
        filterStatus.value != null ||
        filterPriority.value != null ||
        audioFilter.value ||
        completedFilter.value ||
        pendingFilter.value ||
        overdueFilter.value;
  }

  /// Gets active filter count
  int get activeFilterCount {
    int count = 0;
    if (searchQuery.value.isNotEmpty) count++;
    if (filterStatus.value != null) count++;
    if (filterPriority.value != null) count++;
    if (audioFilter.value) count++;
    if (completedFilter.value) count++;
    if (pendingFilter.value) count++;
    if (overdueFilter.value) count++;
    return count;
  }

  /// Gets filter summary for display
  String get filterSummary {
    if (!hasActiveFilters) return 'No filters applied';
    
    final filters = <String>[];
    if (searchQuery.value.isNotEmpty) filters.add('Search: "${searchQuery.value}"');
    if (filterStatus.value != null) filters.add('Status: ${filterStatus.value!.name}');
    if (filterPriority.value != null) filters.add('Priority: ${filterPriority.value!.name}');
    if (audioFilter.value) filters.add('Audio only');
    if (completedFilter.value) filters.add('Completed only');
    if (pendingFilter.value) filters.add('Pending only');
    if (overdueFilter.value) filters.add('Overdue only');
    
    return filters.join(', ');
  }

  /// Notifies that filters have changed
  void _notifyFiltersChanged() {
    if (onFiltersChanged != null) {
      onFiltersChanged!();
    }
  }

  /// Resets all filters to default state
  void resetToDefaults() {
    searchQuery.value = '';
    filterStatus.value = null;
    filterPriority.value = null;
    audioFilter.value = false;
    completedFilter.value = false;
    pendingFilter.value = false;
    overdueFilter.value = false;
    isPendingExpanded.value = true;
    isCompletedExpanded.value = true;
    _notifyFiltersChanged();
  }
}
