import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

import '../../../core/models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  // Initialize auth state
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

  // Login
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

  // Register
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

  // Logout
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

  // Update user profile
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

  // Add XP to user
  void addXp(int xp) {
    if (_user != null) {
      _user!.addXp(xp);
      _saveAuthData();
      notifyListeners();
    }
  }

  // Update streak
  void updateStreak() {
    if (_user != null) {
      _user!.updateStreak();
      _saveAuthData();
      notifyListeners();
    }
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
