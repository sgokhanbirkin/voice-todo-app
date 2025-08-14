import 'package:get/get.dart';
import '../../domain/i_sync_service.dart';

/// Sync controller for managing synchronization operations
class SyncController extends GetxController {
  final ISyncService _syncService;

  /// Current sync status
  final Rx<SyncStatus?> syncStatus = Rx<SyncStatus?>(null);

  /// Last sync result
  final Rx<SyncResult?> lastSyncResult = Rx<SyncResult?>(null);

  /// Whether sync is currently in progress
  final RxBool isSyncing = false.obs;

  /// Error state
  final RxBool hasError = false.obs;

  /// Error message
  final RxString errorMessage = ''.obs;

  /// Auto sync enabled
  final RxBool autoSyncEnabled = false.obs;

  /// Pending sync items count
  final RxInt pendingSyncCount = 0.obs;

  /// Last sync time
  final Rx<DateTime?> lastSyncTime = Rx<DateTime?>(null);

  /// Sync progress (for UI indication)
  final RxDouble syncProgress = 0.0.obs;

  SyncController(this._syncService);

  @override
  void onInit() {
    super.onInit();
    loadSyncStatus();
    loadAutoSyncStatus();
    loadPendingSyncCount();
  }

  @override
  void onClose() {
    _syncService.stopBackgroundSync();
    super.onClose();
  }

  /// Load current sync status
  Future<void> loadSyncStatus() async {
    try {
      hasError.value = false;
      errorMessage.value = '';

      final result = await _syncService.getSyncStatus();

      result.fold(
        (status) {
          syncStatus.value = status;
          isSyncing.value = status.isSyncing;
          pendingSyncCount.value = status.pendingItems;
          lastSyncTime.value = status.lastSyncTime;
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
        },
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load sync status: $e';
    }
  }

  /// Load auto sync status
  Future<void> loadAutoSyncStatus() async {
    try {
      final result = await _syncService.isAutoSyncEnabled();
      result.fold(
        (enabled) {
          autoSyncEnabled.value = enabled;
        },
        (failure) {
          // Handle silently
        },
      );
    } catch (e) {
      // Handle silently
    }
  }

  /// Load pending sync count
  Future<void> loadPendingSyncCount() async {
    try {
      final result = await _syncService.getPendingSyncCount();
      result.fold(
        (count) {
          pendingSyncCount.value = count;
        },
        (failure) {
          // Handle silently
        },
      );
    } catch (e) {
      // Handle silently
    }
  }

  /// Sync all data
  Future<void> syncAll() async {
    try {
      if (isSyncing.value) {
        Get.snackbar('Info', 'Sync already in progress');
        return;
      }

      isSyncing.value = true;
      syncProgress.value = 0.0;
      hasError.value = false;
      errorMessage.value = '';

      Get.snackbar('Sync', 'Starting synchronization...');

      final result = await _syncService.syncAll();

      result.fold(
        (syncResult) {
          lastSyncResult.value = syncResult;
          syncProgress.value = 1.0;
          
          if (syncResult.isSuccessful) {
            Get.snackbar(
              'Success', 
              'Sync completed: ${syncResult.syncedItems} items synced',
            );
          } else {
            Get.snackbar(
              'Warning',
              'Sync completed with issues: ${syncResult.failedItems} failed, ${syncResult.conflicts} conflicts',
            );
          }

          // Refresh status
          loadSyncStatus();
          loadPendingSyncCount();
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
          Get.snackbar('Error', 'Sync failed: ${failure.message}');
        },
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected sync error: $e';
      Get.snackbar('Error', 'Unexpected sync error: $e');
    } finally {
      isSyncing.value = false;
      syncProgress.value = 0.0;
    }
  }

  /// Sync tasks only
  Future<void> syncTasks() async {
    try {
      if (isSyncing.value) {
        Get.snackbar('Info', 'Sync already in progress');
        return;
      }

      isSyncing.value = true;
      Get.snackbar('Sync', 'Syncing tasks...');

      final result = await _syncService.syncTasks();

      result.fold(
        (syncResult) {
          if (syncResult.isSuccessful) {
            Get.snackbar(
              'Success', 
              'Tasks synced: ${syncResult.syncedItems} items',
            );
          } else {
            Get.snackbar(
              'Warning',
              'Tasks sync completed with issues: ${syncResult.failedItems} failed',
            );
          }

          loadSyncStatus();
          loadPendingSyncCount();
        },
        (failure) {
          Get.snackbar('Error', 'Task sync failed: ${failure.message}');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Unexpected task sync error: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  /// Sync audio only
  Future<void> syncAudio() async {
    try {
      if (isSyncing.value) {
        Get.snackbar('Info', 'Sync already in progress');
        return;
      }

      isSyncing.value = true;
      Get.snackbar('Sync', 'Syncing audio files...');

      final result = await _syncService.syncAudio();

      result.fold(
        (syncResult) {
          if (syncResult.isSuccessful) {
            Get.snackbar(
              'Success', 
              'Audio synced: ${syncResult.syncedItems} files',
            );
          } else {
            Get.snackbar(
              'Warning',
              'Audio sync completed with issues: ${syncResult.failedItems} failed',
            );
          }

          loadSyncStatus();
          loadPendingSyncCount();
        },
        (failure) {
          Get.snackbar('Error', 'Audio sync failed: ${failure.message}');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Unexpected audio sync error: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  /// Pull data from remote
  Future<void> pullFromRemote() async {
    try {
      if (isSyncing.value) {
        Get.snackbar('Info', 'Sync already in progress');
        return;
      }

      isSyncing.value = true;
      Get.snackbar('Sync', 'Pulling data from remote...');

      final result = await _syncService.pullFromRemote();

      result.fold(
        (syncResult) {
          if (syncResult.isSuccessful) {
            Get.snackbar(
              'Success', 
              'Data pulled: ${syncResult.syncedItems} items updated',
            );
          } else {
            Get.snackbar(
              'Warning',
              'Pull completed with issues: ${syncResult.conflicts} conflicts',
            );
          }

          loadSyncStatus();
          loadPendingSyncCount();
        },
        (failure) {
          Get.snackbar('Error', 'Pull failed: ${failure.message}');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Unexpected pull error: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  /// Toggle auto sync
  Future<void> toggleAutoSync() async {
    try {
      final newValue = !autoSyncEnabled.value;
      final result = await _syncService.setAutoSync(newValue);

      result.fold(
        (_) {
          autoSyncEnabled.value = newValue;
          Get.snackbar(
            'Settings', 
            'Auto sync ${newValue ? 'enabled' : 'disabled'}',
          );
        },
        (failure) {
          Get.snackbar('Error', 'Failed to toggle auto sync: ${failure.message}');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
    }
  }

  /// Force sync (ignore intervals)
  Future<void> forceSync() async {
    try {
      if (isSyncing.value) {
        Get.snackbar('Info', 'Sync already in progress');
        return;
      }

      isSyncing.value = true;
      Get.snackbar('Sync', 'Force syncing all data...');

      final result = await _syncService.forceSync();

      result.fold(
        (syncResult) {
          lastSyncResult.value = syncResult;
          
          if (syncResult.isSuccessful) {
            Get.snackbar(
              'Success', 
              'Force sync completed: ${syncResult.syncedItems} items synced',
            );
          } else {
            Get.snackbar(
              'Warning',
              'Force sync completed with issues: ${syncResult.failedItems} failed',
            );
          }

          loadSyncStatus();
          loadPendingSyncCount();
        },
        (failure) {
          Get.snackbar('Error', 'Force sync failed: ${failure.message}');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Unexpected force sync error: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  /// Get sync status summary for UI
  String get syncStatusSummary {
    if (isSyncing.value) {
      return 'Syncing...';
    }

    if (pendingSyncCount.value > 0) {
      return '${pendingSyncCount.value} items pending sync';
    }

    if (lastSyncTime.value != null) {
      final now = DateTime.now();
      final diff = now.difference(lastSyncTime.value!);
      
      if (diff.inMinutes < 1) {
        return 'Synced just now';
      } else if (diff.inHours < 1) {
        return 'Synced ${diff.inMinutes}m ago';
      } else if (diff.inDays < 1) {
        return 'Synced ${diff.inHours}h ago';
      } else {
        return 'Synced ${diff.inDays}d ago';
      }
    }

    return 'Never synced';
  }

  /// Get sync status color for UI
  String get syncStatusColor {
    if (isSyncing.value) {
      return 'blue';
    }

    if (hasError.value) {
      return 'red';
    }

    if (pendingSyncCount.value > 0) {
      return 'orange';
    }

    return 'green';
  }

  /// Refresh all sync data
  @override
  Future<void> refresh() async {
    await loadSyncStatus();
    await loadAutoSyncStatus();
    await loadPendingSyncCount();
  }
}
