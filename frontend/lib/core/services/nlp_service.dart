import 'package:intl/intl.dart';

class NLPService {
  // كلمات مفتاحية للتواريخ باللغة العربية
  static const Map<String, int> _arabicDays = {
    'اليوم': 0,
    'غداً': 1,
    'غدا': 1,
    'بعد غد': 2,
    'بعد غدا': 2,
    'الأحد': 7,
    'الاثنين': 1,
    'الثلاثاء': 2,
    'الأربعاء': 3,
    'الخميس': 4,
    'الجمعة': 5,
    'السبت': 6,
  };

  static const Map<String, int> _arabicMonths = {
    'يناير': 1, 'كانون الثاني': 1,
    'فبراير': 2, 'شباط': 2,
    'مارس': 3, 'آذار': 3,
    'أبريل': 4, 'نيسان': 4,
    'مايو': 5, 'أيار': 5,
    'يونيو': 6, 'حزيران': 6,
    'يوليو': 7, 'تموز': 7,
    'أغسطس': 8, 'آب': 8,
    'سبتمبر': 9, 'أيلول': 9,
    'أكتوبر': 10, 'تشرين الأول': 10,
    'نوفمبر': 11, 'تشرين الثاني': 11,
    'ديسمبر': 12, 'كانون الأول': 12,
  };

  static const Map<String, String> _priorityKeywords = {
    // عالي/عاجل
    'عاجل': 'urgent',
    'مهم جداً': 'urgent',
    'مهم جدا': 'urgent',
    'ضروري': 'urgent',
    'فوري': 'urgent',
    'طارئ': 'urgent',
    'urgent': 'urgent',
    'critical': 'urgent',
    'asap': 'urgent',
    
    // عالي
    'مهم': 'high',
    'عالي': 'high',
    'أولوية': 'high',
    'اولوية': 'high',
    'high': 'high',
    'important': 'high',
    
    // متوسط
    'متوسط': 'medium',
    'عادي': 'medium',
    'normal': 'medium',
    'medium': 'medium',
    'regular': 'medium',
    
    // منخفض
    'بسيط': 'low',
    'سهل': 'low',
    'لاحقاً': 'low',
    'لاحقا': 'low',
    'low': 'low',
    'simple': 'low',
    'easy': 'low',
    'later': 'low',
  };

  /// استخراج التاريخ من النص
  static DateTime? extractDate(String text) {
    final lowerText = text.toLowerCase();
    final now = DateTime.now();

    // البحث عن التواريخ النسبية (اليوم، غداً، إلخ)
    for (final entry in _arabicDays.entries) {
      if (lowerText.contains(entry.key)) {
        if (entry.value == 0) {
          return now; // اليوم
        } else if (entry.value <= 6) {
          return now.add(Duration(days: entry.value)); // غداً، بعد غد
        } else {
          // أيام الأسبوع
          final targetWeekday = entry.value == 7 ? 7 : entry.value;
          final currentWeekday = now.weekday;
          int daysToAdd = targetWeekday - currentWeekday;
          if (daysToAdd <= 0) daysToAdd += 7; // الأسبوع القادم
          return now.add(Duration(days: daysToAdd));
        }
      }
    }

    // البحث عن تواريخ محددة (رقم + شهر)
    final dateRegex = RegExp(r'(\d{1,2})\s*([أ-ي]+)');
    final match = dateRegex.firstMatch(lowerText);
    if (match != null) {
      final day = int.tryParse(match.group(1)!);
      final monthName = match.group(2)!;
      
      if (day != null && _arabicMonths.containsKey(monthName)) {
        final month = _arabicMonths[monthName]!;
        try {
          var date = DateTime(now.year, month, day);
          // إذا كان التاريخ في الماضي، اجعله في السنة القادمة
          if (date.isBefore(now)) {
            date = DateTime(now.year + 1, month, day);
          }
          return date;
        } catch (e) {
          // تاريخ غير صحيح
          return null;
        }
      }
    }

    // البحث عن تواريخ بصيغة رقمية (dd/mm أو dd-mm)
    final numericDateRegex = RegExp(r'(\d{1,2})[\/\-](\d{1,2})');
    final numericMatch = numericDateRegex.firstMatch(text);
    if (numericMatch != null) {
      final day = int.tryParse(numericMatch.group(1)!);
      final month = int.tryParse(numericMatch.group(2)!);
      
      if (day != null && month != null && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
        try {
          var date = DateTime(now.year, month, day);
          if (date.isBefore(now)) {
            date = DateTime(now.year + 1, month, day);
          }
          return date;
        } catch (e) {
          return null;
        }
      }
    }

    // البحث عن كلمات تدل على فترات زمنية
    if (lowerText.contains('الأسبوع القادم') || lowerText.contains('الاسبوع القادم')) {
      return now.add(const Duration(days: 7));
    }
    
    if (lowerText.contains('الشهر القادم') || lowerText.contains('الشهر الجاي')) {
      return DateTime(now.year, now.month + 1, now.day);
    }

    // البحث عن "خلال X أيام"
    final daysRegex = RegExp(r'خلال\s*(\d+)\s*أيام?');
    final daysMatch = daysRegex.firstMatch(lowerText);
    if (daysMatch != null) {
      final days = int.tryParse(daysMatch.group(1)!);
      if (days != null) {
        return now.add(Duration(days: days));
      }
    }

    return null;
  }

  /// استخراج الأولوية من النص
  static String extractPriority(String text) {
    final lowerText = text.toLowerCase();
    
    // البحث عن كلمات الأولوية بترتيب الأهمية
    for (final entry in _priorityKeywords.entries) {
      if (lowerText.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // تحليل إضافي بناءً على علامات الترقيم والكلمات
    if (lowerText.contains('!!!') || lowerText.contains('🔥') || lowerText.contains('⚡')) {
      return 'urgent';
    }
    
    if (lowerText.contains('!!') || lowerText.contains('❗')) {
      return 'high';
    }
    
    if (lowerText.contains('!')) {
      return 'medium';
    }
    
    return 'medium'; // افتراضي
  }

  /// استخراج الفئة من النص
  static String? extractCategory(String text, List<String> availableCategories) {
    final lowerText = text.toLowerCase();
    
    // البحث المباشر في الفئات المتاحة
    for (final category in availableCategories) {
      if (lowerText.contains(category.toLowerCase())) {
        return category;
      }
    }
    
    // كلمات مفتاحية للفئات الشائعة
    final categoryKeywords = {
      'عمل': ['عمل', 'وظيفة', 'مكتب', 'اجتماع', 'مشروع'],
      'شخصي': ['شخصي', 'بيت', 'منزل', 'عائلة', 'أسرة'],
      'دراسة': ['دراسة', 'تعلم', 'كتاب', 'امتحان', 'واجب'],
      'صحة': ['صحة', 'رياضة', 'طبيب', 'دواء', 'تمرين'],
      'تسوق': ['تسوق', 'شراء', 'سوق', 'متجر'],
    };
    
    for (final entry in categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          return entry.key;
        }
      }
    }
    
    return null;
  }

  /// استخراج الوقت من النص
  static DateTime? extractTime(String text) {
    final timeRegex = RegExp(r'(\d{1,2}):(\d{2})\s*(ص|م|am|pm)?');
    final match = timeRegex.firstMatch(text.toLowerCase());
    
    if (match != null) {
      final hour = int.tryParse(match.group(1)!);
      final minute = int.tryParse(match.group(2)!);
      final period = match.group(3);
      
      if (hour != null && minute != null) {
        int finalHour = hour;
        
        // تحويل 12-hour إلى 24-hour
        if (period == 'م' || period == 'pm') {
          if (hour != 12) finalHour += 12;
        } else if (period == 'ص' || period == 'am') {
          if (hour == 12) finalHour = 0;
        }
        
        final now = DateTime.now();
        var timeDate = DateTime(now.year, now.month, now.day, finalHour, minute);
        
        // إذا كان الوقت في الماضي، اجعله غداً
        if (timeDate.isBefore(now)) {
          timeDate = timeDate.add(const Duration(days: 1));
        }
        
        return timeDate;
      }
    }
    
    // البحث عن أوقات نسبية
    final now = DateTime.now();
    if (text.toLowerCase().contains('صباحاً') || text.toLowerCase().contains('صباحا')) {
      return DateTime(now.year, now.month, now.day, 9, 0);
    }
    
    if (text.toLowerCase().contains('ظهراً') || text.toLowerCase().contains('ظهرا')) {
      return DateTime(now.year, now.month, now.day, 12, 0);
    }
    
    if (text.toLowerCase().contains('مساءً') || text.toLowerCase().contains('مساءا')) {
      return DateTime(now.year, now.month, now.day, 18, 0);
    }
    
    return null;
  }

  /// تحليل شامل للنص واستخراج جميع المعلومات
  static TaskAnalysis analyzeText(String text, List<String> availableCategories) {
    return TaskAnalysis(
      originalText: text,
      extractedDate: extractDate(text),
      extractedTime: extractTime(text),
      extractedPriority: extractPriority(text),
      extractedCategory: extractCategory(text, availableCategories),
      cleanedTitle: _cleanTitle(text),
    );
  }

  /// تنظيف عنوان المهمة من الكلمات المفتاحية
  static String _cleanTitle(String text) {
    String cleaned = text;
    
    // إزالة كلمات التاريخ والوقت
    final wordsToRemove = [
      ...['اليوم', 'غداً', 'غدا', 'بعد غد', 'بعد غدا'],
      ..._arabicDays.keys,
      ..._arabicMonths.keys,
      ..._priorityKeywords.keys,
      ...['صباحاً', 'صباحا', 'ظهراً', 'ظهرا', 'مساءً', 'مساءا'],
      ...['خلال', 'أيام', 'يوم', 'الأسبوع', 'القادم', 'الشهر'],
    ];
    
    for (final word in wordsToRemove) {
      cleaned = cleaned.replaceAll(RegExp(word, caseSensitive: false), '');
    }
    
    // إزالة الأرقام والرموز الزائدة
    cleaned = cleaned.replaceAll(RegExp(r'\d{1,2}[\/\-]\d{1,2}'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\d{1,2}:\d{2}'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[!]{2,}'), '');
    
    // تنظيف المسافات الزائدة
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned.isNotEmpty ? cleaned : text;
  }
}

/// نموذج تحليل النص
class TaskAnalysis {
  final String originalText;
  final DateTime? extractedDate;
  final DateTime? extractedTime;
  final String extractedPriority;
  final String? extractedCategory;
  final String cleanedTitle;

  TaskAnalysis({
    required this.originalText,
    this.extractedDate,
    this.extractedTime,
    required this.extractedPriority,
    this.extractedCategory,
    required this.cleanedTitle,
  });

  /// دمج التاريخ والوقت
  DateTime? get combinedDateTime {
    if (extractedDate == null && extractedTime == null) return null;
    
    if (extractedDate != null && extractedTime != null) {
      return DateTime(
        extractedDate!.year,
        extractedDate!.month,
        extractedDate!.day,
        extractedTime!.hour,
        extractedTime!.minute,
      );
    }
    
    return extractedDate ?? extractedTime;
  }

  @override
  String toString() {
    return 'TaskAnalysis(title: $cleanedTitle, date: $extractedDate, time: $extractedTime, priority: $extractedPriority, category: $extractedCategory)';
  }
}
