import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/result.dart';
import '../../../../core/errors.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/logger.dart';
import '../../../../data/remote/supabase_service.dart';

/// Authentication controller
class AuthController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Whether the user is currently authenticated
  final RxBool isAuthenticated = false.obs;

  /// Current user ID
  final RxString userId = ''.obs;

  /// Current user email
  final RxString userEmail = ''.obs;

  /// Whether authentication is currently loading
  final RxBool isLoading = false.obs;

  /// Authentication error message
  final RxString errorMessage = ''.obs;

  /// Current user session
  final Rx<Session?> currentSession = Rx<Session?>(null);

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  /// Validates email format
  String? validateEmail(String? email) {
    return Validators.email(email);
  }

  /// Validates password strength
  String? validatePassword(String? password) {
    return Validators.password(password);
  }

  /// Validates password confirmation
  String? validateConfirmPassword(String? password, String? confirmPassword) {
    return Validators.confirmPassword(confirmPassword, password);
  }

  /// Checks the current authentication state
  Future<void> _checkAuthState() async {
    try {
      // Check if user is already authenticated in Supabase
      final currentUser = _supabaseService.currentUser;
      if (currentUser != null) {
        // User is authenticated, update local state
        isAuthenticated.value = true;
        userId.value = currentUser.id;
        userEmail.value = currentUser.email ?? '';

        // Try to get current session
        try {
          final session = _supabaseService.client.auth.currentSession;
          if (session != null) {
            currentSession.value = session;
            Logger.instance.info(
              'Existing session found for user: ${currentUser.email}',
            );
          }
        } catch (e) {
          Logger.instance.warning('Failed to get current session: $e');
        }

        Logger.instance.info(
          'User already authenticated: ${currentUser.email}',
        );
      } else {
        // Check local storage for saved session
        await _loadSessionFromLocal();
      }
    } catch (e) {
      Logger.instance.error('Failed to check auth state: $e');
      // Clear any invalid state
      await _clearLocalSession();
    }
  }

  /// Signs in a user with email and password
  Future<AppResult<User>> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        // Update local state
        isAuthenticated.value = true;
        userId.value = response.user!.id;
        userEmail.value = response.user!.email ?? '';
        currentSession.value = response.session;

        // Save session to local storage
        await _saveSessionToLocal(response.session!);

        Logger.instance.info(
          'User signed in successfully: ${response.user!.email}',
        );
        return AppResult.success(response.user!);
      } else {
        errorMessage.value = 'Authentication failed: Invalid response';
        return const AppResult.failure(
          AuthFailure('Authentication failed: Invalid response'),
        );
      }
    } catch (e) {
      final errorMsg = 'Authentication failed: $e';
      errorMessage.value = errorMsg;
      Logger.instance.error(errorMsg);
      return AppResult.failure(AuthFailure(errorMsg));
    } finally {
      isLoading.value = false;
    }
  }

  /// Signs in a user with email and password (legacy method)
  Future<bool> signIn(String email, String password) async {
    final result = await signInWithEmail(email, password);
    return result.isSuccess;
  }

  /// Saves session to local storage
  Future<void> _saveSessionToLocal(Session session) async {
    try {
      final box = await Hive.openBox('auth_session');
      await box.put('session_data', {
        'access_token': session.accessToken,
        'refresh_token': session.refreshToken,
        'user_id': session.user.id,
        'user_email': session.user.email,
        'expires_at': session.expiresAt != null
            ? DateTime.fromMillisecondsSinceEpoch(
                session.expiresAt!,
              ).toIso8601String()
            : null,
        'created_at': DateTime.now().toIso8601String(),
      });
      Logger.instance.info('Session saved to local storage');
    } catch (e) {
      Logger.instance.error('Failed to save session to local storage: $e');
    }
  }

  /// Loads session from local storage
  Future<void> _loadSessionFromLocal() async {
    try {
      final box = await Hive.openBox('auth_session');
      final sessionData = box.get('session_data');

      if (sessionData != null) {
        // Check if session is still valid
        final expiresAt = DateTime.tryParse(sessionData['expires_at'] ?? '');
        if (expiresAt != null && expiresAt.isAfter(DateTime.now())) {
          // Session is still valid, restore it
          isAuthenticated.value = true;
          userId.value = sessionData['user_id'] ?? '';
          userEmail.value = sessionData['user_email'] ?? '';
          Logger.instance.info('Session restored from local storage');
        } else {
          // Session expired, clear it
          await _clearLocalSession();
          Logger.instance.info('Expired session cleared from local storage');
        }
      }
    } catch (e) {
      Logger.instance.error('Failed to load session from local storage: $e');
      await _clearLocalSession();
    }
  }

  /// Clears local session storage
  Future<void> _clearLocalSession() async {
    try {
      final box = await Hive.openBox('auth_session');
      await box.clear();
      Logger.instance.info('Local session storage cleared');
    } catch (e) {
      Logger.instance.error('Failed to clear local session storage: $e');
    }
  }

  /// Registers a new user
  Future<bool> register(
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate input
      if (email.isEmpty || password.isEmpty) {
        errorMessage.value = 'Please fill in all fields';
        return false;
      }

      if (password != confirmPassword) {
        errorMessage.value = 'Passwords do not match';
        return false;
      }

      if (password.length < 6) {
        errorMessage.value = 'Password must be at least 6 characters';
        return false;
      }

      // Create user account using Supabase
      try {
        final response = await _supabaseService.signUpWithEmail(
          email: email,
          password: password,
        );

        if (response.user != null) {
          // Registration successful
          isAuthenticated.value = true;
          userId.value = response.user!.id;
          userEmail.value = response.user!.email ?? '';

          if (response.session != null) {
            currentSession.value = response.session;
            await _saveSessionToLocal(response.session!);
          }

          Logger.instance.info(
            'User registered successfully: ${response.user!.email}',
          );
          return true;
        } else {
          errorMessage.value = 'Registration failed: Invalid response';
          return false;
        }
      } catch (e) {
        errorMessage.value = 'Registration failed: $e';
        Logger.instance.error('Registration error: $e');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Registration failed: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Resets user password
  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate email
      if (email.isEmpty) {
        errorMessage.value = 'Please enter a valid email';
        return false;
      }

      // Send password reset email using Supabase
      try {
        await _supabaseService.resetPassword(email);
        Logger.instance.info('Password reset email sent to: $email');
        return true;
      } catch (e) {
        errorMessage.value = 'Password reset failed: $e';
        Logger.instance.error('Password reset error: $e');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Password reset failed: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Changes user password
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate input
      if (currentPassword.isEmpty || newPassword.isEmpty) {
        errorMessage.value = 'Please fill in all fields';
        return false;
      }

      if (newPassword.length < 6) {
        errorMessage.value = 'New password must be at least 6 characters';
        return false;
      }

      // Verify current password and update to new password
      try {
        // First, verify current password by attempting to sign in
        final verifyResult = await _supabaseService.signInWithEmail(
          email: userEmail.value,
          password: currentPassword,
        );

        if (verifyResult.user == null) {
          errorMessage.value = 'Current password is incorrect';
          return false;
        }

        // Update password using Supabase
        await _supabaseService.client.auth.updateUser(
          UserAttributes(password: newPassword),
        );

        Logger.instance.info('Password changed successfully');
        return true;
      } catch (e) {
        errorMessage.value = 'Password change failed: $e';
        Logger.instance.error('Password change error: $e');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Password change failed: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates user profile information
  Future<bool> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Update user profile using Supabase
      try {
        final attributes = <String, dynamic>{};

        if (displayName != null) {
          attributes['display_name'] = displayName;
        }

        if (photoUrl != null) {
          attributes['photo_url'] = photoUrl;
        }

        if (attributes.isNotEmpty) {
          await _supabaseService.client.auth.updateUser(
            UserAttributes(data: attributes),
          );
        }

        Logger.instance.info('Profile updated successfully');
        return true;
      } catch (e) {
        errorMessage.value = 'Profile update failed: $e';
        Logger.instance.error('Profile update error: $e');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Profile update failed: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clears any error messages
  void clearError() {
    errorMessage.value = '';
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Sign out from Supabase
      await _supabaseService.signOut();

      // Clear local state
      isAuthenticated.value = false;
      userId.value = '';
      userEmail.value = '';
      currentSession.value = null;

      // Clear local storage (Hive)
      await _clearLocalSession();

      Logger.instance.info('User signed out successfully');
    } catch (e) {
      final errorMsg = 'Sign out failed: $e';
      errorMessage.value = errorMsg;
      Logger.instance.error(errorMsg);
    } finally {
      isLoading.value = false;
    }
  }

  /// Refreshes authentication state
  Future<void> refreshAuth() async {
    await _checkAuthState();
  }
}

// Advanced Features - Future Implementation
// TODO: Implement biometric authentication (fingerprint/face ID)
// TODO: Add social login support (Google, Apple, Facebook)
// TODO: Implement advanced token management and refresh
// TODO: Add multi-factor authentication (MFA)
// TODO: Implement session timeout and auto-logout
// TODO: Add device management and security logs

// Note: These features require additional packages and platform-specific implementations
// They will be implemented in future versions as separate feature modules
