import 'package:get/get.dart';
import 'package:voice_todo/core/logger.dart';
import 'package:voice_todo/features/audio/data/flutter_tts_service.dart';
import 'package:voice_todo/features/audio/domain/i_text_to_speech.dart';

/// Text-to-Speech Controller
class TextToSpeechController extends GetxController {
  final ITextToSpeech _ttsService = FlutterTTSService();
  final Logger _logger = Logger.instance;

  // Reactive variables
  final RxBool isInitialized = false.obs;
  final RxBool isAvailable = false.obs;
  final RxBool isSpeaking = false.obs;
  final RxBool isPaused = false.obs;
  final Rx<SpeechStatus> currentStatus = SpeechStatus.stopped.obs;
  final RxString currentLanguage = 'en-US'.obs;
  final RxString currentVoice = ''.obs;
  final RxDouble currentSpeechRate = 0.5.obs;
  final RxDouble currentPitch = 1.0.obs;
  final RxDouble currentVolume = 1.0.obs;

  // Available options
  final RxList<String> availableLanguages = <String>[].obs;
  final RxList<Map<String, dynamic>> availableVoices =
      <Map<String, dynamic>>[].obs;

  // Error handling
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeTTS();
  }

  @override
  void onClose() {
    _ttsService.dispose();
    super.onClose();
  }

  /// Initialize TTS service
  Future<void> _initializeTTS() async {
    try {
      hasError.value = false;
      errorMessage.value = '';

      // Initialize TTS
      final initialized = await _ttsService.initialize();
      isInitialized.value = initialized;

      if (initialized) {
        // Check availability
        final available = await _ttsService.isAvailable();
        isAvailable.value = available;

        if (available) {
          // Load available languages and voices
          await _loadAvailableOptions();

          // Set completion and error callbacks
          _ttsService.setCompletionCallback(_onSpeechCompleted);
          _ttsService.setErrorCallback(_onSpeechError);

          _logger.info('TTS Controller: Initialized successfully');
        } else {
          _logger.warning('TTS Controller: TTS not available on this device');
        }
      } else {
        _logger.error('TTS Controller: Failed to initialize TTS');
        _setError('Failed to initialize TTS');
      }
    } catch (e) {
      _logger.error('TTS Controller: Initialization error: $e');
      _setError('Initialization error: $e');
    }
  }

  /// Load available languages and voices
  Future<void> _loadAvailableOptions() async {
    try {
      // Load languages
      final languages = await _ttsService.getAvailableLanguages();
      availableLanguages.value = languages;

      // Load voices
      final voices = await _ttsService.getAvailableVoices();
      availableVoices.value = voices;

      _logger.info(
        'TTS Controller: Loaded ${languages.length} languages and ${voices.length} voices',
      );
    } catch (e) {
      _logger.error('TTS Controller: Failed to load available options: $e');
    }
  }

  /// Speak text
  Future<void> speak(String text) async {
    try {
      if (!isInitialized.value) {
        await _initializeTTS();
      }

      if (!isAvailable.value) {
        _setError('TTS is not available on this device');
        return;
      }

      if (text.isEmpty) {
        _setError('Cannot speak empty text');
        return;
      }

      hasError.value = false;
      errorMessage.value = '';

      await _ttsService.speak(text);
      isSpeaking.value = true;
      currentStatus.value = SpeechStatus.speaking;
      isPaused.value = false;

      _logger.info('TTS Controller: Started speaking text');
    } catch (e) {
      _logger.error('TTS Controller: Failed to speak text: $e');
      _setError('Failed to speak text: $e');
    }
  }

  /// Speak task details
  Future<void> speakTask(
    String title, {
    String? description,
    String? priority,
    DateTime? dueDate,
  }) async {
    try {
      if (!isInitialized.value) {
        await _initializeTTS();
      }

      if (!isAvailable.value) {
        _setError('TTS is not available on this device');
        return;
      }

      hasError.value = false;
      errorMessage.value = '';

      await _ttsService.speakTask(
        title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );
      isSpeaking.value = true;
      currentStatus.value = SpeechStatus.speaking;
      isPaused.value = false;

      _logger.info('TTS Controller: Started speaking task: $title');
    } catch (e) {
      _logger.error('TTS Controller: Failed to speak task: $e');
      _setError('Failed to speak task: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _ttsService.stop();
      isSpeaking.value = false;
      isPaused.value = false;
      currentStatus.value = SpeechStatus.stopped;

      _logger.info('TTS Controller: Speech stopped');
    } catch (e) {
      _logger.error('TTS Controller: Failed to stop speech: $e');
      _setError('Failed to stop speech: $e');
    }
  }

  /// Pause speaking
  Future<void> pause() async {
    try {
      await _ttsService.pause();
      isPaused.value = true;
      currentStatus.value = SpeechStatus.paused;

      _logger.info('TTS Controller: Speech paused');
    } catch (e) {
      _logger.error('TTS Controller: Failed to pause speech: $e');
      _setError('Failed to pause speech: $e');
    }
  }

  /// Resume speaking
  Future<void> resume() async {
    try {
      await _ttsService.resume();
      isPaused.value = false;
      currentStatus.value = SpeechStatus.speaking;

      _logger.info('TTS Controller: Speech resumed');
    } catch (e) {
      _logger.error('TTS Controller: Failed to resume speech: $e');
      _setError('Failed to resume speech: $e');
    }
  }

  /// Set language
  Future<void> setLanguage(String languageCode) async {
    try {
      await _ttsService.setLanguage(languageCode);
      currentLanguage.value = languageCode;
      _logger.info('TTS Controller: Language set to $languageCode');
    } catch (e) {
      _logger.error('TTS Controller: Failed to set language: $e');
      _setError('Failed to set language: $e');
    }
  }

  /// Set voice
  Future<void> setVoice(String voiceId) async {
    try {
      await _ttsService.setVoice(voiceId);
      currentVoice.value = voiceId;
      _logger.info('TTS Controller: Voice set to $voiceId');
    } catch (e) {
      _logger.error('TTS Controller: Failed to set voice: $e');
      _setError('Failed to set voice: $e');
    }
  }

  /// Set speech rate
  Future<void> setSpeechRate(double rate) async {
    try {
      final clampedRate = rate.clamp(0.1, 1.0);
      await _ttsService.setSpeechRate(clampedRate);
      currentSpeechRate.value = clampedRate;
      _logger.info('TTS Controller: Speech rate set to $clampedRate');
    } catch (e) {
      _logger.error('TTS Controller: Failed to set speech rate: $e');
      _setError('Failed to set speech rate: $e');
    }
  }

  /// Set pitch
  Future<void> setPitch(double pitch) async {
    try {
      final clampedPitch = pitch.clamp(0.5, 2.0);
      await _ttsService.setPitch(clampedPitch);
      currentPitch.value = clampedPitch;
      _logger.info('TTS Controller: Pitch set to $clampedPitch');
    } catch (e) {
      _logger.error('TTS Controller: Failed to set pitch: $e');
      _setError('Failed to set pitch: $e');
    }
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _ttsService.setVolume(clampedVolume);
      currentVolume.value = clampedVolume;
      _logger.info('TTS Controller: Volume set to $clampedVolume');
    } catch (e) {
      _logger.error('TTS Controller: Failed to set volume: $e');
      _setError('Failed to set volume: $e');
    }
  }

  /// Apply TTS configuration
  Future<void> applyConfig(TTSConfig config) async {
    try {
      await _ttsService.applyConfig(config);

      currentLanguage.value = config.languageCode;
      currentVoice.value = config.voiceId;
      currentSpeechRate.value = config.speechRate;
      currentPitch.value = config.pitch;
      currentVolume.value = config.volume;

      _logger.info('TTS Controller: Configuration applied successfully');
    } catch (e) {
      _logger.error('TTS Controller: Failed to apply configuration: $e');
      _setError('Failed to apply configuration: $e');
    }
  }

  /// Get current TTS configuration
  TTSConfig getCurrentConfig() {
    return TTSConfig(
      languageCode: currentLanguage.value,
      voiceId: currentVoice.value,
      speechRate: currentSpeechRate.value,
      pitch: currentPitch.value,
      volume: currentVolume.value,
    );
  }

  /// Speech completion callback
  void _onSpeechCompleted() {
    isSpeaking.value = false;
    isPaused.value = false;
    currentStatus.value = SpeechStatus.completed;
    _logger.info('TTS Controller: Speech completed');
  }

  /// Speech error callback
  void _onSpeechError(String error) {
    isSpeaking.value = false;
    isPaused.value = false;
    currentStatus.value = SpeechStatus.error;
    _setError('Speech error: $error');
  }

  /// Set error message
  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
  }

  /// Clear error
  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }

  /// Refresh TTS status
  Future<void> refreshStatus() async {
    try {
      if (isInitialized.value) {
        final status = await _ttsService.getStatus();
        currentStatus.value = status;

        final speaking = await _ttsService.isSpeaking();
        isSpeaking.value = speaking;
      }
    } catch (e) {
      _logger.error('TTS Controller: Failed to refresh status: $e');
    }
  }
}
