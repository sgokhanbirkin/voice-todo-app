part of 'home_page.dart';

/// Main content widget for home page body with task lists
class _HomePageBodyContent extends StatefulWidget {
  final AppLocalizations l10n;
  final TaskController controller;

  const _HomePageBodyContent({
    required this.l10n,
    required this.controller,
  });

  @override
  State<_HomePageBodyContent> createState() => _HomePageBodyContentState();
}

class _HomePageBodyContentState extends State<_HomePageBodyContent> {
  bool _isPendingExpanded = true;
  bool _isCompletedExpanded = false;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => widget.controller.refresh(),
      child: Column(
        children: [
          // Task Statistics Card
          _HomePageBodyStatistics(l10n: widget.l10n, controller: widget.controller),

          ResponsiveWidgets.verticalSpace(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),

          // Priority Filters
          _TaskPriorityFilters(l10n: widget.l10n, controller: widget.controller),

          ResponsiveWidgets.verticalSpace(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),

          // Task Lists
          Expanded(child: _buildTaskLists(context)),
        ],
      ),
    );
  }

  Widget _buildTaskLists(BuildContext context) {
    return Obx(() {
      final filteredTasks = widget.controller.filteredTasks;
      final pendingTasks = filteredTasks.where((task) => task.status != TaskStatus.completed).toList();
      final completedTasks = filteredTasks.where((task) => task.status == TaskStatus.completed).toList();

      return ResponsiveBuilder(
        mobile: (context) => _buildMobileTaskList(context, pendingTasks, completedTasks),
        tablet: (context) => _buildTabletTaskList(context, pendingTasks, completedTasks),
        desktop: (context) => _buildDesktopTaskList(context, pendingTasks, completedTasks),
      );
    });
  }

  Widget _buildMobileTaskList(
    BuildContext context,
    List<TaskEntity> pendingTasks,
    List<TaskEntity> completedTasks,
  ) {
    return SingleChildScrollView(
      padding: ResponsiveWidgets.responsivePadding(context),
      child: Column(
        children: [
          // Pending Tasks Section
          if (pendingTasks.isNotEmpty) ...[
            _TaskSectionHeader(
              title: widget.l10n.pending,
              count: pendingTasks.length,
              isExpanded: _isPendingExpanded,
              onToggle: () => setState(() => _isPendingExpanded = !_isPendingExpanded),
            ),
            if (_isPendingExpanded) ...[
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              ...pendingTasks.map((task) => _TaskCard(
                task: task,
                l10n: widget.l10n,
                controller: widget.controller,
              )),
            ],
            ResponsiveWidgets.verticalSpace(context, mobile: 24, tablet: 32, desktop: 40),
          ],

          // Completed Tasks Section
          if (completedTasks.isNotEmpty) ...[
            _TaskSectionHeader(
              title: widget.l10n.completed,
              count: completedTasks.length,
              isExpanded: _isCompletedExpanded,
              onToggle: () => setState(() => _isCompletedExpanded = !_isCompletedExpanded),
            ),
            if (_isCompletedExpanded) ...[
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              ...completedTasks.map((task) => _TaskCard(
                task: task,
                l10n: widget.l10n,
                controller: widget.controller,
              )),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTabletTaskList(
    BuildContext context,
    List<TaskEntity> pendingTasks,
    List<TaskEntity> completedTasks,
  ) {
    return SingleChildScrollView(
      padding: ResponsiveWidgets.responsivePadding(context),
      child: Column(
        children: [
          // Pending Tasks Section
          if (pendingTasks.isNotEmpty) ...[
            _TaskSectionHeader(
              title: widget.l10n.pending,
              count: pendingTasks.length,
              isExpanded: _isPendingExpanded,
              onToggle: () => setState(() => _isPendingExpanded = !_isPendingExpanded),
            ),
            if (_isPendingExpanded) ...[
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: pendingTasks.length,
                itemBuilder: (context, index) => _TaskCard(
                  task: pendingTasks[index],
                  l10n: widget.l10n,
                  controller: widget.controller,
                ),
              ),
            ],
            ResponsiveWidgets.verticalSpace(context, mobile: 24, tablet: 32, desktop: 40),
          ],

          // Completed Tasks Section
          if (completedTasks.isNotEmpty) ...[
            _TaskSectionHeader(
              title: widget.l10n.completed,
              count: completedTasks.length,
              isExpanded: _isCompletedExpanded,
              onToggle: () => setState(() => _isCompletedExpanded = !_isCompletedExpanded),
            ),
            if (_isCompletedExpanded) ...[
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: completedTasks.length,
                itemBuilder: (context, index) => _TaskCard(
                  task: completedTasks[index],
                  l10n: widget.l10n,
                  controller: widget.controller,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopTaskList(
    BuildContext context,
    List<TaskEntity> pendingTasks,
    List<TaskEntity> completedTasks,
  ) {
    return SingleChildScrollView(
      padding: ResponsiveWidgets.responsivePadding(context),
      child: Column(
        children: [
          // Pending Tasks Section
          if (pendingTasks.isNotEmpty) ...[
            _TaskSectionHeader(
              title: widget.l10n.pending,
              count: pendingTasks.length,
              isExpanded: _isPendingExpanded,
              onToggle: () => setState(() => _isPendingExpanded = !_isPendingExpanded),
            ),
            if (_isPendingExpanded) ...[
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: pendingTasks.length,
                itemBuilder: (context, index) => _TaskCard(
                  task: pendingTasks[index],
                  l10n: widget.l10n,
                  controller: widget.controller,
                ),
              ),
            ],
            ResponsiveWidgets.verticalSpace(context, mobile: 24, tablet: 32, desktop: 40),
          ],

          // Completed Tasks Section
          if (completedTasks.isNotEmpty) ...[
            _TaskSectionHeader(
              title: widget.l10n.completed,
              count: completedTasks.length,
              isExpanded: _isCompletedExpanded,
              onToggle: () => setState(() => _isCompletedExpanded = !_isCompletedExpanded),
            ),
            if (_isCompletedExpanded) ...[
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: completedTasks.length,
                itemBuilder: (context, index) => _TaskCard(
                  task: completedTasks[index],
                  l10n: widget.l10n,
                  controller: widget.controller,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
