import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:window_manager/window_manager.dart';

/// نقطة البداية الرئيسية لتطبيق Y0 Task Manager
/// 
/// يقوم هذا الملف بـ:
/// - تهيئة Flutter و Hive
/// - تهيئة الإشعارات (على المنصات المدعومة)
/// - تهيئة Window Manager للـ Desktop
/// - إعداد Providers (Auth, Task, Category, AI)
/// - إعداد الثيمات والتوجيه (Router)

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/utils/platform_utils.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/tasks/providers/task_provider.dart';
import 'features/categories/providers/category_provider.dart';
import 'features/ai/providers/ai_provider.dart';
import 'core/services/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// نقطة البداية وتسلسل التهيئة للتطبيق
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize platform-specific features
  await _initializePlatform();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize Notifications (only on supported platforms)
  if (PlatformUtils.supportsNotifications) {
    await NotificationService.initialize();
  }
  
  runApp(const Y0TaskManagerApp());
}

/// تهيئة الميزات الخاصة بكل منصة (إعداد نافذة سطح المكتب)
Future<void> _initializePlatform() async {
  // Desktop-specific initialization
  if (PlatformUtils.isDesktop) {
    await windowManager.ensureInitialized();
    
    WindowOptions windowOptions = WindowOptions(
      size: PlatformUtils.getDefaultWindowSize(),
      minimumSize: PlatformUtils.getMinimumWindowSize(),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Y0 Task Manager',
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

class Y0TaskManagerApp extends StatelessWidget {
  const Y0TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // إعداد مزودي الحالة عبر MultiProvider لإدارة الحالة على مستوى التطبيق
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
      ],
      child: MaterialApp.router(
        title: 'Y0 Task Manager',
        debugShowCheckedModeBanner: false,
        // إعدادات الثيم: وضع فاتح/غامق مع دعم النظام
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        // إعداد التوجيه عبر GoRouter
        routerConfig: AppRouter.router,
        // إعدادات اللغة: العربية كلغة افتراضية مع دعم الإنجليزية
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [
          Locale('ar', 'SA'),
          Locale('en', 'US'),
        ],
      ),
    );
  }
}
