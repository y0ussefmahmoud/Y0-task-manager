@echo off
title Y0 Task Manager - اختبار جميع المنصات
color 0A

echo.
echo 🧪 اختبار Y0 Task Manager على جميع المنصات...
echo.

cd frontend

echo 🔧 تنظيف وإعداد المشروع...
call flutter clean
call flutter pub get
call flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo ════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
echo.

echo 🌐 اختبار تطبيق الويب...
echo.
start "Y0 Task Manager - Web Test" cmd /c "flutter run -d chrome --web-port=3000"
timeout /t 5 /nobreak

echo.
echo 📱 اختبار تطبيق Android (إذا كان متصل)...
flutter devices | findstr "android" >nul
if %errorlevel% == 0 (
    echo ✅ جهاز Android متصل - بدء الاختبار...
    start "Y0 Task Manager - Android Test" cmd /c "flutter run -d android"
    timeout /t 5 /nobreak
) else (
    echo ⚠️  لا يوجد جهاز Android متصل
)

echo.
echo 🖥️ اختبار تطبيق Windows Desktop...
flutter devices | findstr "windows" >nul
if %errorlevel% == 0 (
    echo ✅ Windows Desktop متاح - بدء الاختبار...
    start "Y0 Task Manager - Windows Test" cmd /c "flutter run -d windows"
    timeout /t 5 /nobreak
) else (
    echo ⚠️  Windows Desktop غير متاح
)

echo.
echo 🍎 فحص دعم iOS...
flutter devices | findstr "ios" >nul
if %errorlevel% == 0 (
    echo ✅ جهاز iOS متصل - يمكن الاختبار يدوياً
    echo    تشغيل: flutter run -d ios
) else (
    echo ⚠️  لا يوجد جهاز iOS متصل (يتطلب macOS + Xcode)
)

echo.
echo 🍎 فحص دعم macOS...
flutter devices | findstr "macos" >nul
if %errorlevel% == 0 (
    echo ✅ macOS Desktop متاح - يمكن الاختبار يدوياً
    echo    تشغيل: flutter run -d macos
) else (
    echo ⚠️  macOS Desktop غير متاح (يتطلب macOS)
)

echo.
echo 🐧 فحص دعم Linux...
flutter devices | findstr "linux" >nul
if %errorlevel% == 0 (
    echo ✅ Linux Desktop متاح - يمكن الاختبار يدوياً
    echo    تشغيل: flutter run -d linux
) else (
    echo ⚠️  Linux Desktop غير متاح (يتطلب Linux)
)

echo.
echo ════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
echo.
echo 📋 ملخص الاختبار:
echo.
echo 🌐 Web: تم تشغيله على http://localhost:3000
echo 📱 Android: %android_status%
echo 🖥️ Windows: تم تشغيله إذا كان متاحاً
echo 🍎 iOS: يتطلب macOS + Xcode + جهاز iOS
echo 🍎 macOS: يتطلب macOS
echo 🐧 Linux: يتطلب Linux
echo.
echo 🎯 نصائح الاختبار:
echo    1. اختبر الميزات الأساسية على كل منصة
echo    2. تأكد من التصميم المتجاوب
echo    3. اختبر الإشعارات (على المنصات المدعومة)
echo    4. اختبر التخزين المحلي
echo    5. اختبر مزامنة البيانات مع Backend
echo.
echo 📱 لاختبار منصة معينة:
echo    flutter run -d chrome      # Web
echo    flutter run -d android     # Android
echo    flutter run -d ios         # iOS
echo    flutter run -d windows     # Windows
echo    flutter run -d macos       # macOS
echo    flutter run -d linux       # Linux
echo.
echo ✅ انتهى الاختبار! تحقق من النوافذ المفتوحة لرؤية التطبيق يعمل.
echo.

pause
