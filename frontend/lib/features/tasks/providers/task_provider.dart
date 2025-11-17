import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/task.dart';
import '../../../core/services/notification_service.dart';

/// Provider لإدارة حالة المهام في التطبيق
/// 
/// يوفر هذا الـ Provider جميع العمليات المتعلقة بالمهام:
/// - إضافة، تعديل، حذف المهام
/// - الفلترة والترتيب
/// - البحث والإحصائيات
/// - التكامل مع Hive للتخزين المحلي
/// - جدولة الإشعارات
class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String _sortBy = 'priority'; // priority, dueDate, createdAt
  String _filterStatus = 'all'; // all, pending, in_progress, completed
  String _filterPriority = 'all'; // all, low, medium, high, urgent
  String? _filterCategory;

  // Getters
  List<Task> get tasks => _getFilteredAndSortedTasks();
  List<Task> get allTasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sortBy => _sortBy;
  String get filterStatus => _filterStatus;
  String get filterPriority => _filterPriority;
  String? get filterCategory => _filterCategory;

  // Statistics
  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasks => _tasks.where((task) => task.status == 'pending').length;
  int get inProgressTasks => _tasks.where((task) => task.status == 'in_progress').length;
  int get overdueTasks => _tasks.where((task) => task.isOverdue).length;
  
  double get completionRate => totalTasks > 0 ? completedTasks / totalTasks : 0.0;

  /// تحميل المهام من Hive عند بدء التطبيق وتحديث الحالة
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      await _loadTasksFromHive();
    } catch (e) {
      _setError('فشل في تحميل المهام');
      debugPrint('Task initialization error: $e');
    }
    
    _setLoading(false);
  }

  /// إضافة مهمة جديدة مع جدولة الإشعار إذا كان هناك `reminderDate`
  Future<bool> addTask({
    required String title,
    String? description,
    String priority = 'medium',
    DateTime? dueDate,
    DateTime? reminderDate,
    int? estimatedDuration,
    List<String> tags = const [],
    String? categoryId,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final task = Task(
        id: const Uuid().v4(),
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        reminderDate: reminderDate,
        estimatedDuration: estimatedDuration,
        tags: tags,
        categoryId: categoryId,
      );

      _tasks.add(task);
      await _saveTasksToHive();
      
      // Schedule notification if reminder is set
      if (reminderDate != null) {
        await NotificationService.showTaskReminder(
          id: task.id.hashCode,
          title: 'تذكير: ${task.title}',
          body: task.description ?? 'حان وقت العمل على هذه المهمة',
          scheduledDate: reminderDate,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل في إضافة المهمة');
      debugPrint('Add task error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تحديث مهمة موجودة وتحديث الإشعار إذا تغيّر `reminderDate`
  /// إذا تم إكمال المهمة يتم تعيين `completedAt` تلقائياً
  Future<bool> updateTask(String taskId, {
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? dueDate,
    DateTime? reminderDate,
    int? estimatedDuration,
    int? actualDuration,
    List<String>? tags,
    String? categoryId,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) {
        _setError('المهمة غير موجودة');
        return false;
      }

      final oldTask = _tasks[taskIndex];
      final updatedTask = oldTask.copyWith(
        title: title,
        description: description,
        priority: priority,
        status: status,
        dueDate: dueDate,
        reminderDate: reminderDate,
        estimatedDuration: estimatedDuration,
        actualDuration: actualDuration,
        tags: tags,
        categoryId: categoryId,
        completedAt: status == 'completed' && !oldTask.isCompleted 
            ? DateTime.now() 
            : oldTask.completedAt,
      );

      _tasks[taskIndex] = updatedTask;
      await _saveTasksToHive();
      
      // Update notification
      await NotificationService.cancelNotification(oldTask.id.hashCode);
      if (reminderDate != null && status != 'completed') {
        await NotificationService.showTaskReminder(
          id: updatedTask.id.hashCode,
          title: 'تذكير: ${updatedTask.title}',
          body: updatedTask.description ?? 'حان وقت العمل على هذه المهمة',
          scheduledDate: reminderDate,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل في تحديث المهمة');
      debugPrint('Update task error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// حذف مهمة وإلغاء أي إشعار مجدول خاص بها
  Future<bool> deleteTask(String taskId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) {
        _setError('المهمة غير موجودة');
        return false;
      }

      final task = _tasks[taskIndex];
      _tasks.removeAt(taskIndex);
      await _saveTasksToHive();
      
      // Cancel notification
      await NotificationService.cancelNotification(task.id.hashCode);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل في حذف المهمة');
      debugPrint('Delete task error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تحديد المهمة كمكتملة عبر تحديث حالتها إلى `completed`
  Future<bool> completeTask(String taskId) async {
    return await updateTask(taskId, status: 'completed');
  }

  /// تبديل حالة إكمال المهمة بين مكتملة/غير مكتملة
  Future<bool> toggleTaskCompletion(String taskId) async {
    final task = getTaskById(taskId);
    if (task == null) return false;
    final newStatus = task.isCompleted ? 'pending' : 'completed';
    return await updateTask(taskId, status: newStatus);
  }

  /// جلب مهمة عبر المعرف
  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (_) {
      return null;
    }
  }

  /// نسخ مهمة مع إضافة "(نسخة)" إلى العنوان والاحتفاظ بالحقول الأخرى
  Future<bool> duplicateTask(String taskId) async {
    final originalTask = getTaskById(taskId);
    if (originalTask == null) return false;

    return await addTask(
      title: '${originalTask.title} (نسخة)',
      description: originalTask.description,
      priority: originalTask.priority,
      dueDate: originalTask.dueDate,
      reminderDate: originalTask.reminderDate,
      estimatedDuration: originalTask.estimatedDuration,
      tags: originalTask.tags,
      categoryId: originalTask.categoryId,
    );
  }

  /// البحث في العنوان والوصف والعلامات حسب النص المدخل
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return tasks;
    
    final lowercaseQuery = query.toLowerCase();
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery) ||
             (task.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Private methods
  /// تطبيق الفلترة حسب `status`, `priority`, `category` ثم ترتيب النتائج
  /// - الترتيب حسب `priority` يعتمد على `priorityScore`
  /// - عند الترتيب حسب `dueDate` يتم التعامل مع القيم null بحيث تأتي في النهاية
  /// - تتم المزامنة مع Hive عبر `_saveTasksToHive()` عند أي تعديل
  List<Task> _getFilteredAndSortedTasks() {
    var filteredTasks = _tasks.where((task) {
      // Status filter
      if (_filterStatus != 'all' && task.status != _filterStatus) {
        return false;
      }
      
      // Priority filter
      if (_filterPriority != 'all' && task.priority != _filterPriority) {
        return false;
      }
      
      // Category filter
      if (_filterCategory != null && task.categoryId != _filterCategory) {
        return false;
      }
      
      return true;
    }).toList();

    // Sort tasks
    filteredTasks.sort((a, b) {
      switch (_sortBy) {
        case 'priority':
          // استخدام درجة الأولوية الرقمية للترتيب (urgent=4..low=1)
          return b.priorityScore.compareTo(a.priorityScore);
        case 'dueDate':
          // التعامل مع القيم الخالية بحيث تظهر المهام بلا موعد لاحقاً
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case 'createdAt':
          return b.createdAt.compareTo(a.createdAt);
        default:
          return b.priorityScore.compareTo(a.priorityScore);
      }
    });

    return filteredTasks;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> _loadTasksFromHive() async {
    final taskBox = await Hive.openBox<Task>('tasks');
    _tasks.clear();
    _tasks.addAll(taskBox.values);
  }

  Future<void> _saveTasksToHive() async {
    final taskBox = await Hive.openBox<Task>('tasks');
    await taskBox.clear();
    
    for (int i = 0; i < _tasks.length; i++) {
      await taskBox.put(i, _tasks[i]);
    }
  }
}
