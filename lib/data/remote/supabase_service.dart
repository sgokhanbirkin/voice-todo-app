import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/logger.dart';

/// Supabase service for database and storage operations
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  late final SupabaseClient _client;

  /// Initialize Supabase client
  Future<void> initialize() async {
    try {
      final url = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (url == null || anonKey == null) {
        throw Exception('Supabase environment variables not found');
      }

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );

      _client = Supabase.instance.client;

      Logger.instance.info('Supabase initialized successfully');
    } catch (e) {
      Logger.instance.error('Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  /// Get Supabase client instance
  SupabaseClient get client => _client;

  /// Check if Supabase is initialized
  bool get isInitialized => true;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      Logger.instance.info(
        'User signed in successfully: ${response.user?.email}',
      );
      return response;
    } catch (e) {
      Logger.instance.error('Sign in failed: $e');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      Logger.instance.info(
        'User signed up successfully: ${response.user?.email}',
      );
      return response;
    } catch (e) {
      Logger.instance.error('Sign up failed: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      Logger.instance.info('User signed out successfully');
    } catch (e) {
      Logger.instance.error('Sign out failed: $e');
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      Logger.instance.info('Password reset email sent to: $email');
    } catch (e) {
      Logger.instance.error('Password reset failed: $e');
      rethrow;
    }
  }

  /// Get database table reference
  SupabaseQueryBuilder from(String table) {
    return _client.from(table);
  }

  /// Get storage bucket reference
  StorageFileApi bucket(String bucketName) {
    return _client.storage.from(bucketName);
  }

  /// Upload file to storage
  Future<String> uploadFile({
    required String bucketName,
    required String filePath,
    required File file,
    FileOptions? options,
  }) async {
    try {
      final response = await _client.storage
          .from(bucketName)
          .upload(filePath, file, fileOptions: options ?? const FileOptions());

      Logger.instance.info('File uploaded successfully: $filePath');
      return response;
    } catch (e) {
      Logger.instance.error('File upload failed: $e');
      rethrow;
    }
  }

  /// Download file from storage
  Future<Uint8List> downloadFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      final response = await _client.storage
          .from(bucketName)
          .download(filePath);

      Logger.instance.info('File downloaded successfully: $filePath');
      return response;
    } catch (e) {
      Logger.instance.error('File download failed: $e');
      rethrow;
    }
  }

  /// Get public URL for file
  String getPublicUrl({required String bucketName, required String filePath}) {
    return _client.storage.from(bucketName).getPublicUrl(filePath);
  }

  /// Delete file from storage
  Future<void> deleteFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      await _client.storage.from(bucketName).remove([filePath]);

      Logger.instance.info('File deleted successfully: $filePath');
    } catch (e) {
      Logger.instance.error('File deletion failed: $e');
      rethrow;
    }
  }

  /// Listen to real-time changes
  RealtimeChannel channel(String channelName) {
    return _client.channel(channelName);
  }

  /// Dispose resources
  void dispose() {
    // Cleanup if needed
    Logger.instance.info('Supabase service disposed');
  }
}
