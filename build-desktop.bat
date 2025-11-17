@echo off
title Y0 Task Manager - بناء تطبيق سطح المكتب
color 0A

echo.
echo 💻 بناء Y0 Task Manager لسطح المكتب...
echo.

cd frontend

echo 🔧 تنظيف المشروع...
call flutter clean

echo 📦 تحديث المكتبات...
call flutter pub get

echo 🏗️ إنشاء ملفات Hive...
call flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo 🖥️ بناء تطبيق Windows...
call flutter build windows --release

echo.
echo 🍎 بناء تطبيق macOS (يتطلب macOS)...
call flutter build macos --release

echo.
echo 🐧 بناء تطبيق Linux (يتطلب Linux)...
call flutter build linux --release

echo.
echo ✅ تم بناء التطبيق بنجاح!
echo.
echo 📁 ملفات التطبيق:
echo    Windows: build\windows\x64\runner\Release\
echo    macOS: build\macos\Build\Products\Release\
echo    Linux: build\linux\x64\release\bundle\
echo.
echo 🚀 تشغيل التطبيق:
echo    Windows: build\windows\x64\runner\Release\y0_task_manager.exe
echo    macOS: build\macos\Build\Products\Release\Y0TaskManager.app
echo    Linux: build\linux\x64\release\bundle\y0_task_manager
echo.
echo 📦 إنشاء installer (اختياري):
echo    - Windows: استخدم Inno Setup أو NSIS
echo    - macOS: استخدم create-dmg
echo    - Linux: استخدم dpkg أو rpm
echo.

pause
