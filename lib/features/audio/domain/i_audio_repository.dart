import '../../../core/result.dart';
import 'audio_entity.dart';

/// Audio repository interface for managing audio files and metadata
abstract class IAudioRepository {
  /// Initialize the repository
  Future<void> initialize();

  /// Save audio metadata to local storage
  Future<AppResult<AudioEntity>> saveAudioMetadata(AudioEntity audio);

  /// Get audio metadata by ID
  Future<AppResult<AudioEntity?>> getAudioById(String id);

  /// Get all audio files for a specific task
  Future<AppResult<List<AudioEntity>>> getAudioByTaskId(String taskId);

  /// Get all audio files
  Future<AppResult<List<AudioEntity>>> getAllAudio();

  /// Update audio metadata
  Future<AppResult<AudioEntity>> updateAudioMetadata(AudioEntity audio);

  /// Delete audio metadata and file
  Future<AppResult<void>> deleteAudio(String id);

  /// Mark audio as uploaded to remote storage
  Future<AppResult<AudioEntity>> markAsUploaded(String id, String remotePath);

  /// Update upload progress
  Future<AppResult<AudioEntity>> updateUploadProgress(
    String id,
    double progress,
  );

  /// Get pending uploads (not yet synced to remote)
  Future<AppResult<List<AudioEntity>>> getPendingUploads();

  /// Get audio files by sync status
  Future<AppResult<List<AudioEntity>>> getAudioBySyncStatus(String syncStatus);

  /// Search audio files by filename or task title
  Future<AppResult<List<AudioEntity>>> searchAudio(String query);

  /// Get audio statistics
  Future<AppResult<AudioStatistics>> getAudioStatistics();

  /// Export audio metadata
  Future<AppResult<String>> exportAudioMetadata(String format);

  /// Import audio metadata
  Future<AppResult<List<AudioEntity>>> importAudioMetadata(
    String data,
    String format,
  );

  /// Clear all audio data
  Future<AppResult<void>> clearAllAudio();
}

/// Audio statistics for dashboard display
class AudioStatistics {
  /// Total number of audio files
  final int totalAudioFiles;

  /// Total size of all audio files in bytes
  final int totalSizeBytes;

  /// Number of uploaded audio files
  final int uploadedFiles;

  /// Number of pending upload files
  final int pendingUploads;

  /// Average audio duration
  final Duration averageDuration;

  /// Total audio duration
  final Duration totalDuration;

  /// Number of audio files per task (average)
  final double audioPerTask;

  /// Most common audio format
  final String mostCommonFormat;

  const AudioStatistics({
    required this.totalAudioFiles,
    required this.totalSizeBytes,
    required this.uploadedFiles,
    required this.pendingUploads,
    required this.averageDuration,
    required this.totalDuration,
    required this.audioPerTask,
    required this.mostCommonFormat,
  });

  /// Get total size in human readable format
  String get totalSizeFormatted {
    if (totalSizeBytes < 1024) {
      return '${totalSizeBytes}B';
    } else if (totalSizeBytes < 1024 * 1024) {
      return '${(totalSizeBytes / 1024).toStringAsFixed(1)}KB';
    } else if (totalSizeBytes < 1024 * 1024 * 1024) {
      return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(totalSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  /// Get average duration in human readable format
  String get averageDurationFormatted {
    final minutes = averageDuration.inMinutes;
    final seconds = averageDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get total duration in human readable format
  String get totalDurationFormatted {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;
    final seconds = totalDuration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  String toString() {
    return 'AudioStatistics(totalFiles: $totalAudioFiles, totalSize: $totalSizeFormatted, uploaded: $uploadedFiles)';
  }
}
