part of 'home_page.dart';

/// Drawer components and menu widgets for HomePage
/// This class coordinates the drawer layout and delegates UI components to specialized classes
class _HomePageDrawer {
  /// Build the animated menu screen for ZoomDrawer
  static Widget buildAnimatedMenuScreen(
    BuildContext context,
    AppLocalizations l10n,
    AuthController authController,
    ZoomDrawerController zoomDrawerController,
    bool isLanguageExpanded,
    bool isThemeExpanded,
    Function(bool) setLanguageExpanded,
    Function(bool) setThemeExpanded,
  ) {
    final localeController = Get.find<LocaleController>();
    final appTheme = Get.find<AppTheme>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close Button and Header
              _DrawerHeader.build(context, l10n, zoomDrawerController),

              SizedBox(height: 20.h),

              // User Profile Section
              _UserProfileSection.build(context),

              SizedBox(height: 20.h),

              // Menu Items - Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: 16.h,
                  ), // Bottom padding for scroll
                  child: Column(
                    children: [
                      _MenuTile.buildAnimated(
                        context: context,
                        icon: Icons.home,
                        title: l10n.home,
                        subtitle: 'Ana sayfa',
                        onTap: () {
                          zoomDrawerController.toggle?.call();
                        },
                      ),

                      SizedBox(height: 16.h),

                      _ExpandableMenuSection.build(
                        context: context,
                        icon: Icons.language,
                        title: l10n.language,
                        subtitle: localeController.getLocaleDisplayName(
                          localeController.currentLocale,
                        ),
                        isExpanded: isLanguageExpanded,
                        onTap: () {
                          setLanguageExpanded(!isLanguageExpanded);
                          if (!isLanguageExpanded) setThemeExpanded(false);
                        },
                        children: LocaleController.supportedLocales.map((
                          locale,
                        ) {
                          final isSelected =
                              locale.languageCode ==
                              localeController.currentLocale.languageCode;
                          return _LanguageOptionTile.build(
                            context: context,
                            title: localeController.getLocaleDisplayName(
                              locale,
                            ),
                            subtitle: _getLanguageNativeName(
                              locale.languageCode,
                            ),
                            isSelected: isSelected,
                            onTap: () async {
                              if (!isSelected) {
                                localeController.changeLocale(locale);
                                await Future.delayed(
                                  const Duration(milliseconds: 300),
                                );
                              }
                              setLanguageExpanded(false);
                            },
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 16.h),

                      _ExpandableMenuSection.build(
                        context: context,
                        icon: Icons.palette,
                        title: l10n.theme,
                        subtitle: _getThemeDisplayName(
                          l10n,
                          appTheme.currentThemeMode,
                        ),
                        isExpanded: isThemeExpanded,
                        onTap: () {
                          setThemeExpanded(!isThemeExpanded);
                          if (!isThemeExpanded) setLanguageExpanded(false);
                        },
                        children: [
                          _ThemeOptionTile.build(
                            context: context,
                            title: l10n.lightTheme,
                            subtitle: 'Açık renkli görünüm',
                            icon: Icons.light_mode,
                            isSelected:
                                appTheme.currentThemeMode == ThemeMode.light,
                            onTap: () async {
                              if (appTheme.currentThemeMode !=
                                  ThemeMode.light) {
                                appTheme.switchToLight();
                                await Future.delayed(
                                  const Duration(milliseconds: 300),
                                );
                              }
                              setThemeExpanded(false);
                            },
                          ),
                          _ThemeOptionTile.build(
                            context: context,
                            title: l10n.darkTheme,
                            subtitle: 'Koyu renkli görünüm',
                            icon: Icons.dark_mode,
                            isSelected:
                                appTheme.currentThemeMode == ThemeMode.dark,
                            onTap: () async {
                              if (appTheme.currentThemeMode != ThemeMode.dark) {
                                appTheme.switchToDark();
                                await Future.delayed(
                                  const Duration(milliseconds: 300),
                                );
                              }
                              setThemeExpanded(false);
                            },
                          ),
                          _ThemeOptionTile.build(
                            context: context,
                            title: l10n.systemTheme,
                            subtitle: 'Sistem ayarını takip eder',
                            icon: Icons.settings_system_daydream,
                            isSelected:
                                appTheme.currentThemeMode == ThemeMode.system,
                            onTap: () async {
                              if (appTheme.currentThemeMode !=
                                  ThemeMode.system) {
                                appTheme.switchToSystem();
                                await Future.delayed(
                                  const Duration(milliseconds: 300),
                                );
                              }
                              setThemeExpanded(false);
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h), // Extra space before logout
                      // Logout Button
                      _LogoutButton.build(
                        context,
                        l10n,
                        authController,
                        zoomDrawerController,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get theme display name
  static String _getThemeDisplayName(
    AppLocalizations l10n,
    ThemeMode themeMode,
  ) {
    switch (themeMode) {
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
      case ThemeMode.system:
        return l10n.systemTheme;
    }
  }

  /// Get language native name
  static String _getLanguageNativeName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English (US)';
      case 'tr':
        return 'Türkçe';
      default:
        return languageCode.toUpperCase();
    }
  }
}
