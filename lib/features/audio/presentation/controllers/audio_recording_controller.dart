import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/i_audio_recorder.dart';

/// Controller responsible for managing audio recording operations
/// This follows the Single Responsibility Principle for recording concerns
class AudioRecordingController extends GetxController {
  final IAudioRecorder _audioRecorder;

  /// Audio recording state
  final RxBool isRecording = false.obs;

  /// Recording duration
  final Rx<Duration> recordingDuration = Duration.zero.obs;

  /// Recording amplitude for visualization
  final RxDouble amplitude = 0.0.obs;

  /// Timer for recording duration updates
  Timer? _recordingTimer;

  /// Current recording file path
  final RxString currentRecordingPath = ''.obs;

  /// Recording error state
  final RxBool hasRecordingError = false.obs;

  /// Recording error message
  final RxString recordingErrorMessage = ''.obs;

  AudioRecordingController(this._audioRecorder);

  @override
  void onInit() {
    super.onInit();
    _setupRecordingListeners();
  }

  @override
  void onClose() {
    _stopRecordingTimer();
    super.onClose();
  }

  // ===== RECORDING METHODS =====

  /// Start audio recording
  Future<void> startRecording() async {
    try {
      hasRecordingError.value = false;
      recordingErrorMessage.value = '';

      // Start recording
      await _audioRecorder.startRecording();
      currentRecordingPath.value =
          'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Update state
      isRecording.value = true;
      recordingDuration.value = Duration.zero;
      amplitude.value = 0.0;

      // Start duration timer
      _startRecordingTimer();

      // Start amplitude monitoring
      _startAmplitudeMonitoring();

      debugPrint(
        'AudioRecordingController: Recording started at ${currentRecordingPath.value}',
      );
    } catch (e) {
      _handleRecordingError('Kayıt başlatılamadı: $e');
    }
  }

  /// Stop audio recording
  Future<String?> stopRecording() async {
    try {
      if (!isRecording.value) {
        return null;
      }

      // Stop recording
      await _audioRecorder.stopRecording();

      // Update state
      isRecording.value = false;
      _stopRecordingTimer();
      _stopAmplitudeMonitoring();

      // Reset duration and amplitude
      recordingDuration.value = Duration.zero;
      amplitude.value = 0.0;

      final filePath = currentRecordingPath.value;
      debugPrint('AudioRecordingController: Recording stopped at $filePath');
      return filePath;
    } catch (e) {
      _handleRecordingError('Kayıt durdurulamadı: $e');
      return null;
    }
  }

  /// Pause audio recording
  Future<void> pauseRecording() async {
    try {
      if (!isRecording.value) return;

      await _audioRecorder.pauseRecording();
      _stopRecordingTimer();
      debugPrint('AudioRecordingController: Recording paused');
    } catch (e) {
      _handleRecordingError('Kayıt duraklatılamadı: $e');
    }
  }

  /// Resume audio recording
  Future<void> resumeRecording() async {
    try {
      if (!isRecording.value) return;

      await _audioRecorder.resumeRecording();
      _startRecordingTimer();
      debugPrint('AudioRecordingController: Recording resumed');
    } catch (e) {
      _handleRecordingError('Kayıt devam ettirilemedi: $e');
    }
  }

  /// Cancel current recording
  Future<void> cancelRecording() async {
    try {
      if (!isRecording.value) return;

      await _audioRecorder.cancelRecording();

      // Reset state
      isRecording.value = false;
      currentRecordingPath.value = '';
      recordingDuration.value = Duration.zero;
      amplitude.value = 0.0;

      _stopRecordingTimer();
      _stopAmplitudeMonitoring();

      debugPrint('AudioRecordingController: Recording cancelled');
    } catch (e) {
      _handleRecordingError('Kayıt iptal edilemedi: $e');
    }
  }

  // ===== UTILITY METHODS =====

  /// Check if recording is active
  bool get isActive => isRecording.value;

  /// Get current recording duration as formatted string
  String get formattedDuration {
    final duration = recordingDuration.value;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get current recording file path
  String? get recordingPath =>
      currentRecordingPath.value.isNotEmpty ? currentRecordingPath.value : null;

  /// Check if there's a recording error
  bool get hasError => hasRecordingError.value;

  /// Get recording error message
  String get errorMessage => recordingErrorMessage.value;

  // ===== PRIVATE METHODS =====

  /// Setup recording listeners
  void _setupRecordingListeners() {
    // Listen to amplitude changes if available
    _audioRecorder.amplitudeStream.listen((amp) {
      amplitude.value = amp;
    });
  }

  /// Start recording duration timer
  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingDuration.value += const Duration(seconds: 1);
    });
  }

  /// Stop recording duration timer
  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  /// Start amplitude monitoring
  void _startAmplitudeMonitoring() {
    // Amplitude monitoring is handled by the recorder's stream
    // This method can be extended for additional monitoring logic
  }

  /// Stop amplitude monitoring
  void _stopAmplitudeMonitoring() {
    // Amplitude monitoring is handled by the recorder's stream
    // This method can be extended for additional monitoring logic
  }

  /// Handle recording errors
  void _handleRecordingError(String message) {
    hasRecordingError.value = true;
    recordingErrorMessage.value = message;
    debugPrint('AudioRecordingController Error: $message');
  }

  /// Clear recording error
  void clearRecordingError() {
    hasRecordingError.value = false;
    recordingErrorMessage.value = '';
  }
}
