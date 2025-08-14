import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../product/responsive/responsive.dart';
import '../../../../product/theme/app_theme.dart';
import '../../../../product/widgets/app_scaffold.dart';
import '../controllers/task_controller.dart';
import '../../domain/task_entity.dart';
import '../../../audio/presentation/controllers/audio_controller.dart';
import '../../../audio/domain/audio_entity.dart';

/// Add task page widget with full localization and responsive support
class AddTaskPage extends StatelessWidget {
  const AddTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AppScaffold(
      title: l10n.addTask,
      body: ResponsiveBuilder(
        mobile: (context) => const _AddTaskForm(),
        tablet: (context) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600.w),
            child: const _AddTaskForm(),
          ),
        ),
        desktop: (context) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800.w),
            child: const _AddTaskForm(),
          ),
        ),
      ),
    );
  }
}

/// Add task form widget with full functionality
class _AddTaskForm extends StatefulWidget {
  const _AddTaskForm();

  @override
  State<_AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<_AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Controllers
  late final TaskController _taskController;
  late final AudioController _audioController;
  
  // Form state
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  bool _isSubmitting = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _taskController = Get.find<TaskController>();
    _audioController = Get.find<AudioController>();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: Responsive.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title Field
            _buildTitleField(context, l10n),
            
            SizedBox(height: Responsive.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            )),
            
            // Description Field
            _buildDescriptionField(context, l10n),
            
            SizedBox(height: Responsive.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            )),
            
            // Priority Selection
            _buildPrioritySection(context, l10n),
            
            SizedBox(height: Responsive.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            )),
            
            // Due Date Selection
            _buildDueDateSection(context, l10n),
            
            SizedBox(height: Responsive.getResponsiveSpacing(
              context,
              mobile: 24,
              tablet: 32,
              desktop: 40,
            )),
            
            // Voice Recording Section
            _buildVoiceRecordingSection(context, l10n),
            
            SizedBox(height: Responsive.getResponsiveSpacing(
              context,
              mobile: 32,
              tablet: 40,
              desktop: 48,
            )),
            
            // Action Buttons
            _buildActionButtons(context, l10n),
          ],
        ),
      ),
    );
  }

  /// Build task title field
  Widget _buildTitleField(BuildContext context, AppLocalizations l10n) {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: l10n.taskTitle,
        hintText: 'Enter task title...',
        prefixIcon: const Icon(Icons.title),
        border: const OutlineInputBorder(),
      ),
      style: TextStyle(
        fontSize: Responsive.getResponsiveFontSize(
          context,
          mobile: 16,
          tablet: 18,
          desktop: 20,
        ),
      ),
      validator: _taskController.validateTaskTitle,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.next,
    );
  }

  /// Build description field
  Widget _buildDescriptionField(BuildContext context, AppLocalizations l10n) {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: l10n.taskDescription,
        hintText: 'Enter task description (optional)...',
        prefixIcon: const Icon(Icons.description),
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      style: TextStyle(
        fontSize: Responsive.getResponsiveFontSize(
          context,
          mobile: 14,
          tablet: 16,
          desktop: 18,
        ),
      ),
      maxLines: Responsive.isDesktop(context) ? 4 : 3,
      validator: _taskController.validateTaskDescription,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.newline,
    );
  }

  /// Build priority selection section
  Widget _buildPrioritySection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.taskPriority,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Responsive.getResponsiveSpacing(
          context,
          mobile: 8,
          tablet: 12,
          desktop: 16,
        )),
        ResponsiveBuilder(
          mobile: (context) => Column(
            children: TaskPriority.values.map((priority) => 
              _buildPriorityOption(context, l10n, priority)
            ).toList(),
          ),
          tablet: (context) => Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            children: TaskPriority.values.map((priority) => 
              _buildPriorityChip(context, l10n, priority)
            ).toList(),
          ),
          desktop: (context) => Row(
            children: TaskPriority.values.map((priority) => 
              Expanded(child: _buildPriorityChip(context, l10n, priority))
            ).toList(),
          ),
        ),
      ],
    );
  }

  /// Build priority option for mobile
  Widget _buildPriorityOption(BuildContext context, AppLocalizations l10n, TaskPriority priority) {
    final color = _getPriorityColor(priority);
    final label = _getPriorityLabel(l10n, priority);
    
    return RadioListTile<TaskPriority>(
      value: priority,
      groupValue: _selectedPriority,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPriority = value;
          });
        }
      },
      title: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(label),
        ],
      ),
      activeColor: color,
    );
  }

  /// Build priority chip for tablet/desktop
  Widget _buildPriorityChip(BuildContext context, AppLocalizations l10n, TaskPriority priority) {
    final isSelected = _selectedPriority == priority;
    final color = _getPriorityColor(priority);
    final label = _getPriorityLabel(l10n, priority);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: isSelected 
            ? color.withValues(alpha: 0.2)
            : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected 
              ? color
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                  ? color
                  : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build due date selection section
  Widget _buildDueDateSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.taskDueDate,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: Responsive.getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Responsive.getResponsiveSpacing(
          context,
          mobile: 8,
          tablet: 12,
          desktop: 16,
        )),
        InkWell(
          onTap: () => _selectDueDate(context),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _selectedDueDate != null
                        ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                        : 'Select due date (optional)',
                    style: TextStyle(
                      color: _selectedDueDate != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: Responsive.getResponsiveFontSize(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                    ),
                  ),
                ),
                if (_selectedDueDate != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDueDate = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    iconSize: 20.sp,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build voice recording section
  Widget _buildVoiceRecordingSection(BuildContext context, AppLocalizations l10n) {
    return Obx(() {
      final isRecording = _audioController.isRecording.value;
      final isPlaying = _audioController.isPlaying.value;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recordVoice,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: Responsive.getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Responsive.getResponsiveSpacing(
            context,
            mobile: 12,
            tablet: 16,
            desktop: 20,
          )),
          
          // Recording Controls
          ResponsiveBuilder(
            mobile: (context) => Column(
              children: [
                _buildRecordButton(context, l10n, isRecording),
                if (_audioPath != null) ...[
                  SizedBox(height: 12.h),
                  _buildPlayButton(context, l10n, isPlaying),
                ],
              ],
            ),
            tablet: (context) => Row(
              children: [
                Expanded(child: _buildRecordButton(context, l10n, isRecording)),
                if (_audioPath != null) ...[
                  SizedBox(width: 16.w),
                  Expanded(child: _buildPlayButton(context, l10n, isPlaying)),
                ],
              ],
            ),
            desktop: (context) => Row(
              children: [
                Expanded(child: _buildRecordButton(context, l10n, isRecording)),
                if (_audioPath != null) ...[
                  SizedBox(width: 24.w),
                  Expanded(child: _buildPlayButton(context, l10n, isPlaying)),
                ],
              ],
            ),
          ),
          
          // Audio visualization or status
          if (isRecording || _audioPath != null) ...[
            SizedBox(height: Responsive.getResponsiveSpacing(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            )),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    isRecording ? Icons.mic : Icons.audio_file,
                    color: isRecording 
                      ? AppColors.audioRecording
                      : AppColors.audioStopped,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      isRecording 
                        ? 'Recording in progress...'
                        : 'Audio recorded successfully',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (_audioPath != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _audioPath = null;
                        });
                        _audioController.stopPlayback();
                      },
                      icon: const Icon(Icons.delete_outline),
                      iconSize: 18.sp,
                    ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  /// Build record button
  Widget _buildRecordButton(BuildContext context, AppLocalizations l10n, bool isRecording) {
    return ElevatedButton.icon(
      onPressed: isRecording ? _stopRecording : _startRecording,
      icon: Icon(
        isRecording ? Icons.stop : Icons.mic,
        color: isRecording ? AppColors.error : AppColors.audioRecording,
      ),
      label: Text(
        isRecording ? l10n.stopRecording : l10n.recordVoice,
        style: TextStyle(
          fontSize: Responsive.getResponsiveFontSize(
            context,
            mobile: 14,
            tablet: 16,
            desktop: 18,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isRecording 
          ? AppColors.error.withValues(alpha: 0.1)
          : AppColors.audioRecording.withValues(alpha: 0.1),
        foregroundColor: isRecording ? AppColors.error : AppColors.audioRecording,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
      ),
    );
  }

  /// Build play button
  Widget _buildPlayButton(BuildContext context, AppLocalizations l10n, bool isPlaying) {
    return ElevatedButton.icon(
      onPressed: isPlaying ? _pauseAudio : _playAudio,
      icon: Icon(
        isPlaying ? Icons.pause : Icons.play_arrow,
        color: AppColors.audioPlaying,
      ),
      label: Text(
        isPlaying ? l10n.pauseAudio : l10n.playAudio,
        style: TextStyle(
          fontSize: Responsive.getResponsiveFontSize(
            context,
            mobile: 14,
            tablet: 16,
            desktop: 18,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.audioPlaying.withValues(alpha: 0.1),
        foregroundColor: AppColors.audioPlaying,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return ResponsiveBuilder(
      mobile: (context) => Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : Text(l10n.saveTask),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isSubmitting ? null : () => context.pop(),
              child: Text(l10n.cancel),
            ),
          ),
        ],
      ),
      tablet: (context) => Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _isSubmitting ? null : () => context.pop(),
              child: Text(l10n.cancel),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : Text(l10n.saveTask),
            ),
          ),
        ],
      ),
      desktop: (context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isSubmitting ? null : () => context.pop(),
            child: Text(l10n.cancel),
          ),
          SizedBox(width: 16.w),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            child: _isSubmitting
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.saveTask),
          ),
        ],
      ),
    );
  }

  /// Get priority color
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
    }
  }

  /// Get priority label
  String _getPriorityLabel(AppLocalizations l10n, TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return l10n.taskPriorityLow;
      case TaskPriority.medium:
        return l10n.taskPriorityMedium;
      case TaskPriority.high:
        return l10n.taskPriorityHigh;
    }
  }

  /// Select due date
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  /// Start recording audio
  Future<void> _startRecording() async {
    try {
      await _audioController.startRecording();
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to start recording: $e',
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    }
  }

  /// Stop recording audio
  Future<void> _stopRecording() async {
    try {
      await _audioController.stopRecording();
      
      setState(() {
        // AudioController should provide the recorded path
        _audioPath = 'recorded_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      });
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to stop recording: $e',
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    }
  }

  /// Play audio
  Future<void> _playAudio() async {
    if (_audioPath != null) {
      try {
        // Create a temporary AudioEntity for playback
        final audioEntity = AudioEntity(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          taskId: 'temp_task',
          fileName: _audioPath!,
          localPath: _audioPath!,
          fileSize: 0, // Will be determined during playback
          duration: const Duration(seconds: 0), // Will be determined during playback
          format: 'm4a',
          recordedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _audioController.playAudio(audioEntity);
      } catch (e) {
        if (mounted) {
          Get.snackbar(
            'Error',
            'Failed to play audio: $e',
            backgroundColor: AppColors.error.withValues(alpha: 0.9),
            colorText: Colors.white,
          );
        }
      }
    }
  }

  /// Pause audio
  Future<void> _pauseAudio() async {
    try {
      await _audioController.pausePlayback();
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to pause audio: $e',
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    }
  }

  /// Submit form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final task = TaskEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        audioPath: _audioPath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _taskController.createTask(task);

      if (mounted) {
        Get.snackbar(
          'Success',
          'Task created successfully!',
          backgroundColor: AppColors.success.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to create task: $e',
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
