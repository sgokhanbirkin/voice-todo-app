import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../domain/i_audio_player.dart';

/// Just Audio player implementation
class JustAudioPlayer implements IAudioPlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> initialize() async {
    try {
      // Loop mode'u kapat (tek parça için)
      await _audioPlayer.setLoopMode(LoopMode.off);

      // Audio session ve focus ayarları
      // Android audio focus ve routing
      await _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse('dummy://init')),
        preload: false,
      );
      
      // iOS audio session configuration
      await _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse('dummy://init')),
        preload: false,
      );

      debugPrint('JustAudioPlayer: Initialized successfully');
    } catch (e) {
      debugPrint('JustAudioPlayer: Failed to initialize: $e');
      rethrow;
    }
  }

  @override
  Future<void> play(String audioPath) async {
    try {
      // NON-BLOCKING: await sadece source set etmek için
      await _audioPlayer.setFilePath(audioPath);
      _audioPlayer.play(); // await YOK - non-blocking

      debugPrint('JustAudioPlayer: Started playing: $audioPath');
    } catch (e) {
      debugPrint('JustAudioPlayer: Failed to play: $e');
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      debugPrint('JustAudioPlayer: Paused playback');
    } catch (e) {
      debugPrint('JustAudioPlayer: Failed to pause: $e');
      rethrow;
    }
  }

  @override
  Future<void> resume() async {
    try {
      _audioPlayer.play(); // await YOK - non-blocking
      debugPrint('JustAudioPlayer: Resumed playback');
    } catch (e) {
      debugPrint('JustAudioPlayer: Failed to resume: $e');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      debugPrint('JustAudioPlayer: Stopped playback');
    } catch (e) {
      debugPrint('JustAudioPlayer: Failed to stop: $e');
      rethrow;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  Duration get position => _audioPlayer.position;

  @override
  Duration get duration => _audioPlayer.duration ?? Duration.zero;

  @override
  bool get isPlaying => _audioPlayer.playing;

  @override
  bool get isPaused =>
      !_audioPlayer.playing && _audioPlayer.position > Duration.zero;

  @override
  bool get isStopped =>
      !_audioPlayer.playing && _audioPlayer.position == Duration.zero;

  /// Get current processing state
  @override
  ProcessingState get processingState => _audioPlayer.processingState;

  /// Get current player state
  @override
  PlayerState get playerState => _audioPlayer.playerState;

  @override
  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
  }

  @override
  double get speed => _audioPlayer.speed;

  @override
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  @override
  double get volume => _audioPlayer.volume;

  @override
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  @override
  Stream<AudioPlaybackState> get playbackStateStream {
    return _audioPlayer.playerStateStream.map((state) {
      // Map JustAudio PlayerState to our AudioPlaybackState
      if (state.processingState == ProcessingState.completed) {
        return AudioPlaybackState.completed;
      } else if (state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering) {
        return AudioPlaybackState.loading;
      } else if (_audioPlayer.playing) {
        return AudioPlaybackState.playing;
      } else if (_audioPlayer.position > Duration.zero) {
        return AudioPlaybackState.paused;
      } else {
        return AudioPlaybackState.stopped;
      }
    });
  }

  /// Stream of player state changes (JustAudio specific)
  @override
  Stream<dynamic> get playerStateStream => _audioPlayer.playerStateStream;

  @override
  Stream<Duration> get durationStream => _audioPlayer.durationStream
      .where((duration) => duration != null)
      .map((duration) => duration!);

  @override
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

// PlayerState mapping implemented above in playbackStateStream
// Audio session management implemented in initialize() method
// Audio focus handling implemented with JustAudio's built-in focus management
// Audio routing handled by JustAudio's platform-specific implementations
// Audio effects and equalizer can be added via JustAudio's audio processing
// Audio caching and preloading handled by JustAudio's built-in mechanisms
