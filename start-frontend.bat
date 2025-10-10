@echo off
echo 📱 بدء تشغيل Y0 Task Manager Frontend...
echo.

cd frontend

echo 📦 تثبيت المكتبات...
call flutter pub get

echo.
echo 🔧 إنشاء ملفات Hive...
call flutter packages pub run build_runner build

echo.
echo 🚀 بدء تشغيل التطبيق على Chrome...
call flutter run -d chrome --web-port=3000

pause
