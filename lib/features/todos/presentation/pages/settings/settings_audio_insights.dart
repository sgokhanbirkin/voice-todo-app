part of 'settings_page.dart';

/// Audio insights section
class _AudioInsightsSection extends StatelessWidget {
  final AppLocalizations l10n;
  final TaskController controller;

  const _AudioInsightsSection({required this.l10n, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveWidgets.responsiveText(
          context,
          text: l10n.audioInsights,
          mobileFontSize: 18,
          tabletFontSize: 20,
          desktopFontSize: 22,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        ResponsiveWidgets.verticalSpace(context, mobile: 16, tablet: 20, desktop: 24),
        
        ResponsiveWidgets.responsiveContainer(
          context,
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Column(
            children: [
              _buildAudioStat(
                context,
                l10n.totalRecordings,
                '24',
                Icons.mic,
                AppColors.audioRecording,
              ),
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              
              _buildAudioStat(
                context,
                l10n.totalDuration,
                '2h 35m',
                Icons.schedule,
                AppColors.primaryBlue,
              ),
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              
              _buildAudioStat(
                context,
                l10n.averageLength,
                '6m 28s',
                Icons.timer,
                AppColors.success,
              ),
              ResponsiveWidgets.verticalSpace(context, mobile: 12, tablet: 16, desktop: 20),
              
              _buildAudioStat(
                context,
                l10n.recordingQuality,
                'High',
                Icons.high_quality,
                AppColors.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        ResponsiveWidgets.responsiveIcon(
          context,
          icon: icon,
          color: color,
          mobileSize: 20,
          tabletSize: 24,
          desktopSize: 28,
        ),
        ResponsiveWidgets.horizontalSpace(context, mobile: 12, tablet: 16, desktop: 20),
        Expanded(
          child: ResponsiveWidgets.responsiveText(
            context,
            text: label,
            mobileFontSize: 14,
            tabletFontSize: 16,
            desktopFontSize: 18,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        ResponsiveWidgets.responsiveText(
          context,
          text: value,
          mobileFontSize: 16,
          tabletFontSize: 18,
          desktopFontSize: 20,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
