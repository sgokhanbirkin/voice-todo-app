/// Task priority levels
enum TaskPriority {
  /// Low priority
  low,

  /// Medium priority
  medium,

  /// High priority
  high,
}

/// Task status
enum TaskStatus {
  /// Task is pending
  pending,

  /// Task is in progress
  inProgress,

  /// Task is completed
  completed,

  /// Task is cancelled
  cancelled,
}

/// Task entity representing a single task
class TaskEntity {
  /// Unique identifier for the task
  final String id;

  /// Task title
  final String title;

  /// Task description (optional)
  final String? description;

  /// Task priority
  final TaskPriority priority;

  /// Task status
  final TaskStatus status;

  /// Due date for the task (optional)
  final DateTime? dueDate;

  /// Date when the task was created
  final DateTime createdAt;

  /// Date when the task was last modified
  final DateTime updatedAt;

  /// Date when the task was completed (optional)
  final DateTime? completedAt;

  /// Audio file path for voice recording (optional)
  final String? audioPath;

  /// Audio duration in seconds (optional)
  final int? audioDuration;

  /// Tags for categorizing the task (optional)
  final List<String> tags;

  /// Whether the task is archived
  final bool isArchived;

  /// Whether the task is starred/favorited
  final bool isStarred;

  /// Subtasks (optional)
  final List<TaskEntity> subtasks;

  /// Parent task ID (optional, for subtasks)
  final String? parentTaskId;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.audioPath,
    this.audioDuration,
    this.tags = const [],
    this.isArchived = false,
    this.isStarred = false,
    this.subtasks = const [],
    this.parentTaskId,
  });

  /// Creates a copy of this task with updated values
  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? audioPath,
    int? audioDuration,
    List<String>? tags,
    bool? isArchived,
    bool? isStarred,
    List<TaskEntity>? subtasks,
    String? parentTaskId,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      audioPath: audioPath ?? this.audioPath,
      audioDuration: audioDuration ?? this.audioDuration,
      tags: tags ?? this.tags,
      isArchived: isArchived ?? this.isArchived,
      isStarred: isStarred ?? this.isStarred,
      subtasks: subtasks ?? this.subtasks,
      parentTaskId: parentTaskId ?? this.parentTaskId,
    );
  }

  /// Creates a task from JSON data
  factory TaskEntity.fromJson(Map<String, dynamic> json) {
    return TaskEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      audioPath: json['audioPath'] as String?,
      audioDuration: json['audioDuration'] as int?,
      tags: List<String>.from(json['tags'] ?? []),
      isArchived: json['isArchived'] as bool? ?? false,
      isStarred: json['isStarred'] as bool? ?? false,
      subtasks:
          (json['subtasks'] as List<dynamic>?)
              ?.map((e) => TaskEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      parentTaskId: json['parentTaskId'] as String?,
    );
  }

  /// Converts the task to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'audioPath': audioPath,
      'audioDuration': audioDuration,
      'tags': tags,
      'isArchived': isArchived,
      'isStarred': isStarred,
      'subtasks': subtasks.map((e) => e.toJson()).toList(),
      'parentTaskId': parentTaskId,
    };
  }

  /// Checks if the task is overdue
  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) {
      return false;
    }
    return DateTime.now().isAfter(dueDate!);
  }

  /// Checks if the task is due today
  bool get isDueToday {
    if (dueDate == null) {
      return false;
    }
    final now = DateTime.now();
    final due = dueDate!;
    return now.year == due.year && now.month == due.month && now.day == due.day;
  }

  /// Checks if the task is due soon (within 3 days)
  bool get isDueSoon {
    if (dueDate == null) {
      return false;
    }
    final now = DateTime.now();
    final due = dueDate!;
    final difference = due.difference(now).inDays;
    return difference >= 0 && difference <= 3;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TaskEntity(id: $id, title: $title, status: $status, priority: $priority)';
  }
}

// TODO: Add task validation logic
// TODO: Implement task comparison methods
// TODO: Add task statistics and analytics
// TODO: Implement task recurrence patterns
