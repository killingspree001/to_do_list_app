// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_repeat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskRepeatAdapter extends TypeAdapter<TaskRepeat> {
  @override
  final int typeId = 2;

  @override
  TaskRepeat read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskRepeat.none;
      case 1:
        return TaskRepeat.daily;
      case 2:
        return TaskRepeat.weekly;
      case 3:
        return TaskRepeat.custom;
      default:
        return TaskRepeat.none;
    }
  }

  @override
  void write(BinaryWriter writer, TaskRepeat obj) {
    switch (obj) {
      case TaskRepeat.none:
        writer.writeByte(0);
        break;
      case TaskRepeat.daily:
        writer.writeByte(1);
        break;
      case TaskRepeat.weekly:
        writer.writeByte(2);
        break;
      case TaskRepeat.custom:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskRepeatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
