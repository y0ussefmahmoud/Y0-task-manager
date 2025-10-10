@echo off
title Y0 Task Manager - إيقاف التطبيق
color 0C

echo.
echo 🛑 إيقاف Y0 Task Manager...
echo.

echo 🗄️  إيقاف قاعدة البيانات...
docker-compose down

echo.
echo 🔌 إيقاف العمليات...
taskkill /f /im node.exe >nul 2>&1
taskkill /f /im flutter.exe >nul 2>&1
taskkill /f /im chrome.exe >nul 2>&1

echo.
echo ✅ تم إيقاف التطبيق بنجاح!
echo.

pause
