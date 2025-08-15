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
        _buildModernTitleField(context, l10n),

        SizedBox(
          height: Responsive.getResponsiveSpacing(
            context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
          ),
        ),

        // Description Field
        _buildModernDescriptionField(context, l10n),

        SizedBox(
          height: Responsive.getResponsiveSpacing(
            context,
            mobile: 20,
            tablet: 24,
            desktop: 28,
          ),
        ),

        // Due Date Selection
        _buildModernDueDateSection(context, l10n),
      ],
    );
  }

  /// Build modern task title field
  Widget _buildModernTitleField(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          Responsive.getResponsiveSpacing(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: titleController,
        decoration: InputDecoration(
          labelText: l10n.taskTitle,
          hintText: l10n.taskTitleHint,
          prefixIcon: Padding(
            padding: EdgeInsets.only(
              left: Responsive.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(
                Responsive.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.title,
                color: Theme.of(context).colorScheme.primary,
                size: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 20,
                  tablet: 22,
                  desktop: 24,
                ),
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(
            Responsive.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
          ),
        ),
        style: TextStyle(
          fontSize: Responsive.getResponsiveFontSize(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
          fontWeight: FontWeight.w500,
        ),
        validator: taskController.validateTaskTitle,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  /// Build modern description field
  Widget _buildModernDescriptionField(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          Responsive.getResponsiveSpacing(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: descriptionController,
        decoration: InputDecoration(
          labelText: l10n.taskDescription,
          hintText: l10n.taskDescriptionHint,
          prefixIcon: Padding(
            padding: EdgeInsets.only(
              left: Responsive.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(
                Responsive.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.description,
                color: Theme.of(context).colorScheme.secondary,
                size: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 20,
                  tablet: 22,
                  desktop: 24,
                ),
              ),
            ),
          ),
          border: InputBorder.none,
          alignLabelWithHint: true,
          contentPadding: EdgeInsets.all(
            Responsive.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
          ),
        ),
        style: TextStyle(
          fontSize: Responsive.getResponsiveFontSize(
            context,
            mobile: 14,
            tablet: 16,
            desktop: 18,
          ),
          fontWeight: FontWeight.w400,
        ),
        maxLines: Responsive.isDesktop(context) ? 4 : 3,
        validator: taskController.validateTaskDescription,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textInputAction: TextInputAction.newline,
      ),
    );
  }

  /// Build modern due date selection section
  Widget _buildModernDueDateSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          margin: EdgeInsets.only(
            bottom: Responsive.getResponsiveSpacing(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Theme.of(context).colorScheme.tertiary,
                size: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 20,
                  tablet: 22,
                  desktop: 24,
                ),
              ),
              SizedBox(
                width: Responsive.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                ),
              ),
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        // Modern Date Picker Container
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectDueDate(context),
            borderRadius: BorderRadius.circular(
              Responsive.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(
                Responsive.getResponsiveSpacing(
                  context,
                  mobile: 20,
                  tablet: 24,
                  desktop: 28,
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(
                  Responsive.getResponsiveSpacing(
                    context,
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  ),
                ),
                border: Border.all(
                  color: selectedDueDate != null
                      ? Theme.of(
                          context,
                        ).colorScheme.tertiary.withValues(alpha: 0.3)
                      : Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                  width: selectedDueDate != null ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Calendar Icon Container
                  Container(
                    padding: EdgeInsets.all(
                      Responsive.getResponsiveSpacing(
                        context,
                        mobile: 10,
                        tablet: 12,
                        desktop: 14,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: selectedDueDate != null
                          ? Theme.of(
                              context,
                            ).colorScheme.tertiary.withValues(alpha: 0.15)
                          : Theme.of(
                              context,
                            ).colorScheme.tertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: Responsive.getResponsiveSpacing(
                        context,
                        mobile: 22,
                        tablet: 24,
                        desktop: 26,
                      ),
                    ),
                  ),

                  SizedBox(
                    width: Responsive.getResponsiveSpacing(
                      context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                  ),

                  // Date Text
                  Expanded(
                    child: Text(
                      selectedDueDate != null
                          ? '${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}'
                          : l10n.selectDueDateHint,
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
                        fontWeight: selectedDueDate != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),

                  // Clear Button
                  if (selectedDueDate != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: () => onDueDateChanged(null),
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          size: Responsive.getResponsiveSpacing(
                            context,
                            mobile: 18,
                            tablet: 20,
                            desktop: 22,
                          ),
                        ),
                        padding: EdgeInsets.all(
                          Responsive.getResponsiveSpacing(
                            context,
                            mobile: 6,
                            tablet: 8,
                            desktop: 10,
                          ),
                        ),
                        constraints: BoxConstraints(
                          minWidth: Responsive.getResponsiveSpacing(
                            context,
                            mobile: 32,
                            tablet: 36,
                            desktop: 40,
                          ),
                          minHeight: Responsive.getResponsiveSpacing(
                            context,
                            mobile: 32,
                            tablet: 36,
                            desktop: 40,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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
