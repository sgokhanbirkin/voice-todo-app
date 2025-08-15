import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Audio Permission Controller - Android runtime izinlerini yönetir
class AudioPermissionController extends GetxController {
  final RxBool _hasMicrophonePermission = false.obs;
  final RxBool _hasStoragePermission = false.obs;
  final RxBool _hasNotificationPermission = false.obs;

  // Getters
  bool get hasMicrophonePermission => _hasMicrophonePermission.value;
  bool get hasStoragePermission => _hasStoragePermission.value;
  bool get hasNotificationPermission => _hasNotificationPermission.value;

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
  }

  /// Check all required permissions
  Future<void> _checkPermissions() async {
    await _checkMicrophonePermission();
    await _checkStoragePermission();
    await _checkNotificationPermission();
  }

  /// Check microphone permission
  Future<void> _checkMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      _hasMicrophonePermission.value = status.isGranted;
      debugPrint(
        'AudioPermissionController: Microphone permission status: $status',
      );
    } catch (e) {
      debugPrint('AudioPermissionController: Microphone permission error: $e');
      _hasMicrophonePermission.value = false;
    }
  }

  /// Check storage permission
  Future<void> _checkStoragePermission() async {
    try {
      // Android 13+ için storage permission gerekli değil, app kendi klasörüne yazabilir
      // Sadece mikrofon izni yeterli
      _hasStoragePermission.value = true;
      debugPrint(
        'AudioPermissionController: Storage permission granted (app directory)',
      );
    } catch (e) {
      debugPrint('AudioPermissionController: Storage permission error: $e');
      _hasStoragePermission.value = false;
    }
  }

  /// Check notification permission
  Future<void> _checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      _hasNotificationPermission.value = status.isGranted;
      debugPrint(
        'AudioPermissionController: Notification permission status: $status',
      );
    } catch (e) {
      debugPrint(
        'AudioPermissionController: Notification permission error: $e',
      );
      _hasNotificationPermission.value = false;
    }
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      debugPrint('AudioPermissionController: Requesting microphone permission');
      final status = await Permission.microphone.request();
      _hasMicrophonePermission.value = status.isGranted;

      if (status.isPermanentlyDenied) {
        showPermissionExplanation('Mikrofon');
      }

      return status.isGranted;
    } catch (e) {
      debugPrint(
        'AudioPermissionController: Failed to request microphone permission: $e',
      );
      _hasMicrophonePermission.value = false;
      return false;
    }
  }

  /// Request storage permission
  Future<bool> requestStoragePermission() async {
    try {
      debugPrint(
        'AudioPermissionController: Storage permission not required for app directory',
      );
      _hasStoragePermission.value = true;
      return true;
    } catch (e) {
      debugPrint(
        'AudioPermissionController: Failed to request storage permission: $e',
      );
      _hasStoragePermission.value = false;
      return false;
    }
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      debugPrint(
        'AudioPermissionController: Requesting notification permission',
      );
      final status = await Permission.notification.request();
      _hasNotificationPermission.value = status.isGranted;

      if (status.isPermanentlyDenied) {
        showPermissionExplanation('Bildirim');
      }

      return status.isGranted;
    } catch (e) {
      debugPrint(
        'AudioPermissionController: Failed to request notification permission: $e',
      );
      _hasNotificationPermission.value = false;
      return false;
    }
  }

  /// Check if all permissions are granted
  bool get allPermissionsGranted {
    return _hasMicrophonePermission.value &&
        _hasStoragePermission.value &&
        _hasNotificationPermission.value;
  }

  /// Request all permissions
  Future<bool> requestAllPermissions() async {
    try {
      final micResult = await requestMicrophonePermission();
      final storageResult = await requestStoragePermission();
      final notificationResult = await requestNotificationPermission();

      return micResult && storageResult && notificationResult;
    } catch (e) {
      debugPrint(
        'AudioPermissionController: Failed to request all permissions: $e',
      );
      return false;
    }
  }

  /// Open app settings
  Future<void> _openAppSettings() async {
    try {
      await openAppSettings();
      debugPrint('AudioPermissionController: App settings opened');
    } catch (e) {
      debugPrint('AudioPermissionController: Failed to open app settings: $e');
      // Fallback: Show error message
      Get.snackbar(
        'Hata',
        'Ayarlar açılamadı. Lütfen manuel olarak ayarlardan izin verin.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Show permission explanation dialog
  void showPermissionExplanation(String permissionName) {
    Get.dialog(
      AlertDialog(
        title: Text('$permissionName İzni Gerekli'),
        content: Text(
          'Bu özelliği kullanmak için $permissionName iznine ihtiyacımız var. '
          'Lütfen ayarlardan bu izni verin.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('İptal')),
          TextButton(
            onPressed: () async {
              Get.back();
              await _openAppSettings();
            },
            child: const Text('Ayarlar'),
          ),
        ],
      ),
    );
  }
}
