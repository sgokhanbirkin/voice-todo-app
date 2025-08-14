import 'dart:io';
import 'package:get/get.dart';
import '../../domain/audio_entity.dart';
import '../../domain/i_audio_repository.dart';
import '../../domain/i_audio_recorder.dart';
import '../../domain/i_audio_player.dart';

/// Audio controller for managing audio recording, playback, and storage
class AudioController extends GetxController {
  final IAudioRepository _audioRepository;
  final IAudioRecorder _audioRecorder;
  final IAudioPlayer _audioPlayer;

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

  /// Playback position
  final Rx<Duration> playbackPosition = Duration.zero.obs;

  /// Playback duration
  final Rx<Duration> playbackDuration = Duration.zero.obs;

  /// Audio loading state
  final RxBool isLoading = false.obs;

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

  AudioController(this._audioRepository, this._audioRecorder, this._audioPlayer);

  @override
  void onInit() {
    super.onInit();
    loadAudioFiles();
    loadAudioStatistics();
  }

  @override
  void onClose() {
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

  /// Start audio recording
  Future<void> startRecording() async {
    try {
      if (isRecording.value) return;

      await _audioRecorder.startRecording();
      isRecording.value = true;
      recordingDuration.value = Duration.zero;
      _startRecordingTimer();
      Get.snackbar('Recording', 'Audio recording started');
    } catch (e) {
      Get.snackbar('Error', 'Failed to start recording: $e');
    }
  }

  /// Stop audio recording and save
  Future<void> stopRecording({String? taskId}) async {
    try {
      if (!isRecording.value) return;

      final audioPath = await _audioRecorder.stopRecording();
      isRecording.value = false;
      
      // Create audio entity
      final audioEntity = AudioEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: taskId ?? currentTaskId.value,
        fileName: 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
        localPath: audioPath,
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
          Get.snackbar('Success', 'Audio recording saved');
        },
        (failure) {
          Get.snackbar('Error', 'Failed to save recording: ${failure.message}');
        },
      );
    } catch (e) {
      isRecording.value = false;
      Get.snackbar('Error', 'Failed to stop recording: $e');
    }
  }

  /// Play audio file
  Future<void> playAudio(AudioEntity audio) async {
    try {
      if (isPlaying.value) {
        await stopPlayback();
      }

      await _audioPlayer.play(audio.localPath);
      isPlaying.value = true;
      isPaused.value = false;
      playingAudio.value = audio;
      selectedAudio.value = audio;
      _startPlaybackTimer();
      Get.snackbar('Playing', 'Audio playback started');
    } catch (e) {
      Get.snackbar('Error', 'Failed to play audio: $e');
    }
  }

  /// Pause audio playback
  Future<void> pausePlayback() async {
    try {
      if (!isPlaying.value) return;

      await _audioPlayer.pause();
      isPaused.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to pause audio: $e');
    }
  }

  /// Resume audio playback
  Future<void> resumePlayback() async {
    try {
      if (!isPaused.value) return;

      await _audioPlayer.resume();
      isPaused.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to resume audio: $e');
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
    } catch (e) {
      Get.snackbar('Error', 'Failed to stop audio: $e');
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
    // TODO: Implement recording timer
    // This would typically use a periodic timer to update recording duration
  }

  /// Start playback timer
  void _startPlaybackTimer() {
    // TODO: Implement playback timer
    // This would typically use a periodic timer to update playback position
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
}
