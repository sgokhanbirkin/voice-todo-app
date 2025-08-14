part of 'settings_page.dart';

/// Overview statistics cards section
class _OverviewSection extends StatelessWidget {
  final AppLocalizations l10n;
  final TaskController controller;

  const _OverviewSection({required this.l10n, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveWidgets.responsiveText(
          context,
          text: l10n.statistics,
          mobileFontSize: 20,
          tabletFontSize: 22,
          desktopFontSize: 24,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        ResponsiveWidgets.verticalSpace(context, mobile: 16, tablet: 20, desktop: 24),
        
        Obx(() {
          final stats = controller.taskStatistics.value;
          if (stats == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildOverviewCard(
                    context,
                    l10n.tasks,
                    stats.totalTasks.toString(),
                    Icons.task_alt,
                    AppColors.primaryBlue,
                  )),
                  ResponsiveWidgets.horizontalSpace(context, mobile: 12, tablet: 16, desktop: 20),
                  Expanded(child: _buildOverviewCard(
                    context,
                    l10n.completed,
                    stats.completedTasks.toString(),
                    Icons.check_circle,
                    AppColors.success,
                  )),
                ],
              ),
              
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              
              Row(
                children: [
                  Expanded(child: _buildOverviewCard(
                    context,
                    l10n.pending,
                    stats.pendingTasks.toString(),
                    Icons.pending_actions,
                    AppColors.warning,
                  )),
                  ResponsiveWidgets.horizontalSpace(context, mobile: 12, tablet: 16, desktop: 20),
                  Expanded(child: _buildOverviewCard(
                    context,
                    l10n.overdue,
                    stats.overdueTasks.toString(),
                    Icons.schedule,
                    AppColors.error,
                  )),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return ResponsiveWidgets.responsiveContainer(
      context,
      color: color.withValues(alpha: 0.1),
      child: Column(
        children: [
          Row(
            children: [
              ResponsiveWidgets.responsiveIcon(
                context,
                icon: icon,
                color: color,
                mobileSize: 24,
                tabletSize: 28,
                desktopSize: 32,
              ),
              ResponsiveWidgets.horizontalSpace(context, mobile: 8, tablet: 12, desktop: 16),
              Expanded(
                child: ResponsiveWidgets.responsiveText(
                  context,
                  text: title,
                  mobileFontSize: 14,
                  tabletFontSize: 16,
                  desktopFontSize: 18,
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          ResponsiveWidgets.verticalSpace(context, mobile: 8, tablet: 12, desktop: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: ResponsiveWidgets.responsiveText(
              context,
              text: value,
              mobileFontSize: 24,
              tabletFontSize: 28,
              desktopFontSize: 32,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overview grid section for tablet/desktop
class _OverviewGridSection extends StatelessWidget {
  final AppLocalizations l10n;
  final TaskController controller;
  final int crossAxisCount;

  const _OverviewGridSection({
    required this.l10n,
    required this.controller,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveWidgets.responsiveText(
          context,
          text: l10n.statistics,
          mobileFontSize: 20,
          tabletFontSize: 22,
          desktopFontSize: 24,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        ResponsiveWidgets.verticalSpace(context, mobile: 16, tablet: 20, desktop: 24),
        
        Obx(() {
          final stats = controller.taskStatistics.value;
          if (stats == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final cards = [
            _buildOverviewCardData(l10n.tasks, stats.totalTasks.toString(), Icons.task_alt, AppColors.primaryBlue),
            _buildOverviewCardData(l10n.completed, stats.completedTasks.toString(), Icons.check_circle, AppColors.success),
            _buildOverviewCardData(l10n.pending, stats.pendingTasks.toString(), Icons.pending_actions, AppColors.warning),
            _buildOverviewCardData(l10n.overdue, stats.overdueTasks.toString(), Icons.schedule, AppColors.error),
          ];
          
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: Responsive.getResponsiveSpacing(context, mobile: 16, tablet: 20, desktop: 24),
              mainAxisSpacing: Responsive.getResponsiveSpacing(context, mobile: 16, tablet: 20, desktop: 24),
              childAspectRatio: 1.5,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return _buildOverviewCard(context, card.title, card.value, card.icon, card.color);
            },
          );
        }),
      ],
    );
  }

  _OverviewCardData _buildOverviewCardData(String title, String value, IconData icon, Color color) {
    return _OverviewCardData(title: title, value: value, icon: icon, color: color);
  }

  Widget _buildOverviewCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return ResponsiveWidgets.responsiveContainer(
      context,
      color: color.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ResponsiveWidgets.responsiveIcon(
            context,
            icon: icon,
            color: color,
            mobileSize: 32,
            tabletSize: 36,
            desktopSize: 40,
          ),
          ResponsiveWidgets.verticalSpace(context, mobile: 8, tablet: 12, desktop: 16),
          ResponsiveWidgets.responsiveText(
            context,
            text: value,
            mobileFontSize: 24,
            tabletSize: 28,
            desktopFontSize: 32,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          ResponsiveWidgets.verticalSpace(context, mobile: 4, tablet: 6, desktop: 8),
          ResponsiveWidgets.responsiveText(
            context,
            text: title,
            mobileFontSize: 14,
            tabletFontSize: 16,
            desktopFontSize: 18,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
