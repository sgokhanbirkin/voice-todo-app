import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../product/responsive/responsive.dart';
import '../../../../product/theme/app_theme.dart';
import '../controllers/audio_controller.dart';

// TODO Localization
// TODO Responsive
/// Widget for recording audio with visual feedback
class AudioRecorderWidget extends StatelessWidget {
  final String taskId;
  final Function(String audioPath)? onAudioRecorded;

  const AudioRecorderWidget({
    super.key,
    required this.taskId,
    this.onAudioRecorded,
  });

  @override
  Widget build(BuildContext context) {
    final audioController = Get.find<AudioController>();

    return Obx(() {
      final isRecording = audioController.isRecording.value;
      final recordingDuration = audioController.recordingDuration.value;
      final amplitude = audioController.amplitude.value;

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
            color: isRecording
                ? AppColors.error
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: isRecording ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.mic,
                  color: isRecording
                      ? AppColors.error
                      : Theme.of(context).colorScheme.primary,
                  size: Responsive.getResponsiveSpacing(
                    context,
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  ),
                ),
                SizedBox(
                  width: Responsive.getResponsiveSpacing(
                    context,
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                Expanded(
                  child: Text(
                    isRecording ? 'Ses Kaydediliyor...' : 'Ses Kaydı',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: Responsive.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),

            // Recording visualization
            if (isRecording) ...[
              _buildRecordingVisualization(context, amplitude),
              ResponsiveWidgets.verticalSpace(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ],

            // Duration display
            if (isRecording) ...[
              _buildDurationDisplay(context, recordingDuration),
              SizedBox(
                height: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
            ],

            // Control buttons
            _buildControlButtons(context, audioController),
          ],
        ),
      );
    });
  }

  Widget _buildRecordingVisualization(BuildContext context, double amplitude) {
    return Container(
      height: Responsive.getResponsiveSpacing(
        context,
        mobile: 60,
        tablet: 80,
        desktop: 100,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            20,
            (index) => Container(
              width: 3,
              height: (amplitude * 100 * (index + 1) / 20).clamp(10.0, 80.0),
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationDisplay(BuildContext context, Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final formattedDuration =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Center(
      child: Text(
        formattedDuration,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildControlButtons(
    BuildContext context,
    AudioController audioController,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Record/Stop button
        Obx(() {
          final isRecording = audioController.isRecording.value;

          return ElevatedButton.icon(
            onPressed: () {
              if (isRecording) {
                _stopRecording(audioController);
              } else {
                _startRecording(audioController);
              }
            },
            icon: Icon(isRecording ? Icons.stop : Icons.mic),
            label: Text(isRecording ? 'Durdur' : 'Kaydet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isRecording
                  ? AppColors.error
                  : AppColors.success,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
                vertical: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
            ),
          );
        }),

        // Cancel button (only show when recording)
        Obx(() {
          final isRecording = audioController.isRecording.value;

          if (!isRecording) return const SizedBox.shrink();

          return ElevatedButton.icon(
            onPressed: () => _cancelRecording(audioController),
            icon: const Icon(Icons.close),
            label: const Text('İptal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
                vertical: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _startRecording(AudioController audioController) async {
    try {
      await audioController.startRecording();
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Ses kaydı başlatılamadı: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _stopRecording(AudioController audioController) async {
    try {
      await audioController.stopRecording();
      final audioPath = audioController.getLastRecordedAudioPath();
      if (onAudioRecorded != null && audioPath != null) {
        onAudioRecorded!(audioPath);
      }

      Get.snackbar(
        'Başarılı',
        'Ses kaydı tamamlandı!',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Ses kaydı durdurulamadı: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _cancelRecording(AudioController audioController) async {
    try {
      await audioController.cancelRecording();
      Get.snackbar(
        'İptal Edildi',
        'Ses kaydı iptal edildi',
        backgroundColor: AppColors.secondaryTeal,
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Ses kaydı iptal edilemedi: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
}
