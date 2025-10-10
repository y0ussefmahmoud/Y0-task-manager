import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3001/api';
  late final Dio _dio;

  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptor for auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired, logout user
          _clearAuthData();
        }
        handler.next(error);
      },
    ));
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      } else {
        return {
          'success': false,
          'message': 'خطأ في الاتصال بالخادم',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع',
      };
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      });

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      } else {
        return {
          'success': false,
          'message': 'خطأ في الاتصال بالخادم',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع',
      };
    }
  }

  // Get Profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      } else {
        return {
          'success': false,
          'message': 'خطأ في الاتصال بالخادم',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع',
      };
    }
  }

  // Update Profile
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? timezone,
    String? language,
    String? theme,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (timezone != null) data['timezone'] = timezone;
      if (language != null) data['language'] = language;
      if (theme != null) data['theme'] = theme;

      final response = await _dio.put('/users/profile', data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      } else {
        return {
          'success': false,
          'message': 'خطأ في الاتصال بالخادم',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع',
      };
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _dio.post('/auth/logout');
      await _clearAuthData();
      return response.data;
    } on DioException catch (e) {
      await _clearAuthData();
      if (e.response != null) {
        return e.response!.data;
      } else {
        return {
          'success': true,
          'message': 'تم تسجيل الخروج محلياً',
        };
      }
    } catch (e) {
      await _clearAuthData();
      return {
        'success': true,
        'message': 'تم تسجيل الخروج محلياً',
      };
    }
  }

  // Clear auth data
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
