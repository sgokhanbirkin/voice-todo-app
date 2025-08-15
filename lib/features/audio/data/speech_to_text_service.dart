import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../domain/i_speech_to_text.dart';

/// Speech-to-text service implementation using Flutter's speech_to_text package
class SpeechToTextService implements ISpeechToText {
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  final StreamController<String> _textController =
      StreamController<String>.broadcast();
  final StreamController<double> _confidenceController =
      StreamController<double>.broadcast();
  final StreamController<SpeechRecognitionState> _stateController =
      StreamController<SpeechRecognitionState>.broadcast();

  String _currentLanguage = 'tr-TR'; // Default to Turkish
  bool _showPartialResults = true;
  Duration _maxListeningDuration = const Duration(seconds: 60);

  bool _isInitialized = false;
  bool _isListening = false;
  String _recognizedText = '';
  double _confidence = 0.0;
  SpeechRecognitionState _currentState = SpeechRecognitionState.notListening;

  @override
  Future<void> initialize() async {
    try {
      debugPrint('SpeechToTextService: initialize called');

      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          debugPrint(
            'SpeechToTextService: Speech recognition error: ${error.errorMsg}',
          );
          _currentState = SpeechRecognitionState.error;
          _stateController.add(_currentState);
        },
        onStatus: (status) {
          debugPrint('SpeechToTextService: Speech recognition status: $status');
          _handleStatusChange(status);
        },
      );

      debugPrint('SpeechToTextService: Initialize result: $_isInitialized');

      if (_isInitialized) {
        _currentState = SpeechRecognitionState.notListening;
        _stateController.add(_currentState);
        debugPrint('SpeechToTextService: Initialized successfully');
      } else {
        _currentState = SpeechRecognitionState.error;
        _stateController.add(_currentState);
        debugPrint('SpeechToTextService: Failed to initialize');
      }
    } catch (e) {
      debugPrint(
        'SpeechToTextService: Failed to initialize speech recognition: $e',
      );
      debugPrint(
        'SpeechToTextService: Error stack trace: ${StackTrace.current}',
      );
      _currentState = SpeechRecognitionState.error;
      _stateController.add(_currentState);
    }
  }

  @override
  Future<void> startListening() async {
    if (!_isInitialized) {
      debugPrint('Speech recognition not initialized');
      return;
    }

    try {
      await _speechToText.listen(
        onResult: _handleResult,
        localeId: _currentLanguage,
        listenFor: _maxListeningDuration,
        listenOptions: stt.SpeechListenOptions(
          partialResults: _showPartialResults,
          listenMode: stt.ListenMode.confirmation,
        ),
      );

      _isListening = true;
      _currentState = SpeechRecognitionState.listening;
      _stateController.add(_currentState);
    } catch (e) {
      debugPrint('Failed to start listening: $e');
      _currentState = SpeechRecognitionState.error;
      _stateController.add(_currentState);
    }
  }

  @override
  Future<void> startListeningWithCallback({
    required Function(String text, double confidence) onResult,
    bool partialResults = true,
    String? localeId,
  }) async {
    debugPrint('SpeechToTextService: startListeningWithCallback called');

    if (!_isInitialized) {
      debugPrint('SpeechToTextService: Speech recognition not initialized');
      return;
    }

    try {
      debugPrint('SpeechToTextService: Starting speech-to-text listening...');
      debugPrint(
        'SpeechToTextService: Locale: ${localeId ?? _currentLanguage}',
      );
      debugPrint('SpeechToTextService: Partial results: $partialResults');

      await _speechToText.listen(
        onResult: (result) {
          debugPrint(
            'SpeechToTextService: Raw result received: ${result.recognizedWords}',
          );

          // Call the custom callback
          onResult(result.recognizedWords, result.confidence);

          // Also update internal state
          _handleResult(result);
        },
        localeId: localeId ?? _currentLanguage,
        listenFor: _maxListeningDuration,
        listenOptions: stt.SpeechListenOptions(
          partialResults: partialResults,
          listenMode: stt.ListenMode.dictation,
        ),
      );

      _isListening = true;
      _currentState = SpeechRecognitionState.listening;
      _stateController.add(_currentState);
      debugPrint(
        'SpeechToTextService: Speech-to-text listening started successfully',
      );
    } catch (e) {
      debugPrint(
        'SpeechToTextService: Failed to start listening with callback: $e',
      );
      debugPrint(
        'SpeechToTextService: Error stack trace: ${StackTrace.current}',
      );
      _currentState = SpeechRecognitionState.error;
      _stateController.add(_currentState);
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      _isListening = false;
      _currentState = SpeechRecognitionState.notListening;
      _stateController.add(_currentState);
    } catch (e) {
      debugPrint('Failed to stop listening: $e');
      _currentState = SpeechRecognitionState.error;
      _stateController.add(_currentState);
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _speechToText.cancel();
      _isListening = false;
      _recognizedText = '';
      _confidence = 0.0;
      _currentState = SpeechRecognitionState.notListening;
      _stateController.add(_currentState);
    } catch (e) {
      debugPrint('Failed to cancel listening: $e');
      _currentState = SpeechRecognitionState.error;
      _stateController.add(_currentState);
    }
  }

  @override
  bool get isListening => _isListening;

  @override
  double get confidence => _confidence;

  @override
  String get recognizedText => _recognizedText;

  @override
  Stream<String> get textStream => _textController.stream;

  @override
  Stream<double> get confidenceStream => _confidenceController.stream;

  @override
  Stream<SpeechRecognitionState> get recognitionStateStream =>
      _stateController.stream;

  @override
  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
  }

  @override
  String get language => _currentLanguage;

  @override
  Future<void> setShowPartialResults(bool show) async {
    _showPartialResults = show;
  }

  @override
  bool get showPartialResults => _showPartialResults;

  @override
  Future<void> setMaxListeningDuration(Duration duration) async {
    _maxListeningDuration = duration;
  }

  @override
  Duration get maxListeningDuration => _maxListeningDuration;

  @override
  Future<void> dispose() async {
    await cancel();
    await _textController.close();
    await _confidenceController.close();
    await _stateController.close();
  }

  /// Handle speech recognition results
  void _handleResult(dynamic result) {
    try {
      if (result.finalResult) {
        _recognizedText = result.recognizedWords;
        _confidence = result.confidence;
        _currentState = SpeechRecognitionState.completed;
        debugPrint(
          'Speech recognition completed: $_recognizedText (confidence: $_confidence)',
        );
      } else {
        _recognizedText = result.recognizedWords;
        _confidence = result.confidence;
        _currentState = SpeechRecognitionState.listening;
        debugPrint(
          'Speech recognition partial: $_recognizedText (confidence: $_confidence)',
        );
      }

      _textController.add(_recognizedText);
      _confidenceController.add(_confidence);
      _stateController.add(_currentState);
    } catch (e) {
      debugPrint('Error handling speech recognition result: $e');
      _currentState = SpeechRecognitionState.error;
      _stateController.add(_currentState);
    }
  }

  /// Handle status changes
  void _handleStatusChange(String status) {
    switch (status) {
      case 'listening':
        _currentState = SpeechRecognitionState.listening;
        break;
      case 'notListening':
        _currentState = SpeechRecognitionState.notListening;
        _isListening = false;
        break;
      case 'done':
        _currentState = SpeechRecognitionState.completed;
        _isListening = false;
        break;
      case 'error':
        _currentState = SpeechRecognitionState.error;
        _isListening = false;
        break;
    }

    _stateController.add(_currentState);
  }
}
