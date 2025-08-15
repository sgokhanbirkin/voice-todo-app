import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../product/responsive/responsive.dart';
import '../../../../../product/theme/app_theme.dart';
import '../../../../../product/widgets/app_scaffold.dart';
import '../../controllers/task_controller.dart';
import '../../../domain/task_entity.dart';
import '../../../../audio/presentation/controllers/audio_controller.dart';
import '../../../../audio/domain/audio_entity.dart';

// Localization: Tüm string'ler AppLocalizations üzerinden alınıyor
// SOLID Principles: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
// Responsive: Tüm boyutlar Responsive utility'ler ile yönetiliyor

part 'task_detail_page_ui.dart';
part 'task_detail_page_form.dart';
part 'task_detail_page_actions.dart';
part 'task_detail_page_utils.dart';

/// Task detail page showing all task information and actions
class TaskDetailPage extends StatefulWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TaskController _taskController;
  late AudioController _audioController;
  TaskEntity? _task;
  bool _isLoading = true;
  bool _isEditing = false;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _taskController = Get.find<TaskController>();
    _audioController = Get.find<AudioController>();
    _loadTask();
  }

  Future<void> _loadTask() async {
    try {
      final task = _taskController.tasks.firstWhereOrNull(
        (task) => task.id == widget.taskId,
      );
      if (task != null) {
        setState(() {
          _task = task;
          _titleController.text = task.title;
          _descriptionController.text = task.description ?? '';
          _selectedPriority = task.priority;
          _selectedDueDate = task.dueDate;
          _audioPath = task.audioPath;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.taskLoadError}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Play audio from path
  Future<void> _playAudioFromPath(String audioPath) async {
    try {
      // Create a temporary AudioEntity for playback
      final audioEntity = AudioEntity(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        taskId: _task?.id ?? 'temp_task',
        fileName: audioPath.split('/').last,
        localPath: audioPath,
        fileSize: 0,
        duration: const Duration(seconds: 0),
        format: 'm4a',
        recordedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _audioController.playAudio(audioEntity);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToPlayAudio}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_task == null) return;

    try {
      final updatedTask = _task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        audioPath: _audioPath,
        updatedAt: DateTime.now(),
      );

      await _taskController.updateTask(updatedTask);

      setState(() {
        _task = updatedTask;
        _isEditing = false;
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.taskUpdatedSuccessfully),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.taskUpdateError}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleTaskStatus() async {
    if (_task == null) return;

    try {
      if (_task!.status == TaskStatus.completed) {
        await _taskController.uncompleteTask(_task!.id);
      } else {
        await _taskController.completeTask(_task!.id);
      }

      await _loadTask(); // Reload task to get updated status
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.taskStatusUpdateError}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleStarred() async {
    if (_task == null) return;

    try {
      if (_task!.isStarred) {
        await _taskController.unstarTask(_task!.id);
      } else {
        await _taskController.starTask(_task!.id);
      }

      await _loadTask(); // Reload task to get updated status
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.taskStarUpdateError}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteTask() async {
    if (_task == null) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.taskDelete),
        content: Text(l10n.taskDeleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _taskController.deleteTask(_task!.id);
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.taskDeleteError}: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  // Callback methods for extensions
  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _updatePriority(TaskPriority priority) {
    setState(() {
      _selectedPriority = priority;
    });
  }

  void _updateDueDate(DateTime? date) {
    setState(() {
      _selectedDueDate = date;
    });
  }

  void _clearDueDate() {
    setState(() {
      _selectedDueDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return AppScaffold(
        title: l10n.loading,
        showDrawerButton: false,
        useAnimatedDrawer: false,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_task == null) {
      return AppScaffold(
        title: l10n.taskNotFound,
        showDrawerButton: false,
        useAnimatedDrawer: false,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              ResponsiveWidgets.verticalSpace(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
              Text(
                l10n.taskNotFoundDescription,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ResponsiveWidgets.verticalSpace(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.goBack),
              ),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      title: l10n.task,
      showDrawerButton: false,
      useAnimatedDrawer: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          Responsive.getResponsiveSpacing(
            context,
            mobile: 16,
            tablet: 24,
            desktop: 32,
          ),
        ),
        physics:
            const ClampingScrollPhysics(), // Android'de daha iyi scroll davranışı
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with task title and action buttons
            _buildHeaderSection(context),
            ResponsiveWidgets.verticalSpace(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
            // Task content
            if (_isEditing) ...[
              _buildEditForm(context, l10n),
            ] else ...[
              _buildTaskContent(context, l10n),
            ],

            ResponsiveWidgets.verticalSpace(
              context,
              mobile: 24,
              tablet: 32,
              desktop: 40,
            ),

            // Action buttons
            _buildActionButtons(context, l10n),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
