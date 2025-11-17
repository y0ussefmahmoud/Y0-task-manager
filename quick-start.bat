@echo off
title Y0 Task Manager - البدء السريع
color 0A

echo.
echo  ██╗   ██╗ ██████╗     ████████╗ █████╗ ███████╗██╗  ██╗    ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗ 
echo  ╚██╗ ██╔╝██╔═████╗    ╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗
echo   ╚████╔╝ ██║██╔██║       ██║   ███████║███████╗█████╔╝     ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝
echo    ╚██╔╝  ████╔╝██║       ██║   ██╔══██║╚════██║██╔═██╗     ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗
echo     ██║   ╚██████╔╝       ██║   ██║  ██║███████║██║  ██╗    ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║
echo     ╚═╝    ╚═════╝        ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
echo.
echo                                      🚀 البدء السريع - 3 دقائق فقط! 🚀
echo                                    تطبيق إدارة المهام الذكي مع نظام التحفيز
echo.
echo ════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
echo.

echo 🎯 اختر طريقة البدء:
echo.
echo    1️⃣  تشغيل سريع على الويب (الأسرع - دقيقة واحدة)
echo    2️⃣  تشغيل التطبيق كاملاً مع قاعدة البيانات (3 دقائق)
echo    3️⃣  إعداد المنصات المتعددة (5 دقائق)
echo    4️⃣  بناء التطبيق للتوزيع (10 دقائق)
echo    5️⃣  عرض معلومات المشروع
echo    0️⃣  خروج
echo.

set /p choice="اختر رقم (1-5): "

if "%choice%"=="1" goto web_quick
if "%choice%"=="2" goto full_app
if "%choice%"=="3" goto setup_platforms
if "%choice%"=="4" goto build_all
if "%choice%"=="5" goto show_info
if "%choice%"=="0" goto exit
goto invalid_choice

:web_quick
echo.
echo 🌐 تشغيل سريع على الويب...
echo.
cd frontend
echo 📦 تحديث المكتبات...
call flutter pub get
echo 🚀 بدء التشغيل...
start "Y0 Task Manager - Web" cmd /c "flutter run -d chrome --web-port=3000"
echo.
echo ✅ تم! افتح المتصفح على: http://localhost:3000
echo 👤 بيانات الاختبار: demo@y0.com / password
echo.
goto end

:full_app
echo.
echo 🚀 تشغيل التطبيق كاملاً...
echo.
call start-app.bat
goto end

:setup_platforms
echo.
echo 🔧 إعداد المنصات المتعددة...
echo.
call setup-platforms.bat
goto end

:build_all
echo.
echo 📦 بناء التطبيق للتوزيع...
echo.
call deploy-all-platforms.bat
goto end

:show_info
echo.
echo 📋 معلومات Y0 Task Manager:
echo.
echo 🎯 الهدف: تطبيق إدارة المهام الذكي مع نظام التحفيز والنقاط
echo.
echo 🛠️ التقنيات:
echo    • Frontend: Flutter (جميع المنصات)
echo    • Backend: Node.js + Express + MySQL
echo    • UI: Material Design 3 + RTL Support
echo    • Storage: Hive (محلي) + MySQL (خادم)
echo.
echo 📱 المنصات المدعومة:
echo    • 🌐 Web (PWA)
echo    • 📱 Android
echo    • 🍎 iOS
echo    • 💻 Windows Desktop
echo    • 🍎 macOS Desktop
echo    • 🐧 Linux Desktop
echo.
echo ✨ المميزات:
echo    • إدارة المهام الكاملة
echo    • نظام النقاط والمستويات
echo    • الفئات والعلامات
echo    • التذكيرات والإشعارات
echo    • الإحصائيات والتقارير
echo    • واجهة عربية جميلة
echo.
echo 🌐 الروابط:
echo    • التطبيق: http://localhost:3000
echo    • API: http://localhost:3001/api
echo    • قاعدة البيانات: http://localhost:8080
echo.
echo 👤 بيانات الاختبار:
echo    • Email: demo@y0.com
echo    • Password: password
echo.
echo 📁 الملفات المهمة:
echo    • start-app.bat - تشغيل كامل
echo    • setup-platforms.bat - إعداد المنصات
echo    • build-android.bat - بناء Android
echo    • build-desktop.bat - بناء Desktop
echo    • FINAL_SETUP_GUIDE.md - الدليل الشامل
echo.
goto menu

:invalid_choice
echo.
echo ❌ اختيار غير صحيح! يرجى اختيار رقم من 1-5
echo.
goto menu

:menu
echo.
echo ════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
echo.
set /p continue="هل تريد العودة للقائمة الرئيسية؟ (y/n): "
if /i "%continue%"=="y" goto start
if /i "%continue%"=="yes" goto start
goto end

:start
cls
goto begin

:begin
echo.
echo  ██╗   ██╗ ██████╗     ████████╗ █████╗ ███████╗██╗  ██╗    ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗ 
echo  ╚██╗ ██╔╝██╔═████╗    ╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗
echo   ╚████╔╝ ██║██╔██║       ██║   ███████║███████╗█████╔╝     ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝
echo    ╚██╔╝  ████╔╝██║       ██║   ██╔══██║╚════██║██╔═██╗     ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗
echo     ██║   ╚██████╔╝       ██║   ██║  ██║███████║██║  ██╗    ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║
echo     ╚═╝    ╚═════╝        ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
echo.
echo                                      🚀 البدء السريع - 3 دقائق فقط! 🚀
echo                                    تطبيق إدارة المهام الذكي مع نظام التحفيز
echo.
echo ════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
echo.

echo 🎯 اختر طريقة البدء:
echo.
echo    1️⃣  تشغيل سريع على الويب (الأسرع - دقيقة واحدة)
echo    2️⃣  تشغيل التطبيق كاملاً مع قاعدة البيانات (3 دقائق)
echo    3️⃣  إعداد المنصات المتعددة (5 دقائق)
echo    4️⃣  بناء التطبيق للتوزيع (10 دقائق)
echo    5️⃣  عرض معلومات المشروع
echo    0️⃣  خروج
echo.

set /p choice="اختر رقم (1-5): "

if "%choice%"=="1" goto web_quick
if "%choice%"=="2" goto full_app
if "%choice%"=="3" goto setup_platforms
if "%choice%"=="4" goto build_all
if "%choice%"=="5" goto show_info
if "%choice%"=="0" goto exit
goto invalid_choice

:end
echo.
echo 🎉 شكراً لاستخدام Y0 Task Manager!
echo.
echo 💡 نصائح سريعة:
echo    • استخدم نظام النقاط للتحفيز
echo    • نظم مهامك بالفئات والأولويات
echo    • فعل التذكيرات للمواعيد المهمة
echo    • راجع الإحصائيات لتتبع تقدمك
echo.
echo 📞 للدعم والمساعدة:
echo    • GitHub: https://github.com/yourusername/y0-task-manager
echo    • Email: support@y0taskmanager.com
echo.

:exit
pause
