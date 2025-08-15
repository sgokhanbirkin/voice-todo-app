part of 'home_page.dart';

// Localization: Tüm string'ler AppLocalizations üzerinden alınıyor
// Responsive: Tüm boyutlar Responsive utility'ler ile yönetiliyor

/// Task priority filter cards widget
class TaskPriorityFilters extends StatelessWidget {
  final AppLocalizations l10n;
  final TaskController controller;

  const TaskPriorityFilters({
    super.key,
    required this.l10n,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.getResponsiveSpacing(
        context,
        mobile: 40,
        tablet: 48,
        desktop: 56,
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: ResponsiveWidgets.responsivePadding(context, horizontal: 4),
        children: [
          _buildPriorityFilterCard(
            context,
            TaskPriority.high,
            l10n.taskPriorityHigh,
            AppColors.priorityHigh,
          ),
          ResponsiveWidgets.horizontalSpace(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          ),
          _buildPriorityFilterCard(
            context,
            TaskPriority.medium,
            l10n.taskPriorityMedium,
            AppColors.priorityMedium,
          ),
          ResponsiveWidgets.horizontalSpace(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          ),
          _buildPriorityFilterCard(
            context,
            TaskPriority.low,
            l10n.taskPriorityLow,
            AppColors.priorityLow,
          ),
          // Filtreleme ve Sıralama Dropdown
          _buildFilterSortDropdown(context),
        ],
      ),
    );
  }

  Widget _buildPriorityFilterCard(
    BuildContext context,
    TaskPriority priority,
    String label,
    Color color,
  ) {
    return Obx(() {
      final isSelected = controller.filterPriority.value == priority;

      return GestureDetector(
        onTap: () {
          if (controller.filterPriority.value == priority) {
            // Same priority clicked - clear filter
            controller.setFilterPriority(null);
          } else {
            // Different priority clicked - set filter
            controller.setFilterPriority(priority);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getResponsiveSpacing(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
            vertical: Responsive.getResponsiveSpacing(
              context,
              mobile: 8,
              tablet: 10,
              desktop: 12,
            ),
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(
              Responsive.getResponsiveSpacing(
                context,
                mobile: 20,
                tablet: 24,
                desktop: 28,
              ),
            ),
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
                width: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
                height: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              ResponsiveWidgets.horizontalSpace(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
              ResponsiveWidgets.responsiveText(
                context,
                text: label,
                mobileFontSize: 12,
                tabletFontSize: 13,
                desktopFontSize: 14,
                style: TextStyle(
                  color: isSelected
                      ? _getContrastTextColor(color)
                      : _getContrastTextColor(
                          Theme.of(context).colorScheme.surface,
                        ),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Build filter and sort dropdown
  Widget _buildFilterSortDropdown(BuildContext context) {
    return Obx(() {
      final hasActiveFilters =
          controller.filterPriority.value != null ||
          controller.filterStatus.value != null ||
          controller.audioFilter.value ||
          controller.completedFilter.value ||
          controller.pendingFilter.value ||
          controller.overdueFilter.value;

      return PopupMenuButton<String>(
        icon: Container(
          height: Responsive.getResponsiveSpacing(
            context,
            mobile: 48,
            tablet: 56,
            desktop: 64,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
            vertical: Responsive.getResponsiveSpacing(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),
          decoration: BoxDecoration(
            color: hasActiveFilters
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(
              Responsive.getResponsiveSpacing(
                context,
                mobile: 20,
                tablet: 24,
                desktop: 28,
              ),
            ),
            border: Border.all(
              color: hasActiveFilters
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
              width: hasActiveFilters ? 2 : 1,
            ),
            boxShadow: hasActiveFilters
                ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasActiveFilters ? Icons.filter_alt : Icons.filter_list,
                color: hasActiveFilters
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onPrimaryContainer,
                size: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 20,
                  tablet: 22,
                  desktop: 24,
                ),
              ),
              ResponsiveWidgets.horizontalSpace(
                context,
                mobile: 8,
                tablet: 10,
                desktop: 12,
              ),
              Text(
                hasActiveFilters ? l10n.filtersActive : l10n.filter,
                style: TextStyle(
                  color: hasActiveFilters
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 15,
                    desktop: 16,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasActiveFilters) ...[
                ResponsiveWidgets.horizontalSpace(
                  context,
                  mobile: 6,
                  tablet: 8,
                  desktop: 10,
                ),
                Container(
                  padding: EdgeInsets.all(
                    Responsive.getResponsiveSpacing(
                      context,
                      mobile: 4,
                      tablet: 6,
                      desktop: 8,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: Responsive.getResponsiveSpacing(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        itemBuilder: (context) => [
          // Filtreleme Başlığı
          PopupMenuItem<String>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.filtering,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
          // Filtre Sıfırlama
          if (hasActiveFilters) ...[
            PopupMenuItem<String>(
              value: 'clear_filters',
              child: Row(
                children: [
                  Icon(
                    Icons.clear_all,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.clearAllFilters,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
          ],
          // Ses Kaydı Filtresi
          PopupMenuItem<String>(
            value: 'audio_filter',
            child: Row(
              children: [
                Icon(
                  Icons.mic,
                  size: 20,
                  color: controller.audioFilter.value
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.audioFilter,
                  style: TextStyle(
                    color: controller.audioFilter.value
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: controller.audioFilter.value
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (controller.audioFilter.value)
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
          // Tamamlanan Filtresi
          PopupMenuItem<String>(
            value: 'completed_filter',
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: controller.completedFilter.value
                      ? AppColors.success
                      : Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.completedFilter,
                  style: TextStyle(
                    color: controller.completedFilter.value
                        ? AppColors.success
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: controller.completedFilter.value
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (controller.completedFilter.value)
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.success,
                  ),
              ],
            ),
          ),
          // Bekleyen Filtresi
          PopupMenuItem<String>(
            value: 'pending_filter',
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 20,
                  color: controller.pendingFilter.value
                      ? AppColors.warning
                      : Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.pendingFilter,
                  style: TextStyle(
                    color: controller.pendingFilter.value
                        ? AppColors.warning
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: controller.pendingFilter.value
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (controller.pendingFilter.value)
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.warning,
                  ),
              ],
            ),
          ),
          // Gecikmiş Filtresi
          PopupMenuItem<String>(
            value: 'overdue_filter',
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  size: 20,
                  color: controller.overdueFilter.value
                      ? AppColors.error
                      : Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.overdueFilter,
                  style: TextStyle(
                    color: controller.overdueFilter.value
                        ? AppColors.error
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: controller.overdueFilter.value
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (controller.overdueFilter.value)
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.error,
                  ),
              ],
            ),
          ),
          // Ayırıcı
          const PopupMenuDivider(),
          // Sıralama Başlığı
          PopupMenuItem<String>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sorting,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
          // Tarihe Göre İleri
          PopupMenuItem<String>(
            value: 'sort_date_asc',
            child: Row(
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Text(l10n.sortByDateAscending),
              ],
            ),
          ),
          // Tarihe Göre Geri
          PopupMenuItem<String>(
            value: 'sort_date_desc',
            child: Row(
              children: [
                Icon(
                  Icons.arrow_downward,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Text(l10n.sortByDateDescending),
              ],
            ),
          ),
          // Önceliğe Göre
          PopupMenuItem<String>(
            value: 'sort_priority',
            child: Row(
              children: [
                Icon(
                  Icons.priority_high,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Text(l10n.sortByPriority),
              ],
            ),
          ),
          // Alfabetik
          PopupMenuItem<String>(
            value: 'sort_alphabetical',
            child: Row(
              children: [
                Icon(
                  Icons.sort_by_alpha,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Text(l10n.sortByAlphabetical),
              ],
            ),
          ),
        ],
        onSelected: (value) {
          _handleFilterSortSelection(context, value);
        },
      );
    });
  }

  /// Handle filter and sort selection
  void _handleFilterSortSelection(BuildContext context, String value) {
    switch (value) {
      case 'clear_filters':
        controller.clearAllFilters();
        break;
      case 'audio_filter':
        controller.toggleAudioFilter();
        break;
      case 'completed_filter':
        controller.toggleCompletedFilter();
        break;
      case 'pending_filter':
        controller.togglePendingFilter();
        break;
      case 'overdue_filter':
        controller.toggleOverdueFilter();
        break;
      case 'sort_date_asc':
        controller.setSortOrder(SortOrder.dateAscending);
        break;
      case 'sort_date_desc':
        controller.setSortOrder(SortOrder.dateDescending);
        break;
      case 'sort_priority':
        controller.setSortOrder(SortOrder.priority);
        break;
      case 'sort_alphabetical':
        controller.setSortOrder(SortOrder.alphabetical);
        break;
    }
  }
}

Color _getContrastTextColor(Color backgroundColor) {
  // Arka plan renginin parlaklığını hesapla
  final luminance = backgroundColor.computeLuminance();
  // Parlaklık 0.5'ten büyükse koyu text, küçükse açık text kullan
  if (luminance > 0.5) {
    return Colors.black; // Açık arka plan için koyu text
  } else {
    return Colors.white; // Koyu arka plan için beyaz text
  }
}
