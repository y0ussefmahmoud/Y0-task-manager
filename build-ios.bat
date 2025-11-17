@echo off
title Y0 Task Manager - بناء تطبيق iOS
color 0A

echo.
echo 🍎 بناء Y0 Task Manager لنظام iOS...
echo.

cd frontend

echo 🔧 تنظيف المشروع...
call flutter clean

echo 📦 تحديث المكتبات...
call flutter pub get

echo 🏗️ إنشاء ملفات Hive...
call flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo ⚠️  ملاحظة مهمة:
echo    بناء تطبيق iOS يتطلب جهاز Mac مع Xcode
echo    هذا الأمر سيعمل فقط على macOS
echo.

echo 🚀 بناء iOS (يتطلب macOS + Xcode)...
call flutter build ios --release

echo.
echo 📦 بناء IPA للتوزيع...
call flutter build ipa --release

echo.
echo ✅ تم بناء التطبيق بنجاح! (إذا كنت على macOS)
echo.
echo 📁 ملفات التطبيق:
echo    iOS Build: build\ios\Release-iphoneos\Runner.app
echo    IPA File: build\ios\ipa\y0_task_manager.ipa
echo.
echo 📋 خطوات النشر على App Store:
echo    1. افتح Xcode
echo    2. اختر Product → Archive
echo    3. استخدم Organizer للرفع على App Store Connect
echo.
echo 💡 للتطوير على iOS:
echo    - تحتاج Apple Developer Account ($99/سنة)
echo    - تحتاج جهاز Mac مع Xcode
echo    - تحتاج iPhone/iPad للاختبار
echo.

pause
