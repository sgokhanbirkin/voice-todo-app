import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../product/widgets/app_scaffold.dart';
import '../../../../product/responsive/responsive.dart';
import '../../../../product/theme/app_theme.dart';
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
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(context, l10n, taskController),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // TODO: Navigate to settings
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'logout') {
              await authController.signOut();
              if (context.mounted) {
                context.go('/');
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(Icons.logout),
                  SizedBox(width: 8.w),
                  Text(l10n.logout),
                ],
              ),
            ),
          ],
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
          icon: const Icon(Icons.search),
          label: Text(l10n.searchTasks),
          onPressed: () => _showSearchDialog(context, l10n, taskController),
        ),
        SizedBox(width: 8.w),
        TextButton.icon(
          icon: const Icon(Icons.settings),
          label: Text(l10n.settings),
          onPressed: () {
            // TODO: Navigate to settings
          },
        ),
        SizedBox(width: 8.w),
        TextButton.icon(
          icon: const Icon(Icons.logout),
          label: Text(l10n.logout),
          onPressed: () async {
            await authController.signOut();
            if (context.mounted) {
              context.go('/');
            }
          },
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
            color: Theme.of(context).colorScheme.surfaceVariant,
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
                onTap: () {},
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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, l10n, taskController),
          ),
          SizedBox(width: 8.w),
          ElevatedButton.icon(
            onPressed: () => _showAddTaskDialog(context, l10n, taskController),
            icon: const Icon(Icons.add),
            label: Text(l10n.addTask),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(
    BuildContext context,
    AppLocalizations l10n,
    TaskController taskController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.searchTasks),
        content: TextField(
          decoration: InputDecoration(
            hintText: l10n.searchTasks,
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (query) => taskController.setSearchQuery(query),
        ),
        actions: [
          TextButton(
            onPressed: () {
              taskController.setSearchQuery('');
              Navigator.pop(context);
            },
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
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
    return GetBuilder<TaskController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(
                  l10n.loading,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
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
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: AppColors.error,
                  ),
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

              // Task List
              Expanded(
                child: ResponsiveBuilder(
                  mobile: (context) => ListView.builder(
                    padding: Responsive.getResponsivePadding(context),
                    itemCount: controller.filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = controller.filteredTasks[index];
                      return _buildTaskCard(context, task, controller);
                    },
                  ),
                  tablet: (context) => GridView.builder(
                    padding: Responsive.getResponsivePadding(context),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: controller.filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = controller.filteredTasks[index];
                      return _buildTaskCard(context, task, controller);
                    },
                  ),
                  desktop: (context) => GridView.builder(
                    padding: Responsive.getResponsivePadding(context),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: controller.filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = controller.filteredTasks[index];
                      return _buildTaskCard(context, task, controller);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
        mobile: (context) => Column(
          children: [
            Row(
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
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  l10n.pending,
                  stats.pendingTasks.toString(),
                ),
                _buildStatItem(
                  context,
                  'Geciken',
                  stats.overdueTasks.toString(),
                ),
              ],
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
            _buildStatItem(
              context,
              l10n.pending,
              stats.pendingTasks.toString(),
            ),
            _buildStatItem(context, 'Geciken', stats.overdueTasks.toString()),
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

  Widget _buildTaskCard(
    BuildContext context,
    TaskEntity task,
    TaskController controller,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
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
                          Icon(task.isStarred ? Icons.star_border : Icons.star),
                          SizedBox(width: 8.w),
                          Text(task.isStarred ? 'Yıldızı Kaldır' : 'Yıldızla'),
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
