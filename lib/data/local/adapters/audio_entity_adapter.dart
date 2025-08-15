import 'package:hive/hive.dart';
import '../../../features/audio/domain/audio_entity.dart';

/// Hive adapter for AudioEntity
class AudioEntityAdapter extends TypeAdapter<AudioEntity> {
  @override
  final int typeId = 2; // Unique type ID for AudioEntity

  @override
  AudioEntity read(BinaryReader reader) {
    return AudioEntity(
      id: reader.readString(),
      taskId: reader.readString(),
      fileName: reader.readString(),
      localPath: reader.readString(),
      remotePath: reader.readString(),
      fileSize: reader.readInt(),
      duration: Duration(microseconds: reader.readInt()),
      format: reader.readString(),
      bitrate: reader.readInt(),
      sampleRate: reader.readInt(),
      recordedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      syncStatus: reader.readString(),
      isUploaded: reader.readBool(),
      uploadProgress: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, AudioEntity obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.taskId);
    writer.writeString(obj.fileName);
    writer.writeString(obj.localPath);
    writer.writeString(obj.remotePath ?? '');
    writer.writeInt(obj.fileSize);
    writer.writeInt(obj.duration.inMicroseconds);
    writer.writeString(obj.format);
    writer.writeInt(obj.bitrate ?? 0);
    writer.writeInt(obj.sampleRate ?? 0);
    writer.writeInt(obj.recordedAt.millisecondsSinceEpoch);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);
    writer.writeString(obj.syncStatus);
    writer.writeBool(obj.isUploaded);
    writer.writeDouble(obj.uploadProgress);
  }
}
