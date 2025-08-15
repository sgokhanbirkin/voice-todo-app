part of 'add_task_page.dart';

/// Audio recording component with play/pause/delete functionality
/// Provides visual feedback and error handling for audio operations
///
/// TODO LOCALIZATION
class _AddTaskAudioRecorder extends StatelessWidget {
  final String? audioPath;
  final Function(String?) onAudioPathChanged;
  final AudioController audioController;

  const _AddTaskAudioRecorder({
    required this.audioPath,
    required this.onAudioPathChanged,
    required this.audioController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final isRecording = audioController.isRecording.value;
      final isPlaying = audioController.isPlaying.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recordVoice,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: Responsive.getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: Responsive.getResponsiveSpacing(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),

          // Recording Controls - Always in Row
          Row(
            children: [
              Expanded(child: _buildRecordButton(context, l10n, isRecording)),
              if (audioPath != null) ...[
                SizedBox(
                  width: Responsive.getResponsiveSpacing(
                    context,
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                Expanded(child: _buildPlayButton(context, l10n, isPlaying)),
              ],
            ],
          ),

          // Audio visualization or status
          if (isRecording || audioPath != null) ...[
            SizedBox(
              height: Responsive.getResponsiveSpacing(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status row
                  Row(
                    children: [
                      Icon(
                        isRecording ? Icons.mic : Icons.audio_file,
                        color: isRecording
                            ? AppColors.audioRecording
                            : AppColors.audioStopped,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          isRecording
                              ? l10n.recordingInProgress
                              : l10n.audioRecordedSuccessfully,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      if (audioPath != null)
                        IconButton(
                          onPressed: () {
                            onAudioPathChanged(null);
                            audioController.stopPlayback();
                          },
                          icon: const Icon(Icons.delete_outline),
                          iconSize: 18.sp,
                        ),
                    ],
                  ),

                  // Live transcription display
                  if (isRecording) ...[
                    SizedBox(height: 8.h),
                    Obx(() {
                      final recognizedText =
                          audioController.recognizedText.value;
                      final isListening = audioController.isListening.value;

                      if (isListening && recognizedText.isNotEmpty) {
                        return Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 16.sp,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  recognizedText,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  /// Build record button
  Widget _buildRecordButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isRecording,
  ) {
    return ElevatedButton.icon(
      onPressed: isRecording ? _stopRecording : _startRecording,
      icon: Icon(
        isRecording ? Icons.stop : Icons.mic,
        color: isRecording ? AppColors.error : AppColors.audioRecording,
      ),
      label: Text(
        isRecording ? l10n.stopRecording : l10n.recordVoice,
        style: TextStyle(
          fontSize: Responsive.getResponsiveFontSize(
            context,
            mobile: 14,
            tablet: 16,
            desktop: 18,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isRecording
            ? AppColors.error.withValues(alpha: 0.1)
            : AppColors.audioRecording.withValues(alpha: 0.1),
        foregroundColor: isRecording
            ? AppColors.error
            : AppColors.audioRecording,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  /// Build play button with reactive icon states
  Widget _buildPlayButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isPlaying,
  ) {
    return Obx(() {
      // Get reactive states from AudioController
      final isBuffering = audioController.isBuffering.value;
      final isCompleted = audioController.isCompleted.value;
      final isCurrentlyPlaying = audioController.isPlaying.value;

      // Determine icon and action based on state
      IconData icon;
      String label;
      VoidCallback? onPressed;

      if (isBuffering) {
        // Buffering: show spinner
        icon = Icons.autorenew;
        label = l10n.loading;
        onPressed = null; // Disabled during buffering
      } else if (isCurrentlyPlaying) {
        // Playing: show pause
        icon = Icons.pause;
        label = l10n.pauseAudio;
        onPressed = _pauseAudio;
      } else if (isCompleted) {
        // Completed: show replay
        icon = Icons.replay;
        label = l10n.playAudio; // Use existing key for now
        onPressed = _playAudio;
      } else {
        // Stopped/Paused: show play
        icon = Icons.play_arrow;
        label = l10n.playAudio;
        onPressed = _playAudio;
      }

      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: isBuffering
            ? SizedBox(
                width: 16.w,
                height: 16.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.audioPlaying,
                  ),
                ),
              )
            : Icon(icon, color: AppColors.audioPlaying),
        label: Text(
          label,
          style: TextStyle(
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.audioPlaying.withValues(alpha: 0.1),
          foregroundColor: AppColors.audioPlaying,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      );
    });
  }

  /// Start recording audio
  Future<void> _startRecording() async {
    try {
      debugPrint('AddTaskAudioRecorder: _startRecording called');
      await audioController.startRecording();
      debugPrint('AddTaskAudioRecorder: startRecording completed successfully');
    } catch (e, stackTrace) {
      debugPrint('AddTaskAudioRecorder: Failed to start recording: $e');
      debugPrint('AddTaskAudioRecorder: Error stack trace: $stackTrace');
      debugPrint('AddTaskAudioRecorder: Error type: ${e.runtimeType}');

      // Use Flutter's native SnackBar instead of Get.snackbar
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Stop recording audio
  Future<void> _stopRecording() async {
    try {
      await audioController.stopRecording();

      // AudioController'dan gerçek path'i al
      final lastRecordedPath = audioController.getLastRecordedAudioPath();
      if (lastRecordedPath != null) {
        onAudioPathChanged(lastRecordedPath);
        debugPrint(
          'AddTaskAudioRecorder: Updated audio path: $lastRecordedPath',
        );
      } else {
        debugPrint('AddTaskAudioRecorder: No recorded audio path found');
      }
    } catch (e) {
      // Use Flutter's native SnackBar instead of Get.snackbar
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text('Failed to stop recording: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Play audio
  Future<void> _playAudio() async {
    if (audioPath != null) {
      try {
        // Create a temporary AudioEntity for playback
        final audioEntity = AudioEntity(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          taskId: 'temp_task',
          fileName: audioPath!,
          localPath: audioPath!,
          fileSize: 0, // Will be determined during playback
          duration: const Duration(
            seconds: 0,
          ), // Will be determined during playback
          format: 'm4a',
          recordedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await audioController.playAudio(audioEntity);
      } catch (e) {
        // Use Flutter's native SnackBar instead of Get.snackbar
        if (Get.context != null) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text('Failed to play audio: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// Pause audio
  Future<void> _pauseAudio() async {
    try {
      await audioController.pausePlayback();
    } catch (e) {
      // Use Flutter's native SnackBar instead of Get.snackbar
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text('Failed to pause audio: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
