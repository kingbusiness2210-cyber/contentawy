import 'package:uuid/uuid.dart';

enum TaskPriority { high, medium, low }

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime dueDate;
  final bool isDone;
  final TaskPriority priority;
  final DateTime createdAt;

  TaskItem({
    String? id,
    required this.title,
    this.description = '',
    this.category = 'عام',
    DateTime? dueDate,
    this.isDone = false,
    this.priority = TaskPriority.medium,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        dueDate = dueDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    bool? isDone,
    TaskPriority? priority,
    DateTime? createdAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'dueDate': dueDate.toIso8601String(),
      'isDone': isDone,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    TaskPriority prio;
    try {
      prio = TaskPriority.values
          .byName(json['priority'] as String? ?? 'medium');
    } catch (_) {
      prio = TaskPriority.medium;
    }

    return TaskItem(
      id: json['id'] as String?,
      title: json['title'] as String? ?? 'مهمة تسويقية',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'عام',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      isDone: json['isDone'] as bool? ?? false,
      priority: prio,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
