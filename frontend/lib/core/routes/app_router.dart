import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

/// نظام التوجيه (Routing) للتطبيق باستخدام GoRouter
/// 
/// يحتوي على جميع مسارات التطبيق:
/// - مسارات المصادقة (Login, Register)
/// - المسارات الرئيسية (Home, Tasks, Categories, Profile)
/// - مسارات الذكاء الاصطناعي (Analytics)
/// - معالجة الأخطاء (404 Page)

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/tasks/screens/task_list_screen.dart';
import '../../features/tasks/screens/add_task_screen.dart';
import '../../features/tasks/screens/task_detail_screen.dart';
import '../../features/categories/screens/categories_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/ai/screens/analytics_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen: الشاشة الافتتاحية لتهيئة التطبيق وتحديد المسار التالي

      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth Routes: مسارات تسجيل الدخول وإنشاء الحساب
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main App Routes: المسارات الأساسية داخل التطبيق بعد المصادقة
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Tasks Routes: إدارة المهام (قائمة، إضافة، تفاصيل، تعديل)
      GoRoute(
        path: '/tasks',
        name: 'tasks',
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: '/tasks/add',
        name: 'add_task',
        builder: (context, state) => const AddTaskScreen(),
      ),
      GoRoute(
        path: '/tasks/:id',
        name: 'task_detail',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          return TaskDetailScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/tasks/:id/edit',
        name: 'edit_task',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          return AddTaskScreen(taskId: taskId);
        },
      ),
      
      // Categories Routes: إدارة الفئات
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      
      // Profile Routes: إدارة الملف الشخصي
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // AI Routes: تحليلات الذكاء الاصطناعي
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
    
    // Error handling: صفحة خطأ مخصصة عند عدم تطابق أي مسار
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('خطأ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'الصفحة غير موجودة',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'المسار: ${state.uri}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
}
