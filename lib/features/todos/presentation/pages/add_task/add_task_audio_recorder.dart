part of 'add_task_page.dart';

/// Audio recording component with play/pause/delete functionality
/// Provides visual feedback and error handling for audio operations
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

          // Recording Controls
          ResponsiveBuilder(
            mobile: (context) => Column(
              children: [
                _buildRecordButton(context, l10n, isRecording),
                if (audioPath != null) ...[
                  SizedBox(height: 12.h),
                  _buildPlayButton(context, l10n, isPlaying),
                ],
              ],
            ),
            tablet: (context) => Row(
              children: [
                Expanded(child: _buildRecordButton(context, l10n, isRecording)),
                if (audioPath != null) ...[
                  SizedBox(width: 16.w),
                  Expanded(child: _buildPlayButton(context, l10n, isPlaying)),
                ],
              ],
            ),
            desktop: (context) => Row(
              children: [
                Expanded(child: _buildRecordButton(context, l10n, isRecording)),
                if (audioPath != null) ...[
                  SizedBox(width: 24.w),
                  Expanded(child: _buildPlayButton(context, l10n, isPlaying)),
                ],
              ],
            ),
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
              child: Row(
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
                          ? 'Recording in progress...'
                          : 'Audio recorded successfully',
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

  /// Build play button
  Widget _buildPlayButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isPlaying,
  ) {
    return ElevatedButton.icon(
      onPressed: isPlaying ? _pauseAudio : _playAudio,
      icon: Icon(
        isPlaying ? Icons.pause : Icons.play_arrow,
        color: AppColors.audioPlaying,
      ),
      label: Text(
        isPlaying ? l10n.pauseAudio : l10n.playAudio,
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
  }

  /// Start recording audio
  Future<void> _startRecording() async {
    try {
      await audioController.startRecording();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start recording: $e',
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  /// Stop recording audio
  Future<void> _stopRecording() async {
    try {
      await audioController.stopRecording();
      
      // AudioController should provide the recorded path
      onAudioPathChanged('recorded_audio_${DateTime.now().millisecondsSinceEpoch}.m4a');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to stop recording: $e',
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
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
        Get.snackbar(
          'Error',
          'Failed to play audio: $e',
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    }
  }

  /// Pause audio
  Future<void> _pauseAudio() async {
    try {
      await audioController.pausePlayback();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pause audio: $e',
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }
}
