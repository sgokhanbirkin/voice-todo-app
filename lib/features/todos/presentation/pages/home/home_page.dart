import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:voice_todo/features/todos/presentation/pages/home/home_page_body_states.dart';

import 'package:voice_todo/features/todos/presentation/pages/home/home_page_task_section_header.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../product/responsive/responsive.dart';
import '../../../../../product/theme/app_theme.dart';
import '../../../../../product/widgets/app_scaffold.dart';
import '../../../../auth/presentation/controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../../domain/task_entity.dart';

import 'home_page_body_statistics.dart';

// Part files for better code organization (SOLID principles)

part 'home_page_body_content.dart';
part 'home_page_body.dart';
part 'home_page_task_card.dart';
part 'home_page_task_filters.dart';

/// Home page widget - Refactored to follow SOLID principles
/// Split into multiple files to maintain <250 lines per file
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authController = Get.find<AuthController>();
    final taskController = Get.find<TaskController>();

    return ResponsiveBuilder(
      mobile: (context) =>
          _buildAppScaffold(context, l10n, authController, taskController),
      tablet: (context) =>
          _buildAppScaffold(context, l10n, authController, taskController),
      desktop: (context) =>
          _buildDesktopLayout(context, l10n, authController, taskController),
    );
  }

  /// Build AppScaffold for mobile and tablet layouts
  Widget _buildAppScaffold(
    BuildContext context,
    AppLocalizations l10n,
    AuthController authController,
    TaskController taskController,
  ) {
    return AppScaffold(
      title: l10n.home,
      showDrawerButton: true,
      useAnimatedDrawer: true,
      showDrawerSettings: true,
      body: _buildMainScreen(context, l10n, taskController),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-task'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build main screen content
  Widget _buildMainScreen(
    BuildContext context,
    AppLocalizations l10n,
    TaskController taskController,
  ) {
    return Column(
      children: [
        // Body content
        Expanded(child: HomePageBody(l10n: l10n)),
      ],
    );
  }

  /// Build desktop layout with sidebar
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
                Expanded(child: HomePageBody(l10n: l10n)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build sidebar for desktop layout
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
                onTap: () {
                  // Desktop için basit dialog gösterebiliriz
                },
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

  /// Build top bar for desktop layout
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
            onPressed: () => context.go('/add-task'),
            icon: const Icon(Icons.add),
            label: Text(l10n.addTask),
          ),
        ],
      ),
    );
  }
}
