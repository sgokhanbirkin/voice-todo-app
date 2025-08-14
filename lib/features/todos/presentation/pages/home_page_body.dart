part of 'home_page.dart';

/// Home page body content with task list implementation
/// Uses responsive design and localization from product layer
class _HomePageBody extends StatelessWidget {
  final AppLocalizations l10n;

  const _HomePageBody({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<TaskController>();

      if (controller.isLoading.value) {
        return _buildLoadingState(context);
      }

      if (controller.hasError.value) {
        return _buildErrorState(context, controller);
      }

      if (controller.tasks.isEmpty) {
        return _buildEmptyState(context);
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

  /// Build loading state
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(
            height: Responsive.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
          ),
          Text(l10n.loading, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(BuildContext context, TaskController controller) {
    return Center(
      child: Padding(
        padding: Responsive.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: Responsive.getResponsiveSpacing(
                context,
                mobile: 64,
                tablet: 80,
                desktop: 96,
              ),
              color: AppColors.error,
            ),
            SizedBox(
              height: Responsive.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            Text(
              l10n.error,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.error),
            ),
            SizedBox(
              height: Responsive.getResponsiveSpacing(
                context,
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
            ),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(
              height: Responsive.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            ElevatedButton(
              onPressed: () => controller.loadTasks(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: Responsive.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: Responsive.getResponsiveSpacing(
                context,
                mobile: 80,
                tablet: 100,
                desktop: 120,
              ),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            SizedBox(
              height: Responsive.getResponsiveSpacing(
                context,
                mobile: 24,
                tablet: 32,
                desktop: 40,
              ),
            ),
            Text(
              l10n.noTasks,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(
              height: Responsive.getResponsiveSpacing(
                context,
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
            ),
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

  /// Build task statistics summary
  Widget _buildTaskSummary(BuildContext context, TaskStatistics stats) {
    return Container(
      margin: Responsive.getResponsiveMargin(context),
      padding: Responsive.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ResponsiveBuilder(
        mobile: (context) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, l10n.tasks, stats.totalTasks.toString()),
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
            _buildStatItem(context, l10n.tasks, stats.totalTasks.toString()),
            _buildStatItem(
              context,
              l10n.pending,
              stats.pendingTasks.toString(),
            ),
            _buildStatItem(
              context,
              l10n.completed,
              stats.completedTasks.toString(),
            ),
          ],
        ),
        desktop: (context) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, l10n.tasks, stats.totalTasks.toString()),
            _buildStatItem(
              context,
              l10n.pending,
              stats.pendingTasks.toString(),
            ),
            _buildStatItem(
              context,
              l10n.completed,
              stats.completedTasks.toString(),
            ),
            _buildStatItem(context, 'Overdue', stats.overdueTasks.toString()),
          ],
        ),
      ),
    );
  }

  /// Build individual stat item
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
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 12,
              tablet: 14,
              desktop: 16,
            ),
          ),
        ),
      ],
    );
  }

  /// Build categorized task list for mobile
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
          // Priority Filter Cards
          if (controller.tasks.isNotEmpty) ...[
            _TaskPriorityFilters(l10n: l10n, controller: controller),
            SizedBox(
              height: Responsive.getResponsiveSpacing(
                context,
                mobile: 24,
                tablet: 32,
                desktop: 40,
              ),
            ),
          ],

          // Pending Tasks Section
          if (pendingTasks.isNotEmpty) ...[
            _TaskSectionHeader(
              title: l10n.pending,
              count: pendingTasks.length,
              isExpanded: controller.isPendingExpanded.value,
              onToggle: controller.togglePendingExpansion,
            ),
            if (controller.isPendingExpanded.value) ...[
              SizedBox(
                height: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 12,
                  tablet: 16,
                  desktop: 20,
                ),
              ),
              ...pendingTasks.map(
                (task) =>
                    _TaskCard(task: task, l10n: l10n, controller: controller),
              ),
              SizedBox(
                height: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 24,
                  tablet: 32,
                  desktop: 40,
                ),
              ),
            ],
          ],

          // Completed Tasks Section
          if (completedTasks.isNotEmpty) ...[
            _TaskSectionHeader(
              title: l10n.completed,
              count: completedTasks.length,
              isExpanded: controller.isCompletedExpanded.value,
              onToggle: controller.toggleCompletedExpansion,
            ),
            if (controller.isCompletedExpanded.value) ...[
              SizedBox(
                height: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 12,
                  tablet: 16,
                  desktop: 20,
                ),
              ),
              ...completedTasks.map(
                (task) =>
                    _TaskCard(task: task, l10n: l10n, controller: controller),
              ),
            ],
          ],
        ],
      );
    });
  }

  /// Build categorized task grid for tablet and desktop
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
            // Priority Filter Cards
            if (controller.tasks.isNotEmpty) ...[
              _TaskPriorityFilters(l10n: l10n, controller: controller),
              SizedBox(
                height: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 24,
                  tablet: 32,
                  desktop: 40,
                ),
              ),
            ],

            // Pending Tasks Section
            if (pendingTasks.isNotEmpty) ...[
              _TaskSectionHeader(
                title: l10n.pending,
                count: pendingTasks.length,
                isExpanded: controller.isPendingExpanded.value,
                onToggle: controller.togglePendingExpansion,
              ),
              if (controller.isPendingExpanded.value) ...[
                SizedBox(
                  height: Responsive.getResponsiveSpacing(
                    context,
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: Responsive.getResponsiveSpacing(
                      context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                    mainAxisSpacing: Responsive.getResponsiveSpacing(
                      context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                    childAspectRatio: crossAxisCount == 2 ? 2.5 : 2.2,
                  ),
                  itemCount: pendingTasks.length,
                  itemBuilder: (context, index) {
                    final task = pendingTasks[index];
                    return _TaskCard(
                      task: task,
                      l10n: l10n,
                      controller: controller,
                    );
                  },
                ),
                SizedBox(
                  height: Responsive.getResponsiveSpacing(
                    context,
                    mobile: 32,
                    tablet: 40,
                    desktop: 48,
                  ),
                ),
              ],
            ],

            // Completed Tasks Section
            if (completedTasks.isNotEmpty) ...[
              _TaskSectionHeader(
                title: l10n.completed,
                count: completedTasks.length,
                isExpanded: controller.isCompletedExpanded.value,
                onToggle: controller.toggleCompletedExpansion,
              ),
              if (controller.isCompletedExpanded.value) ...[
                SizedBox(
                  height: Responsive.getResponsiveSpacing(
                    context,
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: Responsive.getResponsiveSpacing(
                      context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                    mainAxisSpacing: Responsive.getResponsiveSpacing(
                      context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                    childAspectRatio: crossAxisCount == 2 ? 2.5 : 2.2,
                  ),
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    final task = completedTasks[index];
                    return _TaskCard(
                      task: task,
                      l10n: l10n,
                      controller: controller,
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      );
    });
  }
}
