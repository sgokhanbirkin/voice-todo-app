import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/audio_entity.dart';
import '../../domain/i_audio_repository.dart';
import '../../../../core/result.dart';
import '../../../../core/errors.dart';
import '../../../../core/logger.dart';
import '../../../../core/database/hive_database.dart';

/// Hive implementation of audio repository
class HiveAudioRepository implements IAudioRepository {
  final HiveDatabase _database = HiveDatabase.instance;
  final Logger _logger = Logger.instance;

  Box get _audioBox => _database.audioBox;

  @override
  Future<AppResult<AudioEntity>> saveAudioMetadata(AudioEntity audio) async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      await _audioBox.put(audio.id, audio);
      _logger.info('Audio metadata saved: ${audio.id}');
      return AppResult.success(audio);
    } catch (e) {
      _logger.error('Failed to save audio metadata: $e');
      return AppResult.failure(DatabaseFailure('Failed to save audio metadata: $e'));
    }
  }

  @override
  Future<AppResult<AudioEntity?>> getAudioById(String id) async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final audio = _audioBox.get(id) as AudioEntity?;
      _logger.info('Retrieved audio by ID: $id, found: ${audio != null}');
      return AppResult.success(audio);
    } catch (e) {
      _logger.error('Failed to get audio by ID: $e');
      return AppResult.failure(DatabaseFailure('Failed to get audio by ID: $e'));
    }
  }

  @override
  Future<AppResult<List<AudioEntity>>> getAudioByTaskId(String taskId) async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final allAudio = _audioBox.values.cast<AudioEntity>().toList();
      final taskAudio = allAudio.where((audio) => audio.taskId == taskId).toList();
      
      _logger.info('Retrieved ${taskAudio.length} audio files for task: $taskId');
      return AppResult.success(taskAudio);
    } catch (e) {
      _logger.error('Failed to get audio by task ID: $e');
      return AppResult.failure(DatabaseFailure('Failed to get audio by task ID: $e'));
    }
  }

  @override
  Future<AppResult<List<AudioEntity>>> getAllAudio() async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final audio = _audioBox.values.cast<AudioEntity>().toList();
      _logger.info('Retrieved ${audio.length} audio files from local database');
      return AppResult.success(audio);
    } catch (e) {
      _logger.error('Failed to get all audio: $e');
      return AppResult.failure(DatabaseFailure('Failed to get all audio: $e'));
    }
  }

  @override
  Future<AppResult<AudioEntity>> updateAudioMetadata(AudioEntity audio) async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final updatedAudio = audio.copyWith(
        updatedAt: DateTime.now(),
      );

      await _audioBox.put(audio.id, updatedAudio);
      _logger.info('Audio metadata updated: ${audio.id}');
      return AppResult.success(updatedAudio);
    } catch (e) {
      _logger.error('Failed to update audio metadata: $e');
      return AppResult.failure(DatabaseFailure('Failed to update audio metadata: $e'));
    }
  }

  @override
  Future<AppResult<void>> deleteAudio(String id) async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      // Get audio metadata first
      final audio = _audioBox.get(id) as AudioEntity?;
      
      // Delete from Hive
      await _audioBox.delete(id);

      // Delete physical file if it exists
      if (audio != null && audio.localPath.isNotEmpty) {
        final file = File(audio.localPath);
        if (await file.exists()) {
          await file.delete();
          _logger.info('Physical audio file deleted: ${audio.localPath}');
        }
      }

      _logger.info('Audio deleted: $id');
      return AppResult.success(null);
    } catch (e) {
      _logger.error('Failed to delete audio: $e');
      return AppResult.failure(DatabaseFailure('Failed to delete audio: $e'));
    }
  }

  @override
  Future<AppResult<AudioEntity>> markAsUploaded(String id, String remotePath) async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final audio = _audioBox.get(id) as AudioEntity?;
      if (audio == null) {
        return AppResult.failure(DatabaseFailure('Audio not found: $id'));
      }

      final updatedAudio = audio.copyWith(
        remotePath: remotePath,
        isUploaded: true,
        uploadProgress: 1.0,
        syncStatus: 'synced',
        updatedAt: DateTime.now(),
      );

      await _audioBox.put(id, updatedAudio);
      _logger.info('Audio marked as uploaded: $id');
      return AppResult.success(updatedAudio);
    } catch (e) {
      _logger.error('Failed to mark audio as uploaded: $e');
      return AppResult.failure(DatabaseFailure('Failed to mark audio as uploaded: $e'));
    }
  }

  @override
  Future<AppResult<AudioEntity>> updateUploadProgress(String id, double progress) async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final audio = _audioBox.get(id) as AudioEntity?;
      if (audio == null) {
        return AppResult.failure(DatabaseFailure('Audio not found: $id'));
      }

      final updatedAudio = audio.copyWith(
        uploadProgress: progress,
        updatedAt: DateTime.now(),
      );

      await _audioBox.put(id, updatedAudio);
      _logger.info('Audio upload progress updated: $id -> ${(progress * 100).toStringAsFixed(1)}%');
      return AppResult.success(updatedAudio);
    } catch (e) {
      _logger.error('Failed to update upload progress: $e');
      return AppResult.failure(DatabaseFailure('Failed to update upload progress: $e'));
    }
  }

  @override
  Future<AppResult<List<AudioEntity>>> getPendingUploads() async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final allAudio = _audioBox.values.cast<AudioEntity>().toList();
      final pendingUploads = allAudio.where((audio) => !audio.isUploaded).toList();
      
      _logger.info('Retrieved ${pendingUploads.length} pending audio uploads');
      return AppResult.success(pendingUploads);
    } catch (e) {
      _logger.error('Failed to get pending uploads: $e');
      return AppResult.failure(DatabaseFailure('Failed to get pending uploads: $e'));
    }
  }

  @override
  Future<AppResult<List<AudioEntity>>> getAudioBySyncStatus(String syncStatus) async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final allAudio = _audioBox.values.cast<AudioEntity>().toList();
      final filteredAudio = allAudio.where((audio) => audio.syncStatus == syncStatus).toList();
      
      _logger.info('Retrieved ${filteredAudio.length} audio files with sync status: $syncStatus');
      return AppResult.success(filteredAudio);
    } catch (e) {
      _logger.error('Failed to get audio by sync status: $e');
      return AppResult.failure(DatabaseFailure('Failed to get audio by sync status: $e'));
    }
  }

  @override
  Future<AppResult<List<AudioEntity>>> searchAudio(String query) async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      if (query.isEmpty) {
        return getAllAudio();
      }

      final allAudio = _audioBox.values.cast<AudioEntity>().toList();
      final filteredAudio = allAudio.where((audio) {
        return audio.fileName.toLowerCase().contains(query.toLowerCase()) ||
               audio.taskId.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      _logger.info('Audio search for "$query" returned ${filteredAudio.length} results');
      return AppResult.success(filteredAudio);
    } catch (e) {
      _logger.error('Failed to search audio: $e');
      return AppResult.failure(DatabaseFailure('Failed to search audio: $e'));
    }
  }

  @override
  Future<AppResult<AudioStatistics>> getAudioStatistics() async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final allAudio = _audioBox.values.cast<AudioEntity>().toList();
      
      if (allAudio.isEmpty) {
        const emptyStats = AudioStatistics(
          totalAudioFiles: 0,
          totalSizeBytes: 0,
          uploadedFiles: 0,
          pendingUploads: 0,
          averageDuration: Duration.zero,
          totalDuration: Duration.zero,
          audioPerTask: 0.0,
          mostCommonFormat: 'none',
        );
        return AppResult.success(emptyStats);
      }

      // Calculate statistics
      final totalFiles = allAudio.length;
      final totalSize = allAudio.fold<int>(0, (sum, audio) => sum + audio.fileSize);
      final uploadedFiles = allAudio.where((audio) => audio.isUploaded).length;
      final pendingUploads = totalFiles - uploadedFiles;
      
      final totalDuration = allAudio.fold<Duration>(
        Duration.zero,
        (sum, audio) => sum + audio.duration,
      );
      final averageDuration = totalFiles > 0 
          ? Duration(microseconds: totalDuration.inMicroseconds ~/ totalFiles)
          : Duration.zero;

      // Get unique task count
      final uniqueTasks = allAudio.map((audio) => audio.taskId).toSet().length;
      final audioPerTask = uniqueTasks > 0 ? totalFiles / uniqueTasks : 0.0;

      // Find most common format
      final formatCounts = <String, int>{};
      for (final audio in allAudio) {
        formatCounts[audio.format] = (formatCounts[audio.format] ?? 0) + 1;
      }
      final mostCommonFormat = formatCounts.entries.isEmpty 
          ? 'none'
          : formatCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      final stats = AudioStatistics(
        totalAudioFiles: totalFiles,
        totalSizeBytes: totalSize,
        uploadedFiles: uploadedFiles,
        pendingUploads: pendingUploads,
        averageDuration: averageDuration,
        totalDuration: totalDuration,
        audioPerTask: audioPerTask,
        mostCommonFormat: mostCommonFormat,
      );

      _logger.info('Generated audio statistics: $totalFiles total files, $totalSize bytes');
      return AppResult.success(stats);
    } catch (e) {
      _logger.error('Failed to get audio statistics: $e');
      return AppResult.failure(DatabaseFailure('Failed to get audio statistics: $e'));
    }
  }

  @override
  Future<AppResult<String>> exportAudioMetadata(String format) async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      final allAudio = _audioBox.values.cast<AudioEntity>().toList();
      
      if (format.toLowerCase() == 'json') {
        final jsonList = allAudio.map((audio) => audio.toJson()).toList();
        final jsonString = jsonList.toString();
        _logger.info('Exported ${allAudio.length} audio metadata records to JSON');
        return AppResult.success(jsonString);
      }
      
      return AppResult.failure(DatabaseFailure('Unsupported export format: $format'));
    } catch (e) {
      _logger.error('Failed to export audio metadata: $e');
      return AppResult.failure(DatabaseFailure('Failed to export audio metadata: $e'));
    }
  }

  @override
  Future<AppResult<List<AudioEntity>>> importAudioMetadata(String data, String format) async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      // TODO: Implement audio metadata import
      _logger.info('Audio metadata import not yet implemented');
      return AppResult.failure(DatabaseFailure('Import not yet implemented'));
    } catch (e) {
      _logger.error('Failed to import audio metadata: $e');
      return AppResult.failure(DatabaseFailure('Failed to import audio metadata: $e'));
    }
  }

  @override
  Future<AppResult<void>> clearAllAudio() async {
    try {
      if (!_database.isReady) {
        return AppResult.failure(DatabaseFailure('Database not ready'));
      }

      // Get all audio files for cleanup
      final allAudio = _audioBox.values.cast<AudioEntity>().toList();
      
      // Delete physical files
      for (final audio in allAudio) {
        if (audio.localPath.isNotEmpty) {
          final file = File(audio.localPath);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      // Clear the box
      await _audioBox.clear();
      
      _logger.info('All audio data cleared successfully');
      return AppResult.success(null);
    } catch (e) {
      _logger.error('Failed to clear all audio: $e');
      return AppResult.failure(DatabaseFailure('Failed to clear all audio: $e'));
    }
  }
}
