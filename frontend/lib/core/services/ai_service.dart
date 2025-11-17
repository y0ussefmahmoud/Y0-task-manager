import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import '../models/task.dart';
import '../models/user.dart';

class AIService {
  static const List<String> _highPriorityKeywords = [
    'عاجل', 'مهم', 'ضروري', 'فوري', 'طارئ', 'urgent', 'important', 'asap'
  ];
  
  static const List<String> _mediumPriorityKeywords = [
    'متوسط', 'عادي', 'normal', 'medium', 'regular'
  ];
  
  static const List<String> _lowPriorityKeywords = [
    'بسيط', 'سهل', 'لاحقاً', 'low', 'simple', 'easy', 'later'
  ];

  /// تحليل الإنتاجية المحلي
  static ProductivityAnalysis analyzeProductivity(List<Task> tasks, User user) {
    final completedTasks = tasks.where((task) => task.isCompleted).toList();
    final pendingTasks = tasks.where((task) => !task.isCompleted).toList();
    
    // حساب معدل الإنجاز
    final completionRate = tasks.isNotEmpty ? completedTasks.length / tasks.length : 0.0;
    
    // تحليل الأنماط الزمنية
    final timePatterns = _analyzeTimePatterns(completedTasks);
    
    // تحليل الأولويات
    final priorityAnalysis = _analyzePriorityPatterns(tasks);
    
    // اقتراحات التحسين
    final suggestions = _generateImprovementSuggestions(
      completionRate, 
      timePatterns, 
      priorityAnalysis,
      pendingTasks
    );
    
    return ProductivityAnalysis(
      completionRate: completionRate,
      totalTasks: tasks.length,
      completedTasks: completedTasks.length,
      pendingTasks: pendingTasks.length,
      averageTasksPerDay: _calculateAverageTasksPerDay(tasks),
      mostProductiveHour: timePatterns['mostProductiveHour'] ?? 9,
      suggestions: suggestions,
      streakDays: user.streak,
      productivityScore: _calculateProductivityScore(completionRate, user.streak),
    );
  }

  /// اقتراح أولوية المهمة تلقائياً
  static String suggestTaskPriority(String title, String? description) {
    final text = '${title.toLowerCase()} ${description?.toLowerCase() ?? ''}';
    
    // البحث عن كلمات مفتاحية للأولوية العالية
    if (_highPriorityKeywords.any((keyword) => text.contains(keyword))) {
      return 'urgent';
    }
    
    // البحث عن كلمات مفتاحية للأولوية المنخفضة
    if (_lowPriorityKeywords.any((keyword) => text.contains(keyword))) {
      return 'low';
    }
    
    // البحث عن كلمات مفتاحية للأولوية المتوسطة
    if (_mediumPriorityKeywords.any((keyword) => text.contains(keyword))) {
      return 'medium';
    }
    
    // تحليل طول النص (المهام الطويلة عادة أكثر تعقيداً)
    if (text.length > 100) {
      return 'high';
    }
    
    return 'medium'; // افتراضي
  }

  /// تقدير الوقت المطلوب للمهمة
  static int estimateTaskDuration(String title, String? description, List<Task> historicalTasks) {
    final text = '${title.toLowerCase()} ${description?.toLowerCase() ?? ''}';
    
    // البحث عن مهام مشابهة في التاريخ
    final similarTasks = historicalTasks.where((task) {
      final taskText = '${task.title.toLowerCase()} ${task.description?.toLowerCase() ?? ''}';
      return _calculateTextSimilarity(text, taskText) > 0.3;
    }).toList();
    
    if (similarTasks.isNotEmpty) {
      final averageDuration = similarTasks
          .where((task) => task.actualDuration != null)
          .map((task) => task.actualDuration!)
          .fold(0, (sum, duration) => sum + duration) / 
          similarTasks.where((task) => task.actualDuration != null).length;
      
      return averageDuration.round();
    }
    
    // تقدير بناءً على طول النص والكلمات المفتاحية
    int baseDuration = 30; // 30 دقيقة افتراضي
    
    // زيادة الوقت بناءً على طول النص
    baseDuration += (text.length / 10).round();
    
    // زيادة الوقت للمهام المعقدة
    final complexKeywords = ['تطوير', 'برمجة', 'تصميم', 'تحليل', 'دراسة', 'بحث'];
    if (complexKeywords.any((keyword) => text.contains(keyword))) {
      baseDuration *= 2;
    }
    
    return baseDuration.clamp(15, 480); // بين 15 دقيقة و 8 ساعات
  }

  /// اقتراح أفضل وقت للعمل على المهمة
  static int suggestBestWorkTime(List<Task> historicalTasks) {
    final completedTasks = historicalTasks.where((task) => 
        task.isCompleted && task.completedAt != null).toList();
    
    if (completedTasks.isEmpty) return 9; // 9 صباحاً افتراضي
    
    // تحليل الساعات التي تم إنجاز المهام فيها
    final hourCounts = <int, int>{};
    
    for (final task in completedTasks) {
      final hour = task.completedAt!.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    // العثور على الساعة الأكثر إنتاجية
    final mostProductiveHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return mostProductiveHour;
  }

  /// توقع المهام المتأخرة
  static List<Task> predictOverdueTasks(List<Task> tasks) {
    final now = DateTime.now();
    final riskTasks = <Task>[];
    
    for (final task in tasks.where((t) => !t.isCompleted && t.dueDate != null)) {
      final daysUntilDue = task.dueDate!.difference(now).inDays;
      final estimatedDuration = task.estimatedDuration ?? 60;
      
      // إذا كان الوقت المتبقي أقل من الوقت المقدر للمهمة
      if (daysUntilDue <= 1 && estimatedDuration > 120) {
        riskTasks.add(task);
      }
      
      // إذا كانت المهمة عالية الأولوية ولم تبدأ بعد
      if (task.priority == 'urgent' && task.status == 'pending' && daysUntilDue <= 2) {
        riskTasks.add(task);
      }
    }
    
    return riskTasks;
  }

  // Helper methods
  static Map<String, dynamic> _analyzeTimePatterns(List<Task> completedTasks) {
    if (completedTasks.isEmpty) return {'mostProductiveHour': 9};
    
    final hourCounts = <int, int>{};
    
    for (final task in completedTasks.where((t) => t.completedAt != null)) {
      final hour = task.completedAt!.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    final mostProductiveHour = hourCounts.isNotEmpty
        ? hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 9;
    
    return {'mostProductiveHour': mostProductiveHour};
  }

  static Map<String, int> _analyzePriorityPatterns(List<Task> tasks) {
    final priorityCounts = <String, int>{};
    
    for (final task in tasks) {
      priorityCounts[task.priority] = (priorityCounts[task.priority] ?? 0) + 1;
    }
    
    return priorityCounts;
  }

  static List<String> _generateImprovementSuggestions(
    double completionRate,
    Map<String, dynamic> timePatterns,
    Map<String, int> priorityAnalysis,
    List<Task> pendingTasks,
  ) {
    final suggestions = <String>[];
    
    if (completionRate < 0.7) {
      suggestions.add('حاول تقسيم المهام الكبيرة إلى مهام أصغر');
      suggestions.add('ركز على إنجاز 3-5 مهام يومياً بدلاً من الكثير');
    }
    
    if (pendingTasks.where((t) => t.priority == 'urgent').length > 3) {
      suggestions.add('لديك الكثير من المهام العاجلة، حاول إعادة ترتيب الأولويات');
    }
    
    final mostProductiveHour = timePatterns['mostProductiveHour'] ?? 9;
    if (mostProductiveHour < 12) {
      suggestions.add('أنت أكثر إنتاجية في الصباح، جدول المهام المهمة صباحاً');
    } else {
      suggestions.add('أنت أكثر إنتاجية بعد الظهر، استغل هذا الوقت للمهام المعقدة');
    }
    
    return suggestions;
  }

  static double _calculateAverageTasksPerDay(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    
    final dates = tasks.map((t) => DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day))
        .toSet().length;
    
    return dates > 0 ? tasks.length / dates : 0.0;
  }

  static int _calculateProductivityScore(double completionRate, int streakDays) {
    final baseScore = (completionRate * 70).round();
    final streakBonus = (streakDays * 2).clamp(0, 30);
    
    return (baseScore + streakBonus).clamp(0, 100);
  }

  static double _calculateTextSimilarity(String text1, String text2) {
    final words1 = text1.split(' ').toSet();
    final words2 = text2.split(' ').toSet();
    
    final intersection = words1.intersection(words2).length;
    final union = words1.union(words2).length;
    
    return union > 0 ? intersection / union : 0.0;
  }
}

/// نموذج تحليل الإنتاجية
class ProductivityAnalysis {
  final double completionRate;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final double averageTasksPerDay;
  final int mostProductiveHour;
  final List<String> suggestions;
  final int streakDays;
  final int productivityScore;

  ProductivityAnalysis({
    required this.completionRate,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.averageTasksPerDay,
    required this.mostProductiveHour,
    required this.suggestions,
    required this.streakDays,
    required this.productivityScore,
  });
}
