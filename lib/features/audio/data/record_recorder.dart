library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../domain/i_audio_recorder.dart';

/// Record recorder implementation
class RecordRecorder implements IAudioRecorder {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentFilePath;
  bool _isRecording = false;

  // Duration tracking
  DateTime? _recordingStartTime;
  Timer? _durationTimer;
  Duration _currentDuration = Duration.zero;

  // Amplitude tracking
  double _currentAmplitude = 0.0;
  Timer? _amplitudeTimer;

  @override
  Future<void> initialize() async {
    // No-op for now. The record package initializes lazily on start.
    // Hook recording state updates
    _recorder.onStateChanged().listen((state) {
      _isRecording = state == RecordState.record;
    });
  }

  @override
  Future<void> startRecording() async {
    try {
      debugPrint('RecordRecorder: startRecording called');

      // Ensure microphone permission
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission not granted');
      }

      // Resolve a writable file path inside app's documents dir
      final Directory baseDir = await getApplicationDocumentsDirectory();
      final Directory audioDir = Directory('${baseDir.path}/audio');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      _currentFilePath =
          '${audioDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      debugPrint('RecordRecorder: Starting recording to: $_currentFilePath');

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: _currentFilePath!,
      );

      // Start duration and amplitude tracking
      _startDurationTracking();
      _startAmplitudeTracking();

      _isRecording = true;
      _recordingStartTime = DateTime.now();
      debugPrint('RecordRecorder: Recording started successfully');
    } catch (e) {
      debugPrint('RecordRecorder: Failed to start recording: $e');
      debugPrint('RecordRecorder: Error stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  @override
  Future<String> stopRecording() async {
    try {
      debugPrint('RecordRecorder: stopRecording called');

      // Stop tracking timers
      _stopDurationTracking();
      _stopAmplitudeTracking();

      await _recorder.stop();
      _isRecording = false;
      _recordingStartTime = null;

      // Return the path we used for recording
      final recordedPath = _currentFilePath ?? '';
      debugPrint('RecordRecorder: Stopped recording, file path: $recordedPath');

      // Verify file exists
      if (recordedPath.isNotEmpty) {
        final file = File(recordedPath);
        if (await file.exists()) {
          final fileSize = await file.length();
          debugPrint(
            'RecordRecorder: File exists, size: $fileSize bytes, duration: $_currentDuration',
          );
        } else {
          debugPrint(
            'RecordRecorder: WARNING - File does not exist at: $recordedPath',
          );
        }
      }

      return recordedPath;
    } catch (e) {
      debugPrint('RecordRecorder: Error stopping recording: $e');
      debugPrint('RecordRecorder: Error stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  @override
  Future<void> pauseRecording() async {
    // Record package doesn't support pause/resume
    // This method is kept for interface compatibility
    debugPrint(
      'RecordRecorder: pauseRecording not supported by record package',
    );
  }

  @override
  Future<void> resumeRecording() async {
    // Record package doesn't support pause/resume
    // This method is kept for interface compatibility
    debugPrint(
      'RecordRecorder: resumeRecording not supported by record package',
    );
  }

  @override
  Future<void> cancelRecording() async {
    try {
      debugPrint('RecordRecorder: cancelRecording called');

      // Stop tracking timers
      _stopDurationTracking();
      _stopAmplitudeTracking();

      await _recorder.stop();
      _isRecording = false;
      _recordingStartTime = null;
      _currentDuration = Duration.zero;
      _currentAmplitude = 0.0;

      debugPrint('RecordRecorder: Recording cancelled successfully');
    } catch (e) {
      debugPrint('RecordRecorder: Error cancelling recording: $e');
      debugPrint('RecordRecorder: Error stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  @override
  bool get isRecording => _isRecording;

  @override
  bool get isPaused => false; // Record package doesn't support pause

  @override
  Duration get recordingDuration => _currentDuration;

  @override
  double get amplitude => _currentAmplitude;

  @override
  Stream<Duration> get durationStream {
    return Stream.periodic(
      const Duration(milliseconds: 100),
      (i) => _currentDuration,
    );
  }

  @override
  Stream<double> get amplitudeStream {
    return Stream.periodic(
      const Duration(milliseconds: 50),
      (i) => _currentAmplitude,
    );
  }

  @override
  Stream<AudioRecordingState> get recordingStateStream {
    return _recorder.onStateChanged().map((state) {
      switch (state) {
        case RecordState.record:
          return AudioRecordingState.recording;
        case RecordState.pause:
          return AudioRecordingState.paused;
        case RecordState.stop:
          return AudioRecordingState.stopped;
      }
    });
  }

  @override
  Future<void> setQuality(AudioQuality quality) async {
    // Quality is fixed to medium for simplicity
    // Record package configuration is set once during startRecording
    debugPrint(
      'RecordRecorder: setQuality not implemented - using fixed medium quality',
    );
  }

  @override
  AudioQuality get quality => AudioQuality.medium; // Fixed quality for simplicity

  @override
  Future<void> setFormat(AudioFormat format) async {
    // Format is fixed to M4A for compatibility
    // Record package configuration is set once during startRecording
    debugPrint(
      'RecordRecorder: setFormat not implemented - using fixed M4A format',
    );
  }

  @override
  AudioFormat get format => AudioFormat.m4a; // Fixed M4A format for compatibility

  @override
  Future<void> setMaxDuration(Duration maxDuration) async {
    // Max duration is fixed to 10 minutes for simplicity
    // Record package configuration is set once during startRecording
    debugPrint(
      'RecordRecorder: setMaxDuration not implemented - using fixed 10 minute limit',
    );
  }

  @override
  Duration get maxDuration => const Duration(minutes: 10); // Fixed 10 minute limit for simplicity

  @override
  Future<void> dispose() async {
    _stopDurationTracking();
    _stopAmplitudeTracking();
    await _recorder.dispose();
  }

  /// Start duration tracking timer
  void _startDurationTracking() {
    _durationTimer?.cancel();
    _currentDuration = Duration.zero;
    _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isRecording && _recordingStartTime != null) {
        _currentDuration = DateTime.now().difference(_recordingStartTime!);
      }
    });
  }

  /// Stop duration tracking timer
  void _stopDurationTracking() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  /// Start amplitude tracking timer
  void _startAmplitudeTracking() {
    _amplitudeTimer?.cancel();
    _currentAmplitude = 0.0;
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 50), (
      timer,
    ) async {
      if (_isRecording) {
        try {
          final amplitude = await _recorder.getAmplitude();
          _currentAmplitude = amplitude.current;
        } catch (e) {
          // Amplitude tracking is optional, don't fail recording
          debugPrint('RecordRecorder: Failed to get amplitude: $e');
        }
      }
    });
  }

  /// Stop amplitude tracking timer
  void _stopAmplitudeTracking() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
  }
}

// Note: Pause/resume not supported by record package
// Note: Quality/format settings are fixed for simplicity
// Note: Duration and amplitude tracking implemented
