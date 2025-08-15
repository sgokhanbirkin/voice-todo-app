part of 'app_scaffold.dart';

/// Animated drawer widget that can be used across the app
class AnimatedDrawer extends StatefulWidget {
  /// Whether the drawer is currently open
  final bool isOpen;

  /// Callback when drawer state changes
  final Function(bool) onDrawerStateChanged;

  /// Custom drawer content (optional)
  final Widget? customContent;

  /// Whether to show language and theme options
  final bool showSettings;

  const AnimatedDrawer({
    super.key,
    required this.isOpen,
    required this.onDrawerStateChanged,
    this.customContent,
    this.showSettings = true,
  });

  @override
  State<AnimatedDrawer> createState() => _AnimatedDrawerState();
}

class _AnimatedDrawerState extends State<AnimatedDrawer>
    with SingleTickerProviderStateMixin {
  late ZoomDrawerController _zoomDrawerController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _zoomDrawerController = ZoomDrawerController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.isOpen) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _animationController.forward();
        _zoomDrawerController.toggle?.call();
      } else {
        _animationController.reverse();
        _zoomDrawerController.close?.call();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: _zoomDrawerController,
      menuBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
      shadowLayer1Color: Theme.of(context).colorScheme.surface,
      shadowLayer2Color: Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.3),
      borderRadius: 20.0,
      showShadow: true,
      mainScreen: _buildMainScreen(context),
      menuScreen: _buildMenuScreen(context),
      drawerShadowsBackgroundColor: Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.1),
      slideWidth: MediaQuery.of(context).size.width * 0.8,
      angle: 0.0,
      mainScreenTapClose: true,
    );
  }

  Widget _buildMainScreen(BuildContext context) {
    // Bu ekran drawer açıkken gösterilir
    // Gerçek uygulama içeriği burada olmalı
    return Scaffold(
      drawerEnableOpenDragGesture: true,
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Drawer is Open',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Swipe right or tap menu button',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _zoomDrawerController.toggle?.call(),
                icon: const Icon(Icons.close),
                label: const Text('Close Drawer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              _buildDrawerHeader(context, l10n),

              SizedBox(height: 20.h),

              // User Profile Section
              _buildUserProfileSection(context),

              SizedBox(height: 20.h),

              // Menu Items
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Column(
                    children: [
                      _buildMenuTile(
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

                      _buildMenuTile(
                        context: context,
                        icon: Icons.analytics,
                        title: l10n.analytics,
                        subtitle: l10n.insights,
                        onTap: () {
                          _zoomDrawerController.toggle?.call();
                          context.go('/settings');
                        },
                      ),

                      if (widget.showSettings) ...[
                        SizedBox(height: 16.h),

                        _buildExpandableMenuSection(
                          context: context,
                          icon: Icons.language,
                          title: l10n.language,
                          subtitle: localeController.getLocaleDisplayName(
                            localeController.currentLocale,
                          ),
                          children: LocaleController.supportedLocales.map((
                            locale,
                          ) {
                            final isSelected =
                                locale.languageCode ==
                                localeController.currentLocale.languageCode;
                            return _buildLanguageOptionTile(
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

                        _buildExpandableMenuSection(
                          context: context,
                          icon: Icons.palette,
                          title: l10n.theme,
                          subtitle: _getThemeDisplayName(
                            l10n,
                            appTheme.currentThemeMode,
                          ),
                          children: [
                            _buildThemeOptionTile(
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
                            _buildThemeOptionTile(
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
                            _buildThemeOptionTile(
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
                      _buildLogoutButton(context, l10n, authController),
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

  Widget _buildDrawerHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.settings,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => _zoomDrawerController.toggle?.call(),
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 28.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfileSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 32.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kullanıcı',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Voice Todo App',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableMenuSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return _AppScaffoldExpandableMenuSection.build(
      context: context,
      icon: icon,
      title: title,
      subtitle: subtitle,
      isExpanded: false,
      onTap: () {},
      children: children,
    );
  }

  Widget _buildLanguageOptionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return _AppScaffoldLanguageOptionTile.build(
      context: context,
      title: title,
      subtitle: subtitle,
      isSelected: isSelected,
      onTap: onTap,
    );
  }

  Widget _buildThemeOptionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return _AppScaffoldThemeOptionTile.build(
      context: context,
      title: title,
      subtitle: subtitle,
      icon: icon,
      isSelected: isSelected,
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    AppLocalizations l10n,
    AuthController authController,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      child: ElevatedButton.icon(
        onPressed: () async {
          _zoomDrawerController.toggle?.call();
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
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

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

/// Expandable menu section component
class _ExpandableMenuSection extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _ExpandableMenuSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  State<_ExpandableMenuSection> createState() => _ExpandableMenuSectionState();
}

class _ExpandableMenuSectionState extends State<_ExpandableMenuSection> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      widget.icon,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isExpanded ? null : 0,
          child: isExpanded
              ? Container(
                  margin: EdgeInsets.only(top: 8.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(children: widget.children),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

