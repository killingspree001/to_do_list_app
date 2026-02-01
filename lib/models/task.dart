import 'package:hive/hive.dart';
import 'package:to_do_list/models/task_priority.dart';
import 'package:to_do_list/models/task_repeat.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  TaskPriority priority;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  String? category;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  TaskRepeat repeat;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.category,
    required this.createdAt,
    this.repeat = TaskRepeat.none,
  });

  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? dueDate,
    String? category,
    TaskRepeat? repeat,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      createdAt: createdAt,
      repeat: repeat ?? this.repeat,
    );
  }
}
