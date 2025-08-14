import 'package:hive/hive.dart';
import '../../domain/task_entity.dart';

/// Hive adapter for TaskEntity
class TaskEntityAdapter extends TypeAdapter<TaskEntity> {
  @override
  final int typeId = 0; // Unique type ID

  @override
  TaskEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return TaskEntity(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      priority: fields[3] as TaskPriority,
      status: fields[4] as TaskStatus,
      dueDate: fields[5] as DateTime?,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      completedAt: fields[8] as DateTime?,
      audioPath: fields[9] as String?,
      audioDuration: fields[10] as Duration?,
      tags: (fields[11] as List?)?.cast<String>() ?? [],
      isArchived: fields[12] as bool? ?? false,
      isStarred: fields[13] as bool? ?? false,
      parentTaskId: fields[14] as String?,
      userId: fields[15] as String?,
      localCreatedAt: fields[16] as DateTime?,
      localUpdatedAt: fields[17] as DateTime?,
      syncStatus: fields[18] as String? ?? 'pending',
    );
  }

  @override
  void write(BinaryWriter writer, TaskEntity obj) {
    writer
      ..writeByte(19) // Number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.priority)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.completedAt)
      ..writeByte(9)
      ..write(obj.audioPath)
      ..writeByte(10)
      ..write(obj.audioDuration)
      ..writeByte(11)
      ..write(obj.tags)
      ..writeByte(12)
      ..write(obj.isArchived)
      ..writeByte(13)
      ..write(obj.isStarred)
      ..writeByte(14)
      ..write(obj.parentTaskId)
      ..writeByte(15)
      ..write(obj.userId)
      ..writeByte(16)
      ..write(obj.localCreatedAt)
      ..writeByte(17)
      ..write(obj.localUpdatedAt)
      ..writeByte(18)
      ..write(obj.syncStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Hive adapter for TaskPriority enum
class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 1;

  @override
  TaskPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriority.low;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.high;
      default:
        return TaskPriority.medium;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    switch (obj) {
      case TaskPriority.low:
        writer.writeByte(0);
        break;
      case TaskPriority.medium:
        writer.writeByte(1);
        break;
      case TaskPriority.high:
        writer.writeByte(2);
        break;
    }
  }
}

/// Hive adapter for TaskStatus enum
class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 2;

  @override
  TaskStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskStatus.pending;
      case 1:
        return TaskStatus.inProgress;
      case 2:
        return TaskStatus.completed;
      case 3:
        return TaskStatus.cancelled;
      default:
        return TaskStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    switch (obj) {
      case TaskStatus.pending:
        writer.writeByte(0);
        break;
      case TaskStatus.inProgress:
        writer.writeByte(1);
        break;
      case TaskStatus.completed:
        writer.writeByte(2);
        break;
      case TaskStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }
}

/// Hive adapter for Duration
class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 3;

  @override
  Duration read(BinaryReader reader) {
    return Duration(microseconds: reader.readInt());
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.writeInt(obj.inMicroseconds);
  }
}
