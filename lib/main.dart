import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/remote/supabase_service.dart';
import 'core/logger.dart';
import 'core/router/app_router.dart';
import 'data/local/hive_database_manager.dart';
import 'core/bindings/app_bindings.dart';
import 'product/theme/app_theme.dart';
import 'product/localization/locale_controller.dart';
import 'l10n/app_localizations.dart';

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

  // Initialize Hive Database Manager
  try {
    await HiveDatabaseManager.instance.initialize();
    Logger.instance.info(
      'Hive database manager initialized successfully in main',
    );
  } catch (e) {
    Logger.instance.error(
      'Failed to initialize Hive database manager in main: $e',
    );

    // If it's a TypeId error, try to force clear and reinitialize
    if (e.toString().contains('unknown typeId')) {
      Logger.instance.warning('Attempting to force clear database...');
      try {
        await HiveDatabaseManager.instance.deleteAll();
        await HiveDatabaseManager.instance.initialize();
        Logger.instance.info(
          'Hive database manager reinitialized successfully after clearing',
        );
      } catch (clearError) {
        Logger.instance.error(
          'Failed to clear and reinitialize database manager: $clearError',
        );
        // Continue with app initialization even if database fails
      }
    }
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
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() {
          return GetMaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Voice Todo App',

            // Theme configuration - Now reactive!
            theme: AppTheme.instance.lightTheme,
            darkTheme: AppTheme.instance.darkTheme,
            themeMode: AppTheme.instance.currentThemeMode,

            // Localization configuration
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: LocaleController.instance.currentLocale, // Reactive locale
            // Router configuration
            routerDelegate: AppRouter.router.routerDelegate,
            routeInformationParser: AppRouter.router.routeInformationParser,
            routeInformationProvider: AppRouter.router.routeInformationProvider,
          );
        });
      },
    );
  }
}
