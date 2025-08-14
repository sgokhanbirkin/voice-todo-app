part of 'add_task_page.dart';

/// Action buttons component for form submission and cancellation
/// Provides responsive layout and loading states
class _AddTaskActionButtons extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _AddTaskActionButtons({
    required this.isSubmitting,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ResponsiveBuilder(
      mobile: (context) => Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: isSubmitting
                  ? const CircularProgressIndicator()
                  : Text(l10n.saveTask),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: isSubmitting ? null : onCancel,
              child: Text(l10n.cancel),
            ),
          ),
        ],
      ),
      tablet: (context) => Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: isSubmitting ? null : onCancel,
              child: Text(l10n.cancel),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: isSubmitting
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
            onPressed: isSubmitting ? null : onCancel,
            child: Text(l10n.cancel),
          ),
          SizedBox(width: 16.w),
          ElevatedButton(
            onPressed: isSubmitting ? null : onSubmit,
            child: isSubmitting
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
}
