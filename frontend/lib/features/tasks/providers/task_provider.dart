import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/task.dart';
import '../../../core/services/notification_service.dart';

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

  // Initialize
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

  // Add task
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

  // Update task
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

  // Delete task
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

  // Complete task
  Future<bool> completeTask(String taskId) async {
    return await updateTask(taskId, status: 'completed');
  }

  // Get task by ID
  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // Search tasks
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return tasks;
    
    final lowercaseQuery = query.toLowerCase();
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery) ||
             (task.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Set filters and sorting
  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterPriority(String priority) {
    _filterPriority = priority;
    notifyListeners();
  }

  void setFilterCategory(String? categoryId) {
    _filterCategory = categoryId;
    notifyListeners();
  }

  void clearFilters() {
    _filterStatus = 'all';
    _filterPriority = 'all';
    _filterCategory = null;
    notifyListeners();
  }

  // Get tasks by category
  List<Task> getTasksByCategory(String categoryId) {
    return _tasks.where((task) => task.categoryId == categoryId).toList();
  }

  // Get tasks by date range
  List<Task> getTasksByDateRange(DateTime start, DateTime end) {
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(start) && task.dueDate!.isBefore(end);
    }).toList();
  }

  // Get today's tasks
  List<Task> getTodaysTasks() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(startOfDay) && task.dueDate!.isBefore(endOfDay);
    }).toList();
  }

  // Private methods
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
          return b.priorityScore.compareTo(a.priorityScore);
        case 'dueDate':
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
