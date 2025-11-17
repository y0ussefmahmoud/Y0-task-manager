import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/models/category.dart' as TaskCategory;
import '../../../core/services/hive_service.dart';
import 'package:uuid/uuid.dart';

/// Provider لإدارة حالة الفئات في التطبيق
/// 
/// يوفر هذا الـ Provider جميع العمليات المتعلقة بالفئات:
/// - إضافة، تعديل، حذف الفئات
/// - البحث في الفئات
/// - إنشاء الفئات الافتراضية
/// - التخزين المحلي باستخدام Hive
class CategoryProvider extends ChangeNotifier {
  final List<TaskCategory.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  /// قائمة الفئات المتاحة
  List<TaskCategory.Category> get categories => List.unmodifiable(_categories);
  /// حالة التحميل
  bool get isLoading => _isLoading;
  /// رسالة الخطأ
  String? get error => _error;

  /// تحميل الفئات من Hive وإنشاء الفئات الافتراضية إذا لم تكن موجودة
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      await _loadCategoriesFromHive();
      
      // If no categories exist, create default ones
      if (_categories.isEmpty) {
        await _createDefaultCategories();
      }
    } catch (e) {
      _setError('فشل في تحميل الفئات');
      debugPrint('Category initialization error: $e');
    }
    
    _setLoading(false);
  }

  /// إضافة فئة جديدة مع التحقق من عدم تكرار الاسم
  /// يستخدم Hive للتخزين المحلي
  Future<bool> addCategory({
    required String name,
    String color = '#6366F1',
    String icon = 'folder',
    String? description,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      // التحقق من تكرار الاسم (case-insensitive) قبل الإضافة
      if (_categories.any((cat) => cat.name.toLowerCase() == name.toLowerCase())) {
        _setError('اسم الفئة موجود بالفعل');
        return false;
      }

      final category = TaskCategory.Category(
        id: const Uuid().v4(),
        name: name,
        color: color,
        icon: icon,
        description: description,
      );

      _categories.add(category);
      await _saveCategoriesToHive();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل في إضافة الفئة');
      debugPrint('Add category error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تحديث الفئة مع التحقق من عدم تكرار الاسم الجديد
  Future<bool> updateCategory(String categoryId, {
    String? name,
    String? color,
    String? icon,
    String? description,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final categoryIndex = _categories.indexWhere((cat) => cat.id == categoryId);
      if (categoryIndex == -1) {
        _setError('الفئة غير موجودة');
        return false;
      }

      // Check if new name already exists (excluding current category)
      if (name != null) {
        final existingCategory = _categories.firstWhere(
          (cat) => cat.name.toLowerCase() == name.toLowerCase() && cat.id != categoryId,
          orElse: () => TaskCategory.Category(id: '', name: ''),
        );
        
        if (existingCategory.id.isNotEmpty) {
          _setError('اسم الفئة موجود بالفعل');
          return false;
        }
      }

      final updatedCategory = _categories[categoryIndex].copyWith(
        name: name,
        color: color,
        icon: icon,
        description: description,
      );

      _categories[categoryIndex] = updatedCategory;
      await _saveCategoriesToHive();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل في تحديث الفئة');
      debugPrint('Update category error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// حذف الفئة مع منع حذف الفئات الافتراضية
  Future<bool> deleteCategory(String categoryId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final categoryIndex = _categories.indexWhere((cat) => cat.id == categoryId);
      if (categoryIndex == -1) {
        _setError('الفئة غير موجودة');
        return false;
      }

      final category = _categories[categoryIndex];
      
      // Don't allow deleting default categories
      if (category.isDefault) {
        _setError('لا يمكن حذف الفئات الافتراضية');
        return false;
      }

      _categories.removeAt(categoryIndex);
      await _saveCategoriesToHive();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل في حذف الفئة');
      debugPrint('Delete category error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// جلب فئة عبر المعرف
  TaskCategory.Category? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// جلب فئة عبر الاسم
  TaskCategory.Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere(
        (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// البحث في اسم ووصف الفئات عن طريق النص المدخل
  List<TaskCategory.Category> searchCategories(String query) {
    if (query.isEmpty) return categories;
    
    final lowercaseQuery = query.toLowerCase();
    return _categories.where((category) {
      return category.name.toLowerCase().contains(lowercaseQuery) ||
             (category.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// إرجاع قائمة الفئات الافتراضية
  List<TaskCategory.Category> getDefaultCategories() {
    return _categories.where((cat) => cat.isDefault).toList();
  }

  /// إرجاع قائمة الفئات المخصصة (غير الافتراضية)
  List<TaskCategory.Category> getCustomCategories() {
    return _categories.where((cat) => !cat.isDefault).toList();
  }

  // Private methods
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

  Future<void> _loadCategoriesFromHive() async {
    // استخدام Hive Box لتخزين الفئات محلياً
    final categoryBox = await Hive.openBox<TaskCategory.Category>('categories');
    _categories.clear();
    _categories.addAll(categoryBox.values);
  }

  Future<void> _saveCategoriesToHive() async {
    final categoryBox = await Hive.openBox<TaskCategory.Category>('categories');
    await categoryBox.clear();
    
    for (int i = 0; i < _categories.length; i++) {
      await categoryBox.put(i, _categories[i]);
    }
  }

  Future<void> _createDefaultCategories() async {
    final defaultCategories = TaskCategory.Category.getDefaultCategories();
    
    for (final category in defaultCategories) {
      _categories.add(category);
    }
    
    await _saveCategoriesToHive();
    notifyListeners();
  }
}
