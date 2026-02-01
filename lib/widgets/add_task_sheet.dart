import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/models/task_priority.dart';
import 'package:to_do_list/models/task_repeat.dart';
import 'package:to_do_list/providers/task_provider.dart';
import 'package:uuid/uuid.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  TaskRepeat _repeat = TaskRepeat.none;
  DateTime? _dueDate;
  String? _category;

  final List<String> _categories = ['Work', 'Personal', 'School', 'Health', 'Finance'];

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    HapticFeedback.lightImpact();

    final task = Task(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
      category: _category,
      repeat: _repeat,
      createdAt: DateTime.now(),
    );

    ref.read(taskProvider.notifier).addTask(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Task Title',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 18),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Add notes...',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14),
              ),
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildActionChip(
                  icon: LucideIcons.calendar,
                  label: _dueDate == null ? 'Set Date' : 'Today',
                  isSelected: _dueDate != null,
                  onTap: () => setState(() => _dueDate = _dueDate == null ? DateTime.now() : null),
                ),
                _buildPriorityChip(),
                _buildRepeatChip(),
                _buildCategoryChip(),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({required IconData icon, required String label, required bool isSelected, required VoidCallback onTap}) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      selected: isSelected,
      onSelected: (_) {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }

  Widget _buildPriorityChip() {
    return PopupMenuButton<TaskPriority>(
      onSelected: (p) {
        HapticFeedback.selectionClick();
        setState(() => _priority = p);
      },
      itemBuilder: (context) => TaskPriority.values
          .map((p) => PopupMenuItem(value: p, child: Text(p.label)))
          .toList(),
      child: Chip(
        label: Text(_priority.label),
        avatar: Icon(LucideIcons.flag, size: 16, color: _getPriorityColor(_priority)),
      ),
    );
  }

  Widget _buildRepeatChip() {
    return PopupMenuButton<TaskRepeat>(
      onSelected: (r) {
        HapticFeedback.selectionClick();
        setState(() => _repeat = r);
      },
      itemBuilder: (context) => TaskRepeat.values
          .map((r) => PopupMenuItem(value: r, child: Text(r.label)))
          .toList(),
      child: Chip(
        label: Text(_repeat == TaskRepeat.none ? 'No Repeat' : _repeat.label),
        avatar: const Icon(LucideIcons.repeat, size: 16),
      ),
    );
  }

  Widget _buildCategoryChip() {
    return PopupMenuButton<String?>(
      onSelected: (c) {
        HapticFeedback.selectionClick();
        setState(() => _category = c);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('No Category')),
        ..._categories.map((c) => PopupMenuItem(value: c, child: Text(c))),
      ],
      child: Chip(
        label: Text(_category ?? 'Category'),
        avatar: const Icon(LucideIcons.tag, size: 16),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high: return Colors.red;
      case TaskPriority.medium: return Colors.orange;
      case TaskPriority.low: return Colors.blueGrey;
    }
  }
}
