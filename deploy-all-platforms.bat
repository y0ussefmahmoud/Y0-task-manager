@echo off
title Y0 Task Manager - نشر جميع المنصات
color 0A

echo.
echo 🚀 نشر Y0 Task Manager على جميع المنصات...
echo.

cd frontend

echo 🔧 إعداد المشروع...
call flutter clean
call flutter pub get
call flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo ════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
echo.

echo 📦 إنشاء مجلد التوزيع...
if not exist "..\dist" mkdir "..\dist"
if not exist "..\dist\android" mkdir "..\dist\android"
if not exist "..\dist\ios" mkdir "..\dist\ios"
if not exist "..\dist\windows" mkdir "..\dist\windows"
if not exist "..\dist\macos" mkdir "..\dist\macos"
if not exist "..\dist\linux" mkdir "..\dist\linux"
if not exist "..\dist\web" mkdir "..\dist\web"

echo.
echo 🌐 بناء تطبيق الويب...
call flutter build web --release
if exist "build\web" (
    echo ✅ تم بناء Web بنجاح
    xcopy "build\web\*" "..\dist\web\" /E /I /Y >nul
    echo 📁 ملفات Web: dist\web\
) else (
    echo ❌ فشل في بناء Web
)

echo.
echo 📱 بناء تطبيق Android...
call flutter build apk --release
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ تم بناء Android APK بنجاح
    copy "build\app\outputs\flutter-apk\app-release.apk" "..\dist\android\Y0TaskManager.apk" >nul
    echo 📁 ملف Android: dist\android\Y0TaskManager.apk
) else (
    echo ❌ فشل في بناء Android APK
)

call flutter build appbundle --release
if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo ✅ تم بناء Android App Bundle بنجاح
    copy "build\app\outputs\bundle\release\app-release.aab" "..\dist\android\Y0TaskManager.aab" >nul
    echo 📁 ملف App Bundle: dist\android\Y0TaskManager.aab
) else (
    echo ❌ فشل في بناء Android App Bundle
)

echo.
echo 🖥️ بناء تطبيق Windows...
call flutter build windows --release
if exist "build\windows\x64\runner\Release" (
    echo ✅ تم بناء Windows بنجاح
    xcopy "build\windows\x64\runner\Release\*" "..\dist\windows\" /E /I /Y >nul
    echo 📁 ملفات Windows: dist\windows\
) else (
    echo ❌ فشل في بناء Windows
)

echo.
echo 🍎 محاولة بناء iOS (يتطلب macOS)...
call flutter build ios --release
if exist "build\ios\Release-iphoneos" (
    echo ✅ تم بناء iOS بنجاح
    xcopy "build\ios\Release-iphoneos\*" "..\dist\ios\" /E /I /Y >nul
    echo 📁 ملفات iOS: dist\ios\
) else (
    echo ⚠️  iOS غير متاح (يتطلب macOS + Xcode)
)

echo.
echo 🍎 محاولة بناء macOS (يتطلب macOS)...
call flutter build macos --release
if exist "build\macos\Build\Products\Release" (
    echo ✅ تم بناء macOS بنجاح
    xcopy "build\macos\Build\Products\Release\*" "..\dist\macos\" /E /I /Y >nul
    echo 📁 ملفات macOS: dist\macos\
) else (
    echo ⚠️  macOS غير متاح (يتطلب macOS)
)

echo.
echo 🐧 محاولة بناء Linux (يتطلب Linux)...
call flutter build linux --release
if exist "build\linux\x64\release\bundle" (
    echo ✅ تم بناء Linux بنجاح
    xcopy "build\linux\x64\release\bundle\*" "..\dist\linux\" /E /I /Y >nul
    echo 📁 ملفات Linux: dist\linux\
) else (
    echo ⚠️  Linux غير متاح (يتطلب Linux)
)

echo.
echo ════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
echo.

echo 📊 إنشاء تقرير التوزيع...
echo # Y0 Task Manager - تقرير التوزيع > "..\dist\DISTRIBUTION_REPORT.md"
echo. >> "..\dist\DISTRIBUTION_REPORT.md"
echo تاريخ البناء: %date% %time% >> "..\dist\DISTRIBUTION_REPORT.md"
echo. >> "..\dist\DISTRIBUTION_REPORT.md"
echo ## الملفات المتاحة: >> "..\dist\DISTRIBUTION_REPORT.md"
echo. >> "..\dist\DISTRIBUTION_REPORT.md"

if exist "..\dist\web\index.html" (
    echo - ✅ **Web**: `web/` - تطبيق ويب كامل >> "..\dist\DISTRIBUTION_REPORT.md"
)
if exist "..\dist\android\Y0TaskManager.apk" (
    echo - ✅ **Android APK**: `android/Y0TaskManager.apk` - للتثبيت المباشر >> "..\dist\DISTRIBUTION_REPORT.md"
)
if exist "..\dist\android\Y0TaskManager.aab" (
    echo - ✅ **Android Bundle**: `android/Y0TaskManager.aab` - للنشر على Google Play >> "..\dist\DISTRIBUTION_REPORT.md"
)
if exist "..\dist\windows\y0_task_manager.exe" (
    echo - ✅ **Windows**: `windows/y0_task_manager.exe` - تطبيق Windows >> "..\dist\DISTRIBUTION_REPORT.md"
)
if exist "..\dist\ios" (
    echo - ✅ **iOS**: `ios/` - تطبيق iOS >> "..\dist\DISTRIBUTION_REPORT.md"
)
if exist "..\dist\macos" (
    echo - ✅ **macOS**: `macos/` - تطبيق macOS >> "..\dist\DISTRIBUTION_REPORT.md"
)
if exist "..\dist\linux" (
    echo - ✅ **Linux**: `linux/` - تطبيق Linux >> "..\dist\DISTRIBUTION_REPORT.md"
)

echo. >> "..\dist\DISTRIBUTION_REPORT.md"
echo ## طرق التثبيت: >> "..\dist\DISTRIBUTION_REPORT.md"
echo. >> "..\dist\DISTRIBUTION_REPORT.md"
echo ### 🌐 Web >> "..\dist\DISTRIBUTION_REPORT.md"
echo ارفع مجلد `web/` على أي خادم ويب >> "..\dist\DISTRIBUTION_REPORT.md"
echo. >> "..\dist\DISTRIBUTION_REPORT.md"
echo ### 📱 Android >> "..\dist\DISTRIBUTION_REPORT.md"
echo - **APK**: انسخ إلى الهاتف وثبت مباشرة >> "..\dist\DISTRIBUTION_REPORT.md"
echo - **AAB**: ارفع على Google Play Console >> "..\dist\DISTRIBUTION_REPORT.md"
echo. >> "..\dist\DISTRIBUTION_REPORT.md"
echo ### 💻 Windows >> "..\dist\DISTRIBUTION_REPORT.md"
echo شغل `y0_task_manager.exe` مباشرة >> "..\dist\DISTRIBUTION_REPORT.md"
echo. >> "..\dist\DISTRIBUTION_REPORT.md"

echo 📋 إنشاء ملف README للتوزيع...
echo # Y0 Task Manager - ملفات التوزيع > "..\dist\README.md"
echo. >> "..\dist\README.md"
echo 🎉 **مرحباً بك في Y0 Task Manager!** >> "..\dist\README.md"
echo. >> "..\dist\README.md"
echo هذا المجلد يحتوي على جميع ملفات التطبيق الجاهزة للتثبيت والاستخدام. >> "..\dist\README.md"
echo. >> "..\dist\README.md"
echo ## 🚀 التثبيت السريع >> "..\dist\README.md"
echo. >> "..\dist\README.md"
echo ### 📱 Android >> "..\dist\README.md"
echo 1. انسخ `android/Y0TaskManager.apk` إلى هاتفك >> "..\dist\README.md"
echo 2. فعل "مصادر غير معروفة" في الإعدادات >> "..\dist\README.md"
echo 3. اضغط على الملف لتثبيته >> "..\dist\README.md"
echo. >> "..\dist\README.md"
echo ### 💻 Windows >> "..\dist\README.md"
echo 1. انسخ مجلد `windows/` إلى مكان مناسب >> "..\dist\README.md"
echo 2. شغل `y0_task_manager.exe` >> "..\dist\README.md"
echo. >> "..\dist\README.md"
echo ### 🌐 Web >> "..\dist\README.md"
echo 1. ارفع مجلد `web/` على خادم ويب >> "..\dist\README.md"
echo 2. افتح `index.html` في المتصفح >> "..\dist\README.md"
echo. >> "..\dist\README.md"

echo.
echo ✅ تم إنشاء ملفات التوزيع بنجاح!
echo.
echo 📁 مجلد التوزيع: dist\
echo 📋 تقرير التوزيع: dist\DISTRIBUTION_REPORT.md
echo 📖 دليل التثبيت: dist\README.md
echo.
echo 🎯 الخطوات التالية:
echo    1. اختبر الملفات على الأجهزة المختلفة
echo    2. ارفع على متاجر التطبيقات حسب الحاجة
echo    3. شارك الملفات مع المستخدمين
echo.
echo 📦 أحجام الملفات التقريبية:
if exist "..\dist\android\Y0TaskManager.apk" (
    for %%I in ("..\dist\android\Y0TaskManager.apk") do echo    Android APK: %%~zI bytes
)
if exist "..\dist\windows\y0_task_manager.exe" (
    for %%I in ("..\dist\windows\y0_task_manager.exe") do echo    Windows EXE: %%~zI bytes
)

echo.
echo ════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════

pause
