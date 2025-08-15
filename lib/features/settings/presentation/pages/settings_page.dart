import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:voice_todo/product/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../product/responsive/responsive.dart';
import '../../../../product/widgets/app_scaffold.dart';
import '../../../todos/presentation/controllers/task_controller.dart';

// Re-export TaskController for part files
export '../../../todos/presentation/controllers/task_controller.dart';

// Part files for better code organization (SOLID principles)
part 'settings_analytics_view.dart';
part 'settings_overview_section.dart';
part 'settings_statistics_section.dart';
part 'settings_audio_insights.dart';
part 'settings_productivity_section.dart';

/// Settings and Analytics page with insights and statistics
/// Provides comprehensive task analytics, audio insights, and productivity metrics
/// Split into multiple files to maintain <300 lines per file following SOLID principles
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.analytics,
      showDrawerButton: true, // ← Drawer button aktif
      useAnimatedDrawer: true, // ← ZoomDrawer aktif
      showDrawerSettings: true,
      body: ResponsiveBuilder(
        mobile: (context) => const _AnalyticsView(),
        tablet: (context) => const _AnalyticsGridView(crossAxisCount: 2),
        desktop: (context) => const _AnalyticsGridView(crossAxisCount: 3),
      ),
    );
  }
}
