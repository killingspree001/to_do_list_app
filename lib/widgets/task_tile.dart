import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/models/task_priority.dart';
import 'package:to_do_list/providers/task_provider.dart';
import 'package:to_do_list/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class TaskTile extends ConsumerWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(task.id),
      background: _buildSwipeBackground(
        color: AppTheme.accentGreen,
        alignment: Alignment.centerLeft,
        icon: LucideIcons.check,
        label: 'Complete',
      ),
      secondaryBackground: _buildSwipeBackground(
        color: AppTheme.dangerRed,
        alignment: Alignment.centerRight,
        icon: LucideIcons.trash2,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          ref.read(taskProvider.notifier).toggleTask(task.id);
          return false; // Don't remove from list widget, let provider update
        } else {
          final delete = await _showDeleteConfirmation(context);
          if (delete == true) {
            final deletedTask = await ref.read(taskProvider.notifier).deleteTask(task.id);
            if (deletedTask != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "${deletedTask.title}"'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () => ref.read(taskProvider.notifier).addTask(deletedTask),
                  ),
                ),
              );
            }
            return true;
          }
          return false;
        }

      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: InkWell(
          onTap: () {
             // Future: Open task details
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: IconButton(
                icon: Icon(
                  task.isCompleted ? LucideIcons.checkCircle2 : LucideIcons.circle,
                  color: task.isCompleted ? AppTheme.accentGreen : Colors.grey,
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(taskProvider.notifier).toggleTask(task.id);
                },
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  color: task.isCompleted ? Colors.grey : null,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   if (task.description != null && !task.isCompleted)
                    Text(
                      task.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  Row(
                    children: [
                      if (task.category != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            task.category!,
                            style: const TextStyle(fontSize: 10, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (task.dueDate != null)
                        Text(
                          DateFormat('MMM d, h:mm a').format(task.dueDate!),
                          style: TextStyle(
                            color: _getDateColor(task.dueDate!),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              trailing: _PriorityIndicator(priority: task.priority),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSwipeBackground({
    required Color color,
    required Alignment alignment,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          if (alignment == Alignment.centerRight) Icon(icon, color: Colors.white),
        ],
      ),
    );
  }

  Color _getDateColor(DateTime date) {
    final now = DateTime.now();
    if (date.isBefore(now)) return AppTheme.dangerRed;
    if (date.difference(now).inDays < 1) return AppTheme.warningOrange;
    return Colors.grey;
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: AppTheme.dangerRed)),
          ),
        ],
      ),
    );
  }
}

class _PriorityIndicator extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityIndicator({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case TaskPriority.high: color = AppTheme.dangerRed; break;
      case TaskPriority.medium: color = AppTheme.warningOrange; break;
      case TaskPriority.low: color = Colors.blueGrey; break;
    }

    return Container(
      width: 4,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
