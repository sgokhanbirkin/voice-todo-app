part of 'home_page.dart';

class HomePageBody extends StatelessWidget {
  final AppLocalizations l10n;

  const HomePageBody({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<TaskController>();

      if (controller.isLoading.value) {
        return HomePageBodyStates.buildLoadingState(context);
      }

      if (controller.hasError.value) {
        return HomePageBodyStates.buildErrorState(context, controller);
      }

      if (controller.tasks.isEmpty) {
        return HomePageBodyStates.buildEmptyState(context, l10n);
      }

      return HomePageBodyContent(l10n: l10n, controller: controller);
    });
  }
}
