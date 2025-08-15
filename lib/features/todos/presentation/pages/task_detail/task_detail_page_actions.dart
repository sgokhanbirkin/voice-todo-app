part of 'task_detail_page.dart';

/// Action Button Widget'ları
extension _TaskDetailPageActions on _TaskDetailPageState {
  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        // Status toggle
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _toggleTaskStatus,
            icon: Icon(
              _task!.status == TaskStatus.completed ? Icons.undo : Icons.check,
            ),
            label: Text(
              _task!.status == TaskStatus.completed ? l10n.undo : l10n.complete,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _task!.status == TaskStatus.completed
                  ? Theme.of(context).colorScheme.secondary
                  : AppColors.success,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        if (_isEditing) ...[
          ResponsiveWidgets.horizontalSpace(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          ),

          // Save button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: Text(l10n.save),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
