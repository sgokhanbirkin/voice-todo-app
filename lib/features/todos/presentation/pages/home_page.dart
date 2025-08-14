import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../../../../product/widgets/app_scaffold.dart';
import '../../domain/task_entity.dart';

/// Home page widget
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Voice Todo',
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implement search functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // TODO: Implement filter functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // TODO: Navigate to settings
          },
        ),
      ],
      body: const _HomePageBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add task page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Home page body content
class _HomePageBody extends StatelessWidget {
  const _HomePageBody();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${controller.errorMessage.value}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.task_alt, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No tasks yet',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first task',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.filteredTasks.length,
            itemBuilder: (context, index) {
              final task = controller.filteredTasks[index];
              return _TaskCard(task: task);
            },
          ),
        );
      },
    );
  }
}

/// Task card widget
class _TaskCard extends StatelessWidget {
  final TaskEntity task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _PriorityIndicator(priority: task.priority),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.status == TaskStatus.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (task.dueDate != null)
              Text(
                'Due: ${_formatDate(task.dueDate!)}',
                style: TextStyle(
                  color: task.isOverdue ? Colors.red : Colors.grey,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.audioPath != null)
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  // TODO: Implement audio playback
                },
              ),
            IconButton(
              icon: Icon(
                task.isStarred ? Icons.star : Icons.star_border,
                color: task.isStarred ? Colors.amber : null,
              ),
              onPressed: () {
                // TODO: Toggle star status
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    // TODO: Navigate to edit task page
                    break;
                  case 'complete':
                    // TODO: Toggle completion status
                    break;
                  case 'delete':
                    // TODO: Show delete confirmation
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'complete',
                  child: Row(
                    children: [
                      Icon(
                        task.status == TaskStatus.completed
                            ? Icons.undo
                            : Icons.check,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        task.status == TaskStatus.completed
                            ? 'Mark Incomplete'
                            : 'Mark Complete',
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to task detail page
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Priority indicator widget
class _PriorityIndicator extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityIndicator({required this.priority});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late IconData icon;

    switch (priority) {
      case TaskPriority.high:
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        icon = Icons.remove;
        break;
      case TaskPriority.low:
        color = Colors.green;
        icon = Icons.keyboard_arrow_down;
        break;
    }

    return CircleAvatar(
      backgroundColor: color,
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }
}

// TODO: Implement search functionality
// TODO: Implement filter functionality
// TODO: Add task detail page navigation
// TODO: Implement audio playback
// TODO: Add task completion toggle
// TODO: Implement delete confirmation dialog
// TODO: Add task editing functionality
