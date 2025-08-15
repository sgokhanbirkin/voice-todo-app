import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Entity imports
import '../../features/todos/domain/task_entity.dart';
import '../../features/audio/domain/audio_entity.dart';

// Adapter imports
import 'adapters/task_entity_adapter.dart';
import 'adapters/audio_entity_adapter.dart';

/// Merkezi Hive Database Manager
/// Tüm Hive box'ları ve adapter'ları burada yönetilir
class HiveDatabaseManager {
  static HiveDatabaseManager? _instance;
  static HiveDatabaseManager get instance =>
      _instance ??= HiveDatabaseManager._();

  HiveDatabaseManager._();

  // Box names - merkezi tanımlama
  static const String tasksBoxName = 'tasks';
  static const String audioBoxName = 'audio_files';
  static const String settingsBoxName = 'settings';

  // Box references
  Box<TaskEntity>? _tasksBox;
  Box<AudioEntity>? _audioBox;
  Box<dynamic>? _settingsBox;

  // Getters
  Box<TaskEntity> get tasksBox {
    if (_tasksBox == null || !_tasksBox!.isOpen) {
      throw Exception('Tasks box is not initialized');
    }
    return _tasksBox!;
  }

  Box<AudioEntity> get audioBox {
    if (_audioBox == null || !_audioBox!.isOpen) {
      throw Exception('Audio box is not initialized');
    }
    return _audioBox!;
  }

  Box<dynamic> get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw Exception('Settings box is not initialized');
    }
    return _settingsBox!;
  }

  /// Initialize Hive database
  Future<void> initialize() async {
    try {
      debugPrint('HiveDatabaseManager: Starting initialization...');

      // Initialize Hive
      await Hive.initFlutter();

      // Register adapters - merkezi kayıt
      await _registerAdapters();

      // Open boxes
      await _openBoxes();

      debugPrint('HiveDatabaseManager: Initialization completed successfully');
    } catch (e) {
      debugPrint('HiveDatabaseManager: Initialization failed: $e');
      rethrow;
    }
  }

  /// Register all Hive adapters
  Future<void> _registerAdapters() async {
    try {
      // TaskEntity adapter (TypeId: 0)
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskEntityAdapter());
        debugPrint(
          'HiveDatabaseManager: Registered TaskEntity adapter (TypeId: 0)',
        );
      }

      // TaskPriority adapter (TypeId: 1)
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(TaskPriorityAdapter());
        debugPrint(
          'HiveDatabaseManager: Registered TaskPriority adapter (TypeId: 1)',
        );
      }

      // AudioEntity adapter (TypeId: 2)
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(AudioEntityAdapter());
        debugPrint(
          'HiveDatabaseManager: Registered AudioEntity adapter (TypeId: 2)',
        );
      }

      // TaskStatus adapter (TypeId: 3)
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(TaskStatusAdapter());
        debugPrint(
          'HiveDatabaseManager: Registered TaskStatus adapter (TypeId: 3)',
        );
      }

      // Duration adapter (TypeId: 4)
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(DurationAdapter());
        debugPrint(
          'HiveDatabaseManager: Registered Duration adapter (TypeId: 4)',
        );
      }

      debugPrint('HiveDatabaseManager: All adapters registered successfully');
    } catch (e) {
      debugPrint('HiveDatabaseManager: Failed to register adapters: $e');
      rethrow;
    }
  }

  /// Open all Hive boxes
  Future<void> _openBoxes() async {
    try {
      // Tasks box
      _tasksBox = await Hive.openBox<TaskEntity>(tasksBoxName);
      debugPrint(
        'HiveDatabaseManager: Opened tasks box (${_tasksBox!.length} items)',
      );

      // Audio box
      _audioBox = await Hive.openBox<AudioEntity>(audioBoxName);
      debugPrint(
        'HiveDatabaseManager: Opened audio box (${_audioBox!.length} items)',
      );

      // Settings box (dynamic type for flexibility)
      _settingsBox = await Hive.openBox(settingsBoxName);
      debugPrint(
        'HiveDatabaseManager: Opened settings box (${_settingsBox!.length} items)',
      );
    } catch (e) {
      debugPrint('HiveDatabaseManager: Failed to open boxes: $e');
      rethrow;
    }
  }

  /// Close all boxes
  Future<void> closeAll() async {
    try {
      await _tasksBox?.close();
      await _audioBox?.close();
      await _settingsBox?.close();
      debugPrint('HiveDatabaseManager: All boxes closed');
    } catch (e) {
      debugPrint('HiveDatabaseManager: Failed to close boxes: $e');
    }
  }

  /// Delete all data (for development/testing)
  Future<void> deleteAll() async {
    try {
      await _tasksBox?.clear();
      await _audioBox?.clear();
      await _settingsBox?.clear();
      debugPrint('HiveDatabaseManager: All data cleared');
    } catch (e) {
      debugPrint('HiveDatabaseManager: Failed to clear data: $e');
    }
  }

  /// Get box info for debugging
  Map<String, dynamic> getBoxInfo() {
    return {
      'tasks': {
        'isOpen': _tasksBox?.isOpen ?? false,
        'length': _tasksBox?.length ?? 0,
      },
      'audio': {
        'isOpen': _audioBox?.isOpen ?? false,
        'length': _audioBox?.length ?? 0,
      },
      'settings': {
        'isOpen': _settingsBox?.isOpen ?? false,
        'length': _settingsBox?.length ?? 0,
      },
    };
  }

  /// Get database statistics
  Map<String, int> getDatabaseStats() {
    return {
      'tasks': _tasksBox?.length ?? 0,
      'audio': _audioBox?.length ?? 0,
      'settings': _settingsBox?.length ?? 0,
    };
  }

  /// Clear all local data (for testing/debugging)
  Future<void> clearAllData() async {
    try {
      await _tasksBox?.clear();
      await _audioBox?.clear();
      await _settingsBox?.clear();
      debugPrint('HiveDatabaseManager: All data cleared');
    } catch (e) {
      debugPrint('HiveDatabaseManager: Failed to clear data: $e');
      rethrow;
    }
  }
}
