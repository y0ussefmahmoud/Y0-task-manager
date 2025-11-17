@echo off
title Y0 Task Manager - إصلاح طارئ
color 0C

echo.
echo 🚨 إصلاح طارئ لأخطاء البناء...
echo.

cd frontend

echo 🧹 تنظيف شامل...
call flutter clean

echo 📦 إعادة تحميل المكتبات...
call flutter pub get

echo 🔧 إعادة بناء ملفات Hive...
call flutter packages pub run build_runner clean
call flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo ⚡ محاولة تشغيل سريع...
call flutter run -d chrome --web-port=3000

pause
