import 'package:flutter/material.dart';
import '../../../../../product/responsive/responsive.dart';
import '../../../../../product/theme/app_theme.dart';

/// Task section header with expand/collapse functionality
class TaskSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isExpanded;
  final VoidCallback onToggle;

  const TaskSectionHeader({
    super.key,
    required this.title,
    required this.count,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: ResponsiveWidgets.responsiveContainer(
        context,
        child: Row(
          children: [
            Container(
              width: Responsive.getResponsiveSpacing(
                context,
                mobile: 4,
                tablet: 5,
                desktop: 6,
              ),
              height: Responsive.getResponsiveSpacing(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ResponsiveWidgets.horizontalSpace(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
            Expanded(
              child: ResponsiveWidgets.responsiveText(
                context,
                text: title,
                mobileFontSize: 16,
                tabletFontSize: 18,
                desktopFontSize: 20,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            ResponsiveWidgets.horizontalSpace(
              context,
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
                vertical: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 4,
                  tablet: 5,
                  desktop: 6,
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ResponsiveWidgets.responsiveText(
                context,
                text: count.toString(),
                mobileFontSize: 12,
                tabletFontSize: 13,
                desktopFontSize: 14,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ResponsiveWidgets.horizontalSpace(
              context,
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.0 : -0.25, // 0° open, -90° closed
              duration: AppTheme.shortAnimation,
              child: ResponsiveWidgets.responsiveIcon(
                context,
                icon: Icons.keyboard_arrow_down,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                mobileSize: 24,
                tabletSize: 28,
                desktopSize: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
