import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  static final SpeechToText _speechToText = SpeechToText();
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  /// تهيئة خدمة الكلام
  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // طلب إذن الميكروفون
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        debugPrint('Microphone permission denied');
        return false;
      }

      // تهيئة Speech to Text
      final speechAvailable = await _speechToText.initialize(
        onError: (error) => debugPrint('Speech recognition error: $error'),
        onStatus: (status) => debugPrint('Speech recognition status: $status'),
      );

      if (!speechAvailable) {
        debugPrint('Speech recognition not available');
        return false;
      }

      // تهيئة Text to Speech
      await _flutterTts.setLanguage('ar-SA'); // العربية السعودية
      await _flutterTts.setSpeechRate(0.8); // سرعة متوسطة
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // تعيين محرك الكلام للأندرويد
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _flutterTts.setEngine('com.google.android.tts');
      }

      _isInitialized = true;
      debugPrint('Speech service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize speech service: $e');
      return false;
    }
  }

  /// تحويل الكلام إلى نص
  static Future<String?> speechToText({
    Duration timeout = const Duration(seconds: 30),
    String locale = 'ar-SA',
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return null;
    }

    try {
      if (!_speechToText.isAvailable) {
        debugPrint('Speech recognition not available');
        return null;
      }

      String recognizedText = '';
      bool isListening = false;

      await _speechToText.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
          isListening = result.finalResult;
        },
        listenFor: timeout,
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: locale,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );

      // انتظار انتهاء التسجيل
      int waitTime = 0;
      while (_speechToText.isListening && waitTime < timeout.inSeconds) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitTime++;
      }

      await _speechToText.stop();

      if (recognizedText.isNotEmpty) {
        debugPrint('Recognized text: $recognizedText');
        return recognizedText;
      }

      return null;
    } catch (e) {
      debugPrint('Speech to text error: $e');
      await _speechToText.stop();
      return null;
    }
  }

  /// تحويل النص إلى كلام
  static Future<bool> textToSpeech(String text, {String language = 'ar-SA'}) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      await _flutterTts.setLanguage(language);
      await _flutterTts.speak(text);
      return true;
    } catch (e) {
      debugPrint('Text to speech error: $e');
      return false;
    }
  }

  /// إيقاف التحدث
  static Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('Stop speaking error: $e');
    }
  }

  /// إيقاف الاستماع
  static Future<void> stopListening() async {
    try {
      await _speechToText.stop();
    } catch (e) {
      debugPrint('Stop listening error: $e');
    }
  }

  /// التحقق من توفر خدمة الكلام
  static bool get isAvailable => _speechToText.isAvailable;

  /// التحقق من حالة الاستماع
  static bool get isListening => _speechToText.isListening;

  /// الحصول على اللغات المتاحة للتعرف على الكلام
  static Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _speechToText.locales();
  }

  /// الحصول على اللغات المتاحة للنطق
  static Future<List<dynamic>> getAvailableLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _flutterTts.getLanguages();
  }

  /// معالجة الأوامر الصوتية للمهام
  static TaskVoiceCommand? parseVoiceCommand(String text) {
    final lowerText = text.toLowerCase().trim();

    // أوامر إضافة المهام
    final addKeywords = ['أضف', 'اضف', 'أنشئ', 'انشئ', 'جديد', 'مهمة'];
    if (addKeywords.any((keyword) => lowerText.contains(keyword))) {
      // استخراج عنوان المهمة
      String taskTitle = text;
      for (final keyword in addKeywords) {
        taskTitle = taskTitle.replaceAll(RegExp(keyword, caseSensitive: false), '').trim();
      }
      
      return TaskVoiceCommand(
        action: VoiceCommandAction.addTask,
        taskTitle: taskTitle.isNotEmpty ? taskTitle : 'مهمة جديدة',
        originalText: text,
      );
    }

    // أوامر البحث
    final searchKeywords = ['ابحث', 'ابحث عن', 'اعرض', 'أين'];
    if (searchKeywords.any((keyword) => lowerText.contains(keyword))) {
      String searchQuery = text;
      for (final keyword in searchKeywords) {
        searchQuery = searchQuery.replaceAll(RegExp(keyword, caseSensitive: false), '').trim();
      }
      
      return TaskVoiceCommand(
        action: VoiceCommandAction.searchTasks,
        searchQuery: searchQuery,
        originalText: text,
      );
    }

    // أوامر عرض الإحصائيات
    final statsKeywords = ['إحصائيات', 'احصائيات', 'تقرير', 'نتائج'];
    if (statsKeywords.any((keyword) => lowerText.contains(keyword))) {
      return TaskVoiceCommand(
        action: VoiceCommandAction.showStats,
        originalText: text,
      );
    }

    // أوامر عامة غير مفهومة
    return TaskVoiceCommand(
      action: VoiceCommandAction.unknown,
      originalText: text,
    );
  }

  /// تنظيف الموارد
  static Future<void> dispose() async {
    try {
      await _speechToText.stop();
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('Dispose speech service error: $e');
    }
  }
}

/// أنواع الأوامر الصوتية
enum VoiceCommandAction {
  addTask,
  searchTasks,
  showStats,
  unknown,
}

/// نموذج الأمر الصوتي
class TaskVoiceCommand {
  final VoiceCommandAction action;
  final String? taskTitle;
  final String? searchQuery;
  final String originalText;

  TaskVoiceCommand({
    required this.action,
    this.taskTitle,
    this.searchQuery,
    required this.originalText,
  });

  @override
  String toString() {
    return 'TaskVoiceCommand(action: $action, taskTitle: $taskTitle, searchQuery: $searchQuery)';
  }
}
