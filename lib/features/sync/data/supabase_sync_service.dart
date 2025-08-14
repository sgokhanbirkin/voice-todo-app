import 'dart:async';
import 'dart:io';
import '../domain/i_sync_service.dart';
import '../../../core/result.dart';
import '../../../core/errors.dart';
import '../../../core/logger.dart';
import '../../../data/remote/supabase_service.dart';
import '../../todos/domain/i_task_repository.dart';
import '../../todos/domain/task_entity.dart';
import '../../audio/domain/i_audio_repository.dart';

/// Supabase implementation of sync service
class SupabaseSyncService implements ISyncService {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final ITaskRepository _taskRepository;
  final IAudioRepository _audioRepository;
  final Logger _logger = Logger.instance;

  Timer? _backgroundSyncTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  bool _autoSyncEnabled = false;
  int _syncIntervalMinutes = 15; // Default 15 minutes

  SupabaseSyncService(this._taskRepository, this._audioRepository);

  @override
  Future<AppResult<SyncResult>> syncTasks() async {
    if (_isSyncing) {
      return const AppResult.failure(
        DatabaseFailure('Sync already in progress'),
      );
    }

    try {
      _isSyncing = true;
      final startTime = DateTime.now();
      final operations = <SyncOperation>[];
      final errors = <String>[];
      int syncedItems = 0;
      int failedItems = 0;
      int conflicts = 0;

      _logger.info('Starting task sync...');

      // Get pending tasks for sync
      final pendingResult = await _taskRepository.getTasksBySyncStatus(
        'pending',
      );
      if (!pendingResult.isSuccess) {
        return AppResult.failure(pendingResult.errorOrNull!);
      }

      final pendingTasks = pendingResult.dataOrNull!;
      _logger.info('Found ${pendingTasks.length} pending tasks to sync');

      // Sync each pending task
      for (final task in pendingTasks) {
        try {
          final operation = SyncOperation(
            itemType: SyncItemType.task,
            itemId: task.id,
            operationType: SyncOperationType.create,
            status: SyncOperationStatus.inProgress,
            timestamp: DateTime.now(),
          );
          operations.add(operation);

          // Upload task to Supabase
          final taskData = task.toJson();
          taskData.remove('localCreatedAt');
          taskData.remove('localUpdatedAt');
          taskData.remove('syncStatus');

          final result = await _supabaseService.client
              .from('tasks')
              .upsert(taskData)
              .select()
              .single();

          if (result != null) {
            // Mark task as synced locally
            final syncedTask = task.copyWith(
              syncStatus: 'synced',
              localUpdatedAt: DateTime.now(),
            );
            await _taskRepository.updateTask(syncedTask);

            syncedItems++;
            operations.add(
              operation.copyWith(status: SyncOperationStatus.completed),
            );
            _logger.info('Task synced successfully: ${task.id}');
          }
        } catch (e) {
          failedItems++;
          errors.add('Failed to sync task ${task.id}: $e');
          operations.add(
            operations.last.copyWith(
              status: SyncOperationStatus.failed,
              error: e.toString(),
            ),
          );
          _logger.error('Failed to sync task ${task.id}: $e');
        }
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      _lastSyncTime = endTime;

      final syncResult = SyncResult(
        syncedItems: syncedItems,
        failedItems: failedItems,
        conflicts: conflicts,
        duration: duration,
        startTime: startTime,
        endTime: endTime,
        operations: operations,
        errors: errors,
      );

      _logger.info('Task sync completed: $syncResult');
      return AppResult.success(syncResult);
    } catch (e) {
      _logger.error('Task sync failed: $e');
      return AppResult.failure(NetworkFailure('Task sync failed: $e'));
    } finally {
      _isSyncing = false;
    }
  }

  @override
  Future<AppResult<SyncResult>> syncAudio() async {
    if (_isSyncing) {
      return const AppResult.failure(
        DatabaseFailure('Sync already in progress'),
      );
    }

    try {
      _isSyncing = true;
      final startTime = DateTime.now();
      final operations = <SyncOperation>[];
      final errors = <String>[];
      int syncedItems = 0;
      int failedItems = 0;
      int conflicts = 0;

      _logger.info('Starting audio sync...');

      // Get pending audio uploads
      final pendingResult = await _audioRepository.getPendingUploads();
      if (!pendingResult.isSuccess) {
        return AppResult.failure(pendingResult.errorOrNull!);
      }

      final pendingAudio = pendingResult.dataOrNull!;
      _logger.info('Found ${pendingAudio.length} pending audio files to sync');

      // Sync each pending audio file
      for (final audio in pendingAudio) {
        try {
          final operation = SyncOperation(
            itemType: SyncItemType.audio,
            itemId: audio.id,
            operationType: SyncOperationType.create,
            status: SyncOperationStatus.inProgress,
            timestamp: DateTime.now(),
          );
          operations.add(operation);

          // Upload audio file to Supabase Storage
          final remotePath = 'audio/${audio.taskId}/${audio.fileName}';
          final file = File(audio.localPath);

          await _supabaseService.uploadFile(
            bucketName: 'audio-files',
            filePath: remotePath,
            file: file,
          );

          // Mark audio as uploaded
          await _audioRepository.markAsUploaded(audio.id, remotePath);

          syncedItems++;
          operations.add(
            operation.copyWith(status: SyncOperationStatus.completed),
          );
          _logger.info('Audio synced successfully: ${audio.id}');
        } catch (e) {
          failedItems++;
          errors.add('Failed to sync audio ${audio.id}: $e');
          operations.add(
            operations.last.copyWith(
              status: SyncOperationStatus.failed,
              error: e.toString(),
            ),
          );
          _logger.error('Failed to sync audio ${audio.id}: $e');
        }
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      _lastSyncTime = endTime;

      final syncResult = SyncResult(
        syncedItems: syncedItems,
        failedItems: failedItems,
        conflicts: conflicts,
        duration: duration,
        startTime: startTime,
        endTime: endTime,
        operations: operations,
        errors: errors,
      );

      _logger.info('Audio sync completed: $syncResult');
      return AppResult.success(syncResult);
    } catch (e) {
      _logger.error('Audio sync failed: $e');
      return AppResult.failure(NetworkFailure('Audio sync failed: $e'));
    } finally {
      _isSyncing = false;
    }
  }

  @override
  Future<AppResult<SyncResult>> syncAll() async {
    try {
      final startTime = DateTime.now();
      final allOperations = <SyncOperation>[];
      final allErrors = <String>[];
      int totalSynced = 0;
      int totalFailed = 0;
      int totalConflicts = 0;

      _logger.info('Starting full sync (tasks + audio)...');

      // Sync tasks first
      final taskSyncResult = await syncTasks();
      if (taskSyncResult.isSuccess) {
        final taskSync = taskSyncResult.dataOrNull!;
        totalSynced += taskSync.syncedItems;
        totalFailed += taskSync.failedItems;
        totalConflicts += taskSync.conflicts;
        allOperations.addAll(taskSync.operations);
        allErrors.addAll(taskSync.errors);
      } else {
        allErrors.add(
          'Task sync failed: ${taskSyncResult.errorOrNull!.message}',
        );
      }

      // Then sync audio
      final audioSyncResult = await syncAudio();
      if (audioSyncResult.isSuccess) {
        final audioSync = audioSyncResult.dataOrNull!;
        totalSynced += audioSync.syncedItems;
        totalFailed += audioSync.failedItems;
        totalConflicts += audioSync.conflicts;
        allOperations.addAll(audioSync.operations);
        allErrors.addAll(audioSync.errors);
      } else {
        allErrors.add(
          'Audio sync failed: ${audioSyncResult.errorOrNull!.message}',
        );
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      final syncResult = SyncResult(
        syncedItems: totalSynced,
        failedItems: totalFailed,
        conflicts: totalConflicts,
        duration: duration,
        startTime: startTime,
        endTime: endTime,
        operations: allOperations,
        errors: allErrors,
      );

      _logger.info('Full sync completed: $syncResult');
      return AppResult.success(syncResult);
    } catch (e) {
      _logger.error('Full sync failed: $e');
      return AppResult.failure(NetworkFailure('Full sync failed: $e'));
    }
  }

  @override
  Future<AppResult<SyncResult>> pullFromRemote() async {
    try {
      final startTime = DateTime.now();
      final operations = <SyncOperation>[];
      final errors = <String>[];
      int syncedItems = 0;
      int failedItems = 0;
      int conflicts = 0;

      _logger.info('Pulling data from remote...');

      // Get current user
      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        return const AppResult.failure(AuthFailure('User not authenticated'));
      }

      // Pull tasks from remote
      try {
        final remoteTasks = await _supabaseService.client
            .from('tasks')
            .select()
            .eq('user_id', currentUser.id)
            .order('updated_at', ascending: false);

        for (final taskData in remoteTasks) {
          try {
            final remoteTask = TaskEntity.fromJson(
              taskData as Map<String, dynamic>,
            );

            // Check if task exists locally
            final localTaskResult = await _taskRepository.getTaskById(
              remoteTask.id,
            );

            if (localTaskResult.isSuccess &&
                localTaskResult.dataOrNull != null) {
              final localTask = localTaskResult.dataOrNull!;

              // Check for conflicts (compare timestamps)
              if (localTask.updatedAt.isAfter(remoteTask.updatedAt)) {
                conflicts++;
                _logger.warning('Conflict detected for task ${remoteTask.id}');
                continue;
              }
            }

            // Update or create local task
            final localTask = remoteTask.copyWith(
              syncStatus: 'synced',
              localUpdatedAt: DateTime.now(),
            );
            await _taskRepository.updateTask(localTask);

            syncedItems++;
            operations.add(
              SyncOperation(
                itemType: SyncItemType.task,
                itemId: remoteTask.id,
                operationType: SyncOperationType.download,
                status: SyncOperationStatus.completed,
                timestamp: DateTime.now(),
              ),
            );
          } catch (e) {
            failedItems++;
            errors.add('Failed to process remote task: $e');
          }
        }
      } catch (e) {
        errors.add('Failed to pull tasks from remote: $e');
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      _lastSyncTime = endTime;

      final syncResult = SyncResult(
        syncedItems: syncedItems,
        failedItems: failedItems,
        conflicts: conflicts,
        duration: duration,
        startTime: startTime,
        endTime: endTime,
        operations: operations,
        errors: errors,
      );

      _logger.info('Pull from remote completed: $syncResult');
      return AppResult.success(syncResult);
    } catch (e) {
      _logger.error('Pull from remote failed: $e');
      return AppResult.failure(NetworkFailure('Pull from remote failed: $e'));
    }
  }

  @override
  Future<AppResult<SyncResult>> pushToRemote() async {
    // This is essentially the same as syncAll()
    return syncAll();
  }

  @override
  Future<AppResult<List<ConflictResolution>>> resolveConflicts() async {
    try {
      final conflicts = <ConflictResolution>[];

      // TODO: Implement conflict detection and resolution
      _logger.info('Conflict resolution not yet implemented');

      return AppResult.success(conflicts);
    } catch (e) {
      _logger.error('Conflict resolution failed: $e');
      return AppResult.failure(
        DatabaseFailure('Conflict resolution failed: $e'),
      );
    }
  }

  @override
  Future<AppResult<SyncStatus>> getSyncStatus() async {
    try {
      // Get pending items count
      final pendingTasksResult = await _taskRepository.getTasksBySyncStatus(
        'pending',
      );
      final pendingAudioResult = await _audioRepository.getPendingUploads();

      int pendingItems = 0;
      if (pendingTasksResult.isSuccess) {
        pendingItems += pendingTasksResult.dataOrNull!.length;
      }
      if (pendingAudioResult.isSuccess) {
        pendingItems += pendingAudioResult.dataOrNull!.length;
      }

      final status = SyncStatus(
        isSyncing: _isSyncing,
        lastSyncTime: _lastSyncTime,
        nextSyncTime: _getNextSyncTime(),
        pendingItems: pendingItems,
        autoSyncEnabled: _autoSyncEnabled,
        syncIntervalMinutes: _syncIntervalMinutes,
        lastSyncResult: null, // TODO: Store last sync result
      );

      return AppResult.success(status);
    } catch (e) {
      _logger.error('Failed to get sync status: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get sync status: $e'),
      );
    }
  }

  @override
  Future<AppResult<void>> setAutoSync(bool enabled) async {
    try {
      _autoSyncEnabled = enabled;

      if (enabled) {
        await startBackgroundSync();
      } else {
        await stopBackgroundSync();
      }

      _logger.info('Auto sync ${enabled ? 'enabled' : 'disabled'}');
      return const AppResult.success(null);
    } catch (e) {
      _logger.error('Failed to set auto sync: $e');
      return AppResult.failure(DatabaseFailure('Failed to set auto sync: $e'));
    }
  }

  @override
  Future<AppResult<bool>> isAutoSyncEnabled() async {
    return AppResult.success(_autoSyncEnabled);
  }

  @override
  Future<AppResult<void>> startBackgroundSync() async {
    try {
      if (_backgroundSyncTimer != null) {
        _backgroundSyncTimer!.cancel();
      }

      _backgroundSyncTimer = Timer.periodic(
        Duration(minutes: _syncIntervalMinutes),
        (_) async {
          if (!_isSyncing) {
            _logger.info('Running background sync...');
            await syncAll();
          }
        },
      );

      _logger.info(
        'Background sync started (interval: ${_syncIntervalMinutes}min)',
      );
      return const AppResult.success(null);
    } catch (e) {
      _logger.error('Failed to start background sync: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to start background sync: $e'),
      );
    }
  }

  @override
  Future<AppResult<void>> stopBackgroundSync() async {
    try {
      _backgroundSyncTimer?.cancel();
      _backgroundSyncTimer = null;

      _logger.info('Background sync stopped');
      return const AppResult.success(null);
    } catch (e) {
      _logger.error('Failed to stop background sync: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to stop background sync: $e'),
      );
    }
  }

  @override
  Future<AppResult<SyncResult>> forceSync() async {
    _logger.info('Force sync requested');
    return syncAll();
  }

  @override
  Future<AppResult<DateTime?>> getLastSyncTime() async {
    return AppResult.success(_lastSyncTime);
  }

  @override
  Future<AppResult<int>> getPendingSyncCount() async {
    try {
      final pendingTasksResult = await _taskRepository.getTasksBySyncStatus(
        'pending',
      );
      final pendingAudioResult = await _audioRepository.getPendingUploads();

      int pendingItems = 0;
      if (pendingTasksResult.isSuccess) {
        pendingItems += pendingTasksResult.dataOrNull!.length;
      }
      if (pendingAudioResult.isSuccess) {
        pendingItems += pendingAudioResult.dataOrNull!.length;
      }

      return AppResult.success(pendingItems);
    } catch (e) {
      _logger.error('Failed to get pending sync count: $e');
      return AppResult.failure(
        DatabaseFailure('Failed to get pending sync count: $e'),
      );
    }
  }

  /// Get next scheduled sync time
  DateTime? _getNextSyncTime() {
    if (!_autoSyncEnabled || _lastSyncTime == null) {
      return null;
    }
    return _lastSyncTime!.add(Duration(minutes: _syncIntervalMinutes));
  }

  /// Dispose resources
  void dispose() {
    _backgroundSyncTimer?.cancel();
    _backgroundSyncTimer = null;
  }
}

/// Extension to add copyWith method to SyncOperation
extension SyncOperationExtension on SyncOperation {
  SyncOperation copyWith({
    SyncItemType? itemType,
    String? itemId,
    SyncOperationType? operationType,
    SyncOperationStatus? status,
    String? error,
    DateTime? timestamp,
  }) {
    return SyncOperation(
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      operationType: operationType ?? this.operationType,
      status: status ?? this.status,
      error: error ?? this.error,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
