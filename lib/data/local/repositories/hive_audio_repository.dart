import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../../features/audio/domain/audio_entity.dart';
import '../../../features/audio/domain/i_audio_repository.dart';
import '../../../core/result.dart';
import '../../../core/errors.dart';
import '../hive_database_manager.dart';

/// Hive-based audio repository implementation
class HiveAudioRepository implements IAudioRepository {
  final HiveDatabaseManager _database = HiveDatabaseManager.instance;
  static const String _audioDirectoryName = 'audio_files';

  Box<AudioEntity> get _audioBox => _database.audioBox;
  late Directory _audioDirectory;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Database and box are managed by HiveDatabaseManager
      // Just create audio directory
      final appDir = await getApplicationDocumentsDirectory();
      _audioDirectory = Directory('${appDir.path}/$_audioDirectoryName');
      if (!await _audioDirectory.exists()) {
        await _audioDirectory.create(recursive: true);
      }

      _isInitialized = true;
      debugPrint('HiveAudioRepository: Initialized successfully');
    } catch (e) {
      throw Exception('Failed to initialize audio repository: $e');
    }
  }

  @override
  Future<AppResult<List<AudioEntity>>> getAllAudio() async {
    try {
      await _ensureInitialized();
      final audioList = _audioBox.values.toList();
      return AppResult.success(audioList);
    } catch (e) {
      return AppResult.failure(DatabaseFailure('Failed to get all audio: $e'));
    }
  }

  @override
  Future<AppResult<List<AudioEntity>>> getAudioByTaskId(String taskId) async {
    try {
      await _ensureInitialized();
      final audioList = _audioBox.values
          .where((audio) => audio.taskId == taskId)
          .toList();
      return AppResult.success(audioList);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure('Failed to get audio by task ID: $e'),
      );
    }
  }

  @override
  Future<AppResult<AudioEntity?>> getAudioById(String id) async {
    try {
      await _ensureInitialized();
      final audio = _audioBox.get(id);
      return AppResult.success(audio);
    } catch (e) {
      return AppResult.failure(DatabaseFailure('Failed to get audio: $e'));
    }
  }

  @override
  Future<AppResult<AudioEntity>> saveAudioMetadata(AudioEntity audio) async {
    try {
      await _ensureInitialized();
      await _audioBox.put(audio.id, audio);
      return AppResult.success(audio);
    } catch (e) {
      return AppResult.failure(DatabaseFailure('Failed to save audio: $e'));
    }
  }

  @override
  Future<AppResult<void>> deleteAudio(String id) async {
    try {
      await _ensureInitialized();

      // Get audio entity first to delete physical file
      final audio = _audioBox.get(id);
      if (audio != null) {
        // Delete physical file if it exists
        final file = File(audio.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Delete from database
      await _audioBox.delete(id);
      return const AppResult.success(null);
    } catch (e) {
      return AppResult.failure(DatabaseFailure('Failed to delete audio: $e'));
    }
  }

  @override
  Future<AppResult<AudioEntity>> updateAudioMetadata(AudioEntity audio) async {
    try {
      await _ensureInitialized();

      // Check if audio exists
      final existingAudio = _audioBox.get(audio.id);
      if (existingAudio == null) {
        return AppResult.failure(
          DatabaseFailure('Audio not found: ${audio.id}'),
        );
      }

      // Update with current timestamp
      final updatedAudio = audio.copyWith(updatedAt: DateTime.now());
      await _audioBox.put(audio.id, updatedAudio);

      return AppResult.success(updatedAudio);
    } catch (e) {
      return AppResult.failure(DatabaseFailure('Failed to update audio: $e'));
    }
  }

  Future<AppResult<List<AudioEntity>>> getAudioByUploadStatus(
    bool isUploaded,
  ) async {
    try {
      await _ensureInitialized();
      final audioList = _audioBox.values
          .where((audio) => audio.isUploaded == isUploaded)
          .toList();
      return AppResult.success(audioList);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure('Failed to get audio by upload status: $e'),
      );
    }
  }

  @override
  Future<AppResult<AudioStatistics>> getAudioStatistics() async {
    try {
      await _ensureInitialized();
      final audioList = _audioBox.values.toList();

      final stats = AudioStatistics(
        totalAudioFiles: audioList.length,
        totalSizeBytes: audioList.fold<int>(
          0,
          (sum, audio) => sum + audio.fileSize,
        ),
        totalDuration: audioList.fold<Duration>(
          Duration.zero,
          (sum, audio) => sum + audio.duration,
        ),
        uploadedFiles: audioList.where((a) => a.isUploaded).length,
        pendingUploads: audioList.where((a) => !a.isUploaded).length,
        averageDuration: audioList.isEmpty
            ? Duration.zero
            : Duration(
                microseconds:
                    audioList.fold<int>(
                      0,
                      (sum, audio) => sum + audio.duration.inMicroseconds,
                    ) ~/
                    audioList.length,
              ),
        audioPerTask: audioList.isEmpty ? 0.0 : audioList.length.toDouble(),
        mostCommonFormat: audioList.isEmpty ? 'N/A' : 'm4a',
      );

      return AppResult.success(stats);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure('Failed to get audio statistics: $e'),
      );
    }
  }

  /// Ensure repository is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Clear all audio data (for testing/debugging)
  @override
  Future<AppResult<void>> clearAllAudio() async {
    try {
      await _ensureInitialized();

      // Delete all physical files
      for (final audio in _audioBox.values) {
        final file = File(audio.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Clear database
      await _audioBox.clear();
      return const AppResult.success(null);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure('Failed to clear all audio: $e'),
      );
    }
  }

  /// Get audio directory path
  String get audioDirectoryPath => _audioDirectory.path;

  /// Check if audio file exists locally
  Future<bool> audioFileExists(String localPath) async {
    try {
      final file = File(localPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AppResult<AudioEntity>> markAsUploaded(
    String id,
    String remotePath,
  ) async {
    try {
      await _ensureInitialized();

      final audio = _audioBox.get(id);
      if (audio == null) {
        return AppResult.failure(DatabaseFailure('Audio not found: $id'));
      }

      final uploadedAudio = audio.copyWith(
        isUploaded: true,
        remotePath: remotePath,
        updatedAt: DateTime.now(),
      );

      await _audioBox.put(id, uploadedAudio);
      return AppResult.success(uploadedAudio);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure('Failed to mark audio as uploaded: $e'),
      );
    }
  }

  @override
  Future<AppResult<AudioEntity>> updateUploadProgress(
    String id,
    double progress,
  ) async {
    try {
      await _ensureInitialized();

      final audio = _audioBox.get(id);
      if (audio == null) {
        return AppResult.failure(DatabaseFailure('Audio not found: $id'));
      }

      // For now, we'll just update the timestamp
      // Future: Add uploadProgress field to AudioEntity if needed
      final updatedAudio = audio.copyWith(updatedAt: DateTime.now());

      await _audioBox.put(id, updatedAudio);
      return AppResult.success(updatedAudio);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure('Failed to update upload progress: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<AudioEntity>>> getPendingUploads() async {
    try {
      await _ensureInitialized();

      final pendingAudio = _audioBox.values
          .where((audio) => !audio.isUploaded)
          .toList();

      return AppResult.success(pendingAudio);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure('Failed to get pending uploads: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<AudioEntity>>> getAudioBySyncStatus(
    String syncStatus,
  ) async {
    try {
      await _ensureInitialized();

      // For now, we'll return all audio since sync status is not yet implemented
      // Future: Add syncStatus field to AudioEntity when implementing sync
      final audioList = _audioBox.values.toList();

      return AppResult.success(audioList);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure('Failed to get audio by sync status: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<AudioEntity>>> searchAudio(String query) async {
    try {
      await _ensureInitialized();

      if (query.trim().isEmpty) {
        return const AppResult.success([]);
      }

      final lowercaseQuery = query.toLowerCase();
      final results = _audioBox.values
          .where(
            (audio) =>
                audio.fileName.toLowerCase().contains(lowercaseQuery) ||
                audio.taskId.toLowerCase().contains(lowercaseQuery),
          )
          .toList();

      return AppResult.success(results);
    } catch (e) {
      return AppResult.failure(DatabaseFailure('Failed to search audio: $e'));
    }
  }

  @override
  Future<AppResult<String>> exportAudioMetadata(String format) async {
    try {
      await _ensureInitialized();

      final audioList = _audioBox.values.toList();
      String exportData;

      switch (format.toLowerCase()) {
        case 'json':
          exportData = audioList
              .map((audio) => audio.toJson())
              .toList()
              .toString();
          break;
        case 'csv':
          final csvHeader =
              'FileName,TaskId,FileSize,Duration,Format,RecordedAt\n';
          final csvRows = audioList
              .map(
                (audio) =>
                    '${audio.fileName},${audio.taskId},${audio.fileSize},${audio.duration.inSeconds},${audio.format},${audio.recordedAt.toIso8601String()}',
              )
              .join('\n');
          exportData = csvHeader + csvRows;
          break;
        default:
          return AppResult.failure(
            DatabaseFailure('Unsupported export format: $format'),
          );
      }

      return AppResult.success(exportData);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure('Failed to export audio metadata: $e'),
      );
    }
  }

  @override
  Future<AppResult<List<AudioEntity>>> importAudioMetadata(
    String data,
    String format,
  ) async {
    try {
      await _ensureInitialized();

      List<AudioEntity> audioList = [];

      switch (format.toLowerCase()) {
        case 'json':
          try {
            final List<dynamic> jsonList = jsonDecode(data);
            audioList = jsonList
                .map((json) => AudioEntity.fromJson(json))
                .toList();
          } catch (e) {
            return AppResult.failure(
              DatabaseFailure('Invalid JSON format: $e'),
            );
          }
          break;
        case 'csv':
          // Simple CSV import - basic implementation
          final lines = data.split('\n');
          if (lines.length < 2) {
            return const AppResult.failure(
              DatabaseFailure('Invalid CSV format: insufficient data'),
            );
          }

          // Skip header line
          for (int i = 1; i < lines.length; i++) {
            final line = lines[i].trim();
            if (line.isNotEmpty) {
              // Basic CSV parsing - can be enhanced
              debugPrint('Importing CSV line: $line');
            }
          }
          break;
        default:
          return AppResult.failure(
            DatabaseFailure('Unsupported import format: $format'),
          );
      }

      if (audioList.isEmpty) {
        return const AppResult.failure(
          DatabaseFailure('No valid audio metadata found in import data'),
        );
      }

      // Save imported audio metadata
      final List<AudioEntity> importedAudio = [];
      for (final audio in audioList) {
        final result = await saveAudioMetadata(audio);
        if (result.isSuccess) {
          importedAudio.add(result.dataOrNull!);
        }
      }

      return AppResult.success(importedAudio);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure('Failed to import audio metadata: $e'),
      );
    }
  }
}
