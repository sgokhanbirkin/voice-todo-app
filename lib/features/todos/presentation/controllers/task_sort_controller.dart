import 'package:get/get.dart';
import '../../domain/task_entity.dart';

/// Sort order options for tasks
enum SortOrder { dateAscending, dateDescending, priority, alphabetical }

/// Controller responsible for managing task sorting operations
class TaskSortController extends GetxController {
  /// Current sort field
  final RxString sortBy = 'createdAt'.obs;

  /// Current sort direction
  final RxBool sortAscending = false.obs;

  /// Current sort order
  final Rx<SortOrder> sortOrder = SortOrder.dateDescending.obs;

  /// Callback function to update sorted tasks
  Function()? onSortChanged;

  TaskSortController({this.onSortChanged});

  /// Sets the sort field and triggers sort update
  void setSortBy(String field) {
    sortBy.value = field;
    _notifySortChanged();
  }

  /// Toggles the sort direction and triggers sort update
  void toggleSortDirection() {
    sortAscending.value = !sortAscending.value;
    _notifySortChanged();
  }

  /// Set sort order and triggers sort update
  void setSortOrder(SortOrder order) {
    sortOrder.value = order;
    _notifySortChanged();
  }

  /// Applies sorting to a list of tasks
  List<TaskEntity> applySorting(List<TaskEntity> tasks) {
    final sorted = List<TaskEntity>.from(tasks);

    sorted.sort((a, b) {
      int comparison = 0;

      switch (sortOrder.value) {
        case SortOrder.dateAscending:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case SortOrder.dateDescending:
          comparison = b.createdAt.compareTo(a.createdAt);
          break;
        case SortOrder.priority:
          comparison = b.priority.index.compareTo(a.priority.index);
          break;
        case SortOrder.alphabetical:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
      }

      return comparison;
    });

    return sorted;
  }

  /// Gets current sort description for display
  String get sortDescription {
    switch (sortOrder.value) {
      case SortOrder.dateAscending:
        return 'Date (Oldest first)';
      case SortOrder.dateDescending:
        return 'Date (Newest first)';
      case SortOrder.priority:
        return 'Priority (High to Low)';
      case SortOrder.alphabetical:
        return 'Alphabetical (A to Z)';
    }
  }

  /// Gets sort icon for UI
  String get sortIcon {
    switch (sortOrder.value) {
      case SortOrder.dateAscending:
        return '↑';
      case SortOrder.dateDescending:
        return '↓';
      case SortOrder.priority:
        return '⚡';
      case SortOrder.alphabetical:
        return '🔤';
    }
  }

  /// Resets sorting to default state
  void resetToDefaults() {
    sortBy.value = 'createdAt';
    sortAscending.value = false;
    sortOrder.value = SortOrder.dateDescending;
    _notifySortChanged();
  }

  /// Gets next sort order in cycle
  SortOrder get nextSortOrder {
    switch (sortOrder.value) {
      case SortOrder.dateDescending:
        return SortOrder.dateAscending;
      case SortOrder.dateAscending:
        return SortOrder.priority;
      case SortOrder.priority:
        return SortOrder.alphabetical;
      case SortOrder.alphabetical:
        return SortOrder.dateDescending;
    }
  }

  /// Cycles to next sort order
  void cycleSortOrder() {
    setSortOrder(nextSortOrder);
  }

  /// Checks if current sort is date-based
  bool get isDateSort => 
      sortOrder.value == SortOrder.dateAscending || 
      sortOrder.value == SortOrder.dateDescending;

  /// Checks if current sort is priority-based
  bool get isPrioritySort => sortOrder.value == SortOrder.priority;

  /// Checks if current sort is alphabetical
  bool get isAlphabeticalSort => sortOrder.value == SortOrder.alphabetical;

  /// Notifies that sorting has changed
  void _notifySortChanged() {
    if (onSortChanged != null) {
      onSortChanged!();
    }
  }
}
