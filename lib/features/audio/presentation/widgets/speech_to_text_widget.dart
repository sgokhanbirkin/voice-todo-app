import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../product/responsive/responsive.dart';
import '../../../../product/theme/app_theme.dart';
import '../controllers/audio_controller.dart';

// TODO Localization
// TODO Responsive
/// Widget for converting speech to text
class SpeechToTextWidget extends StatelessWidget {
  final Function(String text)? onTextRecognized;
  final String? initialText;
  final String? hintText;

  const SpeechToTextWidget({
    super.key,
    this.onTextRecognized,
    this.initialText,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final audioController = Get.find<AudioController>();

    return Obx(() {
      final isListening = audioController.isListening.value;
      final recognizedText = audioController.recognizedText.value;
      final speechState = audioController.speechState.value;
      final confidence = audioController.speechConfidence.value;

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
            color: isListening
                ? AppColors.primaryBlue
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: isListening ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  isListening ? Icons.record_voice_over : Icons.mic_none,
                  color: isListening
                      ? AppColors.primaryBlue
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
                    isListening ? 'Dinleniyor...' : 'Sesden Yazıya',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            ResponsiveWidgets.verticalSpace(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),

            // Status indicator
            if (isListening) ...[
              _buildStatusIndicator(context, speechState, confidence),
              SizedBox(
                height: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
            ],

            // Recognized text display
            _buildTextDisplay(context, recognizedText),

            SizedBox(
              height: Responsive.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),

            // Control buttons
            _buildControlButtons(context, audioController),
          ],
        ),
      );
    });
  }

  Widget _buildStatusIndicator(
    BuildContext context,
    dynamic speechState,
    double confidence,
  ) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (speechState.toString()) {
      case 'SpeechRecognitionState.listening':
        statusColor = AppColors.primaryBlue;
        statusIcon = Icons.record_voice_over;
        statusText = 'Dinleniyor...';
        break;
      case 'SpeechRecognitionState.processing':
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_empty;
        statusText = 'İşleniyor...';
        break;
      case 'SpeechRecognitionState.completed':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        statusText = 'Tamamlandı';
        break;
      case 'SpeechRecognitionState.error':
        statusColor = AppColors.error;
        statusIcon = Icons.error;
        statusText = 'Hata';
        break;
      default:
        statusColor = Theme.of(context).colorScheme.onSurface;
        statusIcon = Icons.info;
        statusText = 'Hazır';
    }

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
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (confidence > 0) ...[
            const Spacer(),
            Text(
              '${(confidence * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextDisplay(BuildContext context, String text) {
    final displayText = text.isNotEmpty
        ? text
        : (initialText ?? hintText ?? 'Ses kaydı başlatın...');
    final isPlaceholder = text.isEmpty && initialText == null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        Responsive.getResponsiveSpacing(
          context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        displayText,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isPlaceholder
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.onSurface,
          fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
        ),
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
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
        // Listen/Stop button
        Obx(() {
          final isListening = audioController.isListening.value;

          return ElevatedButton.icon(
            onPressed: () {
              if (isListening) {
                _stopListening(audioController);
              } else {
                _startListening(audioController);
              }
            },
            icon: Icon(isListening ? Icons.stop : Icons.mic),
            label: Text(isListening ? 'Durdur' : 'Dinle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isListening
                  ? AppColors.error
                  : AppColors.primaryBlue,
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

        // Clear button
        ElevatedButton.icon(
          onPressed: () => _clearText(audioController),
          icon: const Icon(Icons.clear),
          label: const Text('Temizle'),
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
        ),

        // Use text button
        Obx(() {
          final hasText = audioController.recognizedText.value.isNotEmpty;

          if (!hasText) return const SizedBox.shrink();

          return ElevatedButton.icon(
            onPressed: () => _useText(audioController),
            icon: const Icon(Icons.check),
            label: const Text('Kullan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
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
      ],
    );
  }

  Future<void> _startListening(AudioController audioController) async {
    try {
      await audioController.startSpeechRecognition();
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Ses tanıma başlatılamadı: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _stopListening(AudioController audioController) async {
    try {
      await audioController.stopSpeechRecognition();
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Ses tanıma durdurulamadı: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  void _clearText(AudioController audioController) {
    audioController.clearRecognizedText();
    Get.snackbar(
      'Temizlendi',
      'Metin temizlendi',
      backgroundColor: AppColors.secondaryTeal,
      colorText: Colors.black,
    );
  }

  void _useText(AudioController audioController) {
    final text = audioController.getRecognizedText();
    if (text.isNotEmpty && onTextRecognized != null) {
      onTextRecognized!(text);
      Get.snackbar(
        'Başarılı',
        'Metin kullanıldı!',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    }
  }
}
