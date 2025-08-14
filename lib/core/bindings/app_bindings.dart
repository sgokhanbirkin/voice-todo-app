import 'package:get/get.dart';
import '../../features/todos/domain/i_task_repository.dart';
import '../../features/todos/data/repositories/hive_task_repository.dart';
import '../../features/todos/presentation/controllers/task_controller.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

/// Application-wide dependency injection bindings
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Register repositories
    Get.lazyPut<ITaskRepository>(
      () => HiveTaskRepository(),
      fenix: true,
    );

    // Register controllers
    Get.lazyPut<TaskController>(
      () => TaskController(Get.find<ITaskRepository>()),
      fenix: true,
    );

    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true,
    );
  }
}
