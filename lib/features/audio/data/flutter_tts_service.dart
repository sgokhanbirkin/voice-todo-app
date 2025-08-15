import 'package:flutter_tts/flutter_tts.dart';
import 'package:voice_todo/features/audio/domain/i_text_to_speech.dart';
import '../../../core/logger.dart';

/// Flutter TTS service implementation
class FlutterTTSService implements ITextToSpeech {
  final FlutterTts _flutterTts = FlutterTts();
  final Logger _logger = Logger.instance;

  Function()? _completionCallback;
  Function(String error)? _errorCallback;

  bool _isInitialized = false;
  bool _isCurrentlySpeaking = false;

  @override
  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Set completion and error callbacks
      _flutterTts.setCompletionHandler(() {
        _isCurrentlySpeaking = false;
        _logger.info('TTS: Speech completed');
        _completionCallback?.call();
      });

      // Flutter TTS 4.x error handling - using proper error handler
      _flutterTts.setErrorHandler((msg) {
        _isCurrentlySpeaking = false;
        _logger.error('TTS Error: $msg');
        _errorCallback?.call(msg);
      });

      // Set default configuration
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);

      _isInitialized = true;
      _logger.info('TTS: Initialized successfully');
      return true;
    } catch (e) {
      _logger.error('TTS: Failed to initialize: $e');
      return false;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final available = await _flutterTts.isLanguageAvailable('en-US');
      return available == 1;
    } catch (e) {
      _logger.error('TTS: Failed to check availability: $e');
      return false;
    }
  }

  @override
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      if (languages is List) {
        return languages.cast<String>();
      }
      return [];
    } catch (e) {
      _logger.error('TTS: Failed to get available languages: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      if (voices is List) {
        return voices.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      _logger.error('TTS: Failed to get available voices: $e');
      return [];
    }
  }

  @override
  Future<void> setLanguage(String languageCode) async {
    try {
      await _flutterTts.setLanguage(languageCode);
      _logger.info('TTS: Language set to $languageCode');
    } catch (e) {
      _logger.error('TTS: Failed to set language $languageCode: $e');
      rethrow;
    }
  }

  @override
  Future<void> setVoice(String voiceId) async {
    try {
      await _flutterTts.setVoice({'name': voiceId, 'locale': 'en-US'});
      _logger.info('TTS: Voice set to $voiceId');
    } catch (e) {
      _logger.error('TTS: Failed to set voice $voiceId: $e');
      rethrow;
    }
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    try {
      // Clamp rate between 0.1 and 1.0
      final clampedRate = rate.clamp(0.1, 1.0);
      await _flutterTts.setSpeechRate(clampedRate);
      _logger.info('TTS: Speech rate set to $clampedRate');
    } catch (e) {
      _logger.error('TTS: Failed to set speech rate $rate: $e');
      rethrow;
    }
  }

  @override
  Future<void> setPitch(double pitch) async {
    try {
      // Clamp pitch between 0.5 and 2.0
      final clampedPitch = pitch.clamp(0.5, 2.0);
      await _flutterTts.setPitch(clampedPitch);
      _logger.info('TTS: Pitch set to $clampedPitch');
    } catch (e) {
      _logger.error('TTS: Failed to set pitch $pitch: $e');
      rethrow;
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      // Clamp volume between 0.0 and 1.0
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _flutterTts.setVolume(clampedVolume);
      _logger.info('TTS: Volume set to $clampedVolume');
    } catch (e) {
      _logger.error('TTS: Failed to set volume $volume: $e');
      rethrow;
    }
  }

  @override
  Future<void> speak(String text) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (text.isEmpty) {
        _logger.warning('TTS: Cannot speak empty text');
        return;
      }

      _isCurrentlySpeaking = true;
      await _flutterTts.speak(text);
      _logger.info(
        'TTS: Started speaking: ${text.substring(0, text.length > 50 ? 50 : text.length)}...',
      );
    } catch (e) {
      _logger.error('TTS: Failed to speak text: $e');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isCurrentlySpeaking = false;
      _logger.info('TTS: Speech stopped');
    } catch (e) {
      _logger.error('TTS: Failed to stop speech: $e');
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      _isCurrentlySpeaking = false;
      _logger.info('TTS: Speech paused');
    } catch (e) {
      _logger.error('TTS: Failed to pause speech: $e');
      rethrow;
    }
  }

  @override
  Future<void> resume() async {
    try {
      // Flutter TTS doesn't have a direct resume method
      // We'll need to implement this differently
      _isCurrentlySpeaking = true;
      _logger.info('TTS: Resume not supported, restarting speech');
    } catch (e) {
      _logger.error('TTS: Failed to resume speech: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isSpeaking() async {
    try {
      // Flutter TTS 4.x doesn't have isSpeaking getter
      // We'll track this manually
      return _isCurrentlySpeaking;
    } catch (e) {
      _logger.error('TTS: Failed to check speaking status: $e');
      return false;
    }
  }

  @override
  Future<bool> isPaused() async {
    try {
      // Flutter TTS doesn't have a direct pause status
      // We'll track this manually
      return false;
    } catch (e) {
      _logger.error('TTS: Failed to check pause status: $e');
      return false;
    }
  }

  @override
  Future<SpeechStatus> getStatus() async {
    try {
      final speaking = await isSpeaking();
      if (speaking) {
        return SpeechStatus.speaking;
      }
      return SpeechStatus.stopped;
    } catch (e) {
      _logger.error('TTS: Failed to get status: $e');
      return SpeechStatus.error;
    }
  }

  @override
  void setCompletionCallback(Function() callback) {
    _completionCallback = callback;
  }

  @override
  void setErrorCallback(Function(String error) callback) {
    _errorCallback = callback;
  }

  @override
  Future<void> dispose() async {
    try {
      await _flutterTts.stop();
      _isInitialized = false;
      _isCurrentlySpeaking = false;
      _logger.info('TTS: Disposed successfully');
    } catch (e) {
      _logger.error('TTS: Failed to dispose: $e');
    }
  }

  @override
  /// Apply TTS configuration
  Future<void> applyConfig(TTSConfig config) async {
    try {
      await setLanguage(config.languageCode);
      if (config.voiceId.isNotEmpty) {
        await setVoice(config.voiceId);
      }
      await setSpeechRate(config.speechRate);
      await setPitch(config.pitch);
      await setVolume(config.volume);
      _logger.info('TTS: Configuration applied successfully');
    } catch (e) {
      _logger.error('TTS: Failed to apply configuration: $e');
      rethrow;
    }
  }

  @override
  /// Speak task details with formatting
  Future<void> speakTask(
    String title, {
    String? description,
    String? priority,
    DateTime? dueDate,
  }) async {
    try {
      final text = _formatTaskForSpeech(title, description, priority, dueDate);
      await speak(text);
    } catch (e) {
      _logger.error('TTS: Failed to speak task: $e');
      rethrow;
    }
  }

  /// Format task information for speech
  String _formatTaskForSpeech(
    String title,
    String? description,
    String? priority,
    DateTime? dueDate,
  ) {
    final buffer = StringBuffer();

    buffer.write('Task: $title');

    if (description != null && description.isNotEmpty) {
      buffer.write('. Description: $description');
    }

    if (priority != null && priority.isNotEmpty) {
      buffer.write('. Priority: $priority');
    }

    if (dueDate != null) {
      final now = DateTime.now();
      final difference = dueDate.difference(now);

      if (difference.isNegative) {
        buffer.write('. This task is overdue');
      } else if (difference.inDays == 0) {
        buffer.write('. Due today');
      } else if (difference.inDays == 1) {
        buffer.write('. Due tomorrow');
      } else {
        buffer.write('. Due in ${difference.inDays} days');
      }
    }

    return buffer.toString();
  }
}
