import 'errors.dart';

/// App result wrapper class for handling success and failure outcomes
///
/// This class provides a type-safe way to handle operations that can either
/// succeed with data or fail with an error.

/// Generic app result wrapper
sealed class AppResult<T> {
  /// Creates a success result with data
  const AppResult._();

  /// Success result with data
  const factory AppResult.success(T data) = AppSuccess<T>;

  /// Failure result with error
  const factory AppResult.failure(Failure error) = AppFailure<T>;

  /// Checks if the result is successful
  bool get isSuccess => this is AppSuccess<T>;

  /// Checks if the result is a failure
  bool get isFailure => this is AppFailure<T>;

  /// Gets the data if successful, null otherwise
  T? get dataOrNull => isSuccess ? (this as AppSuccess<T>).data : null;

  /// Gets the error if failed, null otherwise
  Failure? get errorOrNull => isFailure ? (this as AppFailure<T>).error : null;

  /// Maps the data if successful
  AppResult<R> map<R>(R Function(T) mapper) {
    if (isSuccess) {
      return AppResult.success(mapper((this as AppSuccess<T>).data));
    }
    return AppResult.failure((this as AppFailure<T>).error);
  }

  /// Handles success and failure cases
  R fold<R>(R Function(T) onSuccess, R Function(Failure) onFailure) {
    if (isSuccess) {
      return onSuccess((this as AppSuccess<T>).data);
    }
    return onFailure((this as AppFailure<T>).error);
  }
}

/// Success result implementation
class AppSuccess<T> extends AppResult<T> {
  final T data;

  const AppSuccess(this.data) : super._();

  @override
  String toString() => 'AppSuccess(data: $data)';
}

/// Failure result implementation
class AppFailure<T> extends AppResult<T> {
  final Failure error;

  const AppFailure(this.error) : super._();

  @override
  String toString() => 'AppFailure(error: $error)';
}

// TODO: Add more utility methods for result handling
// TODO: Implement async result handling
// TODO: Add result caching mechanisms
