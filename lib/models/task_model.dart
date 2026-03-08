import 'dart:convert';

enum TaskType { frontBurner, backBurner, kitchenSink, counterSpace }

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final TaskType type;
  final DateTime createdAt;
  final String? note;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.type = TaskType.kitchenSink,
    required this.createdAt,
    this.note,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    TaskType? type,
    DateTime? createdAt,
    String? note,
    bool clearNote = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      note: clearNote ? null : (note ?? this.note),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'type': type.index,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'],
      type: TaskType.values[map['type']],
      createdAt: DateTime.parse(map['createdAt']),
      note: map['note'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}
