part of 'task_detail_page.dart';

/// Form Widget'ları
extension _TaskDetailPageForm on _TaskDetailPageState {
  Widget _buildEditForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title field
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: l10n.title,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.titleRequired;
            }
            return null;
          },
        ),

        ResponsiveWidgets.verticalSpace(
          context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),

        // Description field
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: l10n.description,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 3,
        ),

        ResponsiveWidgets.verticalSpace(
          context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),

        // Priority selector
        _buildPrioritySelector(context),

        ResponsiveWidgets.verticalSpace(
          context,
          mobile: 16,
          tablet: 20,
          desktop: 24,
        ),

        // Due date selector
        _buildDueDateSelector(context),
      ],
    );
  }

  Widget _buildPrioritySelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.priority,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        ResponsiveWidgets.verticalSpace(
          context,
          mobile: 8,
          tablet: 12,
          desktop: 16,
        ),
        Wrap(
          spacing: Responsive.getResponsiveSpacing(
          context,
          mobile: 8,
          tablet: 12,
          desktop: 16,
        ),
          children: TaskPriority.values.map((priority) {
            final isSelected = _selectedPriority == priority;
            final color = _getPriorityColor(priority);

            return ChoiceChip(
              label: Text(_getPriorityText(priority)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _updatePriority(priority);
                }
              },
              backgroundColor: color.withValues(alpha: 0.1),
              selectedColor: color.withValues(alpha: 0.3),
              labelStyle: TextStyle(
                color: isSelected
                    ? color
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDueDateSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dueDate,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        ResponsiveWidgets.verticalSpace(
          context,
          mobile: 8,
          tablet: 12,
          desktop: 16,
        ),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    _updateDueDate(date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                                    ResponsiveWidgets.horizontalSpace(
                context,
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
              Text(
                        _selectedDueDate != null
                            ? _formatDate(_selectedDueDate!)
                            : l10n.selectDate,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_selectedDueDate != null) ...[
              ResponsiveWidgets.horizontalSpace(
                context,
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
              IconButton(
                onPressed: _clearDueDate,
                icon: const Icon(Icons.clear),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onErrorContainer,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
