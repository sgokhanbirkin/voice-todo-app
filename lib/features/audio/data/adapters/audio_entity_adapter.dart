import 'package:hive/hive.dart';
import '../../domain/audio_entity.dart';

/// Hive adapter for AudioEntity
class AudioEntityAdapter extends TypeAdapter<AudioEntity> {
  @override
  final int typeId = 4; // Unique type ID

  @override
  AudioEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return AudioEntity(
      id: fields[0] as String,
      taskId: fields[1] as String,
      fileName: fields[2] as String,
      localPath: fields[3] as String,
      remotePath: fields[4] as String?,
      fileSize: fields[5] as int,
      duration: fields[6] as Duration,
      format: fields[7] as String,
      bitrate: fields[8] as int?,
      sampleRate: fields[9] as int?,
      recordedAt: fields[10] as DateTime,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      syncStatus: fields[13] as String? ?? 'pending',
      isUploaded: fields[14] as bool? ?? false,
      uploadProgress: (fields[15] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  void write(BinaryWriter writer, AudioEntity obj) {
    writer
      ..writeByte(16) // Number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.localPath)
      ..writeByte(4)
      ..write(obj.remotePath)
      ..writeByte(5)
      ..write(obj.fileSize)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.format)
      ..writeByte(8)
      ..write(obj.bitrate)
      ..writeByte(9)
      ..write(obj.sampleRate)
      ..writeByte(10)
      ..write(obj.recordedAt)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.syncStatus)
      ..writeByte(14)
      ..write(obj.isUploaded)
      ..writeByte(15)
      ..write(obj.uploadProgress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
