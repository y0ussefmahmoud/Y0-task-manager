import 'package:flutter/foundation.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/services/nlp_service.dart';
import '../../../core/models/task.dart';
import '../../../core/models/user.dart';
import '../../tasks/providers/task_provider.dart';
import '../../categories/providers/category_provider.dart';

/// Provider لإدارة ميزات الذكاء الاصطناعي في التطبيق
/// 
/// يوفر هذا الـ Provider:
/// - تحليل الإنتاجية والإحصائيات
/// - الأوامر الصوتية (Speech-to-Text)
/// - النطق (Text-to-Speech)
/// - اقتراح الأولوية والمدة للمهام
/// - تحليل النص الذكي (NLP)
/// - إنشاء مهام ذكية من النص
class AIProvider extends ChangeNotifier {
  ProductivityAnalysis? _currentAnalysis;
  bool _isAnalyzing = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String? _error;
  
  // Getters
  ProductivityAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isAnalyzing => _isAnalyzing;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String? get error => _error;
  bool get isAIReady => SpeechService.isAvailable;

  /// تهيئة خدمات الذكاء الاصطناعي
  /// تهيئة خدمات الذكاء الاصطناعي (Speech Service)
Future<bool> initializeAI() async {
    try {
      final speechInitialized = await SpeechService.initialize();
      if (!speechInitialized) {
        _setError('فشل في تهيئة خدمة الكلام');
        return false;
      }
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('خطأ في تهيئة الذكاء الاصطناعي: $e');
      return false;
    }
  }

  /// تحليل الإنتاجية
  /// تحليل إنتاجية المستخدم بناءً على المهام (عدد منجز، متأخر، أفضل أوقات)
Future<void> analyzeProductivity(List<Task> tasks, User user) async {
    _setAnalyzing(true);
    _clearError();
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // محاكاة المعالجة
      _currentAnalysis = AIService.analyzeProductivity(tasks, user);
      notifyListeners();
    } catch (e) {
      _setError('فشل في تحليل الإنتاجية: $e');
    } finally {
      _setAnalyzing(false);
    }
  }

  /// اقتراح أولوية المهمة
  /// اقتراح أولوية المهمة بناءً على العنوان والوصف
String suggestPriority(String title, String? description) {
    try {
      return AIService.suggestTaskPriority(title, description);
    } catch (e) {
      debugPrint('Error suggesting priority: $e');
      return 'medium';
    }
  }

  /// تقدير مدة المهمة
  /// تقدير مدة المهمة بناءً على المهام السابقة
/// يستخدم تاريخ المهام لتقريب الزمن المتوقع
int estimateDuration(String title, String? description, List<Task> historicalTasks) {
    try {
      return AIService.estimateTaskDuration(title, description, historicalTasks);
    } catch (e) {
      debugPrint('Error estimating duration: $e');
      return 60; // ساعة واحدة افتراضي
    }
  }

  /// اقتراح أفضل وقت للعمل
  /// اقتراح أفضل وقت للعمل بناءً على عادات المستخدم
int suggestBestWorkTime(List<Task> tasks) {{
    try {
      return AIService.suggestBestWorkTime(tasks);
    } catch (e) {
      debugPrint('Error suggesting work time: $e');
      return 9; // 9 صباحاً افتراضي
    }
  }

  /// توقع المهام المتأخرة
  /// توقع المهام المتأخرة قريباً بالاعتماد على الأنماط
List<Task> predictOverdueTasks(List<Task> tasks) {
    try {
      return AIService.predictOverdueTasks(tasks);
    } catch (e) {
      debugPrint('Error predicting overdue tasks: $e');
      return [];
    }
  }

  /// بدء الاستماع للأوامر الصوتية
  /// بدء الاستماع للأوامر الصوتية وتحويلها لنص ثم تحليلها لأمر مهمة
Future<TaskVoiceCommand?> startVoiceCommand() async {
    if (_isListening) return null;
    
    _setListening(true);
    _clearError();
    
    try {
      final recognizedText = await SpeechService.speechToText();
      
      if (recognizedText != null && recognizedText.isNotEmpty) {
        final command = SpeechService.parseVoiceCommand(recognizedText);
        return command;
      }
      
      return null;
    } catch (e) {
      _setError('خطأ في التعرف على الصوت: $e');
      return null;
    } finally {
      _setListening(false);
    }
  }

  /// إيقاف الاستماع
  /// إيقاف الاستماع للصوت
Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      await SpeechService.stopListening();
    } catch (e) {
      debugPrint('Error stopping listening: $e');
    } finally {
      _setListening(false);
    }
  }

  /// نطق النص
  /// نطق النص باستخدام Text-to-Speech
Future<void> speak(String text) async {
    if (_isSpeaking) return;
    
    _setSpeaking(true);
    _clearError();
    
    try {
      await SpeechService.textToSpeech(text);
    } catch (e) {
      _setError('خطأ في النطق: $e');
    } finally {
      _setSpeaking(false);
    }
  }

  /// إيقاف النطق
  /// إيقاف النطق
Future<void> stopSpeaking() async {
    if (!_isSpeaking) return;
    
    try {
      await SpeechService.stopSpeaking();
    } catch (e) {
      debugPrint('Error stopping speech: $e');
    } finally {
      _setSpeaking(false);
    }
  }

  /// تحليل النص الذكي
  /// تحليل النص لاستخراج الأولوية، التاريخ، والفئة باستخدام NLP
/// يستخدم قائمة الفئات المتاحة لمطابقة الأسماء
TaskAnalysis analyzeTaskText(String text, List<String> availableCategories) {
    try {
      return NLPService.analyzeText(text, availableCategories);
    } catch (e) {
      debugPrint('Error analyzing text: $e');
      return TaskAnalysis(
        originalText: text,
        extractedPriority: 'medium',
        cleanedTitle: text,
      );
    }
  }

  /// إنشاء مهمة ذكية من النص
  /// إنشاء مهمة ذكية من نص حر:
/// - تحليل النص عبر NLP لاستخراج بيانات المهمة
/// - تقدير المدة بالاعتماد على مهام سابقة
/// - اختيار الفئة المناسبة إن وجدت
/// - إنشاء المهمة وجدولة تذكير قبل ساعة
Future<bool> createSmartTask(
    String text,
    TaskProvider taskProvider,
    CategoryProvider categoryProvider,
  ) async {
    try {
      final categories = categoryProvider.categories.map((c) => c.name).toList();
      // تحليل النص واستخراج المعلومات الدلالية (NLP)
      final analysis = analyzeTaskText(text, categories);
      
      // البحث عن معرف الفئة
      String? categoryId;
      if (analysis.extractedCategory != null) {
        final category = categoryProvider.categories
            .where((c) => c.name == analysis.extractedCategory)
            .firstOrNull;
        categoryId = category?.id;
      }
      
      // تقدير المدة
      // تقدير المدة بالاعتماد على مهام تاريخية ذات صلة
      final estimatedDuration = estimateDuration(
        analysis.cleanedTitle,
        null,
        taskProvider.allTasks,
      );
      
      // إنشاء المهمة
      final success = await taskProvider.addTask(
        title: analysis.cleanedTitle,
        priority: analysis.extractedPriority,
        dueDate: analysis.combinedDateTime,
        reminderDate: analysis.combinedDateTime?.subtract(const Duration(hours: 1)),
        estimatedDuration: estimatedDuration,
        categoryId: categoryId,
      );
      
      if (success) {
        // نطق تأكيد
        await speak('تم إنشاء المهمة: ${analysis.cleanedTitle}');
      }
      
      return success;
    } catch (e) {
      _setError('فشل في إنشاء المهمة الذكية: $e');
      return false;
    }
  }

  /// الحصول على اقتراحات ذكية
  /// توليد اقتراحات ذكية مبنية على حالة المستخدم ومهامه الحالية
List<String> getSmartSuggestions(List<Task> tasks, User user) {
    try {
      // إذا توفرت نتيجة تحليل حديثة يتم استخدامها مباشرة
      if (_currentAnalysis != null) {
        return _currentAnalysis!.suggestions;
      }
      
      // اقتراحات عامة
      final suggestions = <String>[];
      
      final pendingTasks = tasks.where((t) => !t.isCompleted).length;
      if (pendingTasks > 10) {
        suggestions.add('لديك الكثير من المهام المعلقة، حاول التركيز على الأهم');
      }
      
      final urgentTasks = tasks.where((t) => t.priority == 'urgent' && !t.isCompleted).length;
      if (urgentTasks > 3) {
        suggestions.add('لديك $urgentTasks مهام عاجلة، ابدأ بها فوراً');
      }
      
      if (user.streak > 7) {
        suggestions.add('ممتاز! لديك سلسلة ${user.streak} أيام، حافظ على هذا الإنجاز');
      }
      
      return suggestions;
    } catch (e) {
      debugPrint('Error getting suggestions: $e');
      return ['استمر في العمل الجيد!'];
    }
  }

  /// تنظيف الموارد
  Future<void> dispose() async {
    await SpeechService.dispose();
    super.dispose();
  }

  // Helper methods
  void _setAnalyzing(bool analyzing) {
    _isAnalyzing = analyzing;
    notifyListeners();
  }

  void _setListening(bool listening) {
    _isListening = listening;
    notifyListeners();
  }

  void _setSpeaking(bool speaking) {
    _isSpeaking = speaking;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
