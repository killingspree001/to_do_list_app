import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/models/task_priority.dart';
import 'package:to_do_list/models/task_repeat.dart';

final taskProvider = NotifierProvider<TaskNotifier, List<Task>>(TaskNotifier.new);

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
final categoryFilterProvider = NotifierProvider<CategoryFilterNotifier, String?>(CategoryFilterNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  set state(String value) => super.state = value;
}

class CategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  set state(String? value) => super.state = value;
}

final filteredTasksProvider = Provider((ref) {
  final tasks = ref.watch(taskProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final category = ref.watch(categoryFilterProvider);

  return tasks.where((task) {
    final matchesQuery = task.title.toLowerCase().contains(query) ||
                        (task.description?.toLowerCase().contains(query) ?? false);
    final matchesCategory = category == null || task.category == category;
    return matchesQuery && matchesCategory;
  }).toList();
});


class TaskNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    _init();
    return [];
  }

  static const String _boxName = 'tasks';

  Future<void> _init() async {
    final box = await Hive.openBox<Task>(_boxName);
    state = box.values.toList();
  }

  Future<void> addTask(Task task) async {
    final box = Hive.box<Task>(_boxName);
    await box.put(task.id, task);
    state = box.values.toList();
  }

  Future<void> toggleTask(String id) async {
    final box = Hive.box<Task>(_boxName);
    final task = box.get(id);
    if (task != null) {
      final wasCompleted = task.isCompleted;
      task.isCompleted = !task.isCompleted;
      await task.save();

      // Handle repeating tasks when marked complete
      if (!wasCompleted && task.isCompleted && task.repeat != TaskRepeat.none) {
        _rescheduleTask(task);
      }

      state = box.values.toList();
    }
  }

  void _rescheduleTask(Task task) {
    if (task.dueDate == null) return;

    DateTime nextDate;
    switch (task.repeat) {
      case TaskRepeat.daily:
        nextDate = task.dueDate!.add(const Duration(days: 1));
        break;
      case TaskRepeat.weekly:
        nextDate = task.dueDate!.add(const Duration(days: 7));
        break;
      default:
        return;
    }

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: task.title,
      description: task.description,
      priority: task.priority,
      dueDate: nextDate,
      category: task.category,
      createdAt: DateTime.now(),
      repeat: task.repeat,
    );
    addTask(newTask);
  }

  Future<Task?> deleteTask(String id) async {
    final box = Hive.box<Task>(_boxName);
    final task = box.get(id);
    if (task != null) {
      final taskCopy = task.copyWith();
      await box.delete(id);
      state = box.values.toList();
      return taskCopy;
    }
    return null;
  }

  Future<void> updateTask(Task task) async {
    final box = Hive.box<Task>(_boxName);
    await box.put(task.id, task);
    state = box.values.toList();
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final items = [...state];
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    state = items;
  }
}

// Smart list providers utilizing filtered tasks
final todayTasksProvider = Provider((ref) {
  final tasks = ref.watch(filteredTasksProvider);
  final now = DateTime.now();
  return tasks.where((task) {
    if (task.isCompleted) return false;
    if (task.dueDate == null) return false;
    return task.dueDate!.year == now.year &&
        task.dueDate!.month == now.month &&
        task.dueDate!.day == now.day;
  }).toList();
});

final completedTodayProvider = Provider((ref) {
  final tasks = ref.watch(filteredTasksProvider);
  final now = DateTime.now();
  return tasks.where((task) {
    if (!task.isCompleted) return false;
    if (task.dueDate == null) return false;
    return task.dueDate!.year == now.year &&
        task.dueDate!.month == now.month &&
        task.dueDate!.day == now.day;
  }).toList();
});

final upcomingTasksProvider = Provider((ref) {
  final tasks = ref.watch(filteredTasksProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return tasks.where((task) => 
    task.dueDate != null && task.dueDate!.isAfter(today.add(const Duration(days: 1)))
  ).toList();
});

final overdueTasksProvider = Provider((ref) {
  final tasks = ref.watch(filteredTasksProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return tasks.where((task) => 
    !task.isCompleted && task.dueDate != null && task.dueDate!.isBefore(today)
  ).toList();
});

