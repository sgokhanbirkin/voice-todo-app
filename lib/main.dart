import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/remote/supabase_service.dart';
import 'core/logger.dart';
import 'core/router/app_router.dart';
import 'core/database/hive_database.dart';
import 'core/bindings/app_bindings.dart';
import 'product/theme/app_theme.dart';
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
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Voice Todo App',

          // Theme configuration
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
          locale: const Locale('tr'), // Default to Turkish
          // Router configuration
          routerDelegate: AppRouter.router.routerDelegate,
          routeInformationParser: AppRouter.router.routeInformationParser,
          routeInformationProvider: AppRouter.router.routeInformationProvider,
        );
      },
    );
  }
}
