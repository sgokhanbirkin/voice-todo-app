part of 'home_page.dart';

// Import specific body widget parts
part 'home_page_body_states.dart';
part 'home_page_body_content.dart';
part 'home_page_body_statistics.dart';

/// Home page body content with task list implementation
/// Uses responsive design and localization from product layer
/// Split into smaller files following SOLID principles
class _HomePageBody extends StatelessWidget {
  final AppLocalizations l10n;

  const _HomePageBody({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<TaskController>();

      if (controller.isLoading.value) {
        return _HomePageBodyStates.buildLoadingState(context);
      }

      if (controller.hasError.value) {
        return _HomePageBodyStates.buildErrorState(context, controller);
      }

      if (controller.tasks.isEmpty) {
        return _HomePageBodyStates.buildEmptyState(context, l10n);
      }

      return _HomePageBodyContent(l10n: l10n, controller: controller);
    });
  }
}