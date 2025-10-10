import 'package:hive/hive.dart';

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
  String priority; // low, medium, high, urgent

  @HiveField(4)
  String status; // pending, in_progress, completed, cancelled

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  DateTime? reminderDate;

  @HiveField(7)
  int? estimatedDuration; // in minutes

  @HiveField(8)
  int? actualDuration; // in minutes

  @HiveField(9)
  int xpReward;

  @HiveField(10)
  bool isRecurring;

  @HiveField(11)
  String? recurringPattern;

  @HiveField(12)
  List<String> tags;

  @HiveField(13)
  String? categoryId;

  @HiveField(14)
  DateTime? completedAt;

  @HiveField(15)
  DateTime createdAt;

  @HiveField(16)
  DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.priority = 'medium',
    this.status = 'pending',
    this.dueDate,
    this.reminderDate,
    this.estimatedDuration,
    this.actualDuration,
    this.xpReward = 10,
    this.isRecurring = false,
    this.recurringPattern,
    this.tags = const [],
    this.categoryId,
    this.completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'dueDate': dueDate?.toIso8601String(),
      'reminderDate': reminderDate?.toIso8601String(),
      'estimatedDuration': estimatedDuration,
      'actualDuration': actualDuration,
      'xpReward': xpReward,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'tags': tags,
      'categoryId': categoryId,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      reminderDate: json['reminderDate'] != null ? DateTime.parse(json['reminderDate']) : null,
      estimatedDuration: json['estimatedDuration'],
      actualDuration: json['actualDuration'],
      xpReward: json['xpReward'] ?? 10,
      isRecurring: json['isRecurring'] ?? false,
      recurringPattern: json['recurringPattern'],
      tags: List<String>.from(json['tags'] ?? []),
      categoryId: json['categoryId'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  // Copy with
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? dueDate,
    DateTime? reminderDate,
    int? estimatedDuration,
    int? actualDuration,
    int? xpReward,
    bool? isRecurring,
    String? recurringPattern,
    List<String>? tags,
    String? categoryId,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      reminderDate: reminderDate ?? this.reminderDate,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      xpReward: xpReward ?? this.xpReward,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      tags: tags ?? this.tags,
      categoryId: categoryId ?? this.categoryId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Helper methods
  bool get isCompleted => status == 'completed';
  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!) && !isCompleted;
  
  int get daysUntilDue {
    if (dueDate == null) return 0;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  int get priorityScore {
    switch (priority) {
      case 'urgent':
        return 4;
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 2;
    }
  }
}
