import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../product/responsive/responsive.dart';
import '../../../../../product/theme/app_theme.dart';
import '../../../../../product/widgets/app_scaffold.dart';
import '../../controllers/task_controller.dart';
import '../../../domain/task_entity.dart';
import '../../../../audio/presentation/controllers/audio_controller.dart';
import '../../../../audio/domain/audio_entity.dart';
import '../../../../../data/remote/supabase_service.dart';

// Part files for better code organization (SOLID principles)
part 'add_task_form.dart';
part 'add_task_form_fields.dart';
part 'add_task_priority_selector.dart';
part 'add_task_audio_recorder.dart';
part 'add_task_action_buttons.dart';

/// Add task page widget with full localization and responsive support
/// Acts as a wrapper providing responsive layout for the add task form
class AddTaskPage extends StatelessWidget {
  const AddTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.addTask,
      showDrawerButton: false, // ← Drawer button kapalı
      useAnimatedDrawer: false, // ← ZoomDrawer kapalı
      showDrawerSettings: false, // ← Drawer ayarları kapalı
      automaticallyImplyLeading: true, // ← Geri butonu göster
      body: ResponsiveBuilder(
        mobile: (context) => const _AddTaskForm(),
        tablet: (context) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600.w),
            child: const _AddTaskForm(),
          ),
        ),
        desktop: (context) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800.w),
            child: const _AddTaskForm(),
          ),
        ),
      ),
    );
  }
}
