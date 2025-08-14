import '../../../core/result.dart';

/// Sync service interface for managing local-remote synchronization
abstract class ISyncService {
  /// Sync all pending tasks to remote storage
  Future<AppResult<SyncResult>> syncTasks();

  /// Sync all pending audio files to remote storage
  Future<AppResult<SyncResult>> syncAudio();

  /// Sync all data (tasks and audio)
  Future<AppResult<SyncResult>> syncAll();

  /// Pull latest data from remote storage
  Future<AppResult<SyncResult>> pullFromRemote();

  /// Push local changes to remote storage
  Future<AppResult<SyncResult>> pushToRemote();

  /// Resolve sync conflicts
  Future<AppResult<List<ConflictResolution>>> resolveConflicts();

  /// Get sync status
  Future<AppResult<SyncStatus>> getSyncStatus();

  /// Enable/disable automatic sync
  Future<AppResult<void>> setAutoSync(bool enabled);

  /// Check if auto sync is enabled
  Future<AppResult<bool>> isAutoSyncEnabled();

  /// Start background sync (periodic)
  Future<AppResult<void>> startBackgroundSync();

  /// Stop background sync
  Future<AppResult<void>> stopBackgroundSync();

  /// Force sync (ignore sync intervals)
  Future<AppResult<SyncResult>> forceSync();

  /// Get last sync timestamp
  Future<AppResult<DateTime?>> getLastSyncTime();

  /// Get pending sync items count
  Future<AppResult<int>> getPendingSyncCount();
}

/// Sync operation result
class SyncResult {
  /// Number of items synced successfully
  final int syncedItems;

  /// Number of items that failed to sync
  final int failedItems;

  /// Number of conflicts encountered
  final int conflicts;

  /// Sync operation duration
  final Duration duration;

  /// Sync start time
  final DateTime startTime;

  /// Sync end time
  final DateTime endTime;

  /// Detailed sync operations
  final List<SyncOperation> operations;

  /// Any errors encountered during sync
  final List<String> errors;

  const SyncResult({
    required this.syncedItems,
    required this.failedItems,
    required this.conflicts,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.operations,
    required this.errors,
  });

  /// Total items processed
  int get totalItems => syncedItems + failedItems;

  /// Sync success rate
  double get successRate => totalItems > 0 ? syncedItems / totalItems : 0.0;

  /// Whether sync was completely successful
  bool get isSuccessful => failedItems == 0 && conflicts == 0 && errors.isEmpty;

  @override
  String toString() {
    return 'SyncResult(synced: $syncedItems, failed: $failedItems, conflicts: $conflicts)';
  }
}

/// Individual sync operation
class SyncOperation {
  /// Type of item being synced
  final SyncItemType itemType;

  /// Item ID
  final String itemId;

  /// Sync operation type
  final SyncOperationType operationType;

  /// Operation status
  final SyncOperationStatus status;

  /// Error message if failed
  final String? error;

  /// Operation timestamp
  final DateTime timestamp;

  const SyncOperation({
    required this.itemType,
    required this.itemId,
    required this.operationType,
    required this.status,
    this.error,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'SyncOperation($itemType $operationType $itemId: $status)';
  }
}

/// Types of items that can be synced
enum SyncItemType {
  /// Task item
  task,

  /// Audio item
  audio,

  /// User settings
  settings,
}

/// Types of sync operations
enum SyncOperationType {
  /// Create new item remotely
  create,

  /// Update existing item remotely
  update,

  /// Delete item remotely
  delete,

  /// Download item from remote
  download,
}

/// Sync operation status
enum SyncOperationStatus {
  /// Operation pending
  pending,

  /// Operation in progress
  inProgress,

  /// Operation completed successfully
  completed,

  /// Operation failed
  failed,

  /// Operation skipped due to conflict
  skipped,
}

/// Overall sync status
class SyncStatus {
  /// Whether sync is currently in progress
  final bool isSyncing;

  /// Last sync timestamp
  final DateTime? lastSyncTime;

  /// Next scheduled sync time
  final DateTime? nextSyncTime;

  /// Number of pending items to sync
  final int pendingItems;

  /// Auto sync enabled status
  final bool autoSyncEnabled;

  /// Sync interval in minutes
  final int syncIntervalMinutes;

  /// Last sync result
  final SyncResult? lastSyncResult;

  const SyncStatus({
    required this.isSyncing,
    this.lastSyncTime,
    this.nextSyncTime,
    required this.pendingItems,
    required this.autoSyncEnabled,
    required this.syncIntervalMinutes,
    this.lastSyncResult,
  });

  @override
  String toString() {
    return 'SyncStatus(syncing: $isSyncing, pending: $pendingItems, autoSync: $autoSyncEnabled)';
  }
}

/// Conflict resolution strategy
class ConflictResolution {
  /// Item ID with conflict
  final String itemId;

  /// Type of item
  final SyncItemType itemType;

  /// Local version timestamp
  final DateTime localTimestamp;

  /// Remote version timestamp
  final DateTime remoteTimestamp;

  /// Resolution strategy to use
  final ConflictStrategy strategy;

  /// Reason for the conflict
  final String conflictReason;

  const ConflictResolution({
    required this.itemId,
    required this.itemType,
    required this.localTimestamp,
    required this.remoteTimestamp,
    required this.strategy,
    required this.conflictReason,
  });

  @override
  String toString() {
    return 'ConflictResolution($itemId: $strategy - $conflictReason)';
  }
}

/// Conflict resolution strategies
enum ConflictStrategy {
  /// Use local version (overwrite remote)
  useLocal,

  /// Use remote version (overwrite local)
  useRemote,

  /// Use the newer version (based on timestamp)
  useNewer,

  /// Use the older version (based on timestamp)
  useOlder,

  /// Skip this item (manual resolution required)
  skip,

  /// Merge both versions (if possible)
  merge,
}
