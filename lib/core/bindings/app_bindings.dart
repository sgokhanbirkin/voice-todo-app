import 'package:get/get.dart';
import '../../features/todos/domain/i_task_repository.dart';
import '../../features/todos/data/repositories/hive_task_repository.dart';
import '../../features/todos/presentation/controllers/task_controller.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/audio/domain/i_audio_repository.dart';
import '../../features/audio/domain/i_audio_recorder.dart';
import '../../features/audio/domain/i_audio_player.dart';
import '../../features/audio/data/repositories/hive_audio_repository.dart';
import '../../features/audio/data/just_audio_player.dart';
import '../../features/audio/data/record_recorder.dart';
import '../../features/audio/presentation/controllers/audio_controller.dart';
import '../../features/sync/domain/i_sync_service.dart';
import '../../features/sync/data/supabase_sync_service.dart';
import '../../features/sync/presentation/controllers/sync_controller.dart';
import '../../product/theme/app_theme.dart';
import '../../product/localization/locale_controller.dart';

/// Application-wide dependency injection bindings
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Register theme and localization
    Get.lazyPut<AppTheme>(() => AppTheme.instance, fenix: true);
    Get.lazyPut<LocaleController>(() => LocaleController.instance, fenix: true);

    // Register repositories
    Get.lazyPut<ITaskRepository>(() => HiveTaskRepository(), fenix: true);
    Get.lazyPut<IAudioRepository>(() => HiveAudioRepository(), fenix: true);

    // Register audio services
    Get.lazyPut<IAudioRecorder>(() => RecordRecorder(), fenix: true);
    Get.lazyPut<IAudioPlayer>(() => JustAudioPlayer(), fenix: true);

    // Register sync service
    Get.lazyPut<ISyncService>(
      () => SupabaseSyncService(
        Get.find<ITaskRepository>(),
        Get.find<IAudioRepository>(),
      ),
      fenix: true,
    );

    // Register controllers
    Get.lazyPut<TaskController>(
      () => TaskController(Get.find<ITaskRepository>()),
      fenix: true,
    );

    Get.lazyPut<AudioController>(
      () => AudioController(
        Get.find<IAudioRepository>(),
        Get.find<IAudioRecorder>(),
        Get.find<IAudioPlayer>(),
      ),
      fenix: true,
    );

    Get.lazyPut<SyncController>(
      () => SyncController(Get.find<ISyncService>()),
      fenix: true,
    );

    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
