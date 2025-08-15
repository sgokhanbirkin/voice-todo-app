import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../domain/i_speech_to_text.dart';
import '../../../todos/domain/task_entity.dart';

/// Voice Commands Controller - Ses komutlarını yönetir ve real-time transcription sağlar
class VoiceCommandsController extends GetxController {
  final ISpeechToText _speechToText;

  // State variables
  final RxBool _isListening = false.obs;
  final RxString _recognizedText = ''.obs;
  final RxDouble _confidence = 0.0.obs;
  final Rx<VoiceRecognitionState> _recognitionState =
      VoiceRecognitionState.notListening.obs;

  // Voice command patterns
  static const Map<String, VoiceCommandType> _commandPatterns = {
    'ekle': VoiceCommandType.addTask,
    'add': VoiceCommandType.addTask,
    'yeni': VoiceCommandType.addTask,
    'new': VoiceCommandType.addTask,
    'tamamla': VoiceCommandType.completeTask,
    'complete': VoiceCommandType.completeTask,
    'bitir': VoiceCommandType.completeTask,
    'finish': VoiceCommandType.completeTask,
    'sil': VoiceCommandType.deleteTask,
    'delete': VoiceCommandType.deleteTask,
    'kaldır': VoiceCommandType.deleteTask,
    'remove': VoiceCommandType.removeTask,
    'yıldız': VoiceCommandType.starTask,
    'star': VoiceCommandType.starTask,
    'öncelik': VoiceCommandType.setPriority,
    'priority': VoiceCommandType.setPriority,
    'yüksek': VoiceCommandType.setPriority,
    'high': VoiceCommandType.setPriority,
    'orta': VoiceCommandType.setPriority,
    'medium': VoiceCommandType.setPriority,
    'düşük': VoiceCommandType.setPriority,
    'low': VoiceCommandType.setPriority,
  };

  VoiceCommandsController(this._speechToText);

  // Getters
  bool get isListening => _isListening.value;
  String get recognizedText => _recognizedText.value;
  double get confidence => _confidence.value;
  VoiceRecognitionState get recognitionState => _recognitionState.value;

  // Streams
  Stream<String> get textStream => _speechToText.textStream;
  Stream<double> get confidenceStream => _speechToText.confidenceStream;
  Stream<VoiceRecognitionState> get recognitionStateStream =>
      _recognitionState.stream;

  @override
  void onInit() {
    super.onInit();
    _initializeSpeechRecognition();
    _setupStreams();
  }

  /// Initialize speech recognition
  Future<void> _initializeSpeechRecognition() async {
    try {
      await _speechToText.initialize();
      debugPrint('Voice Commands Controller: Speech recognition initialized');
    } catch (e) {
      debugPrint(
        'Voice Commands Controller: Failed to initialize speech recognition: $e',
      );
      _recognitionState.value = VoiceRecognitionState.error;
    }
  }

  /// Setup stream listeners
  void _setupStreams() {
    _speechToText.textStream.listen((text) {
      _recognizedText.value = text;
      _processVoiceCommand(text);
    });

    _speechToText.confidenceStream.listen((conf) {
      _confidence.value = conf;
    });

    _speechToText.recognitionStateStream.listen((state) {
      _recognitionState.value = _mapSpeechStateToVoiceState(state);
    });
  }

  /// Start listening for voice commands
  Future<void> startListening() async {
    try {
      await _speechToText.startListening();
      _isListening.value = true;
      debugPrint('Voice Commands Controller: Started listening');
    } catch (e) {
      debugPrint('Voice Commands Controller: Failed to start listening: $e');
    }
  }

  /// Stop listening for voice commands
  Future<void> stopListening() async {
    try {
      await _speechToText.stopListening();
      _isListening.value = false;
      debugPrint('Voice Commands Controller: Stopped listening');
    } catch (e) {
      debugPrint('Voice Commands Controller: Failed to stop listening: $e');
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
      _isListening.value = false;
      _recognizedText.value = '';
      _confidence.value = 0.0;
      debugPrint('Voice Commands Controller: Cancelled listening');
    } catch (e) {
      debugPrint('Voice Commands Controller: Failed to cancel listening: $e');
    }
  }

  /// Process voice command and extract intent
  void _processVoiceCommand(String text) {
    if (text.isEmpty) return;

    final lowerText = text.toLowerCase();
    debugPrint('Voice Commands Controller: Processing command: $lowerText');

    // Check for command patterns
    for (final entry in _commandPatterns.entries) {
      if (lowerText.contains(entry.key)) {
        final commandType = entry.value;
        final commandData = _extractCommandData(lowerText, commandType);

        debugPrint(
          'Voice Commands Controller: Command detected: $commandType with data: $commandData',
        );
        _executeVoiceCommand(commandType, commandData);
        return;
      }
    }

    // If no specific command found, treat as general text input
    debugPrint(
      'Voice Commands Controller: No specific command found, treating as text input',
    );
    _onTextInput(text);
  }

  /// Extract data from voice command
  Map<String, dynamic> _extractCommandData(
    String text,
    VoiceCommandType commandType,
  ) {
    final data = <String, dynamic>{};

    switch (commandType) {
      case VoiceCommandType.addTask:
        // Extract task title and description
        final titleMatch = RegExp(
          r'(?:ekle|add|yeni|new)\s+(.+)',
        ).firstMatch(text);
        if (titleMatch != null) {
          data['title'] = titleMatch.group(1)?.trim() ?? '';
        }

        // Extract priority
        if (text.contains('yüksek') || text.contains('high')) {
          data['priority'] = TaskPriority.high;
        } else if (text.contains('orta') || text.contains('medium')) {
          data['priority'] = TaskPriority.medium;
        } else if (text.contains('düşük') || text.contains('low')) {
          data['priority'] = TaskPriority.low;
        }
        break;

      case VoiceCommandType.setPriority:
        // Extract priority level
        if (text.contains('yüksek') || text.contains('high')) {
          data['priority'] = TaskPriority.high;
        } else if (text.contains('orta') || text.contains('medium')) {
          data['priority'] = TaskPriority.medium;
        } else if (text.contains('düşük') || text.contains('low')) {
          data['priority'] = TaskPriority.low;
        }
        break;

      case VoiceCommandType.completeTask:
      case VoiceCommandType.deleteTask:
      case VoiceCommandType.starTask:
        // Extract task identifier (could be number, title, etc.)
        final taskMatch = RegExp(
          r'(?:tamamla|complete|bitir|finish|sil|delete|kaldır|remove|yıldız|star)\s+(.+)',
        ).firstMatch(text);
        if (taskMatch != null) {
          data['taskIdentifier'] = taskMatch.group(1)?.trim() ?? '';
        }
        break;

      default:
        break;
    }

    return data;
  }

  /// Execute voice command
  void _executeVoiceCommand(
    VoiceCommandType commandType,
    Map<String, dynamic> data,
  ) {
    switch (commandType) {
      case VoiceCommandType.addTask:
        _onAddTaskCommand(data);
        break;
      case VoiceCommandType.completeTask:
        _onCompleteTaskCommand(data);
        break;
      case VoiceCommandType.deleteTask:
        _onDeleteTaskCommand(data);
        break;
      case VoiceCommandType.starTask:
        _onStarTaskCommand(data);
        break;
      case VoiceCommandType.setPriority:
        _onSetPriorityCommand(data);
        break;
      case VoiceCommandType.removeTask:
        _onRemoveTaskCommand(data);
        break;
    }
  }

  /// Callbacks for voice commands (to be implemented by UI)
  void Function(Map<String, dynamic> data)? onAddTaskCommand;
  void Function(Map<String, dynamic> data)? onCompleteTaskCommand;
  void Function(Map<String, dynamic> data)? onDeleteTaskCommand;
  void Function(Map<String, dynamic> data)? onStarTaskCommand;
  void Function(Map<String, dynamic> data)? onSetPriorityCommand;
  void Function(Map<String, dynamic> data)? onRemoveTaskCommand;
  void Function(String text)? onTextInput;

  /// Handle add task command
  void _onAddTaskCommand(Map<String, dynamic> data) {
    onAddTaskCommand?.call(data);
  }

  /// Handle complete task command
  void _onCompleteTaskCommand(Map<String, dynamic> data) {
    onCompleteTaskCommand?.call(data);
  }

  /// Handle delete task command
  void _onDeleteTaskCommand(Map<String, dynamic> data) {
    onDeleteTaskCommand?.call(data);
  }

  /// Handle star task command
  void _onStarTaskCommand(Map<String, dynamic> data) {
    onStarTaskCommand?.call(data);
  }

  /// Handle set priority command
  void _onSetPriorityCommand(Map<String, dynamic> data) {
    onSetPriorityCommand?.call(data);
  }

  /// Handle remove task command
  void _onRemoveTaskCommand(Map<String, dynamic> data) {
    onRemoveTaskCommand?.call(data);
  }

  /// Handle general text input
  void _onTextInput(String text) {
    onTextInput?.call(text);
  }

  /// Map speech recognition state to voice recognition state
  VoiceRecognitionState _mapSpeechStateToVoiceState(
    SpeechRecognitionState state,
  ) {
    switch (state) {
      case SpeechRecognitionState.listening:
        return VoiceRecognitionState.listening;
      case SpeechRecognitionState.notListening:
        return VoiceRecognitionState.notListening;
      case SpeechRecognitionState.completed:
        return VoiceRecognitionState.completed;
      case SpeechRecognitionState.error:
        return VoiceRecognitionState.error;
      default:
        return VoiceRecognitionState.notListening;
    }
  }

  /// Set language for speech recognition
  Future<void> setLanguage(String languageCode) async {
    await _speechToText.setLanguage(languageCode);
  }

  /// Get current language
  String get language => _speechToText.language;

  @override
  void onClose() {
    _speechToText.dispose();
    super.onClose();
  }
}

/// Voice command types
enum VoiceCommandType {
  addTask,
  completeTask,
  deleteTask,
  starTask,
  setPriority,
  removeTask,
}

/// Voice recognition states
enum VoiceRecognitionState { listening, notListening, completed, error }
