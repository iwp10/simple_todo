import 'package:hive_flutter/hive_flutter.dart';

class Task extends HiveObject {
  Task({
    required this.title,
    required this.createdAt,
    this.isCompleted = false,
  });

  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  DateTime createdAt;
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final fieldId = reader.readByte();
      final value = reader.read();
      fields[fieldId] = value;
    }

    return Task(
      title: fields[0] as String,
      isCompleted: fields[1] as bool,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(2)
      ..write(obj.createdAt);
  }
}
