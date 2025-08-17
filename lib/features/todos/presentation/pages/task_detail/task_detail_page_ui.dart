part of 'task_detail_page.dart';

/// UI Widget'ları
extension _TaskDetailPageUI on _TaskDetailPageState {
  Widget _buildHeaderSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(
        Responsive.getResponsiveSpacing(
          context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: Task title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.task,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ResponsiveWidgets.verticalSpace(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
                Text(
                  _task!.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ResponsiveWidgets.horizontalSpace(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
          // Right column: Action buttons in a single row
          Row(
            children: [
              // Star/Unstar button
              IconButton(
                onPressed: _toggleStarred,
                icon: Icon(
                  _task!.isStarred ? Icons.star : Icons.star_border,
                  color: _task!.isStarred
                      ? AppColors.warning
                      : Theme.of(context).colorScheme.onSurface,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: _task!.isStarred
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              ResponsiveWidgets.horizontalSpace(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
              // Edit/View toggle button
              IconButton(
                onPressed: _toggleEditing,
                icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer,
                ),
              ),
              ResponsiveWidgets.horizontalSpace(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
              // Delete button
              IconButton(
                onPressed: _deleteTask,
                icon: const Icon(Icons.delete),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskContent(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        if (_task!.description != null) ...[
          Text(
            _task!.description!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          ResponsiveWidgets.verticalSpace(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
        ],

        // Task info cards
        _buildInfoCards(context, l10n),

        ResponsiveWidgets.verticalSpace(
          context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),

        // Audio section
        if (_task!.audioPath != null) ...[_buildAudioSection(context, l10n)],
      ],
    );
  }

  Widget _buildInfoCards(BuildContext context, AppLocalizations l10n) {
    return Wrap(
      spacing: Responsive.getResponsiveSpacing(
        context,
        mobile: 12,
        tablet: 16,
        desktop: 20,
      ),
      runSpacing: Responsive.getResponsiveSpacing(
        context,
        mobile: 12,
        tablet: 16,
        desktop: 20,
      ),
      children: [
        _buildInfoCard(
          context,
          l10n.priority,
          _getPriorityText(_task!.priority),
          _getPriorityColor(_task!.priority),
          Icons.priority_high,
        ),
        _buildInfoCard(
          context,
          l10n.status,
          _task!.status == TaskStatus.completed ? l10n.completed : l10n.pending,
          _task!.status == TaskStatus.completed
              ? AppColors.success
              : AppColors.warning,
          _task!.status == TaskStatus.completed
              ? Icons.check_circle
              : Icons.schedule,
        ),
        _buildInfoCard(
          context,
          l10n.createdAt,
          _formatDate(_task!.createdAt),
          Theme.of(context).colorScheme.primary,
          Icons.schedule,
        ),
        if (_task!.dueDate != null)
          _buildInfoCard(
            context,
            l10n.dueDate,
            _formatDate(_task!.dueDate!),
            _task!.dueDate!.isBefore(DateTime.now())
                ? AppColors.error
                : Theme.of(context).colorScheme.secondary,
            Icons.event,
          ),
        if (_task!.isStarred)
          _buildInfoCard(
            context,
            l10n.starred,
            l10n.yes,
            AppColors.warning,
            Icons.star,
          ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              ResponsiveWidgets.horizontalSpace(
                context,
                mobile: 6,
                tablet: 8,
                desktop: 10,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          ResponsiveWidgets.verticalSpace(
            context,
            mobile: 6,
            tablet: 8,
            desktop: 10,
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(
        Responsive.getResponsiveSpacing(
          context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mic, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.audioRecording,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          ResponsiveWidgets.verticalSpace(
            context,
            mobile: 12,
            tablet: 16,
            desktop: 20,
          ),
          Row(
            children: [
              // Play/Pause button with reactive icon states
              Obx(() {
                final isBuffering = _audioController.isBuffering.value;
                final isCompleted = _audioController.isCompleted.value;
                final isPlaying = _audioController.isPlaying.value;

                // Determine icon and action based on state
                IconData icon;
                VoidCallback? onPressed;

                if (isBuffering) {
                  // Buffering: show spinner
                  icon = Icons.autorenew;
                  onPressed = null; // Disabled during buffering
                } else if (isPlaying) {
                  // Playing: show pause
                  icon = Icons.pause;
                  onPressed = () {
                    if (_audioPath != null) {
                      _audioController.pauseAudio();
                    }
                  };
                } else if (isCompleted) {
                  // Completed: show replay
                  icon = Icons.replay;
                  onPressed = () {
                    if (_audioPath != null) {
                      _playAudioFromPath(_audioPath!);
                    }
                  };
                } else {
                  // Stopped/Paused: show play
                  icon = Icons.play_arrow;
                  onPressed = () {
                    if (_audioPath != null) {
                      _playAudioFromPath(_audioPath!);
                    }
                  };
                }

                return IconButton(
                  onPressed: onPressed,
                  icon: isBuffering
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Icon(icon),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                );
              }),

              ResponsiveWidgets.horizontalSpace(
                context,
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),

              // Stop button
              IconButton(
                onPressed: () {
                  if (_audioPath != null) {
                    _audioController.stopAudio();
                  }
                },
                icon: const Icon(Icons.stop),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),

              ResponsiveWidgets.horizontalSpace(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),

              Expanded(
                child: Text(
                  l10n.audioFileAvailable,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
