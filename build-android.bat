@echo off
title Y0 Task Manager - بناء تطبيق Android
color 0A

echo.
echo 📱 بناء Y0 Task Manager لنظام Android...
echo.

cd frontend

echo 🔧 تنظيف المشروع...
call flutter clean

echo 📦 تحديث المكتبات...
call flutter pub get

echo 🏗️ إنشاء ملفات Hive...
call flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo 🚀 بناء APK للإصدار التجريبي...
call flutter build apk --debug

echo.
echo 🎯 بناء APK للإصدار النهائي...
call flutter build apk --release

echo.
echo 📦 بناء App Bundle للنشر على Google Play...
call flutter build appbundle --release

echo.
echo ✅ تم بناء التطبيق بنجاح!
echo.
echo 📁 ملفات التطبيق:
echo    Debug APK: build\app\outputs\flutter-apk\app-debug.apk
echo    Release APK: build\app\outputs\flutter-apk\app-release.apk
echo    App Bundle: build\app\outputs\bundle\release\app-release.aab
echo.
echo 📋 خطوات التثبيت:
echo    1. انسخ ملف APK إلى هاتفك
echo    2. فعل "مصادر غير معروفة" في الإعدادات
echo    3. اضغط على ملف APK لتثبيته
echo.

pause
