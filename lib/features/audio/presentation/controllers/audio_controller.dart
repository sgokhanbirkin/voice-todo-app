import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/audio_entity.dart';
import '../../domain/i_audio_repository.dart';
import '../../domain/i_audio_recorder.dart';
import '../../domain/i_audio_player.dart';
import '../../domain/i_speech_to_text.dart';
import 'audio_permission_controller.dart';
import '../../../../core/sync/sync_manager.dart';

/// Audio controller for managing audio recording, playback, and storage
class AudioController extends GetxController {
  final IAudioRepository _audioRepository;
  final IAudioRecorder _audioRecorder;
  final IAudioPlayer _audioPlayer;
  final ISpeechToText _speechToText;
  final SyncManager _syncManager = Get.find<SyncManager>();

  /// Observable list of all audio files
  final RxList<AudioEntity> audioFiles = <AudioEntity>[].obs;

  /// Observable list of audio files for current task
  final RxList<AudioEntity> currentTaskAudio = <AudioEntity>[].obs;

  /// Currently selected audio file
  final Rx<AudioEntity?> selectedAudio = Rx<AudioEntity?>(null);

  /// Currently playing audio
  final Rx<AudioEntity?> playingAudio = Rx<AudioEntity?>(null);

  /// Audio recording state
  final RxBool isRecording = false.obs;

  /// Audio playing state
  final RxBool isPlaying = false.obs;

  /// Audio paused state
  final RxBool isPaused = false.obs;

  /// Recording duration
  final Rx<Duration> recordingDuration = Duration.zero.obs;

  /// Recording amplitude for visualization
  final RxDouble amplitude = 0.0.obs;

  /// Playback position
  final Rx<Duration> playbackPosition = Duration.zero.obs;

  /// Playback duration
  final Rx<Duration> playbackDuration = Duration.zero.obs;

  /// Audio loading state
  final RxBool isLoading = false.obs;

  /// Audio buffering state
  final RxBool isBuffering = false.obs;

  /// Audio completed state
  final RxBool isCompleted = false.obs;

  /// Error state
  final RxBool hasError = false.obs;

  /// Error message
  final RxString errorMessage = ''.obs;

  /// Audio statistics
  final Rx<AudioStatistics?> audioStatistics = Rx<AudioStatistics?>(null);

  /// Upload progress for current file
  final RxDouble uploadProgress = 0.0.obs;

  /// Current task ID for filtering
  final RxString currentTaskId = ''.obs;

  /// Callback for recognized text
  Function(String)? onTextRecognized;

  /// Timer for recording duration updates
  Timer? _recordingTimer;

  /// Timer for playback position updates
  Timer? _playbackTimer;

  /// Speech-to-text state
  final RxBool isListening = false.obs;
  final RxString recognizedText = ''.obs;
  final RxDouble speechConfidence = 0.0.obs;
  final Rx<SpeechRecognitionState> speechState =
      SpeechRecognitionState.notListening.obs;

  AudioController(
    this._audioRepository,
    this._audioRecorder,
    this._audioPlayer,
    this._speechToText,
  );

  @override
  void onInit() {
    super.onInit();
    // Initialize repository asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAudio();
    });
  }

  /// Initialize audio services and repository
  Future<void> _initializeAudio() async {
    try {
      await _audioRepository.initialize();
      debugPrint('AudioController: Audio repository initialized');

      // Setup audio player state listeners
      _setupAudioPlayerListeners();

      loadAudioFiles();
      loadAudioStatistics();
    } catch (e) {
      debugPrint('AudioController: Failed to initialize audio repository: $e');
    }
  }

  /// Setup audio player state listeners for reactive UI updates
  void _setupAudioPlayerListeners() {
    try {
      // Player state stream listener - JustAudio specific
      _audioPlayer.playerStateStream.listen((state) async {
        debugPrint(
          'AudioController: Player state changed: ${state.processingState}',
        );

        // Update reactive states based on player state
        await _updatePlaybackStates(state);
      });

      // Position stream listener
      _audioPlayer.positionStream.listen((position) {
        playbackPosition.value = position;
      });

      // Duration stream listener
      _audioPlayer.durationStream.listen((duration) {
        playbackDuration.value = duration;
      });

      debugPrint('AudioController: Audio player listeners setup completed');
    } catch (e) {
      debugPrint('AudioController: Failed to setup audio player listeners: $e');
    }
  }

  /// Update playback states based on player state
  Future<void> _updatePlaybackStates(dynamic playerState) async {
    try {
      // Get processing state from player
      final processingState = _audioPlayer.processingState;

      // Update buffering state
      isBuffering.value =
          processingState == 'loading' || processingState == 'buffering';

      // Update completed state
      isCompleted.value = processingState == 'completed';

      // Update playing state (not playing if completed)
      isPlaying.value =
          _audioPlayer.isPlaying && processingState != 'completed';

      // Update paused state
      isPaused.value =
          !_audioPlayer.isPlaying && _audioPlayer.position > Duration.zero;

      // Auto-reset when completed
      if (processingState == 'completed') {
        await _autoResetOnCompletion();
      }

      debugPrint(
        'AudioController: States updated - Playing: ${isPlaying.value}, Paused: ${isPaused.value}, Buffering: ${isBuffering.value}, Completed: ${isCompleted.value}',
      );
    } catch (e) {
      debugPrint('AudioController: Failed to update playback states: $e');
    }
  }

  /// Auto-reset audio player when playback completes
  Future<void> _autoResetOnCompletion() async {
    try {
      debugPrint('AudioController: Auto-resetting on completion');

      // Seek to beginning
      await _audioPlayer.seek(Duration.zero);

      // Pause player
      await _audioPlayer.pause();

      // Update states
      isPlaying.value = false;
      isPaused.value = false;
      isCompleted.value = true;

      debugPrint('AudioController: Auto-reset completed');
    } catch (e) {
      debugPrint('AudioController: Failed to auto-reset: $e');
    }
  }

  @override
  void onClose() {
    // Cancel timers
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    
    stopRecording();
    stopPlayback();
    super.onClose();
  }

  /// Load all audio files
  Future<void> loadAudioFiles() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _audioRepository.getAllAudio();

      result.fold(
        (files) {
          audioFiles.value = files;
          _updateCurrentTaskAudio();
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
        },
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Load audio files for specific task
  Future<void> loadAudioForTask(String taskId) async {
    try {
      currentTaskId.value = taskId;
      isLoading.value = true;

      final result = await _audioRepository.getAudioByTaskId(taskId);

      result.fold(
        (files) {
          currentTaskAudio.value = files;
        },
        (failure) {
          hasError.value = true;
          errorMessage.value = failure.message;
        },
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Start audio recording with speech-to-text
  Future<void> startRecording() async {
    try {
      debugPrint('AudioController: startRecording called');

      if (isRecording.value) {
        debugPrint('AudioController: Already recording, returning');
        return;
      }

      // Check permissions before starting
      debugPrint('AudioController: Checking permissions...');
      if (!await _checkPermissions()) {
        debugPrint('AudioController: Permissions denied');
        _showSafeSnackbar(
          'Permission Required',
          'Microphone and storage permissions are required for recording',
          backgroundColor: Colors.orange,
        );
        return;
      }
      debugPrint('AudioController: Permissions granted');

      // Start audio recording
      debugPrint('AudioController: Starting audio recording...');
      await _audioRecorder.startRecording();
      isRecording.value = true;
      recordingDuration.value = Duration.zero;
      _startRecordingTimer();
      debugPrint('AudioController: Audio recording started successfully');

      // Start speech-to-text for live transcription
      debugPrint('AudioController: About to start live transcription...');
      await _startLiveTranscription();
      debugPrint('AudioController: Live transcription completed');

      _showSafeSnackbar(
        'Recording',
        'Audio recording started with live transcription',
      );
    } catch (e, stackTrace) {
      debugPrint('AudioController: Failed to start recording: $e');
      debugPrint('AudioController: Error stack trace: $stackTrace');
      debugPrint('AudioController: Error type: ${e.runtimeType}');

      // Re-throw to let the UI handle it
      rethrow;
    }
  }

  /// Start live speech-to-text transcription during recording
  Future<void> _startLiveTranscription() async {
    try {
      debugPrint('AudioController: Starting live transcription...');

      // Initialize speech-to-text if not already done
      debugPrint('AudioController: Initializing speech-to-text...');
      await _speechToText.initialize();
      debugPrint('AudioController: Speech-to-text initialized successfully');

      // Start listening for live transcription with custom callback
      debugPrint('AudioController: Starting speech-to-text listening...');
      await _speechToText.startListeningWithCallback(
        onResult: (text, confidence) {
          debugPrint(
            'AudioController: Speech-to-text result received: "$text" (confidence: $confidence)',
          );

          // Update recognized text in real-time
          recognizedText.value = text;
          speechConfidence.value = confidence;
          speechState.value = SpeechRecognitionState.listening;

          // Notify callback if provided
          if (onTextRecognized != null) {
            debugPrint(
              'AudioController: Calling onTextRecognized callback with: "$text"',
            );
            onTextRecognized!(text);
          } else {
            debugPrint('AudioController: onTextRecognized callback is null!');
          }

          debugPrint(
            'AudioController: Live transcription: $text (confidence: $confidence)',
          );
        },
        partialResults: true,
        localeId: 'tr-TR', // Default to Turkish
      );

      isListening.value = true;
      speechState.value = SpeechRecognitionState.listening;
      debugPrint('AudioController: Live transcription started successfully');
    } catch (e) {
      debugPrint('AudioController: Failed to start live transcription: $e');
      debugPrint('AudioController: Error stack trace: ${StackTrace.current}');
      // Don't fail recording if speech-to-text fails
      // Recording will continue without live transcription
    }
  }

  /// Stop live speech-to-text transcription
  Future<void> _stopLiveTranscription() async {
    try {
      if (isListening.value) {
        await _speechToText.stopListening();
        isListening.value = false;
        speechState.value = SpeechRecognitionState.notListening;
        debugPrint('AudioController: Live transcription stopped');
      }
    } catch (e) {
      debugPrint('AudioController: Failed to stop live transcription: $e');
      // Ensure state is reset even if stopping fails
      isListening.value = false;
      speechState.value = SpeechRecognitionState.notListening;
    }
  }

  /// Check required permissions
  Future<bool> _checkPermissions() async {
    try {
      // Use AudioPermissionController to check permissions
      final permissionController = Get.find<AudioPermissionController>();

      // Request permissions if not granted
      if (!permissionController.hasMicrophonePermission) {
        final micGranted = await permissionController
            .requestMicrophonePermission();
        if (!micGranted) {
          debugPrint('AudioController: Microphone permission denied');
          return false;
        }
      }

      // Storage permission artık gerekli değil - app kendi directory'sine yazabilir
      debugPrint(
        'AudioController: Storage permission not required for app directory',
      );

      return true;
    } catch (e) {
      debugPrint('AudioController: Permission check failed: $e');
      return false;
    }
  }

  /// Show safe snackbar with error handling
  void _showSafeSnackbar(
    String title,
    String message, {
    Color? backgroundColor,
  }) {
    try {
      // Check if Get.context is available
      if (Get.context != null) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Fallback to debug print if context is not available
        debugPrint('AudioController: $title - $message');
      }
    } catch (e) {
      // Fallback to debug print if snackbar fails
      debugPrint('AudioController: Failed to show snackbar: $e');
      debugPrint('AudioController: $title - $message');
    }
  }

  /// Stop audio recording and save
  Future<void> stopRecording({String? taskId}) async {
    try {
      if (!isRecording.value) return;

      // Stop speech-to-text if it's running
      if (isListening.value) {
        await _stopLiveTranscription();
      }

      final audioPath = await _audioRecorder.stopRecording();
      isRecording.value = false;
      
      // Stop recording timer
      _recordingTimer?.cancel();

      debugPrint(
        'AudioController: Received audio path from recorder: $audioPath',
      );

      // Create audio entity
      final audioEntity = AudioEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: taskId ?? currentTaskId.value,
        fileName: audioPath.split('/').last, // Gerçek dosya adını kullan
        localPath: audioPath, // Recorder'dan gelen gerçek path'i kullan
        fileSize: await _getFileSize(audioPath),
        duration: recordingDuration.value,
        format: 'm4a',
        recordedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to repository
      final saveResult = await _audioRepository.saveAudioMetadata(audioEntity);
      saveResult.fold(
        (savedAudio) {
          audioFiles.add(savedAudio);
          if (savedAudio.taskId == currentTaskId.value) {
            currentTaskAudio.add(savedAudio);
          }

          // Add to sync queue for Supabase
          _syncManager.addAudioToSyncQueue(savedAudio);

          _showSafeSnackbar('Success', 'Audio recording saved');

          // Speech-to-text için ses dosyasını hazırla (otomatik oynatma yok)
          _showSafeSnackbar(
            'Info',
            'Ses kaydedildi, speech-to-text için hazır',
          );

          // Kullanıcı manuel olarak play butonuna basabilir
          // _convertAudioToText(savedAudio); // Otomatik oynatma kaldırıldı
        },
        (failure) {
          _showSafeSnackbar(
            'Error',
            'Failed to save recording: ${failure.message}',
            backgroundColor: Colors.red,
          );
        },
      );
    } catch (e) {
      isRecording.value = false;
      _showSafeSnackbar(
        'Error',
        'Failed to stop recording: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Cancel audio recording
  Future<void> cancelRecording() async {
    try {
      if (!isRecording.value) return;

      await _audioRecorder.cancelRecording();
      isRecording.value = false;
      recordingDuration.value = Duration.zero;
      
      // Stop recording timer
      _recordingTimer?.cancel();
      _showSafeSnackbar('Cancelled', 'Audio recording cancelled');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel recording: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Get the last recorded audio path
  String? getLastRecordedAudioPath() {
    if (audioFiles.isNotEmpty) {
      final lastAudio = audioFiles.last;
      return lastAudio.localPath;
    }
    return null;
  }

  /// Update recording amplitude (called from recorder)
  void updateAmplitude(double newAmplitude) {
    amplitude.value = newAmplitude;
  }

  /// Play audio file with smart toggle logic
  Future<void> playAudio(AudioEntity audio) async {
    try {
      // Dosya varlığını kontrol et
      final file = File(audio.localPath);
      if (!await file.exists()) {
        throw Exception('Audio file not found: ${audio.localPath}');
      }

      debugPrint('AudioController: Playing audio file: ${audio.localPath}');
      debugPrint(
        'AudioController: File exists: ${await file.exists()}, Size: ${await file.length()} bytes',
      );

      // Smart toggle logic based on current state
      if (isCompleted.value) {
        // Completed state: seek to beginning and play
        debugPrint('AudioController: Audio completed, seeking to beginning');
        await _audioPlayer.seek(Duration.zero);
        _audioPlayer.play(audio.localPath); // NON-BLOCKING
      } else if (isPlaying.value) {
        // Already playing: pause
        debugPrint('AudioController: Audio already playing, pausing');
        await _audioPlayer.pause();
      } else {
        // Not playing: start playing
        debugPrint('AudioController: Starting audio playback');
        _audioPlayer.play(audio.localPath); // NON-BLOCKING
      }

      // Update selected audio (always)
      playingAudio.value = audio;
      selectedAudio.value = audio;

      // Start playback timer
      _startPlaybackTimer();

      // Note: State updates are now handled by stream listeners
      // No manual state setting needed
    } catch (e) {
      debugPrint('AudioController: Failed to play audio: $e');
      _showSafeSnackbar(
        'Error',
        'Failed to play audio: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Pause audio playback
  Future<void> pausePlayback() async {
    try {
      if (!isPlaying.value) return;

      await _audioPlayer.pause();
      isPlaying.value = false;
      isPaused.value = true;
      _showSafeSnackbar('Paused', 'Audio playback paused');
    } catch (e) {
      _showSafeSnackbar(
        'Error',
        'Failed to pause audio: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Resume audio playback
  Future<void> resumePlayback() async {
    try {
      if (!isPaused.value) return;

      await _audioPlayer.resume();
      isPlaying.value = true;
      isPaused.value = false;
      _showSafeSnackbar('Resumed', 'Audio playback resumed');
    } catch (e) {
      _showSafeSnackbar(
        'Error',
        'Failed to resume audio: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Stop audio playback
  Future<void> stopPlayback() async {
    try {
      await _audioPlayer.stop();
      isPlaying.value = false;
      isPaused.value = false;
      playingAudio.value = null;
      playbackPosition.value = Duration.zero;
      
      // Stop playback timer
      _playbackTimer?.cancel();
      _showSafeSnackbar('Stopped', 'Audio playback stopped');
    } catch (e) {
      _showSafeSnackbar(
        'Error',
        'Failed to stop audio: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Toggle play/pause for current audio
  Future<void> togglePlayPause() async {
    try {
      if (selectedAudio.value == null) {
        debugPrint('AudioController: No audio selected for toggle');
        return;
      }

      final audio = selectedAudio.value!;

      if (isCompleted.value) {
        // Completed: seek to beginning and play
        debugPrint(
          'AudioController: Toggle - Audio completed, seeking to beginning',
        );
        await _audioPlayer.seek(Duration.zero);
        _audioPlayer.play(audio.localPath); // NON-BLOCKING
      } else if (isPlaying.value) {
        // Playing: pause
        debugPrint('AudioController: Toggle - Pausing audio');
        await _audioPlayer.pause();
      } else {
        // Paused/Stopped: play
        debugPrint('AudioController: Toggle - Playing audio');
        _audioPlayer.play(audio.localPath); // NON-BLOCKING
      }

      // Note: State updates handled by stream listeners
    } catch (e) {
      debugPrint('AudioController: Failed to toggle play/pause: $e');
      _showSafeSnackbar(
        'Error',
        'Failed to toggle playback: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Delete audio file
  Future<void> deleteAudio(String audioId) async {
    try {
      isLoading.value = true;

      final result = await _audioRepository.deleteAudio(audioId);

      result.fold(
        (_) {
          audioFiles.removeWhere((audio) => audio.id == audioId);
          currentTaskAudio.removeWhere((audio) => audio.id == audioId);
          if (selectedAudio.value?.id == audioId) {
            selectedAudio.value = null;
          }
          if (playingAudio.value?.id == audioId) {
            stopPlayback();
          }

          // Add to sync queue for Supabase delete
          _syncManager.addAudioDeleteToSyncQueue(audioId);

          Get.snackbar('Success', 'Audio deleted successfully');
        },
        (failure) {
          Get.snackbar('Error', 'Failed to delete audio: ${failure.message}');
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load audio statistics
  Future<void> loadAudioStatistics() async {
    try {
      final result = await _audioRepository.getAudioStatistics();

      result.fold(
        (statistics) {
          audioStatistics.value = statistics;
        },
        (failure) {
          // Handle statistics loading failure silently
        },
      );
    } catch (e) {
      // Handle statistics loading error silently
    }
  }

  /// Update current task audio list
  void _updateCurrentTaskAudio() {
    if (currentTaskId.value.isNotEmpty) {
      currentTaskAudio.value = audioFiles
          .where((audio) => audio.taskId == currentTaskId.value)
          .toList();
    }
  }

  /// Start recording timer
  void _startRecordingTimer() {
    // Cancel existing timer if any
    _recordingTimer?.cancel();
    
    // Start periodic timer to update recording duration
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (isRecording.value) {
        recordingDuration.value = recordingDuration.value + const Duration(milliseconds: 100);
      } else {
        timer.cancel();
      }
    });
  }

  /// Start playback timer
  void _startPlaybackTimer() {
    // Cancel existing timer if any
    _playbackTimer?.cancel();
    
    // Start periodic timer to update playback position
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (isPlaying.value && !isCompleted.value) {
        // Update position from player if available
        if (_audioPlayer.position > Duration.zero) {
          playbackPosition.value = _audioPlayer.position;
        }
      } else {
        timer.cancel();
      }
    });
  }

  /// Get file size in bytes
  Future<int> _getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Refresh all data
  @override
  Future<void> refresh() async {
    await loadAudioFiles();
    await loadAudioStatistics();
  }

  // ===== SPEECH-TO-TEXT METHODS =====

  /// Start speech recognition
  Future<void> startSpeechRecognition() async {
    try {
      // Speech recognition'ı initialize et
      await _speechToText.initialize();

      isListening.value = true;
      speechState.value = SpeechRecognitionState.listening;
      recognizedText.value = '';
      speechConfidence.value = 0.0;

      await _speechToText.startListening();
      debugPrint('AudioController: Speech recognition started successfully');
    } catch (e) {
      isListening.value = false;
      speechState.value = SpeechRecognitionState.error;
      debugPrint('AudioController: Failed to start speech recognition: $e');
      _showSafeSnackbar(
        'Error',
        'Speech recognition başlatılamadı: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Stop speech recognition
  Future<void> stopSpeechRecognition() async {
    try {
      isListening.value = false;
      speechState.value = SpeechRecognitionState.processing;

      await _speechToText.stopListening();
      debugPrint('AudioController: Speech recognition stopped successfully');
    } catch (e) {
      speechState.value = SpeechRecognitionState.error;
      debugPrint('AudioController: Failed to stop speech recognition: $e');
      _showSafeSnackbar(
        'Error',
        'Speech recognition durdurulamadı: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Cancel speech recognition
  Future<void> cancelSpeechRecognition() async {
    try {
      isListening.value = false;
      speechState.value = SpeechRecognitionState.notListening;
      recognizedText.value = '';

      await _speechToText.cancel();
      debugPrint('AudioController: Speech recognition cancelled successfully');
    } catch (e) {
      debugPrint('AudioController: Failed to cancel speech recognition: $e');
      _showSafeSnackbar(
        'Error',
        'Speech recognition iptal edilemedi: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Get recognized text for task creation
  String getRecognizedText() {
    return recognizedText.value;
  }

  /// Clear recognized text
  void clearRecognizedText() {
    recognizedText.value = '';
    speechConfidence.value = 0.0;
  }
}
