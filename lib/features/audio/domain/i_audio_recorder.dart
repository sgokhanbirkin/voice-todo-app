/// Audio recorder interface for recording audio
abstract class IAudioRecorder {
  /// Initializes the audio recorder
  Future<void> initialize();

  /// Starts recording audio
  Future<void> startRecording();

  /// Stops recording audio
  Future<String> stopRecording();

  /// Pauses recording (if supported)
  Future<void> pauseRecording();

  /// Resumes recording (if supported)
  Future<void> resumeRecording();

  /// Cancels the current recording
  Future<void> cancelRecording();

  /// Gets whether the recorder is currently recording
  bool get isRecording;

  /// Gets whether the recorder is paused
  bool get isPaused;

  /// Gets the current recording duration
  Duration get recordingDuration;

  /// Gets the current recording amplitude (for visualization)
  double get amplitude;

  /// Stream of recording duration updates
  Stream<Duration> get durationStream;

  /// Stream of recording amplitude updates
  Stream<double> get amplitudeStream;

  /// Stream of recording state changes
  Stream<AudioRecordingState> get recordingStateStream;

  /// Sets the recording quality
  Future<void> setQuality(AudioQuality quality);

  /// Gets the current recording quality
  AudioQuality get quality;

  /// Sets the recording format
  Future<void> setFormat(AudioFormat format);

  /// Gets the current recording format
  AudioFormat get format;

  /// Sets the maximum recording duration
  Future<void> setMaxDuration(Duration maxDuration);

  /// Gets the maximum recording duration
  Duration get maxDuration;

  /// Disposes the audio recorder and releases resources
  Future<void> dispose();
}

/// Audio recording states
enum AudioRecordingState {
  /// Recorder is stopped
  stopped,

  /// Recorder is recording
  recording,

  /// Recorder is paused
  paused,

  /// Recorder is initializing
  initializing,

  /// Recorder has encountered an error
  error,
}

/// Audio quality levels
enum AudioQuality {
  /// Low quality (smaller file size)
  low,

  /// Medium quality (balanced)
  medium,

  /// High quality (larger file size)
  high,
}

/// Audio formats
enum AudioFormat {
  /// MP3 format
  mp3,

  /// WAV format
  wav,

  /// AAC format
  aac,

  /// M4A format
  m4a,
}

// TODO: Add more recording features (e.g., noise reduction, echo cancellation)
// TODO: Implement audio compression and optimization
// TODO: Add recording metadata support
// TODO: Implement recording backup and sync
