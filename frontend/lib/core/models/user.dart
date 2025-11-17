import 'package:hive/hive.dart';

part 'user.g.dart';

/// نموذج المستخدم (User Model)
/// 
/// يمثل مستخدم التطبيق مع جميع بياناته:
/// - المعلومات الشخصية (الاسم، البريد، الصورة)
/// - الإعدادات (اللغة، المنطقة الزمنية، الثيم)
/// - نظام التحفيز (XP, Level, Streak)
/// - حالة الحساب (نشط، مفعّل)
/// 
/// يستخدم Hive للتخزين المحلي مع TypeAdapter
@HiveType(typeId: 2)
class User extends HiveObject {
  /// معرف المستخدم
  @HiveField(0)
  String id;

  /// اسم المستخدم
  @HiveField(1)
  String username;

  /// البريد الإلكتروني
  @HiveField(2)
  String email;

  /// الاسم الأول (اختياري)
  @HiveField(3)
  String? firstName;

  /// الاسم الأخير (اختياري)
  @HiveField(4)
  String? lastName;

  /// رابط صورة الحساب (اختياري)
  @HiveField(5)
  String? avatarUrl;

  /// المنطقة الزمنية
  @HiveField(6)
  String timezone;

  /// لغة التطبيق المفضلة
  @HiveField(7)
  String language;

  /// الثيم المفضل (light/dark)
  @HiveField(8)
  String theme;

  /// إجمالي نقاط الخبرة (XP)
  @HiveField(9)
  int totalXp;

  /// المستوى الحالي (كل 1000 XP = مستوى واحد)
  @HiveField(10)
  int level;

  /// عدد الأيام المتتالية
  @HiveField(11)
  int streakDays;

  /// آخر نشاط للمستخدم (لتحديث الـ streak)
  @HiveField(12)
  DateTime lastActivity;

  /// حالة الحساب نشط/غير نشط
  @HiveField(13)
  bool isActive;

  /// تفعيل البريد الإلكتروني
  @HiveField(14)
  bool emailVerified;

  /// وقت إنشاء الحساب
  @HiveField(15)
  DateTime createdAt;

  /// آخر وقت تحديث
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

  /// تحويل المستخدم إلى JSON
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

  /// إنشاء مستخدم من JSON
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

  /// إنشاء نسخة من المستخدم مع تعديل بعض الحقول
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
  /// الاسم الكامل للمستخدم
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  
  /// اسم العرض (الاسم الكامل إن وجد وإلا اسم المستخدم)
  String get displayName => fullName.isNotEmpty ? fullName : username;
  
  /// اسم بديل للتوافق
  String get name => displayName; // Alias for compatibility
  
  /// XP كاسم بديل للتوافق
  int get xp => totalXp; // Alias for compatibility
  
  /// Streak كاسم بديل للتوافق
  int get streak => streakDays; // Alias for compatibility

  /// XP المطلوب للوصول للمستوى التالي
  int get xpForNextLevel => (level * 1000) - totalXp;

  /// نسبة التقدم في المستوى الحالي (0.0 - 1.0)
  double get levelProgress => (totalXp % 1000) / 1000.0;

  /// إضافة XP وحساب المستوى الجديد (كل 1000 XP = مستوى)
  void addXp(int xp) {
    totalXp += xp;
    final newLevel = (totalXp ~/ 1000) + 1;
    if (newLevel > level) {
      level = newLevel;
    }
    updatedAt = DateTime.now();
  }

  /// تحديث عداد الأيام المتتالية
  void updateStreak() {
    final today = DateTime.now();
    final lastActivityDate = DateTime(
      lastActivity.year,
      lastActivity.month,
      lastActivity.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);

    /// Calculates the difference in days between the current date and the
    /// last activity date.
    final daysDifference = todayDate.difference(lastActivityDate).inDays;

    /// Continues the streak if the last activity was yesterday.
    if (daysDifference == 1) {
      streakDays += 1;
    }
    /// Resets the streak if the last activity was more than a day ago.
    else if (daysDifference > 1) {
      streakDays = 1;
    }
    /// Does not change the streak if the last activity was today.

    lastActivity = today;
    updatedAt = DateTime.now();
  }
}
