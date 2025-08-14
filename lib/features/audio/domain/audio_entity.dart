/// Audio file entity for storing audio metadata
class AudioEntity {
  /// Unique identifier for the audio file
  final String id;

  /// Associated task ID
  final String taskId;

  /// Original file name
  final String fileName;

  /// Local file path
  final String localPath;

  /// Remote file path (Supabase Storage)
  final String? remotePath;

  /// File size in bytes
  final int fileSize;

  /// Audio duration
  final Duration duration;

  /// Audio format (mp3, wav, etc.)
  final String format;

  /// Recording quality/bitrate
  final int? bitrate;

  /// Sample rate
  final int? sampleRate;

  /// Date when audio was recorded
  final DateTime recordedAt;

  /// Date when audio was created in local storage
  final DateTime createdAt;

  /// Date when audio was last updated
  final DateTime updatedAt;

  /// Sync status (pending, synced, failed)
  final String syncStatus;

  /// Whether audio is uploaded to remote storage
  final bool isUploaded;

  /// Upload progress (0.0 to 1.0)
  final double uploadProgress;

  const AudioEntity({
    required this.id,
    required this.taskId,
    required this.fileName,
    required this.localPath,
    this.remotePath,
    required this.fileSize,
    required this.duration,
    required this.format,
    this.bitrate,
    this.sampleRate,
    required this.recordedAt,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
    this.isUploaded = false,
    this.uploadProgress = 0.0,
  });

  /// Creates a copy of this audio with updated values
  AudioEntity copyWith({
    String? id,
    String? taskId,
    String? fileName,
    String? localPath,
    String? remotePath,
    int? fileSize,
    Duration? duration,
    String? format,
    int? bitrate,
    int? sampleRate,
    DateTime? recordedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    bool? isUploaded,
    double? uploadProgress,
  }) {
    return AudioEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      fileName: fileName ?? this.fileName,
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      format: format ?? this.format,
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  /// Creates an audio from JSON data
  factory AudioEntity.fromJson(Map<String, dynamic> json) {
    return AudioEntity(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      fileName: json['fileName'] as String,
      localPath: json['localPath'] as String,
      remotePath: json['remotePath'] as String?,
      fileSize: json['fileSize'] as int,
      duration: Duration(microseconds: json['duration'] as int),
      format: json['format'] as String,
      bitrate: json['bitrate'] as int?,
      sampleRate: json['sampleRate'] as int?,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'pending',
      isUploaded: json['isUploaded'] as bool? ?? false,
      uploadProgress: (json['uploadProgress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts the audio to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'fileName': fileName,
      'localPath': localPath,
      'remotePath': remotePath,
      'fileSize': fileSize,
      'duration': duration.inMicroseconds,
      'format': format,
      'bitrate': bitrate,
      'sampleRate': sampleRate,
      'recordedAt': recordedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus,
      'isUploaded': isUploaded,
      'uploadProgress': uploadProgress,
    };
  }

  /// Gets file size in human readable format
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// Gets duration in human readable format
  String get durationFormatted {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Checks if audio file exists locally
  bool get existsLocally {
    // TODO: Implement file existence check
    return localPath.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AudioEntity(id: $id, taskId: $taskId, fileName: $fileName, duration: $durationFormatted)';
  }
}
