import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/i_audio_player.dart';
import '../../domain/audio_entity.dart';

/// Controller responsible for managing audio playback operations
/// This follows the Single Responsibility Principle for playback concerns
class AudioPlaybackController extends GetxController {
  final IAudioPlayer _audioPlayer;

  /// Currently playing audio
  final Rx<AudioEntity?> playingAudio = Rx<AudioEntity?>(null);

  /// Audio playing state
  final RxBool isPlaying = false.obs;

  /// Audio paused state
  final RxBool isPaused = false.obs;

  /// Audio loading state
  final RxBool isLoading = false.obs;

  /// Audio buffering state
  final RxBool isBuffering = false.obs;

  /// Audio completed state
  final RxBool isCompleted = false.obs;

  /// Playback position
  final Rx<Duration> playbackPosition = Duration.zero.obs;

  /// Playback duration
  final Rx<Duration> playbackDuration = Duration.zero.obs;

  /// Timer for playback position updates
  Timer? _playbackTimer;

  /// Playback error state
  final RxBool hasPlaybackError = false.obs;

  /// Playback error message
  final RxString playbackErrorMessage = ''.obs;

  AudioPlaybackController(this._audioPlayer);

  @override
  void onInit() {
    super.onInit();
    _setupPlaybackListeners();
  }

  @override
  void onClose() {
    _stopPlaybackTimer();
    super.onClose();
  }

  // ===== PLAYBACK METHODS =====

  /// Play audio file
  Future<void> playAudio(AudioEntity audio) async {
    try {
      hasPlaybackError.value = false;
      playbackErrorMessage.value = '';
      isLoading.value = true;

      // Set current playing audio
      playingAudio.value = audio;

      // Play the audio
      await _audioPlayer.play(audio.localPath);

      // Update state
      isPlaying.value = true;
      isPaused.value = false;
      isCompleted.value = false;
      isLoading.value = false;

      // Start position timer
      _startPlaybackTimer();

      debugPrint('AudioPlaybackController: Playing audio: ${audio.fileName}');
    } catch (e) {
      _handlePlaybackError('Audio oynatılamadı: $e');
    }
  }

  /// Pause audio playback
  Future<void> pauseAudio() async {
    try {
      if (!isPlaying.value) return;

      await _audioPlayer.pause();

      // Update state
      isPlaying.value = false;
      isPaused.value = true;

      // Stop position timer
      _stopPlaybackTimer();

      debugPrint('AudioPlaybackController: Audio paused');
    } catch (e) {
      _handlePlaybackError('Audio duraklatılamadı: $e');
    }
  }

  /// Resume audio playback
  Future<void> resumeAudio() async {
    try {
      if (!isPaused.value) return;

      await _audioPlayer.resume();

      // Update state
      isPlaying.value = true;
      isPaused.value = false;

      // Start position timer
      _startPlaybackTimer();

      debugPrint('AudioPlaybackController: Audio resumed');
    } catch (e) {
      _handlePlaybackError('Audio devam ettirilemedi: $e');
    }
  }

  /// Stop audio playback
  Future<void> stopAudio() async {
    try {
      if (!isPlaying.value && !isPaused.value) return;

      await _audioPlayer.stop();

      // Reset state
      isPlaying.value = false;
      isPaused.value = false;
      isCompleted.value = false;
      playbackPosition.value = Duration.zero;

      // Stop position timer
      _stopPlaybackTimer();

      debugPrint('AudioPlaybackController: Audio stopped');
    } catch (e) {
      _handlePlaybackError('Audio durdurulamadı: $e');
    }
  }

  /// Seek to specific position
  Future<void> seekTo(Duration position) async {
    try {
      if (!isPlaying.value && !isPaused.value) return;

      await _audioPlayer.seek(position);
      playbackPosition.value = position;

      debugPrint('AudioPlaybackController: Seeked to ${position.inSeconds}s');
    } catch (e) {
      _handlePlaybackError('Audio konumlandırılamadı: $e');
    }
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed);
      debugPrint('AudioPlaybackController: Playback speed set to ${speed}x');
    } catch (e) {
      _handlePlaybackError('Oynatma hızı ayarlanamadı: $e');
    }
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
      debugPrint('AudioPlaybackController: Volume set to $volume');
    } catch (e) {
      _handlePlaybackError('Ses seviyesi ayarlanamadı: $e');
    }
  }

  // ===== UTILITY METHODS =====

  /// Check if audio is currently playing
  bool get isCurrentlyPlaying => isPlaying.value;

  /// Check if audio is paused
  bool get isCurrentlyPaused => isPaused.value;

  /// Check if audio is loading
  bool get isCurrentlyLoading => isLoading.value;

  /// Check if audio is buffering
  bool get isCurrentlyBuffering => isBuffering.value;

  /// Check if audio is completed
  bool get isCurrentlyCompleted => isCompleted.value;

  /// Get current playing audio
  AudioEntity? get currentAudio => playingAudio.value;

  /// Get formatted playback position
  String get formattedPosition {
    final position = playbackPosition.value;
    final minutes = position.inMinutes;
    final seconds = position.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted playback duration
  String get formattedDuration {
    final duration = playbackDuration.value;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get playback progress percentage
  double get progressPercentage {
    if (playbackDuration.value.inMilliseconds == 0) return 0.0;
    return playbackPosition.value.inMilliseconds /
        playbackDuration.value.inMilliseconds;
  }

  /// Check if there's a playback error
  bool get hasError => hasPlaybackError.value;

  /// Get playback error message
  String get errorMessage => playbackErrorMessage.value;

  // ===== PRIVATE METHODS =====

  /// Setup playback listeners
  void _setupPlaybackListeners() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) async {
      await _updatePlaybackStates(state);
    });

    // Listen to position updates
    _audioPlayer.positionStream.listen((position) {
      playbackPosition.value = position;
    });

    // Listen to duration updates
    _audioPlayer.durationStream.listen((duration) {
      playbackDuration.value = duration;
    });
  }

  /// Update playback states based on player state
  Future<void> _updatePlaybackStates(dynamic playerState) async {
    try {
      // Get processing state from player
      final processingState = _audioPlayer.processingState;

      // Update buffering state
      isBuffering.value =
          processingState == 'loading' || processingState == 'buffering';

      // Update completed state
      isCompleted.value = processingState == 'completed';

      // Update playing state (not playing if completed)
      isPlaying.value =
          _audioPlayer.isPlaying && processingState != 'completed';

      // Update paused state
      isPaused.value =
          !_audioPlayer.isPlaying && _audioPlayer.position > Duration.zero;

      // Auto-reset when completed
      if (processingState == 'completed') {
        await _autoResetOnCompletion();
      }

      debugPrint(
        'AudioPlaybackController: States updated - Playing: ${isPlaying.value}, Paused: ${isPaused.value}, Buffering: ${isBuffering.value}, Completed: ${isCompleted.value}',
      );
    } catch (e) {
      debugPrint(
        'AudioPlaybackController: Failed to update playback states: $e',
      );
    }
  }

  /// Auto-reset audio player when playback completes
  Future<void> _autoResetOnCompletion() async {
    try {
      debugPrint('AudioPlaybackController: Auto-resetting on completion');

      // Seek to beginning
      await _audioPlayer.seek(Duration.zero);

      // Pause player
      await _audioPlayer.pause();

      // Update states
      isPlaying.value = false;
      isPaused.value = false;
      isCompleted.value = true;
      playbackPosition.value = Duration.zero;

      // Stop position timer
      _stopPlaybackTimer();

      debugPrint('AudioPlaybackController: Auto-reset completed');
    } catch (e) {
      debugPrint('AudioPlaybackController: Failed to auto-reset: $e');
    }
  }

  /// Start playback position timer
  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // Position updates are handled by the player's stream
      // This timer can be used for additional UI updates if needed
    });
  }

  /// Stop playback position timer
  void _stopPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  /// Handle playback errors
  void _handlePlaybackError(String message) {
    hasPlaybackError.value = true;
    playbackErrorMessage.value = message;
    isLoading.value = false;
    debugPrint('AudioPlaybackController Error: $message');
  }

  /// Clear playback error
  void clearPlaybackError() {
    hasPlaybackError.value = false;
    playbackErrorMessage.value = '';
  }
}
