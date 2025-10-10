import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String color; // Hex color code

  @HiveField(3)
  String icon; // Icon name

  @HiveField(4)
  String? description;

  @HiveField(5)
  bool isDefault;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    this.color = '#6366F1',
    this.icon = 'folder',
    this.description,
    this.isDefault = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'description': description,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? '#6366F1',
      icon: json['icon'] ?? 'folder',
      description: json['description'],
      isDefault: json['isDefault'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  // Copy with
  Category copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
    String? description,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Default categories
  static List<Category> getDefaultCategories() {
    return [
      Category(
        id: 'work',
        name: 'العمل',
        color: '#EF4444',
        icon: 'work',
        description: 'مهام متعلقة بالعمل والوظيفة',
        isDefault: true,
      ),
      Category(
        id: 'study',
        name: 'الدراسة',
        color: '#3B82F6',
        icon: 'school',
        description: 'مهام تعليمية ودراسية',
        isDefault: true,
      ),
      Category(
        id: 'health',
        name: 'الصحة',
        color: '#10B981',
        icon: 'favorite',
        description: 'مهام متعلقة بالصحة واللياقة',
        isDefault: true,
      ),
      Category(
        id: 'family',
        name: 'الأسرة',
        color: '#F59E0B',
        icon: 'family_restroom',
        description: 'مهام عائلية واجتماعية',
        isDefault: true,
      ),
      Category(
        id: 'personal',
        name: 'شخصي',
        color: '#8B5CF6',
        icon: 'person',
        description: 'مهام شخصية متنوعة',
        isDefault: true,
      ),
    ];
  }
}
