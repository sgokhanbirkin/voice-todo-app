import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Application theme manager
class AppTheme {
  static AppTheme? _instance;
  static AppTheme get instance => _instance ??= AppTheme._();

  AppTheme._();

  /// Current theme mode
  final Rx<ThemeMode> _currentThemeMode = ThemeMode.system.obs;
  ThemeMode get currentThemeMode => _currentThemeMode.value;

  /// Stream of theme mode changes
  Stream<ThemeMode> get themeModeStream => _currentThemeMode.stream;

  /// Switch to light theme
  void switchToLight() => _currentThemeMode.value = ThemeMode.light;

  /// Switch to dark theme
  void switchToDark() => _currentThemeMode.value = ThemeMode.dark;

  /// Switch to system theme
  void switchToSystem() => _currentThemeMode.value = ThemeMode.system;

  /// Toggle between light and dark themes
  void toggleTheme() {
    if (_currentThemeMode.value == ThemeMode.light) {
      switchToDark();
    } else {
      switchToLight();
    }
  }

  /// Custom color palette
  static const AppColors colors = AppColors();

  /// Light theme configuration
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      cardTheme: _cardTheme,
      inputDecorationTheme: _inputDecorationTheme,
    );
  }

  /// Dark theme configuration
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      cardTheme: _cardTheme,
      inputDecorationTheme: _inputDecorationTheme,
    );
  }

  /// Light color scheme
  ColorScheme get _lightColorScheme {
    return const ColorScheme.light(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF03DAC6),
      surface: Color(0xFFFFFFFF),
      error: Color(0xFFB00020),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFF000000),
      onSurface: Color(0xFF000000),
      onError: Color(0xFFFFFFFF),
    );
  }

  /// Dark color scheme
  ColorScheme get _darkColorScheme {
    return const ColorScheme.dark(
      primary: Color(0xFF90CAF9),
      secondary: Color(0xFF80DEEA),
      surface: Color(0xFF121212),
      error: Color(0xFFCF6679),
      onPrimary: Color(0xFF000000),
      onSecondary: Color(0xFF000000),
      onSurface: Color(0xFFFFFFFF),
      onError: Color(0xFF000000),
    );
  }

  /// Text theme
  TextTheme get _textTheme {
    return const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    );
  }

  /// App bar theme
  AppBarTheme get _appBarTheme {
    return const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );
  }

  /// Elevated button theme
  ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Card theme
  CardThemeData get _cardTheme {
    return const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  /// Input decoration theme
  InputDecorationTheme get _inputDecorationTheme {
    return const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  /// Page transitions for theme switching
  PageTransitionsTheme get _pageTransitionsTheme {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      },
    );
  }

  /// Animation duration constants
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  /// Animation curve constants
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve fastCurve = Curves.fastOutSlowIn;
  static const Curve slowCurve = Curves.easeInOutCubic;
}

/// Custom color palette for the application
class AppColors {
  const AppColors();

  // Primary colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color primaryRed = Color(0xFFF44336);
  static const Color primaryPurple = Color(0xFF9C27B0);

  // Secondary colors
  static const Color secondaryTeal = Color(0xFF03DAC6);
  static const Color secondaryAmber = Color(0xFFFFC107);
  static const Color secondaryPink = Color(0xFFE91E63);
  static const Color secondaryIndigo = Color(0xFF3F51B5);

  // Neutral colors
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralBlack = Color(0xFF000000);
  static const Color neutralGrey = Color(0xFF9E9E9E);
  static const Color neutralLightGrey = Color(0xFFF5F5F5);
  static const Color neutralDarkGrey = Color(0xFF424242);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Task priority colors
  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityHigh = Color(0xFFF44336);

  // Task status colors
  static const Color statusPending = Color(0xFF9E9E9E);
  static const Color statusInProgress = Color(0xFF2196F3);
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFF44336);

  // Audio colors
  static const Color audioRecording = Color(0xFFE91E63);
  static const Color audioPlaying = Color(0xFF4CAF50);
  static const Color audioPaused = Color(0xFFFF9800);
  static const Color audioStopped = Color(0xFF9E9E9E);
}
