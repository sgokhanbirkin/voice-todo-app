/// Audio player interface for playing audio files
abstract class IAudioPlayer {
  /// Initializes the audio player
  Future<void> initialize();

  /// Plays audio from the given path
  Future<void> play(String audioPath);

  /// Pauses the currently playing audio
  Future<void> pause();

  /// Resumes the paused audio
  Future<void> resume();

  /// Stops the audio playback
  Future<void> stop();

  /// Seeks to a specific position in the audio
  Future<void> seek(Duration position);

  /// Gets the current playback position
  Duration get position;

  /// Gets the total duration of the audio
  Duration get duration;

  /// Gets whether the audio is currently playing
  bool get isPlaying;

  /// Gets whether the audio is paused
  bool get isPaused;

  /// Gets whether the audio is stopped
  bool get isStopped;

  /// Sets the playback speed (1.0 = normal speed)
  Future<void> setSpeed(double speed);

  /// Gets the current playback speed
  double get speed;

  /// Sets the volume (0.0 to 1.0)
  Future<void> setVolume(double volume);

  /// Gets the current volume
  double get volume;

  /// Stream of playback position updates
  Stream<Duration> get positionStream;

  /// Stream of playback state changes
  Stream<AudioPlaybackState> get playbackStateStream;

  /// Stream of audio duration updates
  Stream<Duration> get durationStream;

  /// Stream of player state changes (for JustAudio integration)
  Stream<dynamic> get playerStateStream;

  /// Get current processing state (for JustAudio integration)
  dynamic get processingState;

  /// Get current player state (for JustAudio integration)
  dynamic get playerState;

  /// Disposes the audio player and releases resources
  Future<void> dispose();
}

/// Audio playback states
enum AudioPlaybackState {
  /// Audio is stopped
  stopped,

  /// Audio is playing
  playing,

  /// Audio is paused
  paused,

  /// Audio is loading
  loading,

  /// Audio has completed
  completed,

  /// Audio has encountered an error
  error,
}

// TODO: Add more audio player features (e.g., playlist support, audio effects)
// TODO: Implement audio format detection and conversion
// TODO: Add audio metadata extraction
// TODO: Implement audio caching mechanisms
