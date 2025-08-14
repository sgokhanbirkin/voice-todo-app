import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../logger.dart';
import '../../features/todos/data/adapters/task_entity_adapter.dart';
import '../../features/audio/data/adapters/audio_entity_adapter.dart';

/// Hive database manager for local data storage
class HiveDatabase {
  static HiveDatabase? _instance;
  static HiveDatabase get instance => _instance ??= HiveDatabase._();

  HiveDatabase._();

  /// Database boxes
  static const String _tasksBoxName = 'tasks';
  static const String _usersBoxName = 'users';
  static const String _audioBoxName = 'audio';
  static const String _settingsBoxName = 'settings';
  static const String _syncQueueBoxName = 'sync_queue';

  /// Initialize Hive database
  Future<void> initialize() async {
    try {
      // Get application documents directory
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final hivePath = '${appDocumentDir.path}/hive';

      // Initialize Hive
      await Hive.initFlutter(hivePath);

      // Register adapters
      _registerAdapters();

      // Open boxes
      await _openBoxes();

      Logger.instance.info('Hive database initialized successfully at: $hivePath');
    } catch (e) {
      Logger.instance.error('Failed to initialize Hive database: $e');
      rethrow;
    }
  }

  /// Register Hive type adapters
  void _registerAdapters() {
    // Register TaskEntity and related adapters
    Hive.registerAdapter(TaskEntityAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());
    Hive.registerAdapter(TaskStatusAdapter());
    Hive.registerAdapter(DurationAdapter());
    
    // Register AudioEntity adapter
    Hive.registerAdapter(AudioEntityAdapter());
    
    // TODO: Register UserEntity adapter
    
    Logger.instance.info('Hive adapters registered');
  }

  /// Open all database boxes
  Future<void> _openBoxes() async {
    try {
      // Open boxes with encryption (optional)
      await Hive.openBox(_tasksBoxName);
      await Hive.openBox(_usersBoxName);
      await Hive.openBox(_audioBoxName);
      await Hive.openBox(_settingsBoxName);
      await Hive.openBox(_syncQueueBoxName);

      Logger.instance.info('All Hive boxes opened successfully');
    } catch (e) {
      Logger.instance.error('Failed to open Hive boxes: $e');
      rethrow;
    }
  }

  /// Get tasks box
  Box get tasksBox => Hive.box(_tasksBoxName);

  /// Get users box
  Box get usersBox => Hive.box(_usersBoxName);

  /// Get audio box
  Box get audioBox => Hive.box(_audioBoxName);

  /// Get settings box
  Box get settingsBox => Hive.box(_settingsBoxName);

  /// Get sync queue box
  Box get syncQueueBox => Hive.box(_syncQueueBoxName);

  /// Close all boxes
  Future<void> closeBoxes() async {
    try {
      await Hive.close();
      Logger.instance.info('All Hive boxes closed successfully');
    } catch (e) {
      Logger.instance.error('Failed to close Hive boxes: $e');
    }
  }

  /// Clear all data (for testing/debugging)
  Future<void> clearAllData() async {
    try {
      await tasksBox.clear();
      await usersBox.clear();
      await audioBox.clear();
      await settingsBox.clear();
      await syncQueueBox.clear();

      Logger.instance.info('All Hive data cleared successfully');
    } catch (e) {
      Logger.instance.error('Failed to clear Hive data: $e');
    }
  }

  /// Get database statistics
  Map<String, int> getDatabaseStats() {
    return {
      'tasks': tasksBox.length,
      'users': usersBox.length,
      'audio': audioBox.length,
      'settings': settingsBox.length,
      'sync_queue': syncQueueBox.length,
    };
  }

  /// Check if database is ready
  bool get isReady => Hive.isBoxOpen(_tasksBoxName) && 
                     Hive.isBoxOpen(_usersBoxName) && 
                     Hive.isBoxOpen(_audioBoxName) &&
                     Hive.isBoxOpen(_settingsBoxName) &&
                     Hive.isBoxOpen(_syncQueueBoxName);
}
