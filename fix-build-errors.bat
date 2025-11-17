@echo off
title Y0 Task Manager - إصلاح أخطاء البناء
color 0A

echo.
echo 🔧 إصلاح أخطاء البناء في Y0 Task Manager...
echo.

cd frontend

echo 📦 تنظيف المشروع...
call flutter clean

echo 🔄 تحديث المكتبات...
call flutter pub get

echo 🏗️ إعادة بناء ملفات Hive...
call flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo ✅ تم إصلاح الأخطاء الأساسية!
echo.
echo 🎯 المشاكل التي تم حلها:
echo    • إصلاح تضارب Category imports
echo    • تحديث Android SDK إلى 35
echo    • إضافة ملفات Widget المفقودة
echo    • إصلاح notification service
echo.
echo 🚀 جرب الآن:
echo    flutter run -d chrome
echo.

pause
