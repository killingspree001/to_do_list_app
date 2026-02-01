import 'package:hive/hive.dart';

part 'task_repeat.g.dart';

@HiveType(typeId: 2)
enum TaskRepeat {
  @HiveField(0)
  none,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  custom,
}

extension TaskRepeatExtension on TaskRepeat {
  String get label {
    switch (this) {
      case TaskRepeat.none: return 'None';
      case TaskRepeat.daily: return 'Daily';
      case TaskRepeat.weekly: return 'Weekly';
      case TaskRepeat.custom: return 'Custom';
    }
  }
}
