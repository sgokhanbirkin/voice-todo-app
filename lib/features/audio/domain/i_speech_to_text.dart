/// Speech-to-text interface for converting speech to text
abstract class ISpeechToText {
  /// Initializes the speech-to-text service
  Future<void> initialize();

  /// Starts listening for speech input
  Future<void> startListening();

  /// Starts listening for speech input with custom callback
  Future<void> startListeningWithCallback({
    required Function(String text, double confidence) onResult,
    bool partialResults = true,
    String? localeId,
  });

  /// Stops listening for speech input
  Future<void> stopListening();

  /// Cancels the current speech recognition
  Future<void> cancel();

  /// Gets whether the service is currently listening
  bool get isListening;

  /// Gets the current speech recognition confidence (0.0 to 1.0)
  double get confidence;

  /// Gets the current recognized text
  String get recognizedText;

  /// Stream of recognized text updates
  Stream<String> get textStream;

  /// Stream of confidence updates
  Stream<double> get confidenceStream;

  /// Stream of speech recognition state changes
  Stream<SpeechRecognitionState> get recognitionStateStream;

  /// Sets the language for speech recognition
  Future<void> setLanguage(String languageCode);

  /// Gets the current language for speech recognition
  String get language;

  /// Sets whether to show partial results
  Future<void> setShowPartialResults(bool show);

  /// Gets whether partial results are shown
  bool get showPartialResults;

  /// Sets the maximum duration for listening
  Future<void> setMaxListeningDuration(Duration duration);

  /// Gets the maximum listening duration
  Duration get maxListeningDuration;

  /// Disposes the speech-to-text service and releases resources
  Future<void> dispose();
}

/// Speech recognition states
enum SpeechRecognitionState {
  /// Service is not listening
  notListening,

  /// Service is listening for speech
  listening,

  /// Service is processing speech
  processing,

  /// Speech recognition completed successfully
  completed,

  /// Speech recognition failed
  failed,

  /// Service is initializing
  initializing,

  /// Service has encountered an error
  error,
}

/// Speech recognition result
class SpeechRecognitionResult {
  /// The recognized text
  final String text;

  /// The confidence level (0.0 to 1.0)
  final double confidence;

  /// The language used for recognition
  final String language;

  /// The timestamp when recognition was completed
  final DateTime timestamp;

  /// Whether this is a partial result
  final bool isPartial;

  const SpeechRecognitionResult({
    required this.text,
    required this.confidence,
    required this.language,
    required this.timestamp,
    this.isPartial = false,
  });

  /// Creates a copy of this result with updated values
  SpeechRecognitionResult copyWith({
    String? text,
    double? confidence,
    String? language,
    DateTime? timestamp,
    bool? isPartial,
  }) {
    return SpeechRecognitionResult(
      text: text ?? this.text,
      confidence: confidence ?? this.confidence,
      language: language ?? this.language,
      timestamp: timestamp ?? this.timestamp,
      isPartial: isPartial ?? this.isPartial,
    );
  }

  @override
  String toString() {
    return 'SpeechRecognitionResult(text: $text, confidence: $confidence, language: $language, timestamp: $timestamp, isPartial: $isPartial)';
  }
}
