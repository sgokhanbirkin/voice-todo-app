import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/i_speech_to_text.dart';

/// Controller responsible for managing speech-to-text operations
/// This follows the Single Responsibility Principle for STT concerns
class SpeechToTextController extends GetxController {
  final ISpeechToText _speechToText;

  /// Speech-to-text state
  final RxBool isListening = false.obs;

  /// Recognized text
  final RxString recognizedText = ''.obs;

  /// Speech confidence level
  final RxDouble speechConfidence = 0.0.obs;

  /// Speech recognition state
  final Rx<SpeechRecognitionState> speechState =
      SpeechRecognitionState.notListening.obs;

  /// STT error state
  final RxBool hasSTTError = false.obs;

  /// STT error message
  final RxString sttErrorMessage = ''.obs;

  /// Callback for recognized text
  Function(String)? onTextRecognized;

  SpeechToTextController(this._speechToText);

  @override
  void onInit() {
    super.onInit();
    _setupSTTListeners();
  }

  // ===== SPEECH-TO-TEXT METHODS =====

  /// Start speech recognition
  Future<void> startSpeechRecognition() async {
    try {
      hasSTTError.value = false;
      sttErrorMessage.value = '';

      // Initialize speech recognition
      await _speechToText.initialize();

      isListening.value = true;
      speechState.value = SpeechRecognitionState.listening;
      recognizedText.value = '';
      speechConfidence.value = 0.0;

      await _speechToText.startListening();
      debugPrint(
        'SpeechToTextController: Speech recognition started successfully',
      );
    } catch (e) {
      _handleSTTError('Speech recognition başlatılamadı: $e');
    }
  }

  /// Stop speech recognition
  Future<void> stopSpeechRecognition() async {
    try {
      isListening.value = false;
      speechState.value = SpeechRecognitionState.processing;

      await _speechToText.stopListening();
      debugPrint(
        'SpeechToTextController: Speech recognition stopped successfully',
      );
    } catch (e) {
      _handleSTTError('Speech recognition durdurulamadı: $e');
    }
  }

  /// Cancel speech recognition
  Future<void> cancelSpeechRecognition() async {
    try {
      isListening.value = false;
      speechState.value = SpeechRecognitionState.notListening;
      recognizedText.value = '';

      await _speechToText.cancel();
      debugPrint(
        'SpeechToTextController: Speech recognition cancelled successfully',
      );
    } catch (e) {
      _handleSTTError('Speech recognition iptal edilemedi: $e');
    }
  }

  /// Get recognized text for task creation
  String getRecognizedText() {
    return recognizedText.value;
  }

  /// Clear recognized text
  void clearRecognizedText() {
    recognizedText.value = '';
    speechConfidence.value = 0.0;
  }

  /// Set callback for recognized text
  void setTextRecognizedCallback(Function(String) callback) {
    onTextRecognized = callback;
  }

  // ===== UTILITY METHODS =====

  /// Check if speech recognition is active
  bool get isActive => isListening.value;

  /// Check if speech recognition is processing
  bool get isProcessing =>
      speechState.value == SpeechRecognitionState.processing;

  /// Check if speech recognition has error
  bool get hasError => hasSTTError.value;

  /// Get speech recognition error message
  String get errorMessage => sttErrorMessage.value;

  /// Get speech confidence as percentage
  String get confidencePercentage =>
      '${(speechConfidence.value * 100).toStringAsFixed(1)}%';

  /// Get speech state description
  String get stateDescription {
    switch (speechState.value) {
      case SpeechRecognitionState.notListening:
        return 'Dinlenmiyor';
      case SpeechRecognitionState.listening:
        return 'Dinleniyor...';
      case SpeechRecognitionState.processing:
        return 'İşleniyor...';
      case SpeechRecognitionState.error:
        return 'Hata';
    }
  }

  // ===== PRIVATE METHODS =====

  /// Setup STT listeners
  void _setupSTTListeners() {
    // Listen to text updates
    _speechToText.textStream.listen((text) {
      recognizedText.value = text;

      // Notify callback if set
      onTextRecognized?.call(text);

      debugPrint('SpeechToTextController: Text recognized: $text');
    });

    // Listen to confidence updates
    _speechToText.confidenceStream.listen((confidence) {
      speechConfidence.value = confidence;
    });
  }

  /// Handle STT errors
  void _handleSTTError(String message) {
    hasSTTError.value = true;
    sttErrorMessage.value = message;
    isListening.value = false;
    speechState.value = SpeechRecognitionState.error;
    debugPrint('SpeechToTextController Error: $message');
  }

  /// Clear STT error
  void clearSTTError() {
    hasSTTError.value = false;
    sttErrorMessage.value = '';
  }
}

/// Speech recognition states
enum SpeechRecognitionState {
  /// Not listening
  notListening,

  /// Currently listening
  listening,

  /// Processing speech
  processing,

  /// Error occurred
  error,
}

/// Speech recognition result
class SpeechRecognitionResult {
  /// Recognized text
  final String text;

  /// Confidence level (0.0 to 1.0)
  final double confidence;

  /// Timestamp when result was received
  final DateTime timestamp;

  const SpeechRecognitionResult({
    required this.text,
    required this.confidence,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'SpeechRecognitionResult(text: "$text", confidence: ${(confidence * 100).toStringAsFixed(1)}%, timestamp: $timestamp)';
  }
}
