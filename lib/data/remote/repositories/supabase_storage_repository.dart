import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../../../core/result.dart';
import '../../../core/errors.dart';

/// Supabase storage repository for audio files
class SupabaseStorageRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _audioBucket = 'audio-files';

  /// Upload audio file to Supabase Storage
  Future<AppResult<String>> uploadAudioFile(String localFilePath) async {
    try {
      debugPrint(
        'SupabaseStorageRepository: Uploading audio file: $localFilePath',
      );

      // Check if file exists
      final file = File(localFilePath);
      if (!await file.exists()) {
        return const AppResult.failure(DatabaseFailure('Audio file not found'));
      }

      // Generate unique filename
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(localFilePath)}';
      final filePath = 'tasks/$fileName';

      debugPrint('SupabaseStorageRepository: Generated file path: $filePath');

      // Upload file to Supabase Storage
      final response = await _supabase.storage
          .from(_audioBucket)
          .upload(filePath, file);

      debugPrint('SupabaseStorageRepository: Upload response: $response');

      // Get public URL
      final publicUrl = _supabase.storage
          .from(_audioBucket)
          .getPublicUrl(filePath);

      debugPrint('SupabaseStorageRepository: Public URL: $publicUrl');

      return AppResult.success(publicUrl);
    } catch (e) {
      debugPrint('SupabaseStorageRepository: Error uploading audio: $e');
      return AppResult.failure(DatabaseFailure('Failed to upload audio: $e'));
    }
  }

  /// Download audio file from Supabase Storage
  Future<AppResult<String>> downloadAudioFile(
    String storagePath,
    String localPath,
  ) async {
    try {
      debugPrint('SupabaseStorageRepository: Downloading audio: $storagePath');

      final response = await _supabase.storage
          .from(_audioBucket)
          .download(storagePath);

      // Save to local file
      final file = File(localPath);
      await file.writeAsBytes(response);

      debugPrint('SupabaseStorageRepository: Downloaded to: $localPath');
      return AppResult.success(localPath);
    } catch (e) {
      debugPrint('SupabaseStorageRepository: Error downloading audio: $e');
      return AppResult.failure(DatabaseFailure('Failed to download audio: $e'));
    }
  }

  /// Delete audio file from Supabase Storage
  Future<AppResult<void>> deleteAudioFile(String storagePath) async {
    try {
      debugPrint('SupabaseStorageRepository: Deleting audio: $storagePath');

      await _supabase.storage.from(_audioBucket).remove([storagePath]);

      debugPrint('SupabaseStorageRepository: Successfully deleted audio');
      return const AppResult.success(null);
    } catch (e) {
      debugPrint('SupabaseStorageRepository: Error deleting audio: $e');
      return AppResult.failure(DatabaseFailure('Failed to delete audio: $e'));
    }
  }

  /// Get audio file URL
  String getAudioFileUrl(String storagePath) {
    return _supabase.storage.from(_audioBucket).getPublicUrl(storagePath);
  }

  /// Check if audio bucket exists, create if not
  Future<void> ensureAudioBucketExists() async {
    try {
      debugPrint('SupabaseStorageRepository: Checking audio bucket...');

      final buckets = await _supabase.storage.listBuckets();
      final audioBucketExists = buckets.any(
        (bucket) => bucket.name == _audioBucket,
      );

      if (!audioBucketExists) {
        debugPrint('SupabaseStorageRepository: Creating audio bucket...');
        await _supabase.storage.createBucket(_audioBucket);
        debugPrint('SupabaseStorageRepository: Audio bucket created');
      } else {
        debugPrint('SupabaseStorageRepository: Audio bucket already exists');
      }
    } catch (e) {
      debugPrint('SupabaseStorageRepository: Error ensuring bucket: $e');
    }
  }
}
