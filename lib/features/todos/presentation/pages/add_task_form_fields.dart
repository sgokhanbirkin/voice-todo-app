part of 'add_task_page.dart';

/// Form fields component for task title, description, and due date
/// Handles input validation and date selection
class _AddTaskFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final DateTime? selectedDueDate;
  final Function(DateTime?) onDueDateChanged;
  final TaskController taskController;

  const _AddTaskFormFields({
    required this.titleController,
    required this.descriptionController,
    required this.selectedDueDate,
    required this.onDueDateChanged,
    required this.taskController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task Title Field
        _buildTitleField(context, l10n),

        SizedBox(
          height: Responsive.getResponsiveSpacing(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
        ),

        // Description Field
        _buildDescriptionField(context, l10n),

        SizedBox(
          height: Responsive.getResponsiveSpacing(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
        ),

        // Due Date Selection
        _buildDueDateSection(context, l10n),
      ],
    );
  }

  /// Build task title field
  Widget _buildTitleField(BuildContext context, AppLocalizations l10n) {
    return TextFormField(
      controller: titleController,
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
      validator: taskController.validateTaskTitle,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.next,
    );
  }

  /// Build description field
  Widget _buildDescriptionField(BuildContext context, AppLocalizations l10n) {
    return TextFormField(
      controller: descriptionController,
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
      validator: taskController.validateTaskDescription,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.newline,
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
        SizedBox(
          height: Responsive.getResponsiveSpacing(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          ),
        ),
        InkWell(
          onTap: () => _selectDueDate(context),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.5),
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
                    selectedDueDate != null
                        ? '${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}'
                        : 'Select due date (optional)',
                    style: TextStyle(
                      color: selectedDueDate != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: Responsive.getResponsiveFontSize(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                    ),
                  ),
                ),
                if (selectedDueDate != null)
                  IconButton(
                    onPressed: () => onDueDateChanged(null),
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

  /// Select due date
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != selectedDueDate) {
      onDueDateChanged(picked);
    }
  }
}
