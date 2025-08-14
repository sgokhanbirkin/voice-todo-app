/// Core validation utilities for form inputs
class Validators {
  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validates password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }
    
    return null;
  }

  /// Validates password confirmation
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Password confirmation is required';
    }
    
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validates task title
  static String? taskTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Task title is required';
    }
    
    if (value.trim().isEmpty) {
      return 'Task title cannot be empty';
    }
    
    if (value.length < 2) {
      return 'Task title must be at least 2 characters';
    }
    
    if (value.length > 200) {
      return 'Task title must be less than 200 characters';
    }
    
    return null;
  }

  /// Validates task description
  static String? taskDescription(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Description is optional
    }
    
    if (value.length > 1000) {
      return 'Task description must be less than 1000 characters';
    }
    
    return null;
  }

  /// Validates required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Field'} is required';
    }
    
    if (value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} cannot be empty';
    }
    
    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Let required validator handle empty values
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? 'Field'} must be at least $minLength characters';
    }
    
    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (value.length > maxLength) {
      return '${fieldName ?? 'Field'} must be less than $maxLength characters';
    }
    
    return null;
  }

  /// Validates numeric input
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final numericValue = double.tryParse(value);
    if (numericValue == null) {
      return '${fieldName ?? 'Field'} must be a valid number';
    }
    
    return null;
  }

  /// Validates integer input
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final intValue = int.tryParse(value);
    if (intValue == null) {
      return '${fieldName ?? 'Field'} must be a valid integer';
    }
    
    return null;
  }

  /// Validates phone number format
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    
    if (digitsOnly.length > 15) {
      return 'Phone number must be less than 15 digits';
    }
    
    return null;
  }

  /// Validates URL format
  static String? url(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return '${fieldName ?? 'URL'} must be a valid URL';
    }
    
    return null;
  }

  /// Validates date format
  static String? date(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final dateValue = DateTime.tryParse(value);
    if (dateValue == null) {
      return '${fieldName ?? 'Date'} must be a valid date';
    }
    
    return null;
  }

  /// Validates future date
  static String? futureDate(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final dateValue = DateTime.tryParse(value);
    if (dateValue == null) {
      return '${fieldName ?? 'Date'} must be a valid date';
    }
    
    if (dateValue.isBefore(DateTime.now())) {
      return '${fieldName ?? 'Date'} must be in the future';
    }
    
    return null;
  }

  /// Validates past date
  static String? pastDate(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final dateValue = DateTime.tryParse(value);
    if (dateValue == null) {
      return '${fieldName ?? 'Date'} must be a valid date';
    }
    
    if (dateValue.isAfter(DateTime.now())) {
      return '${fieldName ?? 'Date'} must be in the past';
    }
    
    return null;
  }

  /// Combines multiple validators
  static String? combine(List<String? Function(String?)> validators, String? value) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// Validates file extension
  static String? fileExtension(String? filePath, List<String> allowedExtensions) {
    if (filePath == null || filePath.isEmpty) {
      return null;
    }
    
    final extension = filePath.split('.').last.toLowerCase();
    
    if (!allowedExtensions.contains(extension)) {
      return 'File must be one of: ${allowedExtensions.join(', ')}';
    }
    
    return null;
  }

  /// Validates file size
  static String? fileSize(int? sizeInBytes, int maxSizeInBytes) {
    if (sizeInBytes == null) {
      return null;
    }
    
    if (sizeInBytes > maxSizeInBytes) {
      final maxSizeMB = (maxSizeInBytes / (1024 * 1024)).toStringAsFixed(1);
      return 'File size must be less than ${maxSizeMB}MB';
    }
    
    return null;
  }
}
