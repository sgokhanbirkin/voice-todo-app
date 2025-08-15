/// Interface for Text-to-Speech functionality
abstract class ITextToSpeech {
  /// Initialize the TTS engine
  Future<bool> initialize();

  /// Check if TTS is available on the device
  Future<bool> isAvailable();

  /// Get available languages
  Future<List<String>> getAvailableLanguages();

  /// Get available voices
  Future<List<Map<String, dynamic>>> getAvailableVoices();

  /// Set the language for TTS
  Future<void> setLanguage(String languageCode);

  /// Set the voice for TTS
  Future<void> setVoice(String voiceId);

  /// Set the speech rate (0.1 to 1.0)
  Future<void> setSpeechRate(double rate);

  /// Set the pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch);

  /// Set the volume (0.0 to 1.0)
  Future<void> setVolume(double volume);

  /// Speak the given text
  Future<void> speak(String text);

  /// Stop speaking
  Future<void> stop();

  /// Pause speaking
  Future<void> pause();

  /// Resume speaking
  Future<void> resume();

  /// Check if currently speaking
  Future<bool> isSpeaking();

  /// Check if currently paused
  Future<bool> isPaused();

  /// Get current speech status
  Future<SpeechStatus> getStatus();

  /// Set completion callback
  void setCompletionCallback(Function() callback);

  /// Set error callback
  void setErrorCallback(Function(String error) callback);

  /// Dispose TTS resources
  Future<void> dispose();
}

/// Speech status enum
enum SpeechStatus {
  /// Not speaking
  stopped,
  /// Currently speaking
  speaking,
  /// Paused
  paused,
  /// Speaking completed
  completed,
  /// Error occurred
  error,
}

/// TTS Configuration
class TTSConfig {
  final String languageCode;
  final String voiceId;
  final double speechRate;
  final double pitch;
  final double volume;

  const TTSConfig({
    this.languageCode = 'en-US',
    this.voiceId = '',
    this.speechRate = 0.5,
    this.pitch = 1.0,
    this.volume = 1.0,
  });

  TTSConfig copyWith({
    String? languageCode,
    String? voiceId,
    double? speechRate,
    double? pitch,
    double? volume,
  }) {
    return TTSConfig(
      languageCode: languageCode ?? this.languageCode,
      voiceId: voiceId ?? this.voiceId,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'voiceId': voiceId,
      'speechRate': speechRate,
      'pitch': pitch,
      'volume': volume,
    };
  }

  factory TTSConfig.fromJson(Map<String, dynamic> json) {
    return TTSConfig(
      languageCode: json['languageCode'] ?? 'en-US',
      voiceId: json['voiceId'] ?? '',
      speechRate: json['speechRate']?.toDouble() ?? 0.5,
      pitch: json['pitch']?.toDouble() ?? 1.0,
      volume: json['volume']?.toDouble() ?? 1.0,
    );
  }
}
