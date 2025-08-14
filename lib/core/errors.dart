/// Base application exception class
abstract class AppException implements Exception {
  /// Error message
  final String message;

  /// Error code (optional)
  final String? code;

  /// Stack trace (optional)
  final StackTrace? stackTrace;

  const AppException(this.message, {this.code, this.stackTrace});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Generic failure class for handling operation failures
abstract class Failure {
  /// Error message
  final String message;

  /// Error code (optional)
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Network failure class
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Database failure class
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

/// Audio operation failure class
class AudioFailure extends Failure {
  const AudioFailure(super.message, {super.code});
}

/// Authentication failure class
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

// TODO: Add more specific failure types as needed
// TODO: Implement error logging and reporting mechanisms
// TODO: Add error recovery strategies
