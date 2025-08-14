import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../product/widgets/app_scaffold.dart';
import '../../../../product/responsive/responsive.dart';
import '../../../../product/theme/app_theme.dart';
import '../../../../product/localization/locale_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/task_controller.dart';
import '../../domain/task_entity.dart';
import '../../domain/i_task_repository.dart';

/// Home page widget
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authController = Get.find<AuthController>();
    final taskController = Get.find<TaskController>();

    return ResponsiveBuilder(
      mobile: (context) =>
          _buildMobileLayout(context, l10n, authController, taskController),
      tablet: (context) =>
          _buildTabletLayout(context, l10n, authController, taskController),
      desktop: (context) =>
          _buildDesktopLayout(context, l10n, authController, taskController),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    AppLocalizations l10n,
    AuthController authController,
    TaskController taskController,
  ) {
    return AppScaffold(
      title: l10n.tasks,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => _showSettingsDialog(context, l10n, authController),
        ),
      ],
      body: _HomePageBody(l10n: l10n),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, l10n, taskController),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    AppLocalizations l10n,
    AuthController authController,
    TaskController taskController,
  ) {
    return AppScaffold(
      title: l10n.tasks,
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.settings),
          label: Text(l10n.settings),
          onPressed: () => _showSettingsDialog(context, l10n, authController),
        ),
      ],
      body: _HomePageBody(l10n: l10n),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context, l10n, taskController),
        icon: const Icon(Icons.add),
        label: Text(l10n.addTask),
      ),
    );
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
                onTap: () => _showSettingsDialog(context, l10n, authController),
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

  void _showSettingsDialog(
    BuildContext context,
    AppLocalizations l10n,
    AuthController authController,
  ) {
    final localeController = Get.find<LocaleController>();
    final appTheme = Get.find<AppTheme>();

    showDialog(
      context: context,
      builder: (context) => Obx(
        () => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.settings),
              SizedBox(width: 8.w),
              Text(l10n.settings),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(
                  localeController.getLocaleDisplayName(
                    localeController.currentLocale,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLanguageDialog(context, l10n);
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette),
                title: Text(l10n.theme),
                subtitle: Text(
                  _getThemeDisplayName(l10n, appTheme.currentThemeMode),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showThemeDialog(context, l10n);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(l10n.logout),
                onTap: () async {
                  Navigator.pop(context);
                  await authController.signOut();
                  if (context.mounted) {
                    context.go('/');
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
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

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    final localeController = Get.find<LocaleController>();
    final RxBool isChangingLanguage = false.obs;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Obx(
        () => AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
          title: Row(
            children: [
              Icon(
                Icons.language,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 12.w),
              Text(l10n.selectLanguage),
            ],
          ),
          content: isChangingLanguage.value
              ? Container(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Dil değiştiriliyor...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: LocaleController.supportedLocales.map((locale) {
                    return _buildLanguageOption(
                      context,
                      localeController.getLocaleDisplayName(locale),
                      locale,
                      localeController.currentLocale,
                      () => _changeLanguage(
                        localeController,
                        locale,
                        isChangingLanguage,
                        context,
                      ),
                    );
                  }).toList(),
                ),
          actions: isChangingLanguage.value
              ? []
              : [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String title,
    Locale value,
    Locale groupValue,
    VoidCallback onTap,
  ) {
    final isSelected = value.languageCode == groupValue.languageCode;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16.sp,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : null,
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
                              color: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _getLanguageNativeName(value.languageCode),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.7)
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.language,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20.sp,
                  ),
              ],
            ),
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

  Future<void> _changeLanguage(
    LocaleController localeController,
    Locale locale,
    RxBool isChangingLanguage,
    BuildContext context,
  ) async {
    isChangingLanguage.value = true;

    // Simulate language change delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    localeController.changeLocale(locale);

    // Wait a bit more to see the change
    await Future.delayed(const Duration(milliseconds: 200));

    isChangingLanguage.value = false;
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void _showThemeDialog(BuildContext context, AppLocalizations l10n) {
    final appTheme = Get.find<AppTheme>();
    final RxBool isChangingTheme = false.obs;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Obx(
        () => AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
          title: Row(
            children: [
              Icon(Icons.palette, color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 12.w),
              Text(l10n.selectTheme),
            ],
          ),
          content: isChangingTheme.value
              ? Container(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Tema uygulanıyor...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildThemeOption(
                      context,
                      l10n.lightTheme,
                      ThemeMode.light,
                      appTheme.currentThemeMode,
                      () => _changeTheme(
                        appTheme,
                        ThemeMode.light,
                        isChangingTheme,
                        context,
                      ),
                    ),
                    _buildThemeOption(
                      context,
                      l10n.darkTheme,
                      ThemeMode.dark,
                      appTheme.currentThemeMode,
                      () => _changeTheme(
                        appTheme,
                        ThemeMode.dark,
                        isChangingTheme,
                        context,
                      ),
                    ),
                    _buildThemeOption(
                      context,
                      l10n.systemTheme,
                      ThemeMode.system,
                      appTheme.currentThemeMode,
                      () => _changeTheme(
                        appTheme,
                        ThemeMode.system,
                        isChangingTheme,
                        context,
                      ),
                    ),
                  ],
                ),
          actions: isChangingTheme.value
              ? []
              : [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    ThemeMode value,
    ThemeMode groupValue,
    VoidCallback onTap,
  ) {
    final isSelected = value == groupValue;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16.sp,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : null,
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
                              color: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _getThemeDescription(value),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.7)
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _getThemeIcon(value),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.settings_system_daydream;
    }
  }

  String _getThemeDescription(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Açık renkli görünüm';
      case ThemeMode.dark:
        return 'Koyu renkli görünüm';
      case ThemeMode.system:
        return 'Sistem ayarını takip eder';
    }
  }

  Future<void> _changeTheme(
    AppTheme appTheme,
    ThemeMode themeMode,
    RxBool isChangingTheme,
    BuildContext context,
  ) async {
    isChangingTheme.value = true;

    // Simulate theme change delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    switch (themeMode) {
      case ThemeMode.light:
        appTheme.switchToLight();
        break;
      case ThemeMode.dark:
        appTheme.switchToDark();
        break;
      case ThemeMode.system:
        appTheme.switchToSystem();
        break;
    }

    // Wait a bit more to see the change
    await Future.delayed(const Duration(milliseconds: 200));

    isChangingTheme.value = false;
    if (context.mounted) {
      Navigator.pop(context);
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
          _buildSectionHeader(context, l10n.pending, pendingTasks.length),
          SizedBox(height: 12.h),
          ...pendingTasks.map(
            (task) => _buildTaskCard(context, task, controller),
          ),
          SizedBox(height: 24.h),
        ],

        // Completed Tasks Section
        if (completedTasks.isNotEmpty) ...[
          _buildSectionHeader(context, l10n.completed, completedTasks.length),
          SizedBox(height: 12.h),
          ...completedTasks.map(
            (task) => _buildTaskCard(context, task, controller),
          ),
        ],
      ],
    );
  }

  Widget _buildCategorizedTaskGrid(
    BuildContext context,
    TaskController controller,
    int crossAxisCount,
  ) {
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
            _buildSectionHeader(context, l10n.pending, pendingTasks.length),
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

          // Completed Tasks Section
          if (completedTasks.isNotEmpty) ...[
            _buildSectionHeader(context, l10n.completed, completedTasks.length),
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
      ),
    );
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
           print('🔥 Filter tapped: $priority');
           print('🔥 Current filter: ${controller.filterPriority.value}');
           print('🔥 Total tasks: ${controller.tasks.length}');
           
           if (controller.filterPriority.value == priority) {
             // Same priority clicked - clear filter
             print('🔥 Clearing filter');
             controller.setFilterPriority(null);
           } else {
             // Different priority clicked - set filter
             print('🔥 Setting filter to: $priority');
             controller.setFilterPriority(priority);
           }
           
           print('🔥 Filtered tasks after: ${controller.filteredTasks.length}');
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

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Container(
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
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
        ],
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
                            Icon(Icons.delete, color: AppColors.error),
                            SizedBox(width: 8.w),
                            Text(
                              l10n.delete,
                              style: TextStyle(color: AppColors.error),
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
                      label: Text('Gecikmiş'),
                      backgroundColor: AppColors.error.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: AppColors.error,
                        fontSize: 12.sp,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  if (task.isStarred)
                    Chip(
                      label: Text('Yıldızlı'),
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
