import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../product/responsive/responsive.dart';
import '../../../../product/theme/app_theme.dart';
import '../../../../product/localization/locale_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/task_controller.dart';
import '../../domain/task_entity.dart';
import '../../domain/i_task_repository.dart';

/// Home page widget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ZoomDrawerController _zoomDrawerController = ZoomDrawerController();
  bool _isLanguageExpanded = false;
  bool _isThemeExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authController = Get.find<AuthController>();
    final taskController = Get.find<TaskController>();

    return ResponsiveBuilder(
      mobile: (context) =>
          _buildZoomDrawer(context, l10n, authController, taskController),
      tablet: (context) =>
          _buildZoomDrawer(context, l10n, authController, taskController),
      desktop: (context) =>
          _buildDesktopLayout(context, l10n, authController, taskController),
    );
  }

  Widget _buildZoomDrawer(
    BuildContext context,
    AppLocalizations l10n,
    AuthController authController,
    TaskController taskController,
  ) {
    return ZoomDrawer(
      controller: _zoomDrawerController,
      menuBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
      shadowLayer1Color: Theme.of(context).colorScheme.surface,
      shadowLayer2Color: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.2),
      borderRadius: 24.r,
      showShadow: true,
      angle: -12.0,
      slideWidth: MediaQuery.of(context).size.width * 0.8,
      openCurve: Curves.fastOutSlowIn,
      closeCurve: Curves.bounceIn,
      mainScreen: _buildMainScreen(context, l10n, taskController),
      menuScreen: _buildAnimatedMenuScreen(context, l10n, authController),
    );
  }

  Widget _buildMainScreen(
    BuildContext context,
    AppLocalizations l10n,
    TaskController taskController,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tasks),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _zoomDrawerController.toggle?.call(),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _HomePageBody(l10n: l10n),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, l10n, taskController),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnimatedMenuScreen(
    BuildContext context,
    AppLocalizations l10n,
    AuthController authController,
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
              // Close Button
              Row(
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
              ),

              SizedBox(height: 32.h),

              // User Profile Section
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
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
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Voice Todo App',
                            style: Theme.of(context).textTheme.bodyMedium
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
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Menu Items - Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: 16.h,
                  ), // Bottom padding for scroll
                  child: Column(
                    children: [
                      _buildAnimatedMenuTile(
                        context: context,
                        icon: Icons.home,
                        title: l10n.home,
                        subtitle: 'Ana sayfa',
                        onTap: () {
                          _zoomDrawerController.toggle?.call();
                        },
                      ),

                      SizedBox(height: 16.h),

                      _buildExpandableMenuSection(
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
                            if (_isLanguageExpanded) _isThemeExpanded = false;
                          });
                        },
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
                              setState(() {
                                _isLanguageExpanded = false;
                              });
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
                        isExpanded: _isThemeExpanded,
                        onTap: () {
                          setState(() {
                            _isThemeExpanded = !_isThemeExpanded;
                            if (_isThemeExpanded) _isLanguageExpanded = false;
                          });
                        },
                        children: [
                          _buildThemeOptionTile(
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
                              setState(() {
                                _isThemeExpanded = false;
                              });
                            },
                          ),
                          _buildThemeOptionTile(
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
                              setState(() {
                                _isThemeExpanded = false;
                              });
                            },
                          ),
                          _buildThemeOptionTile(
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
                              setState(() {
                                _isThemeExpanded = false;
                              });
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h), // Extra space before logout
                      // Logout Button
                      Container(
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
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onError,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
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

  Widget _buildExpandableMenuSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
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
                          subtitle,
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
                    turns: isExpanded ? 0.25 : 0.0, // 90° döndürme
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
                  child: Column(children: children),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildAnimatedMenuTile({
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

  Widget _buildLanguageOptionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          margin: EdgeInsets.only(bottom: 4.h),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: isSelected
                ? Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.3),
                    width: 2,
                  ),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 12.sp,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          margin: EdgeInsets.only(bottom: 4.h),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: isSelected
                ? Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.3),
                    width: 2,
                  ),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 12.sp,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2)
                      : Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  size: 16.sp,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLanguageNativeName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English (US)';
      case 'tr':
        return 'Türkiye Türkçesi';
      default:
        return languageCode.toUpperCase();
    }
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    AppLocalizations l10n,
    AuthController authController,
    TaskController taskController,
  ) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280.w,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: _buildSidebar(context, l10n, authController, taskController),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(context, l10n, taskController),
                // Content
                Expanded(child: _HomePageBody(l10n: l10n)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for responsive layouts
  Widget _buildSidebar(
    BuildContext context,
    AppLocalizations l10n,
    AuthController authController,
    TaskController taskController,
  ) {
    return Column(
      children: [
        Container(
          height: 80.h,
          padding: EdgeInsets.all(16.w),
          child: Text(
            l10n.appTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: Text(l10n.home),
                selected: true,
              ),
              ListTile(
                leading: const Icon(Icons.task_alt),
                title: Text(l10n.tasks),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(l10n.settings),
                onTap: () {
                  // Desktop için basit dialog gösterebiliriz
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16.w),
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.logout),
            onTap: () async {
              await authController.signOut();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    AppLocalizations l10n,
    TaskController taskController,
  ) {
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(l10n.tasks, style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),

          ElevatedButton.icon(
            onPressed: () => _showAddTaskDialog(context, l10n, taskController),
            icon: const Icon(Icons.add),
            label: Text(l10n.addTask),
          ),
        ],
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

  /// Shows add task dialog
  void _showAddTaskDialog(
    BuildContext context,
    AppLocalizations l10n,
    TaskController controller,
  ) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    TaskPriority selectedPriority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.addTask),
          content: SizedBox(
            width: Responsive.isDesktop(context) ? 400.w : double.maxFinite,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: l10n.taskTitle,
                      border: const OutlineInputBorder(),
                    ),
                    validator: controller.validateTaskTitle,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.taskDescription,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: controller.validateTaskDescription,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<TaskPriority>(
                    value: selectedPriority,
                    decoration: InputDecoration(
                      labelText: l10n.taskPriority,
                      border: const OutlineInputBorder(),
                    ),
                    items: TaskPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(_getPriorityName(l10n, priority)),
                      );
                    }).toList(),
                    onChanged: (priority) {
                      if (priority != null) {
                        setState(() {
                          selectedPriority = priority;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final task = TaskEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  priority: selectedPriority,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await controller.createTask(task);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  String _getPriorityName(AppLocalizations l10n, TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return l10n.taskPriorityLow;
      case TaskPriority.medium:
        return l10n.taskPriorityMedium;
      case TaskPriority.high:
        return l10n.taskPriorityHigh;
    }
  }
}

/// Home page body content
class _HomePageBody extends StatelessWidget {
  final AppLocalizations l10n;

  const _HomePageBody({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<TaskController>();

      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16.h),
              Text(l10n.loading, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        );
      }

      if (controller.hasError.value) {
        return Center(
          child: Padding(
            padding: Responsive.getResponsivePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
                SizedBox(height: 16.h),
                Text(
                  l10n.error,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: AppColors.error),
                ),
                SizedBox(height: 8.h),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => controller.loadTasks(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.tasks.isEmpty) {
        return Center(
          child: Padding(
            padding: Responsive.getResponsivePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_alt,
                  size: 80.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.5),
                ),
                SizedBox(height: 24.h),
                Text(
                  l10n.noTasks,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.noTasksDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refresh(),
        child: Column(
          children: [
            // Task Statistics Summary
            if (controller.taskStatistics.value != null)
              _buildTaskSummary(context, controller.taskStatistics.value!),

            // Categorized Task List
            Expanded(
              child: ResponsiveBuilder(
                mobile: (context) =>
                    _buildCategorizedTaskList(context, controller),
                tablet: (context) =>
                    _buildCategorizedTaskGrid(context, controller, 2),
                desktop: (context) =>
                    _buildCategorizedTaskGrid(context, controller, 3),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTaskSummary(BuildContext context, TaskStatistics stats) {
    return Container(
      margin: Responsive.getResponsiveMargin(context),
      padding: Responsive.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ResponsiveBuilder(
        mobile: (context) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, 'Toplam', stats.totalTasks.toString()),
            _buildStatItem(
              context,
              l10n.completed,
              stats.completedTasks.toString(),
            ),
          ],
        ),
        tablet: (context) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, 'Toplam', stats.totalTasks.toString()),
            _buildStatItem(
              context,
              l10n.completed,
              stats.completedTasks.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 18.sp,
              tablet: 20.sp,
              desktop: 22.sp,
            ),
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 12.sp,
              tablet: 14.sp,
              desktop: 16.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorizedTaskList(
    BuildContext context,
    TaskController controller,
  ) {
    return Obx(() {
      final pendingTasks = controller.filteredTasks
          .where((task) => task.status != TaskStatus.completed)
          .toList();
      final completedTasks = controller.filteredTasks
          .where((task) => task.status == TaskStatus.completed)
          .toList();

      return ListView(
        padding: Responsive.getResponsivePadding(context),
        children: [
          // Priority Filter Cards (at the top)
          if (controller.tasks.isNotEmpty) ...[
            _buildPriorityFilterCards(context, controller),
            SizedBox(height: 24.h),
          ],

          // Pending Tasks Section
          if (pendingTasks.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              l10n.pending,
              pendingTasks.length,
              controller.isPendingExpanded.value,
              controller.togglePendingExpansion,
            ),
            if (controller.isPendingExpanded.value) ...[
              SizedBox(height: 12.h),
              ...pendingTasks.map(
                (task) => _buildTaskCard(context, task, controller),
              ),
              SizedBox(height: 24.h),
            ],
          ],

          // Completed Tasks Section
          if (completedTasks.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              l10n.completed,
              completedTasks.length,
              controller.isCompletedExpanded.value,
              controller.toggleCompletedExpansion,
            ),
            if (controller.isCompletedExpanded.value) ...[
              SizedBox(height: 12.h),
              ...completedTasks.map(
                (task) => _buildTaskCard(context, task, controller),
              ),
            ],
          ],
        ],
      );
    });
  }

  Widget _buildCategorizedTaskGrid(
    BuildContext context,
    TaskController controller,
    int crossAxisCount,
  ) {
    return Obx(() {
      final pendingTasks = controller.filteredTasks
          .where((task) => task.status != TaskStatus.completed)
          .toList();
      final completedTasks = controller.filteredTasks
          .where((task) => task.status == TaskStatus.completed)
          .toList();

      return SingleChildScrollView(
        padding: Responsive.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority Filter Cards (at the top)
            if (controller.tasks.isNotEmpty) ...[
              _buildPriorityFilterCards(context, controller),
              SizedBox(height: 24.h),
            ],

            // Pending Tasks Section
            if (pendingTasks.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                l10n.pending,
                pendingTasks.length,
                controller.isPendingExpanded.value,
                controller.togglePendingExpansion,
              ),
              if (controller.isPendingExpanded.value) ...[
                SizedBox(height: 12.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: crossAxisCount == 2 ? 2.5 : 2.2,
                  ),
                  itemCount: pendingTasks.length,
                  itemBuilder: (context, index) {
                    final task = pendingTasks[index];
                    return _buildTaskCard(context, task, controller);
                  },
                ),
                SizedBox(height: 32.h),
              ],
            ],

            // Completed Tasks Section
            if (completedTasks.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                l10n.completed,
                completedTasks.length,
                controller.isCompletedExpanded.value,
                controller.toggleCompletedExpansion,
              ),
              if (controller.isCompletedExpanded.value) ...[
                SizedBox(height: 12.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: crossAxisCount == 2 ? 2.5 : 2.2,
                  ),
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    final task = completedTasks[index];
                    return _buildTaskCard(context, task, controller);
                  },
                ),
              ],
            ],
          ],
        ),
      );
    });
  }

  Widget _buildPriorityFilterCards(
    BuildContext context,
    TaskController controller,
  ) {
    return SizedBox(
      height: 40.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        children: [
          _buildPriorityFilterCard(
            context,
            controller,
            TaskPriority.high,
            l10n.taskPriorityHigh,
            AppColors.priorityHigh,
          ),
          SizedBox(width: 8.w),
          _buildPriorityFilterCard(
            context,
            controller,
            TaskPriority.medium,
            l10n.taskPriorityMedium,
            AppColors.priorityMedium,
          ),
          SizedBox(width: 8.w),
          _buildPriorityFilterCard(
            context,
            controller,
            TaskPriority.low,
            l10n.taskPriorityLow,
            AppColors.priorityLow,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityFilterCard(
    BuildContext context,
    TaskController controller,
    TaskPriority priority,
    String label,
    Color color,
  ) {
    return Obx(() {
      final isSelected = controller.filterPriority.value == priority;

      return GestureDetector(
        onTap: () {
          print('🎯 Priority filter card tapped: $priority');
          if (controller.filterPriority.value == priority) {
            // Same priority clicked - clear filter
            print('🎯 Clearing filter (same priority)');
            controller.setFilterPriority(null);
          } else {
            // Different priority clicked - set filter
            print('🎯 Setting filter to: $priority');
            controller.setFilterPriority(priority);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected
                  ? color
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? color
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int count,
    bool isExpanded,
    VoidCallback onToggle,
  ) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
        child: Row(
          children: [
            Container(
              width: 4.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            AnimatedRotation(
              turns: isExpanded ? 0.0 : -0.25, // 0° açık, -90° kapalı
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                size: 24.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    TaskEntity task,
    TaskController controller,
  ) {
    final isCompleted = task.status == TaskStatus.completed;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      color: isCompleted
          ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5)
          : null,
      child: Opacity(
        opacity: isCompleted ? 0.7 : 1.0,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task header with checkbox and menu
              Row(
                children: [
                  Checkbox(
                    value: task.status == TaskStatus.completed,
                    onChanged: (value) async {
                      if (value == true) {
                        await controller.completeTask(task.id);
                      } else {
                        await controller.uncompleteTask(task.id);
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                        fontSize: Responsive.getResponsiveFontSize(
                          context,
                          mobile: 16.sp,
                          tablet: 18.sp,
                          desktop: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'star':
                          if (task.isStarred) {
                            await controller.unstarTask(task.id);
                          } else {
                            await controller.starTask(task.id);
                          }
                          break;
                        case 'delete':
                          await controller.deleteTask(task.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'star',
                        child: Row(
                          children: [
                            Icon(
                              task.isStarred ? Icons.star_border : Icons.star,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              task.isStarred ? 'Yıldızı Kaldır' : 'Yıldızla',
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, color: AppColors.error),
                            SizedBox(width: 8.w),
                            Text(
                              l10n.delete,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Task description
              if (task.description != null) ...[
                SizedBox(height: 8.h),
                Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: Responsive.getResponsiveFontSize(
                      context,
                      mobile: 14.sp,
                      tablet: 15.sp,
                      desktop: 16.sp,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              SizedBox(height: 12.h),

              // Task chips
              Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: [
                  _buildPriorityChip(context, task.priority),
                  _buildStatusChip(context, task.status),
                  if (task.isOverdue)
                    Chip(
                      label: const Text('Gecikmiş'),
                      backgroundColor: AppColors.error.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: AppColors.error,
                        fontSize: 12.sp,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  if (task.isStarred)
                    Chip(
                      label: const Text('Yıldızlı'),
                      backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12.sp,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context, TaskPriority priority) {
    Color color;
    String label;

    switch (priority) {
      case TaskPriority.low:
        color = AppColors.priorityLow;
        label = l10n.taskPriorityLow;
        break;
      case TaskPriority.medium:
        color = AppColors.priorityMedium;
        label = l10n.taskPriorityMedium;
        break;
      case TaskPriority.high:
        color = AppColors.priorityHigh;
        label = l10n.taskPriorityHigh;
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: color,
        fontSize: Responsive.getResponsiveFontSize(
          context,
          mobile: 12.sp,
          tablet: 13.sp,
          desktop: 14.sp,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildStatusChip(BuildContext context, TaskStatus status) {
    Color color;
    String label;

    switch (status) {
      case TaskStatus.pending:
        color = AppColors.statusPending;
        label = l10n.taskPending;
        break;
      case TaskStatus.inProgress:
        color = AppColors.statusInProgress;
        label = 'Devam Ediyor'; // TODO: Add to localization
        break;
      case TaskStatus.completed:
        color = AppColors.statusCompleted;
        label = l10n.taskCompleted;
        break;
      case TaskStatus.cancelled:
        color = AppColors.statusCancelled;
        label = 'İptal Edildi'; // TODO: Add to localization
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: color,
        fontSize: Responsive.getResponsiveFontSize(
          context,
          mobile: 12.sp,
          tablet: 13.sp,
          desktop: 14.sp,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
