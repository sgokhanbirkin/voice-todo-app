import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../localization/locale_controller.dart';
import '../theme/app_theme.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../l10n/app_localizations.dart';

// Part files for better code organization (SOLID principles)
part 'animated_drawer.dart';
part 'app_scaffold_drawer_widgets.dart';
part 'app_scaffold_expandable_menu.dart';

/// Common application scaffold with consistent styling
class AppScaffold extends StatefulWidget {
  /// App bar title
  final String title;

  /// App bar actions
  final List<Widget>? actions;

  /// Leading widget in app bar
  final Widget? leading;

  /// Body content
  final Widget body;

  /// Floating action button
  final Widget? floatingActionButton;

  /// Bottom navigation bar
  final Widget? bottomNavigationBar;

  /// Drawer
  final Widget? drawer;

  /// End drawer
  final Widget? endDrawer;

  /// Whether to automatically handle back button
  final bool automaticallyImplyLeading;

  /// Whether to show app bar
  final bool showAppBar;

  /// Whether to show drawer button
  final bool showDrawerButton;

  /// Whether to show back button
  final bool showBackButton;

  /// Whether to show home button
  final bool showHomeButton;

  /// Custom drawer content
  final Widget? customDrawerContent;

  /// Whether to use animated drawer
  final bool useAnimatedDrawer;

  /// Whether to show settings in drawer
  final bool showDrawerSettings;

  const AppScaffold({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.automaticallyImplyLeading = true,
    this.showAppBar = true,
    this.showDrawerButton = false,
    this.showBackButton = false,
    this.showHomeButton = false,
    this.customDrawerContent,
    this.useAnimatedDrawer = false,
    this.showDrawerSettings = true,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late ZoomDrawerController _zoomDrawerController;
  bool _isLanguageExpanded = false;
  bool _isThemeExpanded = false;

  @override
  void initState() {
    super.initState();
    _zoomDrawerController = ZoomDrawerController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useAnimatedDrawer && widget.showDrawerButton) {
      // ZoomDrawer kullan
      return ZoomDrawer(
        controller: _zoomDrawerController,
        menuBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
        shadowLayer1Color: Theme.of(context).colorScheme.surface,
        shadowLayer2Color: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.3),
        borderRadius: 20.0,
        showShadow: true,
        mainScreen: _buildMainScreenWithZoomDrawer(context),
        menuScreen: _buildMenuScreen(context),
        drawerShadowsBackgroundColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.1),
        slideWidth: MediaQuery.of(context).size.width * 0.8,
        angle: 0.0,
        mainScreenTapClose: true,
        menuScreenTapClose: true,
      );
    } else {
      // Normal Scaffold kullan
      return Scaffold(
        appBar: widget.showAppBar ? _buildAppBar(context) : null,
        body: widget.body,
        floatingActionButton: widget.floatingActionButton,
        bottomNavigationBar: widget.bottomNavigationBar,
        drawer:
            widget.drawer ??
            (widget.showDrawerButton ? _buildDefaultDrawer(context) : null),
        endDrawer: widget.endDrawer,
      );
    }
  }

  /// Builds the main screen for ZoomDrawer
  Widget _buildMainScreenWithZoomDrawer(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? _buildAppBar(context) : null,
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset:
          true, // Keyboard açıldığında ekranı yeniden boyutlandır
    );
  }

  /// Builds the menu screen for ZoomDrawer
  Widget _buildMenuScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authController = Get.find<AuthController>();
    final localeController = Get.find<LocaleController>();
    final appTheme = Get.find<AppTheme>();

    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _AppScaffoldDrawerHeader.build(
                context,
                l10n,
                _zoomDrawerController,
              ),

              SizedBox(height: 20.h),

              // User Profile Section
              _AppScaffoldUserProfileSection.build(context),

              SizedBox(height: 20.h),

              // Menu Items
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Column(
                    children: [
                      _AppScaffoldMenuTile.buildAnimated(
                        context: context,
                        icon: Icons.home,
                        title: l10n.home,
                        subtitle: l10n.home,
                        onTap: () {
                          _zoomDrawerController.toggle?.call();
                          context.go('/');
                        },
                      ),

                      SizedBox(height: 16.h),

                      _AppScaffoldMenuTile.buildAnimated(
                        context: context,
                        icon: Icons.analytics,
                        title: l10n.analytics,
                        subtitle: l10n.insights,
                        onTap: () {
                          _zoomDrawerController.toggle?.call();
                          context.go('/settings');
                        },
                      ),

                      if (widget.showDrawerSettings) ...[
                        SizedBox(height: 16.h),

                        _AppScaffoldExpandableMenuSection.build(
                          context: context,
                          icon: Icons.language,
                          title: l10n.language,
                          subtitle: localeController.getLocaleDisplayName(
                            localeController.currentLocale,
                          ),
                          isExpanded: _isLanguageExpanded,
                          onTap: () {
                            setState(() {
                              _isLanguageExpanded = !_isLanguageExpanded;
                            });
                          },
                          children: LocaleController.supportedLocales.map((
                            locale,
                          ) {
                            final isSelected =
                                locale.languageCode ==
                                localeController.currentLocale.languageCode;
                            return _AppScaffoldLanguageOptionTile.build(
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
                              },
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 16.h),

                        _AppScaffoldExpandableMenuSection.build(
                          context: context,
                          icon: Icons.palette,
                          title: l10n.theme,
                          subtitle: _getThemeDisplayName(
                            l10n,
                            appTheme.currentThemeMode,
                          ),
                          isExpanded: _isThemeExpanded,
                          onTap: () {
                            setState(() {
                              _isThemeExpanded = !_isThemeExpanded;
                            });
                          },
                          children: [
                            _AppScaffoldThemeOptionTile.build(
                              context: context,
                              title: l10n.lightTheme,
                              subtitle: l10n.lightTheme,
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
                              },
                            ),
                            _AppScaffoldThemeOptionTile.build(
                              context: context,
                              title: l10n.darkTheme,
                              subtitle: l10n.darkTheme,
                              icon: Icons.dark_mode,
                              isSelected:
                                  appTheme.currentThemeMode == ThemeMode.dark,
                              onTap: () async {
                                if (appTheme.currentThemeMode !=
                                    ThemeMode.dark) {
                                  appTheme.switchToDark();
                                  await Future.delayed(
                                    const Duration(milliseconds: 300),
                                  );
                                }
                              },
                            ),
                            _AppScaffoldThemeOptionTile.build(
                              context: context,
                              title: l10n.systemTheme,
                              subtitle: l10n.systemTheme,
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
                              },
                            ),
                          ],
                        ),
                      ],

                      SizedBox(height: 24.h),

                      // Logout Button
                      _AppScaffoldLogoutButton.build(
                        context,
                        l10n,
                        authController,
                        _zoomDrawerController,
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

  /// Builds the app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      leading: _buildLeadingWidget(context),
      actions: widget.actions,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    );
  }

  /// Builds the leading widget
  Widget? _buildLeadingWidget(BuildContext context) {
    if (widget.leading != null) return widget.leading;

    if (widget.showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      );
    }

    if (widget.showHomeButton) {
      return IconButton(
        icon: const Icon(Icons.home),
        onPressed: () => context.go('/'),
      );
    }

    if (widget.showDrawerButton) {
      return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          if (widget.useAnimatedDrawer) {
            _zoomDrawerController.toggle?.call();
          } else {
            Scaffold.of(context).openDrawer();
          }
        },
      );
    }

    return null;
  }

  /// Builds the default drawer
  Widget? _buildDefaultDrawer(BuildContext context) {
    if (widget.customDrawerContent != null) {
      return widget.customDrawerContent;
    }

    return _buildStandardDrawer(context);
  }

  /// Builds the standard drawer
  Widget _buildStandardDrawer(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authController = Get.find<AuthController>();
    final localeController = Get.find<LocaleController>();
    final appTheme = Get.find<AppTheme>();

    return Drawer(
      child: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.settings,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kullanıcı',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Voice Todo App',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.home,
                      title: l10n.home,
                      subtitle: l10n.home,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go('/');
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.analytics,
                      title: l10n.analytics,
                      subtitle: l10n.insights,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go('/settings');
                      },
                    ),
                    if (widget.showDrawerSettings) ...[
                      _buildDrawerItem(
                        context,
                        icon: Icons.language,
                        title: l10n.language,
                        subtitle: localeController.getLocaleDisplayName(
                          localeController.currentLocale,
                        ),
                        onTap: () =>
                            _showLanguageOptions(context, localeController),
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.palette,
                        title: l10n.theme,
                        subtitle: _getThemeDisplayName(
                          l10n,
                          appTheme.currentThemeMode,
                        ),
                        onTap: () => _showThemeOptions(context, l10n, appTheme),
                      ),
                    ],
                  ],
                ),
              ),

              // Logout button
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await authController.signOut();
                      if (context.mounted) {
                        context.go('/');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(l10n.logout),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a drawer item
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  /// Shows language options
  void _showLanguageOptions(
    BuildContext context,
    LocaleController localeController,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Language',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ...LocaleController.supportedLocales.map((locale) {
              final isSelected =
                  locale.languageCode ==
                  localeController.currentLocale.languageCode;
              return ListTile(
                title: Text(localeController.getLocaleDisplayName(locale)),
                subtitle: Text(_getLanguageNativeName(locale.languageCode)),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  localeController.changeLocale(locale);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Shows theme options
  void _showThemeOptions(
    BuildContext context,
    AppLocalizations l10n,
    AppTheme appTheme,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Theme', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: Text(l10n.lightTheme),
              onTap: () {
                Navigator.pop(context);
                appTheme.switchToLight();
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: Text(l10n.darkTheme),
              onTap: () {
                Navigator.pop(context);
                appTheme.switchToDark();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_system_daydream),
              title: Text(l10n.systemTheme),
              onTap: () {
                Navigator.pop(context);
                appTheme.switchToSystem();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Gets theme display name
  String _getThemeDisplayName(AppLocalizations l10n, ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
      case ThemeMode.system:
        return l10n.systemTheme;
    }
  }

  /// Gets language native name
  String _getLanguageNativeName(String languageCode) {
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

/// Scaffold with loading state
class LoadingScaffold extends StatelessWidget {
  /// App bar title
  final String title;

  /// Loading message
  final String? loadingMessage;

  const LoadingScaffold({super.key, required this.title, this.loadingMessage});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (loadingMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                loadingMessage!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Scaffold with error state
class ErrorScaffold extends StatelessWidget {
  /// App bar title
  final String title;

  /// Error message
  final String errorMessage;

  /// Retry callback
  final VoidCallback? onRetry;

  const ErrorScaffold({
    super.key,
    required this.title,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// TODO: Create custom app bar with search functionality (Part 5 - UI & Navigation)
