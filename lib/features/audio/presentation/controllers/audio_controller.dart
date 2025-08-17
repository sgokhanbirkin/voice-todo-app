import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/audio_entity.dart';
import '../../domain/i_audio_repository.dart';
import '../../domain/i_audio_recorder.dart';
import '../../domain/i_audio_player.dart';
import '../../domain/i_speech_to_text.dart';
import 'audio_recording_controller.dart';
import 'audio_playback_controller.dart';
import 'speech_to_text_controller.dart';

/// Simplified audio controller that uses specialized controllers
/// This follows the Single Responsibility Principle by delegating to specialized controllers
class AudioController extends GetxController {
  final IAudioRepository _audioRepository;
  final IAudioRecorder _audioRecorder;
  final IAudioPlayer _audioPlayer;
  final ISpeechToText _speechToText;

  late final AudioRecordingController _recordingController;
  late final AudioPlaybackController _playbackController;
  late final SpeechToTextController _sttController;

  /// Observable list of all audio files
  final RxList<AudioEntity> audioFiles = <AudioEntity>[].obs;

  /// Observable list of audio files for current task
  final RxList<AudioEntity> currentTaskAudio = <AudioEntity>[].obs;

  /// Currently selected audio file
  final Rx<AudioEntity?> selectedAudio = Rx<AudioEntity?>(null);

  /// Audio loading state
  final RxBool isLoading = false.obs;

  /// Upload progress for current file
  final RxDouble uploadProgress = 0.0.obs;

  /// Current task ID for filtering
  final RxString currentTaskId = ''.obs;

  /// Audio statistics
  final Rx<dynamic> audioStatistics = Rx<dynamic>(null);

  /// Callback for recognized text
  Function(String)? onTextRecognized;

  AudioController(
    this._audioRepository,
    this._audioRecorder,
    this._audioPlayer,
    this._speechToText,
  );

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  /// Initialize specialized controllers
  void _initializeControllers() {
    _recordingController = AudioRecordingController(_audioRecorder);
    _playbackController = AudioPlaybackController(_audioPlayer);
    _sttController = SpeechToTextController(_speechToText);

    // Set up STT callback
    _sttController.setTextRecognizedCallback((text) {
      onTextRecognized?.call(text);
    });

    // Load initial data
    _loadAudioFiles();
    _loadAudioStatistics();
  }

  // ===== DELEGATED PROPERTIES =====

  // Recording properties
  RxBool get isRecording => _recordingController.isRecording;
  Rx<Duration> get recordingDuration => _recordingController.recordingDuration;
  RxDouble get amplitude => _recordingController.amplitude;
  RxString get currentRecordingPath =>
      _recordingController.currentRecordingPath;

  // Playback properties
  Rx<AudioEntity?> get playingAudio => _playbackController.playingAudio;
  RxBool get isPlaying => _playbackController.isPlaying;
  RxBool get isPaused => _playbackController.isPaused;
  RxBool get isLoadingPlayback => _playbackController.isLoading;
  RxBool get isBuffering => _playbackController.isBuffering;
  RxBool get isCompleted => _playbackController.isCompleted;
  Rx<Duration> get playbackPosition => _playbackController.playbackPosition;
  Rx<Duration> get playbackDuration => _playbackController.playbackDuration;

  // STT properties
  RxBool get isListening => _sttController.isListening;
  RxString get recognizedText => _sttController.recognizedText;
  RxDouble get speechConfidence => _sttController.speechConfidence;
  Rx<dynamic> get speechState => _sttController.speechState;

  // Error properties
  bool get hasError =>
      _recordingController.hasError ||
      _playbackController.hasError ||
      _sttController.hasError;
  String get errorMessage => _getCombinedErrorMessage();

  // ===== DELEGATED METHODS =====

  // Recording methods
  Future<void> startRecording() async {
    await _recordingController.startRecording();
  }

  Future<String?> stopRecording() async {
    return await _recordingController.stopRecording();
  }

  Future<void> pauseRecording() async {
    await _recordingController.pauseRecording();
  }

  Future<void> resumeRecording() async {
    await _recordingController.resumeRecording();
  }

  Future<void> cancelRecording() async {
    await _recordingController.cancelRecording();
  }

  // Playback methods
  Future<void> playAudio(AudioEntity audio) async {
    await _playbackController.playAudio(audio);
  }

  Future<void> pauseAudio() async {
    await _playbackController.pauseAudio();
  }

  Future<void> resumeAudio() async {
    await _playbackController.resumeAudio();
  }

  Future<void> stopAudio() async {
    await _playbackController.stopAudio();
  }

  Future<void> seekTo(Duration position) async {
    await _playbackController.seekTo(position);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _playbackController.setPlaybackSpeed(speed);
  }

  Future<void> setVolume(double volume) async {
    await _playbackController.setVolume(volume);
  }

  // STT methods
  Future<void> startSpeechRecognition() async {
    await _sttController.startSpeechRecognition();
  }

  Future<void> stopSpeechRecognition() async {
    await _sttController.stopSpeechRecognition();
  }

  Future<void> cancelSpeechRecognition() async {
    await _sttController.cancelSpeechRecognition();
  }

  String getRecognizedText() {
    return _sttController.getRecognizedText();
  }

  void clearRecognizedText() {
    _sttController.clearRecognizedText();
  }

  // ===== BASIC AUDIO MANAGEMENT =====

  /// Load all audio files from repository
  Future<void> _loadAudioFiles() async {
    try {
      isLoading.value = true;
      final result = await _audioRepository.getAllAudio();
      if (result.isSuccess) {
        audioFiles.assignAll(result.dataOrNull ?? []);
        _updateCurrentTaskAudio();
      }
    } catch (e) {
      debugPrint('AudioController: Failed to load audio files: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load audio files for specific task
  Future<void> loadTaskAudio(String taskId) async {
    try {
      currentTaskId.value = taskId;
      isLoading.value = true;
      final result = await _audioRepository.getAudioByTaskId(taskId);
      if (result.isSuccess) {
        currentTaskAudio.assignAll(result.dataOrNull ?? []);
      }
    } catch (e) {
      debugPrint('AudioController: Failed to load task audio: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load audio statistics
  Future<void> _loadAudioStatistics() async {
    try {
      final result = await _audioRepository.getAudioStatistics();
      if (result.isSuccess) {
        audioStatistics.value = result.dataOrNull;
      }
    } catch (e) {
      debugPrint('AudioController: Failed to load audio statistics: $e');
    }
  }

  /// Update current task audio list
  void _updateCurrentTaskAudio() {
    if (currentTaskId.value.isNotEmpty) {
      final taskFiles = audioFiles
          .where((a) => a.taskId == currentTaskId.value)
          .toList();
      currentTaskAudio.assignAll(taskFiles);
    }
  }

  // ===== UTILITY METHODS =====

  /// Set selected audio file
  void setSelectedAudio(AudioEntity? audio) {
    selectedAudio.value = audio;
  }

  /// Clear selected audio file
  void clearSelectedAudio() {
    selectedAudio.value = null;
  }

  /// Get audio by ID
  AudioEntity? getAudioById(String id) {
    try {
      return audioFiles.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get audio files by task ID
  List<AudioEntity> getAudioFilesByTask(String taskId) {
    return audioFiles.where((a) => a.taskId == taskId).toList();
  }

  /// Get total audio files count
  int get totalAudioCount => audioFiles.length;

  /// Get current task audio count
  int get currentTaskAudioCount => currentTaskAudio.length;

  /// Get total audio size in bytes
  int get totalAudioSize =>
      audioFiles.fold(0, (sum, audio) => sum + audio.fileSize);

  /// Get total audio duration
  Duration get totalAudioDuration {
    return audioFiles.fold(Duration.zero, (sum, audio) => sum + audio.duration);
  }

  /// Get combined error message
  String _getCombinedErrorMessage() {
    final errors = <String>[];

    if (_recordingController.hasError) {
      errors.add(_recordingController.errorMessage);
    }
    if (_playbackController.hasError) {
      errors.add(_playbackController.errorMessage);
    }
    if (_sttController.hasError) errors.add(_sttController.errorMessage);

    return errors.isEmpty ? '' : errors.join('; ');
  }

  /// Refresh all data
  @override
  Future<void> refresh() async {
    await _loadAudioFiles();
    await _loadAudioStatistics();
  }

  /// Stop all audio operations
  Future<void> stopAllAudio() async {
    await _playbackController.stopAudio();
    await _recordingController.cancelRecording();
    await _sttController.cancelSpeechRecognition();
  }

  /// Get overall audio state
  String get overallAudioState {
    if (_recordingController.isActive) return 'Recording';
    if (_playbackController.isCurrentlyPlaying) return 'Playing';
    if (_playbackController.isCurrentlyPaused) return 'Paused';
    if (_sttController.isActive) return 'Listening';
    return 'Idle';
  }

  /// Check if any audio operation is active
  bool get hasActiveAudioOperation {
    return _recordingController.isActive ||
        _playbackController.isCurrentlyPlaying ||
        _playbackController.isCurrentlyPaused ||
        _sttController.isActive;
  }
}
