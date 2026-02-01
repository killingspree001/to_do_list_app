import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:to_do_list/models/task_priority.dart';
import 'package:to_do_list/providers/task_provider.dart';
import 'package:to_do_list/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/logo.png',
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.checkCircle, size: 80, color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'To-Do List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Appearance'),

          ListTile(
            leading: const Icon(LucideIcons.moon),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                ref.read(themeProvider.notifier).setTheme(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),

          _buildSectionHeader('Data Management'),
          ListTile(
            leading: const Icon(LucideIcons.download),
            title: const Text('Export Tasks (CSV)'),
            onTap: () => _exportTasks(context, ref),
          ),
          ListTile(
            leading: const Icon(LucideIcons.trash2, color: Colors.red),
            title: const Text('Clear Completed Tasks', style: TextStyle(color: Colors.red)),
            onTap: () => _clearCompleted(context, ref),
          ),
          _buildSectionHeader('About'),
          const ListTile(
            title: Text('App Version'),
            trailing: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Future<void> _exportTasks(BuildContext context, WidgetRef ref) async {
    final tasks = ref.read(taskProvider);
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tasks to export')),
      );
      return;
    }

    String csvData = 'ID,Title,Completed,Priority,Due Date,Category\n';
    for (final task in tasks) {
      csvData += '${task.id},"${task.title}",${task.isCompleted},${task.priority.label},${task.dueDate},${task.category}\n';
    }

    await Share.share(csvData, subject: 'My Tasks Export');
  }

  Future<void> _clearCompleted(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed?'),
        content: const Text('This will remove all completed tasks permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final tasks = ref.read(taskProvider);
      for (final task in tasks) {
        if (task.isCompleted) {
          ref.read(taskProvider.notifier).deleteTask(task.id);
        }
      }
    }
  }
}
