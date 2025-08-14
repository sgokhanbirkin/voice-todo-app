part of 'settings_page.dart';

/// Productivity trends section
class _ProductivitySection extends StatelessWidget {
  final AppLocalizations l10n;
  final TaskController controller;

  const _ProductivitySection({required this.l10n, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveWidgets.responsiveText(
          context,
          text: l10n.productivity,
          mobileFontSize: 18,
          tabletFontSize: 20,
          desktopFontSize: 22,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        ResponsiveWidgets.verticalSpace(context, mobile: 16, tablet: 20, desktop: 24),
        
        ResponsiveBuilder(
          mobile: (context) => Column(
            children: [
              _buildProgressCard(context, l10n.weeklyProgress, 85, AppColors.success),
              ResponsiveWidgets.verticalSpace(context, mobile: 16, tablet: 20, desktop: 24),
              _buildProgressCard(context, l10n.monthlyProgress, 72, AppColors.primaryBlue),
            ],
          ),
          tablet: (context) => Row(
            children: [
              Expanded(child: _buildProgressCard(context, l10n.weeklyProgress, 85, AppColors.success)),
              ResponsiveWidgets.horizontalSpace(context, mobile: 16, tablet: 20, desktop: 24),
              Expanded(child: _buildProgressCard(context, l10n.monthlyProgress, 72, AppColors.primaryBlue)),
            ],
          ),
          desktop: (context) => Row(
            children: [
              Expanded(child: _buildProgressCard(context, l10n.weeklyProgress, 85, AppColors.success)),
              ResponsiveWidgets.horizontalSpace(context, mobile: 16, tablet: 20, desktop: 24),
              Expanded(child: _buildProgressCard(context, l10n.monthlyProgress, 72, AppColors.primaryBlue)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, String title, int progress, Color color) {
    return ResponsiveWidgets.responsiveContainer(
      context,
      color: color.withValues(alpha: 0.1),
      child: Column(
        children: [
          ResponsiveWidgets.responsiveText(
            context,
            text: title,
            mobileFontSize: 16,
            tabletFontSize: 18,
            desktopFontSize: 20,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          ResponsiveWidgets.verticalSpace(context, mobile: 16, tablet: 20, desktop: 24),
          
          // Progress indicator (simplified)
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: Responsive.getResponsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * (progress / 100),
                height: Responsive.getResponsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          ResponsiveWidgets.verticalSpace(context, mobile: 8, tablet: 12, desktop: 16),
          
          ResponsiveWidgets.responsiveText(
            context,
            text: '$progress%',
            mobileFontSize: 20,
            tabletFontSize: 24,
            desktopFontSize: 28,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
