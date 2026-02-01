import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:to_do_list/providers/task_provider.dart';
import 'package:to_do_list/widgets/task_tile.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasks = ref.watch(todayTasksProvider);
    final overdueTasks = ref.watch(overdueTasksProvider);
    final completedTasks = ref.watch(completedTodayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(LucideIcons.search, size: 20),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (overdueTasks.isNotEmpty) ...[
                  _SliverHeader(title: 'Overdue', color: Colors.red),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => TaskTile(task: overdueTasks[index]),
                      childCount: overdueTasks.length,
                    ),
                  ),
                ],
                _SliverHeader(title: 'Today'),
                if (todayTasks.isEmpty && overdueTasks.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('Enjoy your day! No tasks left.', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => TaskTile(task: todayTasks[index]),
                      childCount: todayTasks.length,
                    ),
                  ),
                if (completedTasks.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: Divider()),
                  _SliverHeader(title: 'Completed Today', color: Colors.grey),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => TaskTile(task: completedTasks[index]),
                      childCount: completedTasks.length,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverHeader extends StatelessWidget {
  final String title;
  final Color? color;
  const _SliverHeader({required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}
