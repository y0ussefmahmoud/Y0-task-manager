import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize
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

  // Add category
  Future<bool> addCategory({
    required String name,
    String color = '#6366F1',
    String icon = 'folder',
    String? description,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Check if category name already exists
      if (_categories.any((cat) => cat.name.toLowerCase() == name.toLowerCase())) {
        _setError('اسم الفئة موجود بالفعل');
        return false;
      }

      final category = Category(
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

  // Update category
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
          orElse: () => Category(id: '', name: ''),
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

  // Delete category
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

  // Get category by ID
  Category? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Get category by name
  Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere(
        (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Search categories
  List<Category> searchCategories(String query) {
    if (query.isEmpty) return categories;
    
    final lowercaseQuery = query.toLowerCase();
    return _categories.where((category) {
      return category.name.toLowerCase().contains(lowercaseQuery) ||
             (category.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Get default categories
  List<Category> getDefaultCategories() {
    return _categories.where((cat) => cat.isDefault).toList();
  }

  // Get custom categories
  List<Category> getCustomCategories() {
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
    final categoryBox = await Hive.openBox<Category>('categories');
    _categories.clear();
    _categories.addAll(categoryBox.values);
  }

  Future<void> _saveCategoriesToHive() async {
    final categoryBox = await Hive.openBox<Category>('categories');
    await categoryBox.clear();
    
    for (int i = 0; i < _categories.length; i++) {
      await categoryBox.put(i, _categories[i]);
    }
  }

  Future<void> _createDefaultCategories() async {
    final defaultCategories = Category.getDefaultCategories();
    
    for (final category in defaultCategories) {
      _categories.add(category);
    }
    
    await _saveCategoriesToHive();
    notifyListeners();
  }
}
