import 'package:hive/hive.dart';

part 'task.g.dart';

/// نموذج المهمة (Task Model)
/// 
/// يمثل مهمة واحدة في التطبيق مع جميع خصائصها:
/// - المعلومات الأساسية (العنوان، الوصف)
/// - الأولوية والحالة
/// - التواريخ (الإنشاء، الاستحقاق، الإكمال)
/// - نظام التحفيز (XP Reward)
/// - التكرار والعلامات
/// 
/// يستخدم Hive للتخزين المحلي مع TypeAdapter
@HiveType(typeId: 0)
class Task extends HiveObject {
  /// معرف المهمة الفريد
  @HiveField(0)
  String id;

  /// عنوان المهمة
  @HiveField(1)
  String title;

  /// وصف المهمة (اختياري)
  @HiveField(2)
  String? description;

  /// أولوية المهمة: low, medium, high, urgent
  @HiveField(3)
  String priority; // low, medium, high, urgent

  /// حالة المهمة: pending, in_progress, completed, cancelled
  @HiveField(4)
  String status; // pending, in_progress, completed, cancelled

  /// تاريخ الاستحقاق (اختياري)
  @HiveField(5)
  DateTime? dueDate;

  /// تاريخ ووقت التذكير (اختياري)
  @HiveField(6)
  DateTime? reminderDate;

  /// المدة المقدرة بالدقائق (اختياري)
  @HiveField(7)
  int? estimatedDuration; // in minutes

  /// المدة الفعلية بالدقائق (اختياري)
  @HiveField(8)
  int? actualDuration; // in minutes

  /// نقاط الخبرة (XP) المكتسبة عند الإكمال
  @HiveField(9)
  int xpReward;

  /// هل المهمة متكررة؟
  @HiveField(10)
  bool isRecurring;

  /// نمط التكرار (مثال: daily/weekly) إن وجِد
  @HiveField(11)
  String? recurringPattern;

  /// العلامات المرتبطة بالمهمة
  @HiveField(12)
  List<String> tags;

  /// معرف الفئة المرتبطة (اختياري)
  @HiveField(13)
  String? categoryId;

  /// وقت الإكمال (يُعين عند اكتمال المهمة)
  @HiveField(14)
  DateTime? completedAt;

  /// وقت الإنشاء
  @HiveField(15)
  DateTime createdAt;

  /// آخر وقت تحديث
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

  /// تحويل المهمة إلى JSON للإرسال للـ API
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

  /// إنشاء مهمة من JSON المستلم من الـ API
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

  /// إنشاء نسخة من المهمة مع تعديل بعض الحقول
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
  /// هل المهمة مكتملة؟ (status == 'completed')
  bool get isCompleted => status == 'completed';
  /// هل المهمة متأخرة؟ (dueDate في الماضي وغير مكتملة)
  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!) && !isCompleted;
  
  /// عدد الأيام المتبقية حتى موعد الاستحقاق
  int get daysUntilDue {
    if (dueDate == null) return 0;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  /// تحويل الأولوية إلى قيمة رقمية للترتيب (urgent=4, high=3, medium=2, low=1)
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
