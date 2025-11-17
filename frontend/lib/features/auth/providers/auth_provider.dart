import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

import '../../../core/models/user.dart';
import '../services/auth_service.dart';

/// Provider لإدارة حالة المصادقة والمستخدم
/// 
/// يوفر هذا الـ Provider جميع العمليات المتعلقة بالمصادقة:
/// - تسجيل الدخول والخروج
/// - إنشاء حساب جديد
/// - تحديث الملف الشخصي
/// - إدارة نظام التحفيز (XP, Level, Streak)
/// - التخزين المحلي باستخدام SharedPreferences و Hive
/// - التحقق من صلاحية الـ token
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  /// الحصول على المستخدم الحالي (اسم بديل للتوافق)
  User? get currentUser => _user; 
  /// الحصول على الـ token الحالي
  String? get token => _token;
  /// الحصول على حالة التحميل
  bool get isLoading => _isLoading;
  /// الحصول على رسالة الخطأ الحالية
  String? get error => _error;
  /// التحقق من حالة المصادقة
  bool get isAuthenticated => _user != null && _token != null;

  /// تحميل بيانات المصادقة من التخزين المحلي والتحقق من صلاحية الـ token
  /// 
  /// يتم تحميل الـ token من SharedPreferences والمستخدم من Hive، ثم التحقق من صلاحية الـ token مع الخادم
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      
      if (savedToken != null) {
        _token = savedToken;
        
        // Try to load user from Hive
        final userBox = await Hive.openBox<User>('users');
        final savedUser = userBox.get('current_user');
        
        if (savedUser != null) {
          _user = savedUser;
          notifyListeners();
        }
        
        // Validate token with server
        await _validateToken();
      }
    } catch (e) {
      _setError('فشل في تحميل بيانات المصادقة');
      debugPrint('Auth initialization error: $e');
    }
    
    _setLoading(false);
  }

  /// تسجيل الدخول وحفظ الـ token والمستخدم محلياً عند النجاح
  /// 
  /// يتم إرسال طلب تسجيل الدخول إلى الخادم، ثم حفظ الـ token والمستخدم في SharedPreferences و Hive عند النجاح
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.login(email, password);
      
      if (result['success']) {
        _user = User.fromJson(result['data']['user']);
        _token = result['data']['token'];
        
        // Save to local storage
        await _saveAuthData();
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'فشل في تسجيل الدخول');
        return false;
      }
    } catch (e) {
      _setError('خطأ في الاتصال بالخادم');
      debugPrint('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// إنشاء حساب جديد وإرجاع حالة النجاح، مع حفظ البيانات محلياً
  /// 
  /// يتم إرسال طلب إنشاء حساب إلى الخادم، ثم حفظ الـ token والمستخدم في SharedPreferences و Hive عند النجاح
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      
      if (result['success']) {
        _user = User.fromJson(result['data']['user']);
        _token = result['data']['token'];
        
        // Save to local storage
        await _saveAuthData();
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'فشل في إنشاء الحساب');
        return false;
      }
    } catch (e) {
      _setError('خطأ في الاتصال بالخادم');
      debugPrint('Register error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تسجيل الخروج ومسح بيانات المصادقة من SharedPreferences و Hive
  /// 
  /// يتم مسح الـ token والمستخدم من SharedPreferences و Hive، ثم إعادة تعيين حالة المصادقة
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      
      final userBox = await Hive.openBox<User>('users');
      await userBox.delete('current_user');
      
      // Clear state
      _user = null;
      _token = null;
      _clearError();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    
    _setLoading(false);
  }

  /// تحديث بيانات الملف الشخصي (firstName, lastName, timezone, language, theme)
  /// 
  /// يتم إرسال طلب تحديث الملف الشخصي إلى الخادم، ثم حفظ البيانات المحدثة في SharedPreferences و Hive
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? timezone,
    String? language,
    String? theme,
  }) async {
    if (_user == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        timezone: timezone,
        language: language,
        theme: theme,
      );
      
      if (result['success']) {
        _user = User.fromJson(result['data']['user']);
        
        // Save to local storage
        await _saveAuthData();
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'فشل في تحديث الملف الشخصي');
        return false;
      }
    } catch (e) {
      _setError('خطأ في الاتصال بالخادم');
      debugPrint('Update profile error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// إضافة XP للمستخدم وتحديث المستوى تلقائياً (كل 1000 XP = مستوى)
  /// يتم حفظ البيانات محلياً بعد التحديث
  void addXp(int xp) {
    if (_user != null) {
      _user!.addXp(xp);
      _saveAuthData();
      notifyListeners();
    }
  }

  /// تحديث عداد الأيام المتتالية حسب آخر نشاط
  /// يتم حفظ البيانات محلياً بعد التحديث
  void updateStreak() {
    if (_user != null) {
      _user!.updateStreak();
      _saveAuthData();
      notifyListeners();
    }
  }

  // Static method to get XP required for a level
  static int getXpForLevel(int level) {
    if (level <= 1) return 0;
    return (level - 1) * 100; // 100 XP per level
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

  /// حفظ الـ token في SharedPreferences والمستخدم في Hive
Future<void> _saveAuthData() async {
    if (_user != null && _token != null) {
      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      
      // Save user
      final userBox = await Hive.openBox<User>('users');
      await userBox.put('current_user', _user!);
    }
  }

  /// التحقق من صلاحية الـ token مع الخادم وتحديث الحالة، أو تنفيذ logout إذا كان غير صالح
Future<void> _validateToken() async {
    try {
      final result = await _authService.getProfile();
      
      if (result['success']) {
        _user = User.fromJson(result['data']['user']);
        await _saveAuthData();
        notifyListeners();
      } else {
        // Token is invalid, logout
        await logout();
      }
    } catch (e) {
      debugPrint('Token validation error: $e');
      await logout();
    }
  }
}
