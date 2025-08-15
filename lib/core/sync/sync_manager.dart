import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/connectivity_service.dart';
import '../../features/todos/domain/task_entity.dart';
import '../../features/audio/domain/audio_entity.dart';
import '../../data/remote/repositories/supabase_task_repository.dart';
import '../../data/remote/repositories/supabase_storage_repository.dart';

/// Manages synchronization between local Hive storage and remote Supabase
class SyncManager extends GetxController {
  final ConnectivityService _connectivityService = ConnectivityService();

  // Sync status
  final RxBool isSyncing = false.obs;
  final RxBool lastSyncSuccessful = true.obs;
  final Rx<DateTime?> lastSyncTime = Rx<DateTime?>(null);

  // Sync queues
  final RxList<TaskEntity> pendingTaskSync = <TaskEntity>[].obs;
  final RxList<AudioEntity> pendingAudioSync = <AudioEntity>[].obs;

  // Delete queues - track deleted items for sync
  final RxList<String> pendingTaskDeletes = <String>[].obs;
  final RxList<String> pendingAudioDeletes = <String>[].obs;

  // Sync intervals
  static const Duration _autoSyncInterval = Duration(minutes: 5);
  //static const Duration _manualSyncTimeout = Duration(seconds: 30);

  @override
  void onInit() {
    super.onInit();
    _setupConnectivityListener();
    _startAutoSync();
  }

  /// Setup connectivity change listener
  void _setupConnectivityListener() {
    _connectivityService.connectivityStream.listen((connectivityResults) {
      if (connectivityResults.isNotEmpty &&
          !connectivityResults.contains(ConnectivityResult.none)) {
        debugPrint(
          'SyncManager: Internet connection restored, triggering sync',
        );
        _triggerSync();
      } else {
        debugPrint('SyncManager: Internet connection lost, stopping sync');
        isSyncing.value = false;
      }
    });
  }

  /// Start automatic sync timer
  void _startAutoSync() {
    Timer.periodic(_autoSyncInterval, (timer) async {
      if (await _connectivityService.hasInternetConnection()) {
        _triggerSync();
      }
    });
  }

  /// Trigger sync if conditions are met
  Future<void> _triggerSync() async {
    if (isSyncing.value) {
      debugPrint('SyncManager: Sync already in progress, skipping');
      return;
    }

    if (!await _connectivityService.hasInternetConnection()) {
      debugPrint('SyncManager: No internet connection, skipping sync');
      return;
    }

    if (pendingTaskSync.isEmpty && pendingAudioSync.isEmpty) {
      debugPrint('SyncManager: No pending items to sync');
      return;
    }

    await _performSync();
  }

  /// Perform the actual sync operation
  Future<void> _performSync() async {
    try {
      isSyncing.value = true;
      debugPrint('SyncManager: Starting sync...');

      // Sync tasks
      if (pendingTaskSync.isNotEmpty) {
        await _syncTasks();
      }

      // Sync audio files
      if (pendingAudioSync.isNotEmpty) {
        await _syncAudioFiles();
      }

      // Sync task deletes
      if (pendingTaskDeletes.isNotEmpty) {
        await _syncTaskDeletes();
      }

      // Sync audio deletes
      if (pendingAudioDeletes.isNotEmpty) {
        await _syncAudioDeletes();
      }

      lastSyncSuccessful.value = true;
      lastSyncTime.value = DateTime.now();
      debugPrint('SyncManager: Sync completed successfully');
    } catch (e) {
      lastSyncSuccessful.value = false;
      debugPrint('SyncManager: Sync failed: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  /// Sync pending tasks to Supabase
  Future<void> _syncTasks() async {
    debugPrint('SyncManager: Syncing ${pendingTaskSync.length} tasks');

    try {
      final supabaseRepo = Get.find<SupabaseTaskRepository>();

      for (final task in pendingTaskSync) {
        try {
          debugPrint('SyncManager: Syncing task: ${task.title}');

          // Check if task exists in Supabase
          final existingTask = await supabaseRepo.getTaskById(task.id);

          if (existingTask.isSuccess) {
            // Task exists, update it
            await supabaseRepo.updateTask(task);
            debugPrint('SyncManager: Updated task in Supabase: ${task.title}');
          } else {
            // Task doesn't exist, create it
            await supabaseRepo.createTask(task);
            debugPrint('SyncManager: Created task in Supabase: ${task.title}');
          }
        } catch (e) {
          debugPrint('SyncManager: Failed to sync task ${task.title}: $e');
        }
      }

      debugPrint(
        'SyncManager: Successfully synced ${pendingTaskSync.length} tasks',
      );
      pendingTaskSync.clear();
    } catch (e) {
      debugPrint('SyncManager: Error syncing tasks: $e');
    }
  }

  /// Sync pending audio files to Supabase
  Future<void> _syncAudioFiles() async {
    debugPrint('SyncManager: Syncing ${pendingAudioSync.length} audio files');

    try {
      final storageRepo = Get.find<SupabaseStorageRepository>();

      for (final audio in pendingAudioSync) {
        try {
          debugPrint('SyncManager: Syncing audio: ${audio.fileName}');

          // Upload audio file to Supabase Storage
          final uploadResult = await storageRepo.uploadAudioFile(
            audio.localPath,
          );

          if (uploadResult.isSuccess) {
            final storageUrl = uploadResult.dataOrNull!;
            debugPrint('SyncManager: Audio uploaded to storage: $storageUrl');

            // Update audio metadata in Supabase database
            // For now, we'll just log the success
            // TODO: Create SupabaseAudioRepository and implement metadata sync
            debugPrint('SyncManager: Audio metadata sync pending - repository not yet implemented');
          } else {
            debugPrint(
              'SyncManager: Failed to upload audio: ${uploadResult.errorOrNull?.message}',
            );
          }
        } catch (e) {
          debugPrint('SyncManager: Failed to sync audio ${audio.fileName}: $e');
        }
      }

      debugPrint(
        'SyncManager: Successfully synced ${pendingAudioSync.length} audio files',
      );
      pendingAudioSync.clear();
    } catch (e) {
      debugPrint('SyncManager: Error syncing audio files: $e');
    }
  }

  /// Sync pending task deletes to Supabase
  Future<void> _syncTaskDeletes() async {
    debugPrint(
      'SyncManager: Syncing ${pendingTaskDeletes.length} task deletes',
    );

    try {
      final supabaseRepo = Get.find<SupabaseTaskRepository>();

      for (final taskId in pendingTaskDeletes) {
        try {
          debugPrint('SyncManager: Deleting task from Supabase: $taskId');

          await supabaseRepo.deleteTask(taskId);
          debugPrint(
            'SyncManager: Successfully deleted task from Supabase: $taskId',
          );
        } catch (e) {
          debugPrint(
            'SyncManager: Failed to delete task $taskId from Supabase: $e',
          );
        }
      }

      debugPrint(
        'SyncManager: Successfully synced ${pendingTaskDeletes.length} task deletes',
      );
      pendingTaskDeletes.clear();
    } catch (e) {
      debugPrint('SyncManager: Error syncing task deletes: $e');
    }
  }

  /// Sync pending audio deletes to Supabase
  Future<void> _syncAudioDeletes() async {
    debugPrint(
      'SyncManager: Syncing ${pendingAudioDeletes.length} audio deletes',
    );

    // TODO: Implement Supabase audio delete sync
    // This will be implemented when we create the SupabaseAudioRepository
    // For now, we'll just log and clear the pending list
    
    if (pendingAudioDeletes.isNotEmpty) {
      debugPrint('SyncManager: Audio delete sync pending - repository not yet implemented');
      debugPrint('SyncManager: Would delete ${pendingAudioDeletes.length} audio files from Supabase');
    }

    // Clear the pending list for now
    pendingAudioDeletes.clear();
  }

  /// Add task to sync queue
  void addTaskToSyncQueue(TaskEntity task) {
    if (!pendingTaskSync.contains(task)) {
      pendingTaskSync.add(task);
      debugPrint('SyncManager: Added task to sync queue: ${task.id}');
      _triggerSync();
    }
  }

  /// Add audio file to sync queue
  void addAudioToSyncQueue(AudioEntity audio) {
    if (!pendingAudioSync.contains(audio)) {
      pendingAudioSync.add(audio);
      debugPrint('SyncManager: Added audio to sync queue: ${audio.id}');
      _triggerSync();
    }
  }

  /// Add task delete to sync queue
  void addTaskDeleteToSyncQueue(String taskId) {
    if (!pendingTaskDeletes.contains(taskId)) {
      pendingTaskDeletes.add(taskId);
      debugPrint('SyncManager: Added task delete to sync queue: $taskId');
      _triggerSync();
    }
  }

  /// Add audio delete to sync queue
  void addAudioDeleteToSyncQueue(String audioId) {
    if (!pendingAudioDeletes.contains(audioId)) {
      pendingAudioDeletes.add(audioId);
      debugPrint('SyncManager: Added audio delete to sync queue: $audioId');
      _triggerSync();
    }
  }

  /// Manual sync trigger
  Future<void> manualSync() async {
    if (isSyncing.value) {
      Get.snackbar(
        'Sync in Progress',
        'Synchronization is already running',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _performSync();
      Get.snackbar(
        'Sync Complete',
        lastSyncSuccessful.value
            ? 'Data synchronized successfully'
            : 'Sync completed with errors',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: lastSyncSuccessful.value ? null : Colors.orange,
      );
    } catch (e) {
      Get.snackbar(
        'Sync Failed',
        'Failed to synchronize data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  /// Get sync status summary
  String get syncStatusSummary {
    if (isSyncing.value) {
      return 'Syncing...';
    }

    final totalPending = pendingTaskSync.length + pendingAudioSync.length;
    if (totalPending == 0) {
      return 'Up to date';
    }

    return '$totalPending items pending';
  }

  /// Check if sync is needed
  bool get needsSync =>
      pendingTaskSync.isNotEmpty || pendingAudioSync.isNotEmpty;

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}
