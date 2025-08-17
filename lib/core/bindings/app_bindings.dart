import 'package:get/get.dart';
import '../../features/todos/domain/i_task_repository.dart';
import '../../data/local/repositories/hive_task_repository.dart';
import '../../features/todos/presentation/controllers/task_controller.dart';
import '../../features/todos/presentation/controllers/task_list_controller.dart';
import '../../features/todos/presentation/controllers/task_filter_controller.dart';
import '../../features/todos/presentation/controllers/task_sort_controller.dart';
import '../../features/todos/presentation/controllers/task_statistics_controller.dart';
import '../../features/todos/presentation/controllers/task_crud_controller.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/audio/domain/i_audio_repository.dart';
import '../../features/audio/domain/i_audio_recorder.dart';
import '../../features/audio/domain/i_audio_player.dart';
import '../../features/audio/domain/i_speech_to_text.dart';
import '../../data/local/repositories/hive_audio_repository.dart';
import '../../features/audio/data/just_audio_player.dart';
import '../../features/audio/data/record_recorder.dart';
import '../../features/audio/data/speech_to_text_service.dart';
import '../../features/audio/presentation/controllers/audio_controller.dart';
import '../../features/audio/presentation/controllers/audio_permission_controller.dart';

import '../../core/sync/sync_manager.dart';
import '../../data/remote/repositories/supabase_task_repository.dart';
import '../../data/remote/repositories/supabase_storage_repository.dart';
import '../../data/remote/supabase_service.dart';
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

    // Register Supabase repositories for sync
    Get.lazyPut<SupabaseTaskRepository>(
      () => SupabaseTaskRepository(),
      fenix: true,
    );
    Get.lazyPut<SupabaseStorageRepository>(
      () => SupabaseStorageRepository(),
      fenix: true,
    );

    // Register Supabase service
    Get.lazyPut<SupabaseService>(() => SupabaseService.instance, fenix: true);

    // Register audio services
    Get.lazyPut<IAudioRecorder>(() => RecordRecorder(), fenix: true);
    Get.lazyPut<IAudioPlayer>(() => JustAudioPlayer(), fenix: true);
    Get.lazyPut<ISpeechToText>(() => SpeechToTextService(), fenix: true);

    // Register sync manager
    Get.lazyPut<SyncManager>(() => SyncManager(), fenix: true);

    // Register controllers
    Get.lazyPut<TaskController>(
      () => TaskController(Get.find<ITaskRepository>()),
      fenix: true,
    );

    // Register specialized task controllers (optional - for direct access)
    Get.lazyPut<TaskListController>(
      () => TaskListController(Get.find<ITaskRepository>()),
      fenix: true,
    );
    Get.lazyPut<TaskFilterController>(
      () => TaskFilterController(),
      fenix: true,
    );
    Get.lazyPut<TaskSortController>(() => TaskSortController(), fenix: true);
    Get.lazyPut<TaskStatisticsController>(
      () => TaskStatisticsController(Get.find<ITaskRepository>()),
      fenix: true,
    );
    Get.lazyPut<TaskCRUDController>(
      () => TaskCRUDController(Get.find<ITaskRepository>()),
      fenix: true,
    );



    // Register permission controller first
    Get.lazyPut<AudioPermissionController>(
      () => AudioPermissionController(),
      fenix: true,
    );

    Get.lazyPut<AudioController>(
      () => AudioController(
        Get.find<IAudioRepository>(),
        Get.find<IAudioRecorder>(),
        Get.find<IAudioPlayer>(),
        Get.find<ISpeechToText>(),
      ),
      fenix: true,
    );

    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
