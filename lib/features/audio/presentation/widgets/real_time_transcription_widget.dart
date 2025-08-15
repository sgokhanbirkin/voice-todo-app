import 'package:flutter/material.dart';
import 'package:voice_todo/product/responsive/responsive.dart';
import '../controllers/voice_commands_controller.dart';

// TODO Localization
// TODO Responsive
/// Real-time Transcription Widget - Konuşurken metni gerçek zamanlı gösterir
class RealTimeTranscriptionWidget extends StatefulWidget {
  final VoiceCommandsController controller;
  final Function(String text)? onTextTranscribed;
  final Function(VoiceCommandType command, Map<String, dynamic> data)?
  onCommandDetected;

  const RealTimeTranscriptionWidget({
    super.key,
    required this.controller,
    this.onTextTranscribed,
    this.onCommandDetected,
  });

  @override
  State<RealTimeTranscriptionWidget> createState() =>
      _RealTimeTranscriptionWidgetState();
}

class _RealTimeTranscriptionWidgetState
    extends State<RealTimeTranscriptionWidget> {
  final TextEditingController _textController = TextEditingController();
  bool _isListening = false;
  String _recognizedText = '';
  double _confidence = 0.0;
  VoiceRecognitionState _recognitionState = VoiceRecognitionState.notListening;

  @override
  void initState() {
    super.initState();
    _setupControllerCallbacks();
    _setupStreamListeners();
  }

  /// Setup controller callbacks
  void _setupControllerCallbacks() {
    widget.controller.onTextInput = (text) {
      widget.onTextTranscribed?.call(text);
    };

    widget.controller.onAddTaskCommand = (data) {
      widget.onCommandDetected?.call(VoiceCommandType.addTask, data);
    };

    widget.controller.onCompleteTaskCommand = (data) {
      widget.onCommandDetected?.call(VoiceCommandType.completeTask, data);
    };

    widget.controller.onDeleteTaskCommand = (data) {
      widget.onCommandDetected?.call(VoiceCommandType.deleteTask, data);
    };

    widget.controller.onStarTaskCommand = (data) {
      widget.onCommandDetected?.call(VoiceCommandType.starTask, data);
    };

    widget.controller.onSetPriorityCommand = (data) {
      widget.onCommandDetected?.call(VoiceCommandType.setPriority, data);
    };

    widget.controller.onRemoveTaskCommand = (data) {
      widget.onCommandDetected?.call(VoiceCommandType.removeTask, data);
    };
  }

  /// Setup stream listeners
  void _setupStreamListeners() {
    widget.controller.recognitionStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _recognitionState = state;
          _isListening = state == VoiceRecognitionState.listening;
        });
      }
    });

    widget.controller.textStream.listen((text) {
      if (mounted) {
        setState(() {
          _recognizedText = text;
          _textController.text = text;
        });
      }
    });

    widget.controller.confidenceStream.listen((conf) {
      if (mounted) {
        setState(() {
          _confidence = conf;
        });
      }
    });
  }

  /// Start listening
  Future<void> _startListening() async {
    await widget.controller.startListening();
  }

  /// Stop listening
  Future<void> _stopListening() async {
    await widget.controller.stopListening();
  }

  /// Cancel listening
  Future<void> _cancelListening() async {
    await widget.controller.cancelListening();
  }

  /// Clear text
  void _clearText() {
    setState(() {
      _recognizedText = '';
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Responsive.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          SizedBox(
            height: Responsive.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
          ),

          // Transcription Display
          _buildTranscriptionDisplay(),

          SizedBox(
            height: Responsive.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
          ),

          // Control Buttons
          _buildControlButtons(),

          // Confidence Indicator
          if (_isListening) _buildConfidenceIndicator(),
        ],
      ),
    );
  }

  /// Build header section
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.mic,
          color: _isListening
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voice Commands',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                _getStatusText(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Language Selector
        _buildLanguageSelector(),
      ],
    );
  }

  /// Build transcription display
  Widget _buildTranscriptionDisplay() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: Responsive.getResponsiveSpacing(
          context,
          mobile: 80,
          tablet: 100,
          desktop: 120,
        ),
      ),
      padding: Responsive.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: _isListening
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.1)
            : Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isListening
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: _isListening
              ? 'Konuşmaya başlayın...'
              : 'Mikrofon butonuna basarak konuşmaya başlayın',
          hintStyle: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: _isListening
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        readOnly: true,
      ),
    );
  }

  /// Build control buttons
  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Clear Button
        Expanded(
          child: _buildActionButton(
            icon: Icons.clear,
            label: 'Temizle',
            onPressed: _clearText,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
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

        // Main Action Button
        Expanded(
          flex: 2,
          child: _buildActionButton(
            icon: _isListening ? Icons.stop : Icons.mic,
            label: _isListening ? 'Durdur' : 'Dinlemeye Başla',
            onPressed: _isListening ? _stopListening : _startListening,
            backgroundColor: _isListening
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
            foregroundColor: _isListening
                ? Theme.of(context).colorScheme.onError
                : Theme.of(context).colorScheme.onPrimary,
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

        // Cancel Button
        Expanded(
          child: _buildActionButton(
            icon: Icons.close,
            label: 'İptal',
            onPressed: _cancelListening,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Build action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: Responsive.getResponsivePadding(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: Responsive.getResponsiveSpacing(
              context,
              mobile: 20,
              tablet: 22,
              desktop: 24,
            ),
          ),
          SizedBox(
            height: Responsive.getResponsiveSpacing(
              context,
              mobile: 4,
              tablet: 6,
              desktop: 8,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build confidence indicator
  Widget _buildConfidenceIndicator() {
    return Container(
      margin: EdgeInsets.only(
        top: Responsive.getResponsiveSpacing(
          context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Güven Skoru: ${(_confidence * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(
            height: Responsive.getResponsiveSpacing(
              context,
              mobile: 8,
              tablet: 10,
              desktop: 12,
            ),
          ),
          LinearProgressIndicator(
            value: _confidence,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getConfidenceColor(_confidence),
            ),
          ),
        ],
      ),
    );
  }

  /// Build language selector
  Widget _buildLanguageSelector() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.language,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onSelected: (languageCode) {
        widget.controller.setLanguage(languageCode);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'tr-TR', child: Text('Türkçe')),
        const PopupMenuItem(value: 'en-US', child: Text('English')),
      ],
    );
  }

  /// Get status text
  String _getStatusText() {
    switch (_recognitionState) {
      case VoiceRecognitionState.listening:
        return 'Dinleniyor...';
      case VoiceRecognitionState.notListening:
        return 'Dinleme durduruldu';
      case VoiceRecognitionState.completed:
        return 'Tamamlandı';
      case VoiceRecognitionState.error:
        return 'Hata oluştu';
    }
  }

  /// Get confidence color
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
