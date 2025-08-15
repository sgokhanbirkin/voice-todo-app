import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/sync/sync_manager.dart';
import '../responsive/responsive.dart';

/// Widget to display sync status and allow manual sync
class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final syncManager = Get.find<SyncManager>();

    return Obx(() {
      final isSyncing = syncManager.isSyncing.value;
      final needsSync = syncManager.needsSync;
      final syncStatus = syncManager.syncStatusSummary;
      final lastSyncTime = syncManager.lastSyncTime.value;

      // Get detailed sync info
      final pendingTasks = syncManager.pendingTaskSync.length;
      final pendingAudio = syncManager.pendingAudioSync.length;
      final pendingTaskDeletes = syncManager.pendingTaskDeletes.length;
      final pendingAudioDeletes = syncManager.pendingAudioDeletes.length;

      return Container(
        padding: EdgeInsets.all(
          Responsive.getResponsiveSpacing(
            context,
            mobile: 12,
            tablet: 16,
            desktop: 20,
          ),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSyncing ? Icons.sync : Icons.cloud_sync,
                  color: isSyncing
                      ? Theme.of(context).colorScheme.primary
                      : needsSync
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.tertiary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sync Status',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (needsSync && !isSyncing)
                  ElevatedButton.icon(
                    onPressed: () => syncManager.manualSync(),
                    icon: Icon(Icons.sync, size: 16),
                    label: Text('Sync Now', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              syncStatus,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSyncing
                    ? Theme.of(context).colorScheme.primary
                    : needsSync
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Show detailed sync info
            if (needsSync && !isSyncing) ...[
              SizedBox(height: 8),
              _buildSyncDetails(
                context,
                pendingTasks,
                pendingAudio,
                pendingTaskDeletes,
                pendingAudioDeletes,
              ),
            ],
            if (lastSyncTime != null) ...[
              SizedBox(height: 4),
              Text(
                'Last sync: ${_formatLastSyncTime(lastSyncTime)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            if (isSyncing) ...[
              SizedBox(height: 8),
              LinearProgressIndicator(
                backgroundColor: Theme.of(context).colorScheme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Format last sync time
  String _formatLastSyncTime(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  /// Build detailed sync information widget
  Widget _buildSyncDetails(
    BuildContext context,
    int pendingTasks,
    int pendingAudio,
    int pendingTaskDeletes,
    int pendingAudioDeletes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pendingTasks > 0)
          _buildSyncItem(context, '📝 Tasks', pendingTasks, Colors.blue),
        if (pendingAudio > 0)
          _buildSyncItem(context, '🎵 Audio', pendingAudio, Colors.green),
        if (pendingTaskDeletes > 0)
          _buildSyncItem(
            context,
            '🗑️ Task Deletes',
            pendingTaskDeletes,
            Colors.red,
          ),
        if (pendingAudioDeletes > 0)
          _buildSyncItem(
            context,
            '🗑️ Audio Deletes',
            pendingAudioDeletes,
            Colors.orange,
          ),
      ],
    );
  }

  /// Build individual sync item
  Widget _buildSyncItem(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          SizedBox(width: 8),
          Text(
            '$label: $count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
