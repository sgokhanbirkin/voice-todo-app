import 'package:uuid/uuid.dart';

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
  final Duration? audioDuration;

  /// User ID who owns this task
  final String? userId;

  /// Local creation timestamp for sync
  final DateTime? localCreatedAt;

  /// Local update timestamp for sync
  final DateTime? localUpdatedAt;

  /// Sync status (pending, synced, failed)
  final String? syncStatus;

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
    this.userId,
    this.localCreatedAt,
    this.localUpdatedAt,
    this.syncStatus,
  });

  /// Factory constructor to create a new task with generated UUID
  factory TaskEntity.create({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    TaskStatus status = TaskStatus.pending,
    DateTime? dueDate,
    String? audioPath,
    Duration? audioDuration,
    List<String> tags = const [],
    String? parentTaskId,
    String? userId,
  }) {
    final now = DateTime.now();
    final uuid = const Uuid().v4();

    return TaskEntity(
      id: uuid,
      title: title,
      description: description,
      priority: priority,
      status: status,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
      audioPath: audioPath,
      audioDuration: audioDuration,
      tags: tags,
      parentTaskId: parentTaskId,
      userId: userId,
      localCreatedAt: now,
      localUpdatedAt: now,
      syncStatus: 'pending',
    );
  }

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
    Duration? audioDuration,
    List<String>? tags,
    bool? isArchived,
    bool? isStarred,
    List<TaskEntity>? subtasks,
    String? parentTaskId,
    String? userId,
    DateTime? localCreatedAt,
    DateTime? localUpdatedAt,
    String? syncStatus,
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
      userId: userId ?? this.userId,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      audioPath: json['audio_path'] as String?,
      audioDuration: json['audio_duration'] != null
          ? Duration(seconds: json['audio_duration'] as int)
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      isArchived: json['is_archived'] as bool? ?? false,
      isStarred: json['is_starred'] as bool? ?? false,
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((e) => TaskEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      parentTaskId: json['parent_task_id'] as String?,
      userId: json['user_id'] as String?,
      localCreatedAt: json['local_created_at'] != null
          ? DateTime.parse(json['local_created_at'] as String)
          : null,
      localUpdatedAt: json['local_updated_at'] != null
          ? DateTime.parse(json['local_created_at'] as String)
          : null,
      syncStatus: json['sync_status'] as String?,
    );
  }

  /// Converts the task to JSON data for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'audio_path': audioPath,
      'audio_duration': audioDuration?.inSeconds,
      'audio_file_name': audioPath?.split('/').last,
      'tags': tags,
      'is_archived': isArchived,
      'is_starred': isStarred,
      'parent_task_id': parentTaskId,
      'user_id': userId,
      'local_created_at': localCreatedAt?.toIso8601String(),
      'local_updated_at': localUpdatedAt?.toIso8601String(),
      'sync_status': syncStatus,
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
