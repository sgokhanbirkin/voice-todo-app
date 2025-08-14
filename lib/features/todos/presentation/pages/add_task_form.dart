part of 'add_task_page.dart';

/// Add task form widget with full functionality
/// Manages form state and coordinates between different form sections
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
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: Responsive.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Form Fields (title, description, due date)
            _AddTaskFormFields(
              titleController: _titleController,
              descriptionController: _descriptionController,
              selectedDueDate: _selectedDueDate,
              onDueDateChanged: (date) {
                setState(() {
                  _selectedDueDate = date;
                });
              },
              taskController: _taskController,
            ),

            SizedBox(
              height: Responsive.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),

            // Priority Selection
            _AddTaskPrioritySelector(
              selectedPriority: _selectedPriority,
              onPriorityChanged: (TaskPriority priority) {
                setState(() {
                  _selectedPriority = priority;
                });
              },
            ),

            SizedBox(
              height: Responsive.getResponsiveSpacing(
                context,
                mobile: 24,
                tablet: 32,
                desktop: 40,
              ),
            ),

            // Voice Recording Section
            _AddTaskAudioRecorder(
              audioPath: _audioPath,
              onAudioPathChanged: (path) {
                setState(() {
                  _audioPath = path;
                });
              },
              audioController: _audioController,
            ),

            SizedBox(
              height: Responsive.getResponsiveSpacing(
                context,
                mobile: 32,
                tablet: 40,
                desktop: 48,
              ),
            ),

            // Action Buttons
            _AddTaskActionButtons(
              isSubmitting: _isSubmitting,
              onSubmit: _submitForm,
              onCancel: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  /// Submit form and create task
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
