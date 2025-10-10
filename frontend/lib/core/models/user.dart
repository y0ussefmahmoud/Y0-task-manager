import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 2)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? firstName;

  @HiveField(4)
  String? lastName;

  @HiveField(5)
  String? avatarUrl;

  @HiveField(6)
  String timezone;

  @HiveField(7)
  String language;

  @HiveField(8)
  String theme;

  @HiveField(9)
  int totalXp;

  @HiveField(10)
  int level;

  @HiveField(11)
  int streakDays;

  @HiveField(12)
  DateTime lastActivity;

  @HiveField(13)
  bool isActive;

  @HiveField(14)
  bool emailVerified;

  @HiveField(15)
  DateTime createdAt;

  @HiveField(16)
  DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.timezone = 'UTC',
    this.language = 'ar',
    this.theme = 'light',
    this.totalXp = 0,
    this.level = 1,
    this.streakDays = 0,
    DateTime? lastActivity,
    this.isActive = true,
    this.emailVerified = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : lastActivity = lastActivity ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'timezone': timezone,
      'language': language,
      'theme': theme,
      'totalXp': totalXp,
      'level': level,
      'streakDays': streakDays,
      'lastActivity': lastActivity.toIso8601String(),
      'isActive': isActive,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatarUrl: json['avatarUrl'],
      timezone: json['timezone'] ?? 'UTC',
      language: json['language'] ?? 'ar',
      theme: json['theme'] ?? 'light',
      totalXp: json['totalXp'] ?? 0,
      level: json['level'] ?? 1,
      streakDays: json['streakDays'] ?? 0,
      lastActivity: json['lastActivity'] != null 
          ? DateTime.parse(json['lastActivity']) 
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
      emailVerified: json['emailVerified'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  // Copy with
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? timezone,
    String? language,
    String? theme,
    int? totalXp,
    int? level,
    int? streakDays,
    DateTime? lastActivity,
    bool? isActive,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
      lastActivity: lastActivity ?? this.lastActivity,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Helper methods
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  
  String get displayName => fullName.isNotEmpty ? fullName : username;

  int get xpForNextLevel => (level * 1000) - totalXp;

  double get levelProgress => (totalXp % 1000) / 1000.0;

  void addXp(int xp) {
    totalXp += xp;
    final newLevel = (totalXp ~/ 1000) + 1;
    if (newLevel > level) {
      level = newLevel;
    }
    updatedAt = DateTime.now();
  }

  void updateStreak() {
    final today = DateTime.now();
    final lastActivityDate = DateTime(
      lastActivity.year,
      lastActivity.month,
      lastActivity.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);
    
    final daysDifference = todayDate.difference(lastActivityDate).inDays;
    
    if (daysDifference == 1) {
      // Continue streak
      streakDays += 1;
    } else if (daysDifference > 1) {
      // Reset streak
      streakDays = 1;
    }
    // If same day, don't change streak
    
    lastActivity = today;
    updatedAt = DateTime.now();
  }
}
