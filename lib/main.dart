import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/remote/supabase_service.dart';
import 'core/logger.dart';
import 'core/router/app_router.dart';
import 'core/database/hive_database.dart';
import 'core/bindings/app_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Initialize Supabase
  try {
    await SupabaseService.instance.initialize();
    Logger.instance.info('Supabase initialized successfully in main');
  } catch (e) {
    Logger.instance.error('Failed to initialize Supabase in main: $e');
  }

  // Initialize Hive Database
  try {
    await HiveDatabase.instance.initialize();
    Logger.instance.info('Hive database initialized successfully in main');
  } catch (e) {
    Logger.instance.error('Failed to initialize Hive database in main: $e');
  }

  // Initialize GetX bindings
  AppBindings().dependencies();
  Logger.instance.info('GetX dependencies initialized');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Voice Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
