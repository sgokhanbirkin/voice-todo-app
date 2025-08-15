import 'package:flutter/material.dart';

import 'package:get/get.dart';

/// Controller for managing app localization
class LocaleController extends GetxController {
  static LocaleController? _instance;
  static LocaleController get instance => _instance ??= LocaleController._();

  LocaleController._();

  /// Current locale
  final Rx<Locale> _currentLocale = const Locale('en').obs;
  Locale get currentLocale => _currentLocale.value;

  /// Available locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('tr', 'TR'),
  ];

  @override
  void onInit() {
    super.onInit();
    // Initialize with system locale if supported, otherwise default to English
    // Use WidgetsBinding.instance.addPostFrameCallback to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final systemLocale = Get.deviceLocale;
      if (systemLocale != null &&
          supportedLocales.any(
            (locale) => locale.languageCode == systemLocale.languageCode,
          )) {
        _currentLocale.value = Locale(systemLocale.languageCode);
      }
    });
  }

  /// Change app locale
  void changeLocale(Locale locale) {
    _currentLocale.value = locale;
    Get.updateLocale(locale);
  }

  /// Change to English
  void changeToEnglish() => changeLocale(const Locale('en', 'US'));

  /// Change to Turkish
  void changeToTurkish() => changeLocale(const Locale('tr', 'TR'));

  /// Get locale display name
  String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'tr':
        return 'Türkçe';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Check if locale is currently selected
  bool isLocaleSelected(Locale locale) {
    return _currentLocale.value.languageCode == locale.languageCode;
  }
}
